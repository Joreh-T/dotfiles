# greetd + noctalia-greeter Deployment Notes (2026-08-27)

A complete record of migrating from GDM3 to greetd + noctalia-greeter. System state + pitfall conclusions — read this first when rebuilding or troubleshooting.

## System Layout

| Component | Location | Notes |
|---|---|---|
| Greeter binary/libs/assets | `/opt/greeter-deps/` | mode 755, readable by the greetd user; contains the wlroots 0.20 toolchain (see below) |
| greetd config | `/etc/greetd/config.toml` | `command` points to `/opt/greeter-deps/bin/noctalia-greeter-session`, `user=_greetd` (Ubuntu packaging convention, uid 126) |
| Greeter state | `/var/lib/noctalia-greeter/` | greeter.toml + sync.toml; `noctalia msg greeter-sync` syncs wallpaper/palette |
| Switch script | `~/.local/bin/noctalia-greeter-switch` | `switch\|rollback\|status`; source lives in dotfiles/bin, linked by setup.sh |
| Source | `~/workspaces/window_mananger_ui/noctalia-greeter` | 2 local patches (meson.build stb include + session wrapper LD_LIBRARY_PATH), not yet committed on a branch |
| display-manager alias | `/etc/systemd/system/display-manager.service` | → greetd.service; rollback = point it back at gdm.service |
| **getty@tty1** | `systemctl mask getty@tty1.service` | **masked — do not restore!** See below |

## Key Pitfalls (by severity)

1. **getty@tty1 and greetd fight over the VT → login loop** (fixed, masked).
   Symptom: you enter your password, land on the desktop, and 10–30 s later you're bounced back to the greeter — forever.
   Mechanism: the greetd session occupies tty1 → getty@tty1 exits → systemd restarts getty → getty reclaims tty1 and sends SIGHUP to the session → logind concludes the session ended → greetd spawns a fresh greeter → loop.
   Ubuntu's GDM package handles this mutual exclusion itself; greetd does not.
   How we caught niri receiving SIGHUP: a logging wrapper (Exec pointing at a script that writes to /tmp).

2. **Under greetd you must use `niri-session`, not `niri --session`.**
   `/usr/share/wayland-sessions/niri.desktop` currently has `Exec=niri-session`.
   - `niri-session` goes through the `niri.service` user unit → the full graphical-session.target + xdg-desktop-autostart.target chain (portals, im-launch, etc. all depend on it).
   - `niri --session` only imports the environment; the targets never chain up (they RefuseManualStart — only unit dependencies can pull them in), so fcitx5/portals are all dead.
   - While debugging this we initially mis-blamed niri-session as the root cause of the loop; the real culprit was getty (see 1).

3. **IM variables (im-config) conflict with fcitx5 under Wayland** (fixed):
   - `~/.xinputrc` → `run_im none`: cuts the chain where im-config exports GTK_IM_MODULE (niri-session's login shell sources `/etc/profile.d/im-config_wayland.sh`).
   - `~/.config/autostart/im-launch.desktop` → `Hidden=true` (disables im-launch autostart).
   - niri `config.kdl`: `spawn-at-startup "fcitx5"` starts it directly; the environment block keeps only QT_IM_MODULE + XMODIFIERS (GTK goes through niri's native Wayland IM frontend — fcitx5's official recommendation).
   - After changing anything environment-variable shaped, run `systemctl --user unset-environment GTK_IM_MODULE ...` to clear leftovers from the user manager (it does not clean itself).

4. **Build toolchain** (Ubuntu 24.04 noble; no reference `update.sh` exists here, manual chain):
   the whole wlroots 0.20 wrap suite installed into `/opt/greeter-deps` (wayland 1.26.9 / libdrm 2.4.134 / libdisplay-info / libliftoff / pixman / xkbcommon); noble's meson 1.3.2 is too old → `~/.local/opt/meson-venv` (venv meson 1.12, symlinked as `~/.local/bin/meson`);
   stb headers hand-installed into `/opt/greeter-deps/include/stb/` + a meson.build patch; wlroots's indirect dependencies rely on the session wrapper's LD_LIBRARY_PATH (DT_RUNPATH doesn't propagate).
   See the `noctalia-daemon-debugging` memory note for details.

## Wallpaper Rotation Moved to a systemd Timer (2026-08-27)

Noctalia's built-in automation force-rotates once at shell startup (and excludes the current image), which caused the jarring "greeter shows X, desktop becomes Y after login". A systemd user timer now owns rotation:
- `dotfiles/systemd/user/wallpaper-rotate.{timer,service}` (symlinked by setup.sh): every 2 h on the hour runs `noctalia msg wallpaper-next` (alphabetical order), `Persistent=` catch-up, and fails quietly when the shell isn't running, waiting for the next cycle.
- `[wallpaper.automation] enabled = false` (the built-in path is fully off).
- Effect: wallpapers change because time has passed, not because the shell started; greeter and desktop always agree at the login boundary.

## Greeter Wallpaper Follows Rotation: Zero-Privilege Lightweight Scheme (2026-08-27)

No polkit changes, no copy chain from the official greeter-sync. The greeter's wallpaper path points directly at the originals in `~/Pictures/Wallpapers/`; when noctalia rotates the wallpaper, a hook rewrites just the `path` line in `/var/lib/noctalia-greeter/sync.toml` (surgically — every other byte is untouched), and the next greeter start naturally picks up the new image.

One-time ACL prerequisites (sudo):
- `setfacl -m u:_greetd:x /home/joreh /home/joreh/Pictures` (directory traversal)
- `setfacl -R -m u:_greetd:rX,d:u:_greetd:rX /home/joreh/Pictures/Wallpapers` (read the images + default ACL for new files)
- `setfacl -m u:joreh:rw /var/lib/noctalia-greeter/sync.toml` (the hook writes in place; the owner stays `_greetd` and the directory gets no write permission → atomic replacement is impossible, so it's a single in-place `open("w")` write)

Chain: noctalia `[hooks] wallpaper_changed = ~/.local/bin/greeter-wallpaper-follow` (same-named script in dotfiles/bin, linked by setup.sh) → env NOCTALIA_WALLPAPER_PATH/CONNECTOR → the script only accepts files inside `~/Pictures/Wallpapers` (path-domain validation) → updates the `path` under `[appearance.wallpaper]` + `[appearance.wallpapers.<connector>]` → idempotent (no write when unchanged). Log: `~/.cache/noctalia/greeter-follow.log`.

Notes:
- Only the wallpaper follows; palette/layout remain the last greeter-sync snapshot. To refresh, run `noctalia msg greeter-sync` once (it writes the path back to copy mode; the next rotation hook automatically takes over direct mode again — the two modes coexist consistently).
- `wallpaper_blur` in greeter.toml (background blur) is independent of the wallpaper source; the two stack.
- Rotation events fire per-display (eDP-1 and DP-1 each get one); the global `path` always follows the latest.

## Login Background Blur (2026-08-27, local feature)

The greeter fork's `ubuntu-24.04` branch (commit 51e2cb2) ported BlurCache/CachedLayer from the noctalia shell (the greeter previously had only the complete blur shader; its cache layer was a stub): the wallpaper texture is blurred once at load time into a ≤1024px FBO (2-pass separable gaussian), and the blurred texture is what gets displayed.
- Config key: `/var/lib/noctalia-greeter/greeter.toml`, `[appearance] wallpaper_blur` = 0.0..1.0 (compiled default 0.55, 0 = off); like `password_style` it is independent of the scheme source, and greeter-sync won't overwrite it.
- Rebuild: `cd ~/workspaces/window_mananger_ui/noctalia-greeter && ninja -C build-release`, then `sudo env PATH=$HOME/.local/opt/meson-venv/bin:$PATH meson install -C build-release` (`meson install` is mandatory — don't just copy the binary).
- Takes effect at: the greeter only starts at login, so log out / reboot to see it.

## Three Prerequisites for greeter-sync (wallpaper/palette sync to the login screen) (completed 2026-08-27)

1. noctalia only looks for `noctalia-greeter` and `noctalia-greeter-apply-appearance` in `/usr/bin` and `/usr/local/bin` (the daemon registers IPC at startup; otherwise `noctalia msg greeter-sync` reports "unknown command") → the /opt originals are symlinked into `/usr/local/bin`.
2. The polkit action must be installed: `/usr/share/polkit-1/actions/org.noctalia.greeter.apply-appearance.policy` (copied from `/opt/greeter-deps/share/polkit-1/actions/`; `exec.path` already points at the /opt original).
3. A polkit authentication agent must exist in the session, otherwise pkexec falls back to text authentication while the daemon has no tty → noctalia config `polkit_agent = true` (already set in dotfiles).

Verification: `noctalia msg greeter-sync` returns ok, the scheme in `/var/lib/noctalia-greeter/sync.toml` becomes "Synced", and `wallpaper-*.png` appears.

## Remaining Minor Issues

- The first greeter instance after boot occasionally crashes (greetd log: "greeter exited without creating a session"); greetd restarts it and everything is fine. Harmless — waiting on an upstream fix or the next round of debugging.
- The 2 local patches in the greeter source should be committed on an `ubuntu-24.04` branch, mirroring the noctalia fork pattern.
- amdgpu logs DMCUB errors at greeter start (PRIORITY=3, ~8 per greeter start, visible in the journal): wlroots 0.20 picks a non-scanout buffer modifier for renoir; everything works, it's pure noise.
  Note: cmdline `loglevel=3` alone is not enough — Ubuntu's `/etc/sysctl.d/10-console-messages.conf` raises `kernel.printk` back to `4 4 1 7` about 0.5 s after boot. Added `/etc/sysctl.d/99-console-loglevel-3.conf` (`kernel.printk=3 4 1 7`) to suppress it; the real fix belongs upstream in wlroots/greeter modifier negotiation.
- niri-session (`/usr/local/bin`, manually installed) was changed to an import-environment that "only imports variables that are already set": bare invocation is deprecated by systemd (stderr warning to the tty), but a fixed list would make systemctl print "$VAR not set, ignoring" to tty1 for WAYLAND_DISPLAY/DISPLAY, which don't exist yet — those are imported by niri's own session mode after startup and are necessarily empty at the niri-session stage. Now filtered with a for+eval loop.
  The original is backed up as `.bak` in the same directory. Preserve this patch when a niri upgrade reinstalls it.

## Rolling Back to GDM

```bash
noctalia-greeter-switch rollback   # or: sudo ln -sfn /lib/systemd/system/gdm.service /etc/systemd/system/display-manager.service && sudo reboot
```
GDM3 is not uninstalled, and keeping getty@tty1 masked doesn't affect GDM (GDM has its own mutual-exclusion mechanism).
