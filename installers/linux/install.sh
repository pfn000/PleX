#!/bin/bash
# PleXcode SDK Linux Installer v0.1.0
# NCOM Systems (c) 2025
# Developer: Saidie Quinn Newara

set -e

PLEX_VERSION="0.1.0"
INSTALL_DIR="/opt/plexcode-sdk"
USER_CONFIG="${HOME}/.config/plexcode"

echo "============================================"
echo "  PleXcode SDK v${PLEX_VERSION}"
echo "  NCOM Systems (c) 2025"
echo "  Publisher: NCOM Systems & NCOM SDK Team"
echo "  Signed: 4/1/2026"
echo "============================================"
echo ""

# Check for root
if [ "$EUID" -ne 0 ]; then 
    echo "ERROR: Please run as root (use sudo)"
    exit 1
fi

echo "Installing PleXcode SDK v${PLEX_VERSION}..."

# Create directories
mkdir -p "${INSTALL_DIR}"/{core,tools,bridges,manifesto}
mkdir -p "${USER_CONFIG}"

echo "[OK] Directories created"

# Create version info
cat > "${INSTALL_DIR}/version" << EOF
PLEXCODE_SDK_VERSION=${PLEX_VERSION}
PUBLISHER=NCOM Systems & NCOM SDK Team
COMPANY=NCOM Systems (c) 2025
DEVELOPER=Saidie Quinn Newara
SIGNED=4/1/2026
EOF

# Install tools
cat > "${INSTALL_DIR}/tools/plex" << 'TOOL'
#!/bin/bash
# PleXcode CLI wrapper
PLEX_HOME="/opt/plexcode-sdk"
exec "${PLEX_HOME}/core/plex-runtime" "$@"
TOOL
chmod +x "${INSTALL_DIR}/tools/plex"

# Create symlink
ln -sf "${INSTALL_DIR}/tools/plex" /usr/local/bin/plex 2>/dev/null || true

echo "[OK] Tools installed"

# Setup environment
cat > /etc/profile.d/plexcode.sh << EOF
export PLEXCODE_SDK_VERSION="${PLEX_VERSION}"
export PLEXCODE_HOME="${INSTALL_DIR}"
EOF

echo ""
echo "============================================"
echo "  Installation Complete!"
echo "============================================"
echo ""
echo "Install Location: ${INSTALL_DIR}"
echo "Version: ${PLEX_VERSION}"
echo ""
echo "Run: plex --help"