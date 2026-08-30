# Isolated synthesis of ONE module, with submodules left as black boxes.
#
#   vivado -mode batch -source synth_isolated.tcl -tclargs <srcdir> <outdir> <top>
#
# Why isolated: synthesizing the whole `Core` buries the logic under study.
# The 32x32 register file alone is ~1100 LUTs of a ~1540-LUT design, and
# `-flatten_hierarchy rebuilt` re-attributes logic between modules arbitrarily
# (identical CSRFile RTL was reported as 438 LUTs in one variant and 590 in
# another). Only the top-level total is trustworthy there, and it is dominated
# by logic none of the design variants touch.
#
# Here only the named module's own RTL is read. Vivado treats the missing
# submodules as black boxes, so the reported LUTs are exactly the muxes, ALU,
# immediate generation and adders that the variants actually change.

set srcdir [lindex $argv 0]
set outdir [lindex $argv 1]
set top    [lindex $argv 2]

file mkdir $outdir
# black-box stubs for submodules, generated alongside by make_blackbox.py
set stubs [glob -nocomplain $outdir/stub_*.sv]
read_verilog -sv [concat [list $srcdir/$top.sv] $stubs]
synth_design -top $top -part xc7z020clg400-1 -mode out_of_context

report_utilization -file $outdir/util_$top.rpt

set nlut [llength [get_cells -hier -filter {PRIMITIVE_TYPE =~ LUT.*}]]
set nff  [llength [get_cells -hier -filter {PRIMITIVE_TYPE =~ FLOP.*}]]
set fh [open $outdir/summary_$top.txt w]
puts $fh "module $top"
puts $fh "luts $nlut"
puts $fh "ffs $nff"
close $fh
puts "ISOLATED_SUMMARY top=$top luts=$nlut ffs=$nff"
