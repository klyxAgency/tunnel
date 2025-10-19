const Conf = require('conf');
const path = require('path');
const os = require('os');

const config = new Conf({
  projectName: 'klyx-tunnel',
  defaults: {
    serverAddr: 'tunnel.klyx.agency',
    serverPort: '7000',
    token: '',
    domain: 'tunnel.klyx.agency',
    processes: []
  }
});

function getConfig() {
  return {
    serverAddr: config.get('serverAddr'),
    serverPort: config.get('serverPort'),
    token: config.get('token'),
    domain: config.get('domain')
  };
}

function saveConfig(data) {
  config.set(data);
}

function getProcesses() {
  return config.get('processes') || [];
}

function saveProcess(processInfo) {
  const processes = getProcesses();
  processes.push(processInfo);
  config.set('processes', processes);
}

function removeProcess(name) {
  const processes = getProcesses();
  const filtered = processes.filter(p => p.name !== name);
  config.set('processes', filtered);
}

function generateSubdomain() {
  const adjectives = ['fast', 'quick', 'smart', 'cool', 'neat', 'dev', 'test', 'demo'];
  const nouns = ['tunnel', 'link', 'app', 'site', 'web', 'port'];
  const random = Math.floor(Math.random() * 1000);
  
  const adj = adjectives[Math.floor(Math.random() * adjectives.length)];
  const noun = nouns[Math.floor(Math.random() * nouns.length)];
  
  return `${adj}-${noun}-${random}`;
}

module.exports = {
  getConfig,
  saveConfig,
  getProcesses,
  saveProcess,
  removeProcess,
  generateSubdomain
};
