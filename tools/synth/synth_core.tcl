# Out-of-context synthesis of the Sodor core for the PYNQ-Z1 part.
#
# Usage:
#   vivado -mode batch -source synth_core.tcl -tclargs <srcdir> <outdir> <period_ns>
#
# Synthesizes the `Core` module only (CtlPath + DatPath + CSRFile + the
# register file, which firtool emits as its own module). The
# scratchpad memory is outside this boundary, so what is measured is the
# datapath and control logic, which is exactly what the design variants change.
#
# Fmax is not reported directly: comparing variants is done by holding the
# target period fixed and comparing worst negative slack (WNS).

set srcdir  [lindex $argv 0]
set outdir  [lindex $argv 1]
set period  [lindex $argv 2]

set part xc7z020clg400-1

file mkdir $outdir

read_verilog -sv [list \
  $srcdir/Core.sv \
  $srcdir/CtlPath.sv \
  $srcdir/DatPath.sv \
  $srcdir/CSRFile.sv \
  $srcdir/regfile_32x32.sv \
]

synth_design -top Core -part $part -mode out_of_context -flatten_hierarchy rebuilt

create_clock -name clk -period $period [get_ports clock]
set_property HD.CLK_SRC BUFGCTRL_X0Y0 [get_ports clock]

report_utilization -hierarchical -file $outdir/utilization.rpt
report_timing_summary -delay_type max -max_paths 1 -file $outdir/timing_summary.rpt
report_timing -delay_type max -max_paths 5 -nworst 5 -file $outdir/timing_paths.rpt

# machine-readable one-liner
set slack [get_property SLACK [get_timing_paths -delay_type max -max_paths 1]]
set nlut [llength [get_cells -hier -filter {PRIMITIVE_TYPE =~ LUT.*}]]
set nff  [llength [get_cells -hier -filter {PRIMITIVE_TYPE =~ REGISTER.*}]]
set fh [open $outdir/summary.txt w]
puts $fh "period_ns $period"
puts $fh "wns_ns $slack"
puts $fh "luts $nlut"
puts $fh "ffs $nff"
close $fh
puts "SYNTH_SUMMARY period=$period wns=$slack luts=$nlut ffs=$nff"
