#!/bin/sh

iverilog -g2012 key_schedule.sv Sbox.v Rcon.sv key_schedule_tb.sv && ./a.out | tee key_schedule_tb.log

iverilog -g2012 aes_encrypt_core_basic.sv key_schedule.sv mix_column.sv Sbox.v Rcon.sv aes_encrypt_core_basic_tb.sv && ./a.out | tee aes_encrypt_core_basic_tb.log
