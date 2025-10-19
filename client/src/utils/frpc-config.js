const fs = require('fs');
const path = require('path');
const os = require('os');

function generateFrpcConfig(options) {
  const configDir = path.join(os.homedir(), '.klyx-tunnel');
  if (!fs.existsSync(configDir)) {
    fs.mkdirSync(configDir, { recursive: true });
  }

  const configPath = path.join(configDir, `${options.name}.toml`);

  let config = `
# Klyx Tunnel - FRP Client Configuration
serverAddr = "${options.serverAddr}"
serverPort = ${options.serverPort}

auth.method = "token"
auth.token = "${options.token}"

[[proxies]]
name = "${options.name}"
type = "${options.type}"
localPort = ${options.localPort}
`;

  if (options.subdomain) {
    config += `subdomain = "${options.subdomain}"\n`;
  }

  if (options.bandwidthLimit) {
    config += `transport.bandwidthLimit = "${options.bandwidthLimit}"\n`;
  }

  if (options.expire) {
    // Note: FRP doesn't have native expiry, this is for reference
    config += `# Expires in ${options.expire} hours\n`;
  }

  fs.writeFileSync(configPath, config);
  return configPath;
}

module.exports = { generateFrpcConfig };
