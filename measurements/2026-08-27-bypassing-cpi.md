# Forwarding vs interlocking on the Sodor 5-stage

**Date:** 2026-08-27
**Chipyard:** 1.14.0
**riscv-sodor:** 910a2e8
**Simulator:** Verilator 5.022 (from Chipyard's conda env)
**Workload:** `custom-tests/hazard_bench.S` — 200 iterations of an 11-instruction
loop that is a chain of *dependent* adds (every instruction needs the previous
result), so nearly every pair is a RAW hazard.
**Method:** `tools/benchcycles.sh`, which measures the cycles between the
`bench_start` and `bench_end` symbols in the commit trace, counting only
committed (`[1]`) instructions. See the FAQ on why the simulator's
"Completed after N cycles" line cannot be used for this.

## Results

| Configuration | Cycles | Instructions | CPI |
|---|---:|---:|---:|
| `Sodor1StageConfig` | 2,200 | 2,201 | **1.00** |
| `Sodor5StageConfig`, `USE_FULL_BYPASSING = true` | 2,598 | 2,201 | **1.18** |
| `Sodor5StageConfig`, `USE_FULL_BYPASSING = false` | 7,998 | 2,201 | **3.63** |

The flag is at
`generators/riscv-sodor/src/main/scala/sodor/rv32_5stage/consts.scala:21`.

## Reading the numbers

**Forwarding is worth ~3.1x here.** Without it, every RAW dependence stalls, and
this benchmark is nothing but RAW dependences — so 3.63 is close to the worst
case, not a typical workload. A benchmark with independent instructions
interleaved would show much less.

**The 5-stage has worse CPI than the unpipelined core** (1.18 vs 1.00). The extra
~398 cycles is roughly 2 cycles x 200 taken branches — the squashed fetches.
Pipelining does not buy CPI; it buys clock period. Any comparison that stops at
CPI is incomplete.

**1-stage CPI is exactly 1.00**, which is the tooling sanity check: 11
instructions x 200 iterations = 2,200 cycles, and a core with no pipeline cannot
stall.

## Not yet measured

The other half of the trade-off: bypassing adds muxes to the EXE critical path.
Pushing both variants through Vivado synthesis for the PYNQ-Z1 part and comparing
Fmax and LUT count would give the frequency side. Until that exists, none of the
above says which configuration is actually *faster*.

## Reproduce

```bash
export LAB=~/github/cpu-design-lab
cd $LAB/custom-tests && make
$LAB/tools/benchcycles.sh Sodor1StageConfig $LAB/custom-tests/hazard_bench
$LAB/tools/benchcycles.sh Sodor5StageConfig $LAB/custom-tests/hazard_bench
# then flip USE_FULL_BYPASSING to false in consts.scala and re-run the last line
```
