module sha1block
(
  input clk, nrst, restart,
  input [31:0] h0, h1, h2, h3, h4,
  input [31:0] in,
  output reg [31:0] a, b, c, d, e,
  output [3:0] raddr,
  output ready
);

  reg [6:0] t;  // 0 ~ 81

  assign raddr = t[3:0];
  assign ready = t == 81;

  wire en = t[6:4] == 3'b0;  // t < 16
  wire [31:0] w;
  wire [159:0] next_abcde;

  sha1shift shift(clk, en, in, w);
  sha1round round(t, a, b, c, d, e, w, next_abcde);

  always_ff @(posedge clk or negedge nrst)
  begin
    if (!nrst) begin
      t <= 0;
    end else begin
      if (restart)
        t <= 0;
      else if (!ready)
        t <= t + 1;
    end
  end

  always_ff @(posedge clk or negedge nrst)
  begin
    if (!nrst) begin
      {a, b, c, d, e} <= 160'b0;
    end else begin
      if (t == 0)
        {a, b, c, d, e} <= {h0, h1, h2, h3, h4};
      else if (!ready)
        {a, b, c, d, e} <= next_abcde;
    end
  end

endmodule
