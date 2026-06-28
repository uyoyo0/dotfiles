# CLI Tools Cheatsheet

> Access anytime with: `cheat`

---

## bat 

```bash
bat file.py              # view file with syntax highlighting + line numbers
bat -n file.py           # line numbers only (no decoration)
bat -A file.txt          # show non-printing chars (tabs, spaces)
bat --paging=never *.md  # no pager, just print
```

---

## eza 

```bash
ls                       # list with icons (aliased from eza)
ll                       # long listing with git status + icons
lt                       # tree view 2 levels deep
eza --tree --level=3     # tree view 3 levels deep
eza -la --sort=modified  # sort by modification time
eza -la --sort=size      # sort by size
eza -la --git-ignore     # hide .gitignore'd files
```

---

## fd 

```bash
fd pattern               # find files matching pattern (case-insensitive)
fd -e py                 # find by extension (.py files)
fd -t d                  # find directories only
fd -t f                  # find files only
fd -H pattern            # include hidden files
fd --exclude .git pat    # exclude directory
fd -e js -x bat {}       # find + run command on each result
```

---

## fzf 

```bash
# In the shell
Ctrl+R                   # fuzzy search command history
Ctrl+T                   # fuzzy insert file path
Alt+C                    # fuzzy cd into directory

# Piping
cat file | fzf           # fuzzy filter stdin
ls | fzf                 # pick a file
git branch | fzf         # pick a branch

# Preview
fzf --preview 'bat {}'   # preview with bat
fd -t f | fzf --preview 'bat --color=always {}'
```

---

## ripgrep (rg) 

```bash
rg pattern               # search in current dir recursively
rg pattern src/          # search in specific directory
rg -t py pattern         # search only Python files
rg -l pattern            # list files with matches (no content)
rg -c pattern            # count matches per file
rg -i pattern            # case insensitive
rg -v pattern            # invert match
rg -n pattern            # show line numbers (default)
rg "func.*Error"         # supports regex
rg --hidden pattern      # include hidden files
rg -g "*.ts" pattern     # glob filter

# With fzf (live grep)
rg --color=always -n "" | fzf --ansi
```

---

## git 

```bash
git init                 # new repo
git clone URL            # clone repo
git status               # show changes
git add -p               # interactively stage hunks
git commit -m "msg"      # commit
git log --oneline        # compact history
git log --oneline --graph --all  # branch graph
git diff                 # unstaged changes
git diff --staged        # staged changes
git stash                # save dirty state
git stash pop            # restore stash
git branch -a            # list all branches
git switch -c name       # create + switch branch
git rebase main          # rebase onto main
git cherry-pick SHA      # apply a commit
```

---

## gh 

```bash
gh auth login            # authenticate
gh repo create           # create a new repo
gh repo clone owner/repo # clone a repo

# Pull Requests
gh pr create             # create PR interactively
gh pr list               # list open PRs
gh pr view               # view current PR
gh pr checkout NUMBER    # checkout a PR locally
gh pr merge              # merge current PR

# Issues
gh issue create          # create issue
gh issue list            # list issues
gh issue view NUMBER     # view an issue

# Workflows / CI
gh run list              # list recent CI runs
gh run view              # view latest run
gh run watch             # watch a run live
```

---

## jq 

```bash
cat file.json | jq '.'          # pretty-print JSON
jq '.key' file.json             # extract a key
jq '.items[]' file.json         # iterate array
jq '.items[] | .name' file.json # extract field from each item
jq 'length' file.json           # length of array/object
jq 'keys' file.json             # list keys of object
jq 'select(.age > 30)' f.json   # filter
jq '{name, age}' file.json      # pick fields
jq -r '.name' file.json         # raw output (no quotes)
jq -c '.' file.json             # compact (one line)
curl URL | jq '.data[]'         # pipe from curl
```

---

## tmux 

> Prefix key is `Ctrl+a` (configured in dotfiles)

```bash
tmux                     # new session
tmux new -s name         # new named session
tmux ls                  # list sessions
tmux attach -t name      # attach to session
tmux kill-session -t name

# Inside tmux (Prefix = Ctrl+a)
Prefix c                 # new window
Prefix n / p             # next / previous window
Prefix NUMBER            # jump to window by number
Prefix ,                 # rename window
Prefix |                 # split vertical
Prefix -                 # split horizontal
Prefix h/j/k/l           # navigate panes (vim keys)
Prefix z                 # zoom pane (toggle fullscreen)
Prefix d                 # detach session
Prefix [                 # enter scroll/copy mode (q to exit)
Prefix r                 # reload config
```

---

## neovim 

> Leader key is `<Space>`

```bash
nvim file.py             # open file
nvim .                   # open current directory
```

**File finding**
| Key | Action |
|-----|--------|
| `<leader>ff` | Find files (Telescope) |
| `<leader>fg` | Live grep (search content) |
| `<leader>fb` | Switch buffers |
| `<leader>fr` | Recent files |
| `<leader>/` | Search in current file |

**Navigation**
| Key | Action |
|-----|--------|
| `Ctrl+h/j/k/l` | Move between splits |
| `Shift+h / Shift+l` | Previous / next buffer |
| `[d / ]d` | Previous / next diagnostic |

**Editing**
| Key | Action |
|-----|--------|
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `<leader>\|` | Split vertical |
| `<leader>-` | Split horizontal |
| `gc` (visual) | Toggle comment |
| `Alt+j/k` | Move line/selection up/down |
| `> / <` (visual) | Indent (stays in visual) |

**Plugin management**
```
:Lazy          # open plugin manager
:TSUpdate      # update treesitter parsers
:checkhealth   # diagnose issues
```

---

## htop: process viewer

```bash
htop                     # open interactive process viewer

# Inside htop
F2                       # settings
F3                       # search process
F4                       # filter
F5                       # tree view
F6                       # sort
F9                       # kill process
u                        # filter by user
/                        # search
q                        # quit
```

---

## tree 

```bash
tree                     # full tree (can be overwhelming)
tree -L 2                # 2 levels deep
tree -L 2 -a             # include hidden files
tree -I "node_modules"   # exclude pattern
tree -I "node_modules|.git|dist"  # exclude multiple
tree -d                  # directories only
tree -f                  # full path prefix
```

---

## wget 

```bash
wget URL                         # download file
wget -O filename URL             # save with custom name
wget -q URL                      # quiet (no output)
wget -c URL                      # resume interrupted download
wget -r -l 2 URL                 # recursive download, 2 levels
wget --user-agent="..." URL      # custom user agent
```

---

## Quick Recipes

```bash
# Find and preview files
fd -t f | fzf --preview 'bat --color=always {}'

# Search code and jump to result
rg -l "pattern" | fzf --preview 'rg -n "pattern" {}'

# Pretty-print a JSON API response
curl -s URL | jq '.'

# Watch a file for changes and display with bat
fswatch file.py | xargs -I{} bat {}

# Kill a process by name
ps aux | grep name | awk '{print $2}' | xargs kill

# Find largest files
fd -t f | xargs du -sh | sort -rh | head -20
```
