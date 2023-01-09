module aes_encrypt_core (
  input               clk, nrst, start,
  input [127:0]       plain_text, key,
  output reg [127:0]  cipher_text,
  output              finish, bus_free
);

  reg [3:0]   cnt;  // 0 ~ 12

  assign finish = (cnt == 12);

  wire[31:0]  st0, st1, st2, st3;

  wire[31:0]  Te00, Te01, Te02, Te03;
  wire[31:0]  Te10, Te11, Te12, Te13;
  wire[31:0]  Te20, Te21, Te22, Te23;
  wire[31:0]  Te30, Te31, Te32, Te33;

  Tbox #("tbox0.mem") t0b0(.clk(clk), .in1(st0[31:24]), .out1(Te00),
                                      .in2(st1[31:24]), .out2(Te10));
  Tbox #("tbox0.mem") t0b2(.clk(clk), .in1(st2[31:24]), .out1(Te20),
                                      .in2(st3[31:24]), .out2(Te30));

  Tbox #("tbox1.mem") t1b0(.clk(clk), .in1(st1[23:16]), .out1(Te01),
                                      .in2(st2[23:16]), .out2(Te11));
  Tbox #("tbox1.mem") t1b2(.clk(clk), .in1(st3[23:16]), .out1(Te21),
                                      .in2(st0[23:16]), .out2(Te31));

  Tbox #("tbox2.mem") t2b0(.clk(clk), .in1(st2[15:8]),  .out1(Te02),
                                      .in2(st3[15:8]),  .out2(Te12));
  Tbox #("tbox2.mem") t2b2(.clk(clk), .in1(st0[15:8]),  .out1(Te22),
                                      .in2(st1[15:8]),  .out2(Te32));

  Tbox #("tbox3.mem") t3b0(.clk(clk), .in1(st3[7:0]),   .out1(Te03),
                                      .in2(st0[7:0]),   .out2(Te13));
  Tbox #("tbox3.mem") t3b2(.clk(clk), .in1(st1[7:0]),   .out1(Te23),
                                      .in2(st2[7:0]),   .out2(Te33));

  wire [31:0] rk0, rk1, rk2, rk3;
  key_schedule ks(clk, nrst, cnt, key, {rk0, rk1, rk2, rk3});

  assign st0 = (cnt == 1) ? plain_text[127:96] ^ rk0
    : Te00 ^ Te01 ^ Te02 ^ Te03 ^ rk0;
  assign st1 = (cnt == 1) ? plain_text[95:64] ^ rk1
    : Te10 ^ Te11 ^ Te12 ^ Te13 ^ rk1;
  assign st2 = (cnt == 1) ? plain_text[63:32] ^ rk2
    : Te20 ^ Te21 ^ Te22 ^ Te23 ^ rk2;
  assign st3 = (cnt == 1) ? plain_text[31:0] ^ rk3
    : Te30 ^ Te31 ^ Te32 ^ Te33 ^ rk3;

  assign bus_free = (cnt == 0 || cnt == 1) ? 1'b0 : 1'b1;

  always @(posedge clk or negedge nrst)
  begin
    if (nrst == 1'b0) begin
      cnt <= 4'b0;
      cipher_text <= 128'b0;
    end else begin
      if (start == 1'b1)
        cnt <= 0;
      else if (cnt != 12)
        cnt <= cnt + 4'b1;

      if (cnt == 11) begin
        // Last round doesn't MixColumns.
        cipher_text[127:96] <= ({Te00[23:16], Te01[15:8], Te02[7:0], Te03[31:24]}) ^ rk0;
        cipher_text[95:64] <= ({Te10[23:16], Te11[15:8], Te12[7:0], Te13[31:24]}) ^ rk1;
        cipher_text[63:32] <= ({Te20[23:16], Te21[15:8], Te22[7:0], Te23[31:24]}) ^ rk2;
        cipher_text[31:0] <= ({Te30[23:16], Te31[15:8], Te32[7:0], Te33[31:24]}) ^ rk3;
      end
    end
  end
endmodule
