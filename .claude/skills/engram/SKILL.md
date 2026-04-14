---
name: engram
description: This skill should be used when the user asks to "run an engram eval", "score an experiment", "compare experiments", "set a baseline", "estimate cost", "scaffold an engram project", "add a runner", "add a scorer", "add a transform", "reshape inputs or outputs per implementation", "explain results", "suggest improvements", or mentions engram concepts like workflows, implementations, runners, datasets, scorers, transforms, experiments, or baselines. Covers the engram CLI, the workflow/implementation/runner/transform/dataset/scorer data model, the run-score-compare pipeline, LLM-powered analysis, and project layout.
type: reference
---

# Engram

Engram is a Python CLI framework for evaluating and comparing AI workflows across platforms. It separates *what a task is* (workflow) from *how it runs* (implementation + runner) and *how it is measured* (scorers + dataset labels), so the same workflow can be run on multiple platforms and scored on equal footing. Git is the version tracker; cost is a first-class metric alongside accuracy.

## When to apply this skill

Apply this skill when working inside a project that contains an `engram.yaml`, or when the user asks to create one, run an eval, score results, compare runs, explain results, get suggestions, manage baselines, estimate cost, add a runner, or add a scorer. Prefer the CLI over poking at internal modules. For non-trivial changes to the data model or CLI surface, read `docs/spec.md` in the engram repo first.

## Core mental model

Five abstractions, each with a fixed home in the project tree:

- **Workflow** (`workflows/<name>/workflow.yaml`) — declares the input/output schema and which scorer is bound to each output field. Says nothing about *how* to run.
- **Implementation** (`implementations/<name>/implementation.yaml`) — a concrete way to run a workflow on one platform (models, prompts, runner config). All implementations of the same workflow must produce output conforming to the workflow's shared output schema. That shared schema is what makes cross-platform comparison meaningful.
- **Runner** — platform adapter invoked by name from `implementation.yaml` (`anthropic`, `anthropic-agent`, `openai`, `dynamiq`). Runners are registered in `engram/runners/registry.py`.
- **Dataset** (`datasets/<name>/`) — inputs + optionally partial labels. Inputs can be text files, images (JPEG, PNG, GIF, WebP), or PDFs. Labels can be partial: unlabeled fields are skipped at scoring time, never counted as errors.
- **Scorer** — pure function comparing predicted vs. expected for one field. Built-ins: `exact_match`, `fuzzy_match`, `set_match`, `contains`, `contains_all`, `contains_any`, `numeric_tolerance`. Projects can declare custom scorers by Python path in `workflow.yaml`.
- **Transform** (optional, per-implementation) — Python callables that reshape `InputData` before the runner sees it and/or reshape the runner's output dict before scoring. Declared on the implementation, loaded from `implementations/<name>/transforms.py`. Lets one dataset feed multiple platforms whose inputs or outputs differ in shape without forking the dataset (forking would split experiment refs and block comparison).

An **Experiment** is one (implementation, dataset) run. Each experiment gets a monotonic short ID (`#1`, `#2`, ...) for user-facing reference. Raw results, a frozen `ConfigSnapshot`, and (after scoring) an `eval.json` are written under `experiments/{experiment-id}/`. A one-line summary is appended to `experiments/experiments.jsonl` — that file is the queryable index of all runs.

## Experiment references

Experiments can be referenced by:

- **Short ID**: `#1`, `#2`, etc. (assigned at run time, monotonically increasing)
- **Recency**: `@` (most recent), `@~1` (previous), `@~N` (N runs back)
- **Full ID**: `{impl}_{dataset}_{timestamp}` (filesystem handle, hidden from Rich display)

Recency references (`@`, `@~N`) can be scoped with `--impl` and `--dataset` flags to resolve within a specific implementation or dataset. All commands that accept an experiment ID support all three forms. When an argument is omitted in an interactive terminal, commands offer arrow-key selection via questionary.

Shell tab-completion is available for implementations, datasets, and experiment IDs (including `#N` and `@~N` forms).

## The run → score → compare pipeline

Running and scoring are deliberately separate commands so scorers and labels can be updated and re-applied without re-running the workflow.

1. `engram run <implementation> --dataset <name>` — initialize the runner, snapshot config, iterate inputs, write per-example raw results. Supports text, image, and PDF inputs.
2. `engram score <ref> [--save]` — apply bound scorers, compute per-field accuracy/precision/recall/F1 plus cost summary, write `eval.json`, append to the index. Omit `--save` for a dry run. `<ref>` can be `#N`, `@`, `@~N`, or a full ID.
3. `engram compare <a> [<b>] [--against <id>] [--prompts]` — diff accuracy, cost, and config snapshots between two experiments. With a single ID, compares against the workflow baseline (errors if no baseline is set). Works across implementations because both produce the same workflow output schema. Interactive mode offers checkbox multi-select.

## LLM-powered analysis

Two commands use an LLM to analyze experiment results. Both require an `analysis:` block in `engram.yaml`:

```yaml
analysis:
  model: claude-sonnet-4-6    # any Anthropic model
  max_examples: 30            # cap on examples sent to the LLM (default 30)
```

- **`engram explain <ref> [<ref_b>]`** — analyzes a single experiment's results or compares two experiments, producing a markdown narrative of patterns, failure modes, and key observations. Results are cached per experiment directory; use `--no-cache` to re-run. Two-experiment mode produces a comparison analysis.
- **`engram suggest <ref>`** — produces actionable improvement recommendations for an experiment (prompt changes, model swaps, scorer adjustments). Also cached per experiment.

Both commands show estimated token count and cost before calling the LLM, with a confirmation prompt (skip with `-y`). In JSON mode (piped output), they emit structured JSON with the analysis text plus token/cost metadata.

## Commands cheatsheet

```sh
# Project
engram init                                   # scaffold project + classify example + sample dataset
engram status                                 # overview of workflows, implementations, datasets

# Runs
engram run <impl> --dataset <name>            # run an eval; flags below
#   -c / --concurrency N                      # worker count (default 5)
#   -n / --limit N                            # subsample N inputs
#   --sample-seed N                           # RNG seed for subsampling only (does NOT seed model sampling)
#   -r / --repeat N                           # run each input N times for run-to-run noise metrics
#   -l / --label "desc"                       # human-readable label for this run

engram score <ref> [--save]                   # score; --save writes eval.json and appends to index
engram compare <a> [<b>] [--against <id>] [--prompts]   # diff two runs; --prompts shows full prompt diffs

# Analysis (requires analysis: block in engram.yaml)
engram explain <ref> [<ref_b>] [-y] [--no-cache]   # LLM-powered explanation of results
engram suggest <ref> [-y] [--no-cache]              # LLM-powered improvement recommendations

# Baselines (workflow baseline vs. implementation reference — intentionally different lifecycles)
engram baseline set <experiment-id>           # freeze the workflow baseline (rare; "where we started")
engram baseline promote <experiment-id>       # advance the current reference for one implementation (routine)
engram baseline show                          # show current baselines and references

# Cost
engram estimate <impl> --dataset <name>       # needs >=1 prior experiment for calibration

# Experiment index
engram experiments list                       # list runs from experiments.jsonl

# Hosted-platform config (pull-edit-push-deploy; no-op for local implementations)
engram config pull <impl>
engram config diff <impl>
engram config push <impl>
engram config deploy <impl>
engram config list
```

All commands that take an experiment reference accept `#N`, `@`, `@~N`, or the full ID. Recency refs can be scoped with `--impl`/`--dataset`. When arguments are omitted in an interactive terminal, arrow-key selection is offered.

The CLI auto-detects TTY vs. pipe and switches between Rich tables and JSON log lines. Force JSON with `engram --json <subcommand>` when scripting.

## Project layout

```
my-project/
├── engram.yaml                     # project config (marks the project root)
├── .env                            # API keys; loaded automatically from project root
├── workflows/
│   └── classify/
│       ├── workflow.yaml           # schema + scorer bindings
│       └── scorers.py             # optional custom scorers
├── implementations/
│   ├── classify-anthropic/
│   │   ├── implementation.yaml     # platform, runner, model, runner_config, optional transform
│   │   ├── prompts/system.md
│   │   └── transforms.py          # optional: input/output reshape callables
│   └── classify-openai/
│       └── ...
├── datasets/
│   └── sample/
│       ├── dataset.yaml
│       ├── labels.json             # partial labels are fine
│       └── inputs/                 # one file per example (text, images, or PDFs)
└── experiments/                    # gitignored EXCEPT .gitignore + experiments.jsonl + baselines.json
    ├── .gitignore
    ├── experiments.jsonl           # append-only index
    ├── baselines.json              # workflow baselines + impl references
    └── {experiment-id}/
        ├── results.json
        ├── config-snapshot.json
        ├── eval.json               # written by `score --save`
        ├── explain.md              # cached `explain` output
        └── suggest.md              # cached `suggest` output
```

Three subtleties worth knowing:

- `experiments/` is gitignored but `experiments.jsonl`, `baselines.json`, and the directory's own `.gitignore` are deliberately tracked. Don't "fix" that.
- Labels in `labels.json` accept either a `{filename: {labels}}` dict **or** an array of `{filename, ...labels}` objects. Both formats coexist intentionally; don't collapse them.
- The pricing table is cached at `~/.engram/cache/pricing.json` — *outside* the project, which is why there's no project-local `.engram/` ignore.

## Running engram from source vs. installed

- **Installed user-wide** (recommended for normal use): `uv tool install git+https://github.com/2BAD/engram`, then `engram <subcommand>`. Upgrade with `uv tool upgrade engram`.
- **From source** inside the engram repo itself: use `uv run engram <subcommand>`. Project chores run via `poe` under `uv`, never bare `python`/`pip`:
  - `uv sync` — install deps
  - `uv run poe test` | `coverage` | `lint` | `format` | `typecheck`
  - `uv run pytest tests/test_scoring.py::test_name` — single test
- Python **3.14+** is required. Lint and format both go through `ruff` (configured in `ruff.toml`, not `pyproject.toml`). Type checking uses `ty` (Astral), not mypy.

## Working with runners

Built-in runners and what they expect:

| Runner            | Platform                  | Key config                                                |
| ----------------- | ------------------------- | --------------------------------------------------------- |
| `anthropic`       | Anthropic Messages API    | `api_key_env`, `model`, `max_tokens`, `temperature`       |
| `anthropic-agent` | Local Python agent        | `api_key_env`, `model`, `entry_point: file.py:func`       |
| `openai`          | OpenAI Chat Completions   | `api_key_env`, `model` (uses JSON mode for reliable output) |
| `dynamiq`         | Dynamiq hosted platform   | `app_id`, `access_key_env`; `config_management.mode: pull-push` |

All runners accept image (JPEG, PNG, GIF, WebP) and PDF inputs alongside text. The `InputData` model (`engram/models/input.py`) handles binary detection and base64 encoding; runners format these into platform-specific message structures (Anthropic image/document blocks, OpenAI image_url/file content parts).

Defaults and traps:

- Runner temperature defaults to **0**. Raise it only for creative tasks.
- `--sample-seed` seeds *dataset subsampling only*. It does not make model sampling deterministic.
- Dynamiq returns double-wrapped output (`{"output": {"output": {...}}}`). `runners/dynamiq.py` unwraps it so scorers see fields at the top level. **Do not reintroduce the wrapper.**
- Before launching workers, the run command preflights `required_env_vars(impl_config)` and fails fast with a friendly message if any are missing. Keep keys in the project `.env` — it's loaded automatically from the project root.

Adding a new platform: implement the `Runner` ABC in `engram/runners/base.py` (`trigger`, `snapshot_config`, optional `estimate_cost`) and register it in `_RUNNERS` in `engram/runners/registry.py`. The `trigger` method receives an `InputData` object that may be text or binary.

## Transforms: per-implementation input/output reshaping

Transforms solve the case where one canonical dataset has to feed multiple implementations whose platforms expect different input shapes or emit different output shapes. Without transforms the workaround is to fork the dataset, which splits experiment ids and breaks `compare`. Declare transforms on the implementation, and the canonical dataset stays shared.

```yaml
# implementations/<name>/implementation.yaml
transform:
  input: transforms.shape_input     # optional
  output: transforms.shape_output   # optional
```

Both entries are `module.function` paths resolved relative to the implementation directory (so the file above is `implementations/<name>/transforms.py`). Both are independently optional.

Signatures (kept deliberately narrow):

- **`input(inp: InputData) -> InputData`** — runs before `runner.trigger`. Return a new `InputData` (use `dataclasses.replace` — see `engram/models/input.py`). The original `filename` is what ends up on the `RunResult`, regardless of what the transform does; `result.input_file` is set from the pre-transform input.
- **`output(output: dict) -> dict`** — runs after `runner.trigger` on `result.output`. Used to normalize platform quirks back into the workflow's canonical schema so scorers see consistent fields across implementations.

Traps and guarantees:

- **Output transform only runs on `status == 'succeeded'`.** Failed runner calls reach scoring with their empty output intact — don't rely on the output transform to populate error payloads.
- **Transform exceptions are caught by the run loop** and marked as failed results (same path as runner exceptions), so a buggy transform won't crash the eval.
- **Snapshot records both refs** in `ConfigSnapshot.transform`, and `engram compare` surfaces transform drift between two experiments — including when only one side has a transform. Cross-impl comparisons stay honest.
- **Platform wire-format quirks stay in the runner, not the transform.** Example: Dynamiq's `{"output": {"output": {...}}}` unwrap lives in `runners/dynamiq.py`. Transforms are for implementation-level semantic reshaping, not per-platform protocol stripping.

## Scoring and repeat-aware metrics

Scorers are pure functions bound per-field in `workflow.yaml`:

```yaml
scorers:
  topic: exact_match
  sentiment: exact_match
  summary: contains_all              # all expected substrings must appear
  keywords: contains_any             # at least one expected substring must appear
  confidence: numeric_tolerance(0.1)
  outcome: scorers.normalize_outcome # project-local custom scorer
```

Built-in scorers:

| Scorer                   | Behavior                                                                 |
| ------------------------ | ------------------------------------------------------------------------ |
| `exact_match`            | Case-insensitive string equality after stripping whitespace              |
| `fuzzy_match`            | SequenceMatcher similarity >= threshold (default 0.8)                    |
| `set_match`              | Unordered set equality for list-valued fields                            |
| `contains`               | Predicted contains expected substring (case-insensitive)                 |
| `contains_all`           | Predicted contains all expected substrings (list or comma-separated)     |
| `contains_any`           | Predicted contains at least one expected substring                       |
| `numeric_tolerance(N)`   | Predicted within N% of expected (default 0.1 = 10%)                     |

Custom scorers are plain Python functions of `(predicted, expected) -> bool`, referenced by Python path. Declare them in `workflows/<name>/scorers.py` and reference them by dotted path from `workflow.yaml`.

When an experiment was run with `--repeat N` (N >= 2), each field's metrics also carry:

- **`mean_agreement_rate`** — per-input fraction of repeats matching the modal answer, averaged across inputs. Bounded `[1/K, 1]` where K is label space size. Intuitive but uncorrected for chance.
- **`majority_rate`** — fraction of inputs where strictly more than half the successful repeats agreed. Only defined for N >= 3.
- **`fleiss_kappa`** — Fleiss (1971) chance-corrected inter-repeat agreement, range `[-1, 1]`. The standard inter-rater reliability metric for categorical data; comparable across fields with different label-space sizes.
- **`accuracy_stdev`** — stdev of per-repeat field accuracies. The "noise floor" — how much the headline number jitters run-to-run. Used by noise-aware baseline gating to distinguish real regressions from natural variance.

For non-categorical fields (numeric, fuzzy text), `fleiss_kappa` and `majority_rate` are `None`; only `mean_agreement_rate` and `accuracy_stdev` are meaningful. Single-repeat experiments leave all four as `None` and the display layer hides the columns.

## Config management lifecycle

- **Hosted platforms** (`config_management.mode: pull-push`) follow pull -> edit -> diff -> push -> deploy. Sync is *selective*: only editable parts (models, prompts) mirror locally; structural metadata stays on the remote. `engram config push` does fetch-patch-save — don't replace the whole remote definition.
- **Local implementations** (API and agent; `mode: local`) have no remote. The local files *are* the config. Editing a prompt file or changing a model in the YAML is the config change.

Either way, every `engram run` captures an immutable `ConfigSnapshot` at trigger time (`engram/models/config_snapshot.py`). That is what `compare` diffs against — so a later config edit never changes what a past experiment recorded.

## Baselines: two verbs, two lifecycles

These look similar but mean different things:

- **`engram baseline set <id>`** — writes the **workflow baseline**, the frozen anchor for a workflow. One per workflow. Meant to be used rarely. Answers "how far have we come from where we started?". Cross-implementation by design.
- **`engram baseline promote <id>`** — advances the **implementation reference**, the current accepted state for one implementation. One per (workflow, implementation). Meant to be used routinely as new runs are accepted. Answers "did the latest change regress this implementation?".

Both verbs infer the workflow (and `promote` also infers the implementation) from the experiment ID — the user never types either by hand. Baselines and references live in a single `experiments/baselines.json` file keyed by workflow name, git-tracked alongside `experiments.jsonl`.

## Conventions to respect when editing the engram repo

Follow these to avoid reworking PRs:

- **Routing output:** the CLI auto-switches between Rich and JSON via `engram/observability/output_mode.py`. Do not `print(...)` directly — route through `engram/display/` and `engram/observability/`.
- **Ruff config lives in `ruff.toml`**, not `pyproject.toml`. The ruleset is broad; check `lint.ignore` before adding `# noqa`.
- **Single quotes, 120-char lines, 2-space indents.**
- **`docs/spec.md`** is a local working spec (not git-tracked). Update it when making non-trivial changes to the data model or CLI surface. Its untracked status is expected — do not flag it.
- **Labels loader** accepts both dict and array formats. Don't normalize one away.
- **Dynamiq output unwrapping** stays in `runners/dynamiq.py`. Don't move it upstream into scorers.
- **Read the existing command before adding a new one.** CLI commands live under `engram/cli/commands/` and are wired up in `engram/cli/__init__.py`.
- **Interactive prompts** use questionary (arrow-key selection). CLI commands should fall back to interactive pickers when arguments are omitted and stdin is a TTY. See `engram/cli/prompts.py` for helpers.
- **Shell completions** are provided via `engram/cli/completions.py`. When adding a new command that takes implementations, datasets, or experiment IDs as arguments, wire up the `autocompletion` parameter on the typer Argument/Option.

## Typical workflows

**Scaffold and try the sample project:**
```sh
engram init
cp .env.example .env       # paste ANTHROPIC_API_KEY / OPENAI_API_KEY
engram status              # verify both impls load
engram run classify-anthropic --dataset sample
engram run classify-openai --dataset sample
engram score #1 --save
engram score #2 --save
engram compare #1 #2
```

**Iterate on a prompt and measure the delta:**
```sh
# edit implementations/classify-anthropic/prompts/system.md
engram run classify-anthropic --dataset sample --label "prompt-v2"
engram score @ --save
engram compare @                               # compares against workflow baseline
engram compare @ --prompts                     # include full prompt diffs
engram baseline promote @                      # if the new run is accepted
```

**Analyze results with LLM:**
```sh
engram explain @                               # explain the most recent experiment
engram explain #3 #5                           # compare two experiments
engram suggest @                               # get improvement recommendations
```

**Measure run-to-run noise before trusting a headline number:**
```sh
engram run classify-anthropic --dataset sample --repeat 5
engram score @ --save
# read accuracy_stdev and fleiss_kappa in the repeat-aware metrics
```

**Estimate cost before a large run:**
```sh
engram estimate classify-anthropic --dataset big-unlabeled
# requires at least one prior experiment on this implementation for calibration
```
