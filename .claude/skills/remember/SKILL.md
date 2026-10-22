---
name: remember
description: Add an instruction to a CLAUDE.md memory file, merging it with what is already there.
argument-hint: [instruction]
allowed-tools: Read, Edit, Write, AskUserQuestion
disable-model-invocation: true
---

Instruction to add: $ARGUMENTS

If no instruction was given, ask for one and stop.

## Pick the file

If the instruction names a target ("for this repo", "globally"), use it. Otherwise ask with AskUserQuestion:

- **User** (`~/.claude/CLAUDE.md`): personal rules for every project
- **Project** (`CLAUDE.md` or `.claude/CLAUDE.md` in the repo root): rules for this repo
- **Local** (`CLAUDE.local.md` in the repo root): personal rules for this repo only

Offer Project and Local only inside a repo other than the home directory.

## Decide what to do

Read the whole file. Then pick one:

- **Skip**: the rule is already there, in any wording. Say where.
- **Update**: it contradicts or refines an existing rule. Rewrite that rule in place.
- **Add**: it is new. Put it under the existing heading it fits. Create a heading only when none fits, and match the
  file's heading style.

## Write the rule

- One bullet, imperative, specific and checkable: "Use 2-space indentation", not "Format code well"
- Match the file's existing bullet style, tone and line length
- Keep the rest of the file as it is

If the file does not exist, create it with a `# Claude Instructions` title and one heading for the rule.

## Report

One line naming the action, the heading and the rule, for example:

- Added under **Code Style**: use 2-space indentation for TypeScript
- Updated the test runner rule under **Testing** to use Vitest
- Skipped, already covered under **Git & Version Control**
