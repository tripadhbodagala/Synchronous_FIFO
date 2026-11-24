//monitor
class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)

  virtual fifo_if.mon_mp        vif;
  fifo_cfg                      cfg;
  uvm_analysis_port #(fifo_txn) mon_port;

  function new(string name = "monitor", uvm_component parent);
    super.new(name, parent);
    mon_port = new("mon_port", this);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(fifo_cfg)::get(this, "", "fifo_cfg", cfg))
      `uvm_fatal("NOCFG", "config IS NOT WORKING")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = cfg.vif;
    if (vif == null)
      `uvm_fatal("MON", "cfg.vif is null; this cfg is not the object the test filled in")
  endfunction

  task run_phase(uvm_phase phase);
    fifo_txn txn;
    forever begin
      @(vif.mon_cb);
      txn = fifo_txn::type_id::create("txn");
      txn.rst   = vif.mon_cb.rst;
      txn.we    = vif.mon_cb.we;
      txn.re    = vif.mon_cb.re;
      txn.din   = vif.mon_cb.din;
      txn.dout  = vif.mon_cb.dout;
      txn.full  = vif.mon_cb.full;
      txn.empty = vif.mon_cb.empty;
      mon_port.write(txn);
    end
  endtask
endclass

