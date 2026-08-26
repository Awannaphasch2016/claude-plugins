---
name: semantic-refactor
description: Change the repo's shared vocabulary without breaking it. Use when a term is being defined or renamed, when prose contradicts the glossary, when a borrowed word needs its tradition and departure stated, or when any work is about to introduce vocabulary the glossary does not hold.
---

# Semantic refactor

Refactoring, applied to vocabulary: the concepts stay, only their naming and
decomposition change. It carries more weight than the code kind because there
is **no compiler between the words and the behaviour** — the glossary is
loaded into sessions, so renaming a concept is closer to editing the program
than to tidying it.

**There is no oracle.** Nothing proves a renamed concept still means what it
meant. Two things stand in for the test suite, and both are stations below:
*verify* cross-checks the code, and *continue* records the diff.

## The contract — read first, stop if absent

`docs/agents/authoring.md` names this repo's glossary, ADR home, and records
home. **No contract file → stop and say to run `/authoring:setup-anak-skills`.**
Never guess the paths.

The rules live in the glossary's own header — the marker classes,
borrow-or-coin, altitude, constitutive-vs-current. **Read them each run**;
they are edited by this skill's own runs, so memory goes stale.

## Modes

- **define** — a concept has no term
- **rename** — a term exists and the wrong word is canonical
- **reconcile** — prose and the glossary disagree
- **audit** — a section is read for drift with no term in hand

Every mode walks every station. `rename` is the only one that reaches the sweep.

## The stations

Walk in order; skip none; say which you are at.

**1 · trigger** — say which mode, and what raised it. A term argued about in
conversation counts; so does a word in a diff.

**2 · perceive** — gather the raw three, and quote rather than summarise: the
passage as written, the glossary entry as written, and **what the code
actually does**. Grep the schema, the constants and the user-facing strings
for the word before forming any opinion. The glossary has been the outlier
before.

**3 · interpret** — name the concept in one sentence that mentions no word
for it. Then find every existing term that could already be it. A concept
that maps onto an entry already present is a collision, not a new term.

**4 · evaluate** — borrow or coin.
- Search the source fields first — the domains this repo's work actually
  draws on (its glossary header names them; organization theory, BPM,
  enterprise architecture and linguistics are common ones).
- Borrowing means **quoting the source's own definition**. A borrow you
  cannot quote is a coinage wearing a borrowed name.
- Then decide superset or sibling. A superset takes the whole lexicon; a
  sibling takes the word and owes its tradition plus where the repo departs.

**5 · decide** — placement and markers.
- Constitutive structure goes in the body; merely-current structure goes
  under a realization marker. The test is the age test on the definition:
  *what would make this untrue?*
- Write a marker only where the argument that produced it actually happened.
  Every marker is optional, permanently.

**6 · execute** — write the entry. Definition first, two sentences at most,
saying what it IS. Markers after.

**7 · verify** — three checks, each named out loud with its result:
- **code** — the entry agrees with the schema, the constants and the strings,
  or the disagreement is stated in the entry
- **altitude** — every departure sits at the level of the tradition named. A
  missing component is not a departure from a way of thinking
- **spread** — the new word appears in no other entry's avoid-list, and its
  own avoid-list names the words it displaces

**8 · confirm** — a shared vocabulary changes by agreement. Show the entry
and the three verify results, and let a person accept it. This station is a
**Human Gate**; do not answer it yourself.

**9 · continue** — two questions.
- Did a canonical word change? Then sweep **rule-shaped prose only**. Records
  are dated and stay exactly as written; say in the entry which you left and
  why. A record is not repaired.
- Is the decision hard to reverse, surprising without context, and the
  result of a real trade-off? Then it earns an ADR in the contract's ADR home.

## What earns a term

A concept earns a term when it has **instances** — places in this repo where
the thing already happens and is currently described the long way. Name the
instances in the entry. A term with none describes a state nothing is in,
and should say so where it stands.

## What this skill does not do

It does not fill the marker grid. Departures are evidence of where this
repo's semantics do work of their own; one written to complete a row corrupts
a reading the glossary takes of itself. Write markers when an argument
produces them.

It does not rename identifiers. Columns, constants and message keys move
only through a migration or refactor with a reason of its own. Prose and
user-facing strings are this skill's whole surface.
