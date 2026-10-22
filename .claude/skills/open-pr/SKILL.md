---
name: open-pr
description: >
  Open or update a GitHub pull request: correct base branch, only related changes committed, lowercase imperative
  title, and a short plain-prose body. Use when the user asks to open, create, draft, or update a PR, or invokes
  /open-pr.
---

A PR body is for a busy reviewer who has the diff open. It says what the diff cannot: intent, symptom, evidence, ops
notes. It is always short.

## Flow

1. **Existing PR.** Run `gh pr view --json number,url,state` on the current branch. If an open PR exists, go to
   "Updating an existing PR".
2. **Scope.** Run `git status` and `git diff`. Commit only changes related to the PR topic, staged by explicit path,
   never `git add -A` or `git add .`. Leave the rest as it is and list it in the final message.
3. **Changelog.** If the repo has a CHANGELOG.md and the change is user-facing, follow the changelog skill first.
4. **Branch.** On the default branch, create a short kebab-case branch named after the change.
5. **Base.** Don't assume. If the branch was cut from another feature branch, ask whether to stack on it. Otherwise
   check where recent PRs target: `gh pr list --state merged --limit 10 --json baseRefName`. With no history, use the
   default branch.
6. **Commit and push** per the global git rules, then `git push -u origin <branch>`.
7. **Create** with `gh pr create --base <base> --title "..." --body-file -` and the body on stdin from a quoted
   heredoc, so backticks and `$` stay literal. Add `--draft` only when asked.
8. **Report** the PR URL and the body used.

Ignore the repo's PR template unless a project instruction requires it.

## Title

Lowercase, imperative, no Conventional Commits prefix, no trailing period. It often becomes the squash commit, so it
follows the commit rules. Name the change, not the activity: `retry failed webhook deliveries with backoff`, not
`fix webhook issues`.

## Body

Plain prose, scaled to the change, about 80 words at most:

- Small or mechanical change: one or two sentences.
- Most PRs: one short paragraph.
- Two or three paragraphs only when the problem needs explaining.

Cover, in this order, only what applies:

1. What changes, in product and code behavior.
2. The problem behind it, with the concrete symptom. Cite real evidence: issue numbers, an incident. Add `Closes #N`
   when it closes an issue.
3. A deploy or ops note: a manual step, ordering, required config. Only when one exists.

Leave out:

- A file-by-file walk through the diff, or anything the code shows on its own.- The decision log: alternatives weighed, why a value was picked, what was skipped or deferred.
- How the change was developed, which tools were used, and any attribution line.
- Headers, bold labels, and "Summary", "Changes" or "Test plan" sections. Use bullets only for three or more parallel
  items.
- Filler and AI vocabulary: "comprehensive", "robust", "seamless", "enhance", "leverage", "streamline", "ensure".
  Apply the deslop skill's dev rules to the draft when it is available.

Reread the draft before submitting and cut what the reviewer doesn't need. Over the cap means it is wrong.

Small change:

> Raise the webhook timeout from 5s to 30s; slow consumers were cut off mid-delivery (#201).

Change that needs context:

> Bounce notifications are now dropped at intake: the job is marked handled and logged with its DSN code, with no
> retry and no reply.
>
> They used to go through the normal send pipeline and could get an auto-reply, which the remote mailer answered,
> looping the thread until the rate limiter tripped (#183).
>
> Mute the bounce-loop alert in monitoring before deploying, or on-call gets paged while the backlog drains.

## Updating an existing PR

Commit and push the follow-up, then `gh pr edit <n> --body-file -` with the body rewritten for the PR's full current
state, same rules. No "update: also fixed X" addenda. Change the title only if the scope changed.
