module sha1top
(
  input clk, nrst,
  input wr, last,
  input [31:0] in,
  input [1:0] last_len,  // 0 ~ 3
  input [2:0] haddr,

  output [31:0] out,
  output done, busy
);

  wire reset_n;
  reset r(clk, nrst, reset_n);

  logic write;
  logic [31:0] cin;
  wire [31:0] h0, h1, h2, h3, h4;
  wire busy0;

  sha1core core(clk, reset_n, write, cin,
    h0, h1, h2, h3, h4, busy0);

  assign out = (haddr == 0) ? h0:
               (haddr == 1) ? h1:
               (haddr == 2) ? h2:
               (haddr == 3) ? h3:
               (haddr == 4) ? h4:
               32'bz;
  assign busy = busy0 || state == PADDING || state == LENGTH;
  assign done = state == DONE && !busy;

  wire [2:0] len = last ? {1'b0, last_len} : 3'd4;

  always_comb begin
    case (state)
      IDLE: begin
        write = wr;
        if (!last)
          cin = in;
        else begin
          if (last_len == 0)
            cin = 32'h8000_0000;
          else if (last_len == 1)
            cin = {in[31:24], 24'h80_0000};
          else if (last_len == 2)
            cin = {in[31:16], 16'h8000};
          else
            cin = {in[31:8], 8'h80};
        end
      end
      PADDING: begin
        write = 1;
        cin = 0;
      end
      LENGTH: begin
        write = 1;
        cin = {16'd0, length} << 3;
      end
      DONE: begin
        write = 0;
        cin = 0;
      end
    endcase
  end

  reg [15:0] length;  // 64KiB max
  reg [3:0] pad;  // how many words to pad

  localparam IDLE = 0, PADDING = 1, LENGTH = 2, DONE = 3;
  reg [1:0] state;

  function automatic [3:0] pad_len(input[15:0] len);
  begin
    logic [3:0] pos = len[5:2];
    return pos == 14 ? 15 :
           pos == 15 ? 14 : (13 - pos);
  end
  endfunction

  always_ff @(posedge clk or negedge reset_n)
  begin
    if (reset_n == 1'b0) begin
      length <= 0;
      state <= IDLE;
    end
    else if (!busy0) begin
      case (state)
        IDLE: begin
          if (wr)
            length <= length + {13'b0, len};
          if (wr && last) begin
            state <= PADDING;
            pad <= pad_len(length);
          end
        end
        PADDING: begin
          if (pad == 0)
            state <= LENGTH;
          pad <= pad - 1;
        end
        LENGTH: begin
          state <= DONE;
        end
      endcase
    end
  end

endmodule
