class apb_2_i2c_test;

  apb_2_i2c_env env;

  function new();
    env = new();
  endfunction

  task run();
    env.run();
  endtask

endclass

