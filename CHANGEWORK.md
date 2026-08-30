# Plugin changes ride the Changework rail

A plugin change = branch `change/<id>` + `changes/<id>/contract.md`
(intent · delta · admission+verdicts · landing · continuation). No PR
layer. Landing is the sponsor running ONE deterministic command:

    scripts/land.sh <id>

which gates (contract complete · touched plugins version-bumped · no
secret in diff · SKILL frontmatter parses), prints the house SUMMARY
line, and only on all-green merges --no-ff, tags `<plugin>-v<version>`,
and pushes. Refusal merges nothing. The cache updates only via the normal
plugin-update pull — never by hand (the cache is derived, read-only by
convention).

Machine note: marketplace clones are single-branch by default — set
`remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'` once, or the
rail cannot see change branches. `land.sh --check <id>` runs the gates
without landing (the rehearsal mode). `LAND_PUSH_URL` may carry an
authenticated push URL for automated landings.
