class i2c_monitor;

   i2c_transaction i2c_tr;
   virtual i2c_interface vif;

   bit reg_ack;
   bit transaction_in_progress;

   mailbox#(i2c_transaction) i2c_mon_sb_mbx;

   task run();
     i2c_tr = new();
     vif.sda_pad_i = 1;
     monitor_i2c_master();
   endtask

   // Monitor task
   task monitor_i2c_master();
      forever begin
         start_condition();
         get_address();
         check_type_op();
         if (i2c_tr.write) begin
            get_write();
            if (i2c_tr.repeated_start) begin
               get_address(); // Get slave address for read operation
               check_type_op(); // Check for read operation
            end
         end
         if (i2c_tr.read) begin
            send_read();
         end
         stop_condition(); // Check and handle stop condition
      end
   endtask

   // Task to detect start condition
   task start_condition();
      forever begin
         @(negedge vif.sda_padoen_o);
         if ((vif.sda_padoen_o == 1'b0) && (vif.scl_padoen_o == 1'b1)) begin
            if (transaction_in_progress) begin
               $display("I2C_MON : Repeated start condition detected");
               i2c_tr.repeated_start = 1;
               i2c_tr.stop = 0;
            end else begin
               $display("I2C_MON : Start condition detected");
               i2c_tr.start = 1;
               transaction_in_progress = 1;
            end
            break; // Exit loop after start condition
         end
      end
   endtask

   // Task to get the address
   task get_address();
      forever begin
         @(posedge vif.scl_padoen_o);
         if (i2c_tr.start || i2c_tr.repeated_start) begin
            i2c_tr.start = 0;
            i2c_tr.repeated_start = 0;
            for (int i = 7; i > 0; i--) begin
               i2c_tr.addr[i] = vif.sda_padoen_o; // Sample the address
               @(posedge vif.scl_padoen_o);
            end
            i2c_tr.addr[0] = vif.sda_padoen_o;
            $display("I2C_MON : The received address is %0h", i2c_tr.addr);
            i2c_tr.addr_q.push_front(i2c_tr.addr);
            // Acknowledge
            @(negedge vif.scl_padoen_o);
            vif.sda_pad_i <= 0;
            @(negedge vif.scl_padoen_o);
            reg_ack = 1;
            vif.sda_pad_i <= 1;
            $display("I2C_MON : The ACK driven by the slave");
            break; // Exit loop after getting address
         end
      end
   endtask

   // Task to check operation type
   task check_type_op();
      if (reg_ack) begin
         reg_ack = 0;
         if (i2c_tr.addr[0] == 1'b0) begin
            i2c_tr.write = 1;
            i2c_tr.read = 0;
            $display("I2C_MON_WRITE : Write operation detected");
         end else begin
            i2c_tr.write = 0;
            i2c_tr.read = 1;
            $display("I2C_MON_READ : Read operation detected");
         end
      end
   endtask

   // Task to send read data
   task send_read();
      forever begin
         if (i2c_tr.read) begin
            i2c_tr.custom_randomize();
            vif.sda_pad_i <= i2c_tr.data[7];
            for (int i = 6; i >= 0; i--) begin
               @(negedge vif.scl_padoen_o);
               vif.sda_pad_i <= i2c_tr.data[i];
            end
            i2c_tr.read = 0;
            $display("I2C_MON : The read data sent from the slave : %h", i2c_tr.data);

            // Send ACK
            @(negedge vif.scl_padoen_o);
            vif.sda_pad_i = 1; // Send NACK
            break; // Exit loop after capturing read data
         end
      end
   endtask

   // Task to get write data
   task get_write();
      forever begin
         if (i2c_tr.write) begin
            for (int i = 7; i >= 0; i--) begin
               @(posedge vif.scl_padoen_o);
               i2c_tr.input_data_monitor[i] = vif.sda_padoen_o; // Capture write data
            end
            i2c_tr.write = 0;
            i2c_tr.monitor_data_q.push_front(i2c_tr.input_data_monitor);

            // Acknowledge
            @(negedge vif.scl_padoen_o);
            vif.sda_pad_i = 0; // Send ACK
            @(negedge vif.scl_padoen_o);
            vif.sda_pad_i = 1; // Release ACK

            $display("I2C_MON : Received write data: %h", i2c_tr.input_data_monitor);

            // Check for repeated start
            @(negedge vif.sda_padoen_o);
            if ((vif.sda_padoen_o == 1'b0) && (vif.scl_padoen_o == 1'b1)) begin
               $display("I2C_MON : Repeated start detected after write");
               i2c_tr.repeated_start = 1;
               break; // Exit loop after repeated start condition
            end else begin
               break; // Exit loop after capturing write data
            end
         end
      end
   endtask

   // Task to detect stop condition
   task stop_condition();
      forever begin
         @(posedge vif.sda_padoen_o);
         if ((vif.sda_padoen_o == 1'b1) && (vif.scl_padoen_o == 1'b1)) begin
            i2c_tr.stop = 1;
            transaction_in_progress = 0;
            $display("I2C_MON : Stop condition detected");
           i2c_mon_sb_mbx.put(i2c_tr);
            break; // Exit loop after stop condition
         end
      end
   endtask

endclass



