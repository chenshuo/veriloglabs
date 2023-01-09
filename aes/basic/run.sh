#!/bin/sh

KEY_SRCS="key_schedule.sv Sbox.v Rcon.sv"
AES_SRCS="aes_encrypt_core.sv mix_column.sv $KEY_SRCS"

iverilog -g2012 $KEY_SRCS key_schedule_tb.sv && ./a.out | tee key_schedule_tb.log

iverilog -g2012 $AES_SRCS aes_encrypt_core_basic_tb.sv && ./a.out | tee aes_encrypt_core_basic_tb.log

iverilog -g2012 $AES_SRCS aes_encrypt_core_tb.sv && ./a.out | tee aes_encrypt_core_tb.log
