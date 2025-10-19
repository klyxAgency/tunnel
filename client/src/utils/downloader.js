const fs = require('fs');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');

const FRP_VERSION = '0.65.0';

const binDir = path.join(
  process.env.APPDATA || process.env.HOME || process.cwd(), 
  '.klyx-tunnel', 
  'bin'
);

function downloadFrpc() {
  return new Promise((resolve, reject) => {
    const platform = process.platform;
    const arch = process.arch === 'x64' ? 'amd64' : 'arm64';
    
    let platformName, archiveExt, extractCmd;
    if (platform === 'win32') {
      platformName = 'windows';
      archiveExt = 'zip';
    } else if (platform === 'darwin') {
      platformName = 'darwin';
      archiveExt = 'tar.gz';
    } else {
      platformName = 'linux';
      archiveExt = 'tar.gz';
    }

    const binaryName = platform === 'win32' ? 'frpc.exe' : 'frpc';
    const binaryPath = path.join(binDir, binaryName);

    // Check if already exists
    if (fs.existsSync(binaryPath)) {
      return resolve(binaryPath);
    }

    console.log('First-time setup: Downloading FRP client...');
    console.log('This only happens once (5-10 seconds)');
    
    // Create bin directory
    if (!fs.existsSync(binDir)) {
      fs.mkdirSync(binDir, { recursive: true });
    }

    const downloadUrl = `https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_${platformName}_${arch}.${archiveExt}`;
    const archiveFile = path.join(binDir, `frp.${archiveExt}`);
    
    try {
      // Download file
      const file = fs.createWriteStream(archiveFile);
      
      function followRedirect(url) {
        https.get(url, (response) => {
          if (response.statusCode === 302 || response.statusCode === 301) {
            followRedirect(response.headers.location);
          } else {
            response.pipe(file);
            file.on('finish', () => {
              file.close();
              extractAndInstall();
            });
          }
        }).on('error', (err) => {
          if (fs.existsSync(archiveFile)) fs.unlinkSync(archiveFile);
          reject(new Error('Download failed. Check internet connection.'));
        });
      }
      
      followRedirect(downloadUrl);

      function extractAndInstall() {
        try {
          console.log('Extracting...');
          
          const extractedDir = path.join(binDir, `frp_${FRP_VERSION}_${platformName}_${arch}`);
          
          // Extract based on platform
          if (platform === 'win32') {
            // Windows: Use PowerShell Expand-Archive
            execSync(`powershell -command "Expand-Archive -Path '${archiveFile}' -DestinationPath '${binDir}' -Force"`, { stdio: 'ignore' });
          } else {
            // Linux/Mac: Use tar
            execSync(`tar -xzf "${archiveFile}" -C "${binDir}"`, { stdio: 'ignore' });
          }
          
          // Find and copy binary
          const sourcePath = path.join(extractedDir, binaryName);
          
          if (fs.existsSync(sourcePath)) {
            fs.copyFileSync(sourcePath, binaryPath);
            
            // Make executable on Unix
            if (platform !== 'win32') {
              fs.chmodSync(binaryPath, '755');
            }

            // Cleanup
            if (fs.existsSync(archiveFile)) fs.unlinkSync(archiveFile);
            if (fs.existsSync(extractedDir)) {
              fs.rmSync(extractedDir, { recursive: true, force: true });
            }

            console.log('✓ Setup complete!');
            console.log('');
            resolve(binaryPath);
          } else {
            reject(new Error('Binary not found after extraction.'));
          }
        } catch (error) {
          reject(new Error(`Extraction failed: ${error.message}`));
        }
      }
    } catch (error) {
      reject(new Error(`Download failed: ${error.message}`));
    }
  });
}

module.exports = { downloadFrpc };
