#!/usr/bin/env bash
# Run a binary on a Sodor config and report pass/fail plus TOTAL simulation cycles.
#
# WARNING: the total includes loading the program over the serial link and the
# host handshake, which dominate and are nearly identical on every core. Do NOT
# use this number to compare microarchitectures -- use benchcycles.sh for that.
#
#   ./tools/cycles.sh Sodor5StageConfig ~/github/sodor-lab/custom-tests/mytest
#   ./tools/cycles.sh Sodor1StageConfig $RISCV/riscv64-unknown-elf/share/riscv-tests/isa/rv32ui-p-add
#
# Builds the simulator first if it does not exist yet.
set -e

CONFIG=${1:?usage: cycles.sh <CONFIG> <binary>}
BINARY=${2:?usage: cycles.sh <CONFIG> <binary>}
CHIPYARD=${CHIPYARD:-$HOME/github/chipyard}

source "$HOME/tools/miniforge3/etc/profile.d/conda.sh"
cd "$CHIPYARD"
source env.sh > /dev/null

cd sims/verilator
make -j"$(nproc)" CONFIG="$CONFIG" > /dev/null
make CONFIG="$CONFIG" run-binary BINARY="$BINARY" > /dev/null

OUT="output/chipyard.harness.TestHarness.$CONFIG/$(basename "$BINARY").out"
printf '%-28s %-24s ' "$CONFIG" "$(basename "$BINARY")"
grep -a -o "\*\*\* [A-Z]* \*\*\* Completed after *[0-9]*" "$OUT" | tail -1 \
  | sed 's/\*\*\* \([A-Z]*\) \*\*\* Completed after *\([0-9]*\)/\1  \2 total sim cycles (incl. load+handshake)/'
