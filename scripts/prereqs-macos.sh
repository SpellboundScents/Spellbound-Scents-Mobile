#!/usr/bin/env bash
set -euo pipefail

echo "🧙‍♀️ Spellbound setup (macOS)…"

# Xcode CLT (required for compilers & headers)
if ! xcode-select -p >/dev/null 2>&1; then
  echo "→ Installing Xcode Command Line Tools (a dialog may appear)…"
    xcode-select --install || true
    fi

    # Homebrew
    if ! command -v brew >/dev/null 2>&1; then
      echo "→ Installing Homebrew…"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
          echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile" || true
            eval "$(/opt/homebrew/bin/brew shellenv)"
            fi

            echo "→ Installing base packages…"
            brew update
            brew install git wget pkg-config openssl@3

            # Java 17 for Android builds
            if ! /usr/libexec/java_home -v 17 >/dev/null 2>&1; then
              echo "→ Installing Java 17 (Temurin)…"
                brew install --cask temurin17
                fi

                # Rust (stable)
                if ! command -v rustc >/dev/null 2>&1; then
                  echo "→ Installing Rust toolchain…"
                    curl https://sh.rustup.rs -sSf | sh -s -- -y
                      source "$HOME/.cargo/env"
                      fi

                      # Node + pnpm via corepack (prefer system Node via brew, else nvm)
                      if ! command -v node >/dev/null 2>&1; then
                        echo "→ Installing Node (brew)…"
                          brew install node
                          fi

                          echo "→ Enabling corepack + pnpm…"
                          corepack enable
                          corepack prepare pnpm@latest --activate

                          # CocoaPods for iOS
                          if ! command -v pod >/dev/null 2>&1; then
                            echo "→ Installing CocoaPods…"
                              brew install cocoapods || sudo gem install cocoapods
                              fi

                              echo ""
                              echo "✅ macOS prerequisites installed."
                              echo "• iOS: open the Xcode workspace when Tauri generates it (CocoaPods handled in build)."
                              echo "• Android: install Android Studio separately and set ANDROID_HOME + accept SDK licenses."
                              echo "You can now run: pnpm i"