class apb_generator;

    mailbox#(apb_transaction) apb_gen_drv_mbx;
    int trans_count = 1;
 
    event transaction_done;
    task run();
        apb_transaction apb_tr;
        repeat (trans_count) begin
            apb_tr = new(); // Create an instance of apb_transaction
            
            // Randomize transaction fields
            if (!apb_tr.randomize()) begin
                $display("Error: Randomization failed for apb_tr");
                break; // Exit loop on failure
            end

            // Send the transaction to the driver
	       //	apb_tr.op = read;
            apb_gen_drv_mbx.put(apb_tr);

            // Wait for the transaction_done event before sending the next transaction
            @ (transaction_done);
        end
    endtask

endclass

