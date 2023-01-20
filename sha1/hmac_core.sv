module hmac_core (
  input clk, nrst, wr,
  input new_key, new_message, finish,
  input [31:0] in,

  output [159:0] out,
  output idle, done
);

  localparam RESET = 0, KEYIN = 1,
    ISTART = 2, IPAD = 3, OSTART = 4, OPAD = 5,
    IDLE = 6, START = 7, RUNNING = 8, HPAD = 9,
    FINISH = 10, WAIT = 11, DONE = 12;
  reg [3:0] state;
  assign idle = (state == IDLE || state == KEYIN);
  assign done = state == DONE;

  reg [3:0] waddr;
  wire [31:0] mem_in, mem_out;
  wire we = (idle && wr) || state == HPAD;
  assign mem_in = (state == HPAD ?
    (waddr == 0 ? h0 : waddr == 1 ? h1 : waddr == 2 ? h2 : waddr == 3 ? h3 : waddr == 4 ? h4 :
     waddr == 5 ? 32'h80000000 : waddr == 15 ? 32'h02a0 : 32'b0)
    : in);
  // FPGA memory has 1-cycle delay
  wire [3:0] mem_raddr = sha1_start ? 0 : (sha1_raddr + 4'b1);
  mem m(clk, we, mem_in, waddr, mem_raddr, mem_out);

  reg [31:0] h0, h1, h2, h3, h4;
  assign out = {h0, h1, h2, h3, h4};
  wire [31:0] a, b, c, d, e;
  wire [31:0] word = (state == IPAD ? mem_out ^ 32'h36363636
                   : (state == OPAD ? mem_out ^ 32'h5c5c5c5c : mem_out));
  wire [3:0] sha1_raddr;
  wire sha1_ready;
  wire sha1_start = state == ISTART || state == OSTART || state == START || state == FINISH;

  sha1block s(clk, nrst, sha1_start,
    h0, h1, h2, h3, h4,
    word,
    a, b, c, d, e,
    sha1_raddr, sha1_ready
  );

  reg [31:0] ik_h0, ik_h1, ik_h2, ik_h3, ik_h4;
  reg [31:0] ok_h0, ok_h1, ok_h2, ok_h3, ok_h4;

  always @(posedge clk or negedge nrst)
  begin
    if (nrst == 1'b0) begin
      state <= RESET;
      ik_h0 <= 32'b0;
      ok_h0 <= 32'b0;
      h0 <= 32'b0;
      waddr <= 4'b0;
    end else begin
      case (state)
        RESET: begin
          ik_h0 <= 32'h67452301;
          ik_h1 <= 32'hEFCDAB89;
          ik_h2 <= 32'h98BADCFE;
          ik_h3 <= 32'h10325476;
          ik_h4 <= 32'hC3D2E1F0;
          ok_h0 <= 32'h67452301;
          ok_h1 <= 32'hEFCDAB89;
          ok_h2 <= 32'h98BADCFE;
          ok_h3 <= 32'h10325476;
          ok_h4 <= 32'hC3D2E1F0;
          waddr <= 4'b0;
          state <= KEYIN;
        end

        KEYIN: begin
          if (we) begin
            waddr <= waddr + 1;
            if (waddr == 15) begin
              state <= ISTART;
            end
          end
        end

        ISTART: begin
          h0 <= ik_h0;
          h1 <= ik_h1;
          h2 <= ik_h2;
          h3 <= ik_h3;
          h4 <= ik_h4;
          state <= IPAD;
        end

        IPAD: begin
          if (sha1_ready) begin
            ik_h0 <= h0 + a;
            ik_h1 <= h1 + b;
            ik_h2 <= h2 + c;
            ik_h3 <= h3 + d;
            ik_h4 <= h4 + e;
            state <= OSTART;
          end
        end

        OSTART: begin
          h0 <= ok_h0;
          h1 <= ok_h1;
          h2 <= ok_h2;
          h3 <= ok_h3;
          h4 <= ok_h4;
          state <= OPAD;
        end

        OPAD: begin
          if (sha1_ready) begin
            ok_h0 <= h0 + a;
            ok_h1 <= h1 + b;
            ok_h2 <= h2 + c;
            ok_h3 <= h3 + d;
            ok_h4 <= h4 + e;
            h0 <= ik_h0;
            h1 <= ik_h1;
            h2 <= ik_h2;
            h3 <= ik_h3;
            h4 <= ik_h4;
            state <= IDLE;
          end
        end

        IDLE: begin
          if (we) begin
            waddr <= waddr + 1;
            if (waddr == 15) begin
              state <= START;
            end
          end else if (finish) begin
            waddr <= 0;
            state <= HPAD;
          end else if (new_key) begin
            state <= RESET;
          end
        end

        START: begin
          state <= RUNNING;
        end

        RUNNING: begin
          if (sha1_ready) begin
            h0 <= h0 + a;
            h1 <= h1 + b;
            h2 <= h2 + c;
            h3 <= h3 + d;
            h4 <= h4 + e;
            state <= IDLE;
          end
        end

        HPAD: begin
          waddr <= waddr + 1;
          if (waddr == 15) begin
            state <= FINISH;
          end
        end

        FINISH: begin
            h0 <= ok_h0;
            h1 <= ok_h1;
            h2 <= ok_h2;
            h3 <= ok_h3;
            h4 <= ok_h4;
            state <= WAIT;
        end

        WAIT: begin
          if (sha1_ready) begin
            h0 <= h0 + a;
            h1 <= h1 + b;
            h2 <= h2 + c;
            h3 <= h3 + d;
            h4 <= h4 + e;
            state <= DONE;
          end
        end

        DONE: begin
          if (new_message) begin
            h0 <= ik_h0;
            h1 <= ik_h1;
            h2 <= ik_h2;
            h3 <= ik_h3;
            h4 <= ik_h4;
            state <= IDLE;
          end else if (new_key) begin
            state <= RESET;
          end
        end
      endcase
    end
  end

endmodule
