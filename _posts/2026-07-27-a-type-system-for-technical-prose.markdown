---
layout: post
title: "A Type System for Technical Prose"
date: 2026-07-27 12:00:00 +0000
description: "Treating ASD-STE100 as a target language for AI systems that must be clear, consistent, and auditable."
---

Some writing problems improve when a language model becomes more inventive. A story can benefit from an unexpected image. A speech can benefit from rhythm. Even a product essay can benefit from a distinctive voice.

A maintenance procedure is not such a problem. Neither is a safety instruction, an operational runbook, a support article, or a compliance notice. In these documents, rhetorical variety often creates cost rather than value. Synonym churn makes search and translation harder. Elegant pronouns acquire ambiguous antecedents. A compressed sentence quietly merges two conditions. Ornamental prose competes with the action that a reader must perform.

[ASD-STE100 Simplified Technical English (STE)](https://www.asd-ste100.org/) exists for this general class of difficulty. The official maintenance group describes STE as both a controlled natural language and an international standard for technical documentation. STE began in aerospace, but its official history describes adoption beyond that sector.

This suggests a more interesting AI architecture than “put the style guide in the system prompt.” Treat STE not merely as advice for a general-purpose writer, but as a **target language**. Let a capable model interpret difficult source material, but do not let that model publish prose. Require it to emit meaning in a typed intermediate representation. Then compile that representation into controlled English with a smaller, restricted output machine.

This is also the design thesis behind my open-source project, [**ste-compiler**](https://github.com/eahenle/ste-compiler). The project is an attempt to turn the architecture in this essay into an inspectable, high-assurance implementation: explicit semantics in, constrained prose out, with validation evidence between them. The distinction in the project name is deliberate. It is not another wrapper that asks a model to “write more simply.” It treats controlled prose generation as compilation.

The goal is not to ask a general model to exercise discipline. The goal is to make undisciplined output difficult—or impossible.

## A semantic compiler

The pipeline resembles a compiler:

1. Source material enters the system.
2. A large reasoning model extracts its meaning into a semantic intermediate representation (IR).
3. A controlled-language realizer converts the IR into sentences.
4. Deterministic and model-assisted validators reject lexical, structural, or semantic violations.
5. Only validated text can be published.

Here, **front end** and **back end** have their compiler meanings, not their web-application meanings. A compiler front end consumes source material and produces an IR. A compiler back end consumes that IR and produces the target language. The large model is therefore the semantic front end, and the realizer is the controlled-language back end. A product diagram might place the output machine in front of the model, but calling it the front end here would reverse the compiler analogy. The validator is a type checker for prose.

This separation matters because reasoning and expression require different capabilities. The semantic front end needs broad context, world knowledge, document understanding, and the ability to identify uncertainty. The realization back end needs little literary range. Its task is closer to translation, serialization, or semantic-to-text generation: choose an allowed construction that faithfully realizes an already specified proposition.

The IR must contain more than a summary. It must preserve the features that simplification systems are prone to erase: document type; actors; actions; objects; preconditions and postconditions; temporal order; cause and effect; negation; warnings and hazards; quantities and tolerances; references; authorized terminology; facts that must not be omitted; and unresolved ambiguity.

For example:

```yaml
document_type: procedure
terminology:
  COMPONENT_7:
    canonical: hydraulic isolation valve
    roles: [technical_noun]
steps:
  - id: STEP_1
    actor: technician
    action: open
    object: COMPONENT_7
    preconditions:
      - pressure_psi: {operator: less_than, value: 10}
    warning:
      id: WARNING_1
      hazard: unexpected actuator movement
      prohibition: do_not_continue_if_pressure_is_10_psi_or_more
    postconditions:
      - COMPONENT_7.state: open
ordering:
  - before: WARNING_1
    before_step: STEP_1
unresolved:
  - source_does_not_specify_pressure_measurement_location
required_facts: [pressure_threshold, prohibition, valve_identity]
```

That last field is as important as the first. If the source does not say where pressure is measured, the system must not transform absence into confidence. It must stop, ask, or publish an explicitly marked unresolved condition. Controlled language must not launder uncertain source material into crisp, unsupported instructions.

## Nine hundred words are not nine hundred tokens

The STE dictionary contains a controlled general vocabulary of approximately 900 approved words, according to the [official FAQ](https://www.asd-ste100.org/STE_faq.html). It also permits technical nouns and technical verbs applicable to a company, industry, or subject field, under specific writing rules. Those terms can come from official documents, drawings, company glossaries, or terminology databases.

This is not equivalent to placing 900 tokenizer IDs on an allowlist. The entries are **words**, not necessarily BPE or SentencePiece tokens. One approved word can be split into several tokens. A token fragment can occur in both approved and prohibited words. Punctuation and structural markup need their own treatment. Most importantly, valid domain terminology extends beyond the general dictionary. A token-level gate over an ordinary tokenizer can therefore reject valid text and still assemble invalid words from permitted fragments.

The target vocabulary has two layers:

* a closed, versioned general vocabulary, with approved meanings and grammatical uses; and
* a runtime-authorized set of domain-specific technical nouns and verbs.

The decoder must produce approved general language, punctuation and structural markers, plus references to authorized terms. Domain terminology should ordinarily live outside model weights in a terminology store. Each record should have a stable identifier, canonical spelling, definition, allowed grammatical roles, source and approver, effective revision, and change history.

The IR can refer to `TERM_1` or `COMPONENT_7`. The realizer builds grammatical structures around those identifiers; a deterministic pass inserts the canonical strings. A copying mechanism can serve the same purpose when its boundaries are strictly controlled.

This divides authority cleanly. The language model owns grammar and sentence organization. The glossary owns technical terminology. Neither may rewrite the other. A model cannot improve “hydraulic isolation valve” into “hydraulic shutoff control” because the latter sounds less repetitive. In this setting, repetition is a feature.

## Choosing the output machine

There is a useful spectrum of realization back ends.

A **prompted general model** is the fastest baseline. A reusable **Agent Skill** can add durable instructions, examples, and a validation workflow. In the experiment that prompted this project, the skill was supplied to the model as system context and a separate linter scored the result. That is a stronger working setup than a short prompt, but it still does not restrict the model’s output space.

This baseline has already been tested in the work that prompted this project. In [“The cure for AI slop is a 1986 aircraft manual”](https://www.youtube.com/watch?v=uJblcC4lKYw), Vusal Ismayilov compared six developer-writing tasks under four conditions: a plain baseline, a banned-words list, Orwell’s six rules, and a distilled STE Agent Skill. Across Claude Sonnet and gpt-5.5, the skill reduced heuristic writing violations by 74% and 50% relative to the plain baseline. The [published experiment data](https://github.com/woosal1337/blog/blob/main/videos/ep01-the-cure-for-ai-slop/experiment-results.md) also states the limits clearly: six tasks, two models, a heuristic linter, and a measurement of form rather than truth. The result is good evidence that a writing system can improve surface discipline. It does not measure semantic fidelity, test an IR, or make prompt-level enforcement hard.

A **LoRA-adapted model** can make approved words and constructions more probable. LoRA freezes pretrained weights and introduces trainable low-rank matrices, drastically reducing the parameters that must be trained for adaptation. ([Hu et al., “LoRA: Low-Rank Adaptation of Large Language Models”](https://arxiv.org/abs/2106.09685)) But LoRA changes preferences, not the set of possible outputs. The base model retains its unrestricted vocabulary and rhetorical habits. An adapter can reduce violations; it cannot constitute hard enforcement.

A **fully fine-tuned small encoder-decoder** is a better conceptual fit for production. The input is a structured semantic object and the output is a controlled sequence: much closer to conditional translation than open-ended chat. The original T5 work provides a well-established text-to-text encoder-decoder framing, while data-to-text research such as WebNLG demonstrates the broader task of realizing structured meaning as language. ([Raffel et al., “Exploring the Limits of Transfer Learning with a Unified Text-to-Text Transformer”](https://jmlr.org/papers/v21/20-074.html), [Gardent et al., “The WebNLG Challenge”](https://aclanthology.org/W17-3518/))

A **constrained decoder** can mask continuations that would violate a lexical automaton or grammar. Grammar-constrained decoding research shows how formal constraints can be integrated into generation rather than checked only afterward. ([Geng et al., “Grammar-Constrained Decoding for Structured NLP Tasks without Finetuning”](https://aclanthology.org/2023.emnlp-main.674/)) A **grammar-driven surface realizer** can map typed propositions into hand-specified constructions. A **template system** is still better for highly regular warnings or single-action instructions.

The strongest production design is likely hybrid: templates where the semantic shape is fixed; a small neural model for sentence division and limited structural choices; constrained decoding for lexical control; deterministic glossary substitution; and validators at the boundary. Neural generation is used only where it earns its uncertainty.

## Validation must reach meaning

The official STE guidance is unusually relevant here. It says that checking tools can flag unknown words, sentence length, long multi-word nouns, and passive voice, but that not all rules can be checked automatically. It also warns that tools cannot determine whether text makes sense, cannot replace the standard or writer, and are neither endorsed nor certified by ASD or the maintenance group. Tools must incorporate the organization’s technical terms to avoid useless “unknown word” alerts. ([official guidance on STE tools](https://www.asd-ste100.org/STEsoftware.html))

Deterministic checks can identify unauthorized vocabulary, incorrect parts of speech, disallowed meanings of approved words, sentence and paragraph length, passive voice, complex noun phrases, multiple instructions in one sentence, ambiguous pronouns, and rules that differ between procedures and descriptions. The official guidance explicitly notes that procedural and descriptive text can require different checks. ([official guidance on STE tools](https://www.asd-ste100.org/STEsoftware.html))

But lexical compliance is not semantic fidelity. “Do not open the valve above 10 psi” and “Open the valve above 10 psi” can use an identical vocabulary while specifying opposite behavior.

The validator must compare output with the IR. Did negation survive? Are every value, unit, tolerance, and comparator unchanged? Is action A still before action B? Does each warning precede the hazardous step? Is every `required_fact` realized exactly once? Do terminology identifiers resolve to the correct canonical terms? Model-assisted entailment checks can add evidence, but high-consequence fields should also have deterministic aligners and explicit proof obligations.

Failures should return structured diagnostics, not “please make this clearer”:

```json
{
  "status": "reject",
  "violations": [
    {"code": "NEGATION_LOST", "ir_path": "steps[0].warning.prohibition"},
    {"code": "TERM_REWRITTEN", "expected": "COMPONENT_7", "found": "shutoff control"},
    {"code": "QUANTITY_MISMATCH", "expected": "< 10 psi", "found": "<= 10 psi"}
  ]
}
```

The back end can regenerate under tighter constraints, fall back to a template, or escalate to a person. Crucially, rejected text never becomes the next model’s unmarked source of truth.

## Do not simplify another model’s prose

The tempting pipeline is prose-to-prose: let a large model write normally, then ask another model to simplify the draft. It is easy to demo and hard to trust.

The second model must reconstruct semantics from rhetoric that the first model invented. During simplification it can lose a negation, collapse nested conditions, reorder actions, delete a qualification, or turn a precise distinction into a fluent falsehood. The result can look cleaner precisely because evidence of the error has disappeared.

Suppose the source means: “If the backup pump is not available, do not disconnect the primary pump until reservoir pressure is below 10 psi.” A prose author might subordinate, paraphrase, or split that relationship. A simplifier can easily preserve the nouns and number while changing the scope of “not” or “until.” Surface fluency provides no alarm.

IR-to-prose removes one lossy inference step. The realizer receives explicit predicates and constraints, not another model’s literary interpretation of them. The semantic front end can still be wrong, but the error surface becomes inspectable: reviewers can examine the extracted condition, prohibition, threshold, and ordering separately from how they are worded.

## A staged route to production

**Stage one: prompted and Agent Skill baselines.** Compare a plain model, an STE-oriented system prompt, and a distilled Agent Skill with the same source documents and evaluation set. Ismayilov’s experiment establishes that the skill condition can improve surface form; this implementation must extend the comparison to semantic fidelity and hard failure modes. These runs establish benchmarks and yield candidate examples—not automatically trusted training data.

**Stage two: LoRA prototype.** Train an adapter to favor compliant constructions. Use rejection sampling, rule-based scoring, and human review. This stage tests whether the task and data are coherent before investment in a dedicated model.

**Stage three: dedicated realizer.** Train a smaller encoder-decoder directly on IR-to-controlled-English pairs. Sources can include licensed or otherwise authorized STE documents, synthetic IR extracted from verified STE sentences, human-authored parallel examples, rule-targeted contrastive pairs, deliberately corrupted negatives, and glossaries with explicit grammatical metadata. A corpus labeled “technical English” is not thereby ASD-STE100-compliant; provenance and expert verification are dataset features, not paperwork.

**Stage four: hybrid production system.** Route regular instructions and warnings to deterministic templates. Use the small model for sentence division and sanctioned choices. Apply constrained decoding, terminology substitution, and final validators. Escalate unresolved semantics instead of generating around them.

This progression also produces a sensible assurance case. Each stage separates failures of source interpretation, IR construction, realization, terminology, and validation. A monolithic prompt collapses all five into one opaque completion.

## Evaluate the contract, not the paraphrase

<!-- Publication gate: add ste-compiler figures before merging this post. Include prompt/skill/compiler comparisons, semantic-fidelity results, validator error rates, and representative failure analysis. -->

Similarity is inadequate. An evaluation suite should report lexical compliance and structural-rule compliance, but also semantic fidelity, omission rate, negation preservation, quantity and tolerance preservation, ordering preservation, terminology consistency, and the coverage of required IR fields. Operational metrics matter too: regeneration and escalation rates, validator false positives and false negatives, latency, and the percentage of outputs that fall back to templates.

Human evaluation should test task comprehension, not literary preference. Can trained and less-expert readers identify the correct actor, action, condition, and hazard? Do translations from the controlled source preserve terminology and relationships consistently? STE’s original purpose included improving comprehensibility for readers with limited English, so multilingual comprehension and translation behavior deserve first-class measurement, not an appendix.

The adversarial set should be deliberately unpleasant: nested conditions, exceptions, negative instructions, similar component names, unit conversions, sequential actions, contradictory terminology, ambiguous sources, and procedures in which warnings and cautions interact with steps. Test `less_than` against `less_than_or_equal`. Swap two nearly identical identifiers. Remove one “not.” If the validator does not notice, it is not yet a safety boundary.

## Governance is part of the language

ASD-STE100 is a maintained, copyrighted, and trademarked standard owned by ASD, with formal revisions and established training practices. The official copy of Issue 9 is available by request, and the official site warns that ASD and STEMG do not certify commercial checking or AI tools. ([official downloads page](https://www.asd-ste100.org/STE_downloads.html), [official tools disclaimer](https://www.asd-ste100.org/STEsoftware.html))

Before publishing a system or dataset, verify the current edition, official terminology, permissions, quotation limits, and conditions for reproducing vocabulary or other parts of the standard. Link to official sources rather than copying substantial protected material. Obtain appropriate expertise before claiming compliance.

Three labels must remain distinct:

* **ASD-STE100 compliance** is a claim about conformance to the actual standard.
* **STE-inspired controlled language** describes a local subset or derivative control scheme.
* **Plain language** is a broader writing practice, not a synonym for either one.

Calling a prompted model “STE-compliant” because its sentences look short weakens both engineering and governance. Compliance is not a vibe, and a validator badge is not certification.

None of this makes restricted language universally superior. Creative ambiguity, voice, humor, persuasion, and emotional resonance are valuable capabilities. A condolence letter should not sound like a maintenance card. A novel should not compile. The argument applies where consistency, auditability, translation, and precise action dominate originality.

In those domains, separating thought from speech gives us a cleaner contract. The large model can interpret a complicated world. The IR can expose what it thinks that world requires. The realization back end can surrender rhetorical vanity and realize only authorized meanings in authorized forms.

The large model may think in a rich, high-dimensional internal language. **The output machine should speak only with the precision the task permits.**
