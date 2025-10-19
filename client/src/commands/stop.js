const chalk = require('chalk');
const { getProcesses, removeProcess } = require('../utils/config');

async function execute(name) {
  const processes = getProcesses();
  const tunnel = processes.find(p => p.name === name);

  if (!tunnel) {
    console.log(chalk.red(`❌ Tunnel not found: ${name}`));
    return;
  }

  try {
    // Kill process
    if (tunnel.pid) {
      process.kill(tunnel.pid);
    }

    // Remove from config
    removeProcess(name);

    console.log(chalk.green(`✓ Stopped tunnel: ${name}`));
  } catch (error) {
    console.error(chalk.red(`Error stopping tunnel: ${error.message}`));
  }
}

module.exports = { execute };
