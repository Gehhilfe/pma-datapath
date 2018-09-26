vlib work

vlog +cover tb_conv_seq_to_parllel.v conv_seq_to_parallel.v

vsim -novopt work.tb_conv_seq_to_parllel

add wave -position insertpoint sim:/tb_conv_seq_to_parllel/dut/*

log -r *

run -all
