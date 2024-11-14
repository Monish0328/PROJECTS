`define APB_ADDR_WIDTH 12 
//`define DATA_SIZE 8

typedef enum  {
	read = 0,
    write = 1
} oper_mode;

typedef enum  bit [31:0]{
	prescale_reg = 0,
	command_reg  = 1,
	status_reg   = 2,
	transmit_reg = 3,
	receive_reg  = 4,
	control_reg  = 5
}reg_type;

function string reg_type_to_string(reg_type rt);
    case (rt)
        prescale_reg: return "prescale_reg";
        command_reg:  return "command_reg";
        status_reg:   return "status_reg";
        transmit_reg: return "transmit_reg";
        receive_reg:  return "receive_reg";
        control_reg:  return "control_reg";
        default:      return "unknown";
    endcase
endfunction


