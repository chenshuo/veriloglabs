`timescale 1ns/1ns

module hmac_core_tb;
  reg clk, nrst, wr;
  reg new_key, new_message, finish;
  reg [31:0] in;

  wire [159:0] digest;
  wire idle, done;
  hmac_core dut(.clk, .nrst, .wr,
    .new_key, .new_message, .finish,
    .in, .out(digest), .idle, .done);

  reg [31:0] message[0:15];
  integer i;

  initial begin
    clk = 1'b1;
    nrst = 1'b1;
    wr = 0;
    finish = 1'b0;

    # 5 nrst = 0;
    # 5 nrst = 1;

    // KEY = "key"
    # 8 in = 32'h6b657900;
    # 10 wr = 1;
    # 10 in = 0;
    # 160 wr = 0;
    while (!idle)
      #10;
    $display("IDLE");

    // Message = "The quick brown fox jumps over the lazy dog"
    $readmemh("hmac_core_tb1.mem", message);
    #10 wr = 1;
    for (i = 0; i < 16; ++i) begin
      in = message[i];
      # 10;
    end
    #10 wr = 0;

    while (!idle)
      #10;
    $display("FINISH");
    #0 finish = 1;
    #10 finish = 0;

    while (!done)
      #10;
    $display("DONE %h", digest);
    assert (digest == 160'hde7c9b85_b8b78aa6_bc8a7a36_f70a9070_1c9db4d9) else $fatal(1);
    # 50 $finish;
  end

  always #5 clk = !clk;

  initial begin
    $dumpfile("hmac_core_tb1.vcd");
    $dumpvars;
    #4000 $finish;
  end

  always @(negedge clk)
  begin
    $display("%2d %h %h %h %h %h %h %2d | %h %h",
      dut.mem_raddr, dut.word, dut.state, dut.ik_h0, dut.ok_h0, dut.h0, dut.wr, dut.s.t,
      dut.a, dut.sha1_ready);
  end

endmodule
