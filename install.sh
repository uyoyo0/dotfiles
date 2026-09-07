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
BREW_PKGS="neovim git gh fzf ripgrep fd bat eza htop jq tmux tree wget starship tree-sitter-cli"
if ! brew install $BREW_PKGS; then
  warn "One or more brew formulae failed to install"
fi
brew install --cask font-fira-code-nerd-font || warn "Nerd Font cask failed to install"
MISSING=""
for t in $BREW_PKGS; do
  case "$t" in neovim) b=nvim ;; tree-sitter-cli) b=tree-sitter ;; *) b="$t" ;; esac
  command -v "$b" >/dev/null 2>&1 || MISSING="$MISSING $b"
done
if [ -n "$MISSING" ]; then
  warn "Not on PATH after install:$MISSING"
else
  ok "Brew tools ready"
fi

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

# -n stops ln from following an existing symlink-to-directory and creating
# the new link *inside* it. Without it, a second run makes $src/$(basename $dst).
symlink() {
  local src="$1" dst="$2"
  if [ -e "$dst" ] && [ ! -L "$dst" ]; then
    local bak="$dst.bak.$(date +%Y%m%d%H%M%S)"
    warn "Backing up existing $dst -> $bak"
    mv "$dst" "$bak"
  fi
  ln -sfn "$src" "$dst"
  ok "$dst -> $src"
}

symlink "$DOTFILES/nvim"              "$HOME/.config/nvim"
symlink "$DOTFILES/zsh/.zshrc"       "$HOME/.zshrc"
symlink "$DOTFILES/starship/starship.toml" "$HOME/.config/starship.toml"
symlink "$DOTFILES/tmux/.tmux.conf"  "$HOME/.tmux.conf"

step "Machine-local config"
if [ -e "$HOME/.zshrc.local" ]; then
  ok "~/.zshrc.local already exists, leaving it alone"
else
  cp "$DOTFILES/zsh/zshrc.local.example" "$HOME/.zshrc.local"
  ok "Created ~/.zshrc.local from template"
  warn "Fill in host-specific paths there (it starts out as a no-op)"
fi

step "Git hooks"
# Filesystems without POSIX permissions (ExFAT/FAT) drop the exec bit, which
# would make git silently skip the hook. Restore it, and never rely on it below.
chmod +x "$DOTFILES"/scripts/*.sh "$DOTFILES"/githooks/* 2>/dev/null || true
if [ -d "$DOTFILES/githooks" ]; then
  git -C "$DOTFILES" config core.hooksPath githooks
  ok "pre-commit secret scan enabled"
else
  warn "No githooks/ directory, skipping"
fi

step "Claude Code settings"
APPLY="$DOTFILES/scripts/apply-claude-policy.sh"
if ! command -v jq >/dev/null 2>&1; then warn "jq missing, Claude policy cannot be applied"; fi
if [ ! -f "$APPLY" ]; then
  warn "No scripts/apply-claude-policy.sh, skipping"
elif ! { : < /dev/tty; } 2>/dev/null; then
  warn "No terminal available, skipping Claude policy"
  ok "Run scripts/apply-claude-policy.sh by hand to apply it"
else
  # Read from /dev/tty, not stdin, so the prompt still works when the script
  # is piped (curl ... | bash), where stdin is the script text itself.
  reply=""
  read -r -p "Apply Claude Code policy to ~/.claude/settings.json? [y/N] " reply < /dev/tty || true
  case "$reply" in
    [Yy]*) bash "$APPLY" ;;
    *) ok "Skipped Claude policy" ;;
  esac
fi

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
