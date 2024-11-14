class apb_monitor;
 

   virtual apb_interface vif ;
   apb_transaction apb_tr;
   mailbox#(apb_transaction) apb_mon_sb_mbx; 

 

    task run();
        // Monitor activity during the run phase
        forever begin
            // Wait for reset to be deasserted
            wait (vif.HRESETn);

            // Wait for the positive edge of the clock
            @(posedge vif.HCLK);
	    apb_tr = new;

            // Capture APB transactions if valid and selected
            if (vif.PENABLE && vif.PREADY && vif.PSEL) begin
                // Populate transaction fields
                apb_tr.PADDR = vif.PADDR;
                apb_tr.PSEL = vif.PSEL;
                apb_tr.PWRITE = vif.PWDATA;

                if (vif.PWRITE && (vif.PADDR == 'h10)) begin
                    // Handle write operation
                    apb_tr.PWDATA = vif.PWDATA;
                    apb_tr.op = write;
		    $display("APB_MON : The write_data was updated to sb");
                apb_mon_sb_mbx.put(apb_tr);
		    
                end else if (!vif.PWRITE && (vif.PADDR == 'h08)) begin
                    // Handle read operation
                    apb_tr.PRDATA = vif.PRDATA;
                  $display("APB_MON : The write_data was updated to sb PRDATA = %h ",apb_tr.PRDATA);
                    apb_tr.op = read;
                apb_mon_sb_mbx.put(apb_tr);
                end

                // Send transaction to scoreboard
            end
        end
    endtask

endclass



