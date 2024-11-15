class agent extends uvm_agent;
  
  driver dri;
  sequencer  sqr;
  monitor mon;
  
  
//virtual intf vif;
  
  `uvm_component_utils(agent);
  
  function new(string name="agent",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  
   function void build_phase(uvm_phase phase);
    super.build_phase(phase);  
//     if(get_is_active()==UVM_ACTIVE)begin
      dri = driver::type_id::create("dri", this);
      sqr = sequencer::type_id::create("sqr", this);
//     end
    
      mon = monitor::type_id::create("mon", this);
         `uvm_info("AGENT", "BUILD PHASE::OBJECT CREATED FOR ACTIVE AGENT", UVM_LOW);

  endfunction
    
    function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
//       if(get_is_active()==UVM_ACTIVE)
        dri.seq_item_port.connect(sqr.seq_item_export);
      `uvm_info("AGENT", "CONNECT PHASE:: PORT CONNECTION DRI-SQR", UVM_LOW);
   endfunction
    
  
endclass