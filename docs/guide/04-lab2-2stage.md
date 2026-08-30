---
layout: default
title: "Lab 2 — what a pipeline costs"
parent: Lab guide
nav_order: 4
---

# Lab 2 — what a pipeline costs

`rv32_2stage/`. Diff it mentally against the 1-stage.

The core question to answer as you read: **when a branch is taken, the instruction
already fetched behind it is wrong. What happens to it?**

The answer is two signals. In `cpath.scala`:

```scala
val ifkill = !(ctrl_pc_sel === PC_4)   // any redirect kills the fetched instruction
```

and in `dpath.scala`, when that fires, the IF/EXE pipeline register is not written
with the fetched instruction but with `BUBBLE`:

```scala
exe_reg_inst  := BUBBLE
exe_reg_valid := false.B
```

That is the entire branch penalty: one squashed instruction, every taken branch,
because the fetch of the next instruction has already happened by the time the
branch resolves. Note `exe_reg_valid` — a pipeline register carries not just data
but *whether the data means anything*. That idea scales all the way to BOOM.

### Exercise 2.1
Write a small assembly loop with a taken branch every iteration. Count cycles on
the 1-stage vs the 2-stage. The 2-stage has a shorter critical path but pays a
branch penalty. Confirm the penalty is what you predicted from the code.

---
