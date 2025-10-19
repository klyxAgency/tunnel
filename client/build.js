const fs = require('fs');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');

const FRP_VERSION = '0.65.0';
const binDir = path.join(__dirname, '../../bin');

function downloadFrpc() {
  return new Promise((resolve, reject) => {
    const platform = process.platform;
    const arch = process.arch === 'x64' ? 'amd64' : 'arm64';
    
    let platformName;
    if (platform === 'win32') platformName = 'windows';
    else if (platform === 'darwin') platformName = 'darwin';
    else platformName = 'linux';

    const binaryName = platform === 'win32' ? 'frpc.exe' : 'frpc';
    const binaryPath = path.join(binDir, binaryName);

    // Check if already exists
    if (fs.existsSync(binaryPath)) {
      return resolve(binaryPath);
    }

    // Create bin directory
    if (!fs.existsSync(binDir)) {
      fs.mkdirSync(binDir, { recursive: true });
    }

    console.log('Downloading FRP client... (this may take a moment)');
    
    const downloadUrl = `https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_${platformName}_${arch}.tar.gz`;
    
    try {
      // Download using system commands
      const tarFile = path.join(binDir, 'frp.tar.gz');
      
      if (platform === 'win32') {
        // Windows: use curl (built-in on Windows 10+)
        execSync(`curl -L -o "${tarFile}" "${downloadUrl}"`, { cwd: binDir });
      } else {
        // Linux/Mac: use wget or curl
        try {
          execSync(`wget -O "${tarFile}" "${downloadUrl}"`, { cwd: binDir });
        } catch (e) {
          execSync(`curl -L -o "${tarFile}" "${downloadUrl}"`, { cwd: binDir });
        }
      }
      
      // Extract
      console.log('Extracting...');
      execSync(`tar -xzf frp.tar.gz`, { cwd: binDir });
      
      // Move binary
      const extractedDir = `frp_${FRP_VERSION}_${platformName}_${arch}`;
      const sourcePath = path.join(binDir, extractedDir, binaryName);
      fs.copyFileSync(sourcePath, binaryPath);
      
      // Make executable on Unix
      if (platform !== 'win32') {
        fs.chmodSync(binaryPath, '755');
      }

      // Cleanup
      fs.unlinkSync(tarFile);
      fs.rmSync(path.join(binDir, extractedDir), { recursive: true, force: true });

      console.log('FRP client ready!');
      resolve(binaryPath);
    } catch (error) {
      reject(new Error('Failed to download FRP client. Please download manually from https://github.com/fatedier/frp/releases'));
    }
  });
}

module.exports = { downloadFrpc };
