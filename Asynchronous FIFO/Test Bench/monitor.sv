class monitor extends uvm_monitor;
  `uvm_component_utils(monitor)
  
  
   seq_item fifo_pkt;
  virtual intf vif;
  
  uvm_analysis_port #(seq_item) item_collect_export;
  
  function new(string name="monitor",uvm_component parent = null);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collect_export=new("item_collect_port",this);

  
    if(!uvm_config_db#(virtual intf)::get(this,"","vif",vif)) 
      `uvm_fatal("APB_MONITOR","top level not set");
  endfunction
  
  
  virtual task run_phase(uvm_phase phase);
    super.run_phase(phase);
//     forever begin
      repeat(5)begin

//       seq_item fifo_pkt;
      fifo_pkt=seq_item::type_id::create("fifo_pkt",this);
      mon_write();
      mon_read();
      item_collect_export.write(fifo_pkt);
      `uvm_info("MONITOR","RUN PHASE WORKING", UVM_MEDIUM)
    end
  endtask
      
      
      
      
//       task mon_run();
        
//         @(posedge vif.wclk);
//     fifo_pkt.wrst_n<=0;
//     fifo_pkt.wdata<=0;
//     fifo_pkt.winc<=0;
//         `uvm_info("MONITOR",$sformatf("WRITE OP IN RST CODN::wrst=%0b,wdata=%0b,winc=%0b",fifo_pkt.wrst_n,fifo_pkt.wdata,fifo_pkt.winc),UVM_MEDIUM)  
    
    
    
//      @(posedge vif.wclk);
//     fifo_pkt.wrst_n<=vif.wrst_n;
    
//     fifo_pkt.winc<=vif.winc;
//     fifo_pkt.wdata<=vif.wdata;
//         `uvm_info("MONITOR",$sformatf("WRITE OPERATION::wrst=%0b,wdata=%0b,winc=%0b",fifo_pkt.wrst_n,fifo_pkt.wdata,fifo_pkt.winc),UVM_MEDIUM)  
      
//       endtask
        
        
  
  
  
  task mon_write();
    
    @(posedge vif.wclk);
//     if(vif.wrst_n==0)begin
//     fifo_pkt.winc<=vif.winc;
//     fifo_pkt.wdata<=vif.wdata;
//       `uvm_info("MONITOR","WRITE RESET CONDITION ON",UVM_NONE);
//     end
    
//     else begin
    fifo_pkt.winc<=vif.winc;
    fifo_pkt.wdata<=vif.wdata;
      `uvm_info("MONITOR"," WRITE RESET CONDITION OFF",UVM_NONE);
//     end
    
    `uvm_info("MONITOR",$sformatf("WRITE OPERATION::wrst=%0b,wdata=%0b,winc=%0b",fifo_pkt.wrst_n,fifo_pkt.wdata,fifo_pkt.winc),UVM_MEDIUM) 
  endtask
  
  
  
  
   task mon_read();
    
     @(posedge vif.rclk);
//    if(vif.rrst_n==0)begin
//     fifo_pkt.rinc<=vif.rinc;
//     fifo_pkt.rdata<=vif.rdata;
//      `uvm_info("DRIVER","READ RESET CONDITION ON",UVM_NONE);
//     end
    
//     else begin
    fifo_pkt.rinc<=vif.rinc;
    fifo_pkt.rdata<=vif.rdata;
     `uvm_info("MONITOR","READ RESET CONDITION OFF",UVM_NONE);
//     end
     `uvm_info("MONITOR",$sformatf("READ OPERATION::rrst=%0b,rdata=%0b,rinc=%0b",fifo_pkt.rrst_n,fifo_pkt.rdata,fifo_pkt.rinc),UVM_MEDIUM) 
  
  endtask
        
        
endclass