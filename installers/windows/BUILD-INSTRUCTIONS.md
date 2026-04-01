# AdvancedInstaller Build Instructions

## Step 1: Open AdvancedInstaller

1. Launch **AdvancedInstaller** (v25.0 or newer recommended)
2. Go to **File** → **Import** → **Repackager** → **Import Project**
3. Select `PleXcodeSDK.aip` or `IMPORT-CONFIG.aic`

## Step 2: Configure Project

### Product Details
- **Name**: PleXcode SDK
- **Version**: 0.1.0
- **Upgrade Code**: {A1B2C3D4-E5F6-7890-ABCD-EF1234567890}

### Publisher Information
- **Publisher**: NCOM Systems & NCOM SDK Team
- **Company**: NCOM Systems (c) 2025
- **Developer**: Saidie Quinn Newara
- **Signed**: 4/1/2026

## Step 3: Add Visual Assets

1. **Splash Screen**: 
   - Go to **User Interface** → **Dialogs** → **Splash**
   - Add: `../../Assets/Images/NCOM Logo.png`

2. **License Dialog**:
   - Go to **User Interface** → **Dialogs** → **LicenseAgreement**  
   - Point to: `../../LICENSE.md`

3. **Installer Banner**:
   - **Dialogs** → **Banner** → `../../Assets/Images/NCOM Systems 2026 Banner.PNG`

4. **Product Icon**:
   - Convert: `../../Assets/Images/PleX code.png` to `.ico`
   - Set as product icon

## Step 4: Add Files

### Core Files
```
Source: ../../plexcode-sdk/core/
Target: [ProgramFiles64Folder]\NCOM\PleXcode SDK\core\
```

### Jane AI
```
Source: ../../jane-ai/
Target: [ProgramFiles64Folder]\NCOM\PleXcode SDK\jane-ai\
```

### Tools
```
Source: ../../plexcode-sdk/tools/
Target: [ProgramFiles64Folder]\NCOM\PleXcode SDK\tools\
```

### Bridges
```
Source: ../../plexcode-sdk/bridges/
Target: [ProgramFiles64Folder]\NCOM\PleXcode SDK\bridges\
```

## Step 5: Configure DLLs

### Security DLLs
```
- ncom_security.dll (code signing)
- plex_manifest.dll (manifesto verification)
- plex_runtime.dll (core runtime)
```

Locate these in `dlls/` folder or mark as **COM/ActiveX** components

## Step 6: Build MSI

1. Go to **Build** → **Build MSIs**
2. **Output**: `PleXcodeSDK_0.1.0.msi`
3. Click **Build**

## Step 7: Sign MSI (Optional but Recommended)

```bash
signtool sign /f ncom.pfx /p password /t http://timestamp.digicert.com /d "PleXcode SDK" PleXcodeSDK_0.1.0.msi
```

## Output

- `Output/PleXcodeSDK_0.1.0.msi` - Ready to install!
- Creates Start Menu shortcut: **PleXcode SDK**
- Registers in Add/Remove Programs

## Registry Keys Added

```
HKEY_LOCAL_MACHINE\SOFTWARE\NCOM\PleXcodeSDK
  Version     = "0.1.0"
  InstallPath = "C:\Program Files\NCOM\PleXcode SDK"
  Publisher   = "NCOM Systems & NCOM SDK Team"
  Developer   = "Saidie Quinn Newara"
  Company     = "NCOM Systems (c) 2025"
  Signed      = "4/1/2026"
```

## Troubleshooting

### "Cannot import .aip file"
- Use **File** → **Open** instead
- Select `.aip` file

### "Missing images"
- Copy images to `Assets/Images/` folder before import
- Or manually add in **User Interface** tab

### "Build fails"
- Check **Files and Folders** has valid source paths
- Ensure all referenced files exist