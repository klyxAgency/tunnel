# Klyx Tunnel - Command Reference

Quick reference for all Klyx Tunnel commands and installation methods.

---

## 🚀 Installation

### One-Liner Install (PowerShell)
```
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/klyxAgency/tunnel/main/klyx-installer-dark.ps1 | Out-File $env:TEMP\k.ps1; & $env:TEMP\k.ps1`"'"
```

### Alternative: Download & Run
```
Invoke-WebRequest "https://raw.githubusercontent.com/klyxAgency/tunnel/main/klyx-installer-dark.ps1" -OutFile "$env:TEMP\klyx.ps1"
Start-Process powershell -Verb RunAs -ArgumentList "-ExecutionPolicy Bypass -File $env:TEMP\klyx.ps1"
```

### Batch File Install
Create `install-klyx.bat`:
```
@echo off
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/klyxAgency/tunnel/main/klyx-installer-dark.ps1 | Out-File $env:TEMP\k.ps1; & $env:TEMP\k.ps1`"'"
```

---

## 📁 Folder Sharing Commands

### Basic Folder Sharing
```
klyx folder C:\Users\YourName\Documents --name myfiles
```

### With Custom Name
```
klyx folder C:\Path\To\Folder --name demo
```

### With Password Protection
```
klyx folder C:\Files --name secure --password mypassword123
```

### With Auto-Expire (Hours)
```
klyx folder C:\Files --name temp --expire 24
```

### With Bandwidth Limit
```
klyx folder C:\Files --name limited --limit 50mbps
```

### Complete Example (All Options)
```
klyx folder C:\Files --name share --password secret --expire 12 --limit 100mbps
```

**Access URL Format:**
```
https://yourname.tunnel.klyx.agency
```

**Features:**
- ✅ Beautiful dark-themed UI
- ✅ Download all files as ZIP
- ✅ Individual file downloads
- ✅ File listing with icons
- ✅ HTTPS enabled

---

## 🌐 Web Server Tunneling

### Basic Tunnel (Port Only)
```
klyx 3000
```

### With Custom Subdomain
```
klyx 3000 --name myapp
```

### With Auto-Expire
```
klyx 8080 --name demo --expire 6
```

### Explicit Tunnel Command
```
klyx tunnel 3000 --name api
```

**Access URL Format:**
```
https://myapp.tunnel.klyx.agency
```

---

## 🔧 Management Commands

### List Active Tunnels
```
klyx list
```

### Stop Specific Tunnel
```
klyx stop myapp
```

### Check Status
```
klyx status
```

### Login / Configure Token
```
klyx login
```

### Check Version
```
klyx --version
```

### Help
```
klyx --help
```

---

## 🎯 Common Use Cases

### Share Project Folder
```
cd C:\Projects\MyWebsite
klyx folder . --name website --password demo123
```

### Tunnel Local Development Server
```
# React/Vite (usually port 5173)
klyx 5173 --name myreactapp

# Node.js Express (usually port 3000)
klyx 3000 --name myapi

# Python Flask (usually port 5000)
klyx 5000 --name myflaskapp
```

### Temporary File Share (Auto-Delete After 2 Hours)
```
klyx folder C:\Temp\Files --name quickshare --expire 2
```

### Share Large Files with Speed Limit
```
klyx folder C:\Videos --name media --limit 200mbps
```

### Secure Document Sharing
```
klyx folder C:\Documents\Confidential --name docs --password SecurePass123 --expire 24
```

---

## 🔐 Security Notes

- **Passwords**: Use strong passwords for sensitive files
- **Expiration**: Always set `--expire` for temporary shares
- **HTTPS**: All connections use HTTPS by default
- **Access Control**: Only people with the URL can access

---

## 📂 File Locations

### Installed Executables
```
C:\Program Files\Klyx\klyx.exe
```

### FRP Client
```
%APPDATA%\.klyx-tunnel\bin\frpc.exe
```

### Configuration
```
%APPDATA%\.klyx-tunnel\config.json
```

### Temp Installer Cache
```
%TEMP%\klyx-install\
```

---

## 🔄 Update Klyx

Rerun the installer to update to the latest version:
```
powershell -Command "Start-Process powershell -Verb RunAs -ArgumentList '-ExecutionPolicy Bypass -Command `"irm https://raw.githubusercontent.com/klyxAgency/tunnel/main/klyx-installer-dark.ps1 | Out-File $env:TEMP\k.ps1; & $env:TEMP\k.ps1`"'"
```

---

## ❌ Uninstall

### Remove Klyx
```
# Remove executable
Remove-Item "C:\Program Files\Klyx" -Recurse -Force

# Remove from PATH (requires admin)
$path = [Environment]::GetEnvironmentVariable("Path", "Machine")
$newPath = $path -replace ";?C:\\Program Files\\Klyx", ""
[Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")

# Remove config
Remove-Item "$env:APPDATA\.klyx-tunnel" -Recurse -Force
```

---

## 🐛 Troubleshooting

### "klyx is not recognized"
**Solution:** Open a NEW PowerShell window after installation

### "FRP client not found"
**Solution:** Manually download frpc.exe to `%APPDATA%\.klyx-tunnel\bin\`

### "Not configured. Please run: klyx login"
**Solution:** Run `klyx login` and enter your authentication token

### Connection Refused
**Solution:** Ensure local server is running before tunneling

### Permission Denied
**Solution:** Run PowerShell as Administrator for installation

---

## 📖 Examples

### Example 1: Share Portfolio Website
```
cd C:\Projects\Portfolio
klyx folder . --name portfolio
# Share: https://portfolio.tunnel.klyx.agency
```

### Example 2: Tunnel React Dev Server
```
# Terminal 1: Start React
npm run dev

# Terminal 2: Create tunnel
klyx 5173 --name myreactapp
# Access: https://myreactapp.tunnel.klyx.agency
```

### Example 3: Secure File Transfer
```
klyx folder C:\SensitiveData --name transfer --password Secure2024 --expire 1
# Will auto-delete after 1 hour
```

---

## 🌟 Pro Tips

1. **Use Descriptive Names**: `--name project-demo` instead of random names
2. **Always Set Expiration**: For temporary shares, use `--expire`
3. **Password Protect Sensitive Data**: Use `--password` for private files
4. **Limit Bandwidth for Large Files**: Use `--limit 100mbps` to prevent overload
5. **Test Locally First**: Ensure your server works on localhost before tunneling

---

## 📞 Support

- **GitHub**: https://github.com/klyxAgency/tunnel
- **Issues**: https://github.com/klyxAgency/tunnel/issues
- **Documentation**: https://github.com/klyxAgency/tunnel/blob/main/README.md

---

## 🎉 Quick Start Checklist

- [ ] Install Klyx using one-liner
- [ ] Open NEW PowerShell window
- [ ] Run `klyx --version` to verify
- [ ] Test with: `klyx folder C:\Users\YourName\Documents --name test`
- [ ] Open the URL in browser
- [ ] Download all as ZIP ✅
- [ ] Stop tunnel with Ctrl+C

---

**Made with ❤️ by Klyx Agency**
```
