vlib work

vlog +cover tb_shiftbuffer.v shiftbuffer.v

vsim -novopt work.tb_shiftbuffer

add wave -position insertpoint sim:/tb_shiftbuffer/dut/*

run -all
