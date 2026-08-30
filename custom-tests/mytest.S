# Minimal RV32I test for Sodor, using the riscv-tests environment.
# Build with the Makefile in this directory, then run on a Sodor sim.
#
# Pattern: TEST_CASE(<number>, <dest reg>, <expected value>, <code>)
# The environment traps to a pass/fail routine that writes tohost.

#include "riscv_test.h"
#include "test_macros.h"

RVTEST_RV32U
RVTEST_CODE_BEGIN

  # ---- your instruction under test goes here ----

  TEST_CASE( 2, x14, 5,   li x1, 2; li x2, 3; add x14, x1, x2 )
  TEST_CASE( 3, x14, 0,   li x1, 7; li x2, 7; sub x14, x1, x2 )

  # A RAW dependence chain -- interesting on the 5-stage with and without
  # USE_FULL_BYPASSING, since every one of these stalls when interlocked.
  TEST_CASE( 4, x14, 10,  li x1, 1; add x2, x1, x1; add x3, x2, x2; \
                          add x4, x3, x3; add x14, x4, x2 )

  TEST_PASSFAIL

RVTEST_CODE_END

  .data
RVTEST_DATA_BEGIN
  TEST_DATA
RVTEST_DATA_END
