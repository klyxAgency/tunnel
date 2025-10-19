const { spawn } = require('child_process');
const chalk = require('chalk');
const ora = require('ora');
const express = require('express');
const serveIndex = require('serve-index');
const path = require('path');
const fs = require('fs');
const archiver = require('archiver');
const { getConfig, saveProcess } = require('../utils/config');
const { generateFrpcConfig } = require('../utils/frpc-config');
const { downloadFrpc } = require('../utils/downloader');
const { generateSubdomain } = require('../utils/config');

async function execute(folderPath, options) {
  const config = getConfig();
  
  if (!config.token || !config.serverAddr) {
    console.log(chalk.red('❌ Not configured. Please run: klyx-tunnel login'));
    process.exit(1);
  }

  if (!fs.existsSync(folderPath)) {
    console.log(chalk.red(`❌ Folder not found: ${folderPath}`));
    process.exit(1);
  }

  const spinner = ora('Setting up file server...').start();

  try {
    const subdomain = options.name || generateSubdomain();
    const tunnelUrl = `http://${subdomain}.${config.domain}`;

    const app = express();
    
    // Password protection
    if (options.password) {
      app.use((req, res, next) => {
        if (req.path === '/download-all') return next();
        
        const auth = req.headers.authorization;
        if (!auth) {
          res.setHeader('WWW-Authenticate', 'Basic realm="Klyx Tunnel"');
          return res.status(401).send('Authentication required');
        }
        
        const credentials = Buffer.from(auth.split(' ')[1], 'base64').toString();
        const [username, password] = credentials.split(':');
        
        if (password === options.password) {
          next();
        } else {
          res.status(401).send('Invalid password');
        }
      });
    }

    // Download all as ZIP endpoint
    app.get('/download-all', (req, res) => {
      const folderName = path.basename(folderPath);
      const zipName = `${folderName}.zip`;
      
      res.attachment(zipName);
      res.setHeader('Content-Type', 'application/zip');
      
      const archive = archiver('zip', {
        zlib: { level: 9 }
      });
      
      archive.on('error', (err) => {
        console.error('ZIP error:', err);
        res.status(500).send('Error creating ZIP');
      });
      
      archive.pipe(res);
      archive.directory(folderPath, false);
      archive.finalize();
    });

    // Custom HTML with Download All button
    app.get('/', (req, res) => {
      const folderName = path.basename(folderPath);
      const files = fs.readdirSync(folderPath);
      
      let fileListHTML = files.map(file => {
        const filePath = path.join(folderPath, file);
        const stats = fs.statSync(filePath);
        const isDir = stats.isDirectory();
        const icon = isDir ? '📁' : '📄';
        const size = isDir ? '-' : (stats.size / 1024).toFixed(2) + ' KB';
        
        return `
          <tr>
            <td><a href="/${file}">${icon} ${file}</a></td>
            <td>${size}</td>
            <td>${stats.mtime.toLocaleString()}</td>
          </tr>
        `;
      }).join('');

      const html = `
        <!DOCTYPE html>
        <html>
        <head>
          <title>${folderName} - Klyx Tunnel</title>
          <style>
            * { margin: 0; padding: 0; box-sizing: border-box; }
            body {
              font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              min-height: 100vh;
              padding: 40px 20px;
            }
            .container {
              max-width: 1000px;
              margin: 0 auto;
              background: white;
              border-radius: 16px;
              box-shadow: 0 20px 60px rgba(0,0,0,0.3);
              overflow: hidden;
            }
            .header {
              background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
              color: white;
              padding: 30px;
              text-align: center;
            }
            .header h1 { font-size: 28px; margin-bottom: 10px; }
            .header p { opacity: 0.9; }
            .download-btn {
              display: inline-block;
              background: white;
              color: #667eea;
              padding: 15px 40px;
              border-radius: 8px;
              text-decoration: none;
              font-weight: bold;
              margin: 20px 0;
              box-shadow: 0 4px 15px rgba(0,0,0,0.2);
              transition: transform 0.2s;
            }
            .download-btn:hover { transform: scale(1.05); }
            table {
              width: 100%;
              border-collapse: collapse;
            }
            th, td {
              padding: 15px;
              text-align: left;
              border-bottom: 1px solid #eee;
            }
            th {
              background: #f5f5f5;
              font-weight: 600;
            }
            tr:hover { background: #f9f9f9; }
            a { color: #667eea; text-decoration: none; }
            a:hover { text-decoration: underline; }
            .footer {
              text-align: center;
              padding: 20px;
              color: #999;
              font-size: 14px;
            }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>📁 ${folderName}</h1>
              <p>${files.length} items</p>
              <a href="/download-all" class="download-btn">⬇️ Download All as ZIP</a>
            </div>
            <table>
              <thead>
                <tr>
                  <th>Name</th>
                  <th>Size</th>
                  <th>Modified</th>
                </tr>
              </thead>
              <tbody>
                ${fileListHTML}
              </tbody>
            </table>
            <div class="footer">
              Powered by Klyx Tunnel
            </div>
          </div>
        </body>
        </html>
      `;
      
      res.send(html);
    });

    // Serve static files
    app.use(express.static(folderPath));

    const fileServerPort = 9000 + Math.floor(Math.random() * 1000);
    const server = app.listen(fileServerPort, () => {
      spinner.text = 'Starting tunnel...';
    });

    await downloadFrpc();

    const configPath = generateFrpcConfig({
      serverAddr: config.serverAddr,
      serverPort: config.serverPort,
      token: config.token,
      name: subdomain,
      type: 'http',
      localPort: fileServerPort,
      subdomain: subdomain,
      expire: options.expire,
      bandwidthLimit: options.limit
    });

    const frpcPath = path.join(process.env.APPDATA || process.env.HOME, '.klyx-tunnel', 'bin', 'frpc' + (process.platform === 'win32' ? '.exe' : ''));

    
    if (!fs.existsSync(frpcPath)) {
      spinner.fail(chalk.red('FRP client binary not found'));
      console.log(chalk.yellow('Please download frpc manually and place in client/bin/'));
      process.exit(1);
    }

    const frpcProcess = spawn(frpcPath, ['-c', configPath]);

    let started = false;

    frpcProcess.stdout.on('data', (data) => {
      const output = data.toString();
      if (output.includes('start proxy success') || output.includes('login to server success')) {
        if (!started) {
          started = true;
          spinner.succeed(chalk.green('✓ File sharing started!'));
          console.log('');
          console.log(chalk.cyan.bold('  🌐 Share URL:'), chalk.white.bold(tunnelUrl));
          console.log(chalk.gray('  Folder:'), folderPath);
          console.log(chalk.gray('  Subdomain:'), subdomain);
          if (options.password) {
            console.log(chalk.yellow('  🔒 Password protected'));
          }
          if (options.limit) {
            console.log(chalk.gray('  Bandwidth limit:'), options.limit);
          }
          if (options.expire) {
            console.log(chalk.yellow(`  ⏱️  Expires in: ${options.expire} hours`));
          }
          console.log('');
          console.log(chalk.gray('  Press Ctrl+C to stop'));
          console.log('');

          saveProcess({
            name: subdomain,
            type: 'folder',
            url: tunnelUrl,
            folderPath: folderPath,
            pid: frpcProcess.pid,
            startTime: Date.now(),
            configPath: configPath
          });
        }
      }
    });

    process.on('SIGINT', () => {
      console.log(chalk.yellow('\n\nStopping file server...'));
      server.close();
      frpcProcess.kill();
      process.exit(0);
    });

  } catch (error) {
    spinner.fail(chalk.red('Error setting up file sharing'));
    console.error(chalk.red(error.message));
    process.exit(1);
  }
}

module.exports = { execute };
