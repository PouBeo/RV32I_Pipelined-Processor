import StructPkg::*;
//import StructPkg::EX_MEM_ff;

module FF_EX_MEM
(
  input  logic  clk_i,
  input  logic  en_i,
  input  logic  synclr_ni,
  input  logic  asynclr_i,
  
  input  EX_MEM_ff EX_i,
  output EX_MEM_ff MEM_o
);
  always_ff @ ( posedge clk_i, negedge synclr_ni )
    if ( !synclr_ni ) begin
      MEM_o.wb_sel      = 2'b0;
      MEM_o.mem_wren    = 1'b0;
      MEM_o.byte_num    = 4'b0;
      MEM_o.ld_unsigned = 1'b0;
      MEM_o.rd_wren     = 1'b0;
      MEM_o.rd_addr     = 5'b0;
      MEM_o.pc4         = 32'b0;
      MEM_o.alu_data    = 32'b0;
      MEM_o.rs2_data    = 32'b0;
      MEM_o.rs2_forward = 32'b0;
      end
    else if ( asynclr_i ) begin
      MEM_o.wb_sel      = 2'b0;
      MEM_o.mem_wren    = 1'b0;
      MEM_o.byte_num    = 4'b0;
      MEM_o.ld_unsigned = 1'b0;
      MEM_o.rd_wren     = 1'b0;
      MEM_o.rd_addr     = 5'b0;
      MEM_o.pc4         = 32'b0;
      MEM_o.alu_data    = 32'b0;
      MEM_o.rs2_data    = 32'b0;
      MEM_o.rs2_forward = 32'b0;
      end
    else if ( en_i ) begin
      MEM_o.wb_sel      = EX_i.wb_sel;
      MEM_o.mem_wren    = EX_i.mem_wren;
      MEM_o.byte_num    = EX_i.byte_num;
      MEM_o.ld_unsigned = EX_i.ld_unsigned;
      MEM_o.rd_wren     = EX_i.rd_wren;
      MEM_o.rs2_data    = EX_i.rs2_data;
      MEM_o.rs2_forward = EX_i.rs2_forward;
      MEM_o.alu_data    = EX_i.alu_data;
      MEM_o.rd_addr     = EX_i.rd_addr;
      MEM_o.pc4         = EX_i.pc4;
      end

endmodule: FF_EX_MEM