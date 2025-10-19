
# Klyx Tunnel - Quick Start Guide

Get up and running in 2 minutes!

## For Administrators

### 1. Deploy Server (15 minutes)

```
# Launch AWS EC2 t2.micro (Free Tier)
# Allocate Elastic IP
# Configure Security Group (ports 7000, 80, 443, 7500)

# SSH into server
ssh -i key.pem ec2-user@YOUR_IP

# Upload files
scp -i key.pem server/* ec2-user@YOUR_IP:/tmp/

# Install
sudo bash /tmp/install-server.sh
```

### 2. Configure DNS (10 minutes)

**Cloudflare:**
- A Record: `tunnel` → `YOUR_ELASTIC_IP`
- CNAME: `*` → `tunnel.klyx.agency`

Wait 5-10 minutes for propagation.

### 3. Update Security Token

```
# Generate token
openssl rand -base64 32

# Update config
sudo nano /etc/frp/frps.toml
# Change: auth.token = "YOUR_SECURE_TOKEN"

# Restart
sudo systemctl restart frps
```

### 4. Verify

```
sudo systemctl status frps
curl http://YOUR_IP:7500
```

## For End Users

### 1. Download CLI Tool

Get the executable for your platform:
- Windows: `klyx-tunnel-windows.exe`
- Linux: `klyx-tunnel-linux`
- macOS: `klyx-tunnel-macos`

### 2. First-Time Setup

```
# Make executable (Linux/Mac only)
chmod +x klyx-tunnel-linux

# Configure
./klyx-tunnel-linux login
```

Enter when prompted:
- **Server Address:** tunnel.klyx.agency
- **Server Port:** 7000
- **Auth Token:** (ask your admin)
- **Domain:** tunnel.klyx.agency

### 3. Start Tunneling!

```
# Tunnel your local app
klyx-tunnel 3000

# Output:
# 🌐 Tunnel URL: http://fast-app-123.tunnel.klyx.agency
# Local Port: 3000
# Press Ctrl+C to stop
```

### 4. Share Files

```
# Share a folder
klyx-tunnel folder "C:\ClientFiles" --name project-abc --password secret123

# Output:
# 🌐 Share URL: http://project-abc.tunnel.klyx.agency
# 🔒 Password protected
```

## Common Use Cases

### Web Development

```
# React app
klyx-tunnel 3000 --name my-react-app

# Express API
klyx-tunnel 8080 --name api-dev

# Next.js
klyx-tunnel 3000 --name nextjs-demo
```

### Client Deliveries

```
# Video files with password
klyx-tunnel folder "D:\Videos" --name hotel-videos --password client123 --expire 48

# Design assets
klyx-tunnel folder "./designs" --name final-designs --password abc123

# Large files with bandwidth limit
klyx-tunnel folder "./assets" --name big-files --limit 50MB
```

### Demos & Presentations

```
# 4-hour demo
klyx-tunnel 3000 --name demo --expire 4

# Client presentation
klyx-tunnel 8000 --name presentation --expire 8
```

## Quick Commands Reference

```
# Tunnel port
klyx-tunnel 3000

# Custom subdomain
klyx-tunnel 3000 --name my-app

# Share folder
klyx-tunnel folder /path --name files

# Password protect
klyx-tunnel folder /path --name secure --password secret

# Auto-expire
klyx-tunnel 3000 --expire 24

# List tunnels
klyx-tunnel list

# Stop tunnel
klyx-tunnel stop my-app

# Check status
klyx-tunnel status

# Reconfigure
klyx-tunnel login
```

## Tips

1. **Use meaningful subdomain names**
   ```
   klyx-tunnel 3000 --name hotel-booking-demo
   ```

2. **Always password-protect client files**
   ```
   klyx-tunnel folder ./files --name client-abc --password SecurePass123
   ```

3. **Set expiry for temporary shares**
   ```
   klyx-tunnel folder ./temp --name demo --expire 4
   ```

4. **Limit bandwidth for large files**
   ```
   klyx-tunnel folder ./videos --name big --limit 10MB
   ```

## Troubleshooting

### "Not configured"
```
klyx-tunnel login
```

### "Cannot reach server"
```
klyx-tunnel status
# Check if server is online
```

### "Port already in use"
```
klyx-tunnel list
klyx-tunnel stop existing-tunnel
```

### "Subdomain taken"
```
# Try different name
klyx-tunnel 3000 --name my-app-v2
```

## Next Steps

- Read full documentation in `README.md`
- Server setup: `server/README.md`
- DNS configuration: `docs/DNS-SETUP.md`
- Detailed setup: `docs/SETUP-SERVER.md`

---

**Need help?** Contact your administrator or check the troubleshooting guides.
```

***

