#!/usr/bin/env bash
# SessionStart hook — tell the session where it is before it does anything.
#
# WHERE THE OUTPUT GOES, and it is two different places (docs: code.claude.com/docs/en/hooks):
#   plain stdout on SessionStart  → CLAUDE's context. The user sees only a collapsed
#                                   "SessionStart:… hook success" line, expandable with ctrl+o.
#   JSON field `systemMessage`    → shown to the USER in the terminal.
# So this hook emits JSON carrying BOTH: additionalContext for the agent, systemMessage for
# the human. Printing to stdout alone is why the [family] block was invisible on screen for
# a whole afternoon while the agent could see it perfectly. Measured 2026-08-21.
set -uo pipefail
. "$(dirname "$0")/lib.sh"
input=$(cat 2>/dev/null || true)
# The transcript path arrives ONLY here, on hook stdin. Skills run later in plain shell
# and never see it, so persist it the one documented way: CLAUDE_ENV_FILE (SessionStart
# only). /cockpit:felt reads $COCKPIT_TRANSCRIPT to give each mark its join key.
txp=$(printf '%s' "$input" | jq -r '.transcript_path // empty' 2>/dev/null)
[ -n "${CLAUDE_ENV_FILE:-}" ] && [ -n "$txp" ] && printf 'export COCKPIT_TRANSCRIPT=%q\n' "$txp" >> "$CLAUDE_ENV_FILE"

OUT=""
say(){ OUT="$OUT$*"$'\n'; }   # collect; emitted once at the end, to both surfaces
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null); [ -z "$cwd" ] && cwd=$PWD
git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1 || { printf '{"systemMessage":"[where] %s — not a git repository"}\n' "$cwd"; exit 0; }
root=$(git -C "$cwd" rev-parse --show-toplevel)
branch=$(git -C "$cwd" branch --show-current); [ -z "$branch" ] && branch="detached @ $(git -C "$cwd" rev-parse --short HEAD)"
# If the PROJECT registers its own SessionStart hook, stay silent. Both would run and
# print every block twice; the project's copy is the authority on project-specific rules.
if [ -f "$root/.claude/settings.json" ] && command -v jq >/dev/null 2>&1 \
   && jq -e '.hooks.SessionStart' "$root/.claude/settings.json" >/dev/null 2>&1; then exit 0; fi
case "$root" in
  */.claude/worktrees/*) name="${root##*/.claude/worktrees/}"; where="worktree ⑂ $name";;
  *) where="MAIN CHECKOUT";;
esac
ab=$(git -C "$cwd" rev-list --left-right --count "@{upstream}...HEAD" 2>/dev/null | awk '{printf "behind %s · ahead %s", $1, $2}')
mod=$(git -C "$cwd" status --porcelain --untracked-files=no | wc -l | tr -d ' ')
unt=$(git -C "$cwd" status --porcelain --untracked-files=all | grep -c '^??' || true)
say "[where] $where · branch $branch${ab:+ · $ab} · $root"
# [family]: a fixed window around this branch — 2 hops up, 2 down, every sibling,
# worktree per branch, "+N above" when the chain is deeper than the rule. Rendered by
# the repo's own script so the rule lives with the repo; older repos get the spine.
if [ -x "$root/scripts/subtree.sh" ] && [ -n "$branch" ] && [ "${branch#detached}" = "$branch" ]; then
  fam=$(cd "$root" && timeout 6 scripts/subtree.sh "$branch" --window 2 --hook 2>/dev/null) || fam="[family] subtree.sh failed — run: npm run subtree"
  say "$fam"
else
  path=$("$COCKPIT_ROOT/scripts/lineage-path.sh" "$cwd" "$branch" 2>/dev/null)
  if [ -n "$path" ] && [ "$path" != "$branch" ]; then
    parent=$(git -C "$cwd" config --get "branch.$branch.parent" 2>/dev/null || true)
    say "[lineage] $path · merges from/into: ${parent:-(none recorded)}"
  else
    say "[lineage] no recorded parent for $branch — record one: git config branch.$branch.parent <parent>"
  fi
fi
if [ "$mod" != 0 ]; then
  say "[dirty] $mod tracked file(s) modified (first 5):"
  say "$(git -C "$cwd" status --porcelain --untracked-files=no | head -5 | sed 's/^/        /')"
  say "        These may belong to ANOTHER session sharing this checkout. Never blanket-stash; move by path."
else
  say "[clean] no tracked changes${unt:+ · $unt untracked}"
fi
say "[worktrees]"
while read -r p h b; do
  mark=" "; [ "$p" = "$root" ] && mark="▶"
  say "$(printf '  %s %-62s %s %s' "$mark" "$p" "$h" "$b")"
done < <(git -C "$cwd" worktree list)

# Emit once, to BOTH surfaces: systemMessage reaches the human, additionalContext the agent.
# jq builds it so a branch name with a quote in it cannot break the JSON.
if command -v jq >/dev/null 2>&1; then
  jq -nc --arg t "$OUT" '{systemMessage:$t, hookSpecificOutput:{hookEventName:"SessionStart", additionalContext:$t}}'
else
  printf '%s' "$OUT"   # no jq: fall back to plain stdout, agent-only
fi
