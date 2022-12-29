`timescale 1ns/1ns

module sha1core_tb1;
  reg clk, nrst;
  reg wr;
  reg [31:0] data;
  uwire[31:0] h0, h1, h2, h3, h4;
  uwire busy;

  uwire [159:0] digest = { h0, h1, h2, h3, h4 };

  sha1core dut(clk, nrst, wr, data,
    h0, h1, h2, h3, h4, busy);

  initial begin
    clk = 1;
    nrst = 1;
    wr = 0;
    #3 nrst = 0;
    #3 nrst = 1;
    
    while (busy)
      #10;

    #17 data = 'h61626380; wr = 1;

    #10 data = 0; wr = 0;
    #10 data = 'h0; wr = 1;
    #140 data = 'h18;
    #100 wr = 0;
    while (busy)
      #10;

    #3;
    if (digest == 160'ha9993e36_4706816a_ba3e2571_7850c26c_9cd0d89d)
      $display("*** PASSED 0x%h", digest);
    else
      $fatal(1, "*** FAILED 0x%h", digest);

  end

  always #5 clk = !clk;

  initial begin
    $dumpfile("sha1core_tb1.vcd");
    $dumpvars;
    #1100 $finish;
  end
endmodule
