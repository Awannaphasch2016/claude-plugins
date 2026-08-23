---
name: report
description: This skill should be used when the user says "/cockpit:report", "context report", "how heavy were my sessions", "show the cache trend", or asks what the lab dials did before a /felt mark. It runs the retrospective context report over recent transcripts.
disable-model-invocation: true
---

Run `"${CLAUDE_PLUGIN_ROOT}/scripts/context-report.sh" [days]` (default 7) in one Bash
call and show its output verbatim.

Then, only if `${COCKPIT_DATA:-$HOME/.claude/cockpit}/felt.log` exists and has entries, add
one short section: for each mark, the `lab` dials from the 20 turns before it (compute them
with `"${CLAUDE_PLUGIN_ROOT}/scripts/ctxlab.py" <transcript>` on the transcript the mark
names). Draw no conclusion the numbers do not support — the point is to let the user see
whether a dial was elevated before a `rot` and quiet before a `fine`. That is the
promotion evidence described in `${COCKPIT_DATA:-$HOME/.claude/cockpit}/metrics.md`.
