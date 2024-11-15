class seq_item extends uvm_sequence_item;
  
 `uvm_object_utils(seq_item);
  
  function new(string name="seq_item");
    super.new(name);
  endfunction
  

  
  
  bit [`DSIZE-1:0] rdata;
  logic wfull;
  logic rempty;
  rand bit [`DSIZE-1:0] wdata;
  rand logic wrst_n;
  rand logic winc;
  rand logic rinc;
  rand logic rrst_n;
//   logic underflow;
//   logic overflow;
//   logic almost_full;
//   logic almost_empty;
  
  integer  wr_en_on=80;
   integer rd_en_on=90;
  
  constraint rd_rst { rrst_n dist { 0 := 2, 1:=98};}
  constraint wr_rst { wrst_n dist { 0 := 2, 1:=98};}
  
  constraint cn_wen {winc dist { 0:=100-wr_en_on,1:= wr_en_on};};
  
  constraint cn_ren {rinc dist { 0:=100-rd_en_on,1:= rd_en_on};};
  
  
  constraint wr_only {winc ==1'b1 && rinc==1'b0;};
  constraint rd_only {rinc ==1'b1 && winc==1'b0;};
  
  
  
endclass