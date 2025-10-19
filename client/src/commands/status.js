const chalk = require('chalk');
const axios = require('axios');
const { getConfig } = require('../utils/config');

async function execute() {
  const config = getConfig();

  if (!config.serverAddr) {
    console.log(chalk.red('❌ Not configured. Run: klyx-tunnel login'));
    return;
  }

  console.log(chalk.cyan.bold('\n📊 Server Status\n'));
  console.log(chalk.gray('Server:'), config.serverAddr + ':' + config.serverPort);
  
  try {
    // Try to connect to server dashboard
    const response = await axios.get(`http://${config.serverAddr}:7500/api/serverinfo`, {
      timeout: 5000
    }).catch(() => null);

    if (response && response.data) {
      console.log(chalk.green('✓ Server is online'));
    } else {
      console.log(chalk.yellow('⚠️  Server status unknown'));
    }
  } catch (error) {
    console.log(chalk.yellow('⚠️  Cannot reach server'));
  }

  console.log('');
}

module.exports = { execute };
