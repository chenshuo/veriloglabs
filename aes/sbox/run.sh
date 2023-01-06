#!/bin/sh

iverilog -g2012 key_schedule.sv Sbox.sv Rcon.sv key_schedule_tb.sv && ./a.out | tee key_schedule_tb.log
