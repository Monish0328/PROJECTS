class apb_2_i2c_sb;

    apb_transaction apb_trans;
    i2c_transaction i2c_trans;

    mailbox#(apb_transaction) apb_mon_sb_mbx = new();
    mailbox#(i2c_transaction) i2c_mon_sb_mbx = new();

    bit [7:0] apb_data;
    bit [7:0] i2c_data;
    bit [7:0] read_data;
    bit trans_type;
    bit [31:0] total_size;
    bit [7:0] apb_data_compare;
    bit [31:0] apb_write_monitor_queue[$];
    bit [31:0] apb_read_monitor_queue[$];

    // Event to signal the completion of transaction comparison
    event transaction_done;

    task run();
        fork
            apb_mon_sb();
            i2c_mon_sb();
        join
    endtask

    // Continuously monitor APB transactions
    task apb_mon_sb();
        forever begin
            // Process APB transactions
            apb_mon_sb_mbx.get(apb_trans);

            if (apb_trans.PADDR == 8'h10) begin
                apb_data = apb_trans.PWDATA;
                apb_write_monitor_queue.push_front(apb_data);
                $display("SB: The write data/address was updated in the scoreboard from APB_MON = %h", apb_trans.PWDATA);
            end else if (apb_trans.PADDR == 8'h08) begin
                apb_data = apb_trans.PRDATA;
                apb_read_monitor_queue.push_front(apb_data);
                $display("SB: The read data was updated in the scoreboard from APB_MONITOR = %h", apb_trans.PRDATA);
            end

            trans_type = apb_trans.op;
            total_size = apb_write_monitor_queue.size();
        end
    endtask

    // Continuously monitor I2C transactions
    task i2c_mon_sb();
        forever begin
            i2c_mon_sb_mbx.get(i2c_trans);

            for (int i = 0; i < total_size; i++) begin
                if (i % 2 == 0) begin
                    i2c_data = i2c_trans.addr_q.pop_back();
                    apb_data_compare = apb_write_monitor_queue.pop_back();
                    if (i2c_data == apb_data_compare) begin
                        $display("SB_MATCH: The address matched apb_data = %h, i2c_data = %h", apb_data_compare, i2c_data);
                    end else begin
                        $error("SB_MISMATCH: The address mismatched apb_data = %h, i2c_data = %h", apb_data_compare, i2c_data);
                    end
                end else begin
                    i2c_data = i2c_trans.monitor_data_q.pop_back();
                    apb_data_compare = apb_write_monitor_queue.pop_back();
                    if (i2c_data == apb_data_compare) begin
                        if (trans_type == 0) begin
                            $display("SB_MATCH: The write_memory data location matched apb_data = %h, i2c_data = %h", apb_data_compare, i2c_data);
                        end else begin
                            $display("SB_MATCH: The write_data matched apb_data = %h, i2c_data = %h", apb_data_compare, i2c_data);
                        end
                    end else begin
                        if (trans_type == 0) begin
                            $error("SB_MISMATCH: The write_memory data location mismatched apb_data = %h, i2c_data = %h", apb_data_compare, i2c_data);
                        end else begin
                            $error("SB_MISMATCH: The write_data mismatched apb_data = %h, i2c_data = %h", apb_data_compare, i2c_data);
                        end
                    end
                end
            end

            // Check APB read queue
            if (apb_read_monitor_queue.size() != 0) begin
                read_data = apb_read_monitor_queue.pop_back();
                if (i2c_trans.data == read_data) begin
                    $display("SB_MATCH: The read data matched apb_data = %h, i2c_data = %h", read_data, i2c_trans.data);
                end else begin
                    $error("SB_MISMATCH: The read data mismatched apb_data = %h, i2c_data = %h", read_data, i2c_trans.data);
                end
            end

            // Signal the completion of transaction comparison
            -> transaction_done;
        end
    endtask

endclass

