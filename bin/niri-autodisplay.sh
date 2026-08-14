#!/usr/bin/env bash
# Auto-switch built-in laptop panel (eDP-1) based on EXTERNAL monitors.
#
# Rule (vendor-based, verified by EDID PNP code + ASCII name):
#   - AOC (Q27G2S) or SKYDATA (F27B40Q) connected  → turn built-in eDP-1 OFF
#   - Redmi (Xiaomi, "Redmi 27 NQ") connected       → KEEP built-in ON (works together)
#   - No external connected                          → turn built-in eDP-1 ON
#
# Identify each external by the EDID PNP manufacturer code (bytes 8-9), with the
# EDID ASCII name as fallback. The ASCII name alone is unreliable — e.g. the
# SKYDATA F27B40Q's EDID only contains "F27B40Q", not "SKYDATA". We avoid the
# niri output name (can be stale right after hotplug) and the connector port
# (Redmi shares a port with AOC).
#
# Uses POLLING of /sys/class/drm/*/status every 2s. (udevadm monitor piped to
# while-read is block-buffered and drops events; don't use it.)
# Started by niri's spawn-at-startup.
set -uo pipefail

BUILTIN="eDP-1"
NIRI_BIN="$(command -v niri || echo /usr/bin/niri)"
POLL_SECONDS="${POLL_SECONDS:-2}"

# External monitors that TRIGGER turning the built-in off (AOC / SKYDATA).
# Matched by EDID PNP code (primary) and ASCII name (fallback).
# Redmi (PNP "XMI") is intentionally NOT here — it keeps the built-in panel on.
TRIGGER_PNPS="AOC SKY"
TRIGGER_NAMES="AOC SKYDATA"

# Is the built-in output currently enabled in niri? ("Disabled" => off)
builtin_is_on() {
  "$NIRI_BIN" msg outputs 2>/dev/null | awk -v o="$BUILTIN" '
    $0 ~ "^Output .*\\(" o "\\)" { in_out = 1; next }
    in_out && /Disabled/ { print "no"; exit }
    in_out && /Current mode/ { print "yes"; exit }
  '
}

# Decode the 3-letter EDID manufacturer (PNP) ID from a raw edid file.
edid_pnp() {
  python3 -c '
import sys
d = open(sys.argv[1], "rb").read()
if len(d) < 10:
    sys.exit(1)
b8, b9 = d[8], d[9]
c1 = chr(0x41 + ((b8 >> 2) & 0x1f) - 1)
c2 = chr(0x41 + (((b8 & 0x03) << 3) | ((b9 >> 5) & 0x07)) - 1)
c3 = chr(0x41 + (b9 & 0x1f) - 1)
print(c1 + c2 + c3)
' "$1" 2>/dev/null
}

# Return 1 if any connected external is a trigger monitor, else 0.
# Trigger = PNP code in $TRIGGER_PNPS, or EDID ASCII name matching $TRIGGER_NAMES.
any_trigger_external() {
  for f in /sys/class/drm/card1-DP-*/status; do
    [[ -f "$f" ]] || continue
    [[ "$(cat "$f")" == "connected" ]] || continue
    local edid="${f%/status}/edid"
    [[ -f "$edid" ]] || continue
    local pnp name
    pnp="$(edid_pnp "$edid")"
    name="$(strings "$edid" 2>/dev/null | grep -iE 'AOC|SKYDATA|Redmi' | head -1)"
    for trig in $TRIGGER_PNPS; do
      [[ "$pnp" == "$trig" ]] && { echo 1; return; }
    done
    for trig in $TRIGGER_NAMES; do
      [[ "$name" == *"$trig"* ]] && { echo 1; return; }
    done
  done
  echo 0
}

apply_rule() {
  local ext on_state
  ext="$(any_trigger_external)"
  on_state="$(builtin_is_on)"

  if (( ext > 0 )); then
    # A trigger external present → ensure built-in is off.
    if [[ "$on_state" == "yes" ]]; then
      "$NIRI_BIN" msg output "$BUILTIN" off >/dev/null 2>&1 || true
      echo "$(date +%T) trigger-external → eDP-1 OFF" >> /tmp/niri-autodisplay.log
    fi
  else
    # No trigger external (Redmi only, or nothing) → ensure built-in is on.
    if [[ "$on_state" == "no" ]]; then
      "$NIRI_BIN" msg output "$BUILTIN" on >/dev/null 2>&1 || true
      echo "$(date +%T) no-trigger-external → eDP-1 ON" >> /tmp/niri-autodisplay.log
    fi
  fi
}

# Apply immediately at startup.
apply_rule

# Poll connector status.
while true; do
  sleep "$POLL_SECONDS"
  apply_rule
done
