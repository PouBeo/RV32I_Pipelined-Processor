`include "D:/BKU/CTMT/2011919_Pipelined_Processor/Parameter.sv"
import StructPkg::*;
/////////////////////////////////////////////////////////////////////
// Module: Hazard-unit Nopping
/////////////////////////////////////////////////////////////////////
module hazard_unit_nop
(
  input  logic EX_br_sel, EX_rd_wren,
  input  logic is_load, MEM_rd_wren,
  
  input  logic [4:0] ID_rs1_addr, ID_rs2_addr, ID_rd_addr,
  input  logic [4:0] EX_rs1_addr, EX_rs2_addr, EX_rd_addr,
  input  logic [4:0] MEM_rd_addr,
  input  logic [4:0]  WB_rd_addr, 
  
  output logic stall_IF, stall_ID,
  output logic flush_ID, flush_EX
);

  // NOP logics:
  logic ld_nop ;
  logic br_nop ;
  logic alu_nop ;
  logic yet_nop ;
  
  //    or(rd_addr) = 0 when rd_addr = 5'b00000
  // Assign yet_nop = 1 until EX, MEM, WB stage all nop (hazard instrc out pipeline):
  assign yet_nop = ( ( |EX_rd_addr ) | ( |MEM_rd_addr ) | ( |WB_rd_addr) ); 

  // Reg detect: detect for the two-next-by-instruction and step-by-one-instruction:
  assign alu_nop =  (( ID_rs1_addr != 5'b0 ) | ( ID_rs2_addr != 5'b0 )) ?
                       (  EX_rd_wren & ((ID_rs1_addr ==  EX_rd_addr) | (ID_rs2_addr ==  EX_rd_addr)) ) ? 1 /* i[n] and i[n+1] */ :
                       ( MEM_rd_wren & ((ID_rs1_addr == MEM_rd_addr) | (ID_rs2_addr == MEM_rd_addr)) ) ? 1 /* i[n] and i[n+2] */ : 0 : 0 ;

  // Load detect: use wb_sel[0] to indicate 'isload', since writeback ld_data if wb_sel = 2'b01 (else: 00, 10)
  assign ld_nop = is_load & (((ID_rs1_addr == EX_rd_addr) | (ID_rs2_addr == EX_rd_addr)) ? 1 : ((ID_rs1_addr == MEM_rd_addr) | (ID_rs2_addr == MEM_rd_addr)) ? 1 : 0 ) ;

  // Control signals available at IDstage first, but need to wait until ALU calculate BTA, so branch detect at EXstage with br_sel: 1: branch, 0: pc4
  assign br_nop = EX_br_sel;
  
    ////* STALL FF *////
  // NOP until yet_nop = 0 : Since 'nop detect' just set 1 by comb-logic, use rise edge of them to DFF's clock, yet_nop as the DFF's neg-syn-clr:
  always_ff @ ( posedge ( (ld_nop | alu_nop) & ~br_nop ) or negedge yet_nop ) begin
    if ( ~ yet_nop ) begin
      stall_IF <= 1'b0 ;
      stall_ID <= 1'b0 ;
    end else begin
      stall_IF <= 1'b1 ;
      stall_ID <= 1'b1 ;
    end
  end

  initial begin  // avoid X logic when simulating
    stall_IF = 1'b0 ;
    stall_ID = 1'b0 ;
  end

  ////* FLUSH FF *////
  assign flush_ID = br_nop ;
  assign flush_EX = br_nop | stall_ID ;

endmodule: hazard_unit_nop