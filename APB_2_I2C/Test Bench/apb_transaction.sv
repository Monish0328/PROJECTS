class apb_transaction;
      logic PENABLE; 
      logic PSEL ;  
      logic PWRITE ; 
 rand logic [`APB_ADDR_WIDTH-1 : 0] PADDR ;
 rand logic [31:0] PWDATA;
 rand logic [31:0] PRDATA;  
      logic PREADY;
 rand       oper_mode op;
 rand       reg_type  reg_t;

 rand logic [31:0] data_to_write;
 rand logic [31:0] address_to_write;
 rand logic [31:0] address_to_read;
 rand logic [31:0] rd_mem_loc;
      
 bit        [7:0] sts_read_data;



 rand logic [31:0] prescale_register;
 rand logic [31:0] command_register;
 rand logic [31:0] control_register;
 rand logic [31:0] status_register;
 rand logic [31:0] transmit_register;
 rand logic [31:0] recieve_register;
      
      logic [7:0] start_with_write = 8'b1001_0001; //here interrrupt ack(0th bit) asserted because 
                                                  //of the to deassert the interrupt flag from slave
      logic [7:0] start_with_read = 8'b1010_0001;
      logic [7:0] start_cmd = 8'b1000_0001 ;
      logic [7:0] stop_cmd = 8'b0100_0001;
      logic [7:0] ctl_en = 8'b1100_0000; //asserting the 
      logic [7:0] write_cmd = 8'b0001_0001;
      logic [7:0] read_cmd = 8'b0010_1001;
      logic [7:0] prescalue_value = 8'b0000_0101; //clk_speed ~ 1MHz for to
                                                                //verify purpose only
      logic [7:0] intr_ack =  8'b0000_0001;





  
     constraint d_wr { data_to_write[31:8] ==0;}
     constraint mem { rd_mem_loc[31:8] ==0;}
     constraint addr_wr {address_to_write[31:8] == 0 && address_to_write[0] == 0;}
     constraint addr_rd {address_to_read == (address_to_write | 1);}

     constraint pre_addr {prescale_register =='h0;}
     constraint cmd_addr {command_register  =='h14;}
     constraint ctl_addr {control_register == 'h4;}
     constraint sts_addr {status_register =='hc;}
     constraint trans_addr {transmit_register =='h10; }
     constraint recv_addr {recieve_register == 'h8;}


endclass

//CMD_REGISTER

//Bit 7 STA: Send start bit.
//Bit 6 STO: Send stop bit.
//Bit 5 RD: Read from bus.
//Bit 4 WR: Write to bus.
//Bit 3 ACK: Acknowledge received data.
//Bit 2:1 Reserved: Set to 0.
//Bit 0 IA: Interrupt Acknowldge
     





