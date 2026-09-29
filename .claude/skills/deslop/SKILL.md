---
name: deslop
description: >
  Rewrite text so a person understands it on the first read and it doesn't read as AI output.
  Rewrites structure and sentences for the reader, not just banned words. Use when user says
  "deslop this", "make it sound human", "remove AI voice", "too LLM", "sounds like AI",
  "humanize this", "more human", or invokes /deslop.
---

The text you get here was usually written under banned-word rules already. It has no "leverage" or "delve" in it, and a word checklist will find nothing. That doesn't make it clean. What's left is what people actually complain about:

- They can't tell what it means on the first read. Sentences carry four facts joined by commas, "so", "and" and parentheses.
- The main point or the reason is in the last clause instead of the first sentence.
- It describes what the code does inside instead of what the reader sees or has to do. "Many devices answer the other connect calls without auth" is the code's point of view; a reader wants to know that a wrong password won't fail at connect.
- Words the reader can't resolve: "later", "the other calls", "in a different form", "some cases", "the first real call".
- Every fact the writer knew is in there, whether this reader needs it or not.
- It's the same sentences in the same order with contractions added.

Never report text as "already clean" because nothing matched a word list. If the text has none of the problems above, say so in one line and change nothing.

## Process

1. Read all of the target. For a file, read the whole section, not a slice.
2. Decide who reads it and what they need from it: someone deciding whether to turn an option off, an issue author who wants to know if their bug is fixed, a user scanning a changelog for what's new.
3. List the points that reader needs, most important first. Drop what they don't need even if it's true: internal mechanics, exported constant names, how we got here.
4. Check each point is true. Plain wording shows when a claim was vague. If you can't state it plainly without guessing, check the code, spec or source. Don't carry a fuzzy claim over in nicer words.
5. Write it fresh from the points. Don't patch the old sentences. For a file, replace the whole paragraph or section in one edit, not a string of phrase-level edits.
6. Reread it cold as that reader, without the code or this conversation. For each sentence: would they get it? Is any word vague? Would a developer say it out loud like that? Fix and reread.
7. Run the word and structure lists at the end of this file.

If the result differs from the input only by contractions and swapped words, go back to step 3.

## How it should read

- Point first. What something is for, or why a change was made, goes in the first sentence.
- One idea per sentence. Split sentences that chain facts with "and", "so", "which" or parentheses.
- Concrete over vague: "on the first call that needs a login", not "later".
- The reader's point of view: what they see, do or get. Internals only when the reader works on those internals.
- Shorter by cutting points the reader doesn't need, not by squeezing. Three plain sentences beat one dense one.
- Keep the register the destination needs. Announcements, READMEs, docs and issue replies stay plain and neutral. Casual isn't the same as human: don't add "tbh", "atm", "fwiw", "honestly", "couple of", "stuff", or short forms like "org", "repo", "deps" to make it sound relaxed. Chat and commit messages can be terse.
- If it's the user's own draft, keep their voice, opinions and word choices. Fix only what's unclear or wrong.

## By destination

**Code comment.** Delete it if it restates the code. Keep it only for a reason the code can't show. For an option or parameter: what it does, why it exists, what happens with each value.

**Changelog.** One line per entry: what the user can now do, and the API name. Leave out formats, constants and internals unless the user acts on them.

**Issue or PR reply.** Answer first (fixed, won't do, here's how), then the reason in a sentence or two.

**README and docs.** What it does in the first sentence. Examples over explanation. No walls of text.

**Commit message.** Lowercase imperative subject line, no prefix, no body unless asked.

**Chat.** Short. Fragments are fine.

## Examples

### Option comment (reason buried, code's point of view, vague)

Before:

```ts
/**
 * Check the credentials with an authenticated `GetDeviceInformation` before resolving, `true` by default. Many
 * devices answer the other connect calls without auth, so without this check a wrong password only shows up on the
 * first real call. Costs one round trip.
 */
```

After:

```ts
/**
 * Test the username and password while connecting. ONVIF has no login step, and the spec lets anyone read the clock
 * and the service list, so without this test a wrong password only shows up on the first call that needs a login.
 * Default `true`.
 *
 * `true`: `connect()` sends one extra request (`GetDeviceInformation`) and throws `AuthError` if the password is
 * wrong.
 *
 * `false`: no extra request. A wrong password is only reported by the first call that needs a login.
 */
```

The "before" also made a false claim ("many devices answer ... without auth"; really the spec allows those calls without auth). A reword that kept it would still be wrong.

### Changelog entry (every fact the writer knew)

Before:

```md
- Recorded footage. `searchRecordings` lists the segments on a channel, `downloadRecording`
  pulls a clip to a file (AVI by default or the device's native format, main or sub stream,
  with progress), and `startPlayback` returns a `PlaybackStream` with the same `frames()`
  iterator and `recordTo`, plus transport controls (pause, resume, fast-forward, rewind,
  frame step, normal speed). `RECORD_TYPE`/`RECORD_TYPE_NAME` and `RECORDING_FORMAT` are exported.
```

After:

```md
- Recorded footage: `searchRecordings`, `downloadRecording` (AVI or native format, main/sub stream, progress), and `startPlayback` for a `PlaybackStream` with `frames()`, `recordTo`, and transport controls.
```

### Fake work

Changing "Mechanics you should know:" to "Things to know:" and "you are" to "you're" across a README is not a deslop. If that's all you can find, the text is either fine (say so) or you didn't look at structure and the reader.

### Casual isn't better

A pinned announcement went from "The repository now lives at ... Stepan and I both maintain it from there." to "The repo now lives at ... Same maintainers, Stepan and me." The user posted the original. For public text, keep the plain neutral version.

## Final lists

Use these only after the rewrite. Fix a hit by rewriting the sentence, not by swapping in a synonym.

Words: utilize, leverage, facilitate, ensure, comprehensive, robust, streamline, enhance, seamless, straightforward, delve, nuanced, holistic, optimal, subsequently, additionally, functionality, methodology, in order to, baked in, lands/landed, surface (verb), verbatim, caveat, untouched, settled, survives, honors, clobber, hand-rolled, stray, spurious, canonical, authoritative, load-bearing, corroborate, guardrail, vestigial, stopgap, masquerading, pare back, wire up, plumb, anchor, the full picture, checks out, footgun, escape hatch, smoking gun. Drop the adverbs silently, deliberately, intentionally, genuinely, cleanly, notably, crucially. Physical metaphors for code changes (lands, ships, leaks, drifts, surfaces, gets wired) become the literal verb. Literal technical senses stay: a real CI gate, a memory leak, config drift, a stale cache, variable shadowing, CLI flags.

Structure:

- Opening that restates the question; closing that summarizes what was just said
- "Let me..." narration; "worth noting/checking/flagging"; "which is exactly what we wanted"
- Colon or question reveals ("The fix? One line."), "not X, it's Y" when nobody said X, lists of three adjectives
- Trailing ", ensuring that...", ", which means...", ", allowing you to..." clauses
- Closing offers ("want me to...", "happy to...", "say the word")
- Bold on every other phrase, headers over three-line sections, numbered lists for two or three items, emoji markers
- Any dash other than ASCII `-`. Rewrite em/en dash asides with commas, parens, a colon, or two sentences

## Boundaries

- Never change code blocks, inline code, URLs, paths, commands, versions, hashes, error messages, structured data, regexes or env var names.
- Never add facts, opinions or claims that weren't there. Removing points the reader doesn't need is fine; removing something they do need is not.
- Don't deslop security advisories, legal or license text, compliance text, or quotes from other people. Say what you skipped.
- Text in chat: output only the rewrite. Files: edit them and reply with one line on what changed.
