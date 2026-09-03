# Noctalia v5 Adaptation Notes

**Date**: 2026-08-13
**Environment**: Ubuntu 24.04.4 LTS · niri 26.04 · laptop built-in display 2880×1800 + one or two external 2560×1440 monitors

---

## 1. Background and Goals

- **Noctalia**: native C++/Wayland, no Qt/Gtk dependencies, aims to be a first-class niri citizen, and provides bar / launcher / notifications / lock screen / clipboard / wallpaper / tray in one piece.

Noctalia serves as the desktop shell under niri, replacing waybar/fuzzel/dunst/swayidle/swaylock/cliphist/polkit.

---

## 2. Key Problems and Solutions (all battle-tested)

### 1. Build requires wireplumber-0.5 ❌ → patched down to 0.4 ✅
- Noctalia v5 needs the `wireplumber-0.5` headers at build time; Ubuntu 24.04 only ships `wireplumber-0.4`.
- **Fix**: point `meson.build` at `wireplumber-0.4`; 3 API differences in `wireplumber_mixer.cpp` (`wp_core_new` takes one fewer argument, `wp_core_load_component` became synchronous, `_finish` variants removed).

### 2. Missing `stb_image_resize2.h` ❌ → vendored into the repo ✅
- 24.04's `libstb-dev` lacks this newer header; the meson configure step fails.
- **Fix**: vendor the single header from stb v2.18 into `~/src/noctalia/stb/` and point the meson check at it.

### 3. `<print>` requires GCC 14 ❌ → install `g++-14` ✅
- The default gcc-13 lacks `<print>` (C++23).
- **Fix**: `apt install g++-14` — it installs versioned commands only and does **not** take over the default gcc-13, so nothing else on the system is affected.

### 4. Requires sdbus-c++ v2 ❌ → built from source into an isolated prefix ✅
- Noctalia uses the sdbus-c++ **v2** API (296 call sites); 24.04 only has v1.4.0.
- **Fix**: build sdbus-c++ **v2.3.1** from source into the isolated prefix `~/workspaces/window_mananger_ui/noctalia-deps` (soname `.so.2`, so it doesn't clash with the system v1 `.so.1`). Noctalia links to it via RPATH; no other program on the system is affected.

### 5. `wl_proxy_get_display` needs libwayland ≥ 1.23 ❌ → patched down to a single call site ✅
- 24.04's libwayland is 1.22 and lacks this API. In the entire tree, only `virtual_keyboard_service.cpp:95` uses it.
- **Fix**: give `VirtualKeyboardService` a `wl_display*` member passed in by `bind()` and call `wl_display_flush(m_display)` directly — behaviorally equivalent. **The first version had a bug caught during review** (`cleanup()` was nulling `m_display`); fixed and re-reviewed.

### 6. niri spawn couldn't find `noctalia` ❌ → add PATH via `environment {}` ✅
- **Root cause**: the niri process inherits PATH from the login manager, which does **not** include `~/.local/bin`, so `spawn "noctalia"` failed silently (all keybinds appeared dead).
- **Fix**: add `environment { PATH "..." }` at the top of `config.kdl` to include `~/.local/bin`. Root cause was pinned down through systematic debugging.

### 7. waybar reappeared after reboot ❌ → masked the systemd service ✅
- **Root cause**: `/usr/lib/systemd/user/waybar.service` is enabled by distro presets with `WantedBy=graphical-session.target`, so it starts with every graphical session, bypassing niri's config.
- **Fix**: `systemctl --user mask waybar.service` (creates a symlink to /dev/null, fully blocking autostart; reversible). **No impact on GNOME** (GNOME doesn't use waybar).

### 8. "Disconnected Network" notification at login ❌ → disabled nm-applet autostart ✅
- **Root cause**: `nm-applet` (NetworkManager tray) autostarts via `/etc/xdg/autostart/nm-applet.desktop`; the network isn't ready the instant you log in, so it fires a spurious notification. **It does not come from Noctalia.**
- **Fix**: user-level override at `~/.config/autostart/nm-applet.desktop` (`Hidden=true`) to disable its autostart. GNOME ships its own network indicator and doesn't need nm-applet, so **no impact on GNOME**.

---

## 3. Final Configuration Inventory

### niri —— `~/.config/niri/config.kdl`
- `environment { PATH }`: added `~/.local/bin` so spawn can find noctalia
- Three outputs:
  - `eDP-1` (built-in 2880×1800) → scale 1.75
  - `DP-1` (USB-C external 2560×1440) → scale 1
  - `DP-2` (dock HDMI external 2560×1440) → scale 1
- spawn-at-startup: only `noctalia` (absolute path) + dbus environment refresh
- Keybinds: `Mod+Space`/`Mod+D` → Noctalia launcher; `Super+Alt+L` → Noctalia lock screen
- Kept from before: rounded corners, shadows, animations, prefer-no-csd, gaps 10

### Noctalia —— `~/.config/noctalia/config.toml`
- Theme: `builtin = "Noctalia"` (default palette — user's choice to keep)
- bar: thickness 44, widget_spacing 10, scale 1.3 (larger icons)

### Isolated toolchain (no system pollution)
- `~/workspaces/window_mananger_ui/noctalia-deps/`: isolated sdbus-c++ v2.3.1 install (headers + libs + pkg-config)
- `~/.local/bin/noctalia`: build artifact (27 MB)
- `~/workspaces/window_mananger_ui/noctalia`: source + patches

### System-level overrides (on record)
- `systemctl --user mask waybar.service` → waybar never autostarts
- `~/.config/autostart/nm-applet.desktop` (`Hidden=true`) → nm-applet doesn't autostart
- See `docs/autostart-overrides.md` for details

---

## 4. Updating to Future Upstream Versions

The compatibility patches in the source repo (`~/workspaces/window_mananger_ui/noctalia`) are committed on the local branch **`ubuntu-24.04`** (based on upstream `713e6ca`; contains all wireplumber-0.4 / libwayland-1.22 / vendored-stb changes plus `update.sh`).

Updating is a single command:

```bash
cd ~/workspaces/window_mananger_ui/noctalia && ./update.sh
```

What it does: `git fetch` → rebase the patches onto `origin/main` (resolve conflicts one by one) → fresh meson setup (g++-14 + sdbus-c++ v2 from `~/workspaces/window_mananger_ui/noctalia-deps` + RPATH) → build → install to `~/.local/bin/noctalia`.
Restart noctalia (or log out and back in) for changes to take effect.

Notes:
- Ubuntu 24.04 will not upgrade to wireplumber-0.5 / libwayland-1.23; these patches are **needed long-term** and must be carried through every rebase.
- Rebase conflict hotspots: `src/pipewire/wireplumber_mixer.cpp` (0.5→0.4 API) and `src/wayland/virtual_keyboard_service.*` (avoiding `wl_proxy_get_display`).

---
