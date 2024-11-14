class i2c_transaction;

   bit start;
   bit [7:0] addr;
   bit stop;
   bit [7:0] input_data_monitor;
   bit repeated_start;
   bit write, read;
   rand bit [7:0] data  ;
   int addr_q [$];
  int monitor_data_q [$];



// randomize the varible calling from the i2c_monitor
   function void custom_randomize();
     assert(this.randomize());
   endfunction


endclass


