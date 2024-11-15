class driver extends uvm_driver#(seq_item);
  `uvm_component_utils(driver)
  
   seq_item fifo_pkt;
  virtual intf vif;
  
  function new(string name="driver",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
//     fifo_pkt=new();
    
//         fifo_pkt=seq_item::type_id::create("fifo_pkt",this);
    if(!uvm_config_db#(virtual intf)::get(this,"*","vif",vif)) 
      `uvm_fatal("APB_DRIVER","top level not set");
  endfunction
  
  virtual task run_phase(uvm_phase phase);
    
    super.run_phase(phase);
   
    forever begin
//     repeat(2)begin
//     seq_item fifo_pkt;
      
      fifo_pkt=seq_item::type_id::create("fifo_pkt",this);
      `uvm_info("DRIVER","run phase working",UVM_MEDIUM);
      seq_item_port.get_next_item(fifo_pkt);
       
//       fork 
      fifo_write(fifo_pkt);
      fifo_read(fifo_pkt);
//       join_any
      
//           @(posedge vif.wclk);

      seq_item_port.item_done();
    end
  endtask
  
  
  task fifo_write(seq_item fifo_pkt);
    
    @(posedge vif.wclk);
    if(vif.wrst_n==0)begin
    vif.winc<=0;
    vif.wdata<=0;
      `uvm_info("DRIVER","WRITE RESET CONDITION ON",UVM_NONE);
    end
    
    else begin
    vif.winc<=fifo_pkt.winc;
    vif.wdata<=fifo_pkt.wdata;
      `uvm_info("DRIVER"," WRITE RESET CONDITION OFF",UVM_NONE);
    end
    
    
    
//     
    
//      @(posedge vif.wclk);
//     fifo_pkt.waddr<=vif.waddr;
//     fifo_pkt.wptr<=vif.wptr;
//     fifo_pkt.rptr<=vif.rptr;
//     fifo_pkt.rq2_wptr<=vif.rq2_wptr;
    
//     `uvm_info("DRIVER",$sformatf("WRITE OPERATION::wrst=%0b,wdata=%0b,winc=%0b,wptr=%0d,rptr=%0b",vif.wrst_n,vif.wdata,vif.winc, fifo_pkt.wptr, fifo_pkt.rptr),UVM_MEDIUM)  
    
    
    
//      @(posedge vif.wclk);
// //     vif.wrst_n<=1;
// //     if(vif.wrst_n==1)begin
    
// //     vif.winc<=1;
// //     vif.wdata<=fifo_pkt.wdata;
// //     end
    
//       @(posedge vif.wclk);
// //     fifo_pkt.waddr<=vif.waddr;
//     fifo_pkt.wptr<=vif.wptr;
//     fifo_pkt.rptr<=vif.rptr;
// //     fifo_pkt.rq2_wptr<=vif.rq2_wptr;
    
    `uvm_info("DRIVER",$sformatf("WRITE OPERATION::wrst=%0b,wdata=%0b,winc=%0b",vif.wrst_n,vif.wdata,vif.winc),UVM_MEDIUM) 
  endtask
  
  
 task fifo_read(seq_item fifo_pkt);
    
   @(posedge vif.rclk);
   if(vif.rrst_n==0)begin
    vif.rinc<=0;
    vif.rdata<=0;
     `uvm_info("DRIVER","READ RESET CONDITION ON",UVM_NONE);
    end
    
    else begin
    vif.rinc<=fifo_pkt.rinc;
    fifo_pkt.rdata<=vif.rdata;
      `uvm_info("DRIVER","READ RESET CONDITION OFF",UVM_NONE);
    end
    
    
    
    
    
//      @(posedge vif.wclk);
//     fifo_pkt.waddr<=vif.waddr;
//     fifo_pkt.wptr<=vif.wptr;
//     fifo_pkt.rptr<=vif.rptr;
//     fifo_pkt.rq2_wptr<=vif.rq2_wptr;
    
//     `uvm_info("DRIVER",$sformatf("WRITE OPERATION::wrst=%0b,wdata=%0b,winc=%0b,wptr=%0d,rptr=%0b",vif.wrst_n,vif.wdata,vif.winc, fifo_pkt.wptr, fifo_pkt.rptr),UVM_MEDIUM)  
    
    
    
//      @(posedge vif.wclk);
// //     vif.wrst_n<=1;
// //     if(vif.wrst_n==1)begin
    
// //     vif.winc<=1;
// //     vif.wdata<=fifo_pkt.wdata;
// //     end
    
//       @(posedge vif.wclk);
// //     fifo_pkt.waddr<=vif.waddr;
//     fifo_pkt.wptr<=vif.wptr;
//     fifo_pkt.rptr<=vif.rptr;
// //     fifo_pkt.rq2_wptr<=vif.rq2_wptr;
    
   `uvm_info("DRIVER",$sformatf("READ OPERATION::rrst=%0b,rdata=%0b,rinc=%0b",vif.rrst_n,fifo_pkt.rdata,vif.rinc),UVM_MEDIUM) 
  
  endtask
endclass