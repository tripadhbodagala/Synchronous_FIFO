//environment config 

class env_config extends uvm_object;
        `uvm_object_utils(env_config)
        fifo_cfg cfg;

        bit has_scoreboard =1;
        bit has_agents =1;

        function new(string name="env_config");
                super.new(name);
        endfunction

endclass