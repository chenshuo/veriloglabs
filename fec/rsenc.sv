module rsenc
(
  input clk, nrst, control,
  input [7:0] in,
  output [7:0] out
);

  reg running;
  reg [7:0] ind, s0, s1, s2, s3;
  wire [7:0] feedback, g0out, g1out, g2out, g3out;

  g40 g0(feedback, g0out);
  g78 g1(feedback, g1out);
  g36 g2(feedback, g2out);
  g0f g3(feedback, g3out);

  assign feedback = running == 1'b1 ? (ind ^ s3) : 8'b0;
  assign out = running == 1'b1 ? ind : s3;

  always @(posedge clk or negedge nrst)
  begin
    if (nrst == 1'b0) begin
      running <= 1'b0; ind <= 8'b0;
      s0 <= 8'b0; s1 <= 8'b0;
      s2 <= 8'b0; s3 <= 8'b0;
    end else begin
      running <= control;
      ind <= in;
      s0 <= g0out;
      s1 <= g1out ^ s0;
      s2 <= g2out ^ s1;
      s3 <= g3out ^ s2;
    end
  end
endmodule
