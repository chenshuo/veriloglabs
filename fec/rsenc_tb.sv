`timescale 1ns/1ns

module rsenc_tb;
  reg clk, nrst, control;
  reg [7:0] in;
  wire [7:0] out;

  rsenc dut(clk, nrst, control, in, out);

  always #5 clk <= !clk;

  initial begin
    $dumpfile("rsenc_tb.vcd");
    $dumpvars;
    clk = 1'b1;
    nrst = 1'b1;
    control = 1'b1;
    in = 8'b0;

    #5 nrst = 0;
    #10 nrst = 1;
    #10 in = 8'h12;
    #10 in = 8'h34;
    #10 in = 8'h56;
    #10 control = 1'b0;
    in = 8'b0;

    #60 $finish;
  end

  always @(negedge clk) begin
    $display("%2h %h %h | %h", control, in, out, dut.feedback);
  end

endmodule
