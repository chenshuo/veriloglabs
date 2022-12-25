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

  sha1shift shift(clk, en, in, w);

  function automatic [31:0] sha1_k(input[6:0] t);
  begin
    sha1_k = (t <= 7'd20) ? 32'h5A827999 :
             (t <= 40) ? 32'h6ED9EBA1 :
             (t <= 60) ? 32'h8F1BBCDC : 32'hCA62C1D6;
  end
  endfunction

  function automatic [31:0] sha1_f(input[6:0] t);
  begin
    logic [31:0] f20 = (b & c) | ((~b) & d);
    logic [31:0] f40 = b ^ c ^ d;
    logic [31:0] f60 = (b & c) | (b & d) | (c & d);

    sha1_f = (t <= 20) ? f20 :
             (t <= 40) ? f40 :
             (t <= 60) ? f60 : f40;
  end
  endfunction

  function automatic [159:0] sha1round(
      input[6:0] t,
      input[31:0] a, b, c, d, e, w);
  begin
    logic [31:0] na = {a[26:0], a[31:27]} + sha1_f(t) + e + sha1_k(t) + w;
    logic [31:0] nc = {b[1:0], b[31:2]};

    sha1round = {na, a, nc, c, d};
  end
  endfunction

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
        {a, b, c, d, e} <= sha1round(t, a, b, c, d, e, w);
    end
  end

endmodule
