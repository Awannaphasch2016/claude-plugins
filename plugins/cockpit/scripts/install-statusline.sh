#!/usr/bin/env bash
# The ONE thing a plugin cannot do for itself: statusLine is a user-level setting
# (docs: settings-reference — user scope only). This writes the single key into
# ~/.claude/settings.json, pointing at THIS install's absolute path, and backs the
# file up first. Idempotent: re-running after a plugin update re-points the path.
set -euo pipefail
. "$(dirname "$0")/lib.sh" || true
S="$HOME/.claude/settings.json"; [ -f "$S" ] || echo '{}' > "$S"
bak="$S.bak-$(date +%Y%m%d-%H%M%S)"; cp "$S" "$bak"; echo "backup: $bak"
cmd="$COCKPIT_ROOT/scripts/statusline.sh"
tmp=$(mktemp); jq --arg c "$cmd" '.statusLine = {type:"command", command:$c, padding:0}' "$S" > "$tmp" && mv "$tmp" "$S"
echo "statusLine → $cmd"
echo "(restart Claude Code, or it takes effect on the next session)"
