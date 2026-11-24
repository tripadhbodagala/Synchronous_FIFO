class fifo_txn extends uvm_sequence_item;
 `uvm_object_utils(fifo_txn)
 bit clk;
 rand bit we, re, rst;
 rand bit[3:0] din;
 bit [3:0] dout;
 bit full, empty;
 function new(string name ="fifo_txn");
         super.new(name);
 endfunction

 function void do_print(uvm_printer printer);
         super.do_print(printer);
                printer.print_field("rst",this.rst,1,UVM_BIN);
                printer.print_field("we",this.we,1,UVM_BIN);
                printer.print_field("re",this.re,1,UVM_BIN);
                printer.print_field("din",this.din,4,UVM_BIN);
                printer.print_field("dout",this.dout,4,UVM_BIN);
                printer.print_field("full",this.full,1,UVM_BIN);
                printer.print_field("empty",this.empty,1,UVM_BIN);
        endfunction

endclass:fifo_txn
