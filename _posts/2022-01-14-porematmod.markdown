---
layout: post
title:  "PoreMatMod.jl: Chemical Substructure Find/Replace"
date:   2022-01-14 00:00:00 -0800
---

![PoreMatMod.jl Logo](/assets/img/porematmod_logo.jfif)

[PoreMatMod.jl][porematmod-pub] is a [Julia][julialang] package for chemical structure 
modification based on subgraph-search and point-cloud-alignment algorithms.
The original purpose was generation of hypothetical MOFs, but use cases
extend to various other molecular and atomistic contexts, several of which
are exemplified in the [documentation][porematmod-docs].

The [code][porematmod-github] is designed to be simple to use, even by scientists 
with limited computational chemistry or programming experience:

{% highlight julia %}
using PoreMatMod
parent = Crystal("IRMOF-1.cif")
pattern = moiety("p-phenylene.xyz")
fragment = moiety("CF3-phenylene.xyz")
new_xtal = replace(parent, pattern => fragment)
{% endhighlight %}

There is also an in-browser GUI for those who don't have time for any coding at all:

{% highlight julia %}
using PoreMatMod
PoreMatModGo()
{% endhighlight %}

[julialang]: https://julialang.org/
[porematmod-pub]: https://pubs.acs.org/doi/10.1021/acs.jcim.1c01219
[porematmod-docs]: https://SimonEnsemble.github.io/PoreMatMod.jl
[porematmod-github]: https://github.com/SimonEnsemble/PoreMatMod.jl
