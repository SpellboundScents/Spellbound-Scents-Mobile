## 🎃 Spellbound Scents App 
# *Coming Soon!* 🕯️✨

<img src="public/logo.png" alt="Spellbound Scents" width="180" />

A cozy, kawaii-Halloween companion app for **Spellbound Scents Wax Co.**  
*Brooms are sweeping, cauldrons are bubbling… the app is brewing!*

---

### 🧪 Prerequisites

- **Rust** (stable)
- **Node.js** (18+ recommended) + **pnpm**
- **Tauri CLI v2**
- **Android builds**: Android Studio / command-line SDK, Java 17, platform tools
- **iOS builds** (macOS): Xcode 15+, CocoaPods

## Run the setup script first:

# Linux
```bash
chmod +x scripts/prereqs-linux.sh
./scripts/prereqs-linux.sh
```
# macOS
```bash
chmod +x scripts/prereqs-macos.sh
./scripts/prereqs-macos.sh
```
# Windows (PowerShell, as Administrator)
```bash
Set-ExecutionPolicy Bypass -Scope Process -Force
.\scripts\prereqs-windows.ps1
```

---

### 📦 Install deps
```bash
pnpm i
```

---

### 📱 Build (Android)

Prereqs: Android Studio or command-line SDK, Java 17, and env vars set.

# Build:
```bash
pnpm tauri android build
```
# Run on device/emulator:
```bash
pnpm tauri android dev
```

---

### 🍎 Build (iOS)

Prereqs (macOS): Xcode 15+, Command Line Tools, CocoaPods

# Build:
```bash
pnpm tauri ios build
```
# Run (simulator):
```bash
pnpm tauri ios dev
```

---

## ☕ Support the brew

[🎃 Buy me a coffee](https://buymeacoffee.com/chirv)
  ---

  <p align="center">🦇🖤 Thanks for visiting! The spirits whisper: <em>“Come back soon…”</em> 🖤🦇</p>
