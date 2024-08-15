import StructPkg::*;

module FF_IF_ID
(
  input  logic  clk_i,
  input  logic  en_i,
  input  logic  synclr_ni,
  input  logic  asynclr_i,
  input  IF_ID_ff IF_i,
  output IF_ID_ff ID_o
);
  always_ff @ ( posedge clk_i, negedge synclr_ni )
    if ( !synclr_ni ) begin
      ID_o.pc = 0;
      ID_o.pc4 = 0;
      ID_o.instr = 0;
      end
    else if ( asynclr_i ) begin
      ID_o.pc = 0;
      ID_o.pc4 = 0;
      ID_o.instr = 0;
      end
    else if ( en_i ) begin
      ID_o.pc = IF_i.pc;
      ID_o.pc4 = IF_i.pc4;
      ID_o.instr = IF_i.instr;
      end
  
endmodule: FF_IF_ID