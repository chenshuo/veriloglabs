module aes_encrypt_top(
  input clk, nrst, wr, start,
  input [2:0] waddr,
  input [1:0] raddr,
  input [31:0] in,
  output [31:0] out,
  output finish, bus_free
);

  reg[127:0]    plain_text, key;
  wire[127:0]   cipher_text;

  assign out = raddr == 2'b11 ? cipher_text[127:96] :
    raddr == 2'b10 ? cipher_text[95:64] :
    raddr == 2'b01 ? cipher_text[63:32] : cipher_text[31:0];

  always @(posedge clk or negedge nrst)
  begin
    if (nrst == 1'b0) begin
      plain_text <= 128'b0;
      key <= 128'b0;
    end
    else begin
      if (wr) begin
        case (waddr)
          3'b000: plain_text[31:0] <= in;
          3'b001: plain_text[63:32] <= in;
          3'b010: plain_text[95:64] <= in;
          3'b011: plain_text[127:96] <= in;
          3'b100: key[31:0] <= in;
          3'b101: key[63:32] <= in;
          3'b110: key[95:64] <= in;
          3'b111: key[127:96] <= in;
        endcase
      end
    end
  end

  aes_encrypt_core aes_core(clk, nrst, start,
    plain_text, key, cipher_text,
    finish, bus_free);
endmodule

