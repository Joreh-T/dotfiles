#!/usr/bin/env sh
# fuzzel-driven power menu (Catppuccin rice).
entry=$(printf 'lock\nlogout\nreboot\nshutdown\n' | fuzzel --dmenu --prompt='Power: ' -l 4) || exit 0
case "$entry" in
  lock)     swaylock ;;
  logout)   niri msg action quit --skip-confirmation ;;
  reboot)   systemctl reboot ;;
  shutdown) systemctl poweroff ;;
esac
