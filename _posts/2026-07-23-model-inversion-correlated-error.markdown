---
layout: post
title: "Model Inversion and the Geometry of Correlated Error"
date: 2026-07-23 09:00:00 -0700
description: "Why heterogeneous AI code review can reveal defects that a model reviewing its own work is structurally likely to miss."
---

There is a familiar kind of debugging failure. You solve a problem, inspect the solution, inspect it again, and get the same reassuring answer every time: yes, that looks right. Then someone else glances at it and asks the question you never asked. They have not necessarily worked harder. They have simply not inherited the premise that made your solution look inevitable.

That is a useful intuition pump for a recent [Greptile experiment on “Model Inversion”](https://www.greptile.com/blog/model-inversion). It is not, however, a reason to imagine that a language model trusts its own work, feels ownership of a pull request, or is reluctant to criticize itself. Those are social and psychological explanations. They are the wrong level of description for a code-review policy.

The machine version is both less romantic and more useful: **correlated error**. An authoring model and a reviewer that use closely related reasoning processes can fail together. A second model can add value not because it is more skeptical, but because it is a partially independent instrument.

## What Greptile actually measured

Greptile assembled two historical datasets: 500 pull requests attributed to Claude Code and 500 attributed to Codex. Authorship was inferred from signals such as `Co-authored-by` commit trailers, PR-title prefixes, and branch prefixes—not observed directly at generation time. It constructed roughly 1,500 ground-truth comments from sentiment analysis, vote ratios, and git archaeology; excluded style, praise, and documentation comments; then ran Claude Code’s and Codex’s `/review` three times per PR. Recall of high-severity bugs was matched to that ground truth by an LLM judge and averaged.

The headline figure is modest but provocative. On Claude-authored PRs, GPT 5.5 recalled 60.0% of the high-severity bugs versus Claude Opus 4.7’s 53.7%. On Codex-authored PRs, Opus recalled 62.0% versus GPT’s 50.5%. The matrix makes the crossed comparison explicit:

| Author attributed by Greptile | Claude Opus 4.7 review recall | GPT 5.5 review recall |
| --- | ---: | ---: |
| Claude Code | 53.7% (same-model) | 60.0% (cross-model) |
| Codex | 62.0% (cross-model) | 50.5% (same-model) |

*High-severity-bug recall (P0/P1); values and model labels reproduced from [Greptile’s “Models are worse at reviewing their own code,” Fig. 01](https://www.greptile.com/blog/model-inversion).*

In Greptile’s terminology, each reviewer did better on the other model’s attributed code than on its own. The company has turned that observation into an experimental routing feature: infer the coding agent from PR metadata and send the review to the other model.

There are other clues in the article that make the result less mysterious. Greptile reports that Claude-attributed PRs contained a larger share of missing-behavior defects, a category in which GPT had better recall, while Codex-attributed PRs skewed more toward semantic-intent and error-handling issues, where Claude’s recall was stronger. It also reports markedly different review traces: in the sampled runs, Opus spent 59.4% of visible evidence in a broad “scope” phase, whereas GPT spent 82.5% in an “investigate” phase. Those are observations about a particular evaluation setup and model versions, not a timeless taxonomy of model personalities. But they are exactly the sort of differences that can produce complementary blind spots.

## The quantity that matters is covariance

It helps to name the measurement precisely. Treat a model plus its prompt, tools, repository context, and decoding configuration as a stochastic transition kernel—a policy that maps the current state of a task into the next action or token. This is a better abstraction than pretending that an agent is literally a classical Turing machine, and it keeps the surrounding scaffold in view.

Let

```text
Q_ij = P(reviewer M_j detects a defect | defect introduced by author M_i)
```

The Model Inversion hypothesis says that, for at least some pairs,

```text
Q_ii < Q_ij,    where i != j.
```

In plain English: model *j* may be better at finding defects introduced by model *i* than model *i* is at finding its own. Notice what this does **not** say. It does not say that *j* is the universally stronger reviewer. Nor does it say that “different” automatically means “better.” The decisive quantity is the covariance between the author’s error events and the reviewer’s missed-detection events.

A reviewer with lower standalone recall can be the more valuable partner if its failures are less correlated with the author’s. Conversely, repeatedly sampling a nominally excellent reviewer whose omissions track the author’s omissions can produce a misleading pile of agreement. Review quality is therefore not just a property of one model; it is a property of a pair, under a task distribution and a scaffold.

## Why the same model can miss the same defect twice

A coding agent does not emit a patch in one indivisible flash. It follows a sequence of transitions shaped by learned parameters, the user request, system and developer instructions, available tools, the repository state, retrieved files, and a decoding policy. Somewhere along that path it chooses an abstraction boundary: perhaps a cache is treated as local rather than shared, an error is treated as unreachable, or a requirement is read as a UI preference rather than an invariant.

If the resulting patch lies near a stable region of that process, a later request to “review this change” may start a different local trajectory while remaining in the same basin of attraction. The reviewer sees the diff, searches the same kinds of evidence, makes similar relevance judgments, and stops when its familiar criteria are met. The original assumption may be so central to its representation of the task that it is not selected as a hypothesis to test at all.

This is not self-deception. It is shared inductive bias. It can arise through several concrete channels:

* **Shared representations and abstraction boundaries.** The author and reviewer may compress the same requirement into the same, inadequate latent distinction.
* **Similar salience over requirements.** Both may attend strongly to the visible happy path and weakly to a terse concurrency constraint or an implied compatibility promise.
* **Similar search and tool-use policies.** If both inspect the same files, issue the same narrow searches, or seek the same confirming evidence, neither is likely to expose the omitted dependency.
* **Common stopping criteria.** A policy trained to avoid noisy findings may decline to report a plausible defect before it has collected decisive evidence; another policy may report it but create a false-positive burden.

Changing “implement” to “review” changes the immediate objective. It does not necessarily replace the representations that made the defect plausible. Raising temperature or changing the sampling seed creates diversity, but diversity is not independence. It may amount to sending another explorer through the same terrain with the same map.

A different model changes more than a seed. Its transition rules, learned features, post-training trade-offs, and tool-use habits may cause it to partition the task differently. It may inspect the migration before the handler, treat a fallback as suspicious rather than pragmatic, or spend its uncertainty budget on an edge case the author made invisible. Call that **epistemic parallax**: a change of inferential viewpoint that makes a previously aligned assumption visible as an assumption.

## A checksum, not a proof

It would be a mistake to turn epistemic parallax into a new folk theorem. Claude, Codex, Gemini, and other frontier systems share large portions of public training data, programming conventions, documentation, benchmark incentives, architectural ancestry, and post-training objectives. They can inherit the same false premise, cargo-cult the same API pattern, or fail to notice the same underspecified requirement. A reviewer can also be confidently wrong in a way that agrees with the author.

Bayesian language is useful here. Convergence under sufficiently decorrelated reasoning processes increases the posterior probability that a result is valid. It does not establish validity by itself. The increase depends on the base rate of defects, the models’ sensitivities and false-positive rates, and—most importantly—the residual correlation of their errors. Two agreeing systems whose mistakes are almost perfectly correlated add little evidence. Two genuinely independent checks add much more.

Model diversity is a checksum, not a proof. The executable world remains the final arbiter: compilation, type checking, tests, fuzzing, property tests, static analysis, deployment checks, and runtime telemetry answer questions that a fluent review comment cannot settle.

## Read the study as product research, not causality

Greptile is appropriately clear that Model Inversion is experimental. Its study is interesting exploratory product research, but it cannot by itself isolate a causal “same model” effect.

The task populations may differ before review ever begins: models could have been used for different kinds of repositories, languages, or changes. Metadata attribution can be wrong, and a PR attributed to an agent may contain substantial human work or mixed-agent contributions. Historical review comments and git archaeology are necessarily incomplete ground truth: an unreported defect may still exist, and a later fix may have another cause. An LLM judge adds a further model-mediated measurement layer. Even the observed differences—6.3 points in one direction and 11.5 in the other—need uncertainty intervals before anyone should generalize them into a procurement rule.

A stronger experiment would assign identical, representative tasks to several authoring models, then cross every author with every reviewer. Reviewers should be blinded to authorship. Researchers could deliberately inject known defects alongside naturally occurring ones, use independent human adjudication for disputed findings, and publish precision as well as recall. The results should be stratified by defect type, language, repository, task type, and severity, with confidence intervals and estimated error correlations. Only then can we distinguish a model-pair interaction from differences in task mix or labeling.

## Build a validation portfolio

The operational conclusion is not “never let a model review itself.” A same-model pass can still catch regressions, especially when it is cheap. The conclusion is that a serious agentic engineering system should avoid spending all of its validation budget on one correlated channel.

A defensible pipeline might combine:

1. one model to author the change;
2. a heterogeneous model to review it;
3. static analysis, tests, fuzzing, property checks, or runtime validation; and
4. an independent adjudication step for disputed findings.

The key phrase is **validation diversity**: model diversity *and* modality diversity. A second model can question an assumption; a fuzzer can discover an input neither model considered; a type checker can refute an interface claim with no rhetorical ambiguity.

Eventually the routing rule should be a learned reviewer matrix, not a slogan. The best reviewer may depend on the authoring model, programming language, repository, defect category, task type, historical reviewer performance, cost, latency, and an estimate of error covariance. The right question is not “Which model is best?” It is “Which next validation instrument is most likely to reveal what this author-and-scaffold combination has left invisible?”

Don’t spend all your inference budget asking the same epistemic instrument whether it agrees with itself. Heterogeneous review reduces correlated error. Executable validation determines whether the code actually works.
