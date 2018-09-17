vlib work

vlog +cover tb_histogram.v shiftbuffer.v mul.v add.v datapath_histogram.v

vsim -novopt work.tb_histogram

add wave -position insertpoint sim:/tb_histogram/dut/*

run -all
