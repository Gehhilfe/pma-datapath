vlib work

vlog +cover tb_gray_par.v mul.v datapath_gray_par.v add.v shiftbuffer.v datapath_histogram.v

vsim -novopt work.tb_gray

add wave -position insertpoint sim:/tb_gray/dut/*

run -all
