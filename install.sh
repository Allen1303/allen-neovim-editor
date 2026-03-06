#!/usr/bin/env bash
# ============================================================================
# install.sh — Allen's Neovim PDE installer (macOS)
# Repo: https://github.com/Allen1303/allen-neovim-editor.git
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/Allen1303/allen-neovim-editor/main/install.sh | bash
#   — or —
#   ./install.sh
#
# What it does:
#   1. Checks macOS + Neovim >= 0.10
#   2. Installs missing Homebrew dependencies
#   3. Backs up any existing Neovim config/state/cache
#   4. Clones the config into ~/.config/nvim
#   5. Installs global npm tools (live-server, tsx, ts-node)
#   6. Launches Neovim headlessly to trigger lazy.nvim + plugin install
# ============================================================================

set -euo pipefail

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { echo -e "${BLUE}[info]${NC}  $*"; }
success() { echo -e "${GREEN}[ok]${NC}    $*"; }
warn()    { echo -e "${YELLOW}[warn]${NC}  $*"; }
error()   { echo -e "${RED}[error]${NC} $*"; exit 1; }
section() { echo -e "\n${BOLD}── $* ──────────────────────────────────────────${NC}"; }

REPO_URL="https://github.com/Allen1303/allen-neovim-editor.git"
NVIM_CONFIG="$HOME/.config/nvim"
BACKUP_SUFFIX="bak.$(date +%Y%m%d_%H%M%S)"

# ── 1. Platform check ─────────────────────────────────────────────────────────
section "Platform"
if [[ "$(uname)" != "Darwin" ]]; then
    error "This installer is macOS only."
fi
success "macOS detected"

# ── 2. Homebrew ───────────────────────────────────────────────────────────────
section "Homebrew"
if ! command -v brew &>/dev/null; then
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    success "Homebrew already installed"
fi

# ── 3. Dependencies ───────────────────────────────────────────────────────────
section "Dependencies"

# FIX: replaced declare -A (bash 4+ only) with a function — macOS ships bash 3.2
brew_install_if_missing() {
    local pkg="$1"
    local bin="${2:-$1}"
    if ! command -v "$bin" &>/dev/null; then
        info "Installing $pkg..."
        brew install "$pkg"
        success "$pkg installed"
    else
        success "$pkg already installed"
    fi
}

brew_install_if_missing "neovim"  "nvim"
brew_install_if_missing "git"     "git"
brew_install_if_missing "ripgrep" "rg"
brew_install_if_missing "fd"      "fd"
brew_install_if_missing "node"    "node"
brew_install_if_missing "make"    "make"

# Nerd Font
if ls ~/Library/Fonts/JetBrainsMonoNerdFont* &>/dev/null 2>&1 || \
   ls /Library/Fonts/JetBrainsMonoNerdFont* &>/dev/null 2>&1; then
    success "JetBrainsMono Nerd Font already installed"
else
    info "Installing JetBrainsMono Nerd Font..."
    brew install --cask font-jetbrains-mono-nerd-font
    success "JetBrainsMono Nerd Font installed"
fi

# ── 4. Neovim version check ───────────────────────────────────────────────────
section "Neovim version"
NVIM_VERSION=$(nvim --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
NVIM_MINOR=$(echo "$NVIM_VERSION" | cut -d. -f2)

if [[ "$NVIM_MINOR" -lt 10 ]]; then
    warn "Neovim $NVIM_VERSION detected — this config targets >= 0.10"
    info "Upgrading Neovim via Homebrew..."
    brew upgrade neovim || brew install neovim
fi
success "Neovim $(nvim --version | head -1)"

# ── 5. Backup existing config ─────────────────────────────────────────────────
section "Backup"

backup_if_exists() {
    local path="$1"
    local label="$2"
    if [[ -e "$path" ]]; then
        local dest="${path}.${BACKUP_SUFFIX}"
        mv "$path" "$dest"
        warn "Backed up $label → $dest"
    fi
}

backup_if_exists "$NVIM_CONFIG"                 "~/.config/nvim"
backup_if_exists "$HOME/.local/share/nvim"      "~/.local/share/nvim"
backup_if_exists "$HOME/.local/state/nvim"      "~/.local/state/nvim"
backup_if_exists "$HOME/.cache/nvim"            "~/.cache/nvim"

success "Backup complete (suffix: .$BACKUP_SUFFIX)"

# ── 6. Clone config ───────────────────────────────────────────────────────────
section "Clone config"
info "Cloning from $REPO_URL..."
git clone "$REPO_URL" "$NVIM_CONFIG"
success "Config cloned to $NVIM_CONFIG"

# ── 7. Global npm tools ───────────────────────────────────────────────────────
section "npm tools"

npm_install_if_missing() {
    local pkg="$1"
    local bin="${2:-$1}"
    if ! command -v "$bin" &>/dev/null; then
        info "Installing $pkg globally..."
        npm install -g "$pkg"
        success "$pkg installed"
    else
        success "$pkg already installed"
    fi
}

npm_install_if_missing "live-server"
npm_install_if_missing "typescript" "tsc"
npm_install_if_missing "ts-node"
npm_install_if_missing "tsx"

# ── 8. Headless plugin install ────────────────────────────────────────────────
section "Plugin install"
info "Installing plugins headlessly via lazy.nvim (takes ~1-2 min)..."
nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
success "Plugins installed"

# ── 9. Done ───────────────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}================================================${NC}"
echo -e "${GREEN}${BOLD}  Allen's Neovim PDE — ready to use! 🎉        ${NC}"
echo -e "${GREEN}${BOLD}================================================${NC}"
echo ""
echo -e "  Config : ${BLUE}$NVIM_CONFIG${NC}"
echo -e "  Backup : ${YELLOW}*.${BACKUP_SUFFIX}${NC} (safe to delete once verified)"
echo ""
echo -e "  Run ${BOLD}nvim${NC} to launch."
echo -e "  Mason will auto-install LSP servers on first open."
echo ""
echo -e "  ${YELLOW}Tip:${NC} If icons look broken, set your terminal"
echo -e "       font to ${BOLD}JetBrainsMono Nerd Font${NC}."
echo ""

