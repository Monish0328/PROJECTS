// `include "fifomem.v"
// `include "wptr_sync.v"
// `include "rptr_sync.v"
// `include "empty.v"
// `include "full.v"
module fifo1 #(
    parameter DSIZE = 8,  // Data size
  parameter ASIZE = 4   // Address size
) (
  output [DSIZE-1:0] rdata,        //  fifo depth =8(0 to 7)
                                      //  fifo address size = 3
    output wfull,
    output rempty,
    input [DSIZE-1:0] wdata,
    input winc,
    input wclk,
    input wrst_n,
    input rinc,
    input rclk, 
    input rrst_n
);

    wire [ASIZE-1:0] waddr, raddr;
    wire [ASIZE:0] wptr, rptr, wq2_rptr, rq2_wptr;

    sync_r2w sync_r2w (
        .wq2_rptr(wq2_rptr), 
        .rptr(rptr),
        .wclk(wclk), 
        .wrst_n(wrst_n)
    );

    sync_w2r sync_w2r (
        .rq2_wptr(rq2_wptr), 
        .wptr(wptr),
        .rclk(rclk), 
        .rrst_n(rrst_n)
    );

    fifomem #(DSIZE, ASIZE) fifomem (
        .rdata(rdata), 
        .wdata(wdata),
        .waddr(waddr), 
        .raddr(raddr),
        .wclken(winc), 
        .wfull(wfull),
        .wclk(wclk)
    );

    rptr_empty #(ASIZE) rptr_empty (
        .rempty(rempty),
        .raddr(raddr),
        .rptr(rptr), 
        .rq2_wptr(rq2_wptr),
        .rinc(rinc), 
        .rclk(rclk),
        .rrst_n(rrst_n)
    );

    wptr_full #(ASIZE) wptr_full (
        .wfull(wfull), 
        .waddr(waddr),
        .wptr(wptr), 
        .wq2_rptr(wq2_rptr),
        .winc(winc), 
        .wclk(wclk),
        .wrst_n(wrst_n)
    );

endmodule


module fifomem #(parameter DATASIZE = 8, // Memory data word width 
                 parameter ADDRSIZE = 4) // Number of mem address bits
(
    output [DATASIZE-1:0] rdata,
    input [DATASIZE-1:0] wdata,
    input [ADDRSIZE-1:0] waddr, raddr,
    input wclken, wfull, wclk
);
    
   `ifdef VENDORRAM
   // instantiation of a vendor's dual-port RAM
   vendor_ram mem (
       .dout(rdata), 
       .din(wdata),
       .waddr(waddr), 
       .raddr(raddr),
       .wclken(wclken),
       .wclken_n(wfull), 
       .clk(wclk)
       
   );
   `else
   // RTL Verilog memory model
   //localparam DEPTH = 1 << ADDRSIZE;
  
   localparam DEPTH = 16;
   reg [DATASIZE-1:0] mem [0:DEPTH-1];
   
     assign rdata = mem[raddr];

   always @(posedge wclk) begin
       if (wclken && !wfull) begin
           mem[waddr] <= wdata;
       end
   end
   `endif

endmodule

module sync_r2w #(parameter ADDRSIZE = 4)
(
    output reg [ADDRSIZE:0] wq2_rptr,
    input [ADDRSIZE:0] rptr,
    input wclk, wrst_n
);
    
    reg [ADDRSIZE:0] wq1_rptr;

    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            {wq2_rptr,wq1_rptr} <= 0;
        end else begin
//             {wq2_rptr,wq1_rptr} <= {wq1_rptr,rptr};
          wq1_rptr <= rptr;
          wq2_rptr <= wq1_rptr;
        end
    end

endmodule

module sync_w2r #(parameter ADDRSIZE = 4)
(
    output reg [ADDRSIZE:0] rq2_wptr,
    input [ADDRSIZE:0] wptr,
    input rclk, rrst_n
);
    
    reg [ADDRSIZE:0] rq1_wptr;

    always @(posedge rclk or negedge rrst_n) begin
          if (!rrst_n) begin
              {rq2_wptr,rq1_wptr} <= 0;
          end else begin
//               {rq2_wptr,rq1_wptr} <= {rq1_wptr,wptr};
            rq1_wptr <= wptr;
            rq2_wptr <= rq1_wptr;
          end
    end

endmodule



module rptr_empty #(parameter ADDRSIZE = 4)
(
    output reg rempty,
    output [ADDRSIZE-1:0] raddr,
    output reg [ADDRSIZE :0] rptr,
    input [ADDRSIZE :0] rq2_wptr,
    input rinc, rclk, rrst_n
);
    
    reg [ADDRSIZE:0] rbin;
    
//-------------------
// GRAYSTYLE2 pointer
//-------------------
    
    wire [ADDRSIZE:0] rgraynext, rbinnext;

    always @(posedge rclk or negedge rrst_n) begin
         if (!rrst_n) begin
             {rbin, rptr} <= 0;
         end else begin
             {rbin, rptr} <= {rbinnext, rgraynext};
         end
     end

     // Memory read-address pointer (okay to use binary to address memory)
     assign raddr = rbin[ADDRSIZE-1:0];
   //  assign rbinnext = rbin + (rinc & ~rempty);
  assign rbinnext = rbin + (rinc & ~rempty);
     assign rgraynext = (rbinnext >> 1) ^ rbinnext;

     //---------------------------------------------------------------
// FIFO empty when the next rptr == synchronized wptr or on reset
//---------------------------------------------------------------
    
     always @(posedge rclk or negedge rrst_n) begin
         if (!rrst_n) begin
             rempty <= 1'b1;
            {rbin, rptr} <= 0;
end
         else begin
           rempty <= (rgraynext == rq2_wptr) ? 1'b1 : 1'b0 ;
         end
     end

endmodule


module wptr_full #(parameter ADDRSIZE = 4)
(
    output reg wfull,
    output [ADDRSIZE-1:0] waddr,
    output reg [ADDRSIZE :0] wptr,
    input [ADDRSIZE :0] wq2_rptr,
    input winc, wclk, wrst_n
);
  
   reg [ADDRSIZE:0] wbin;
   wire [ADDRSIZE:0] wgraynext, wbinnext;

// GRAYSTYLE2 pointer

   always @(posedge wclk or negedge wrst_n) begin
       if (!wrst_n) begin
           {wbin, wptr} <= 0;
       end else begin
           {wbin, wptr} <= {wbinnext, wgraynext};
       end
   end
   
   // Memory write-address pointer (okay to use binary to address memory)
   assign waddr = wbin[ADDRSIZE-1:0];
   assign wbinnext = wbin + (winc & ~wfull);
   assign wgraynext = (wbinnext >> 1) ^ wbinnext;

//------------------------------------------------------------------
// Full condition check:
//------------------------------------------------------------------
   
   always @(posedge wclk or negedge wrst_n) begin
       if (!wrst_n) begin
           wfull <= 1'b0;
       end else begin
           // Check for full condition based on Gray code comparison.
           // If the next write pointer equals the synchronized read pointer.
         wfull <= (wgraynext == {~wq2_rptr[ADDRSIZE], wq2_rptr[ADDRSIZE-1:0]}) ? 1'b1 : 1'b0 ;
       end
   end 

endmodule

