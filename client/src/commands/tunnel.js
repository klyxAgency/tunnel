const { spawn } = require('child_process');
const chalk = require('chalk');
const ora = require('ora');
const fs = require('fs');
const path = require('path');
const { getConfig, saveProcess, generateSubdomain } = require('../utils/config');
const { generateFrpcConfig } = require('../utils/frpc-config');
const { downloadFrpc } = require('../utils/downloader');

async function execute(port, options) {
  const config = getConfig();
  
  if (!config.token || !config.serverAddr) {
    console.log(chalk.red('❌ Not configured. Please run: klyx-tunnel login'));
    process.exit(1);
  }

  const spinner = ora('Starting tunnel...').start();

  try {
    // Generate subdomain
    const subdomain = options.name || generateSubdomain();
    const tunnelUrl = `http://${subdomain}.${config.domain}`;

    // Download/ensure frpc binary exists and get its path
    const frpcPath = await downloadFrpc();
    
    if (!fs.existsSync(frpcPath)) {
      spinner.fail(chalk.red('FRP client binary not found'));
      console.log(chalk.yellow('Download failed. Please check internet connection.'));
      process.exit(1);
    }

    // Generate frpc configuration
    const configPath = generateFrpcConfig({
      serverAddr: config.serverAddr,
      serverPort: config.serverPort,
      token: config.token,
      name: subdomain,
      type: 'http',
      localPort: port,
      subdomain: subdomain,
      expire: options.expire
    });

    // Start frpc process
    const frpcProcess = spawn(frpcPath, ['-c', configPath], {
      stdio: ['ignore', 'pipe', 'pipe']
    });

    let started = false;

    frpcProcess.stdout.on('data', (data) => {
      const output = data.toString();
      if (output.includes('start proxy success') || output.includes('login to server success')) {
        if (!started) {
          started = true;
          spinner.succeed(chalk.green('✓ Tunnel started successfully!'));
          console.log('');
          console.log(chalk.cyan.bold('  🌐 Tunnel URL:'), chalk.white.bold(tunnelUrl));
          console.log(chalk.gray('  Local Port:'), port);
          console.log(chalk.gray('  Subdomain:'), subdomain);
          if (options.expire) {
            console.log(chalk.yellow(`  ⏱️  Expires in: ${options.expire} hours`));
          }
          console.log('');
          console.log(chalk.gray('  Press Ctrl+C to stop'));
          console.log('');

          // Save process info
          saveProcess({
            name: subdomain,
            type: 'http',
            url: tunnelUrl,
            localPort: port,
            pid: frpcProcess.pid,
            startTime: Date.now(),
            configPath: configPath
          });
        }
      }
    });

    frpcProcess.stderr.on('data', (data) => {
      const error = data.toString();
      if (!started && error.includes('error')) {
        spinner.fail(chalk.red('Failed to start tunnel'));
        console.error(chalk.red(error));
      }
    });

    frpcProcess.on('close', (code) => {
      if (code !== 0 && !started) {
        spinner.fail(chalk.red(`Failed to start tunnel (exit code ${code})`));
      }
    });

    // Handle process termination
    process.on('SIGINT', () => {
      console.log(chalk.yellow('\n\nStopping tunnel...'));
      frpcProcess.kill();
      process.exit(0);
    });

  } catch (error) {
    spinner.fail(chalk.red('Error starting tunnel'));
    console.error(chalk.red(error.message));
    process.exit(1);
  }
}

module.exports = { execute };
