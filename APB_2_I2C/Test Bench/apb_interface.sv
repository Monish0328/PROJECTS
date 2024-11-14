interface apb_interface #(parameter APB_ADDR_WIDTH = 12);

      logic                      HCLK    ; 
      logic                      HRESETn ;
      logic                      PENABLE ; 
      logic                      PSEL   ;
      logic                      PWRITE  ;
      logic [APB_ADDR_WIDTH-1:0] PADDR   ;
      logic [31:0]               PWDATA  ;
      logic [31:0]               PRDATA  ;
      logic                      PREADY  ;    
      logic                      PSLVERR ;
      logic 		         interrupt_o ;
endinterface

