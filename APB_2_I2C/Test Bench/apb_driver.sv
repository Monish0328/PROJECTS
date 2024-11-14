class apb_driver; 
  
  virtual apb_interface vif;
  
  mailbox#(apb_transaction) apb_gen_drv_mbx;
  
  
  task run();
    forever begin
      apb_transaction req;
      apb_gen_drv_mbx.get(req);
      drive_trans(req);
    end
  endtask

  task drive_trans(apb_transaction req);
    wait(vif.HRESETn);
    
    // Updating prescale register
    @(posedge vif.HCLK);
    vif.PWRITE  <= 1;
    vif.PWDATA  <= req.prescalue_value;
    vif.PADDR   <= req.prescale_register;
    vif.PENABLE <= 1;
    vif.PSEL    <= 1;
    // Log the transaction
    $display("APB_DRV : PRESCALE REGISTER: PADDR = %h, PWDATA = %h", req.prescale_register, req.prescalue_value);

    drive_control_register(req);
  endtask

  // Drive Control Register
  task drive_control_register(apb_transaction req);
    @(posedge vif.HCLK);
    vif.PWDATA  <= req.ctl_en;
    vif.PADDR   <= req.control_register;
    // Log the transaction
    $display("APB_DRV : CONTROL REGISTER: PADDR = %h, PWDATA = %h", req.control_register, req.ctl_en);

    if(req.op == write) begin
       drive_write_transaction(req);
    end
    else if(req.op == read) begin
       drive_read_transaction(req);
    end
  endtask

  // I2C write Sequence
  // 1) Generate start command 
  // 2) Write slave address + write bit 
  // 3) Receive acknowledge from slave 
  // 4) Write data 
  // 5) Receive acknowledge from slave 
  // 6) Generate stop command

  // I2C read sequence
  // 1) Generate start signal 
  // 2) Write slave address + write bit 
  // 3) Receive acknowledge from slave 
  // 4) Write memory location 
  // 5) Receive acknowledge from slave 
  // 6) Generate repeated start signal 
  // 7) Write slave address + read bit 
  // 8) Receive acknowledge from slave 
  // 9) Read byte from slave 
  // 10) Write no acknowledge (NACK) to slave, indicating end of transfer 
  // 11) Generate stop signal

  task drive_write_transaction(apb_transaction req);
    $display("APB_DRV_WRITE : WRITE TRANSACTION INITIATED");
    send_write_address(req);
    @(posedge vif.HCLK);
    vif.PADDR   <= 0;
    vif.PWDATA  <= 0;
    vif.PWRITE  <= 0;
    vif.PENABLE <= 0;
  endtask

  // Send Write Address
  task send_write_address(apb_transaction req);
    @(posedge vif.HCLK);
    vif.PWDATA  <= req.start_with_write;
    vif.PADDR   <= req.command_register;
    // Log the transaction
    $display("APB_DRV : WRITE ADDRESS: PADDR = %h, PWDATA = %h", req.command_register, req.start_with_write);

    @(posedge vif.HCLK);
    vif.PWDATA  <= req.address_to_write;
    vif.PADDR   <= req.transmit_register;
    // Log the transaction
    $display("APB_DRV : TRANSMIT REGISTER: PADDR = %h, PWDATA = %h", req.transmit_register, req.address_to_write);

    @(posedge vif.HCLK);
    vif.PWRITE  <= 0;
    vif.PADDR   <= req.status_register;
    // Log the transaction
    $display("APB_DRV : STATUS REGISTER: PADDR = %h", req.status_register);

    // Continuously monitor the status register until interrupt
    do begin
      @(posedge vif.HCLK);
      req.sts_read_data = vif.PRDATA;
    end while ((req.sts_read_data[0] == 1'b1 && req.sts_read_data[7] == 1'b0));
    $display("APB_DRV : INTERRUPT RECEIVED FOR WRITE ADDRESS");

    // Send write data
    send_write_data(req);
  endtask

  // Send Write Data
  task send_write_data(apb_transaction req);
    @(posedge vif.HCLK);
    vif.PWRITE  <= 1;
    vif.PWDATA  <= req.write_cmd;
    vif.PADDR   <= req.command_register;
    // Log the transaction
    $display("APB_DRV : WRITE COMMAND: PADDR = %h, PWDATA = %h", req.command_register, req.write_cmd);

    @(posedge vif.HCLK);
    vif.PWDATA  <= (req.op == write) ? req.data_to_write : req.rd_mem_loc;
    vif.PADDR   <= req.transmit_register;
    // Log the transaction
    if (req.op == write) begin
    $display("APB_DRV : WRITE DATA: PADDR = %h, PWDATA = %h", req.transmit_register, req.data_to_write);
    end
    else begin
    $display("APB_DRV : The WRITE MEM LOC : PADDR = %h, PWDATA = %h", req.transmit_register, req.rd_mem_loc);
    end

    @(posedge vif.HCLK);
    vif.PWRITE  <= 0;
    vif.PADDR   <= req.status_register;
    // Log the transaction
    $display("APB_DRV : STATUS REGISTER: PADDR = %h", req.status_register);

    // Continuously monitor the status register until interrupt
    do begin
      @(posedge vif.HCLK);
      req.sts_read_data = vif.PRDATA;
    end while ((req.sts_read_data[0] == 1'b1 && req.sts_read_data[7] == 1'b0));
    $display("APB_DRV : INTERRUPT RECEIVED FOR WRITE DATA");

    // Check if it was a write or read operation
    if (req.op == write) begin
      send_stop(req);
    end
    else begin
      send_read_address(req);
    end
  endtask

  // Send Stop
  task send_stop(apb_transaction req);
    @(posedge vif.HCLK);
    vif.PENABLE <= 1;
    vif.PWRITE  <= 1;
    vif.PWDATA  <= req.stop_cmd;
    vif.PADDR   <= req.command_register;
    // Log the transaction
    $display("APB_DRV : STOP COMMAND: PADDR = %h, PWDATA = %h", req.command_register, req.stop_cmd);

    // Send acknowledgment
    send_ack(req);
  endtask

  // Send Acknowledgment
  task send_ack(apb_transaction req);
    @(posedge vif.HCLK);
    vif.PWRITE  <= 0;
    vif.PADDR   <= req.status_register;
    // Log the transaction
    $display("APB_DRV : STATUS REGISTER: PADDR = %h", req.status_register);

    // Continuously monitor the status register until acknowledgment
    do begin
      @(posedge vif.HCLK);
      req.sts_read_data = vif.PRDATA;
    end while ((req.sts_read_data[0] == 1'b1 && ((req.sts_read_data[7] == 1'b1 && req.op == read) || (req.sts_read_data[7] == 1'b0 && req.op == write))));
    $display("APB_DRV : ACK RECEIVED FOR STOP");

    @(posedge vif.HCLK);
    vif.PWRITE  <= 1;
    vif.PWDATA  <= req.intr_ack;
    vif.PADDR   <= req.command_register;
    // Log the transaction
    $display("APB_DRV : INTR ACK: PADDR = %h, PWDATA = %h", req.command_register, req.stop_cmd);
    $display("APB_DRV : ACK SENT FROM MASTER");
  endtask

  // Drive Read Transaction
  task drive_read_transaction(apb_transaction req);
    $display("APB_DRV_READ : READ TRANSACTION INITIATED");
    send_write_address(req);
    @(posedge vif.HCLK);
    vif.PADDR   <= 0;
    vif.PWDATA  <= 0;
    vif.PWRITE  <= 0;
    vif.PENABLE <= 0;
  endtask

  // Send Read Address
  task send_read_address(apb_transaction req);
    @(posedge vif.HCLK);
    vif.PWDATA  <= req.start_with_write;
    vif.PADDR   <= req.command_register;
    vif.PWRITE  <= 1;
    // Log the transaction
    $display("APB_DRV : READ ADDRESS: PADDR = %h, PWDATA = %h", req.command_register, req.start_with_read);

    @(posedge vif.HCLK);
    vif.PADDR   <= req.transmit_register;
    vif.PWDATA  <= req.address_to_read;
    // Log the transaction
    $display("APB_DRV : TRANSMIT REGISTER: PADDR = %h, PWDATA = %h", req.transmit_register, req.address_to_read);

    @(posedge vif.HCLK);
    vif.PWRITE  <= 0;
    vif.PADDR   <= req.status_register;
    // Log the transaction
    $display("APB_DRV : STATUS REGISTER: PADDR = %h", req.status_register);

    // Continuously monitor the status register until interrupt
    do begin
      @(posedge vif.HCLK);
      req.sts_read_data = vif.PRDATA;
    end while ((req.sts_read_data[0] == 1'b1 && req.sts_read_data[7] == 1'b0));
    $display("APB_DRV : INTERRUPT RECEIVED FOR READ ADDRESS");

    get_read_data(req);
  endtask

  // Send Read Data
  task get_read_data(apb_transaction req);
    @(posedge vif.HCLK);
    @(posedge vif.HCLK);
    vif.PWRITE  <= 1;
    vif.PWDATA  <= req.read_cmd;
    vif.PADDR   <= req.command_register;
    // Log the transaction
    $display("APB_DRV : READ COMMAND: PADDR = %h, PWDATA = %h", req.command_register, req.read_cmd);

    @(posedge vif.HCLK);
    @(posedge vif.HCLK);
    vif.PWRITE  <= 0;
    vif.PADDR   <= req.status_register;
    // Log the transaction
    $display("APB_DRV : STATUS REGISTER: PADDR = %h", req.status_register);

    // Continuously monitor the status register until interrupt
    do begin
      @(posedge vif.HCLK);
      req.sts_read_data = vif.PRDATA;
    end while ((req.sts_read_data[0] == 1'b1 && req.sts_read_data[7] == 1'b1));
    $display("APB_DRV : INTERRUPT RECEIVED FOR READ DATA");

    @(posedge vif.HCLK);
    vif.PWRITE  <= 0;
    vif.PADDR   <= req.recieve_register;
    // Log the transaction
    $display("APB_DRV : RECEIVE REGISTER: PADDR = %h", req.recieve_register);
    
    @(posedge vif.HCLK);
    vif.PENABLE <= 0;
    $display("APB_DRV : READ DATA FROM THE I2C SLAVE : PRDATA = %h", vif.PRDATA);
    
    send_stop(req);
  endtask

endclass

