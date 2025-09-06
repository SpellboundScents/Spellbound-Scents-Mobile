#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./scripts/refresh-deps-linux.sh
# Options:
#   --keep-lock   Keep existing pnpm-lock.yaml (more conservative)
#   --no-audit    Skip pnpm audit
#   --quiet-fund  Suppress funding messages (adds 'fund=false' to .npmrc)
#   --conservative Use range-respecting updates (no -L latest)

PNPM_MIN="11.0.0"
KEEP_LOCK=false
RUN_AUDIT=true
QUIET_FUND=false
CONSERVATIVE=false

for arg in "$@"; do
  case "$arg" in
      --keep-lock) KEEP_LOCK=true ;;
          --no-audit) RUN_AUDIT=false ;;
              --quiet-fund) QUIET_FUND=true ;;
                  --conservative) CONSERVATIVE=true ;;
                      *) echo "Unknown option: $arg"; exit 2 ;;
                        esac
                        done

                        # --- Checks ---
                        if ! command -v pnpm >/dev/null 2>&1; then
                          echo "pnpm not found in PATH"; exit 1
                          fi

                          PNPM_VER="$(pnpm -v)"
                          # version_ge A B -> returns true if A >= B
                          version_ge() { printf '%s\n%s\n' "$2" "$1" | sort -C -V; }
                          if ! version_ge "$PNPM_VER" "$PNPM_MIN"; then
                            echo "Found pnpm $PNPM_VER, need >= $PNPM_MIN"; exit 1
                            fi

                            ROOT="$(pwd)"

                            # --- Optional: quiet funding messages ---
                            if $QUIET_FUND; then
                              if ! grep -q '^fund=' .npmrc 2>/dev/null; then
                                  printf '\nfund=false\n' >> .npmrc || true
                                    fi
                                    fi

                                    # --- Clean installs (optional lock reset) ---
                                    if ! $KEEP_LOCK; then
                                      rm -f pnpm-lock.yaml
                                      fi

                                      # Remove node_modules (root and workspace packages/*)
                                      if command -v pnpm >/dev/null 2>&1; then
                                        pnpm dlx rimraf "node_modules" "packages/*/node_modules" 2>/dev/null || true
                                        fi
                                        pnpm store prune || true

                                        # --- Update to latest / conservative ---
                                        UPDATE_FLAGS=()
                                        if [ -f "pnpm-workspace.yaml" ]; then
                                          UPDATE_FLAGS+=("-r")
                                          fi
                                          if $CONSERVATIVE; then
                                            # Range-respecting (stays within your ^/~ ranges)
                                              pnpm up "${UPDATE_FLAGS[@]}"
                                              else
                                                # Latest published, updates package.json ranges
                                                  pnpm up "${UPDATE_FLAGS[@]}" -L latest
                                                  fi

                                                  # --- Deduplicate and reinstall fresh ---
                                                  if [ -f "pnpm-workspace.yaml" ]; then
                                                    pnpm dedupe -r || true
                                                    else
                                                      pnpm dedupe || true
                                                      fi

                                                      pnpm install --force

                                                      # --- Optional audit ---
                                                      if $RUN_AUDIT; then
                                                        pnpm audit --prod || true
                                                        fi

                                                        # --- Build/test if scripts exist (best-effort) ---
                                                        HAS_SCRIPTS="$(pnpm -s run || true)"
                                                        if echo "$HAS_SCRIPTS" | grep -qE '(^|\s)(build)(\s|:)'; then
                                                          pnpm -r build || true
                                                          fi
                                                          if echo "$HAS_SCRIPTS" | grep -qE '(^|\s)(test)(\s|:)'; then
                                                            pnpm -r test || true
                                                            fi

                                                            echo
                                                            echo "✅ Dependency refresh complete on CURRENT BRANCH."
                                                            echo "   pnpm: $PNPM_VER"
                                                            echo "   Options: keep-lock=$KEEP_LOCK, conservative=$CONSERVATIVE, audit=$RUN_AUDIT, quiet-fund=$QUIET_FUND"
