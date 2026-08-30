---
layout: default
title: "Lab 4 — hazards and forwarding"
parent: Lab guide
nav_order: 6
---

# Lab 4 — hazards and forwarding

`rv32_5stage/`. This is the canonical IF/DEC/EXE/MEM/WB pipeline.

Read in this order:
1. `cpath.scala` around the stall logic — the hazard detection.
2. `dpath.scala` around the bypass muxes — the forwarding network.

### The experiment that matters

`rv32_5stage/consts.scala` has:

```scala
val USE_FULL_BYPASSING = true  // turn on full bypassing (only stalls on load-use).
                               // Otherwise rely entirely on interlocking.
```

One boolean switches the core between *fully bypassed* and *fully interlocked*.
Both are correct; they differ in CPI and in area/critical path.

### Measuring properly

`$LAB/tools/benchcycles.sh` measures a *region* of the commit trace. It
looks up the `bench_start` and `bench_end` symbols in the ELF, finds the cycle
each one commits at, and subtracts — so program load and host handshake fall out
of the number entirely. It counts only committed instructions (`[1]`), because a
pipelined core also traces instructions it fetched speculatively and then killed.

`custom-tests/hazard_bench.S` is the workload: 200 iterations of a chain of
*dependent* adds. Every instruction needs the result of the one before it, which
is exactly the case forwarding exists to handle.

Here is the method working, and the first real result:

```
$ $LAB/tools/benchcycles.sh Sodor1StageConfig custom-tests/hazard_bench
Sodor1StageConfig          hazard_bench          2200 cycles    2201 instructions  CPI 1.00

$ $LAB/tools/benchcycles.sh Sodor5StageConfig custom-tests/hazard_bench
Sodor5StageConfig          hazard_bench          2598 cycles    2201 instructions  CPI 1.18
```

Stop and make sure this surprises you in the right way. **The 5-stage has worse
CPI than the 1-stage.** Pipelining did not reduce the instruction count or the
work per instruction — it *added* cycles, because every taken branch throws away
fetched instructions. What pipelining buys is a much shorter clock period, and
the whole bet is that the frequency gain beats the CPI loss. CPI alone never
tells you whether a design is faster.

(The 1-stage's exact 1.00 is a good sanity check on the tooling: 11 instructions
× 200 iterations = 2200 cycles, no stalls possible.)

### Exercise 4.1 — what does forwarding buy?

1. Record the 5-stage number above.
2. Flip `USE_FULL_BYPASSING` to `false` in
   `generators/riscv-sodor/src/main/scala/sodor/rv32_5stage/consts.scala`.
3. Re-run `benchcycles.sh`. The build picks the change up automatically.
4. Compute the CPI difference — then, before you look at anything else, predict
   it from the stall condition in `cpath.scala` and check whether your prediction
   matches. With bypassing, only load-use stalls. Without it, *every* RAW
   dependence stalls, and `hazard_bench` is nothing but RAW dependences.
5. Put the flag back to `true` when you are done.

Step 4 is the exercise. The number is only worth having if you can derive it.

### Exercise 4.2 — the cost side
Bypassing is not free: it adds muxes in the EXE stage's critical path. Look at
the generated Verilog for both versions and compare. If you want the real answer,
this is where your Vivado experience pays off — push both through synthesis for
the PYNQ-Z1 part and compare Fmax and LUT count. That is the actual engineering
tradeoff, and you already have the tools for it.

---
