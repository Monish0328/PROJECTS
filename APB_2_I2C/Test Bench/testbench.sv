`include "apb_2_i2c_pkg.svh"
`include "apb_interface.sv"
`include "i2c_interface.sv"

`timescale 1ns/1ps
module top;
  apb_interface apb_intf();
  i2c_interface i2c_intf();
  apb_2_i2c_test test;

  apb_i2c #(
    .APB_ADDR_WIDTH(`APB_ADDR_WIDTH)  // Replace with your parameter value
  ) DUT (
    .HCLK(apb_intf.HCLK),
    .HRESETn(apb_intf.HRESETn),
    .PADDR(apb_intf.PADDR),
    .PWDATA(apb_intf.PWDATA),
    .PWRITE(apb_intf.PWRITE),
    .PSEL(apb_intf.PSEL),
    .PENABLE(apb_intf.PENABLE),
    .PRDATA(apb_intf.PRDATA),
    .PREADY(apb_intf.PREADY),
    .PSLVERR(apb_intf.PSLVERR),
    .interrupt_o(apb_intf.interrupt_o),
    .scl_pad_i(i2c_intf.scl_pad_i),
    .scl_pad_o(i2c_intf.scl_pad_o),
    .scl_padoen_o(i2c_intf.scl_padoen_o),
    .sda_pad_i(i2c_intf.sda_pad_i),
    .sda_pad_o(i2c_intf.sda_pad_o),
    .sda_padoen_o(i2c_intf.sda_padoen_o)
  );

  // Initial block for setting up initial conditions
  initial begin
    test = new;
    test.env.apb_if = apb_intf;
    test.env.i2c_if = i2c_intf;
    // Initialize clock and reset
    apb_intf.HCLK = 0;
    apb_intf.HRESETn = 0;
    #15 apb_intf.HRESETn = 1;  // Release reset after 15 time units

    // Initialize testbench with interfaces

    // Start simulation
    $dumpfile("apb_i2c.vcd");
    $dumpvars(0, top);
    test.run();
    $finish;
  end


  // Clock generation
  always #5 apb_intf.HCLK = ~apb_intf.HCLK;

 assign i2c_intf.scl_pad_i = i2c_intf.scl_padoen_o;
endmodule

