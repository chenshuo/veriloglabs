`timescale 1ns/1ns

module sha1top_tb;
  reg clk, nrst;
  reg wr, last;
  reg [1:0] last_len;

  reg [2:0] haddr;
  reg [31:0] data;
  uwire[31:0] out;

  uwire done, busy;

  sha1top dut(clk, nrst, wr, last, data,
    last_len, haddr, out, done, busy);

  reg [31:0] alphabet[0:31];
  reg [159:0] testvectors[0:128];
  reg [159:0] digest;
  reg [7:0] word;
  integer i = 0;

  initial begin
    $readmemh("alphabet.txt", alphabet);
    $readmemh("sha1top_tb.txt", testvectors);
    clk = 1;
    nrst = 1;

    for (i = 0; i < 129; ++i)
    begin
      if (testvectors[i] === 160'bx)
        $finish;
      run_one_test(i, digest);
      $display("%d %h", i, digest);
      assert (digest == testvectors[i]);
    end

    $display("%d PASSED", i);
    # 100 $finish;
  end

  initial begin
  end

  always #5 clk = !clk;

  task run_one_test(input [7:0] length, output reg [159:0] digest);
    integer len;
  begin
    @(posedge clk) #2;

    data = 0;
    wr = 0;
    last = 0;
    last_len = 0;
    haddr = 0;
    
    #2 nrst = 0;
    #5 nrst = 1;
    wait_idle();

    len = length;
    word = 0;
    wr = 1;
    while (len >= 4) begin
      len -= 4;
      data = alphabet[word];
      # 10;
      wait_idle();
      word++;
    end

    data = alphabet[word];
    wait_idle();
    last = 1;
    last_len = len;
    @(posedge clk) #2;
    wr = 0;

    while (!done)
      #10;

    haddr = 0;
    #3 digest[160-1:160-32] = out;
    haddr = 1;
    #3 digest[127:96] = out;
    haddr = 2;
    #3 digest[95:64] = out;
    haddr = 3;
    #3 digest[63:32] = out;
    haddr = 4;
    #3 digest[31:0] = out;
  end
  endtask

  task wait_idle;
    begin
      while (busy)
        #10;
    end
  endtask

endmodule
