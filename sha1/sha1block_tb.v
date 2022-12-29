`timescale 1ns/1ns

module sha1block_tb;
  reg clk, nrst, restart;
  wire [159:0] digest;
  reg [31:0] word;
  reg [31:0] h0, h1, h2, h3, h4;
  wire [31:0] a, b, c, d, e;
  wire [3:0] raddr;
  wire ready;
  integer i;

  sha1block dut(clk, nrst, restart,
    h0, h1, h2, h3, h4,
    word,
    a, b, c, d, e,
    raddr, ready);
  
  assign digest = { h0 + a, h1 + b, h2 + c, h3 + d, h4 + e };

  initial
  begin
    clk = 0;
    nrst = 1;
    i = 0;
    h0 = 32'h67452301;
    h1 = 32'hEFCDAB89;
    h2 = 32'h98BADCFE;
    h3 = 32'h10325476;
    h4 = 32'hC3D2E1F0;
  end

  always #5 clk = !clk;
  
  initial begin
    $dumpfile("sha1block_tb.vcd");
    $dumpvars;
    $display(" i  rst   word   |  t words[0] |");
  end

  always @(negedge clk)
  begin
    $display("%3d  %1d  %h | %2d %h | %h %h %h %h %h", i, restart, word,
      dut.t, dut.w,
      a, b, c, d, e);
    i = i+1;
  end

  initial begin
    restart = 0;
    #3 nrst = 0;
    #20 nrst = 1;
    #860 $finish;
  end

  initial begin
    #10 word = 32'b0;

    #10 restart = 1;
    #27 restart = 0;
    #0 word = 32'h61626380;
    #10 word = 32'b0;
    #10 word = 32'b0;
    #10 word = 32'b0;

    #10 word = 32'b0;
    #10 word = 32'b0;
    #10 word = 32'b0;
    #10 word = 32'b0;

    #10 word = 32'b0;
    #10 word = 32'b0;
    #10 word = 32'b0;
    #10 word = 32'b0;

    #10 word = 32'b0;
    #10 word = 32'b0;
    #10 word = 32'b0;
    #10 word = 32'h18;

    wait_ready();

    if (digest == 160'ha9993e36_4706816a_ba3e2571_7850c26c_9cd0d89d)
      $display("*** PASSED 0x%h", digest);
    else
      $fatal(1, "*** FAILED 0x%h", digest);

  end

  task wait_ready;
    begin
      while (!ready)
        #10;
      #5;
    end
  endtask

endmodule
