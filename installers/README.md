# PleXcode SDK Installers

Official installers for PleXcode SDK across all platforms.

## Available Installers

| Platform | File | Method |
|----------|------|--------|
| Windows | `install.bat` | Batch script (run as Admin) |
| Windows | `PlexSetup.msi` | MSI via AdvancedInstaller |
| Linux | `install.sh` | Bash script (sudo required) |
| macOS | `install.command` | App bundle installer |

## Quick Start

### Windows (Batch)
```cmd
Right-click install.bat → Run as Administrator
```

### Windows (MSI - Recommended)
```
1. Download PlexSetup.msi
2. Double-click to run
3. Accept license terms
4. Install
```

### Linux
```bash
sudo chmod +x install.sh
sudo ./install.sh
```

### macOS
```bash
double-click install.command
# Or run in terminal:
chmod +x install.command
./install.command
```

## Version Information

```
Version:     0.1.0
Publisher:   NCOM Systems & NCOM SDK Team
Company:     NCOM Systems (c) 2025
Developer:   Saidie Quinn Newara
Signed:      4/1/2026
```

## What's Installed

### Core Components
- `core/` - PleXcode runtime and PVM
- `tools/` - CLI tools (`plex` command)
- `bridges/` - Language adapters
- `manifesto/` - .mf file handler

### System Integration
- Registry entries (Windows)
- PATH environment variable
- Desktop shortcuts (optional)

## Platform-Specific Notes

### Windows
- Requires Windows 10/11
- Administrator privileges required
- Installs to `C:\Program Files\NCOM\PleXcodeSDK`

### Linux
- Supports Debian/Ubuntu, RHEL/CentOS, Arch
- Requires root (sudo)
- Installs to `/opt/plexcode-sdk`

### macOS
- macOS 11+ (Big Sur and later)
- Creates .app bundle
- Installs to `/Applications/PleXcode SDK.app`

## Building from AdvancedInstaller

See [AdvancedInstaller-Setup-Guide.md](windows/AdvancedInstaller-Setup-Guide.md) for MSI creation.