`include "uvm_macros.svh"
import uvm_pkg::*;

`include "interface.sv"
`include "defines.sv"
`include "seq_item.sv"
`include "sequence.sv"
`include "sequencer.sv"
`include "driver.sv"
`include "monitor.sv"
`include "agent.sv"
`include "scoreboard.sv"
`include "environment.sv"
`include "test.sv"

`timescale 1ns/1ns

module testbench;
 
  test tst;
   intf vif();
  
//   reg [`ASIZE-1:0] waddr, raddr;
//   wire [`ASIZE:0] wptr, rptr;

  
  fifo1  #(
    .DSIZE(8),  // Data size
    .ASIZE(4)   // Address size
  ) 
  dut(
    
      .rempty(vif.rempty),
      .rdata(vif.rdata),
      .wfull(vif.wfull),
      .wdata(vif.wdata),
      .winc(vif.winc),
      .wclk(vif.wclk),
      .wrst_n(vif.wrst_n),
      .rinc(vif.rinc),
      .rclk(vif.rclk),
      .rrst_n(vif.rrst_n)
  //  .rptr(vif.rptr),
  //  .wptr(vif.wptr)
);

  initial begin
    uvm_config_db#(virtual intf#(.DSIZE(`DSIZE),.ASIZE(`ASIZE)))::set(null,"*","vif",vif);
    run_test("test");
  end
  
    initial begin
      vif.wclk=0;
     vif.rclk=0;
      #20 vif.wrst_n=0;
       vif.rrst_n=0;
      
      
      #20 vif.wrst_n=1;
      #10 vif.rrst_n=1;
      
     #5 vif.winc=1;
      #30 vif.rinc=1;
      
       #650 $finish;

    end
  
//    initial begin
// //       vif.wclk=0;
//      vif.rclk=0;
// //    #5   vif.wrst_n=0;
//       #5 vif.rrst_n=0;
      
// //       #15 vif.wrst_n=1;
//       #15 vif.rrst_n=1;
      
      
//        #100 $finish;

//     end
  
  initial begin
    $dumpfile("fifo1.vcd");
    $dumpvars(0,testbench);
  end
  
  
  
  always #12.5  vif.wclk=~vif.wclk;
  always #20 vif.rclk=~vif.rclk;

endmodule
  
