# dotfiles

Personal terminal setup. Tokyo Night color scheme throughout.

## What's included

| Config | Description |
|--------|-------------|
| `nvim/` | Neovim - lazy.nvim, Tokyo Night, Treesitter, Telescope, Lualine |
| `zsh/.zshrc` | Oh My Zsh + Starship prompt, aliases for bat/eza/fd/rg |
| `starship/starship.toml` | Starship prompt (Tokyo Night colors, git status, lang versions) |
| `tmux/.tmux.conf` | Prefix Ctrl+a, Tokyo Night status bar, vim pane nav |
| `iterm2/TokyoNight.itermcolors` | iTerm2 color preset |
| `TOOLS.md` | Cheatsheet for all CLI tools - run `cheat` to open |

## Setup on a new machine

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

The script installs all brew tools, oh-my-zsh, zsh plugins, Starship, and creates symlinks.

## Manual steps (one-time)

**iTerm2 colors**
Preferences -> Profiles -> Colors -> Color Presets -> Import -> `iterm2/TokyoNight.itermcolors`

**iTerm2 font**
Preferences -> Profiles -> Text -> Font -> `FiraCode Nerd Font`, 14pt

**GitHub auth**
```bash
gh auth login
```

## Key aliases

| Alias | Expands to |
|-------|-----------|
| `ls` | `eza --icons` |
| `ll` | `eza -la --icons --git` |
| `lt` | `eza --tree --icons --level=2` |
| `cat` | `bat` |
| `grep` | `rg` |
| `find` | `fd` |
| `vim` / `vi` | `nvim` |
| `cheat` | opens `TOOLS.md` from dotfiles |

## Neovim leader keys 

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Buffers |
| `<leader>fr` | Recent files |
| `<leader>w` | Save |
| `<leader>q` | Quit |
