---
layout: post
title: "Cloverleaf: The Research Should Continue Into the Paper"
date: 2026-09-08 09:00:00 -0700
description: "I wanted to turn an agent-coordinated research project into a paper without leaving the local environment where the work already lived."
tags: [ai, agents, open-source, latex, local-first]
---

I did not set out to build a LaTeX editor.

I was working on a research project. The work already had an agentic rhythm: I used an AI agent to coordinate the investigation, inspect the project, help run down questions, and keep the different parts moving together. Eventually the research reached the stage research is supposed to reach. I needed to stop accumulating findings and write them up as a paper.

That should have been a change in the work, not a change of worlds.

I used to use Overleaf, and the obvious move was to create a project there. But I had never been especially happy with its cloud-storage model or its third-party integrations. More importantly, moving the paper into Overleaf would have separated the writing from the environment where the research had happened. The files, context, tools, and agent that already understood the project were local. The manuscript would become a new cloud artifact, and my AI collaborator would be reduced to whatever context I could shuttle into and out of another interface.

I did not want a new collaborator for the writing stage. I wanted to continue working with the one that had helped coordinate the research.

So I built [Cloverleaf](https://github.com/eahenle/cloverleaf): the subset of Overleaf I actually wanted, integrated with the agentic environment where I already work.

## The paper is the next stage of the research

It is easy to treat “do the research” and “write the paper” as separate tasks. Operationally, they often are. Research happens in repositories, notebooks, scripts, data directories, terminal sessions, and conversations. Then the result is exported into a document system, where the writing begins with a mostly blank page and a surprisingly incomplete account of how anyone reached it.

But a paper is not packaging applied after the intellectual work is done. Writing exposes missing evidence, vague claims, bad organization, and conclusions that seemed stronger before they had to survive a paragraph. The manuscript sends you back into the project. The project changes what the manuscript can say. This is still the research loop.

An agent that helped coordinate the investigation is unusually useful at this point. It can inspect the same source material, recover why a decision was made, compare a claim against the implementation, trace a result back to the relevant file, and notice that the draft has simplified away an important qualification. Starting over in a generic writing assistant throws away precisely the continuity that makes an AI collaborator valuable.

The problem I wanted Cloverleaf to solve was therefore not “put a chatbot next to LaTeX.” It was:

> How do I carry the existing research partnership into the manuscript without giving up the writing interface I need?

That framing made most of the product decisions easier.

## The Overleaf functionality I actually use

I did not need to reproduce a cloud collaboration company. I needed a desktop-oriented research-writing workbench.

Cloverleaf has a project tree, a CodeMirror editor, live compilation, a PDF preview, and compiler diagnostics. The layout is deliberately familiar: files on the left, source and rendered paper in the middle, assistant on the right. Edit a `.tex` file and Cloverleaf autosaves it, recompiles the manuscript, and refreshes the PDF while approximately preserving the page position I was reading.

The application can load an existing local manuscript rather than importing it into a proprietary store. A project remains an ordinary directory containing `.tex`, `.bib`, style, and asset files. Git works. Terminal tools work. Scripts can regenerate tables. Another editor can open the same files. Cloverleaf participates in the local project instead of becoming the place from which the project must be exported.

This is the part of the Overleaf experience I wanted: a good source-and-PDF loop that removes LaTeX's mechanical friction. I did not want its storage model to become the new center of the research project, and I did not want the agent bolted on through a third-party integration with a partial view of the work.

The agent should begin where the research already is.

## Not a fresh chat with a pasted excerpt

The most common AI writing workflow is a context migration performed by hand. Copy a few paragraphs into a chat box. Explain what the document is. Paste back a revision. Discover that it broke a citation or used a term inconsistently. Add more context and try again.

This turns the author into a synchronization protocol between the manuscript and the model.

It also discards the main advantage of the agentic environment I was already using. My research agent did not need me to serialize an entire project into one prompt; it could start in the project and inspect what mattered. Cloverleaf preserves that mode of work.

The assistant receives the immediate authoring context: the active workspace and compilation root, open file, selected text, build state, structured diagnostics, and a bounded compiler-log tail. Then Codex starts in the manuscript directory with read-only tools. If the selected paragraph depends on an earlier definition, an included section, a bibliography entry, or a result elsewhere in the repository, the agent can go find it.

The browser does not have to guess which files will matter and upload their contents on every turn. The author does not have to paste the whole intellectual history into a new conversation. The project remains the shared context.

There is also a useful middle ground between selecting a paragraph and asking the agent to explore the whole repository. I can explicitly attach up to twenty visible project files to a turn. The browser sends their paths—not a second, potentially stale copy of their contents—and the backend validates those paths and reads the authoritative files before calling Codex. That makes it easy to say, in effect, “revise this section with this result, this table, and these notes in view,” while keeping file access inside the same workspace boundary. The attachment picker clears after the message is sent, so each bundle of extra context is an intentional part of a particular request rather than ambient context that silently accumulates.

This is a small architectural difference with a large experiential effect. I can ask a question about the paper and continue the same kind of collaboration I used during the investigation: inspect the work, establish what is true, then make the artifact better.

## The response should be an edit

Continuity does not mean the agent should be able to rewrite the manuscript silently.

Cloverleaf gives Codex broad read access inside the selected workspace, but no direct write access. When a request requires a document change, the assistant returns a structured proposal with two separate channels:

1. a short conversational message explaining the result; and
2. compact, exact-text replacements describing the file changes.

The backend validates every proposed path against the workspace boundary. Each old-text fragment for an existing file must match exactly once. Cloverleaf expands those replacements into complete review content, records the version of the file the agent inspected, and presents a before-and-after card in the browser.

Only my confirmation writes the change.

Confirmed changes also become local Git checkpoints. Cloverleaf initializes a repository for a project that does not already have one, establishes a baseline where necessary, and commits only the precise paths changed by the confirmed operation. It leaves unrelated staged work and existing ignore rules alone, and it never contacts a remote. The review card is therefore not the only record of what the agent changed; the manuscript itself keeps a local, inspectable history.

This avoids the strange middle ground where an “integrated” assistant still responds with a large LaTeX block that I must manually transplant into the real document. If I ask the agent to state the contribution earlier, completion means a reviewable change against the introduction—not suggested wording floating in a transcript.

It also protects the live writing loop. If I keep typing while the agent works, its proposal is based on an older file. The version check rejects the stale edit rather than overwriting newer work. If a request needs several files, Cloverleaf validates the entire accepted set before writing any of them, applies the set together, and compiles once.

The useful asymmetry is this: **the agent can read enough to reason across the research project while earning write access one visible change at a time.**

## The compiler is part of the collaboration

Writing a LaTeX paper produces a kind of feedback that ordinary chat interfaces rarely see. A revision can be rhetorically better and syntactically broken. It can refer to a missing label, misuse a project-specific command, or compile while moving a figure somewhere absurd.

Cloverleaf keeps compilation inside the same loop. The backend serializes and coalesces `latexmk` jobs, parses common diagnostics, and retains the latest successful PDF. The agent receives the current build state, structured errors, and compiler-log context with its request.

When a build fails, **Fix with Codex** turns those diagnostics into an assistant request and returns the proposed repair through the same review flow. I can also make any open `.tex` file the compilation root, including a source in a subdirectory, and save a successful PDF through the browser. These are small affordances, but together they make the build a first-class part of authorship rather than a command I periodically remember to run.

That does not guarantee that every proposed edit compiles. It means a compiler failure becomes evidence available to the same collaborator that proposed the change.

This is part of the larger continuity I wanted. The agent should not only remember the conceptual work and then become blind to the authoring environment. It should be able to move between prose, project files, and build feedback as the paper develops.

The human interface needs continuity too. A successful build refreshes the rendered PDF without throwing me back to page one. Agentic software can perform impressive reasoning and still be miserable to use if every useful action destroys the author's place in the document.

## Local-first is an integration strategy

“Local-first” describes storage, but in Cloverleaf it also describes how the pieces meet.

The filesystem is the integration layer between the manuscript, the research project, ordinary development tools, and the agent. There is no document database that must be synchronized back into the repository. The application watches the open file over a WebSocket: clean external changes reload automatically, while an external change that conflicts with unsaved editor text pauses autosave and preserves what I was writing for review.

Project switching is similarly explicit. The backend validates the new manuscript root, waits for an active build, persists the choice locally, constructs a new workspace and compiler, and rebinds the assistant before exposing the project as active. The editor, compiler, and agent should never disagree about which body of research they are working on.

Cloverleaf can load an existing project or initialize a new one from the same local folder browser. Each project carries its own Codex transcript and unresolved review cards in local application state, so switching manuscripts or restarting the server does not turn a continuing collaboration into a fresh chat. Assistant turns can be queued while one is running, paused behind edits that still need review, or cancelled without letting queued follow-ups immediately restart the work.

Cloverleaf itself is a two-process application managed by a small launcher. React and Vite provide the workbench. FastAPI owns filesystem access, compilation, runtime control, and the assistant provider. The frontend talks to narrow JSON and WebSocket APIs; it does not receive provider credentials or arbitrary host-filesystem access. Inside the interface, status and terminal views expose bounded operational information, and explicit controls can restart or shut down the supervised local services without turning the browser into a general-purpose shell.

By default, the backend uses the official Codex Python SDK and the machine's existing Codex CLI authentication. That lets Cloverleaf join the authenticated agentic environment already on the machine rather than asking me to put another long-lived secret into a browser integration.

## The boundary is intentionally modest

Cloverleaf is “Overleaf at home,” not a local reimplementation of everything Overleaf does.

It binds to localhost. File APIs reject traversal forms, symlink escapes, access to Git internals, and generated LaTeX artifacts; assistant attachments are limited to visible project files. The backend invokes `latexmk` with a fixed argument list, without a shell or shell escape. Codex runs server-side in a read-only sandbox, and only Cloverleaf's confirmed apply path writes assistant proposals.

These are useful boundaries, but they do not turn a local LaTeX compiler into a secure service for hostile documents. TeX itself is not sandboxed. Cloverleaf assumes the manuscript is trusted. It has no authentication, real-time collaboration, remote Git synchronization, or production multi-user deployment.

That scope is deliberate. I wanted to continue one local research project into its writing stage. The shortest route was not to recreate an entire cloud platform. It was to build the focused source, compilation, preview, and review surfaces that let my existing tools—and my existing AI collaborator—stay involved.

## Do not reset the collaboration at the blank page

The most important thing Cloverleaf preserves is not a file format or a layout. It is accumulated context.

Research develops a history. The useful artifacts include code and results, but also rejected approaches, qualifications, definitions, and the chain of decisions that made the conclusion defensible. An agent involved in that process can help turn it into a paper because the writing stage is another pass over the same body of work.

Moving to a disconnected document service would have made the manuscript neatly separate and intellectually poorer. I would have gained a writing surface and lost the environment that knew what I was writing about.

Cloverleaf keeps those together. I get the local LaTeX workbench I wanted. The agent can inspect the research behind the prose. Its changes arrive as diffs I can understand and approve. The compiler reports whether the document still works. Then the rendered paper refreshes and the collaboration continues.

I did not need AI added to Overleaf.

I needed the research environment I already had to grow an Overleaf-shaped writing surface.
