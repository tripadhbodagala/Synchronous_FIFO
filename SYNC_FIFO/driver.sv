//DRIVER
class driver extends uvm_driver #(fifo_txn);
  `uvm_component_utils(driver)

  virtual fifo_if.drv_mp vif;
  fifo_cfg               cfg;

  function new(string name = "driver", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(fifo_cfg)::get(this, "", "fifo_cfg", cfg))
      `uvm_fatal("NOCFG", "config IS NOT WORKING")
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    vif = cfg.vif;
  endfunction

  task run_phase(uvm_phase phase);
    // initial reset so the DUT and scoreboard start from a known state
    @(vif.drv_cb);
    vif.drv_cb.rst <= 1;
    vif.drv_cb.we  <= 0;
    vif.drv_cb.re  <= 0;
    vif.drv_cb.din <= 0;
    repeat (2) @(vif.drv_cb);

    forever begin
      seq_item_port.get_next_item(req);
      drive_dut(req);
      seq_item_port.item_done();
    end
  endtask

  task drive_dut(fifo_txn txn);
    @(vif.drv_cb);
    vif.drv_cb.rst <= txn.rst;
    vif.drv_cb.we  <= txn.we;
    vif.drv_cb.re  <= txn.re;
    vif.drv_cb.din <= txn.din;
  endtask
endclass
