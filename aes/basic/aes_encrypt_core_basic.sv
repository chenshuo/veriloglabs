module aes_encrypt_core_basic (
  input           clk, nrst, start,
  input [127:0]   plain_text, key,
  output [127:0]  cipher_text,
  output          finish, bus_free
);

  reg [3:0]   cnt;  // 0 ~ 12
  assign finish = cnt == 4'd12;

  // State, column major.
  reg [7:0]   st00, st01, st02, st03;
  reg [7:0]   st10, st11, st12, st13;
  reg [7:0]   st20, st21, st22, st23;
  reg [7:0]   st30, st31, st32, st33;

  assign cipher_text =
    { st00, st10, st20, st30,
      st01, st11, st21, st31,
      st02, st12, st22, st32,
      st03, st13, st23, st33 };

  // SubBytes
  wire [7:0]  bs00, bs01, bs02, bs03;
  wire [7:0]  bs10, bs11, bs12, bs13;
  wire [7:0]  bs20, bs21, bs22, bs23;
  wire [7:0]  bs30, bs31, bs32, bs33;

  Sbox s00(st00, bs00), s01(st01, bs01), s02(st02, bs02), s03(st03, bs03);
  Sbox s10(st10, bs10), s11(st11, bs11), s12(st12, bs12), s13(st13, bs13);
  Sbox s20(st20, bs20), s21(st21, bs21), s22(st22, bs22), s23(st23, bs23);
  Sbox s30(st30, bs30), s31(st31, bs31), s32(st32, bs32), s33(st33, bs33);

  // ShiftRows
  wire [31:0] col0 = { bs00, bs11, bs22, bs33 };
  wire [31:0] col1 = { bs01, bs12, bs23, bs30 };
  wire [31:0] col2 = { bs02, bs13, bs20, bs31 };
  wire [31:0] col3 = { bs03, bs10, bs21, bs32 };

  // MixColumns
  wire [31:0]  mx0, mx1, mx2, mx3;
  mix_column m0(col0, mx0);
  mix_column m1(col1, mx1);
  mix_column m2(col2, mx2);
  mix_column m3(col3, mx3);

  // AddRoundKey
  wire [31:0] rk0, rk1, rk2, rk3;
  key_schedule ks(clk, nrst, cnt, key, {rk0, rk1, rk2, rk3});

  always @(posedge clk or negedge nrst)
  begin
    if (nrst == 1'b0) begin
      cnt <= 4'b0;

      st00 <= 8'b0; st01 <= 8'b0; st02 <= 8'b0; st03 <= 8'b0;
      st10 <= 8'b0; st11 <= 8'b0; st12 <= 8'b0; st13 <= 8'b0;
      st20 <= 8'b0; st21 <= 8'b0; st22 <= 8'b0; st23 <= 8'b0;
      st30 <= 8'b0; st31 <= 8'b0; st32 <= 8'b0; st33 <= 8'b0;
    end else begin
      if (start == 1'b1)
        cnt <= 0;
      else if (cnt != 12)
        cnt <= cnt + 4'b1;

      // Wasted one cycle
      if (cnt == 0) begin
        { st00, st10, st20, st30,
          st01, st11, st21, st31,
          st02, st12, st22, st32,
          st03, st13, st23, st33 } <= plain_text;
      end else if (cnt == 1) begin
        { st00, st10, st20, st30 } <= { st00, st10, st20, st30 } ^ rk0;
        { st01, st11, st21, st31 } <= { st01, st11, st21, st31 } ^ rk1;
        { st02, st12, st22, st32 } <= { st02, st12, st22, st32 } ^ rk2;
        { st03, st13, st23, st33 } <= { st03, st13, st23, st33 } ^ rk3;
      end else if (cnt == 11) begin
        // Last round doesn't MixColumns.
        { st00, st10, st20, st30 } <= col0 ^ rk0;
        { st01, st11, st21, st31 } <= col1 ^ rk1;
        { st02, st12, st22, st32 } <= col2 ^ rk2;
        { st03, st13, st23, st33 } <= col3 ^ rk3;
      end else if (cnt != 12) begin
        { st00, st10, st20, st30 } <= mx0 ^ rk0;
        { st01, st11, st21, st31 } <= mx1 ^ rk1;
        { st02, st12, st22, st32 } <= mx2 ^ rk2;
        { st03, st13, st23, st33 } <= mx3 ^ rk3;
      end
    end
  end

endmodule
