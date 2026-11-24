class test extends uvm_test;
 `uvm_component_utils(test)
 env_config e_cfg;
 fifo_cfg cfg;
 environment env;
 agent agt;
 sequencee seq;
 sequencer seqr;

 bit has_scoreboard =1;
 bit has_agents =1;

function new (string name="test",uvm_component parent);
        super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
  super.build_phase(phase);
  e_cfg = env_config::type_id::create("e_cfg");

  if (has_agents == 1) begin
    cfg = fifo_cfg::type_id::create("cfg");
    e_cfg.cfg = cfg;
    if (!uvm_config_db #(virtual fifo_if)::get(this, "", "fifo_if", cfg.vif))
      `uvm_fatal("NOVIF", "virtual interface not found in config DB")
    if (cfg.vif == null)
      `uvm_fatal("TEST", "get succeeded but vif is null; top.sv stored a null interface")
  end

  e_cfg.has_scoreboard = has_scoreboard;
  e_cfg.has_agents     = has_agents;
  uvm_config_db #(env_config)::set(this, "*", "env_config", e_cfg);

  env = environment::type_id::create("env", this);
  seq = sequencee::type_id::create("seq");
endfunction


function void start_of_simulation_phase(uvm_phase phase);
//      super.start_of_simulation_phase(phase)
        uvm_top.print_topology();
endfunction


task run_phase(uvm_phase phase);
  phase.raise_objection(this);
  seq.start(env.agt.seqr);
  #100ns;                      // let the last transactions reach the scoreboard
  phase.drop_objection(this);
endtask


endclass