---
name: explain
description: This skill should be used when the user asks why a turn was expensive, what a cache read costs, why context grew, what "fresh" or "cache_read" mean, whether to clear or compact, whether to delegate a read to a subagent, or any question about how Claude Code token cost is calculated. It holds the derivation; the prices live in the claude-api reference.
disable-model-invocation: true
---

# explain — the cost mechanism

**Do not restate prices from memory.** The multipliers, TTLs, per-model minimums and
breakpoint limits drift when Anthropic changes them, and they are maintained in the
bundled `claude-api` skill's `shared/prompt-caching.md`. Read that file for any number.
What follows is the *derivation*, which does not drift — it is what makes those numbers
mean something.

## The algorithm, in one sentence

A request renders in a fixed order — `tools` → `system` → `messages` — is hashed at each
`cache_control` breakpoint, matched against the **longest byte-identical prefix currently
alive**, which is served from stored state while everything after it is processed and
written. An entry lives on a short TTL from its last write.

Two facts follow, and almost every question reduces to one of them.

## Fact 1 — context is a running total

`cache_read(N) = cache_read(N−1) + cache_new(N−1)`.

Your message, every tool result, and **the model's own output** all join the context and
are re-sent on every later turn. So `cache_read` per turn *is* the size of the
conversation — the same number seen from the billing side. A file read into the main
context is paid once at full price and then carried on every subsequent turn.

- **Delegating a large read to a subagent** costs the main thread only the returned
  summary. Break-even is roughly **4 remaining turns**; past that, delegate.
- Under budget pressure, cut **turns and context**, not subagents. Fan-out costs more
  *fresh* and usually less *total*.

## Fact 2 — the ladder has two rungs

While the prefix is alive a turn costs ~1× whatever the context size. The instant it is
not, the next turn costs ~10×, because the whole prefix is re-written instead of read.
There is no middle.

A prefix dies exactly two ways:

- **Time** — no request within the TTL. Kills everything, indiscriminately. An idle gap,
  a tool call that itself runs longer than the TTL, or working in another session while
  this one's lease ages.
- **Change** — a byte or parameter differs. Kills **from that position rightward**, which
  is the whole of the tier table: message content kills only `messages` (a normal turn,
  hence cheap); a system-prompt edit kills `system` and `messages`; a tool-set change or a
  **model switch** kills all three — and a model switch is the only case with *no* cheap
  read at all, since the stored state is that model's own computation.

**The consequence worth knowing:** because the key is the exact prefix, appending is free
and pruning the stale middle is charged. That is the real link between caching and context
rot — an incentive, not a corruption. Caching never changes what the model reads.

**And therefore:** a cold prefix is the *free* moment to compact or clear. You are about to
re-pay for the whole context anyway; doing it while the prefix is warm throws away a live
cheap entry.

## What the numbers on screen mean

- `cache_read` — the conversation so far, served from stored state
- `cache_creation` — what is being written into the cache this turn
- `input_tokens` — the uncached remainder only; **total prompt = all three summed**
- `↑k/turn` (statusline) — how fast context is growing; cannot be flattered
- `live %` (statusline) — how much of the context you have touched recently. Low `live`
  with high `old` means carry the live part forward — compaction or a handoff, then clear.
  **Not** a bare clear, which drops the live part too.
- **fresh : cache ratio** — do not steer by it. It is `mean_context ÷ fresh_per_turn`
  algebraically, so it cannot separate "context grew" from "I read less", and the best
  ratios in this user's history were the heaviest sessions. It is in
  `/cockpit:report` as a trend, never as a gauge.

## Answering

Read the question, name which of the two facts it reduces to, and answer from there. When
a price is needed, read it from `claude-api`'s `shared/prompt-caching.md` rather than
recalling it. When the question is "what did MY session cost", that is `/cockpit:report`.

**Unverified, and say so if it matters to the answer:** whether cache reads meter against
the weekly rate limit the way fresh tokens do. Nothing published says. Every cost figure
here is price-weighted, which is not necessarily quota-weighted.
