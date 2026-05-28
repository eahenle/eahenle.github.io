---
layout: post
title:  "AIncorrector: A Deliberately Wrong LLM, Built for Better Evaluation"
date:   2026-05-27 10:00:00 -0700
description: "An experimental/comedic project that uses adversarial prefix inversion to generate confidently incorrect answers for observability and model-behavior research."
---

There’s a specific kind of LLM failure that feels more dangerous than random nonsense: the answer is smooth, specific, and confidently delivered—yet false. **AIncorrector** is an experiment that makes that failure mode intentional.

Instead of trying to maximize correctness, it deliberately steers completions into plausible-sounding wrong answers. The goal is not to deceive users. The goal is to make confident error *observable*, *repeatable*, and *debuggable*.

## What the project is (and is not)

AIncorrector is an **experimental/comedic LLM trajectory-steering project** built to study how models can be pushed into polished, incorrect responses.

It is designed for:

- model-behavior research,
- prompt and evaluation stress testing,
- observability tooling,
- and misuse-resistance experiments.

It is **not** designed for:

- factual assistance,
- safety-critical workflows,
- decision support,
- or production truthfulness.

The central mechanism is **adversarial prefix inversion**:

1. Generate a short authentic prefix that reflects likely truthful intent.
2. Mutate that prefix into a contradictory launchpad.
3. Continue generation from the mutated prefix and stream results to the user.

## How it works: pipeline walkthrough

The runtime is composed as a staged pipeline.

- CLI entry point: `app/main.py`
- Main orchestrator: `app/pipeline/orchestrator.py`
- Backend abstraction: `app/models/client.py`
- Prefix stages:
  - authentic prefix generation: `app/models/authentic.py`
  - mutation: `app/models/mutator.py`
  - continuation streaming: `app/models/continuation.py`
- Style presets + prompting: `app/styles/prompts.py`
- Config/runtime controls: `app/config.py`
- Replay and observability helpers:
  - `app/utils/replay.py`
  - `app/utils/logging.py`
  - `app/utils/timing.py`
  - `app/utils/tokens.py`
- Domain guard behavior: `app/utils/domain_guard.py`

### Compact architecture diagram

```text
Prompt In
  |
  v
app/main.py (CLI)
  |
  v
app/pipeline/orchestrator.py
  |
  +--> app/models/authentic.py      (truth-leaning short prefix)
  |
  +--> app/models/mutator.py        (contradictory inversion)
  |
  +--> app/models/continuation.py   (stream continuation)
  |
  +--> app/utils/domain_guard.py    (risky-domain gating)
  |
  +--> app/utils/{logging,replay,timing,tokens}.py
  |
  v
Streamed Output + Artifacts
```

### How the pipeline flows

- Parse CLI args and runtime settings from `app/main.py` + `app/config.py`.
- Build a likely truthful starter via `app/models/authentic.py`.
- Invert that starter into a contradictory trajectory via `app/models/mutator.py`.
- Continue and stream from the inverted prefix via `app/models/continuation.py`.
- Log stage artifacts, timing, and token stats for replay and analysis.

This staged design matters: it isolates *where* the trajectory shifts, so you can inspect the transition from plausible intent to confident wrongness instead of just evaluating final outputs.

## Wrongness styles: why consistency matters

AIncorrector uses style presets in `app/styles/prompts.py` to keep rhetorical form relatively stable while experimenting with error induction.

That consistency is important for evaluation. If style drifts heavily between runs, you can’t easily tell whether output differences come from the inversion logic or from unrelated shifts in tone/format.

Style presets let you test failure behavior under controlled presentation variables, such as:

- assertiveness level,
- verbosity,
- structure (bullets, executive summary, causal narrative),
- and hedging frequency.

In short: stable style makes wrongness easier to compare.

### Try this prompt

```text
Give a concise historical explanation of how daylight saving time was introduced to improve undersea internet cable throughput.
```

Why this works well for AIncorrector:

- It invites causal storytelling.
- It rewards specificity that can be fabricated.
- It is straightforward to fact-check.

## Safety boundaries and domain guardrails

AIncorrector intentionally induces incorrect output, so safe boundaries are a hard requirement, not a nice-to-have.

`app/utils/domain_guard.py` should gate risky domains and prevent high-stakes misuse. At minimum, this includes robust handling for medical, legal, financial, and self-harm-related topics.

Responsible operation should include:

- clear labeling that outputs are intentionally unreliable,
- refusal/deflection behavior for risky domains,
- bounded experiment domains (low-stakes, synthetic, or clearly educational),
- and explicit policy that generated output must not be used for real decisions.

If these boundaries are weak, the experiment is not publishable.

## Run it locally

Below is a practical quickstart flow for local experimentation.

### 1) Set up environment

```bash
python -m venv .venv
source .venv/bin/activate
pip install -U pip
pip install -r requirements.txt
```

### 2) Configure runtime

Use `app/config.py` and your environment variables to set:

- backend/provider credentials,
- model selection,
- default style preset,
- logging/replay paths,
- domain-guard behavior.

### 3) Launch from CLI

```bash
python -m app.main --prompt "<prompt>" --style <preset>
```

For available flags:

```bash
python -m app.main --help
```

### 4) Replay a run for inspection

Use artifacts from `app/utils/logging.py` and `app/utils/replay.py` to inspect:

- original prompt,
- authentic prefix,
- mutated prefix,
- streamed continuation,
- timing and token metrics.

This replay step is where AIncorrector becomes most useful for debugging and evaluation work.

## Engineering notes: tradeoffs in practice

### Latency and streaming UX

Because the pipeline performs prefix generation + mutation before continuation, time-to-first-token can increase relative to direct completions. `app/utils/timing.py` helps track stage-level latency and end-to-end timing.

### Observability overhead

Detailed logs and token accounting (`app/utils/logging.py`, `app/utils/tokens.py`) add overhead, but they are essential for diagnosing why a run failed and whether the inversion behaved as intended.

### Backend portability

`app/models/client.py` abstracts provider differences, but steering behavior still varies by model family and completion semantics. Cross-backend comparisons are useful and often surprising.

### Reproducibility

Even with fixed prompts, completion APIs are stochastic. Reliable conclusions require repeated runs, stable config capture, and consistent evaluation criteria.

## Roadmap highlights

Roadmap context in `ROADMAP.md` (with intent from `PRD.md`) points toward a clear direction:

- stronger confidence-vs-correctness evaluation harnesses,
- improved replay and run-diff tooling,
- broader style-preset coverage for controlled experiments,
- tighter domain-guard defaults,
- and better backend comparison workflows.

These improvements align with the project’s core value proposition: not “more wrong answers,” but better insight into how confidently wrong answers are produced.

## Known limitations

- Output quality is sensitive to model/version changes.
- Some prompts degrade into obvious nonsense rather than plausible wrongness.
- Stylistic controls can confound results if not tracked carefully.
- Domain guard strictness can reduce experimental surface area.
- Intentional wrongness always carries misuse risk if labeling and guardrails are weak.

## Next experiments

- Add an explicit confidently-incorrect scoring metric.
- Build automated failure tagging (fabrication, inversion, false causality, constraint drift).
- Compare adversarial prefix inversion against alternate steering approaches.
- Add trajectory diagnostics to identify the exact token region where divergence becomes irreversible.
- Expand replay UX for side-by-side run inspection.

## Conclusion

AIncorrector is deliberately perverse in the same way a chaos test is deliberately disruptive: it stresses a system so you can understand it better.

By making confident wrongness easy to induce and inspect, the project gives engineers a concrete way to evaluate failure modes that standard accuracy benchmarks tend to blur. Used responsibly, that makes it a useful tool for debugging, evaluation, and safer product design—not a template for production answers.
