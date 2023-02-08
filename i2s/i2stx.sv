module i2stx (
  input clk, nrst,
  output mclk,
  output reg lrclk, bclk, dout
  
);

  localparam FS = 48000, FCLK = FS * 512, BITS = 32;

  reg [8:0] cycle;

  assign mclk = clk;  // CLK is 24.576 MHz

  // work on real circuit?
  // assign lrclk = cycle[8];
  // assign bclk = cycle[3];

  reg [31:0] data;

  reg [31:0] rom[0:255];
  reg [7:0] laddr, raddr;

  // Debug only:
  wire [31:0] ldata, rdata;
  assign ldata = rom[laddr];
  assign rdata = rom[raddr];

  always_ff @(posedge clk or negedge nrst)
  begin
    if (!nrst) begin
      cycle <= 9'b0;
    end else begin
      cycle <= cycle + 9'b1;
    end
  end

  always_ff @(posedge clk or negedge nrst)
  begin
    if (!nrst) begin
      data <= 32'h0;
      laddr <= 8'b0;
      raddr <= 8'b0;
    end else begin
      if (cycle == 9'h007) begin
        data <= rom[laddr];
        if (laddr == 47)
          laddr <= 0;
        else
          laddr <= laddr + 1;
      end else if (cycle == 9'h107) begin
        data <= rom[raddr];
      end else if (cycle[2:0] == 3'h7) begin
        data <= {data[30:0], 1'b0};
      end
    end
  end

  always_ff @(posedge clk or negedge nrst)
  begin
    if (!nrst) begin
      lrclk <= 1'b0;
      bclk <= 1'b0;
      dout <= 1'b0;
    end else begin
      lrclk <= cycle[8];
      bclk <= cycle[2];
      dout <= data[31];
    end
  end

  initial begin
    assert (FCLK == 24_576_000) else $fatal(1);
    $readmemh("f1000.mem", rom);
  end
  
endmodule
