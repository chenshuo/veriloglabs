`timescale 1ns/1ns

module i2stx_tb;

  reg clk, nrst;
  wire mclk, lrclk, bclk, dout;

  i2stx dut(clk, nrst, mclk, lrclk, bclk, dout);

  initial begin
    clk = 1;
    nrst = 1;
    # 3 nrst = 0;
    # 3 nrst = 1;
  end

  always #20.35 clk <= !clk;

  initial begin
    $dumpfile("i2stx_tb.vcd");
    $dumpvars;
    #10000000 $finish;
  end
endmodule
