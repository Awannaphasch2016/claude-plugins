#!/usr/bin/env python3
"""ctxlab — the instrument register. Reads ONE transcript, prints two lines of dials.

DIM, NO COLOUR, SAME ORDER EVERY TURN. These are candidates: readings for the eye to
learn from, never claims. A colour or a verdict word would assert a meaning none of
them has earned yet (the fresh:cache ratio was dim-but-read-as-a-claim, and had to be
evicted). Promotion happens in $COCKPIT_DATA/metrics.md, by evidence, and moves a dial UP
a line into the alarm register.

Liveness = "did I touch anything from this segment in the last 20 turns" — a file
re-read, or its path appearing in later text. That is what YOU engaged with, not what
the MODEL used; a dim segment can still be informing answers silently. Read the strip
as "what I have stopped engaging with", a hint not a verdict.

Usage: ctxlab.py <transcript.jsonl>   → line1: lab dials · line2: liveness strip
Cached on transcript size, so it computes once per turn, not per render.
"""
import json, sys, os, re, hashlib
from collections import Counter, defaultdict

tx = sys.argv[1] if len(sys.argv) > 1 else ""
if not tx or not os.path.isfile(tx): sys.exit(0)
st = os.stat(tx); key = f"{st.st_size}-{int(st.st_mtime)}"
data = os.environ.get("CLAUDE_PLUGIN_DATA") or os.path.expanduser("~/.claude/cockpit")
os.makedirs(data, exist_ok=True)
cache = f"{data}/ctxlab.{hashlib.md5(tx.encode()).hexdigest()[:8]}"
try:
    k, body = open(cache).read().split("\n", 1)
    if k == key: print(body, end=""); sys.exit(0)
except Exception: pass

turns = []          # per assistant message: dict(tokens_added, ctx, files_read, text)
seen = set(); cur_files = []; cur_text = []; tool_chars = 0; read_chars = Counter(); reads = Counter()
last_tool_file = None
for line in open(tx, errors="ignore"):
    try: d = json.loads(line)
    except Exception: continue
    m = d.get("message") or {}
    c = m.get("content")
    if isinstance(c, list):
        for b in c:
            if not isinstance(b, dict): continue
            t = b.get("type")
            if t == "tool_use":
                p = (b.get("input") or {}).get("file_path")
                if p: cur_files.append(p); reads[p] += 1; last_tool_file = p
            elif t == "tool_result":
                s = len(str(b.get("content") or "")); tool_chars += s
                if last_tool_file: read_chars[last_tool_file] += s; last_tool_file = None
            elif t == "text":
                cur_text.append(b.get("text") or "")
    elif isinstance(c, str):
        cur_text.append(c)
    u = m.get("usage")
    if u and m.get("id") and m["id"] not in seen:
        seen.add(m["id"])
        added = (u.get("input_tokens", 0) + u.get("output_tokens", 0) + u.get("cache_creation_input_tokens", 0))
        turns.append({"added": added, "ctx": u.get("cache_read_input_tokens", 0) + added,
                      "files": list(cur_files), "text": " ".join(cur_text)})
        cur_files = []; cur_text = []

n = len(turns)
if n < 5: sys.exit(0)
ctx = turns[-1]["ctx"] or 1

# --- lab dials ---------------------------------------------------------------
old_tok = sum(t["added"] for t in turns[:-50]) if n > 50 else 0
old_pct = 100 * old_tok / max(1, sum(t["added"] for t in turns))
dup_tok = sum(read_chars[p] * (reads[p] - 1) / reads[p] for p in reads if reads[p] > 1) / 4
tool_pct = 100 * (tool_chars / 4) / ctx
def area(p):
    q = p.split("/"); return "/".join(q[:4]) if len(q) > 4 else p
recent_reads = [p for t in turns[-40:] for p in t["files"]]
areas = len(set(area(p) for p in recent_reads))
lab = f"lab     areas {areas} · old {old_pct:.0f}% · dup {100*dup_tok/ctx:.1f}% · tool {tool_pct:.0f}% · files {len(reads)} · turns {n}"

# --- liveness strip ------------------------------------------------------------
# 10 segments by cumulative tokens added, oldest left. A segment is LIVE if any file
# first read in it is touched (re-read, or path mentioned) in the last 20 turns.
total = sum(t["added"] for t in turns) or 1
recent_text = " ".join(t["text"] for t in turns[-20:]) + " " + " ".join(" ".join(t["files"]) for t in turns[-20:])
seg_files = defaultdict(set); seg_tok = [0]*10; first_seen = {}
acc = 0
for i, t in enumerate(turns):
    seg = min(9, int(10 * acc / total)); acc += t["added"]; seg_tok[seg] += t["added"]
    for p in t["files"]:
        if p not in first_seen: first_seen[p] = seg; seg_files[seg].add(p)
glyph = []
for s in range(10):
    fs = seg_files[s]
    if not fs and seg_tok[s] == 0: glyph.append("·"); continue
    hits = sum(1 for p in fs if p in recent_text or os.path.basename(p) in recent_text)
    if s >= 8: glyph.append("█")                 # the most recent fifth is live by definition
    elif fs and hits / len(fs) >= 0.5: glyph.append("▓")
    elif hits: glyph.append("▒")
    else: glyph.append("░")
live_pct = 100 * sum(seg_tok[s] for s in range(10) if glyph[s] in "█▓") / total
strip = f"ctx     {''.join(glyph)}  {ctx//1000}k · live {live_pct:.0f}% · old→new"

out = lab + "\n" + strip + "\n"
open(cache, "w").write(key + "\n" + out); print(out, end="")
