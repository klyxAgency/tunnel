
# Klyx Tunnel

🚀 **Dead-simple CLI tunneling tool for local services & file sharing**

Self-hosted alternative to ngrok on your own AWS infrastructure with custom branding.

## Features

- ✅ **Web App Tunneling** - Expose localhost:3000 instantly
- ✅ **File Sharing** - Share 500GB+ folders with clients
- ✅ **Custom Subdomains** - `your-app.tunnel.klyx.agency`
- ✅ **Password Protection** - Secure file shares
- ✅ **Bandwidth Limiting** - Control transfer speeds
- ✅ **Auto-Expiry** - Tunnels expire after N hours
- ✅ **No Installation** - Standalone executable
- ✅ **Cross-Platform** - Windows, Linux, macOS
- ✅ **Self-Hosted** - Your AWS, your control
- ✅ **FREE** - First 12 months on AWS Free Tier

## Quick Start

### For Users

```
# 1. Download executable
wget https://klyx.agency/tools/klyx-tunnel-linux

# 2. Configure once
chmod +x klyx-tunnel-linux
./klyx-tunnel-linux login

# 3. Start tunneling
./klyx-tunnel 3000
# → http://fast-app-123.tunnel.klyx.agency
```

### For Administrators

```
# 1. Generate project structure
powershell .\simple-generate.ps1

# 2. Deploy to AWS EC2
cd klyx-tunnel/server
# Follow server/README.md

# 3. Build CLI tool
cd ../client
npm install
npm run build
```

## Examples

### Tunnel Web Application

```
# Basic usage
klyx-tunnel 3000

# Custom subdomain
klyx-tunnel 3000 --name hotel-booking-demo

# Temporary demo (4 hours)
klyx-tunnel 3000 --name presentation --expire 4
```

### Share Files

```
# Basic folder sharing
klyx-tunnel folder "C:\ClientAssets" --name client-files

# Password protected
klyx-tunnel folder "./videos" --name secure --password abc123

# Full featured
klyx-tunnel folder "/data" --name project --password secret --expire 48 --limit 50MB
```

### Manage Tunnels

```
# List active tunnels
klyx-tunnel list

# Stop specific tunnel
klyx-tunnel stop my-app

# Check server status
klyx-tunnel status
```

## Use Cases

### 🎨 Web Development
- Share localhost with clients instantly
- Test webhooks from external services
- Demo work-in-progress to stakeholders
- Collaborate with remote team members

### 📦 Client Deliveries
- Share 500GB+ video files
- Deliver design assets securely
- Temporary file access with auto-expiry
- Password-protected downloads

### 🚀 Demos & Presentations
- Live product demonstrations
- Client presentations
- Testing on real devices
- Quick prototyping

## Architecture

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   Client    │────────>│  AWS EC2     │<────────│  Internet   │
│  (Your PC)  │  Tunnel │  FRP Server  │  Access │   Users     │
└─────────────┘         └──────────────┘         └─────────────┘
 klyx-tunnel CLI            Port 7000           *.tunnel.klyx.agency
```

**Technology Stack:**
- **Server:** FRP (Fast Reverse Proxy) on AWS EC2
- **Client:** Node.js + pkg (standalone executable)
- **DNS:** Cloudflare wildcard subdomain
- **Cost:** FREE for 12 months, then ~$10/month

## Project Structure

```
klyx-tunnel/
├── server/                 # AWS EC2 deployment
│   ├── frps.toml          # FRP server config
│   ├── frps.service       # Systemd service
│   ├── install-server.sh  # One-command installation
│   └── README.md          # Server setup guide
│
├── client/                 # CLI tool source
│   ├── src/
│   │   ├── index.js       # Main entry point
│   │   ├── commands/      # Tunnel, folder, list, stop, login
│   │   └── utils/         # Config, FRP wrapper
│   ├── package.json
│   ├── build.js
│   └── README.md          # Client usage guide
│
├── docs/
│   ├── QUICKSTART.md      # 2-minute getting started
│   ├── DNS-SETUP.md       # DNS configuration
│   └── SETUP-SERVER.md    # Detailed server setup
│
└── dist/                   # Compiled executables
    ├── klyx-tunnel-windows.exe
    ├── klyx-tunnel-linux
    └── klyx-tunnel-macos
```

## Documentation

- **[Quick Start](docs/QUICKSTART.md)** - Get running in 2 minutes
- **[Server Setup](docs/SETUP-SERVER.md)** - Deploy AWS EC2 server
- **[DNS Configuration](docs/DNS-SETUP.md)** - Cloudflare setup
- **[Client Usage](client/README.md)** - Build and use CLI tool

## Requirements

### Server
- AWS EC2 t2.micro (Free Tier eligible)
- Amazon Linux 2023 or Ubuntu 22.04
- Ports: 22, 7000, 80, 443, 7500
- Domain with DNS management

### Client
- Windows 10+, macOS 10.14+, or Linux
- ~40MB disk space for executable
- No dependencies (standalone)

## Installation

### Server (One-Time Setup)

```
# 1. Launch AWS EC2 t2.micro
# 2. Upload files
scp server/* ec2-user@YOUR_IP:/tmp/

# 3. Run installation
ssh ec2-user@YOUR_IP
sudo bash /tmp/install-server.sh

# 4. Configure DNS
# Add: tunnel.klyx.agency → YOUR_IP
# Add: *.tunnel.klyx.agency → tunnel.klyx.agency
```

### Client (End Users)

```
# Download and configure
chmod +x klyx-tunnel-linux
./klyx-tunnel-linux login
```

## Cost Breakdown

### First 12 Months (AWS Free Tier)
- EC2 t2.micro (750 hrs/month): **$0**
- EBS Storage (30GB): **$0**
- Data Transfer (100GB/month): **$0**
- **Total: $0/month** ✅

### After 12 Months
- EC2 t2.micro: ~$8.50/month
- EBS Storage 8GB: ~$0.80/month
- Data Transfer: $0.09/GB (after 100GB)
- **Total: ~$10-15/month** (typical usage)

### ROI Comparison
- ngrok Pro: $20/month/user
- Cloudflare Tunnel: Free (but limited)
- Klyx Tunnel: **$10/month unlimited users** 🎉

## Security

- ✅ Token-based authentication
- ✅ Optional password protection
- ✅ TLS encryption support
- ✅ Bandwidth limiting
- ✅ Auto-expiry tunnels
- ✅ Port restrictions
- ✅ IP whitelisting (optional)

## Troubleshooting

### Common Issues

**"Not configured"**
```
klyx-tunnel login
```

**"Cannot reach server"**
```
klyx-tunnel status
# Check server: sudo systemctl status frps
```

**"Port already in use"**
```
klyx-tunnel list
klyx-tunnel stop existing-tunnel
```

**DNS not resolving**
```
nslookup tunnel.klyx.agency
# Wait 10 minutes, clear DNS cache
```

## Development

### Build from Source

```
# Generate structure
powershell .\simple-generate.ps1

# Install dependencies
cd klyx-tunnel/client
npm install

# Run locally
node src/index.js 3000

# Build executables
npm install -g pkg
npm run build
```

### Testing

```
# Test tunnel
klyx-tunnel 3000 --name test

# Test folder
klyx-tunnel folder ./test-files --name test-share --password test123

# List and stop
klyx-tunnel list
klyx-tunnel stop test
```

## Roadmap

- [ ] HTTPS support with Let's Encrypt
- [ ] Download analytics/tracking
- [ ] Web UI for tunnel management
- [ ] Email notifications
- [ ] Multi-user authentication
- [ ] Usage statistics dashboard
- [ ] Docker deployment
- [ ] Custom domain support

## Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open Pull Request

## License

MIT License - Free for personal and commercial use

## Acknowledgments

Built with:
- [FRP](https://github.com/fatedier/frp) - Fast Reverse Proxy
- [pkg](https://github.com/vercel/pkg) - Node.js compiler
- [Commander.js](https://github.com/tj/commander.js) - CLI framework
- [Express](https://expressjs.com/) - Web server

## Support

- 📚 **Documentation:** See `/docs` folder
- 🐛 **Issues:** Check troubleshooting guides
- 💬 **Contact:** support@klyx.agency
- 🌐 **Website:** https://klyx.agency

---

**Made with ❤️ by Klyx Agency**

🌐 [klyx.agency](https://klyx.agency) | 📧 hello@klyx.agency | 🚀 Empowering digital experiences
```

***

