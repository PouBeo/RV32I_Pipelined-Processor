import StructPkg::*;
module FF_ID_EX
(
  input  logic  clk_i,
  input  logic  en_i,
  input  logic  synclr_ni,
  input  logic  asynclr_i,

  input  ID_EX_ff ID_i,
  output ID_EX_ff EX_o
);
  always_ff @ ( posedge clk_i, negedge synclr_ni )
    if ( !synclr_ni ) begin
      EX_o.wb_sel      = 2'b0;
      EX_o.mem_wren    = 1'b0;
      EX_o.byte_num    = 4'b0;
      EX_o.ld_unsigned = 1'b0;
      EX_o.alu_op      = 4'b0;
      EX_o.op_a_sel    = 1'b0;
      EX_o.op_b_sel    = 1'b0;
      EX_o.rd_wren     = 1'b0;
      EX_o.br_sel      = 1'b0;
      EX_o.imm         = 32'b0;
      EX_o.rs1_data    = 32'b0;
      EX_o.rs2_data    = 32'b0;
      EX_o.rs1_addr    = 5'b0;
      EX_o.rs2_addr    = 5'b0;
      EX_o.rd_addr     = 5'b0;
      EX_o.pc          = 32'b0;
      EX_o.pc4         = 32'b0;
      end
    else if ( asynclr_i ) begin
      EX_o.wb_sel      = 2'b0;
      EX_o.mem_wren    = 1'b0;
      EX_o.byte_num    = 4'b0;
      EX_o.ld_unsigned = 1'b0;
      EX_o.alu_op      = 4'b0;
      EX_o.op_a_sel    = 1'b0;
      EX_o.op_b_sel    = 1'b0;
      EX_o.rd_wren     = 1'b0;
      EX_o.br_sel      = 1'b0;
      EX_o.imm         = 32'b0;
      EX_o.rs1_data    = 32'b0;
      EX_o.rs2_data    = 32'b0;
      EX_o.rs1_addr    = 5'b0;
      EX_o.rs2_addr    = 5'b0;
      EX_o.rd_addr     = 5'b0;
      EX_o.pc          = 32'b0;
      EX_o.pc4         = 32'b0;
      end
    else if ( en_i ) begin
      EX_o.wb_sel      = ID_i.wb_sel;
      EX_o.mem_wren    = ID_i.mem_wren;
      EX_o.byte_num    = ID_i.byte_num;
      EX_o.ld_unsigned = ID_i.ld_unsigned;
      EX_o.alu_op      = ID_i.alu_op;
      EX_o.op_a_sel    = ID_i.op_a_sel;
      EX_o.op_b_sel    = ID_i.op_b_sel;
      EX_o.rd_wren     = ID_i.rd_wren;
      EX_o.br_sel      = ID_i.br_sel;
      EX_o.imm         = ID_i.imm;
      EX_o.rs1_data    = ID_i.rs1_data;
      EX_o.rs2_data    = ID_i.rs2_data;
      EX_o.rs1_addr    = ID_i.rs1_addr;
      EX_o.rs2_addr    = ID_i.rs2_addr;
      EX_o.rd_addr     = ID_i.rd_addr;
      EX_o.pc          = ID_i.pc;
      EX_o.pc4         = ID_i.pc4;
      end

endmodule: FF_ID_EX