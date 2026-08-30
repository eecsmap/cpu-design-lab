# Synthesis + place & route of the full Core, for timing.
#
#   vivado -mode batch -source impl_core.tcl -tclargs <srcdir> <outdir> <period_ns>
#
# Post-synthesis timing on this design is meaningless: the reported critical
# path was 78% "unplaced" routing estimate, and it did not even pass through
# the logic the variants change. Only after place & route are the routing
# delays real. Fmax is still not reported directly -- the target period is held
# fixed across variants and WNS compared, since an out-of-context module with
# no I/O constraints has an artificial boundary either way.

set srcdir [lindex $argv 0]
set outdir [lindex $argv 1]
set period [lindex $argv 2]

file mkdir $outdir
read_verilog -sv [list \
  $srcdir/Core.sv $srcdir/CtlPath.sv $srcdir/DatPath.sv \
  $srcdir/CSRFile.sv $srcdir/regfile_32x32.sv]

synth_design -top Core -part xc7z020clg400-1 -mode out_of_context
create_clock -name clk -period $period [get_ports clock]

opt_design
place_design
phys_opt_design
route_design

report_timing_summary -delay_type max -file $outdir/impl_timing.rpt
report_utilization -file $outdir/impl_util.rpt

set wns [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
set luts [llength [get_cells -hier -filter {PRIMITIVE_TYPE =~ LUT.*}]]
set fh [open $outdir/impl_summary.txt w]
puts $fh "period_ns $period"
puts $fh "wns_ns $wns"
puts $fh "fmax_mhz [format %.1f [expr {1000.0/($period - $wns)}]]"
close $fh
puts "IMPL_DONE period=$period wns=$wns"
