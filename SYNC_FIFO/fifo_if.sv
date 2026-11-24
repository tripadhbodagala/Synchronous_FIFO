interface fifo_if(input bit clk);
  logic       rst, we, re;
  logic [3:0] din, dout;
  logic       full, empty;
  // clocking blocks and modports unchanged

clocking drv_cb@(posedge clk);
        default input #1 output #1;
        output rst,we,re,din;
        input dout, empty, full;
endclocking

clocking mon_cb@(posedge clk);
        default input #1 output #1;
        input rst,we,re,din;
        input dout, empty, full;
endclocking

modport drv_mp(clocking drv_cb);
modport mon_mp(clocking mon_cb);

endinterface