module rs_br_mux (
  input  logic [ 1:0]  rs_sel_i,
  input  logic [31:0]  ID_rs_data_i,
  input  logic [31:0]  EX_alu_data_i,
  input  logic [31:0]  MEM_alu_data_i,
  input  logic [31:0]  MEM_ld_data_i,
  output logic [31:0]  rs_data_o
);
  assign rs_data_o = ( rs_sel_i == 2'b00 ) ?   ID_rs_data_i :
                     ( rs_sel_i == 2'b01 ) ?  EX_alu_data_i :
                     ( rs_sel_i == 2'b10 ) ? MEM_alu_data_i : MEM_ld_data_i ;
endmodule: rs_br_mux
