module sha1shift(
  input clk, en,
  input [31:0] in,
  output [31:0] out
);
  // SHA1 block, 32 * 16 = 512 bits
  reg [31:0] words[0:15];

  assign out = words[0];

  wire [31:0] xor_word = words[2] ^ words[7] ^ words[13] ^ words[15];
  wire [31:0] next_word = en ? in : {xor_word[30:0], xor_word[31]};

  integer i;

  always @ (posedge clk)
  begin
      // shift
      for (i = 0; i < 15; i = i + 1)
        words[i+1] <= words[i];

      words[0] <= next_word;
  end
endmodule
