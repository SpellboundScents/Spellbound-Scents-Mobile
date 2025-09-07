#!/usr/bin/env bash
set -euo pipefail

# Detect Debian/Ubuntu vs. Fedora
if command -v apt >/dev/null 2>&1; then
  sudo apt update
    sudo apt install -y \
        build-essential curl wget git pkg-config libssl-dev \
            libgtk-3-dev libayatana-appindicator3-dev librsvg2-dev \
                # WebKitGTK 4.1 (newer dists)
                    libwebkit2gtk-4.1-dev libjavascriptcoregtk-4.1-dev || true
                      # Fallback to 4.0 on older dists
                        sudo apt install -y libwebkit2gtk-4.0-dev libjavascriptcoregtk-4.0-dev || true

                        elif command -v dnf >/dev/null 2>&1; then
                          sudo dnf install -y \
                              clang curl wget git pkgconf-pkg-config openssl-devel \
                                  gtk3-devel libappindicator-gtk3 librsvg2-devel webkit2gtk4.1-devel || true
                                    sudo dnf install -y webkit2gtk3-devel || true
                                    fi

                                    # Rust (if missing)
                                    if ! command -v rustc >/dev/null 2>&1; then
                                      curl https://sh.rustup.rs -sSf | sh -s -- -y
                                        source "$HOME/.cargo/env"
                                        fi

                                        # Node + pnpm (using corepack)
                                        if ! command -v node >/dev/null 2>&1; then
                                          # install a recent Node via nvm
                                            curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
                                              export NVM_DIR="$HOME/.nvm"
                                                [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
                                                  nvm install --lts
                                                  fi

                                                  corepack enable
                                                  corepack prepare pnpm@latest --activate

                                                  echo "✅ Linux prerequisites installed. You can now: pnpm i"