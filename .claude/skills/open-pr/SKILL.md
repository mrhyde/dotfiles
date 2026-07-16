---
name: open-pr
description: >
  Open or update a GitHub pull request: correct base branch, only related
  changes committed, lowercase imperative title, and a brief plain-prose body.
  Use when the user asks to open, create, draft, or update a PR, or invokes
  /open-pr.
---

Open a pull request with a body a busy teammate actually reads. The body is always short; a body longer than the diff is an automatic failure. Do not drift back to default PR-template behavior.

## Flow

1. **Scope the diff.** Run `git status` and `git diff` first. Include only changes related to the PR topic. Stage files by explicit path, never `git add -A` or `git add .`. Leave unrelated modifications untouched and mention them.
2. **Branch.** If on the default branch, create a feature branch: short kebab-case name describing the change.
3. **Base branch.** Do not assume. Check where recent PRs land: `gh pr list --state merged --limit 5 --json baseRefName`. If there are none, use the repo default branch.
4. **Commit and push** per the global git rules (imperative, lowercase, no prefixes, subject line only), then `gh pr create --base <base> --title "..." --body "..."`.
5. **Show the result.** Print the PR URL and the body used.

## Title

Lowercase, imperative, no Conventional Commits prefixes, no trailing period. Describe the change itself, not the activity: `retry failed webhook deliveries with backoff`, not `Fix webhook issues`.

## Body

Plain prose, scaled to the change: 1-2 sentences for a small or mechanical change, 1 short paragraph for most PRs, 2 paragraphs only when the problem needs real explanation. Hard cap: about 80 words. Cover, in order, only what applies:

- What the change does: product-facing and code behavior, stated plainly.
- The problem that made it necessary, with the concrete symptom. Cite real evidence when it exists (issue numbers, a specific incident). Add `Closes #N` when it closes an issue.
- A deploy or ops note (manual step, ordering, required config), only if one genuinely exists.

Hard rules:

- Never describe the diff file by file or restate what the code visibly does; the reviewer has the diff. The body carries only what the diff cannot say: intent, symptom, evidence, ops notes.
- No markdown headers, no bold section labels, no "Summary" / "Changes" / "Test plan" scaffolding.
- Bullets only when listing 3+ genuinely parallel items; prefer prose.
- Dry and to the point. No filler words or AI-voice vocabulary ("comprehensive", "robust", "seamless", "enhance", "leverage", "streamline", "ensure"). If the deslop skill is available, apply its dev-level rules to the draft before submitting.
- Written for reviewers: they care about behavior and code changes, not how the change was developed or which tools were involved.
- Test evidence is one trailing sentence at most (`58 tests pass, type-check and lint clean`), and only when tests were actually run.
- Before submitting, reread the draft and cut anything the reviewer does not need. If it is over the cap, it is wrong; shorten it.

Example for a small change:

> Bump the webhook timeout from 5s to 30s; slow consumers were getting cut off mid-delivery (#201).

Example for a change that needs context:

> Delivery failure notifications are now dropped at intake before any pipeline work: job marked handled, a warning log with the DSN code, no retry, nothing sent back to the sender.
>
> These mails went through the normal send pipeline and could get an auto-reply, which the remote mailer answered in turn and looped the thread until the rate limiter tripped (#183).
>
> The bounce-loop alert still needs to be muted in the monitoring config, otherwise on-call gets paged while the backlog drains.

## Updating an existing PR

For follow-up commits on the same branch: commit, push, then `gh pr edit <n> --body "..."` with a body rewritten to describe the full current state of the PR, same rules as above. Do not append changelog-style addenda like "update: also fixed X".
