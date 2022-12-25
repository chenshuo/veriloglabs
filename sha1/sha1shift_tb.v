`timescale 1ns/1ns

module sha1shift_tb;

  reg clk;
  reg [6:0] t;
  reg [31:0] in;
  wire [31:0] out;
  wire en = t < 16;

  sha1shift dut(clk, en, in, out);

  initial begin
    clk = 1;
    t = 0;

    $dumpfile("sha1shift_tb.vcd");
    $dumpvars;
    $display(" t  in  |  out");
    #2 in = 'h61626380;
    #10 in = 0;
    #140 in = 'h3 << 3;
    #10 in = 0;
    #820 $finish;
  end

  always #5 clk <= !clk;

  always @(posedge clk)
    t <= t + 1;

  always @(negedge clk)
  begin
    $display(" %2d %h | %h", t, in, out);
  end
endmodule
