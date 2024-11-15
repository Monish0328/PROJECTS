class test extends uvm_test;
  `uvm_component_utils(test);
  
  environment envi;
  reset_sequens sequ_rst;
  write_sequens sequ_wr;
  read_sequens  sequ_rd;
  read_write_sequens sequ_rd_wr;
  
  function new(string name="test",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    envi=environment::type_id::create("envi",this);
    sequ_rst=reset_sequens::type_id::create("sequ_rst");
    sequ_wr=write_sequens::type_id::create("sequ_wr");
    sequ_rd=read_sequens::type_id::create("sequ_rd");
    sequ_rd_wr=read_write_sequens::type_id::create("sequ_rd_wr");
    `uvm_info("TEST","build phase working object created",UVM_MEDIUM);
  endfunction
  
  
//   function void connect_phase(uvm_phase phase);
//     super.connect_phase(phase);
//     `uvm_info("TEST","connect phase working object created",UVM_MEDIUM);
//   endfunction
  
  
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
    
   
     phase.raise_objection(this);
    `uvm_info("TEST","run_phase:: inside raise objection ",UVM_MEDIUM);
     forever begin
//     repeat(2)begin
//     sequ_rst.start(envi.agt.sqr);
//     `uvm_info("TEST","run_phase working reset seqns started",UVM_MEDIUM);
//      end
    #20;
//     sequ_wr.start(envi.agt.sqr);
//     `uvm_info("TEST","run_phase working write seqns started",UVM_MEDIUM); 
//     #80;
    
//     sequ_rd.start(envi.agt.sqr);
//     `uvm_info("TEST","run_phase working read seqns started",UVM_MEDIUM); 
    
        sequ_rd_wr.start(envi.agt.sqr);
       `uvm_info("TEST","run_phase working read write seqns started",UVM_MEDIUM); 
       
     end
    phase.drop_objection(this);
   `uvm_info("TEST","END OF TESTCASE",UVM_LOW);
    
   endtask
  
  
endclass
  
  
  