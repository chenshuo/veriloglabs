module key_schedule (
  input           clk, nrst,
  input  [3:0]    cnt,
  input  [127:0]  key,
  output [127:0]  round_key
);

  reg [7:0]   rk00, rk01, rk02, rk03;
  reg [7:0]   rk10, rk11, rk12, rk13;
  reg [7:0]   rk20, rk21, rk22, rk23;
  reg [7:0]   rk30, rk31, rk32, rk33;

  assign round_key =
    { rk00, rk10, rk20, rk30,
      rk01, rk11, rk21, rk31,
      rk02, rk12, rk22, rk32,
      rk03, rk13, rk23, rk33 };

  // SubWord()
  wire [7:0] bs0, bs1, bs2, bs3;
  Sbox s0(rk03, bs0);
  Sbox s1(rk13, bs1);
  Sbox s2(rk23, bs2);
  Sbox s3(rk33, bs3);

  wire [7:0] rcon;
  Rcon rcon00(.in(cnt[3:0]), .out(rcon));

  // RotWord
  wire [7:0] rk00n = rk00 ^ bs1 ^ rcon;
  wire [7:0] rk10n = rk10 ^ bs2;
  wire [7:0] rk20n = rk20 ^ bs3;
  wire [7:0] rk30n = rk30 ^ bs0;

  always @(posedge clk or negedge nrst)
  begin
    if (nrst == 1'b0) begin
      rk00 <= 8'b0; rk01 <= 8'b0; rk02 <= 8'b0; rk03 <= 8'b0;
      rk10 <= 8'b0; rk11 <= 8'b0; rk12 <= 8'b0; rk13 <= 8'b0;
      rk20 <= 8'b0; rk21 <= 8'b0; rk22 <= 8'b0; rk23 <= 8'b0;
      rk30 <= 8'b0; rk31 <= 8'b0; rk32 <= 8'b0; rk33 <= 8'b0;
    end else begin
      if (cnt == 0) begin
        { rk00, rk10, rk20, rk30,
          rk01, rk11, rk21, rk31,
          rk02, rk12, rk22, rk32,
          rk03, rk13, rk23, rk33 } <= key;
      end else begin : update_round_key
        rk00 <= rk00n;
        rk10 <= rk10n;
        rk20 <= rk20n;
        rk30 <= rk30n;

        rk01 <= rk01 ^ rk00n;
        rk11 <= rk11 ^ rk10n;
        rk21 <= rk21 ^ rk20n;
        rk31 <= rk31 ^ rk30n;

        rk02 <= rk02 ^ rk01 ^ rk00n;
        rk12 <= rk12 ^ rk11 ^ rk10n;
        rk22 <= rk22 ^ rk21 ^ rk20n;
        rk32 <= rk32 ^ rk31 ^ rk30n;

        rk03 <= rk03 ^ rk02 ^ rk01 ^ rk00n;
        rk13 <= rk13 ^ rk12 ^ rk11 ^ rk10n;
        rk23 <= rk23 ^ rk22 ^ rk21 ^ rk20n;
        rk33 <= rk33 ^ rk32 ^ rk31 ^ rk30n;
      end : update_round_key
    end
  end

endmodule
