module Tbox #(
  parameter file = "tbox0.mem"
) (
  input clk,
  input [7:0] in1, in2,
  output reg [31:0] out1, out2);

  reg [31:0] mem[0:255];

  initial begin
    $readmemh(file, mem);
  end

  always @(posedge clk)
  begin
    out1 <= mem[in1];
    out2 <= mem[in2];
  end

endmodule
