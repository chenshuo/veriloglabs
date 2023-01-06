`timescale 1ns/1ns

module aes_encrypt_core_basic_tb;

  reg clk, nrst, start;
  wire finish, bus_free;
    
  wire[127:0] cipher_text, round_key;
  reg[127:0]  plain_text, key;

  aes_encrypt_core_basic dut(.clk(clk), .nrst(nrst), .start(start), .finish(finish), .bus_free(bus_free),
    .plain_text(plain_text), .key(key), .cipher_text(cipher_text));

  assign round_key = { dut.rk0, dut.rk1, dut.rk2, dut.rk3 };

  always #5 clk <= !clk;

  initial begin
    $dumpfile("aes_encrypt_core_basic_tb.vcd");
    $dumpvars;

    clk = 1'b1;
    nrst = 1'b1;
    key = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;
    plain_text = 128'h3243f6a8_885a308d_313198a2_e0370734;

    #5 nrst = 0;
    #10 nrst = 1;

    while (!finish)
      #10;
    #3 assert(cipher_text == 128'h3925841d_02dc09fb_dc118597_196a0b32) else $fatal(1);

    #50 start = 1;
    key = 128'h000102030405060708090a0b0c0d0e0f;
    plain_text = 128'h00112233445566778899aabbccddeeff;
    #10 start = 0;

    while (!finish)
      #10;

    #3 assert(cipher_text == 128'h69c4e0d86a7b0430d8cdb78070b4c55a) else $fatal(1);

    #50 $finish;
  end

  always @(negedge clk) begin
    $display("%2d %h %h", dut.cnt, cipher_text, round_key);
  end

endmodule

