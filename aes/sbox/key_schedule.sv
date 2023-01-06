module key_schedule (
  input           clk, nrst,
  input  [3:0]    cnt,
  input  [127:0]  key,
  output [127:0]  round_key
);

  reg [31:0] w0, w1, w2, w3;
  wire [31:0] w3n = (cnt == 0) ? key[31:0] : w3 ^ w2 ^ w1 ^ w0n;

  assign round_key = { w0, w1, w2, w3 };

  // SubWord()
  wire [7:0] bs0, bs1, bs2, bs3;
  Sbox s01(clk, w3n[31:24], w3n[23:16], bs0, bs1);
  Sbox s23(clk, w3n[15:8] , w3n[7:0]  , bs2, bs3);

  wire [7:0] rcon;
  Rcon rcon00(.in(cnt[3:0] - 4'b1), .out(rcon));

  // RotWord()
  wire [31:0] rw = {bs1 ^ rcon, bs2, bs3, bs0 };

  wire [31:0] w0n = w0 ^ rw;

  always @(posedge clk or negedge nrst)
  begin
    if (nrst == 1'b0) begin
      { w0, w1, w2, w3 } <= 128'b0;
    end else begin
      if (cnt == 0) begin
        { w0, w1, w2, w3 } <= key;
      end else begin : update_round_key
        w0 <= w0n;
        w1 <= w1 ^ w0n;
        w2 <= w2 ^ w1 ^ w0n;
        w3 <= w3n;
      end : update_round_key
    end
  end

endmodule
