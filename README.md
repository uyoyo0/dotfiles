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
| `zsh/zshrc.local.example` | Template for machine-specific shell config |
| `TOOLS.md` | Cheatsheet for all CLI tools - run `cheat` to open |

## Setup on a new machine

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/dotfiles
cd ~/dotfiles && bash install.sh
```

The script installs all brew tools, oh-my-zsh, zsh plugins, Starship, and creates symlinks.

## Machine-specific config

```bash
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"
```

`install.sh` creates `~/.zshrc.local` from `zsh/zshrc.local.example` if it
does not already exist, and never overwrites it after that.

## Manual steps

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

## Claude Code

Settings are split

| File | Tracked | Purpose |
|---|---|---|
| `claude/policy.json` | yes | Security rules applied on every machine |
| `claude/prefs.json` | yes | Theme, model, UI. Seeds a fresh machine only |
| `claude/policy.local.example.json` | yes | Template, lax machine |
| `claude/policy.strict.example.json` | yes | Template, sensitive machine |
| `~/.claude/policy.local.json` | no | This machine's own rules. Keep private paths here |

Apply with `scripts/apply-claude-policy.sh` (idempotent). Shared and local
arrays are unioned; the result replaces the arrays in `~/.claude/settings.json`,
so deleting a local rule removes it again. Preferences are never overwritten
after the first install.

Blacklisting a folder:

- `deny` blocks it outright, regardless of where the session was started.
- `ask` prompts every time, including in auto mode. Use this for folders you
  want reachable only when you say so.
- `sandbox.filesystem.denyRead` is the only layer enforced by the OS rather
  than the harness, and it requires `"sandbox": {"enabled": true}`.

A pre-commit hook (`githooks/pre-commit`, enabled via `core.hooksPath`) scans
staged `claude/*.json` for credential material. Bypass with `--no-verify`.

### Background image (optional)

In iTerm2, `claude` shows a background image while it runs and clears it on
exit. To turn it on, save an image to `~/.claude/claude-bg.png` (not tracked).
Without that file, `claude` runs normally. iTerm2 asks permission the first
time an image is set. To fade the image so text stays readable, use the
Blending slider in Preferences -> Profiles -> Window -> Background Image.
