#Requires -RunAsAdministrator
$ErrorActionPreference = "Stop"
Write-Host "🧙‍♂️ Spellbound setup (Windows)…"

# Ensure winget exists
if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
  Write-Host "❌ winget not found. Please update to the latest Windows 10/11 or install App Installer from Microsoft Store."
    exit 1
    }

    # Git
    Write-Host "→ Installing Git…"
    winget install --id Git.Git -e --source winget --silent || Write-Host "Git may already be installed."

    # Node LTS (includes Corepack)
    Write-Host "→ Installing Node.js LTS…"
    winget install --id OpenJS.NodeJS.LTS -e --source winget --silent || Write-Host "Node may already be installed."

    # Enable Corepack + pnpm (in current session and for later shells)
    $env:COREPACK_ENABLE_DOWNLOAD_PROMPT=0
    try { corepack enable } catch {}
    try { corepack prepare pnpm@latest --activate } catch {}

    # Rust (rustup)
    Write-Host "→ Installing Rustup + stable toolchain…"
    winget install --id Rustlang.Rustup -e --source winget --silent || Write-Host "Rustup may already be installed."

    # Visual Studio Build Tools (for MSVC, required by Tauri)
    # Note: --override passes arguments to VS installer. May take a while.
    Write-Host "→ Installing Visual Studio 2022 Build Tools (C++ & Windows SDK)…"
    winget install --id Microsoft.VisualStudio.2022.BuildTools -e --source winget `
      --override "--add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --quiet --wait" `
        --silent || Write-Host "VS Build Tools may already be installed."

        # Windows 11 SDK (usually included above, but ensure via component)
        # If needed you can explicitly add a specific SDK component like below:
        # winget install --id Microsoft.VisualStudio.2022.BuildTools -e --source winget `
        #   --override "--add Microsoft.VisualStudio.Component.Windows11SDK.22621 --quiet --wait" --silent

        # WebView2 Runtime (required by Tauri on Windows)
        Write-Host "→ Installing WebView2 Runtime…"
        winget install --id Microsoft.EdgeWebView2Runtime -e --source winget --silent `
          || winget install --id Microsoft.Edge.WebView2Runtime -e --source winget --silent `
            || Write-Host "WebView2 may already be installed."

            # Android (optional, for Android builds on Windows)
            Write-Host "→ (Optional) Installing Android Studio…"
            winget install --id Google.AndroidStudio -e --source winget --silent `
              || Write-Host "Android Studio install skipped or already present."

              Write-Host ""
              Write-Host "✅ Windows prerequisites installed."
              Write-Host "• Ensure JAVA 17 is available if building Android (Android Studio bundles a JDK)."
              Write-Host "• After opening a new terminal, run: corepack enable; corepack prepare pnpm@latest --activate"
              Write-Host "You can now run: pnpm i"