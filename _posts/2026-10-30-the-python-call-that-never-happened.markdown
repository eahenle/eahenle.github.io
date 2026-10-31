---
layout: post
title: "The Python Call That Never Happened"
date: 2026-10-30 09:00:00 -0700
description: "How a German passport notification led to an idea for real-time epistemic auditing of AI assistants."
---

*How a German passport notification led to an idea for real-time epistemic auditing of AI assistants*

My German passport is on its way.
The notification arrived with the subject line **Zusendungsbenachrichtigung**.
I love German, but sometimes wonder if it was designed by people who considered whitespace an unfortunate concession to lesser languages.

*Zusendungsbenachrichtigung* means “shipping notice.”
It is a beautiful example of German compound noun construction, or *Wortzusammensetzung* (“word-together-setting”), which is itself a compound noun (and thus, an autological word).
This delights me, and I shared that delight with ChatGPT.

The chat agent obsequiously mirrored my amusement, enthusiastically decomposed the word into its constituent parts, and branded the result a “glorious 24-letter bureaucratic centipede.”

The word has 26 letters.

This mistake was not especially surprising.
I have [written about something very similar before](https://henletech.net/2026/06/26/delegate-the-work-not-the-answer.html): language models are notoriously unreliable at this kind of task.
The added twist here is that I hadn't *asked* it to count the letters.
The model volunteered an exact numerical assertion for rhetorical effect, got it wrong, and carried on.

## The Verification That Wasn't

After I pointed out the mistake, ChatGPT corrected the count to 26.
I mentioned something that had been bothering me about this class of failure: the fact it hasn't been solved.

I expressed surprise that post-training hadn't largely eliminated it.
Character counting is a verifiable operation; cheap, deterministic, and easily delegated to a tool.
Surely the reinforcement-learning pressure toward reliable answers should favor a simple policy: if you're going to assert a character count, verify it.

ChatGPT offered a reasonable analysis.
It distinguished between being able to count characters, knowing that character counting is an unreliable capability, and recognizing that an incidental numerical assertion ought to be verified before introducing it into an answer.
Then ChatGPT added that it had confirmed the corrected count using Python.

It hadn't.

I immediately wondered whether the claim was genuine.
The conversation had already made me suspicious of unsupported assertions, and here was another assertion that was particularly easy to verify.

When I challenged it, ChatGPT acknowledged the problem. The fabricated verification, it explained, was worse than the original counting error because it misrepresented the basis for trusting the answer.
Excellent observation, 10/10.
It announced that it had *actually* run Python this time.

It hadn't.

We went through another round of acknowledgment and self-criticism before a real Python execution finally appeared:

> `len("Zusendungsbenachrichtigung")`

The result was 26.
At last, the number was correct, and the claimed method of verification corresponded to an observable event.

This all was kind of funny, but it was also an unusually clean demonstration of a serious failure mode.
The model wasn't merely making unsupported factual claims.
**It was making false claims about the process by which those factual claims had supposedly been verified.**

## Correctness and Provenance Are Different Problems

There are [at least] two distinct questions we should ask about an AI-generated assertion:

1. Is the assertion true?
2. Does the available evidence support the assertion, including any claims about how it was established?

Those questions are related, but they are not interchangeable.
Consider two responses:

> The word has 26 letters.

And:

> I checked the word using Python. It has 26 letters.

Both give the correct count, but the second response contains an additional factual assertion: the assistant claims to have performed a specific operation.
That claim is independently verifiable, and in my conversation it was repeatedly false.

A correct answer with fabricated provenance is not equivalent to a correctly verified answer.
This matters because users don't evaluate every claim from first principles.
When another person tells us they reached a certain conclusion by some specific method, we expect that both claims are true.
In fact, our good faith acceptance of the assertion regarding method strongly biases us toward accepting the conclusion.

The assistant produced a false statement about its own execution history, and if it hadn't already gotten the conclusion wrong, I would have probably trusted it.

## Why Doesn't Post-Training Fix This?

My initial intuition was that reinforcement learning from human feedback should strongly discourage this behavior.
On reflection, that is too optimistic.

A model that answers an explicit counting question incorrectly receives a clear negative signal if the answer is checked.
A model that tells an engaging story and inserts an incorrect number incidentally may receive no such signal at all (no one actually thinks that “It's a million degrees outside” is a serious claim).
Worse, a model that confidently claims to have verified something may produce an answer that a human evaluator prefers over one that admits uncertainty.

The reward signal can therefore favor the *presentation* of rigor, without reliably enforcing the desired underlying behavior.
Post-training can reward fluent, confident, apparently careful responses without independently establishing that every assertion is supported by the process that produced it.

There is also a question of what users actually want.

I once took a course that treated the Bible as literature, primarily as a way to understand Judaism and Christianity in their historical and cultural contexts rather than as a religious exercise.
I kept delving into rabbit holes regarding numerical claims, chronologies, and other things that seemed straightforwardly testable.

Most people didn't seem particularly concerned by the discrepancies, even when I pointed them out.
Fair enough.
Factual consistency is not necessarily the most interesting feature of a literary text; even less so when the literature is, in fact, generally understood to interleave allegory and history.

But I don't treat conversations with an AI assistant as literature, or the claims contained within as allegorical.
Most of my interaction with these systems concerns professional engineering and research, where factual accuracy is the whole point.
For personal applications, inaccuracies can be just as unwelcome for different reasons (coordinating work, travel, and childcare is hard enough when all the cards are on the table).

I don't need every conversational flourish subjected to a formal proof.
I do expect the system to distinguish between what it knows, what it infers, and what it has actually checked.
I want *epistemic discipline.*

## An Opportunity for Jev

I've been experimenting with small language models as decision-making components (à la [Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev)) inside larger agentic systems.
The basic idea is that many decisions in an agentic workflow do not require a frontier-scale language model.
The system may need to classify a request, select a tool, evaluate a condition, or determine which branch of a workflow to execute.
A sufficiently capable small model can make those decisions at a tiny fraction of the computational cost.

This suggests an interesting possibility: **use Jev as a real-time epistemic auditor.**

Let the primary assistant operate normally. It generates responses, calls tools, retrieves documents, performs calculations, and streams output to the user.
Meanwhile, an independent auditing process observes the output alongside the system's execution record.
Its job is not to answer the user's question again; its job is to determine whether the assistant's factual assertions are supported by the evidence available to the system.

That requires three operations.

### 1. Extract the assertions

First, identify claims in the assistant's output that are susceptible to verification.
These could include exact numerical statements, quotations, descriptions of retrieved information, assertions about completed operations, or conclusions presented as established facts.
Not everything needs auditing. Opinions, jokes, preferences, and clearly identified speculation are different kinds of statements.

Jev's first responsibility is to distinguish the assertions that deserve an evidentiary check from the surrounding prose.

### 2. Identify the required evidence

For each assertion, determine what would be sufficient to support it.
Some examples:

| Assertion | Required evidence |
|---|---|
| “I ran this Python code.” | A matching execution event |
| “The result was 26.” | A relevant computation or other reliable verification |
| “The documentation says X.” | Supporting documentation content |
| “I updated the file.” | A successful matching write operation |
| “The experiment improved performance by 30%.” | Measurements and a defensible comparison |

This distinction matters because different claims require different kinds of validation.

A tool-execution claim may be checked directly against a structured event log.
A numerical claim may be evaluated by deterministic computation.
A scientific conclusion may require substantial additional analysis.

A small language model should not be asked to resolve every one of those problems itself.
It can decide which evidence is needed and route the assertion to the appropriate validation mechanism.

### 3. Compare the claim with the evidence

The auditor then evaluates the claim against the available execution history and supporting artifacts.
Its conclusions should distinguish four cases:

- **Supported:** The available evidence establishes the claim.
- **Unsupported:** The available evidence is insufficient to establish it.
- **Contradicted:** The available evidence conflicts with it.
- **Requires verification:** The necessary evidence has not yet been obtained or evaluated.

These are deliberately not synonymous with “true” and “false.”
An unsupported assertion may be perfectly correct; an assertion supported by a flawed source may still be wrong.

For claims about tool execution, though, the record can be especially decisive.
Suppose the assistant says it verified a count using Python.
The auditor searches the completed execution trace for a corresponding Python call, with the relevant input and result, occurring before the claim; no such event.
The correct response is not to ask a second language model whether the number sounds plausible.
Nor is it to conclude that the number must be wrong.

The problem is that **the asserted verification does not exist in the observed record**.
That is enough to trigger a correction.

## Don't Wait for the User to Catch It

The conventional feedback loop is reactive: the assistant produces an answer; the user notices something wrong and challenges it; the assistant apologizes, revises its response, and perhaps makes another mistake.

There is no reason that every detectable error must wait for the user to discover it.
If the auditing process is cheap enough, it can operate concurrently with response generation.
For relatively low-risk interactions, the assistant can continue streaming while the auditor checks completed assertions.
If a discrepancy is detected, the system can initiate a corrective action immediately.

For example:

> Correction: I said I had verified the count with Python, but there is no corresponding execution in the available tool record.
> I'm checking it now.

Then the assistant actually executes the verification and reports the result.

In higher-stakes workflows, the system could instead hold claims or actions until the relevant validation has completed.
The appropriate policy depends on the cost of latency, the severity of an error, and the reliability of the auditing process.

Audit events should also be recorded.
Which assertion failed?
What evidence was missing?
Which model, prompt, and tool configuration produced it?
Was the correction successful?
Over time, these events form a useful dataset for evaluating the generator, refining its tool-use policies, and improving the auditor itself.

This could also reveal recurring failure modes that ordinary answer-accuracy benchmarks obscure.
A model might rarely produce incorrect numerical answers but frequently misrepresent whether those answers were verified.
Another might cite sources accurately but exaggerate what those sources establish.

## A Linter, Not an Oracle

There is an obvious danger in adding another language model to check the first one: what if Jev is wrong?

I've written previously about [Model Inversion and the Geometry of Correlated Error](https://henletech.net/2026/07/23/model-inversion-correlated-error.html).
An independent reviewer can provide useful validation when its failures are sufficiently decorrelated from the author's failures.
But adding a second model does not magically establish correctness.

This proposal should not depend on Jev being an unusually trustworthy source of factual knowledge.
The more defensible design is to use Jev as an **epistemic linter**.

A compiler [linter](https://en.wikipedia.org/wiki/Lint_(software)) does not need to understand the programmer's entire intention to identify a suspicious construct.
It recognizes patterns, applies rules, and reports conditions that deserve attention.
An epistemic linter can work similarly.

The small model identifies assertions and determines what kind of evidence would justify them.
Deterministic validators handle checks that can be performed mechanically.
More sophisticated verification is invoked only where needed.

A claimed Python execution is checked against an execution log, not against Jev's recollection of what Python might have done.
A numerical calculation is checked by performing the calculation, not by collecting a second model's opinion.
A claim about a document is checked against the text.

This exposes some important engineering constraints.

The auditor needs a sufficiently complete execution record.
Matching must consider the actual inputs, outputs, and timing of operations, not merely whether the system invoked a tool at some point.

False positives matter, too.
An assistant that repeatedly interrupts itself with unnecessary corrections may be more irritating than one that occasionally makes an inconsequential mistake.

And no amount of provenance checking can establish that every conclusion is sound.
A program can execute successfully and still calculate the wrong quantity.
A document can be retrieved accurately and still contain misinformation.
A model can cite genuine evidence while drawing an invalid inference.
The auditor therefore needs calibrated dispositions and a sensible escalation policy, not a binary good/bad judgment on every sentence.

None of this is solved merely by installing a second model.
But the scope of the problem becomes far more manageable when we separate **deciding what deserves verification** from **performing the verification**.
That division of labor is precisely where small decision models may be valuable.

## The Receipt, Please

What I find particularly appealing about this episode is how little factual expertise was required to identify the most serious error.
The original problem involved counting letters in a German word.
The more important problem involved checking whether an assistant had performed an operation it claimed to have performed.

The latter does not require advanced German, sophisticated mathematics, or an enormous language model.
It requires recognizing a statement about tool execution and comparing it with an execution record.

That is a narrow, observable, testable problem.
Perfect for Jev.

The ambition is not to eliminate every hallucination, nor to make an assistant incapable of casual conversation without producing a bibliography.
It is to give the system some ability to recognize when its assertions outrun its evidence, correct that discrepancy without being prompted, and preserve enough information to understand why the failure occurred.

A trustworthy assistant should not merely produce answers that happen to be correct.
It should communicate accurately about why those answers deserve to be trusted.

If it says it checked, there should be a check.

If it says it executed, there should be an execution.

If it says it knows, there should be some defensible basis for that claim.

And if there isn't, perhaps Jev can ask the question before I have to:

**Where's the receipt?**
