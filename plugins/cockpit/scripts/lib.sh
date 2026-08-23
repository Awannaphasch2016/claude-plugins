#!/usr/bin/env bash
# Sourced by every cockpit script. Resolves two directories:
#   COCKPIT_ROOT — this plugin's install dir (scripts live here; replaced on update)
#   COCKPIT_DATA — the user's persistent state: felt.log, metrics.md, caches.
#                  CLAUDE_PLUGIN_DATA when the harness provides it, else ~/.claude/cockpit.
#                  Either survives a plugin update; neither is in the plugin tree.
COCKPIT_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
COCKPIT_DATA="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/cockpit}"
mkdir -p "$COCKPIT_DATA" 2>/dev/null && chmod 700 "$COCKPIT_DATA" 2>/dev/null || true
[ -f "$COCKPIT_DATA/metrics.md" ] || cp "$COCKPIT_ROOT/metrics.template.md" "$COCKPIT_DATA/metrics.md" 2>/dev/null
export COCKPIT_ROOT COCKPIT_DATA
