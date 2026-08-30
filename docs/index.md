---
layout: default
title: Home
nav_order: 1
---

# CPU Design Lab

Notes, tools and measurements from learning processor microarchitecture the
hands-on way: build the core, run real programs on it, measure what it actually
does, then read the source to explain the number.

The spine is the **Berkeley Sodor collection** — five RV32I cores that implement
the same instruction set with five different microarchitectures, from an
unpipelined design that reads like a specification through to a micro-coded
machine. They run inside [Chipyard](https://github.com/ucb-bar/chipyard), which
also supplies Rocket and BOOM for later.

## Start here

| If you want to… | Go to |
|---|---|
| Rebuild the environment on a new machine | [Setup]({{ site.baseurl }}/setup.html) |
| Work through the labs in order | [Lab guide]({{ site.baseurl }}/guide/) |
| Look up something we already figured out | [FAQ]({{ site.baseurl }}/faq/) |
| See measured numbers and how they were obtained | [Measurements](https://github.com/eecsmap/cpu-design-lab/tree/main/measurements) |

## Why these cores

All five Sodor cores implement the same ISA and differ *only* in
microarchitecture, so the design space is visible with everything else held
constant. And they are small enough to hold in your head:

| Core | Lines of Scala |
|---|---:|
| 1-stage | 690 |
| 2-stage | 694 |
| 3-stage | 1,098 |
| 5-stage | 1,063 |
| micro-coded | 1,237 |

For scale: the Rocket core is 1,388 lines (13,865 counting its caches and MMU),
and BOOM v4 is 19,376 lines on top of the whole rocket-chip substrate. Sodor is
the only one of the three you can read completely.

## What's in the repo

```
docs/           this site — setup, lab guide, FAQ
tools/          benchcycles.sh, cycles.sh
custom-tests/   assembly test programs that run on the cores
measurements/   experimental results, each tied to a commit
```
