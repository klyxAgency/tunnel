const inquirer = require('inquirer');
const chalk = require('chalk');
const { saveConfig, getConfig } = require('../utils/config');

async function execute() {
  console.log(chalk.cyan.bold('\n🔐 Klyx Tunnel Configuration\n'));

  const currentConfig = getConfig();

  const answers = await inquirer.prompt([
    {
      type: 'input',
      name: 'serverAddr',
      message: 'FRP Server Address:',
      default: currentConfig.serverAddr || 'tunnel.klyx.agency'
    },
    {
      type: 'input',
      name: 'serverPort',
      message: 'FRP Server Port:',
      default: currentConfig.serverPort || '7000'
    },
    {
      type: 'input',
      name: 'token',
      message: 'Authentication Token:',
      default: currentConfig.token || ''
    },
    {
      type: 'input',
      name: 'domain',
      message: 'Tunnel Domain:',
      default: currentConfig.domain || 'tunnel.klyx.agency'
    }
  ]);

  saveConfig(answers);

  console.log(chalk.green('\n✓ Configuration saved successfully!\n'));
  console.log(chalk.gray('You can now run: klyx-tunnel 3000\n'));
}

module.exports = { execute };
