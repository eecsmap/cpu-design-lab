---
layout: default
title: "The five cores"
parent: Lab guide
nav_order: 1
---

# The five cores

All five implement the **same ISA** — RV32I with just enough M-mode privileged
support to take traps. They differ *only* in microarchitecture. That is the whole
point: you can read all five and see the design space of "how do I actually build
this" with the ISA held constant.

| Core | Chipyard config | What it teaches |
|---|---|---|
| 1-stage | `Sodor1StageConfig` | The ISA itself. No pipeline. Reads like a spec. |
| 2-stage | `Sodor2StageConfig` | Your first pipeline: register between stages, branch redirect, kill. |
| 3-stage | `Sodor3StageConfig` | Synchronous (sequential) memory — real SRAM timing, not magic async reads. |
| 3-stage, 1 port | `Sodor3StageSinglePortConfig` | Princeton vs Harvard: one memory port shared by fetch and load/store. |
| 5-stage | `Sodor5StageConfig` | The classic. Hazards, forwarding, load-use stalls. |
| micro-coded | `SodorUCodeConfig` | A bus + microcode ROM. How CPUs were built before pipelining won. |

Common shape of every core: a **control path** (`cpath.scala`) and a **data path**
(`dpath.scala`) that talk over an explicit bundle. This separation is the single
most valuable habit Sodor will teach you.

Diagrams for the cores are in `$LAB/docs/reference-pdfs/`
(`1stage.pdf`, `2stage.pdf`, `sodor.pdf`, and `lab1.pdf`, the original CS152 lab).

---
