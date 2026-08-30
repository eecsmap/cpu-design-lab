# A microbenchmark for measuring the cost of pipeline hazards.
#
# The inner loop is a chain of *dependent* adds: every instruction needs the
# result of the one immediately before it. That is the worst case for a pipeline
# without forwarding, and the best case for showing what forwarding buys.
#
# `bench_start` and `bench_end` bracket the region to measure; benchcycles.sh
# finds the cycle numbers at those two PCs in the commit trace and subtracts.

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  li s0, 200          # iteration count
  li a1, 1

  .global bench_start
bench_start:
1:
  add  a2, a1, a1     # each add depends on the previous one
  add  a3, a2, a2
  add  a4, a3, a3
  add  a5, a4, a4
  add  a6, a5, a5
  add  a7, a6, a6
  add  a1, a7, a7
  andi a1, a1, 1      # keep the value from growing without bound
  addi a1, a1, 1
  addi s0, s0, -1
  bnez s0, 1b

  .global bench_end
bench_end:

  li TESTNUM, 1
  li a0, 1
  RVTEST_PASS

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
