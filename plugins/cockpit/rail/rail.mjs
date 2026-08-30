#!/usr/bin/env node
/*
  The plugin landing rail, REIMPLEMENTED ON THE KARANT DSL (sponsor's veto,
  2026-08-30: frequent updates + simple workflow = the right first dogfood).

  Layering per src/lib/dsl/core.ts: rail.line.json is the ORGANIZATION layer
  (which stations, where the decision sits, what judgment it asks, who may
  resolve). THIS file is the EXECUTION layer: it binds stations to shell
  steps and honors the stop. The line was validated through the real
  compile() at authoring (verdict in the Change contract); the two runtime
  invariants are revalidated here because this caller arrives as JSON.
*/
import { readFileSync } from "node:fs";
import { execSync } from "node:child_process";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";

const STATIONS = ["trigger","perceive","interpret","reconstruct","evaluate",
  "decide","plan","execute","verify","confirm","continue"]; // core.ts vocabulary, verbatim

const here = dirname(fileURLToPath(import.meta.url));
const LINE = JSON.parse(readFileSync(join(here, "rail.line.json"), "utf8"));

// core.ts's two measured invariants, revalidated for the JSON caller
const uses = LINE.stations.map(s => { const n = STATIONS.indexOf(s)+1;
  if (!n) throw new Error(`${LINE.id}: unknown station "${s}"`); return n; });
uses.forEach((u,i)=>{ if (i && u<=uses[i-1]) throw new Error(`${LINE.id}: stations must be strictly ascending`); });
for (const d of LINE.decisions) if (!LINE.stations.includes(d.at))
  throw new Error(`${LINE.id}: decision "${d.id}" at unwalked station "${d.at}"`);

const [,, ...argv] = process.argv;
const LAND = argv.includes("--land");
const ID = argv.filter(a=>!a.startsWith("--"))[0];
if (!ID) { console.error("usage: rail.mjs <change-id> [--land]"); process.exit(1); }
const BR = `change/${ID}`;
const sh = (c) => execSync(c, {encoding:"utf8", stdio:["ignore","pipe","pipe"]}).trim();
let P=0, F=0;
const pass=(m)=>{P++;console.log(`  ✓ ${m}`)}, fail=(m)=>{F++;console.log(`  ✗ ${m}`)};

const STEPS = {
  trigger() { console.log(`rail: line ${LINE.id} · change ${ID} · ${LAND?"LANDING":"walking to the stop"}`); },

  perceive() {
    sh("git fetch -q origin");
    sh(`git rev-parse -q --verify origin/${BR}`);
    sh("git checkout -q main"); sh("git pull -q origin main");
    try { sh(`git checkout -q ${BR}`); } catch { sh(`git checkout -qb ${BR} origin/${BR}`); }
    try { sh(`git merge -q --ff-only origin/${BR}`); } catch {}
  },

  verify() {
    const C = `changes/${ID}/contract.md`;
    let c=""; try { c = readFileSync(C,"utf8"); } catch {}
    (["## 1 · Intent","## 2 · Delta","## 3 · Admission","## 4 · Landing","## 5 · Continuation"]
      .every(s=>c.includes(s))) ? pass("contract present, five sections") : fail(`contract missing/incomplete (${C})`);

    const touched=[...new Set(sh("git diff --name-only main..HEAD -- 'plugins/*'").split("\n").filter(Boolean).map(p=>p.split("/")[1]))];
    if (!touched.length) fail("no plugin touched — nothing to release");
    for (const pl of touched) {
      const vj=`plugins/${pl}/.claude-plugin/plugin.json`;
      const now=JSON.parse(readFileSync(vj,"utf8")).version;
      let old="none"; try { old=JSON.parse(sh(`git show main:${vj}`)).version; } catch {}
      now!==old ? pass(`${pl} version bumped ${old} → ${now}`) : fail(`${pl} touched but version unchanged (${old})`);
    }

    const diff = sh("git diff main..HEAD").split("\n").filter(l=>l.startsWith("+")).join("\n");
    /(postgres(ql)?:\/\/[^:]+:[^@:{$][^@]*@)|password *= *'[0-9a-fA-F]{16,}'|(sbp_|sb_secret_|krnt_v1\.)[A-Za-z0-9]/.test(diff)
      ? fail("diff contains a plausible secret — parameterize it") : pass("no plausible secret in diff");

    const skills = sh("git diff --name-only main..HEAD -- 'plugins/*/skills/*/SKILL.md'").split("\n").filter(Boolean);
    let bad=0;
    for (const s of skills) { const t=readFileSync(s,"utf8").split("\n");
      if (t[0]!=="---" || !t.slice(1, t.indexOf("---",1)+1).some(l=>l.startsWith("name:"))) { bad++; console.log(`    bad frontmatter: ${s}`);} }
    bad ? fail("SKILL.md frontmatter broken") : pass("changed SKILL.md frontmatter parses");

    console.log(`SUMMARY land-gates ${P}/${P+F}${F?` · ${F} failed`:""}`);
    if (F) { console.log("REFUSED — fix and rerun. Nothing merged."); process.exit(1); }
    this.touched = touched;
  },

  confirm() {
    const d = LINE.decisions.find(x=>x.at==="confirm");
    const dp = `${LINE.id}.${d.id}`;
    if (!LAND) {
      console.log(`STOP · decision ${dp} · surface ${d.surface} · authority ${d.authority}`);
      console.log(`gates green, nothing merged. The word: rail.mjs ${ID} --land`);
      process.exit(0);
    }
    console.log(`decision ${dp} resolved: LAND (authority ${d.authority} — the invoker carries the sponsor's word)`);
  },

  continue() {
    sh("git checkout -q main");
    sh(`git merge --no-ff -q ${BR} -m "Land Change ${ID} (via rail.mjs on line ${LINE.id} — gates ${P}/${P})"`);
    for (const pl of STEPS.touched ?? []) {
      const v=JSON.parse(readFileSync(`plugins/${pl}/.claude-plugin/plugin.json`,"utf8")).version;
      sh(`git tag -f ${pl}-v${v}`);
    }
    sh(`git push -q ${process.env.LAND_PUSH_URL || "origin"} main --tags`);
    console.log(`LANDED: ${BR} → main`);
    console.log("next: 'claude plugin update' carries it to each machine's cache");
  },
};

for (const s of LINE.stations) STEPS[s].call(STEPS);
