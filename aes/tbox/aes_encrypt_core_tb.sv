`timescale 1ns/1ns

module aes_encrypt_core_tb;
    reg clk, nrst, start;
    wire finish, bus_free;
    
    wire[127:0] cipher_text;
    reg[127:0]  plain_text, key;
    
    reg[127:0]  pt[0:100], ks[0:100], ct[0:100];
    
    integer i;
    
    aes_encrypt_core dut(.clk(clk), .nrst(nrst), .start(start), .finish(finish), .bus_free(bus_free),
                         .plain_text(plain_text), .key(key), .cipher_text(cipher_text));
    
    always #5 clk <= !clk;
    
    initial begin
        $dumpfile("aes_encrypt_core_tb.vcd");
        $dumpvars;

        clk = 1'b0;
        nrst = 1'b1;
        start = 1'b0;
        key = 128'h2b7e1516_28aed2a6_abf71588_09cf4f3c;
        plain_text = 128'h3243f6a8_885a308d_313198a2_e0370734;
        
        #15 nrst = 1'b0;
        #15 nrst = 1'b1;
        
        #50 start = 1'b1;
        #15 start = 1'b0;

        #200;
        $dumpoff;
        $display("%h", cipher_text);
        assert(cipher_text == 128'h3925841d_02dc09fb_dc118597_196a0b32) else $fatal(1);

        $readmemh("plain_text.txt", pt);
        $readmemh("key.txt", ks);
        $readmemh("cipher_text.txt", ct);
        
        for (i = 0; i < 100; i = i + 1)
        begin
          if (ct[i] === 128'hx) begin
            $display("PASSED.");
            $finish;
          end

          while (!bus_free)
            #25;
          plain_text = pt[i];
          key = ks[i];
          
          #3 start = 1'b1;
          #17 start = 1'b0;
          
          while (!finish)
            #7;
          
          #11;
          if (ct[i] != cipher_text) 
          begin
            $display("ERROR: \nexp: %H\ngot: %H", ct[i], cipher_text);
            $fatal(1);
          end
          else
            $display("%3d %h %h %h", i, plain_text, key, cipher_text);
        end
        $finish;        
    end
    
endmodule
