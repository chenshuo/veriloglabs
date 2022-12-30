module reset (
  input clk, nrst,
  output reg reset_n
);

  reg r;

  always @ (posedge clk or negedge nrst)
  begin
    if (!nrst) begin
      r <= 0;
      reset_n <= 0;
    end else begin
      r <= 1;
      reset_n <= r;
    end
  end

endmodule
