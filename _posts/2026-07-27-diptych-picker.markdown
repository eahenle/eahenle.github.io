---
layout: post
title: "Pick One: Building Diptych Picker as a Durable Agent Loop"
date: 2026-07-27 16:00:00 -0700
description: "How a two-image preference game became a local-first system for durable agent work, immutable winners, editable taste, and crash-safe image generation."
tags: [ai, agents, open-source, image-generation, nextjs]
---

The interface is two images and one decision.

Pick A or B. The winner stays exactly where it is. The loser disappears, and a
new challenger takes its place.

That is [Diptych Picker](https://github.com/eahenle/diptych-picker), which I
have just released as open-source software under the MIT License. It is also a
good example of how a very small product idea can force surprisingly serious
systems architecture.

<img src="{{ '/assets/img/diptych-picker-1.0-offline-demo.jpg' | relative_url }}" alt="Diptych Picker 1.0 offline demo showing two independent image candidates">

*Diptych Picker 1.0 in deterministic offline mode. The demo ships with five
redistributable seed images and makes no model calls.*

The first version of the idea sounded almost trivial: generate two images, let
me choose one, and use the choice to generate something better. Repeat until
the system understands my taste.

But “generate something better” hides nearly every difficult part.

What does the model learn from one click? What happens when generation takes
longer than the user wants to wait? What survives a crash? What if three
independent images are needed at once? What if a moderation filter rejects one
job? What does it mean for the selected image to “stay” when the surrounding
application is polling, preloading, reconciling disk state, and rerendering a
React tree?

The visible interaction remained a binary choice. The machinery behind it
became a durable agent loop.

## The winner is an invariant

The most important product rule is unusually strict:

> When an image wins, that exact image remains on the same side. Only the loser
> is replaced.

“Exact” means more than preserving the prompt or asking an image model for a
variation. Diptych Picker preserves the winner's candidate ID, URL, bytes,
metadata, side, browser object identity, and existing `<img>` node. The winner
is never sent through an editing model.

That rule gives the comparison meaning. If choosing A quietly replaces A with
a close reconstruction, the user is no longer comparing a stable reference
against new evidence. The experiment changes underneath them.

It also made the implementation better. Winner preservation became a contract
that reaches from the domain model through the server, API, preloader, React
components, and browser tests. A tiny interaction rule turned into a useful
architectural spine.

The app supports four outcomes:

- A wins;
- B wins;
- the pair is a neutral tie; or
- both lose.

Wins update Elo ratings with K=32. A tie replaces both images without treating
either as positive or negative evidence. “Both lose” removes both from the
reusable pool without distorting Elo, while still recording that the generated
directions were unwanted.

The result is less like rating a static gallery and more like running a
continuous tournament whose contestants are being invented while it proceeds.

## Image generation should not live inside the web server

The easiest architecture would have been a Next.js route that calls a model
API, waits, and returns an image.

I deliberately did not build that.

The Diptych Picker web process never receives an API key, launches a model
subprocess, or invokes the Codex CLI. It binds to `127.0.0.1`, owns the game,
and writes complete generation jobs to a file-backed mailbox. An interactive
Codex session owns authentication, permissions, agent execution, and image
generation.

The process hierarchy is:

```text
interactive root supervisor
└── persistent mailbox monitor
    ├── fresh image worker
    ├── fresh image worker
    └── fresh image worker
```

There is exactly one persistent monitor. It recovers the mailbox, polls for
work, claims jobs, maintains a heartbeat, delegates bounded tasks, and
publishes terminal results. Each image job receives a fresh worker, and up to
three independent workers can run concurrently.

This separation matters for more than credential hygiene. A browser request
should not own the lifetime of a slow, expensive, failure-prone creative job.
The job should exist before a worker notices it, remain valid if the UI
refreshes, and still be recoverable if the agent session disconnects.

The web app and the agent agree through durable files, not wishful timing.

## The mailbox is the product

When the ready queue drops below its configured target, the app writes refill
requests under `.local-data/agent-mailbox/`. Claiming is atomic. Active work is
leased. Completion and failure are idempotent. Job IDs remain tombstoned after
archival so an old request cannot reappear as new work.

A completed worker does not simply hand the app a path and hope for the best.
The publication path verifies the expected job, fully decodes the PNG, checks
its dimensions and square format, computes its SHA-256 digest, stores it under
that content-addressed name, and records a strict terminal result.

This is a lot of ceremony for an image game. It is also why the game can
recover cleanly.

If Codex closes in the middle of a refill, I leave `.local-data` alone and run
the launcher again. The monitor reconciles already-terminal work, resumes
unfinished jobs whose leases require recovery, and continues ordinary polling.
It does not regenerate everything or publish two candidates for one request.

The same durability supports the rest of the product:

- a FIFO challenger buffer for instant swaps;
- a local fallback pool when generation is briefly behind;
- a bounded Elo-ranked pool of curated and learned candidates;
- content-addressed image exports;
- versioned save files with validation on restore; and
- an experimental acknowledged `co-proc` transport that can accelerate live
  delivery without replacing the mailbox as the source of truth.

The mailbox began as infrastructure. It became the boundary that makes the
interaction trustworthy.

## Taste needs more than a prompt

A single free-form prompt is a poor representation of taste. It entangles
subject, medium, composition, palette, mood, safety boundaries, and negative
constraints in one paragraph that is difficult to edit or compare.

Diptych Picker instead keeps a structured preference profile with separate
fields for themes, inspiration, media, visual style, palette, content level,
and things to avoid. A private source image can be analyzed into an editable
draft that describes transferable visual qualities without asking for a
person's identity or exact likeness.

The profile can be:

- **Frozen**, so the model never edits it;
- **Guided**, allowing restrained revisions after enough evidence; or
- **Unfettered**, allowing broader revisions at a faster cadence.

Even adaptive changes remain winner-gated and reviewable. The app records
revision history, permits named presets, and keeps manual control over what
becomes active.

There is also an immutable weighted prompt deck. Cards can gain weight when
their generated candidates win. Repeated rejections can request repair
suggestions, but the suggestions do not silently overwrite the source card.
Two cards can be blended into a review-only child. Three to five favorite
generated images can be distilled into a new card that records all of its
source candidates.

This is the distinction I wanted: the system may learn from behavior without
pretending that behavior is unambiguous.

## Product rules should be editable too

The mechanics that shape the experiment are not universal constants. Version
1.0 exposes four per-game rules in the UI:

- ready-queue size;
- reusable-pool size;
- champion-retirement streak; and
- maximum consecutive local fallback draws.

Changing the pool limit trims the weakest members immediately. Increasing the
queue schedules refill capacity. A new retirement streak applies to the next
comparison. These rules persist in exported saves, while starting a fresh game
restores configured defaults.

Making them editable turned out to be useful for the same reason structured
preferences are useful: hidden constants are difficult to reason about.
Visible rules make the experiment inspectable.

## What “1.0” means here

Calling something 1.0 should be a claim about its boundary, not its perfection.

For Diptych Picker, the stable boundary includes the deterministic offline
demo, the local agent workflow, the comparison mechanics, durable recovery,
editable preferences and rules, prompt cards, saves, the public API, and the
documented single-user loopback security model.

It does not claim that every proposed transport or future game mode is
finished. Tournament play and further persistent `co-proc` parity remain
follow-up work. The current co-proc channel pool is explicitly experimental;
the mailbox path is the supported fallback.

I made the release scope auditable:

- [32 public feature scenarios](https://github.com/eahenle/diptych-picker/blob/v1.0.0/examples/feature-scenarios.md);
- [a feature matrix connecting every scenario to documentation and automated evidence](https://github.com/eahenle/diptych-picker/blob/v1.0.0/docs/FEATURE_MATRIX.md);
- 470 unit and integration tests;
- 20 mailbox-protocol tests;
- 23 Chromium end-to-end scenarios;
- a clean source-archive installation test; and
- five documented, redistributable seed PNGs.

The release workflow reruns the required checks before creating its annotated
tag and GitHub release. The public archives contain no local game data,
environment overrides, worker handoffs, or generated artifacts.

## Try it without an agent

Diptych Picker requires Node.js 24 or newer. The quickest path is the
deterministic offline demo:

```bash
git clone https://github.com/eahenle/diptych-picker.git
cd diptych-picker
npm ci
npm run demo
```

Open <http://127.0.0.1:3000>. After dependency installation, that mode makes no
model or network calls.

To run the generated-image loop, install and authenticate Codex, then launch
the repository workflow:

```bash
npm install --global @openai/codex
codex login
npm run codex:play
```

The launcher starts the optimized local app and asks the repo-local
`$run-diptych-picker` skill to supervise the persistent monitor and fresh
workers.

The project includes a [getting-started guide](https://github.com/eahenle/diptych-picker/blob/v1.0.0/docs/GETTING_STARTED.md),
[user guide](https://github.com/eahenle/diptych-picker/blob/v1.0.0/docs/USER_GUIDE.md),
[agent-mode architecture](https://github.com/eahenle/diptych-picker/blob/v1.0.0/docs/AGENT_MODE.md),
[local API reference](https://github.com/eahenle/diptych-picker/blob/v1.0.0/docs/API.md),
and [complete 1.0.0 release notes](https://github.com/eahenle/diptych-picker/releases/tag/v1.0.0).

## The small loop is still the point

It is easy to discuss Diptych Picker as a mailbox, an agent hierarchy, an Elo
system, a content-addressed store, or a preference-learning scaffold.

Those things matter because they protect a much smaller experience.

Two images appear.

You pick one.

It stays.

Something new arrives.

And, one comparison at a time, the space of possible images begins to bend
toward what you meant.
