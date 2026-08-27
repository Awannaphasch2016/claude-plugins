#!/usr/bin/env bash
# PreCompact hook — the /felt moment, caught BEFORE the box.
#
# The lap is freshest in the DRIVER's memory at the instant they choose to
# compact; the register's post-box line (ctxlab) is the backstop for the ~5
# turns after. This hook is the nudge before: one systemMessage, never a
# blocking dialog — /felt is the driver's ground truth and holding /compact
# hostage to a question is the hacky version this deliberately is not.
#
# trigger=manual → the box is a CHOICE: ask rain or planned.
# trigger=auto   → the tank ran dry mid-corner — no choice was made, which is
#                  itself a signal (weather, not strategy); word it that way.
#
# Output: JSON systemMessage (reaches the USER; plain stdout would reach only
# the transcript). Same lesson as session-start.sh, measured 2026-08-21.
set -uo pipefail
input=$(cat 2>/dev/null || true)
trig=$(printf '%s' "$input" | jq -r '.trigger // "manual"' 2>/dev/null)
tx=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)

n="?"; lap="?"
if [ -n "$tx" ] && [ -f "$tx" ]; then
  # Rough lap stats for the nudge: assistant records since the last boundary.
  # Approximate on purpose (sidechains included) — this is a greeting, not a
  # dial; the register owns the honest numbers.
  n=$(tac "$tx" 2>/dev/null | awk '/"subtype":"compact_boundary"/{exit} /"type":"assistant"/{c++} END{print c+0}')
  b=$(grep -c '"subtype":"compact_boundary"' "$tx" 2>/dev/null || echo 0)
  lap=$((b+1))
fi

if [ "$trig" = "auto" ]; then
  msg="🏁 lap ${lap} auto-boxed at ~${n}t — the tank ran dry, no choice was made. When you surface: /cockpit:felt rot|tangled|fine (an auto-box is weather, and weather is worth a mark)"
else
  msg="🏁 boxing lap ${lap} (~${n}t) — how did it feel? /cockpit:felt rot|tangled|fine — rain or planned?"
fi
jq -cn --arg m "$msg" '{systemMessage:$m}'
