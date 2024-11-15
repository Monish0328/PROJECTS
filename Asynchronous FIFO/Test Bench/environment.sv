class environment extends uvm_env;
  `uvm_component_utils(environment);
  
  agent agt;
  scoreboard sb;
  
  function new(string name= "environment",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agt=agent::type_id::create("agt",this);
    sb=scoreboard::type_id::create("sb",this);
    set_config_int("agt", "is_active", UVM_ACTIVE);
    `uvm_info("ENVI"," build phase working",UVM_MEDIUM);
  endfunction
  
  function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
    agt.mon.item_collect_export.connect(sb.item_collect_port);
    `uvm_info("ENVI"," connect phase working",UVM_MEDIUM);
    
   endfunction

  
  
  
endclass
  
  
  