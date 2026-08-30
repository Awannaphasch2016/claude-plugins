#!/usr/bin/env bash
# land.sh <change-id> — the DETERMINISTIC plugin landing rail (Changework).
# The sponsor's landing word IS running this script. It refuses loudly or
# lands completely; there is no third state. SUMMARY line per house style.
set -euo pipefail
ID="${1:?usage: land.sh <change-id>  (branch change/<change-id>)}"
BR="change/$ID"; P=0; F=0
say(){ echo "  $1"; }
pass(){ P=$((P+1)); say "✓ $1"; }
fail(){ F=$((F+1)); say "✗ $1"; }

git fetch -q origin
git rev-parse -q --verify "origin/$BR" >/dev/null || { echo "no branch origin/$BR"; exit 1; }
git checkout -q main && git pull -q origin main
git checkout -q "$BR" 2>/dev/null || git checkout -qb "$BR" "origin/$BR"
git merge -q --ff-only "origin/$BR" 2>/dev/null || true

# gate 1 · contract exists with the five required sections
C="changes/$ID/contract.md"
if [ -f "$C" ] && grep -q "## 1 · Intent" "$C" && grep -q "## 2 · Delta" "$C" \
   && grep -q "## 3 · Admission" "$C" && grep -q "## 4 · Landing" "$C" \
   && grep -q "## 5 · Continuation" "$C"; then pass "contract present, five sections"
else fail "contract missing or incomplete ($C)"; fi

# gate 2 · every touched plugin bumped its version vs main
TOUCHED=$(git diff --name-only main..HEAD -- 'plugins/*' | cut -d/ -f2 | sort -u)
for pl in $TOUCHED; do
  VJ="plugins/$pl/.claude-plugin/plugin.json"
  NEW=$(python3 -c "import json;print(json.load(open('$VJ'))['version'])")
  OLD=$(git show "main:$VJ" 2>/dev/null | python3 -c "import json,sys;print(json.load(sys.stdin)['version'])" 2>/dev/null || echo "none")
  [ "$NEW" != "$OLD" ] && pass "$pl version bumped $OLD → $NEW" || fail "$pl touched but version unchanged ($OLD)"
done
[ -z "$TOUCHED" ] && fail "no plugin touched — nothing to release"

# gate 3 · no plausible secret in the diff (hex/base64 blobs, conn strings with passwords)
if git diff main..HEAD | grep -E "^\+" | grep -qE "postgres(ql)?://[^:]+:[^@:{\$][^@]*@|password *= *'[0-9a-fA-F]{16,}'|(sbp_|sb_secret_|krnt_v1\.)[A-Za-z0-9]"; then
  fail "diff contains a plausible secret — parameterize it"
else pass "no plausible secret in diff"; fi

# gate 4 · every SKILL.md parses (frontmatter closes, name present)
BAD=0
while IFS= read -r s; do
  awk 'NR==1&&$0!="---"{exit 1} /^name:/{n=1} NR>1&&$0=="---"{if(!n)exit 1; exit 0}' "$s" || { BAD=1; say "  bad frontmatter: $s"; }
done < <(git diff --name-only main..HEAD -- 'plugins/*/skills/*/SKILL.md' | grep . || true)
[ "$BAD" = 0 ] && pass "changed SKILL.md frontmatter parses" || fail "SKILL.md frontmatter broken"

echo "SUMMARY land-gates $P/$((P+F))$( [ $F -gt 0 ] && echo " · $F failed")"
[ $F -gt 0 ] && { echo "REFUSED — fix and rerun. Nothing merged."; exit 1; }

# the landing, atomic: merge --no-ff, tag each touched plugin's version, push
git checkout -q main
git merge --no-ff -q "$BR" -m "Land Change $ID (via land.sh — gates $P/$P)"
for pl in $TOUCHED; do
  V=$(python3 -c "import json;print(json.load(open('plugins/$pl/.claude-plugin/plugin.json'))['version'])")
  git tag -f "$pl-v$V"
done
git push -q origin main --tags
echo "LANDED: $BR → main · tags: $(for pl in $TOUCHED; do python3 -c "import json;print('$pl-v'+json.load(open('plugins/$pl/.claude-plugin/plugin.json'))['version'])"; done | tr '\n' ' ')"
echo "next: 'claude plugin update' (or marketplace refresh) carries it to each machine's cache"
