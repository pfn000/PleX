#!/bin/bash
# PleXcode SDK macOS Installer v0.1.0
# NCOM Systems (c) 2025
# Developer: Saidie Quinn Newara

set -e

PLEX_VERSION="0.1.0"
INSTALL_DIR="/Applications/PleXcode SDK.app"
USER_CONFIG="${HOME}/Library/Application Support/PleXcode"

echo "============================================"
echo "  PleXcode SDK v${PLEX_VERSION}"
echo "  NCOM Systems (c) 2025"
echo "============================================"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "ERROR: This installer is for macOS only"
    exit 1
fi

echo "Installing PleXcode SDK v${PLEX_VERSION}..."

# Create app bundle structure
mkdir -p "${INSTALL_DIR}/Contents"/{MacOS,Resources,Frameworks}
mkdir -p "${USER_CONFIG}"

echo "[OK] App bundle created"

# Create Info.plist
cat > "${INSTALL_DIR}/Contents/Info.plist" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>PleXcode SDK</string>
    <key>CFBundleVersion</key>
    <string>${PLEX_VERSION}</string>
    <key>CFBundleIdentifier</key>
    <string>com.ncom.plexcode-sdk</string>
    <key>CFBundleExecutable</key>
    <string>plex</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
</dict>
</plist>
EOF

echo "[OK] Info.plist created"

# Create main executable
cat > "${INSTALL_DIR}/Contents/MacOS/plex" << 'TOOL'
#!/bin/bash
# PleXcode SDK Launcher
PLEX_VERSION="0.1.0"
exec "/opt/plexcode-sdk/core/plex-runtime" "$@"
TOOL
chmod +x "${INSTALL_DIR}/Contents/MacOS/plex"

echo ""
echo "============================================"
echo "  Installation Complete!"
echo "============================================"
echo ""
echo "Install Location: ${INSTALL_DIR}"
echo "Version: ${PLEX_VERSION}"