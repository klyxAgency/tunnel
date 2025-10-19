
### 📄 `server/README.md`

```markdown
# Klyx Tunnel - Server Setup Guide

## AWS EC2 Deployment

### Step 1: Launch EC2 Instance

1. Go to AWS Console → EC2 → Launch Instance
2. Choose **Amazon Linux 2023** or **Ubuntu 22.04**
3. Instance Type: **t2.micro** (Free Tier)
4. Configure Security Group:
   - Port 22 (SSH)
   - Port 7000 (FRP server)
   - Port 80 (HTTP)
   - Port 443 (HTTPS)
   - Port 7500 (Dashboard - restrict to your IP)
5. Create/Select Key Pair
6. Launch Instance

### Step 2: Allocate Elastic IP

1. EC2 Console → Elastic IPs → Allocate
2. Associate with your EC2 instance
3. Note the IP address (e.g., 54.123.45.67)

### Step 3: Upload Files

```
# From your local machine
scp -i your-key.pem frps.toml ec2-user@YOUR_IP:/tmp/
scp -i your-key.pem frps.service ec2-user@YOUR_IP:/tmp/
scp -i your-key.pem install-server.sh ec2-user@YOUR_IP:/tmp/
```

### Step 4: SSH and Install

```
# Connect to server
ssh -i your-key.pem ec2-user@YOUR_IP

# Run installation
cd /tmp
sudo bash install-server.sh
```

### Step 5: Update Security Token

```
# Generate secure token
openssl rand -base64 32

# Edit config
sudo nano /etc/frp/frps.toml
# Update: auth.token = "YOUR_SECURE_TOKEN"

# Restart service
sudo systemctl restart frps
```

### Step 6: Verify Installation

```
# Check service status
sudo systemctl status frps

# View logs
sudo journalctl -u frps -f

# Test dashboard
curl http://localhost:7500
```

## DNS Configuration

See `../docs/DNS-SETUP.md` for detailed DNS configuration with Cloudflare.

## Monitoring

### Check Service

```
sudo systemctl status frps
```

### View Logs

```
sudo tail -f /var/log/frp/frps.log
```

### Restart Service

```
sudo systemctl restart frps
```

## Troubleshooting

### Service won't start

```
# Check logs
sudo journalctl -u frps -n 50

# Run manually to see errors
sudo /usr/bin/frps -c /etc/frp/frps.toml
```

### Port issues

```
# Check if ports are open
sudo netstat -tlnp | grep frps

# Check firewall
sudo iptables -L -n
```

## Security Best Practices

1. Change default auth token
2. Restrict dashboard access (port 7500) to your IP only
3. Enable TLS in production
4. Regularly update FRP version
5. Monitor logs for unauthorized access attempts

## Cost Estimate

- **First 12 months**: FREE (AWS Free Tier)
- **After 12 months**: ~$8-10/month

## Support

For issues, check the troubleshooting section or review FRP documentation at https://github.com/fatedier/frp
```
