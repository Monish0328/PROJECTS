class apb_2_i2c_env;
  
    virtual apb_interface apb_if;
    virtual i2c_interface i2c_if;
    
    apb_generator apb_gen;
    apb_driver apb_drv;
//  apb_monitor apb_mon;
//     i2c_monitor i2c_mon;
//     apb_2_i2c_sb sb;
    
    mailbox#(apb_transaction) apb_gen_drv_mbx;
//     mailbox#(apb_transaction) apb_mon_sb_mbx;
//     mailbox#(i2c_transaction) i2c_mon_sb_mbx;
    
    event transaction_done;

    function new();
        apb_gen = new();
        apb_drv = new();
//         apb_mon = new();
//         i2c_mon = new();
//         sb      = new();
        apb_gen_drv_mbx = new();
//         apb_mon_sb_mbx  = new();
//         i2c_mon_sb_mbx  = new();
        
        apb_gen.apb_gen_drv_mbx = apb_gen_drv_mbx;
        apb_drv.apb_gen_drv_mbx = apb_gen_drv_mbx;
//         apb_mon.apb_mon_sb_mbx  = apb_mon_sb_mbx;
//         i2c_mon.i2c_mon_sb_mbx  = i2c_mon_sb_mbx;
//         sb.apb_mon_sb_mbx       = apb_mon_sb_mbx;
//         sb.i2c_mon_sb_mbx       = i2c_mon_sb_mbx;

        // Pass the transaction_done event to the scoreboard
//         sb.transaction_done = transaction_done;
	apb_gen.transaction_done = transaction_done;

    endfunction
    
    virtual task run();
        apb_drv.vif = apb_if;
//         apb_mon.vif = apb_if;
//         i2c_mon.vif = i2c_if;
        
        fork
            apb_gen.run();
            apb_drv.run();
//             apb_mon.run();
//             i2c_mon.run();
//             sb.run();
        join_any
    endtask

endclass

