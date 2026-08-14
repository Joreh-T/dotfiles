#!/usr/bin/env bash
# Auto-switch built-in laptop panel (eDP-1) based on EXTERNAL monitors.
#
# Rule (vendor-based, verified by EDID ASCII name):
#   - AOC (Q27G2S) or SKYDATA (F27B40Q) connected  → turn built-in eDP-1 OFF
#   - Redmi (Xiaomi, "Redmi 27 NQ") connected       → KEEP built-in ON (works together)
#   - No external connected                          → turn built-in eDP-1 ON
#
# We identify each external by reading its EDID ASCII name (strings), which is
# more reliable than the niri output name (niri caches EDID-derived names and
# can show a stale name right after hotplug) or the connector port (Redmi may
# share a port with AOC).
#
# Uses POLLING of /sys/class/drm/*/status every 2s. (udevadm monitor piped to
# while-read is block-buffered and drops events; don't use it.)
# Started by niri's spawn-at-startup.
set -uo pipefail

BUILTIN="eDP-1"
NIRI_BIN="$(command -v niri || echo /usr/bin/niri)"
POLL_SECONDS="${POLL_SECONDS:-2}"

# External monitors that TRIGGER turning the built-in off (AOC / SKYDATA).
# Redmi is intentionally NOT here — it keeps the built-in panel on.
TRIGGER_NAMES="AOC SKYDATA"

# Is the built-in output currently enabled in niri? ("Disabled" => off)
builtin_is_on() {
  "$NIRI_BIN" msg outputs 2>/dev/null | awk -v o="$BUILTIN" '
    $0 ~ "^Output .*\\(" o "\\)" { in_out = 1; next }
    in_out && /Disabled/ { print "no"; exit }
    in_out && /Current mode/ { print "yes"; exit }
  '
}

# Return 1 if any connected external matches a TRIGGER_NAMES vendor, else 0.
any_trigger_external() {
  for f in /sys/class/drm/card1-DP-*/status; do
    [[ -f "$f" ]] || continue
    [[ "$(cat "$f")" == "connected" ]] || continue
    local edid="${f%/status}/edid"
    [[ -f "$edid" ]] || continue
    local name
    name="$(strings "$edid" 2>/dev/null | grep -iE 'AOC|SKYDATA|Redmi' | head -1)"
    for trig in $TRIGGER_NAMES; do
      if [[ "$name" == *"$trig"* ]]; then
        echo 1
        return
      fi
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
