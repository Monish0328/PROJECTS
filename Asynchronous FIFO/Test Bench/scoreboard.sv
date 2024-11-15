class scoreboard extends uvm_scoreboard;
  
  `uvm_component_utils(scoreboard);
  
  uvm_analysis_export #(seq_item) item_collect_port;
  uvm_tlm_analysis_fifo #(seq_item) sb_fifo;
  seq_item pkt;
//   virtual intf vif;
  
  
  bit [`DSIZE-1:0] read_data_sb;
  bit wfull;
  bit rempty;
  bit [`DSIZE-1:0] write_data_sb[$];
  
  
  function new(string name="scoreboard",uvm_component parent);
    super.new(name,parent);
  endfunction
  
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    item_collect_port=new("item_collect_port",this);
    sb_fifo=new("sb_fifo",this);
    `uvm_info("SCOREBOARD", "BUILD PHASE::OBJECT CREATED FOR PORT", UVM_LOW);
  endfunction

  
  function void connect_phase(uvm_phase phase);
     super.connect_phase(phase);
    item_collect_port.connect(sb_fifo.analysis_export);
//      item_collect_export.get(pkt);
   endfunction
  
  
  
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
      
    `uvm_info("SCOREBOARD", "RUN PHASE::INSIDE", UVM_LOW);
    forever begin
//     repeat(2)begin
      sb_fifo.get(pkt);  
      
      `uvm_info("SCOREBOARD", "RUN PHASE::GET FROM MONITOR PORT", UVM_LOW);
    
      if(pkt.wrst_n && !pkt.wfull && pkt.winc)begin
      
        write_data_sb.push_front(pkt.wdata);
        `uvm_info("SCOREBOARD", $sformatf("data in queue:din=%0d",pkt.wdata), UVM_LOW);
      end
      else  `uvm_info("SCOREBOARD", "FIFO FULL", UVM_LOW); 
        
      
    
    
      if(pkt.rrst_n && !pkt.rempty && pkt.rinc) begin 
        if(write_data_sb.pop_back()== pkt.rdata)begin
          `uvm_info("SCOREBOARD", " PASS", UVM_LOW);
        end
              else
                `uvm_info("SCOREBOARD", "FAIL", UVM_LOW);
              end
      
//       if(write_data_sb == pkt.wdata)begin
//       $display("WRITE DATA MATCHED ::write_data_SB=%0b,vif.wdata=%0b",write_data_sb,vif.wdata);
//     end
//       else begin
//         $display("WRITE DATA NOT MATCHED:: write_data_SB=%0b,vif.wdata=%0b",write_data_sb,vif.wdata);
//     end
      
      
    end
    
  endtask
  
endclass