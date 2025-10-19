#!/bin/bash
# Klyx Tunnel - Server Installation Script for AWS EC2
# Run as root: sudo bash install-server.sh

set -e

echo "============================================"
echo "  Klyx Tunnel Server Installation"
echo "============================================"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
   echo "Please run as root (use sudo)"
   exit 1
fi

# Variables
FRP_VERSION="0.65.0"
FRP_ARCH="linux_amd64"
FRP_URL="https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_${FRP_ARCH}.tar.gz"

echo "[1/7] Updating system packages..."
yum update -y 2>/dev/null || apt-get update -y 2>/dev/null || true

echo "[2/7] Installing required packages..."
yum install -y wget tar 2>/dev/null || apt-get install -y wget tar 2>/dev/null || true

echo "[3/7] Downloading FRP v${FRP_VERSION}..."
cd /tmp
wget "$FRP_URL" -O frp.tar.gz

echo "[4/7] Extracting FRP..."
tar -xzf frp.tar.gz
cd "frp_${FRP_VERSION}_${FRP_ARCH}"

echo "[5/7] Installing FRP server..."
cp frps /usr/bin/
chmod +x /usr/bin/frps

# Create directories
mkdir -p /etc/frp
mkdir -p /var/log/frp

# Copy configuration if exists
if [ -f /tmp/frps.toml ]; then
    cp /tmp/frps.toml /etc/frp/frps.toml
else
    echo "Warning: frps.toml not found in /tmp"
fi

echo "[6/7] Setting up systemd service..."
if [ -f /tmp/frps.service ]; then
    cp /tmp/frps.service /etc/systemd/system/frps.service
else
    cat > /etc/systemd/system/frps.service << 'EOF'
[Unit]
Description=FRP Server Service - Klyx Tunnel
After=network.target

[Service]
Type=simple
User=root
Restart=on-failure
RestartSec=5s
ExecStart=/usr/bin/frps -c /etc/frp/frps.toml
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
EOF
fi

# Reload systemd
systemctl daemon-reload
systemctl enable frps.service
systemctl start frps.service

echo "[7/7] Configuring firewall..."
# For Amazon Linux / RHEL
if command -v firewall-cmd > /dev/null 2>&1; then
    firewall-cmd --permanent --add-port=7000/tcp
    firewall-cmd --permanent --add-port=80/tcp
    firewall-cmd --permanent --add-port=443/tcp
    firewall-cmd --permanent --add-port=7500/tcp
    firewall-cmd --reload
fi

# Using iptables as fallback
iptables -A INPUT -p tcp --dport 7000 -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null || true
iptables -A INPUT -p tcp --dport 7500 -j ACCEPT 2>/dev/null || true

echo ""
echo "============================================"
echo "  Installation Complete!"
echo "============================================"
echo ""
echo "Service Status:"
systemctl status frps.service --no-pager
echo ""
echo "Dashboard: http://YOUR_SERVER_IP:7500"
echo "Username: admin"
echo "Password: klyx-admin-2024"
echo ""
echo "IMPORTANT: Update the auth token in /etc/frp/frps.toml"
echo "Then restart: sudo systemctl restart frps"
echo ""
