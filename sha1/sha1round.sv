module sha1round(
  input[6:0] t,
  input[31:0] a, b, c, d, e, w,
  output[159:0] out
);

  function automatic [31:0] sha1_k(input[6:0] t);
  begin
    sha1_k = (t <= 7'd20) ? 32'h5A827999 :
             (t <= 40) ? 32'h6ED9EBA1 :
             (t <= 60) ? 32'h8F1BBCDC : 32'hCA62C1D6;
  end
  endfunction

  function automatic [31:0] sha1_f(input[6:0] t);
  begin
    logic [31:0] f20 = (b & c) | ((~b) & d);
    logic [31:0] f40 = b ^ c ^ d;
    logic [31:0] f60 = (b & c) | (b & d) | (c & d);

    sha1_f = (t <= 20) ? f20 :
             (t <= 40) ? f40 :
             (t <= 60) ? f60 : f40;
  end
  endfunction

  function automatic [159:0] sha1op(
      input[6:0] t,
      input[31:0] a, b, c, d, e, w);
  begin
    logic [31:0] na = {a[26:0], a[31:27]} + sha1_f(t) + e + sha1_k(t) + w;
    logic [31:0] nc = {b[1:0], b[31:2]};

    sha1op = {na, a, nc, c, d};
  end
  endfunction

  assign out = sha1op(t, a, b, c, d, e, w);

endmodule
