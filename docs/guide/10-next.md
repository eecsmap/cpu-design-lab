---
layout: default
title: "Where this goes next"
parent: Lab guide
nav_order: 10
---

# Where this goes next

Sodor is deliberately unrealistic in one way: no caches, no virtual memory, no
external DRAM — just a scratchpad. Once the 5-stage makes sense, the same Chipyard
tree gives you the real thing:

- **Rocket** (`generators/rocket-chip`) — in-order, 5-stage, with real caches, an
  MMU, and full privileged support. `make CONFIG=RocketConfig`.
- **BOOM** (`generators/boom`) — out-of-order superscalar. Register renaming,
  issue queues, a reorder buffer, branch prediction.

The step from Sodor's 5-stage to Rocket is mostly *memory system*. The step from
Rocket to BOOM is *instruction-level parallelism*. Take them in that order.

And you already have the last mile: this repo tree also contains your PYNQ-Z1
work. Getting a Sodor or Rocket core onto that board closes the loop from Chisel
source to real silicon-adjacent hardware.

---
