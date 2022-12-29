
all: test

test: sha1block_tb.log sha1shift_tb.log

sha1shift_tb.log: sha1shift_tb.v sha1shift.v
	iverilog $^
	./a.out > $@

sha1block_tb.log: sha1block_tb.v sha1block.sv sha1shift.v sha1round.sv
	iverilog -g2012 $^
	./a.out > $@
