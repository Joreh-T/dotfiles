# XDG autostart overrides (disable system autostart that conflicts with Noctalia)

- `~/.config/autostart/nm-applet.desktop` → `Hidden=true` — disables NetworkManager
  Applet's login notification ("Disconnected Network" was fired by nm-applet at login
  when the network wasn't ready yet). Noctalia provides the network tray instead.
  (systemd) `waybar.service` → `masked` via `systemctl --user mask waybar.service`
  (creates `~/.config/systemd/user/waybar.service -> /dev/null`) — waybar was enabled
  by the distro preset and auto-started in every graphical session, overriding niri's
  intent for Noctalia to be the sole bar. Re-enable with
  `systemctl --user unmask waybar.service`.

- `~/.config/autostart/im-launch.desktop` → `Hidden=true` — 禁用 im-config 的
  im-launch 自启。它导出的 `GTK_IM_MODULE=fcitx` 在 Wayland 下与 fcitx5 冲突
  (fcitx5 官方建议 GTK 走 Wayland IM 前端)。fcitx5 改由 niri `spawn-at-startup`
  直接拉起,`~/.xinputrc` 设为 `run_im none` 掐断 profile 链。详见 greetd-greeter.md。

## 其他系统级 autostart/DM 相关覆盖

- `getty@tty1.service` → **masked**(greetd 与 getty 抢 VT1 会导致登录死循环,
  详见 `greetd-greeter.md` 坑 1)
- greeter/greetd 部署全记录: `greetd-greeter.md`

- `~/.local/bin/niri-autodisplay.sh` (autostarted by niri) — udev hotplug listener:
  if any external (DP-1/DP-2) connected → `niri msg output eDP-1 off`; all disconnected → `on`.
  Added so the laptop panel auto-turns-off when docked to an external monitor.

  FIXED (2026-08-14): switched to POLLING /sys/class/drm/*/status every 2s.
  Root causes: (1) `udevadm monitor | while read` is block-buffered — hotplug
  events never reach the loop; (2) a LAST-state cache meant external toggles
  were never re-corrected. Now checks actual niri on/off state each poll.

  RULE UPDATE (2026-08-14): vendor-based identification. Script now reads each
  connected DP port's EDID ASCII name: AOC/SKYDATA → eDP-1 off; Redmi ("Redmi 27 NQ",
  XMI/Xiaomi) → eDP-1 stays ON (works together with built-in). Redmi shares the DP-1
  port with AOC (only one of them connected at a time).
