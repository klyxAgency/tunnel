### 📄 `docs/DNS-SETUP.md`

```markdown
# DNS Configuration Guide

Complete guide for setting up wildcard DNS with Cloudflare.

## Prerequisites

- Domain: klyx.agency (or your domain)
- Cloudflare account
- AWS EC2 Elastic IP address

## Cloudflare Setup (Recommended)

### Step 1: Add A Record

1. Log in to **Cloudflare Dashboard**
2. Select your domain: **klyx.agency**
3. Navigate to **DNS** → **Records**
4. Click **Add record**

**Configuration:**
- **Type:** A
- **Name:** tunnel
- **IPv4 address:** YOUR_EC2_ELASTIC_IP (e.g., 54.123.45.67)
- **TTL:** Auto
- **Proxy status:** DNS only (gray cloud icon - NOT proxied)

Click **Save**

### Step 2: Add Wildcard CNAME

Click **Add record** again

**Configuration:**
- **Type:** CNAME
- **Name:** * (asterisk)
- **Target:** tunnel.klyx.agency
- **TTL:** Auto
- **Proxy status:** DNS only (gray cloud)

Click **Save**

### Step 3: Verify DNS Records

Your DNS records should look like this:

```
Type    Name     Content                Proxy Status
A       tunnel   54.123.45.67          DNS only
CNAME   *        tunnel.klyx.agency     DNS only
```

### Step 4: Test DNS Propagation

Wait 5-10 minutes, then test:

```
# Windows (Command Prompt)
nslookup tunnel.klyx.agency
nslookup test.tunnel.klyx.agency
nslookup anything.tunnel.klyx.agency

# Linux/Mac (Terminal)
dig tunnel.klyx.agency
dig test.tunnel.klyx.agency
dig randomname.tunnel.klyx.agency

# Check from external DNS checker
# Visit: https://dnschecker.org
# Enter: tunnel.klyx.agency
```

All subdomains should resolve to your EC2 IP.

## Alternative DNS Providers

### Namecheap

1. Go to **Domain List** → **Manage**
2. Click **Advanced DNS** tab

**Add A Record:**
- **Host:** tunnel
- **Value:** YOUR_EC2_IP
- **TTL:** Automatic

**Add CNAME Record:**
- **Host:** *
- **Target:** tunnel.klyx.agency
- **TTL:** Automatic

### GoDaddy

1. Go to **My Products** → **DNS Management**

**Add A Record:**
- **Name:** tunnel
- **Value:** YOUR_EC2_IP
- **TTL:** 600 seconds

**Add CNAME Record:**
- **Name:** *
- **Points to:** tunnel.klyx.agency
- **TTL:** 1 Hour

### Google Domains

1. Go to **DNS** settings

**Add A Record:**
- **Host name:** tunnel
- **Type:** A
- **TTL:** 1h
- **Data:** YOUR_EC2_IP

**Add CNAME Record:**
- **Host name:** *
- **Type:** CNAME
- **TTL:** 1h
- **Data:** tunnel.klyx.agency

### Route 53 (AWS)

1. Create **Hosted Zone** for klyx.agency
2. Create **A Record Set:**
   - **Name:** tunnel.klyx.agency
   - **Type:** A
   - **Value:** YOUR_EC2_IP

3. Create **CNAME Record Set:**
   - **Name:** *.tunnel.klyx.agency
   - **Type:** CNAME
   - **Value:** tunnel.klyx.agency

## Testing Your Setup

### Basic DNS Test

```
# Should return your EC2 IP
nslookup tunnel.klyx.agency

# Test wildcards
nslookup app1.tunnel.klyx.agency
nslookup app2.tunnel.klyx.agency
nslookup test123.tunnel.klyx.agency
```

### HTTP Test

```
# Test server is responding
curl http://tunnel.klyx.agency:7500

# Should show FRP dashboard or connection
```

### Full Integration Test

```
# On your local machine, run:
klyx-tunnel 3000 --name test

# Should get:
# http://test.tunnel.klyx.agency
```

## Troubleshooting

### DNS Not Resolving

**Problem:** `nslookup tunnel.klyx.agency` fails

**Solutions:**
1. Verify records are saved in DNS provider
2. Wait 10-15 minutes for propagation
3. Check TTL settings (lower is faster)
4. Clear local DNS cache:
   ```
   # Windows
   ipconfig /flushdns
   
   # Mac
   sudo dscacheutil -flushcache
   sudo killall -HUP mDNSResponder
   
   # Linux
   sudo systemd-resolve --flush-caches
   ```

### Wildcard Not Working

**Problem:** Main domain works but `*.tunnel.klyx.agency` doesn't

**Solutions:**
1. Ensure CNAME target is exactly: `tunnel.klyx.agency`
2. Do NOT include `http://` or trailing `/`
3. Check proxy status is OFF (gray cloud in Cloudflare)
4. Test with multiple random subdomains

### SSL/HTTPS Issues

**For HTTPS support via Cloudflare:**

1. Change proxy status to **Proxied** (orange cloud)
2. Go to **SSL/TLS** → **Overview**
3. Set mode to **Flexible** or **Full**

**For Let's Encrypt on server:**

```
# On EC2
sudo yum install certbot -y

# Get wildcard certificate
sudo certbot certonly --standalone \
  -d tunnel.klyx.agency \
  -d *.tunnel.klyx.agency

# Update frps.toml
# Add:
# transport.tls.certFile = "/etc/letsencrypt/live/tunnel.klyx.agency/fullchain.pem"
# transport.tls.keyFile = "/etc/letsencrypt/live/tunnel.klyx.agency/privkey.pem"

sudo systemctl restart frps
```

### Propagation Taking Too Long

**Check propagation status:**
- Visit: https://dnschecker.org
- Enter: tunnel.klyx.agency
- View global propagation

**Speed up propagation:**
1. Lower TTL to 300 seconds (5 minutes)
2. Use Cloudflare (fastest propagation)
3. Wait at least 15 minutes before testing

### Wrong IP Resolving

**Problem:** DNS resolves to old/wrong IP

**Solutions:**
1. Update A record with correct Elastic IP
2. Ensure Elastic IP is associated with EC2 instance
3. Clear DNS cache (see above)
4. Check if you have multiple A records (delete old ones)

## Advanced Configuration

### Multiple Environments

```
# Production
A       tunnel         54.123.45.67
CNAME   *              tunnel.klyx.agency

# Staging
A       tunnel-staging 54.123.45.68
CNAME   *.staging      tunnel-staging.klyx.agency
```

### Custom Subdomain Patterns

```
# Specific subdomains only
CNAME   app1           tunnel.klyx.agency
CNAME   app2           tunnel.klyx.agency
CNAME   api            tunnel.klyx.agency
```

### Geographic Routing (Route 53)

1. Create multiple A records with same name
2. Set routing policy to **Geolocation**
3. Route users to nearest server

## Security Considerations

### DNS Security

1. **Enable DNSSEC** in Cloudflare (recommended)
2. **Restrict dashboard access** (port 7500) to your IP only
3. **Use strong auth token** in FRP configuration
4. **Monitor DNS changes** with alerts

### Cloudflare Protection

**Enable these features:**
- Under Attack Mode (if needed)
- Rate Limiting
- Firewall Rules
- DDoS Protection

## Maintenance

### Updating IP Address

```
# If you get new Elastic IP
# 1. Update A record in DNS
# 2. Wait 5-10 minutes
# 3. Test with nslookup
```

### Monitoring DNS

```
# Automated monitoring script
watch -n 60 'dig tunnel.klyx.agency +short'
```

## Summary Checklist

- [ ] A record created: tunnel.klyx.agency → EC2 IP
- [ ] CNAME wildcard created: * → tunnel.klyx.agency
- [ ] Proxy status is OFF (gray cloud)
- [ ] DNS propagation verified with nslookup
- [ ] Multiple subdomains tested
- [ ] HTTP connection to server:7500 successful
- [ ] Full tunnel test completed

---

**DNS setup complete!** Now users can create tunnels with custom subdomains.
```

***

