### 📄 `docs/SETUP-SERVER.md`

```markdown
# Klyx Tunnel - Detailed Server Setup Guide

Complete step-by-step guide for deploying Klyx Tunnel server on AWS EC2.

## Overview

**What you'll need:**
- AWS account (Free Tier eligible)
- Domain with DNS management access
- SSH client
- 30 minutes

**What you'll get:**
- FRP server running 24/7
- Wildcard subdomain support
- Web dashboard for monitoring
- Auto-restart on failure

## Part 1: AWS EC2 Setup

### 1.1 Create EC2 Instance

1. **Login to AWS Console**
   - Go to: https://console.aws.amazon.com/ec2

2. **Launch Instance**
   - Click **Launch Instance**
   - Name: `klyx-tunnel-server`

3. **Choose AMI**
   - Select: **Amazon Linux 2023** (Free Tier eligible)
   - Or: **Ubuntu Server 22.04 LTS** (also Free Tier)

4. **Choose Instance Type**
   - Select: **t2.micro** (1 vCPU, 1GB RAM)
   - Free Tier: 750 hours/month

5. **Key Pair**
   - Create new key pair: `klyx-tunnel-key`
   - Type: RSA
   - Format: `.pem` (for SSH)
   - **Download and save securely**

6. **Network Settings**
   - Create new security group: `klyx-tunnel-sg`
   - Description: "Klyx Tunnel FRP Server"

7. **Configure Security Group**
   
   Add these inbound rules:
   
   | Type        | Protocol | Port  | Source    | Description     |
   |-------------|----------|-------|-----------|-----------------|
   | SSH         | TCP      | 22    | My IP     | SSH access      |
   | Custom TCP  | TCP      | 7000  | 0.0.0.0/0 | FRP server      |
   | HTTP        | TCP      | 80    | 0.0.0.0/0 | HTTP tunnels    |
   | HTTPS       | TCP      | 443   | 0.0.0.0/0 | HTTPS tunnels   |
   | Custom TCP  | TCP      | 7500  | My IP     | Dashboard       |

8. **Storage**
   - 8 GB gp3 (Free Tier: up to 30GB)

9. **Launch Instance**
   - Review and click **Launch**

### 1.2 Allocate Elastic IP

1. Go to **EC2** → **Elastic IPs**
2. Click **Allocate Elastic IP address**
3. Click **Allocate**
4. Select the new IP → **Actions** → **Associate Elastic IP address**
5. Select your instance: `klyx-tunnel-server`
6. Click **Associate**
7. **Note the IP address** (e.g., 54.123.45.67)

### 1.3 Connect to Server

**Windows (PowerShell):**
```
ssh -i "klyx-tunnel-key.pem" ec2-user@54.123.45.67
```

**Mac/Linux:**
```
chmod 400 klyx-tunnel-key.pem
ssh -i klyx-tunnel-key.pem ec2-user@54.123.45.67
```

**First time:** Type `yes` when asked about authenticity

## Part 2: Server Configuration

### 2.1 Upload Server Files

**From your local machine:**

```
# Upload all server files
scp -i klyx-tunnel-key.pem server/frps.toml ec2-user@54.123.45.67:/tmp/
scp -i klyx-tunnel-key.pem server/frps.service ec2-user@54.123.45.67:/tmp/
scp -i klyx-tunnel-key.pem server/install-server.sh ec2-user@54.123.45.67:/tmp/
```

### 2.2 Run Installation

**On the server:**

```
# Navigate to /tmp
cd /tmp

# Make script executable
chmod +x install-server.sh

# Run installation
sudo bash install-server.sh
```

**Installation takes 2-3 minutes**

Output should show:
```
[1/7] Updating system packages... ✓
[2/7] Installing required packages... ✓
[3/7] Downloading FRP... ✓
[4/7] Extracting FRP... ✓
[5/7] Installing FRP server... ✓
[6/7] Setting up systemd service... ✓
[7/7] Configuring firewall... ✓
```

### 2.3 Update Security Token

**Generate secure token:**
```
openssl rand -base64 32
```

**Example output:** `vK8x7nQ2mP4hL9wR3tY6uI0oP5mN1bV2cX4zA8sD9fG=`

**Edit configuration:**
```
sudo nano /etc/frp/frps.toml
```

**Update this line:**
```
auth.token = "vK8x7nQ2mP4hL9wR3tY6uI0oP5mN1bV2cX4zA8sD9fG="
```

**Save:** Ctrl+X, Y, Enter

**Restart service:**
```
sudo systemctl restart frps
```

### 2.4 Verify Installation

**Check service status:**
```
sudo systemctl status frps
```

Should show: `Active: active (running)`

**View logs:**
```
sudo journalctl -u frps -f
```

Should show: `start frps success`

**Test dashboard:**
```
curl http://localhost:7500
```

Should return HTML content

## Part 3: DNS Configuration

See `DNS-SETUP.md` for detailed instructions.

**Quick summary:**

1. Add A record: `tunnel.klyx.agency` → `54.123.45.67`
2. Add CNAME: `*` → `tunnel.klyx.agency`
3. Wait 5-10 minutes
4. Test: `nslookup tunnel.klyx.agency`

## Part 4: Client Distribution

### 4.1 Share Server Details

Provide to users:
- **Server Address:** tunnel.klyx.agency
- **Server Port:** 7000
- **Auth Token:** `vK8x7nQ2mP4hL9wR3tY6uI0oP5mN1bV2cX4zA8sD9fG=`
- **Domain:** tunnel.klyx.agency

### 4.2 Build Client Executables

**On your development machine:**

```
cd klyx-tunnel/client
npm install
npm install -g pkg
npm run build
```

Executables in `dist/` folder:
- `klyx-tunnel-windows.exe`
- `klyx-tunnel-linux`
- `klyx-tunnel-macos`

### 4.3 Distribute

Upload to:
- Website: https://klyx.agency/tools/tunnel
- GitHub Releases
- Internal file server

## Part 5: Monitoring & Maintenance

### 5.1 Daily Checks

```
# Check service
sudo systemctl status frps

# View logs
sudo tail -f /var/log/frp/frps.log

# Check disk space
df -h

# Check memory
free -m
```

### 5.2 Automated Monitoring

**Create monitor script:**
```
sudo nano /root/monitor-frps.sh
```

**Add content:**
```
#!/bin/bash
if ! systemctl is-active --quiet frps; then
    echo "FRP is down! Restarting..."
    systemctl restart frps
    echo "FRP restarted at $(date)" | mail -s "FRP Alert" admin@klyx.agency
fi
```

**Make executable:**
```
sudo chmod +x /root/monitor-frps.sh
```

**Add to crontab:**
```
sudo crontab -e
```

**Add line:**
```
*/5 * * * * /root/monitor-frps.sh
```

Runs every 5 minutes

### 5.3 Log Rotation

**Create logrotate config:**
```
sudo nano /etc/logrotate.d/frps
```

**Add content:**
```
/var/log/frp/frps.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
    create 0640 root root
    postrotate
        systemctl reload frps > /dev/null 2>&1 || true
    endscript
}
```

### 5.4 Updates

**Update FRP version:**
```
# Stop service
sudo systemctl stop frps

# Download new version
cd /tmp
wget https://github.com/fatedier/frp/releases/download/v0.XX.X/frp_0.XX.X_linux_amd64.tar.gz
tar -xzf frp_0.XX.X_linux_amd64.tar.gz
cd frp_0.XX.X_linux_amd64

# Replace binary
sudo cp frps /usr/bin/

# Start service
sudo systemctl start frps
```

## Troubleshooting

### Service Won't Start

```
# Check logs
sudo journalctl -u frps -n 50 --no-pager

# Run manually
sudo /usr/bin/frps -c /etc/frp/frps.toml

# Check config syntax
sudo frps verify -c /etc/frp/frps.toml
```

### Port Already in Use

```
# Check what's using ports
sudo netstat -tlnp | grep 7000
sudo netstat -tlnp | grep 80

# Kill process if needed
sudo kill <PID>
```

### High Memory Usage

```
# Check memory
free -m

# Restart service
sudo systemctl restart frps

# If persistent, upgrade to t2.small
```

### Connection Timeout

```
# Check firewall
sudo iptables -L -n

# Check security group in AWS Console
# Ensure ports 7000, 80, 443 are open
```

### Dashboard Not Accessible

```
# Check if running
curl http://localhost:7500

# If working locally, check security group
# Port 7500 should allow your IP
```

## Security Hardening

### Enable Firewall

```
# Amazon Linux
sudo yum install firewalld -y
sudo systemctl start firewalld
sudo systemctl enable firewalld

sudo firewall-cmd --permanent --add-port=7000/tcp
sudo firewall-cmd --permanent --add-port=80/tcp
sudo firewall-cmd --permanent --add-port=443/tcp
sudo firewall-cmd --reload
```

### Disable Root Login

```
sudo nano /etc/ssh/sshd_config
# Change: PermitRootLogin no
sudo systemctl restart sshd
```

### Enable Automatic Updates

```
# Amazon Linux
sudo yum install yum-cron -y
sudo systemctl enable yum-cron
sudo systemctl start yum-cron
```

### Setup Fail2Ban

```
sudo yum install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
```

## Cost Optimization

### Free Tier (First 12 Months)
- 750 hours/month t2.micro: **FREE**
- 30GB EBS storage: **FREE**
- 100GB data transfer out: **FREE**

### After Free Tier
- t2.micro: ~$8.50/month
- EBS 8GB: ~$0.80/month
- Data transfer: $0.09/GB (after 100GB)
- **Total: ~$10-15/month** (typical usage)

### Save Money
1. Use Reserved Instance (40% savings)
2. Stop instance when not needed
3. Use CloudFront for static content
4. Enable compression in FRP

## Backup & Recovery

### Backup Configuration

```
# Backup config
sudo cp /etc/frp/frps.toml ~/frps.toml.backup

# Create snapshot
# AWS Console → EC2 → Volumes → Create Snapshot
```

### Disaster Recovery

```
# Restore config
sudo cp ~/frps.toml.backup /etc/frp/frps.toml
sudo systemctl restart frps

# Or launch new instance from snapshot
```

## Success Checklist

- [ ] EC2 instance launched (t2.micro)
- [ ] Elastic IP allocated and associated
- [ ] Security group configured correctly
- [ ] FRP server installed
- [ ] Auth token updated
- [ ] Service running and enabled
- [ ] DNS configured (A + CNAME)
- [ ] Dashboard accessible
- [ ] Test tunnel created successfully
- [ ] Monitoring setup
- [ ] Backups configured

---

**Server setup complete!** Users can now create tunnels using the CLI tool.

**Support:** For issues, check troubleshooting section or FRP docs.
```

***

