
# Klyx Tunnel - CLI Tool

## Installation

### From Source

```
cd client
npm install
node src/index.js login
```

### Using Pre-built Executable

Download from releases and run directly - no installation needed!

## Configuration

```
klyx-tunnel login
```

Enter:
- Server: tunnel.klyx.agency
- Port: 7000
- Token: (provided by admin)
- Domain: tunnel.klyx.agency

## Usage

### Tunnel Web Application

```
# Basic
klyx-tunnel 3000

# Custom subdomain
klyx-tunnel 3000 --name my-app

# With expiry
klyx-tunnel 3000 --expire 24
```

### Share Folder

```
# Basic
klyx-tunnel folder /path/to/folder --name client-files

# Password protected
klyx-tunnel folder ./assets --name secure --password secret123

# Full featured
klyx-tunnel folder "C:\Files" --name project --password abc --expire 48 --limit 50MB
```

### Manage Tunnels

```
# List all
klyx-tunnel list

# Stop specific
klyx-tunnel stop my-app

# Check status
klyx-tunnel status
```

## Building

```
# Install dependencies
npm install

# Install pkg globally
npm install -g pkg

# Build all platforms
npm run build

# Or build specific platform
npm run build:win
npm run build:linux
npm run build:mac
```

Output in `dist/` folder.

## Troubleshooting

### "Not configured"
Run `klyx-tunnel login` first

### "Cannot reach server"
Check server is running and token is correct

### "Port already in use"
Stop existing tunnel with `klyx-tunnel stop <name>`
```

