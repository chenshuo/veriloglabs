module mem (
  input clk, we,
  input [31:0] wdata,
  input [3:0] waddr,
  input [3:0] raddr,
  output reg [31:0] q
);

  reg [31:0] ram [0:15];

  always @(posedge clk)
  begin
    if(we) begin
      ram[waddr] <= wdata;
    end

    q <= ram[raddr];
  end

endmodule
