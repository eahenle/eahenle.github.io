---
layout: post
title:  "Let Me Ask Claude for You"
date:   2026-08-06 09:00:00 -0700
description: "AI can do more of the work. That makes the part we owe each other—context, judgment, and accountability—easier to see."
---

A lot of my job is being a meat proxy for AI.

That sounds like a confession, but it is not the kind of confession [Niklas Gruhn describes in “Don’t be a meat proxy.”](https://gruhn.me/blog/2026-08-03/) His complaint is about an increasingly familiar interaction: you ask a person a question, they ask Claude, and they paste Claude's giant response back to you verbatim. Now you have to read and validate an answer you could have generated yourself, with less control over its context. The human has added a network hop and little else.

Gruhn is right. This is irritating. It is often disrespectful of the recipient's time. And it can make the recipient responsible for finding plausible nonsense in an answer sent under somebody else's name.

But “meat proxy” is funny partly because it collapses two very different jobs. One is clerical packet forwarding: move words from a human to a model and move tokens back. The other is directing machine effort, supplying context, evaluating the result, fitting it to organizational reality, and deciding what happens next. One is a very articulate pneumatic tube. The other increasingly describes high-leverage professional work.

## Let Me Ask Claude for You

We have seen a version of this social transition before.

When web search was new, “I looked it up on the internet” could sound enterprising. Access itself was novel enough to be a contribution. Someone could take your question, type it into a search engine, and return proudly with whatever the machine found. They knew the incantation. They had visited the electronic library.

Then search became ordinary. Once everyone had roughly the same box available, handing someone an unprocessed search result no longer looked much like assistance. It could feel faintly insulting: did you think I could not type these words myself? The passive-aggressive endpoint was [**Let Me Google That for You**](https://letmegooglethat.com/), a whole website built to animate the offensively simple search your correspondent could have performed.

The cultural pattern is recognizable even if people adopted search at different times and with different levels of access. Operating a scarce tool looks like expertise; once that tool becomes common, expectations shift to what you do with its results.

LLMs appear to be running through the same progression, much faster. First comes wizardry: *you can ask a machine that and get a coherent answer?* Then service: *I will ask the machine for you.* Then commodity: *we both have the machine.* Then annoyance: *why did you send me something I could have generated myself?* Finally, perhaps, a norm: use the machine privately, but bring back something that reflects your judgment.

People are in all of these phases contemporaneously. For someone still in the wizardry phase, forwarding an LLM response can feel generous. For someone who uses several models every day, it feels like receiving search results with more adjectives. They have already arrived at **Let Me Ask Claude for You**.

## Judgment Was Always the Product

The social norm is changing because the economics of the work are changing. The machine can now produce a larger share of what used to be visible evidence of effort: the prose, the code, the table, the summary, the intermediate analysis. When those artifacts were expensive, it was easy to mistake producing them for the whole job.

It never was.

The valuable core of skilled labor was deciding what matters, what the real problem is, which information deserves trust, and which shortcut is safe. It was noticing the anomaly that changes the conclusion. It was knowing which local fact defeats the generally correct advice. It was deciding that a result is adequate—or that a fluent, plausible result is dangerously wrong. And, finally, it was being willing to stand behind the decision.

**Judgment was always the product.**

AI did not create the distinction between execution and judgment. It is exposing that distinction by removing more of the execution layer. The problem with raw AI forwarding is therefore not that the sender used AI. Using an LLM is ordinary tool use. The problem is that the sender omitted the part of the work that had value, then delivered the residue under the implied authority of their own name. That is answer laundering.

Gruhn recommends reading, understanding, validating, and responding in your own words. The underlying requirement is exactly right. I would sharpen the final test, though, because paraphrasing is no longer a useful certificate of thought. A model can perform the paraphrase too. Smooth prose may mean only that the raw answer passed through a second prompt on its way to you.

The meaningful question is not:

> Did you rewrite it?

It is:

> Can you explain why this answer is appropriate here, defend its assumptions, identify its uncertainties, and accept responsibility for acting on it?

The recipient should get something they could not obtain by prompting a general-purpose model cold. That might be private context, verification against an authoritative source, selection among alternatives, knowledge of local constraints, or synthesis across several tools and conversations. Often it should be a recommendation rather than an information dump. Sometimes it should simply be a decision.

This is also the difference between compression and forwarding. A valuable intermediary reduces the complexity that reaches the next person. They filter, combine, qualify, and make the response fit for use. An empty intermediary adds another hop while leaving all of the cognitive work at the destination.

## Who Did the Implementation?

Code review makes the distinction unusually sharp.

A developer can give a ticket to a coding agent, submit the generated implementation, paste the review comments back into the agent, and repeat until the pull request is accepted. At no point must the developer understand the code. In the worst version of this workflow, as Gruhn observes, the reviewers have effectively done the implementation with the coding agent. The nominal implementer merely preserves conversational continuity between them.

This is not harmless just because the code eventually passes review. Reviewers reasonably expect the author of a pull request to have made choices they can explain. If every question becomes a new message to an agent, review stops being a conversation with the implementer and becomes remote control through a biological permissions layer. The reviewers inherit both the implementation work and the task of discovering what its supposed owner does not know.

Yet agent-assisted implementation is not inherently empty. A skilled developer might use exactly the same agent and still own the architecture, the constraints given to the agent, the interpretation of feedback, the testing strategy, the tradeoffs, and the final decision to ship. The agent can write nearly every line without making the developer irrelevant. What matters is whether the developer has a defensible model of the system and remains accountable for its behavior.

The mechanics can look almost identical from outside. Ticket goes in. Code comes out. Comments go in. New code comes out. But delegation preserves responsibility while moving execution. Abdication moves the execution and pretends the responsibility has been fulfilled.

Fluency makes the abdication easy to miss. Generated prose can sound complete before anyone involved has formed a mental model they could defend. Generated code can look conventional while encoding assumptions nobody has named. The artifact appears finished, so the temptation is to pass it along and let the next person find out whether it is true.

## The Moving Target

This transition is exciting in practice, and also stressful in a very specific way. The definition of competent work is being rewritten during the workday.

A task that recently demonstrated expertise can quickly come to demonstrate only that it has not yet been automated. Writing the first implementation, locating the relevant documentation, comparing a handful of options, or producing a competent draft may collapse from an afternoon into a prompt. The worker does become more productive. But the reward for that productivity is usually not a quiet afternoon.

Instead, the scope expands. Now the same person can specify more goals, decompose more work, supply context to more agents, supervise parallel attempts, evaluate more output, and manage the consequences across a larger surface area. The machine removes execution cost while creating more things it is possible—and therefore increasingly expected—to attempt.

This produces the odd sensation of gaining leverage and falling behind at the same time. Every new capability reveals a larger possible scope of responsibility. Yesterday you were responsible for implementing one approach. Today you may be responsible for commissioning four approaches and knowing why three should be discarded. The goalposts are not merely moving. The playing field is expanding beneath them.

The stressful part is not simply fear that the machine will take the job. It is that the job's center of gravity keeps shifting toward higher-level decisions while the worker is still learning how much machine activity they can safely supervise. More leverage means more output. More output means more places where plausible errors can hide. Judgment is becoming more important at exactly the moment it is being spread across a wider field.

## What Should Come Back From the Machine?

We are still negotiating the etiquette, but a reasonable present-tense rule is available: use any tools you like, then return the result of your involvement rather than evidence that a tool ran.

Bring back the two paragraphs that matter, not twelve pages of generated throat-clearing. Say which source you checked. Name the assumption most likely to break. Explain that the generic recommendation conflicts with a local constraint. Choose between the alternatives. If the evidence does not support a decision, say what remains uncertain and what would resolve it.

Most importantly, make clear what you are prepared to own. “Claude says we should do X” is usually weaker than “I recommend X because of A and B; C is the risk, and here is how I checked it.” The first sentence reports model output. The second turns that output into professional judgment. It gives the recipient something to evaluate besides the model's fluency and someone to question besides a chat window.

None of this requires pretending the model was absent. Concealing tool use is not the goal. Nor is performing authorship by manually retyping a machine-generated idea. The standard is whether your contribution changed the answer into something appropriate for this person, this system, and this decision.

As tools absorb more execution, the obligation becomes clearer. Do not return the machinery's exhaust. Return the result of having applied it.

Use the model. Let it search, draft, code, compare, and argue. But when another person asks you a question, bring back something that bears the marks of your involvement: context, compression, a decision, a warning, a recommendation, or a commitment. If all you bring back is what the model gave you, you have not mediated the work. You have merely been a meat proxy.
