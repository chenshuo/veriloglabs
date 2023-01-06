module mix_column (
  input  [31:0] in,
  output [31:0] out
);

  wire [7:0]  b0 = in[31:24], b1 = in[23:16], b2 = in[15:8], b3 = in[7:0];

  function automatic [7:0] xtime(input[7:0] x);
  begin
    logic [7:0]   left_shift = {x[6:0], 1'b0};
    xtime = (x[7] == 1'b0) ? left_shift : left_shift ^ 8'h1B;
  end
  endfunction

  wire [7:0]  mu0, mu1, mu2, mu3;

  assign mu0 = xtime(b0 ^ b1);
  assign mu1 = xtime(b1 ^ b2);
  assign mu2 = xtime(b2 ^ b3);
  assign mu3 = xtime(b3 ^ b0);

  wire[7:0]  p = b0 ^ b1 ^ b2 ^ b3;

  assign out = { b0 ^ mu0 ^ p, b1 ^ mu1 ^ p, b2 ^ mu2 ^ p, b3 ^ mu3 ^ p };

endmodule
