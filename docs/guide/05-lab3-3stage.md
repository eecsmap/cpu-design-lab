---
layout: default
title: "Lab 3 — memory stops being magic"
parent: Lab guide
nav_order: 5
---

# Lab 3 — memory stops being magic

The 1- and 2-stage cores read instruction memory *asynchronously* — address in,
data out, same cycle. Real SRAM does not do that. The 3-stage uses **sequential**
memory: you present an address, you get data next cycle.

Read `rv32_3stage/frontend.scala`. It's the whole lesson: fetch becomes a
decoupled unit that runs ahead speculatively and gets redirected when the datapath
disagrees. The header comment lists optimizations left "as an exercise to the
reader" — those are real exercises, take one.

### Harvard vs Princeton
`Sodor3StageConfig` gives fetch and load/store separate memory ports.
`Sodor3StageSinglePortConfig` makes them share one.

### Exercise 3.1
Build both. Run the same benchmark on each. The single-port version must stall
fetch whenever a load or store is in flight — measure that structural hazard cost
in cycles. This is the clearest structural-hazard demo you will find anywhere.

---
