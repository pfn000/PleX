@echo off
REM PleXcode SDK Windows Installer v0.1.0
REM NCOM Systems (c) 2025
REM Developer: Saidie Quinn Newara

title PleXcode SDK Installer
echo ============================================
echo   PleXcode SDK v0.1.0
echo   NCOM Systems (c) 2025
echo   Publisher: NCOM Systems & NCOM SDK Team
echo   Signed: 4/1/2026
echo ============================================
echo.

REM Check for admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: Administrator privileges required.
    echo Please run as Administrator.
    pause
    exit /b 1
)

set INSTALL_DIR=%ProgramFiles%\NCOM\PleXcodeSDK
set VERSION=0.1.0

echo Installing PleXcode SDK v%VERSION%...
echo Install Directory: %INSTALL_DIR%
echo.

REM Create directories
mkdir "%INSTALL_DIR%\core" 2>nul
mkdir "%INSTALL_DIR%\tools" 2>nul
mkdir "%INSTALL_DIR%\bridges" 2>nul
mkdir "%INSTALL_DIR%\manifesto" 2>nul
mkdir "%LOCALAPPDATA%\NCOM\PleXcode\config" 2>nul

echo [OK] Directories created

REM Set registry keys for version tracking
reg add "HKLM\SOFTWARE\NCOM\PleXcodeSDK" /v Version /t REG_SZ /d "%VERSION%" /f >nul
reg add "HKLM\SOFTWARE\NCOM\PleXcodeSDK" /v InstallPath /t REG_SZ /d "%INSTALL_DIR%" /f >nul
reg add "HKLM\SOFTWARE\NCOM\PleXcodeSDK" /v Publisher /t REG_SZ /d "NCOM Systems & NCOM SDK Team" /f >nul
reg add "HKLM\SOFTWARE\NCOM\PleXcodeSDK" /v Developer /t REG_SZ /d "Saidie Quinn Newara" /f >nul
reg add "HKLM\SOFTWARE\NCOM\PleXcodeSDK" /v Signed /t REG_SZ /d "4/1/2026" /f >nul
reg add "HKLM\SOFTWARE\NCOM\PleXcodeSDK" /v Company /t REG_SZ /d "NCOM Systems (c) 2025" /f >nul

echo [OK] Registry entries added

REM Add to PATH
setx PATH "%PATH%;%INSTALL_DIR%\tools" /M >nul 2>&1

echo.
echo ============================================
echo   Installation Complete!
echo ============================================
echo.
echo Install Location: %INSTALL_DIR%
echo Version: %VERSION%
echo.
pause
