module sha1core
(
  input clk, nrst,
  input wr,
  input [31:0] in,

  output reg [31:0] h0, h1, h2 ,h3, h4,
  output busy
);

  reg [2:0] state;
  localparam RESET = 0, IDLE = 1, START = 2, RUNNING = 3, UPDATE = 4;
  wire we = state == IDLE && wr;
  assign busy = state != IDLE;
  wire start = state == START;

  wire [31:0] a, b, c, d, e;
  wire [31:0] word;
  wire [3:0] raddr;
  wire ready;

  sha1block block(clk, nrst, start,
    h0, h1, h2, h3, h4,
    word,
    a, b, c, d, e,
    raddr, ready
  );

  reg [3:0] waddr;

  // FPGA memory has 1-cycle delay
  wire [3:0] raddrm = start ? 0 : (raddr+1);

  mem m(clk, we, in, waddr, raddrm, word);

  always_ff @(posedge clk or negedge nrst)
  begin
    if (nrst == 1'b0) begin
      state <= RESET;
      waddr <= 0;
    end else begin
      case (state)
        RESET: begin
          h0 <= 32'h67452301;
          h1 <= 32'hEFCDAB89;
          h2 <= 32'h98BADCFE;
          h3 <= 32'h10325476;
          h4 <= 32'hC3D2E1F0;
          waddr <= 0;
          state <= IDLE;
        end
        IDLE: begin
          if (we) begin
            waddr <= waddr + 1;
            if (waddr == 15)
              state <= START;
          end
        end
        START: begin
          state <= RUNNING;
        end
        RUNNING: begin
          if (ready) begin
            state <= UPDATE;
          end
        end
        UPDATE: begin
          h0 <= h0 + a;
          h1 <= h1 + b;
          h2 <= h2 + c;
          h3 <= h3 + d;
          h4 <= h4 + e;
          state <= IDLE;
        end
      endcase
    end
  end
endmodule
