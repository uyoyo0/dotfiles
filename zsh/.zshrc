export ZSH="$HOME/.oh-my-zsh"

# No theme since Starship handles the prompt
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Resolve dotfiles location by following the ~/.zshrc symlink
export DOTFILES="$(dirname "$(dirname "$(readlink ~/.zshrc)")")"

# Starship prompt
eval "$(starship init zsh)"

# FZF shell integration (installed via brew)
eval "$(fzf --zsh)"

# --- Aliases ---
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --group-directories-first --git"
alias lt="eza --tree --icons --level=2"
alias cat="bat"
alias grep="rg"
alias find="fd"
alias vim="nvim"
alias vi="nvim"
alias cheat="bat $DOTFILES/TOOLS.md"

# --- FZF settings (Tokyo Night) ---
export FZF_DEFAULT_COMMAND="fd --type file --hidden --follow --exclude .git"
export FZF_DEFAULT_OPTS="
  --height 40% --layout=reverse --border rounded
  --color=bg+:#1e2030,bg:#1a1b26,spinner:#7dcfff,hl:#f7768e
  --color=fg:#c0caf5,header:#f7768e,info:#7aa2f7,pointer:#7aa2f7
  --color=marker:#7aa2f7,fg+:#c0caf5,prompt:#7aa2f7,hl+:#f7768e"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# --- History ---
HISTSIZE=10000
SAVEHIST=10000
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE

# --- Editor ---
export EDITOR="nvim"
export VISUAL="nvim"

# --- PATH additions ---
export PATH="$HOME/.local/bin:$PATH"
