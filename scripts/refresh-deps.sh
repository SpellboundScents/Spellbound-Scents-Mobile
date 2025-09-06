#!/usr/bin/env bash
set -euo pipefail

# Options:
#   --no-audit     Skip pnpm audit (faster)
#   --dry-run      Show actions without changing anything
#   --npm-only     Force npm -g for pnpm instead of Corepack

TARGET_PNPM="10.15.1"
RUN_AUDIT=true
DRY_RUN=false
NPM_ONLY=false

for arg in "$@"; do
  case "$arg" in
      --no-audit) RUN_AUDIT=false ;;
          --dry-run) DRY_RUN=true ;;
              --npm-only) NPM_ONLY=true ;;
                  *) echo "Unknown option: $arg"; exit 2 ;;
                    esac
                    done

                    say() { printf '%b\n' "$*"; }
                    run() { $DRY_RUN && say "DRY-RUN: $*" || eval "$@"; }

                    # --- 1) Ensure pnpm@10.15.1 globally (Corepack preferred) ---
                    if ! $NPM_ONLY && command -v corepack >/dev/null 2>&1; then
                      say "🔧 Using Corepack to activate pnpm@${TARGET_PNPM}…"
                        run "corepack enable"
                          run "corepack prepare pnpm@${TARGET_PNPM} --activate"
                          else
                            say "🔧 Installing pnpm@${TARGET_PNPM} globally via npm…"
                              command -v npm >/dev/null 2>&1 || { say "❌ npm not found in PATH"; exit 1; }
                                run "npm install -g pnpm@${TARGET_PNPM}"
                                fi

                                # Verify
                                PNPM_PATH="$(command -v pnpm || true)"
                                PNPM_VER="$(pnpm -v 2>/dev/null || true)"
                                say "🔎 pnpm path: ${PNPM_PATH:-<not found>}"
                                say "🔎 pnpm version: ${PNPM_VER:-<unknown>}"
                                if [ "$PNPM_VER" != "$TARGET_PNPM" ]; then
                                  say "❌ pnpm version is '$PNPM_VER' (expected ${TARGET_PNPM}). Aborting."
                                    exit 1
                                    fi

                                    # --- 2) Remove accidentally installed local pnpm dependency ---
                                    if [ -f package.json ] && grep -q '"pnpm"\s*:' package.json; then
                                      say "🧽 Removing local 'pnpm' from package.json…"
                                        run "pnpm remove pnpm || true"
                                        fi

                                        # --- 3) Clean node_modules, lockfile, and prune store ---
                                        if [ -d node_modules ] || [ -f pnpm-lock.yaml ]; then
                                          say "🧹 Deleting node_modules and pnpm-lock.yaml…"
                                            run "rm -rf node_modules pnpm-lock.yaml"
                                            else
                                              say "✅ Nothing to clean (no node_modules or lockfile)."
                                              fi

                                              say "🗃️  Pruning pnpm store (optional)…"
                                              run "pnpm store prune || true"

                                              # --- 4) Fresh install to regenerate the lockfile with pnpm 10.15.1 ---
                                              say "📦 Installing dependencies fresh (this regenerates pnpm-lock.yaml)…"
                                              run "pnpm install --force"

                                              # --- 5) Deduplicate (workspace-aware) ---
                                              if [ -f pnpm-workspace.yaml ]; then
                                                say "🧩 Workspace detected — running dedupe -r…"
                                                  run "pnpm dedupe -r || true"
                                                  else
                                                    run "pnpm dedupe || true"
                                                    fi

                                                    # --- 6) Optional security check ---
                                                    if $RUN_AUDIT; then
                                                      say "🔐 pnpm audit (prod)…"
                                                        run "pnpm audit --prod || true"
                                                        else
                                                          say "⏭️ Skipping audit (--no-audit)."
                                                          fi

                                                          say ""
                                                          say "✅ Lockfile reset complete with pnpm@${TARGET_PNPM}."
                                                          say "   You can now build/test as usual."
