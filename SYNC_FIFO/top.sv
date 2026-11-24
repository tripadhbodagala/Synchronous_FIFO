//top 
module top;
        import fifo_pkg::*;
        import uvm_pkg::*;
        `include "uvm_macros.svh"

       bit clk;
			initial forever #5 clk = ~clk;

        fifo_if INTF(clk);

        sync_fifo DUT(.clk(clk),
        .rst(INTF.rst),
        .we(INTF.we),
        .re(INTF.re),
         .din(INTF.din),
         .dout(INTF.dout),
         .full(INTF.full),
         .empty(INTF.empty));

 initial begin
  `ifdef VCS
  $fsdbDumpvars(0,top);
  `endif

          uvm_config_db #(virtual fifo_if)::set(null,"*","fifo_if", INTF);
          //call run_test
          run_test("test");
        end
endmodule