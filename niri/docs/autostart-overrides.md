# XDG Autostart Overrides (Disabling System Autostart That Conflicts with Noctalia)

- `~/.config/autostart/nm-applet.desktop` → `Hidden=true` — disables NetworkManager
  Applet's login notification (the "Disconnected Network" toast was fired by nm-applet
  at login when the network wasn't ready yet). Noctalia provides the network tray instead.
- (systemd) `waybar.service` → **masked** via `systemctl --user mask waybar.service`
  (creates `~/.config/systemd/user/waybar.service -> /dev/null`) — waybar was enabled
  by the distro preset and auto-started in every graphical session, overriding niri's
  intent for Noctalia to be the sole bar. Re-enable with
  `systemctl --user unmask waybar.service`.
- `~/.config/autostart/im-launch.desktop` → `Hidden=true` — disables im-config's
  im-launch autostart. The `GTK_IM_MODULE=fcitx` it exports conflicts with fcitx5
  under Wayland (fcitx5's official recommendation is for GTK to use the Wayland IM
  frontend). fcitx5 is instead started directly by niri's `spawn-at-startup`, and
  `~/.xinputrc` is set to `run_im none` to cut the profile chain.
  See `greetd-greeter.md` for details.

## Other System-Level Autostart / Display-Manager Overrides

- `getty@tty1.service` → **masked** (greetd and getty fighting over VT1 causes a
  login loop; see pitfall 1 in `greetd-greeter.md`)
- Full deployment record for greeter/greetd: `greetd-greeter.md`

- `~/.local/bin/niri-autodisplay.sh` (autostarted by niri) — udev hotplug listener:
  if any external monitor (DP-1/DP-2) is connected → `niri msg output eDP-1 off`;
  all disconnected → `on`. Added so the laptop panel automatically turns off when
  docked to an external monitor.

  FIXED (2026-08-14): switched to POLLING `/sys/class/drm/*/status` every 2s.
  Root causes: (1) `udevadm monitor | while read` is block-buffered — hotplug
  events never reach the loop; (2) a LAST-state cache meant external toggles
  were never re-corrected. Now checks actual niri on/off state each poll.

  RULE UPDATE (2026-08-14): vendor-based identification. The script now reads each
  connected DP port's EDID ASCII name: AOC/SKYDATA → eDP-1 off; Redmi ("Redmi 27 NQ",
  XMI/Xiaomi) → eDP-1 stays ON (works together with the built-in panel). Redmi shares
  the DP-1 port with AOC (only one of them is connected at a time).
