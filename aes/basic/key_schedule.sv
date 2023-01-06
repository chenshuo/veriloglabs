module key_schedule (
  input           clk, nrst,
  input  [3:0]    cnt,
  input  [127:0]  key,
  output [127:0]  round_key
);

  reg [31:0] w0, w1, w2, w3;

  assign round_key = { w0, w1, w2, w3 };

  // RotWord() and SubWord()
  wire [7:0] bs0, bs1, bs2, bs3;
  Sbox s0(w3[31:24], bs3);
  Sbox s1(w3[23:16], bs0);
  Sbox s2(w3[15:8] , bs1);
  Sbox s3(w3[7:0]  , bs2);

  wire [7:0] rcon;
  Rcon rcon00(.in(cnt[3:0] - 4'b1), .out(rcon));

  wire [31:0] w0n = w0 ^ { bs0 ^ rcon, bs1, bs2, bs3 };

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
        w3 <= w3 ^ w2 ^ w1 ^ w0n;
      end : update_round_key
    end
  end

endmodule
