`timescale 1ns/1ns

module key_schedule_tb;
  reg clk, nrst;
  reg [3:0] cnt;
  reg[127:0]  key;
  wire[127:0] round_key;

  key_schedule dut(.clk(clk), .nrst(nrst), .cnt(cnt), .key(key), .round_key(round_key));

  /*
  wire [31:0] w0 = {dut.rk00, dut.rk10, dut.rk20, dut.rk30};
  wire [31:0] w1 = {dut.rk01, dut.rk11, dut.rk21, dut.rk31};
  wire [31:0] w2 = {dut.rk02, dut.rk12, dut.rk22, dut.rk32};
  wire [31:0] w3 = {dut.rk03, dut.rk13, dut.rk23, dut.rk33};
  */
  wire [31:0] w0 = round_key[127:96];
  wire [31:0] w1 = round_key[95:64];
  wire [31:0] w2 = round_key[63:32];
  wire [31:0] w3 = round_key[31:0];

  always #5 clk <= !clk;

  initial begin
    $dumpfile("key_schedule_tb.vcd");
    $dumpvars;

    clk = 1'b1;
    nrst = 1'b1;
    key = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;

    #5 nrst = 0;
    #10 nrst = 1;
    #200 $finish;
  end

  always @(posedge clk or negedge nrst)
  begin
    if (nrst == 1'b0) begin
      cnt <= 4'b0;
    end else begin
      cnt <= cnt + 4'b1;
    end
  end

  always @(negedge clk) begin
    $display("%2d %h %h %h %h", dut.cnt, w0, w1, w2, w3);
    case (cnt)
      1: assert (round_key == key);
      2: assert (round_key == 128'ha0fafe17_88542cb1_23a33939_2a6c7605) else $fatal(1);
      11: assert (round_key == 128'hd014f9a8_c9ee2589_e13f0cc8_b6630ca6) else $fatal(1);
    endcase
  end

endmodule
