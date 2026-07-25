---
layout: post
title: "The Room Between the Voices"
date: 2026-07-25 14:00:00 -0700
description: "Designing HermanoAgents around timing, selective attention, interruptions, silence, and the operational state of a synthetic group chat."
---

The idea began, as respectable systems architecture often does, with a group chat making jokes.

Someone suggested training AI versions of the people in the chat. The obvious implementation was easy to imagine: collect enough messages from each participant, produce a persona prompt or LoRA for each one, put the resulting bots in a shared channel, and let them talk. Give every model the right verbal fingerprints and perhaps the simulation would feel like the original group.

That version might clone several voices. It would not clone the chat.

A group conversation is not merely a bag of people with recognizable prose styles. It has timing, rhythm, selective attention, dormant threads, interruptions, reactions, crossed messages, and silence. It has an intuitive sense of whether the room can tolerate one more subject right now. It remembers who has been talking, who has gone quiet, which joke is still alive, and which argument everyone is carefully stepping around.

This is the more interesting design problem behind **HermanoAgents**, a proposed system for simulating an ongoing multi-person group chat. The central claim is simple: the system can be mechanistically nonhuman while remaining behaviorally human. Humans coordinate conversation through distributed attention, inhibition, familiarity, social prediction, and awareness of the room. HermanoAgents makes a compiled approximation of some of that invisible coordination explicit.

It calls that approximation the **Conductor**.

The Conductor is not a puppetmaster. It does not put opinions into anyone's mouth or compose a joke and hand it to the funniest participant. It represents room-level state and manages access to the floor. The participants still decide whether they care, whether they have anything worth saying, and what their words will be.

## Three kinds of agency

HermanoAgents divides the job among three components: the Scout, the Conductor, and the Hermanos.

The **Scout** looks outward. It notices events that could inspire a new thread: news, technical releases, project activity, media, and personal developments from explicitly authorized sources. Its output is structured stimulus rather than prose for the group. It might report that a new model was released, why the release is timely, and which known interests it touches. It does not decide who should speak. It does not decide whether now is a good moment. It certainly does not write the eventual post.

The **Conductor** looks at the room. It tracks conversational pace and tone, active and dormant threads, recent participation, interruption cost, and the group's apparent appetite for novelty. When the Scout brings it an event, the Conductor asks whether the chat can absorb a new topic at all. If so, it identifies plausible participants, offers them the opportunity, and resolves simultaneous interest. This is floor management, not authorship.

The **Hermanos** are the participant models. Each has its own learned or prompted attention patterns, interests, relationships, and written voice. An Hermano decides whether an offered event matters to it; whether it has an angle worth adding; whether it would bring that subject to this particular group; and whether to bid, pass, react, defer, or withdraw. If it ultimately speaks, it realizes the message in its own voice.

That separation prevents a subtle architectural collapse. If the Scout chooses a person, the Scout becomes a casting director. If the Conductor supplies the substance of a response, the Conductor becomes the real author. HermanoAgents gives each component less power so the simulated participants can retain meaningful autonomy.

## The new-thread protocol

For a newly observed event, the order of operations is the design:

```text
1. Scout observes and structures an event.
2. Conductor decides whether the room is ready.
3. Conductor offers the event to plausible Hermanos.
4. Hermanos independently bid or pass.
5. Conductor performs a light final allocation gate.
6. One or more Hermanos receive soft grants.
7. Each granted Hermano waits a stochastic pre-authoring interval.
8. On waking, each sees the conversation as it exists now and re-evaluates.
9. It may open, bridge, reply, react, pass, or withdraw.
10. If it proceeds, inference begins.
11. Once inference begins, its context is fixed.
12. Inference streaming supplies the typing latency.
```

The first Conductor gate must happen before the Hermanos bid. The room first decides whether a new topic is welcome; only then do relevant people spend attention deciding whether they personally care. Otherwise every external stimulus wakes every persona, or some upstream router appoints an announcer without regard for the conversation already in progress.

“Interesting” is not a universal property of an event. Two people can care for different reasons. A third may be the obvious topical match but have nothing worth saying. A fourth may care deeply and still know that this is not a subject they would bring to this group. Bidding after the room-level gate preserves those distinctions, including the participant's ability to pass.

The final Conductor gate should be perfunctory. It resolves contention, notices changes in conversational state, and prevents three nearly identical openings when that would feel wrong. It can also grant several complementary bids when a pile-on would feel entirely right. What it cannot do is write the joke, opinion, or argument. Allocation should remain allocation.

## Inspiration context is not authorship context

The crucial temporal distinction is between the state that inspires a message and the state in which the message is finally written.

An Hermano may bid because a particular conversational moment makes an event seem irresistible. But it does not begin authoring immediately. A stochastic pre-authoring delay creates a window in which the world of the chat can move. Someone may post. The topic may turn serious. Another participant may introduce the same event. A better bridge may appear. The original opening may become redundant or suddenly tasteless.

Consider a concrete run:

> **11:02** — The Scout observes an AI release.  
> **11:05** — The Conductor decides the room is ready and offers it to two Hermanos.  
> **11:05** — Both bid.  
> **11:06** — Both receive soft grants with different delays.  
> **11:08** — The first begins authoring.  
> **11:09** — An unrelated message appears.  
> **11:10** — The second begins authoring and sees that new message.  
> **11:11** — The first message appears, generated from its older context.  
> **11:12** — The second bridges from the intervening message, turns its opener into a reply, or withdraws.

At 11:10, the second Hermano is not obligated to fulfill the intention it formed at 11:05. It re-evaluates against the current room. The first Hermano, however, does not magically absorb the 11:09 message after inference has begun. Its causal history has already forked.

This gives the chat crossed messages and imperfect coordination without asking the Conductor to sprinkle in synthetic disorder. The mess emerges from ordinary concurrency: different actors make decisions from different snapshots, then their outputs arrive in an order no one completely controlled.

That is socially normal. The mechanism is not human, but the effect is. Real chats are full of messages that were sensible when someone began typing and slightly strange by the time they landed.

## One delay, not two

The only synthetic timing mechanism needed here is the stochastic delay **before authoring starts**.

Once inference begins, model execution and streaming already take time. That duration tends to scale with the generated response, producing the functional equivalent of typing latency. Adding another randomized “typing…” delay after generation would add theater without improving causality.

More importantly, the inference boundary prevents retroactive conversational omniscience. A message that arrives after generation starts is not incorporated into the output merely because it arrived before the output finished streaming. The Hermano writes from the context it actually saw when it began. Longer responses remain exposed to more intervening activity, just as they should.

## A grant is not a command

A turn offer is not an order. A bid is not an irreversible commitment. A grant is a soft lease on the floor, not a command to fill it.

An Hermano may pass when first offered an event. After bidding and waiting, it may withdraw because the moment has changed. It may downgrade a planned thread starter to a reaction, defer to someone else, or convert its idea into a reply. Silence is a valid outcome, not a routing failure.

The same principle applies to ordinary reactive conversation. When a message seems to invite one or more participants, the Conductor can offer them the floor. A selected Hermano can answer, react, defer, or decline. This matters because believable people do not merely possess distinctive things to say; they possess distinctive thresholds for saying them.

## Concurrency without choreography

The Conductor may grant the same event to more than one Hermano. Different pre-authoring delays can then yield sequential adaptation, crossed messages, complementary pile-ons, redundant posts, withdrawal, or a thread starter transformed into a reply.

The goal is not chaos as decoration. It is to avoid the polished, serialized quality of a single omniscient author writing every participant in turn. In that design, every message perfectly incorporates every previous message because the author sees the total sequence. The result can be witty and coherent while feeling nothing like a group chat. Nobody steps on anyone. Nobody independently reaches the same conclusion. Nobody posts the setup to a joke that has already moved on.

A real group contains overlapping causal histories. Several people can begin from one shared state, develop different intentions in parallel, and publish into states none of them individually selected. Soft grants allow the system to preserve that structure without surrendering all floor control.

## Six tempting ways to get it wrong

The simplest alternative is to let every persona monitor every event and decide whether to post. That maximizes local autonomy at the cost of compute, noise, and a peculiar culture in which agents constantly campaign for airtime. Most events should not interrupt most rooms.

Letting the Scout assign an event directly to a persona is cheaper, but it bypasses the room-level timing decision. The selected participant becomes an announcer whose job is to deliver routed content, whether or not the chat is ready.

Letting the Conductor tell a persona exactly what to say is cleaner still—and quietly fatal. The Conductor becomes a centralized author while the Hermanos become voice filters. Their apparent agency is cosmetic.

A fixed round-robin speaker order solves contention by destroying selective participation. It treats silence as a missing turn and presence as an obligation. Human groups do neither.

One global model writing every participant sequentially can produce excellent dialogue, but it also produces suspiciously composed dialogue. Each turn is written with complete knowledge of the preceding one, so the room behaves like a screenplay rather than concurrent messaging.

Finally, post-generation typing delays imitate a user-interface cue while leaving the causal model untouched. If the output was already generated from an earlier snapshot, waiting longer does not make it more socially situated. Inference already provides the latency that matters.

## Does attention belong to the voice?

One unresolved question is how much of a participant should live in one model adaptation.

A single persona adapter might learn both conversational attention and written voice: what this person notices, when they participate, and how they phrase the result. A more modular system could use two LoRAs, one aimed at participation and attention and another at written realization. A still cleaner separation could use two stages or agents, with one deciding interest and intent and another expressing that intent in the participant's voice.

There is an alluring story in which early transformer layers are “thought” and later layers are “voice,” making the split a matter of attaching adapters at different depths. It is a hypothesis worth testing, not an architectural fact. Representations are distributed, layer roles vary, and convenient metaphors can outrun evidence.

Fortunately, the orchestration design does not depend on settling this question. A sensible V1 can use a simpler participant model, log its offers, bids, withdrawals, and realized messages, and evaluate the failure modes. If Hermanos notice the wrong things, speak too often, or produce generically on-brand prose, then the evidence supports splitting attention from realization. Modularity should answer an observed problem, not an aesthetic craving for more boxes.

## The room as operational state

To simulate a social group, modeling individuals independently is not enough. The group has an operational state: what is alive, what is exhausted, what can be interrupted, who has recently dominated, whether the room wants another subject, whether silence is comfortable, and whether two people are likely to collide.

This does not require claiming that the group has a separate consciousness hovering above its members. Much of what humans call “reading the room” is already an informal estimate of distributed signals. The Conductor is a practical representation of those signals—a compiled approximation of the room that makes timing and access decisions explicit while leaving meaning and language local.

That may be the most interesting part of HermanoAgents. Cloned voices are the obvious demo. The harder and more revealing work is modeling the shared space in which those voices sometimes speak, sometimes overlap, and often decide not to.

The Scout notices the world.  
The Conductor decides whether the room can entertain it.  
The Hermanos decide whether it moves them.  
Time changes the context.  
The Hermanos still own the words.
