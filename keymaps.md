# Keymaps

## Shell (zsh)

| Keys                | Does                                      |
| ------------------- | ----------------------------------------- |
| `ctrl+r`            | Fuzzy search command history              |
| `ctrl+t`            | Fuzzy find a file and paste its path      |
| `alt+c`             | Fuzzy find a folder and cd into it        |
| `z foo`             | Jump to the most used folder matching foo |
| zi foo`            | Pick from matching folders in a list      |
| `→`                 | Accept the grey autosuggestion            |
| `tab`               | Completion menu (arrows to move)          |
| `ctrl+a` / `ctrl+e` | Start / end of line                       |
| `ctrl+w` / `ctrl+u` | Delete word / whole line                  |

## Tabs and splits (Ghostty keys, tmux underneath)

Ghostty always starts inside tmux, and its own `ctrl+shift+t` / `ctrl+shift+n` are unbound.

| Keys                          | Does                                 |
| ----------------------------- | ------------------------------------ |
| `cmd+t`                       | New tab                              |
| `cmd+w`                       | Close pane / tab                     |
| `cmd+1`-`9`                   | Go to tab                            |
| `cmd+shift+[` / `cmd+shift+]` | Previous / next tab                  |
| `cmd+d` / `cmd+shift+d`       | Split side by side / top and bottom  |
| `ctrl+h` `j` `k` `l`          | Move between panes (and nvim splits) |
| `alt+shift+h` `j` `k` `l` | Resize pane or nvim split (hold to repeat) |

## Ghostty

| Keys                        | Does                            |
| --------------------------- | ------------------------------- |
| `` cmd+` ``                 | Drop-down terminal from any app |
| `cmd+n`                     | New window                      |
| `cmd+=` / `cmd+-` / `cmd+0` | Font bigger / smaller / reset   |
| `cmd+enter`                 | Fullscreen                      |
| `cmd+shift+,`               | Reload config                   |
| `option+drag`               | Move the frameless window       |

## tmux (prefix is `ctrl+space`, press it then the key)

| Keys       | Does                                                                          |
| ---------- | ----------------------------------------------------------------------------- |
| `f`        | Jump to a project (opens or switches session)                                 |
| `s`        | List sessions                                                                 |
| `c`        | New tab                                                                       |
| `H` / `L`  | Previous / next tab (like LazyVim buffers)                                    |
| `,`        | Rename tab                                                                    |
| `\|` / `-` | Split side by side / top and bottom (like LazyVim `<leader>\|` / `<leader>-`) |
| `z`        | Zoom pane to full size and back                                               |
| `x`        | Close pane                                                                    |
| `ctrl+l`   | Clear screen                                                                  |
| `d`        | Detach (session keeps running, `tmux a` to return)                            |
| `[`        | Scroll mode: `v` select, `y` copy, `q` quit                                   |
| `r`        | Reload config                                                                 |

## Neovim (LazyVim, leader is `space`; press `space` and wait for the full menu)

| Keys                                 | Does                                                         |
| ------------------------------------ | ------------------------------------------------------------ |
| `jk`                                 | Leave insert mode                                            |
| `ctrl+j` (insert mode)               | Open completion menu (`ctrl+space` is the tmux prefix)       |
| `ctrl+h` `j` `k` `l`                 | Move between splits and tmux panes                           |
| `space space` / `space /`            | Find file / search text in project                           |
| `gd` / `gr` / `K`                    | Go to definition / references / hover docs                   |
| `space ca` / `space cr`              | Code action (imports, fixes) / rename                        |
| `space cf`                           | Format file (no format on save)                              |
| `space db`                           | Toggle breakpoint                                            |
| `space dc`                           | Start debugger / continue (Java: pick the main class to run) |
| `space di` / `space dO` / `space do` | Step into / over / out                                       |
| `space du`                           | Debugger panels on / off                                     |
| `space dt`                           | Stop debugger                                                |
| `space tt` / `space tr`              | Java: run tests in file / nearest test                       |
| `space cm`                           | Mason (installed language tools)                             |
| `ctrl+/`                             | Terminal on / off (floating, project root)                   |
| `space D`                            | Database UI (connections from `~/.config/zsh/.env`)          |
