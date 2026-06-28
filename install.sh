#!/usr/bin/env bash
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RESET="\033[0m"

step() { echo -e "\n${BOLD}${BLUE}▶ $1${RESET}"; }
ok()   { echo -e "${GREEN}✓ $1${RESET}"; }
warn() { echo -e "${YELLOW}⚠ $1${RESET}"; }

step "Checking Homebrew"
if ! command -v brew &>/dev/null; then
  echo 'Install Homebrew first: /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  exit 1
fi
ok "Homebrew found"

step "Installing brew tools"
brew install neovim git gh fzf ripgrep fd bat eza htop jq tmux tree wget starship 2>/dev/null || true
brew install --cask font-fira-code-nerd-font 2>/dev/null || true
ok "Brew tools ready"

step "Installing oh-my-zsh"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ok "oh-my-zsh installed"
else
  ok "oh-my-zsh already present"
fi

step "Installing ZSH plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions \
    "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  ok "zsh-autosuggestions installed"
else
  ok "zsh-autosuggestions already present"
fi
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  ok "zsh-syntax-highlighting installed"
else
  ok "zsh-syntax-highlighting already present"
fi

step "Creating symlinks"
mkdir -p "$HOME/.config"

symlink() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    warn "Backing up existing $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi
  ln -sf "$src" "$dst"
  ok "$dst -> $src"
}

symlink "$DOTFILES/nvim"              "$HOME/.config/nvim"
symlink "$DOTFILES/zsh/.zshrc"       "$HOME/.zshrc"
symlink "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
symlink "$DOTFILES/tmux/.tmux.conf"  "$HOME/.tmux.conf"

step "Done!"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal (or run: source ~/.zshrc)"
echo "  2. Open nvim: lazy.nvim will auto-install plugins on first launch"
echo "  3. Import iTerm2 colors:"
echo "     Preferences -> Profiles -> Colors -> Color Presets -> Import"
echo "     pick: $DOTFILES/iterm2/TokyoNight.itermcolors"
echo "  4. Set iTerm2 font:"
echo "     Preferences -> Profiles -> Text -> Font -> FiraCode Nerd Font, 14pt"
echo "  5. Authenticate GitHub: gh auth login"
echo ""
