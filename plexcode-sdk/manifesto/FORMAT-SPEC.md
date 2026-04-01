# .mf (Manifesto) File Format

## Overview
Encrypted container for PleXcode files:
- `.TAG` files (metadata)
- `.attributes` (asset references)
- `.plx` source (encrypted)
- Can open as HTML in any browser
- Tamper-proof signatures

## Security
- AES-256-GCM encryption
- Unique key per file
- Digital signatures required
- Modification breaks signature

## Usage
- **Browser**: Double-click → Shows documentation
- **SDK**: `plex run file.mf` → Execute

## Publisher Info
- **Publisher**: NCOM Systems & NCOM SDK Team
- **Company**: NCOM Systems (c) 2025
- **Developer**: Saidie Quinn Newara
- **Signed**: 4/1/2026