`timescale 1ns/1ns

module mix_column_tb;
  reg clk;
  reg [31:0] in;
  wire[31:0] out;

  mix_column dut(.b0(in[31:24]), .b1(in[23:16]), .b2(in[15:8]), .b3(in[7:0]),
                 .mx0(out[31:24]), .mx1(out[23:16]), .mx2(out[15:8]), .mx3(out[7:0]));

  always #5 clk <= !clk;

  initial begin
    $dumpfile("mix_column_tb.vcd");
    $dumpvars;

    clk = 1'b1;

    in = 32'h01010101;
    #5 assert(out == 32'h01010101);

    #5 in = 32'hdb135345;
    #5 assert(out == 32'h8e4da1bc);

    #5 in = 32'hf20a225c;
    #5 assert(out == 32'h9fdc589d);

    #20 $finish;
  end

endmodule
