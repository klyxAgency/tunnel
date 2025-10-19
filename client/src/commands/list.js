const chalk = require('chalk');
const { getProcesses } = require('../utils/config');

async function execute() {
  const processes = getProcesses();

  if (processes.length === 0) {
    console.log(chalk.yellow('No active tunnels'));
    return;
  }

  console.log(chalk.cyan.bold('\nActive Tunnels:\n'));
  
  processes.forEach((proc, index) => {
    const uptime = Math.floor((Date.now() - proc.startTime) / 1000 / 60);
    console.log(chalk.white(`[${index + 1}] ${proc.name}`));
    console.log(chalk.gray(`    Type: ${proc.type}`));
    console.log(chalk.gray(`    URL: ${proc.url}`));
    console.log(chalk.gray(`    Uptime: ${uptime} minutes`));
    if (proc.localPort) {
      console.log(chalk.gray(`    Local Port: ${proc.localPort}`));
    }
    if (proc.folderPath) {
      console.log(chalk.gray(`    Folder: ${proc.folderPath}`));
    }
    console.log('');
  });
}

module.exports = { execute };
