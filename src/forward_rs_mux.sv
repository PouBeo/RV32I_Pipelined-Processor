`include "Parameter.sv"

module forward_rs_mux (
  input  logic [ 1:0]  forward_sel_i,
  input  logic [31:0]  EX_rsdata_i,
  input  logic [31:0]  WB_wbdata_i,
  input  logic [31:0]  MEM_aludata_i,
  output logic [31:0]  rs_data_o
);
  assign rs_data_o = ( forward_sel_i == `NOforward  ) ? EX_rsdata_i :
                     ( forward_sel_i == `forwardMEM ) ? MEM_aludata_i :
                     ( forward_sel_i == `forwardWB  ) ? WB_wbdata_i : 32'bx ;

endmodule: forward_rs_mux
