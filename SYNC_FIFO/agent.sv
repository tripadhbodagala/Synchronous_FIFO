//agent 
class agent extends uvm_agent;
  `uvm_component_utils(agent)

  driver    drv;
  monitor   mon;
  sequencer seqr;
  fifo_cfg  cfg;

  function new(string name = "agent", uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db #(fifo_cfg)::get(this, "", "fifo_cfg", cfg))
      `uvm_fatal("NOCFG", "config IS NOT WORKING")

    mon = monitor::type_id::create("mon", this);
    if (cfg.is_active == UVM_ACTIVE) begin
      drv  = driver::type_id::create("drv", this);
      seqr = sequencer::type_id::create("seqr", this);
    end
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    if (cfg.is_active == UVM_ACTIVE)
      drv.seq_item_port.connect(seqr.seq_item_export);
  endfunction
endclass