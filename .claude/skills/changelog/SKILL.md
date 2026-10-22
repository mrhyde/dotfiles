---
name: changelog
description: >
  Write, check and release CHANGELOG.md entries in any project. Use before opening a pull
  request that changes user-facing code, whenever a changelog entry is added or edited, when
  cutting a release, or when the user invokes /changelog.
---

# Changelog

A changelog is read by the people who use the software, not by its developers. Every line is
written for them, in the words the product shows them.

## Before writing

1. Find the file: `CHANGELOG.md` at the repo root, or the package's own in a monorepo. If the
   project has none, ask before creating one.
2. Read the project's own rules first. A project CLAUDE.md section, a project `changelog` skill,
   or a lint hook over the file overrides anything here.
3. Read the last two or three released sections and match them: heading format, group names and
   order, link style, tense, how names are quoted. The existing file is the style guide.

If the file has no established format, use Keep a Changelog: `## [Unreleased]` on top, then
`## [x.y.z] - YYYY-MM-DD` headings, newest first.

## When an entry is written

- In the same pull request as the change, under `## [Unreleased]`. Never at release time: a
  release only moves the Unreleased entries under a new version heading.
- One user-visible change, one bullet.
- A change nobody using the product can see gets no entry: a refactor, lint or format fix, build
  or CI change, test, internal docs move, or a dependency bump with no behavior change.

## Groups

`### Added`, `### Changed`, `### Fixed`, `### Removed`, in that order unless the file uses
another. Add `### Deprecated` or `### Security` only when the file already does or the change
needs it. A `### Highlights` group first is optional for a feature-heavy release: `- **Label:**
one or two plain sentences.` Create a group when it is missing.

## Writing an entry

- Added: starts with "Added" and names the feature: `Added the "Export as CSV" command`. A new
  ability with no single name reads "<thing> can now <verb>".
- Changed: says what is different, with "now", "no longer", or a past-tense verb such as
  Renamed, Replaced, Redesigned, Improved: `Renaming a project now renames its folder too`.
- Fixed: starts with "Fixed" and names the broken behavior as the user saw it, not the repair.
  Name a failure ("failing to load", "not opening"), not an appearance that could be a normal
  state ("showing nothing"). When the bug reached several places, name the area a user would
  recognize ("the editor", "every export format") instead of listing each one.
- Removed: starts with "Removed" and names the replacement when there is one.
- Breaking: an entry in any group that forces users to change code, config or habits starts with
  `**Breaking:**`, unless the file already marks them another way. Its second sentence says what
  to do instead.
- One line of about 8 to 15 words. At most one condition (when, after, if). No "so that",
  "keeping" or ", which" clauses stacked on the end.
- The words the product shows: its screens, buttons, settings and commands. Quote setting,
  command and option names exactly as they appear. For a library or CLI, the public names are
  the product: function names, flags and config keys in backticks.
- No file paths, internal names or implementation details. No refactor, repository, CI or
  build talk. No marketing tone ("powerful", "seamless", "robust").
- No trailing period on a one-sentence entry. A second sentence is only for a migration or
  breaking-change note, and then the entry ends with a period.
- Link the issue at the end in the file's existing style, usually `([#NN](url))`.

## Checking

If the project has a lint script or hook for the changelog, run it after every edit. Otherwise
reread each new entry against the rules above and against the `git diff` it describes: does it
name what a user would notice, and nothing they would not?

Before opening a pull request, compare `git diff <base>...HEAD -- CHANGELOG.md` with the code
diff. A user-visible change with no entry, or an entry for an internal change, is wrong.

## Releasing

1. Add `## [x.y.z] - YYYY-MM-DD` directly under `## [Unreleased]` and move the Unreleased
   entries beneath it. Write no new entries now; a change missing one gets its own PR first.
2. Leave `## [Unreleased]` in place, empty.
3. Pick the version by semver from the groups: Removed or a breaking entry is major, Added is
   minor, Changed or Fixed only is patch. Before 1.0, shift each down one.
4. Bump every file that carries the version (`package.json`, `pyproject.toml`, `Cargo.toml`,
   manifests). Check the project's release docs or workflow for the full list and the tag format.
5. Update the comparison links at the bottom of the file if it has them.
