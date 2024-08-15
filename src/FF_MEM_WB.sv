import StructPkg::*;

module FF_MEM_WB
(
  input  logic  clk_i,
  input  logic  en_i,
  input  logic  synclr_ni,
  input  logic  asynclr_i,
  
  input  MEM_WB_ff MEM_i,
  output MEM_WB_ff WB_o
);
  always_ff @ ( posedge clk_i, negedge synclr_ni )
    if ( !synclr_ni ) begin
      WB_o.wb_sel      = 2'b0;
      WB_o.rd_wren     = 1'b0;
      WB_o.rd_addr     = 5'b0;
      WB_o.pc4         = 32'b0;
      WB_o.alu_data    = 32'b0;
      WB_o.ld_data     = 32'b0;
      end
    else if ( asynclr_i ) begin
      WB_o.wb_sel      = 2'b0;
      WB_o.rd_wren     = 1'b0;
      WB_o.rd_addr     = 5'b0;
      WB_o.pc4         = 32'b0;
      WB_o.alu_data    = 32'b0;
      WB_o.ld_data     = 32'b0;
      end
    else if ( en_i ) begin
      WB_o.wb_sel      = MEM_i.wb_sel;
      WB_o.alu_data     = MEM_i.alu_data;
      WB_o.rd_wren     = MEM_i.rd_wren;
      WB_o.rd_addr     = MEM_i.rd_addr;
      WB_o.ld_data     = MEM_i.ld_data;
      WB_o.pc4         = MEM_i.pc4;
      end

endmodule: FF_MEM_WB