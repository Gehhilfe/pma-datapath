vlib work

vlog +cover sobel_tb.sv sobel_gx.sv sobel_gy.sv add.v add3.v

vsim -coverage work.tbench_top

log -r *

run
