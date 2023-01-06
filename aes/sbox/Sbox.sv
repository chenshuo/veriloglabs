module Sbox(
  input clk,
  input [7:0] in1, in2,
  output reg [7:0] out1, out2);

  reg [7:0] sbox[0:255];
  
  initial begin
    $readmemh("sbox.mem", sbox);
  end

  always @(posedge clk)
  begin
    out1 <= sbox[in1];
    out2 <= sbox[in2];
  end

endmodule
