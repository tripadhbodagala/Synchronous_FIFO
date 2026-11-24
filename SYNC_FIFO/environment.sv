//environment 

class environment extends uvm_env;
`uvm_component_utils(environment)
agent agt;
scoreboard sb;
env_config e_cfg;
fifo_cfg cfg;

function new (string name ="environment", uvm_component parent);
        super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  if (!uvm_config_db #(env_config)::get(this, "", "env_config", e_cfg))
    `uvm_fatal("NOENVCFG", "environment config IS NOT WORKING")

  if (e_cfg.has_agents == 1) begin
    // pass the SAME object the test filled in (it holds the vif)
    uvm_config_db #(fifo_cfg)::set(this, "agt*", "fifo_cfg", e_cfg.cfg);
    agt = agent::type_id::create("agt", this);
  end

  if (e_cfg.has_scoreboard == 1)
    sb = scoreboard::type_id::create("sb", this);
endfunction

function void connect_phase(uvm_phase phase);
  super.connect_phase(phase);
  if (e_cfg.has_agents == 1 && e_cfg.has_scoreboard == 1)
    agt.mon.mon_port.connect(sb.item_export.analysis_export);
endfunction

endclass
