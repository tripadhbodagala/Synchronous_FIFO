//SCOREBOARD 

class scoreboard extends uvm_scoreboard;
  `uvm_component_utils(scoreboard)

  uvm_tlm_analysis_fifo #(fifo_txn) item_export;

  localparam int DEPTH = 16;

  // ---- reference model and checking state ----
  bit [3:0] ref_q[$];          // reference model: a pure queue
  bit [3:0] exp_data;
  bit       exp_valid;         // a read was accepted last cycle, dout is due now
  bit       seen_reset;
  int       pass_cnt, fail_cnt;

  // ---- coverage sample variables ----
  int unsigned occ;            // occupancy BEFORE this edge's operation
  bit          cv_we, cv_re;
  bit          cv_full, cv_empty;   // flags reported by the DUT
  bit [3:0]    cv_din, cv_dout;
  bit          cv_dout_valid;       // dout was compared this cycle

  covergroup fifo_cg;
    option.per_instance = 1;
    option.comment      = "sync FIFO functional coverage";

    cp_we : coverpoint cv_we { bins idle = {0}; bins write = {1}; }
    cp_re : coverpoint cv_re { bins idle = {0}; bins read  = {1}; }

    // how full the FIFO is
    cp_occ : coverpoint occ {
      bins empty = {0};
      bins low   = {[1:4]};
      bins mid   = {[5:11]};
      bins high  = {[12:15]};
      bins full  = {16};
    }

    // occupancy transitions between consecutive clocks
    cp_occ_trans : coverpoint occ {
      bins first_write  = (0  => 1);
      bins last_read    = (1  => 0);
      bins becomes_full = (15 => 16);
      bins leaves_full  = (16 => 15);
    }

    // flags as seen on the DUT
    cp_full_flag  : coverpoint cv_full  { bins low = {0}; bins high = {1}; }
    cp_empty_flag : coverpoint cv_empty { bins low = {0}; bins high = {1}; }

    // every data value written, and every data value read back
    cp_din  : coverpoint cv_din  iff (cv_we)         { bins val[] = {[0:15]}; }
    cp_dout : coverpoint cv_dout iff (cv_dout_valid) { bins val[] = {[0:15]}; }

    // operation x occupancy: 2 x 2 x 5 = 20 bins, includes
    //   write at full (overflow attempt), read at empty (underflow attempt),
    //   simultaneous read+write at empty / mid / full, and idle at every level
    cx_op_occ : cross cp_we, cp_re, cp_occ;
  endgroup

  // what occupancy the FIFO had when reset hit
  covergroup reset_cg;
    option.per_instance = 1;
    cp_occ_at_reset : coverpoint occ {
      bins on_empty = {0};
      bins partial  = {[1:15]};
      bins on_full  = {16};
    }
  endgroup

  function new(string name = "scoreboard", uvm_component parent);
    super.new(name, parent);
    fifo_cg  = new();
    reset_cg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_export = new("item_export", this);
  endfunction

  // pulls one transaction per clock from the monitor
  task run_phase(uvm_phase phase);
    fifo_txn tx;
    forever begin
      item_export.get(tx);
      process(tx);
    end
  endtask

  // renamed from 'check': uvm_component already has a method called check
  function void sb_check(bit cond, string msg);
    if (cond) pass_cnt++;
    else begin
      fail_cnt++;
      `uvm_error("SB", msg)
    end
  endfunction

  // one call per clock, with values sampled just BEFORE the edge
  function void process(fifo_txn tx);
    bit exp_full, exp_empty, do_wr, do_rd;

    // reset: the DUT clears at this edge, so clear the model too
    if (tx.rst) begin
      if (seen_reset) begin
        occ = ref_q.size();            // occupancy being cleared
        reset_cg.sample();
      end
      ref_q.delete();
      exp_valid  = 0;
      seen_reset = 1;
      return;
    end
    if (!seen_reset) return;           // ignore X values before the first reset

    occ       = ref_q.size();          // take it BEFORE the pop/push below
    exp_full  = (ref_q.size() == DEPTH);
    exp_empty = (ref_q.size() == 0);
    do_wr     = tx.we && !exp_full;
    do_rd     = tx.re && !exp_empty;

    // 1. flags (they show the state before this edge)
    sb_check(tx.full == exp_full,
             $sformatf("FULL mismatch: exp=%0b got=%0b size=%0d", exp_full, tx.full, ref_q.size()));
    sb_check(tx.empty == exp_empty,
             $sformatf("EMPTY mismatch: exp=%0b got=%0b size=%0d", exp_empty, tx.empty, ref_q.size()));

    // 2. data from the read accepted on the PREVIOUS edge
    cv_dout_valid = 0;
    if (exp_valid) begin
      sb_check(tx.dout == exp_data,
               $sformatf("DATA mismatch: exp=%0h got=%0h", exp_data, tx.dout));
      cv_dout       = tx.dout;
      cv_dout_valid = 1;
      exp_valid     = 0;
    end

    // coverage: capture this cycle and sample (occ is still the pre-edge value)
    cv_we    = tx.we;
    cv_re    = tx.re;
    cv_din   = tx.din;
    cv_full  = tx.full;
    cv_empty = tx.empty;
    fifo_cg.sample();

    // 3. read accepted at this edge: take the expected value now, compare next sample
    if (do_rd) begin
      exp_data  = ref_q.pop_front();
      exp_valid = 1;
    end

    // 4. write accepted at this edge
    if (do_wr) ref_q.push_back(tx.din);
  endfunction

  function void report_phase(uvm_phase phase);
    `uvm_info("SB", $sformatf("PASS=%0d FAIL=%0d, left in model=%0d",
                              pass_cnt, fail_cnt, ref_q.size()), UVM_LOW)
    `uvm_info("COV", $sformatf("fifo_cg=%0.2f%%  reset_cg=%0.2f%%",
              fifo_cg.get_inst_coverage(), reset_cg.get_inst_coverage()), UVM_LOW)
    if (pass_cnt == 0) 
         `uvm_error("SB", "nothing was checked: no transactions reached the scoreboard")
    else if (fail_cnt == 0) 
      `uvm_info("SB", "TEST PASSED", UVM_LOW)
    else        
      `uvm_error("SB", "TEST FAILED")
endfunction
endclass
