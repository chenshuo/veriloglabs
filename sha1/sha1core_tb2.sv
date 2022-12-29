`timescale 1ns/1ns

module sha1_tb1;
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
    
    #17 data = 'h61626364; wr = 1;
    #10 data = 'h62636465;
    #10 data = 'h63646566;
    #10 data = 'h64656667;
    #10 data = 'h65666768;
    #10 data = 'h66676869;
    #10 data = 'h6768696a;
    #10 data = 'h68696a6b;
    #10 data = 'h696a6b6c;
    #10 data = 'h6a6b6c6d;
    #10 data = 'h6b6c6d6e;
    #10 data = 'h6c6d6e6f;
    #10 data = 'h6d6e6f70;
    #10 data = 'h6e6f7071;
    #10 data = 'h80000000;
    #10 data = 'h00000000;
    #100 wr = 0;
    while (busy)
      #10;

    #3 assert (digest == 160'hF4286818_C37B27AE_0408F581_84677148_4A566572);

    // The length is in 2nd block.
    #10 wr = 1;
    #150 data = 'h000001c0;
    #100 wr = 0;

    while (busy)
      #10;

    #3;
    if (digest == 160'h84983E44_1C3BD26E_BAAE4AA1_F95129E5_E54670F1)
      $display("*** PASSED 0x%h", digest);
    else
      $fatal(1, "*** FAILED 0x%h", digest);

  end

  always #5 clk = !clk;

  initial begin
    $dumpfile("sha1core_tb2.vcd");
    $dumpvars;
    #2200 $finish;
  end
endmodule
