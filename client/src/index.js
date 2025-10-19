#!/usr/bin/env node

const { program } = require('commander');
const chalk = require('chalk');
const boxen = require('boxen');
const packageJson = require('../package.json');

const tunnelCommand = require('./commands/tunnel');
const folderCommand = require('./commands/folder');
const listCommand = require('./commands/list');
const stopCommand = require('./commands/stop');
const loginCommand = require('./commands/login');
const statusCommand = require('./commands/status');

const banner = chalk.cyan.bold(`
KLYX TUNNEL
Fast tunneling for local services & file sharing
`);

console.log(boxen(banner, {
  padding: 1,
  margin: 1,
  borderStyle: 'round',
  borderColor: 'cyan'
}));

program
  .name('klyx-tunnel')
  .description('CLI tool for tunneling local servers and sharing files')
  .version(packageJson.version);

program
  .argument('[port]', 'Local port to tunnel')
  .option('--port <port>', 'Local port to tunnel')
  .option('--name <name>', 'Subdomain name')
  .option('--expire <hours>', 'Auto-expire after N hours')
  .action(async (port, options) => {
    if (port || options.port) {
      await tunnelCommand.execute(port || options.port, options);
    } else {
      program.help();
    }
  });

program
  .command('tunnel <port>')
  .description('Tunnel a local web server')
  .option('--name <name>', 'Subdomain name')
  .option('--expire <hours>', 'Auto-expire after N hours')
  .action(function(port) {
    tunnelCommand.execute(port, this.opts());
  });

  program
  .command('folder <path>')
  .description('Share a folder for file downloads')
  .option('--name <name>', 'Subdomain name')
  .option('--password <password>', 'Password protection')
  .option('--expire <hours>', 'Auto-expire after N hours')
  .option('--limit <speed>', 'Bandwidth limit (e.g., 50mbps)')
  .action(function(folderPath) {
    // Manual option extraction for pkg compatibility
    const args = process.argv;
    const options = {};
    
    for (let i = 0; i < args.length; i++) {
      if (args[i] === '--name' && args[i + 1]) {
        options.name = args[i + 1];
      }
      if (args[i] === '--password' && args[i + 1]) {
        options.password = args[i + 1];
      }
      if (args[i] === '--expire' && args[i + 1]) {
        options.expire = args[i + 1];
      }
      if (args[i] === '--limit' && args[i + 1]) {
        options.limit = args[i + 1];
      }
    }
    
    folderCommand.execute(folderPath, options);
  });


program
  .command('list')
  .description('List all active tunnels')
  .action(function() {
    listCommand.execute();
  });

program
  .command('stop <name>')
  .description('Stop a specific tunnel')
  .action(function(name) {
    stopCommand.execute(name);
  });

program
  .command('login')
  .description('Configure authentication token')
  .action(function() {
    loginCommand.execute();
  });

program
  .command('status')
  .description('Check tunnel status')
  .action(function() {
    statusCommand.execute();
  });

program.parse();
