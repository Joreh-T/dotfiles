# Usage Instructions

Clone the current repository into the `"$HOME\dotfiles"` directory.

Dotfiles will automatically update once a day via my nvim's [autocmd](./nvim/lua/config/autocmds.lua).

## Setup

* Use `setup.ps1` to apply the configuration in a Windows environment.

* Use `setup.sh` to apply the configuration in a Linux environment.

## Zsh (Linux)

`setup.sh` symlinks `zsh/.zshrc`, `zsh/.p10k.zsh` and `zsh/.zshenv` into `$HOME`.

The shared `~/.zshrc` sources a per-host file by hostname at the end:

```zsh
[[ -f "$HOME/dotfiles/zsh/hosts/$HOST.zsh" ]] && source "$HOME/dotfiles/zsh/hosts/$HOST.zsh"
```

So machine-specific bits (e.g. `dk-run`, host-only `PATH`) live in `zsh/hosts/<hostname>.zsh`. Add one file per PC. Machines with no matching file simply skip it.

## Niri + Noctalia (Linux)

`setup.sh` symlinks `niri/` → `~/.config/niri` and `noctalia/` → `~/.config/noctalia`.

- `niri/config.kdl` — niri window manager config (3-monitor layout, keybinds, autostart of Noctalia).
- `niri/scripts/` — helper scripts (e.g. `power-menu.sh`).
- `niri/docs/` — notes (apt packages, autostart overrides).
- `noctalia/config.toml` — Noctalia desktop shell config (bar, theme, wallpaper, launcher).

Note: `~/.config/niri` also contains runtime-only artifacts (`build/`, `.superpowers/`) that are NOT tracked here. The auto-display script lives at `~/.local/bin/niri-autodisplay.sh` (outside dotfiles, since it's a user binary not a dotfile).
