
all: test

test: sha1shift_tb.log sha1block_tb.log sha1core_tb1.log sha1core_tb2.log sha1top_tb.log

sha1shift_tb.log: sha1shift_tb.v sha1shift.v
	iverilog $^
	./a.out > $@

sha1block_tb.log: sha1block_tb.v sha1block.sv sha1shift.v sha1round.sv
	iverilog -g2012 $^
	./a.out > $@

sha1core_tb1.log: sha1core_tb1.sv sha1core.sv sha1block.sv sha1shift.v sha1round.sv mem.sv
	iverilog -g2012 $^
	./a.out > $@

sha1core_tb2.log: sha1core_tb2.sv sha1core.sv sha1block.sv sha1shift.v sha1round.sv mem.sv
	iverilog -g2012 $^
	./a.out > $@

sha1top_tb.log: sha1top_tb.sv sha1top.sv sha1core.sv sha1block.sv sha1shift.v sha1round.sv mem.sv reset.v
	iverilog -g2012 $^
	./a.out > $@
