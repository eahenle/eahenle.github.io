---
layout: post
title:  "Delegate the Work, Not the Answer"
date:   2026-06-26 09:00:00 -0700
description: "AI raises the floor for producing plausible artifacts, not necessarily correct products. The useful trick is to outsource implementation while keeping judgment, verification, and product sense in the loop."
---

The cost of writing software is collapsing.

The cost of knowing what software should exist is not.

That distinction explains a lot of the confusion in the current AI discourse. We keep arguing as if there are only two possible stories:

- everyone is a programmer now, or
- AI is useless slop.

Neither one describes what I am seeing.

The thing modern LLMs have become astonishingly good at is producing artifacts that look finished.

Code that compiles. Design documents with clean headings. Unit tests. Architecture diagrams. API wrappers. Pull requests. PowerPoints. You can ask for almost any software-shaped object and receive something that looks like it belongs in a real repository.

Five years ago, this was impossible.

Today, it is routine.

But a plausible artifact is not a product.

A product survives contact with reality. It satisfies constraints nobody remembered to mention. It keeps working after the third feature request, the second rewrite, the first security review, and the inevitable moment when someone asks whether it can handle ten million users.

Those constraints do not disappear because an LLM generated the first draft. In many cases they become more important, because now you can generate software faster than you can understand it.

That shifts the bottleneck.

The scarce resource is no longer typing.

It is judgment.

## The Floor That Actually Rose

I do not think AI has suddenly created millions of expert engineers.

I think it has created millions of people capable of producing convincing artifacts.

Those are different things.

The floor for making something that convinces a layperson has risen dramatically. A generated application can have a nice landing page, a plausible database schema, a familiar folder structure, and a test suite with a respectable amount of green text. It can look more finished on day one than many hand-written prototypes used to look after a week.

That matters. Demos matter. Prototypes matter. The ability to materialize an idea quickly is useful.

But slop is not product.

The harder floor is not "can you produce something that looks like software?" It is "can you produce something correct, maintainable, secure, observable, operable, and useful under changing constraints?"

AI raises that floor too, but much less evenly.

The biggest gains accrue to people who already know what good looks like. An experienced engineer can reject bad suggestions instantly. They can ask increasingly precise questions. They know which generated code deserves trust and which deserves suspicion. They know when to throw away 5,000 generated lines and replace them with fifty carefully written ones.

The model does not replace their expertise.

It amplifies it.

Meanwhile, someone without that foundation often cannot distinguish elegant code from fragile code, because both compile.

The result feels magical right up until production.

## The "10x Engineer" Was Always a Bad Frame

This is why the "10x engineer" framing annoys me.

Not just because it is smug, although it is. Not just because it flattens collaborative work into an individual scoreboard, although it does that too. It is also a bad model of how human minds work.

Engineering output is not a scalar quantity produced by typing speed. It is a messy interaction between problem selection, taste, debugging ability, system knowledge, communication, sequencing, risk management, and the willingness to delete your own favorite idea when reality rejects it.

AI compresses some parts of that process more than others.

It compresses expression.

It does not compress judgment nearly as much.

That is why the people getting the most leverage are often the people who least needed help writing code in the first place. They already had the mental model. They already knew the shape of the solution. They already understood the failure modes. AI removed friction from the boring parts.

It made experts less likely to spend Tuesday afternoon writing boilerplate.

That is valuable. It is just not the same as turning everyone into an expert.

## Delegate the Work, Not the Answer

Here is a silly question:

How many letters `p` are in the name `Florent`?

Frontier models can get questions like this hilariously, preposterously wrong. Sometimes they will answer one. Sometimes two. Sometimes zero. Worse, if you confidently tell them they are wrong, many will obediently "correct" themselves to whatever false count you suggest.

A former coworker gave me my favorite verb for this: **incorrecting**. It means correcting someone, with confidence, into a less correct answer.

This example is funny because the correct answer is obvious to a human who slows down for half a second. There are zero `p`s in `Florent`.

But the more interesting lesson is not "LLMs make mistakes."

The lesson is about where intelligence should live.

Ask the model the question directly and you are asking it to be an oracle. You are delegating the answer.

Ask it something else instead:

> Write a small script that uses regex to count all occurrences of a given letter, case insensitive, in a given string.

Now the model succeeds beautifully.

The script is readable. The logic is inspectable. The output is deterministic. If you do not trust it, you can change three lines and rerun it.

Notice what changed.

You did not ask the AI to know the answer.

You asked it to build a machine that discovers the answer.

That is a profoundly different use of intelligence.

The first approach asks the model to be correct. The second asks the model to produce an artifact whose correctness can be checked by something outside the model.

The first approach is fragile and non-deterministic.

The second approach is engineering.

## "The AI Can Do It" Is the Trap

The practical heuristic I keep coming back to is this:

> "The AI can do it" fails surprisingly often. "I can do it, but I do not want to write it" succeeds surprisingly often.

If I already know how to solve a problem, but do not want to spend fifteen minutes writing boilerplate, AI is incredible.

It writes the parser. It generates the regex. It scaffolds the migration. It builds the tedious API wrapper. It converts one boring data shape into another boring data shape. It saves me from typing code whose structure I already understand.

But if I ask it to simply be correct about something I have not constrained, tested, or independently understood, I am often just moving uncertainty around.

Sometimes that is fine. Exploratory work is allowed to be uncertain. Brainstorming is allowed to be messy. Drafts are allowed to be wrong.

Production systems are not.

The trick is to use the model where its mistakes are cheap, visible, and recoverable.

Good AI usage looks less like this:

> Here is my problem. Solve it.

And more like this:

> Here is a well-defined subproblem. Produce an artifact that I, a test suite, a compiler, a linter, a type checker, a database constraint, or another deterministic process can verify.

LLMs are strongest when they are part of an algorithm, not when they are the algorithm.

## From Prompting to Systems

This is also why the future of AI engineering is not just better prompts.

Prompting matters, but prompting is the assembly language of AI work. The more durable leverage comes from systems: decomposition, routing, tools, retrieval, validation, ranking, retries, observability, and human review at the right choke points.

Early programmers learned not to write enormous monolithic functions. They decomposed problems into smaller functions with clear contracts. They made state explicit. They built tests. They separated the part that guesses from the part that verifies.

We are learning the same lesson with AI.

A weak AI workflow asks the model to swallow a vague problem and emit a final answer.

A strong AI workflow breaks the problem into pieces:

- one component gathers context,
- another proposes a plan,
- another generates a patch,
- another runs deterministic checks,
- another summarizes the diff,
- and a human decides whether the result actually deserves to exist.

In that kind of system, the model is not an omniscient coworker. It is a fast, useful, occasionally unreliable component embedded inside a larger loop of tools and judgment.

That is where the leverage is.

Not in pretending the model is always right.

In arranging the work so it does not have to be.

## Expression Is Not Judgment

Calculators did not eliminate mathematicians. CAD did not eliminate mechanical engineers. Compilers did not eliminate programmers.

Each tool removed labor while increasing the value of judgment.

AI is doing something similar, but with a much broader class of expression. It can draft code, prose, diagrams, plans, tests, explanations, interfaces, and glue. That is a big deal. A huge amount of professional work consists of turning partially formed intent into communicable artifacts.

But expression was never the whole job.

The hard part is deciding what deserves to be expressed. Which abstraction will survive? Which requirement is fake? Which tradeoff matters? Which failure mode is unacceptable? Which piece of generated cleverness is actually a liability? Which simple thing should replace the impressive thing?

AI automates expression faster than it automates judgment.

That is the sentence I trust most in all of this.

It explains why demos are accelerating faster than products. It explains why experienced people often get magical results while newcomers get plausible messes. It explains why generated code can be simultaneously impressive and dangerous. It explains why software teams may ship faster without thinking less.

The typing was never the expensive part.

The expensive part was knowing what should be typed.

## The Useful Kind of Humility

None of this is an argument against using AI aggressively.

I use it constantly. I want sharper tools, longer-running agents, better code generation, better retrieval, better local models, better verification loops, and better ways to turn intent into working systems.

But the useful posture is not "AI can do my job now."

It is closer to:

> I can do this. I know what correct looks like. I would prefer not to manually perform every tedious step between here and there.

That posture keeps judgment where it belongs.

It lets the model accelerate work without becoming the final authority on whether the work is good.

The floor has risen. The ceiling may rise too. But the distance between a convincing artifact and a useful product is still real, and pretending otherwise mostly produces faster slop.

So delegate the work.

Delegate the boilerplate, the scaffolding, the translation, the first draft, the search, the mechanical transformation, the parts where mistakes are visible and cheap.

Do not delegate the answer unless you have a way to check it.

Do not delegate taste.

Do not delegate responsibility.

The future belongs less to people who believe AI can do everything than to people who know exactly which parts they should make it do.
