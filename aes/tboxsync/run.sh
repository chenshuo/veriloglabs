#!/bin/sh

iverilog -g2012 *.sv && ./a.out | tee aes_encrypt_core_tb.log
