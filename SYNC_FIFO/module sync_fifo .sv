module sync_fifo (
  input  logic       clk, rst, we, re,
  input  logic [3:0] din,
  output logic [3:0] dout,
  output logic       full, empty
);
  logic [3:0] mem [16];
  logic [4:0] wptr, rptr;

  // write side
  always_ff @(posedge clk) begin
    if (rst) begin
      wptr <= '0;
      for (int i = 0; i < 16; i++) mem[i] <= '0;
    end
    else if (we && !full) begin
      mem[wptr[3:0]] <= din;
      wptr           <= wptr + 1;
    end
  end

  // read side (registered output)
  always_ff @(posedge clk) begin
    if (rst) begin
      rptr <= '0;
      dout <= '0;
    end
    else if (re && !empty) begin
      dout <= mem[rptr[3:0]];
      rptr <= rptr + 1;
    end
  end

  assign empty = (wptr == rptr);
  assign full  = (wptr[3:0] == rptr[3:0]) && (wptr[4] != rptr[4]);
endmodule