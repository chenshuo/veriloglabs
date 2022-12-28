module counter(
  input clk, nrst, ena,
  output reg [7:0] out
);

  always_ff @(posedge clk or negedge nrst)
  begin
    if (!nrst)
      out <= 0;
    else if (ena)
      out <= out + 1;
  end

endmodule
