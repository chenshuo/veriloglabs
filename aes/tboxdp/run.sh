#!/bin/sh

iverilog -g2012 *.v *.sv && ./a.out | tee aes_encrypt_core_tb.log
