#!/usr/bin/env bash
# Measure the cycles a core spends between two labels in a program.
#
#   ./tools/benchcycles.sh Sodor5StageConfig custom-tests/hazard_bench
#
# Unlike the simulator's "Completed after N cycles" line -- which is dominated by
# program load over the serial link and the host handshake, and is therefore
# nearly identical on every core -- this reads the commit trace and measures only
# the region between the `bench_start` and `bench_end` symbols.
set -e

CONFIG=${1:?usage: benchcycles.sh <CONFIG> <binary> [start_sym] [end_sym]}
BINARY=$(readlink -f "${2:?usage: benchcycles.sh <CONFIG> <binary>}")
START_SYM=${3:-bench_start}
END_SYM=${4:-bench_end}
CHIPYARD=${CHIPYARD:-$HOME/github/chipyard}

source "$HOME/tools/miniforge3/etc/profile.d/conda.sh"
cd "$CHIPYARD"; source env.sh > /dev/null

START_PC=$(riscv64-unknown-elf-nm "$BINARY" | awk -v s="$START_SYM" '$3==s{print $1}')
END_PC=$(riscv64-unknown-elf-nm   "$BINARY" | awk -v s="$END_SYM"   '$3==s{print $1}')
[ -n "$START_PC" ] && [ -n "$END_PC" ] || { echo "could not find $START_SYM / $END_SYM in $BINARY" >&2; exit 1; }

cd sims/verilator
make -j"$(nproc)" CONFIG="$CONFIG" > /dev/null
make CONFIG="$CONFIG" run-binary BINARY="$BINARY" > /dev/null
OUT="output/chipyard.harness.TestHarness.$CONFIG/$(basename "$BINARY").out"

# First cycle at each PC, and how many instructions actually committed in between.
# Only committed instructions (the [1] flag) count: a pipelined core also prints
# instructions it fetched speculatively and then killed, and matching those would
# stop the measurement on the loop's very first not-taken fall-through.
read -r c0 c1 committed < <(awk -v spc="$START_PC" -v epc="$END_PC" '
  $1 == "Cyc=" {
    cyc = $2
    valid = ($3 == "[1]")
    pc = $4; gsub(/^pc=\[|\]$/, "", pc)
    if (valid && pc == spc && c0 == "") c0 = cyc
    if (c0 != "" && c1 == "" && valid) n++
    if (valid && pc == epc && c1 == "") c1 = cyc
  }
  END { printf "%s %s %s\n", c0, c1, n+0 }' "$OUT")

[ -n "$c0" ] && [ -n "$c1" ] || { echo "labels never reached in trace" >&2; exit 1; }
cycles=$((c1 - c0))
printf '%-26s %-18s %7d cycles  %6d instructions  CPI %.2f\n' \
  "$CONFIG" "$(basename "$BINARY")" "$cycles" "$committed" \
  "$(echo "$cycles $committed" | awk '{print $1/$2}')"
