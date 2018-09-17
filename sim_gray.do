vlib work

vlog +cover tb_gray.v mul.v datapath_gray.v add.v shiftbuffer.v datapath_histogram.v

vsim -novopt work.tb_gray

add wave -position insertpoint sim:/tb_gray/dut/*

run -all
