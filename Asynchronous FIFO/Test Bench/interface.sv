interface intf #(
    parameter DSIZE = 8,  // Data size
    parameter ASIZE = 4   // Address size
);
  
  logic [DSIZE-1:0] rdata;
  logic [DSIZE-1:0] wdata;
  logic winc;
  logic wfull;
  logic rempty;
  logic wclk;
  logic wrst_n;
  logic rinc;
  logic rclk;
  logic rrst_n;
  
//   logic [ASIZE-1:0] waddr, raddr;
//   logic [ASIZE:0] wptr, rptr;
  
//   logic underflow;
//   logic overflow;
//   logic almost_full;
//   logic almost_empty;
  
  
endinterface