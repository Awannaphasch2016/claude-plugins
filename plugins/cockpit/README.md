# cockpit

Where am I, what will this turn cost, and what is my context made of.

| piece | register | what it shows |
|---|---|---|
| SessionStart hook | — | `[where]` · `[family]` (2 hops up, 2 down, siblings, worktrees) · `[clean]/[dirty]` · `[worktrees]`. Emits `systemMessage` so it reaches the **user**, not only the agent. Stands down when the project ships its own SessionStart hook |
| statusline line 1 | — | session · checkout · **the branch family as one structure**: the FULL lineage with `★` as the pivot — left of it is ancestry, right is descendants — a shared stem printed once then folded to `·`, `⑂` on any branch with its own worktree, and `⇄` siblings at the end. Nothing is elided under 8 segments, deliberately: a long line is the smell. Falls back to the recorded-parent spine where the repo has neither `scripts/family.sh` nor `scripts/subtree.sh` |
| statusline lines 2–4 | alarm | context + `↑k/turn` · session/week limits with countdowns · **runway** (`%/active-h · ⛽fuel-h · lands ~N%` + verdict) |
| lines 5–6 `lab` · `ctx` | instrument | dim, no colour, no verdict: `areas · old · dup · tool · files` and the liveness strip `░░░░░░░▓██` |
| line 7 `prefix` | alarm, conditional | `❄ idle Nm (lease expired) — next turn likely rebuilds ~Xk` — the free moment to compact or clear |
| `/cockpit:felt rot\|tangled\|fine` | — | one timestamped mark in `felt.log` — the ground truth a dial needs to earn its colour |
| `/cockpit:explain` | — | the cost mechanism: why a turn was expensive, what to cut, whether to clear or compact. Holds the derivation; reads prices from the bundled `claude-api` reference rather than copying them |
| `/cockpit:report [days]` | — | per-session shape, daily trend, marks vs dials |

## Install

```
claude plugin marketplace add <this repo>
claude plugin install cockpit@anak
```
then, once — a plugin cannot set `statusLine` for you:
```
/cockpit:install-statusline
```

## The rule the two registers encode

A dial on the **instrument** register is a reading; a line on the **alarm** register is a claim.
A candidate is promoted only when `/felt` marks show it elevated before ≥3 `rot`/`tangled` and
quiet before ≥3 `fine`. `metrics.md` (in the data dir) is the ledger; the fresh:cache ratio is its
first demoted entry, with the reason. Colour is a claim — never on a candidate.

## Behaviour
The hook stands down when the project's `.claude/settings.json` declares its own `hooks.SessionStart` — otherwise both would fire and every block would print twice. Without `jq` the hook falls back to plain stdout, which reaches the agent but **not** the user's screen. The statusline takes effect on the next session after `/cockpit:install-statusline`.

## Needs
`bash`, `jq`, `python3`, `git`. The `[family]` block needs the repo's own `scripts/subtree.sh`
(Karant); elsewhere the hook prints the recorded-parent spine instead.
