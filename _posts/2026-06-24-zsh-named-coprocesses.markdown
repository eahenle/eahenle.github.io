---
layout: post
title:  "zsh Only Supports One Coprocess? No. That Will Not Do."
date:   2026-06-24 09:00:00 -0700
description: "A technical note on co-proc, a small zsh layer that turns native coprocesses into named, simultaneous shell services without replacing zsh's native coproc syntax."
---

zsh has a useful feature hiding in plain sight: `coproc`.

A coprocess is just a process connected to the shell by pipes in both directions.
The shell can write to the process's stdin and read from its stdout. That makes
it a natural fit for calculators, interpreters, protocol adapters, local test
services, and anything else that should stay warm while a shell script talks to
it.

The strange part is not that zsh has coprocesses.

The strange part is that zsh exposes only one active coprocess through the
special `p` redirection target.

```zsh
coproc bc -l
print -r -- '2 ^ 10' >&p
read -r answer <&p
```

That works. But if you start another coprocess, `p` moves. The old process may
still exist, the operating system is perfectly capable of handling more pipes,
and nothing fundamental has run out. The shell abstraction simply stopped at
"the current coprocess."

That felt too small.

## The Trick

The core idea behind [`co-proc`](https://github.com/eahenle/co-proc) is that
`p` does not need to remain special forever.

Immediately after starting a native zsh coprocess, `co-proc` duplicates the
current `p` descriptors into ordinary numbered file descriptors:

```zsh
coproc COMMAND
exec {outfd}<&p
exec {infd}>&p
```

Those numbered descriptors remain usable even after zsh retargets `p` for a
later coprocess.

Once you have that, the rest is bookkeeping:

- store `outfd`, `infd`, and the child process id,
- key them by a user-provided name,
- provide commands to send, read, list, switch, stop, wait, and prune,
- and clean everything up when the shell exits.

The result is a small sourceable zsh layer for named, simultaneous
coprocesses.

```zsh
source ./co-proc.zsh

co-proc start calc bc -l
co-proc start echo cat

co-proc send calc '2 ^ 16'
co-proc send echo 'hello'

co-proc read -t 1 calc
co-proc read -t 1 echo

co-proc stop calc
co-proc stop echo
```

This is not a new process model. It is native zsh plus descriptor ownership.

## Why Not Replace `coproc`?

The tempting design was to make a shell function named `coproc` and extend the
syntax directly:

```zsh
coproc calc bc -l
coproc send calc '2 ^ 10'
coproc read calc
```

But `coproc` is not an ordinary command in zsh. It is parsed as a reserved word.
That matters because native forms like these are grammar, not function calls:

```zsh
coproc bc
coproc { cat }
coproc while read -r line; do print -r -- "$line"; done
```

If `co-proc` replaced `coproc`, it would break exactly the native syntax it was
trying to build on. That was the wrong trade.

So the project splits the interface in two:

- `co-proc ...` is the explicit, scriptable API.
- `coproc ...` remains native zsh.
- Interactive users can opt into a conservative ZLE rewrite for simple extended
  forms.

With the optional interactive layer enabled:

```zsh
co-proc enable-zle

coproc calc bc -l
coproc send calc '2 ^ 10'
coproc read calc
```

The rewrite intentionally avoids complex shell syntax. Lines with redirections,
pipes, separators, grouped commands, or control words are left alone. Native
zsh remains native.

That constraint is the point. Compatibility is a feature.

## Where It Helps

Named coprocesses are most useful when startup cost, state, or protocol context
matters.

For a tiny example, `bc -l` becomes a persistent calculator:

```zsh
co-proc start calc bc -l

co-proc send calc 'scale=4; 22 / 7'
co-proc read -t 1 calc

co-proc stop calc
```

A Python snippet can become a small line-oriented service:

```zsh
co-proc start upper python3 -u -c '
import sys

for line in sys.stdin:
    print(line.rstrip().upper(), flush=True)
'

co-proc send upper 'hello'
co-proc read -t 1 upper
co-proc stop upper
```

The same pattern works for database shells, local protocol adapters, model or
agent servers, and test fixtures. Start the thing once, keep it alive, and talk
to it by name.

For structured protocols, the right move is usually to wrap `co-proc send` and
`co-proc read` in small domain-specific helper functions so callers do not have
to think about raw line ordering.

## What I Like About This Solution

The satisfying part of `co-proc` is that it does not require zsh to grow a new
primitive.

The primitive was already there.

The missing piece was ownership. zsh owns one moving `p` handle. `co-proc`
captures the underlying descriptors before they move, gives them names, and
tracks their lifecycle.

That makes the feature feel larger without making the shell less itself.

There is a broader lesson here that shows up often in systems work: sometimes a
feature is not missing because it is impossible. Sometimes the available
abstraction stopped one layer too early.
