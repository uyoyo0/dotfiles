export ZSH="$HOME/.oh-my-zsh"

# No theme since Starship handles the prompt
ZSH_THEME=""

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# Resolve the dotfiles root from this file's own path
export DOTFILES="${${(%):-%x}:A:h:h}"

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
alias reload="exec zsh"

# --- Helpers ---
home() { cd ~; }

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

# --- Machine-local overrides ---
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# iTerm2: show a background image while Claude Code is running
CLAUDE_BG_IMAGE="$HOME/.claude/claude-bg.png"
claude() {
  if [[ "$TERM_PROGRAM" == "iTerm.app" && -f "$CLAUDE_BG_IMAGE" ]]; then
    printf '\e]1337;SetBackgroundImageFile=%s\a' "$(printf '%s' "$CLAUDE_BG_IMAGE" | base64)"
    # `always` runs even if claude exits via SIGINT, which would otherwise abort the function
    {
      command claude "$@"
    } always {
      printf '\e]1337;SetBackgroundImageFile=\a'
      # iTerm's Claude Code workgroup exit trigger can re-apply the image after we clear it, so clear again shortly after
      ( sleep 0.5; printf '\e]1337;SetBackgroundImageFile=\a' > /dev/tty ) &!
    }
    return
  fi
  command claude "$@"
}
