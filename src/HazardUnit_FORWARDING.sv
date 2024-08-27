`include "D:/BKU/CTMT/2011919_Pipelined_Processor/Parameter.sv"
import StructPkg::*;
/////////////////////////////////////////////////////////////////////
// Module: Hazard-unit Forwarding
// Description: 
// 
/////////////////////////////////////////////////////////////////////
module hazard_unit_forwarding
(
  input  logic EX_br_sel, EX_rd_wren,
  input  logic is_load, MEM_rd_wren, WB_rd_wren,
  
  input  logic [4:0] ID_rs1_addr, ID_rs2_addr, 
  input  logic [4:0] EX_rs1_addr, EX_rs2_addr, EX_rd_addr,
  input  logic [4:0] MEM_rd_addr,
  input  logic [4:0] WB_rd_addr, 
  
  output logic stall_IF, stall_ID,
  output logic flush_ID, flush_EX,
  
  output logic [1:0] forward_rs1_sel, forward_rs2_sel, br_rs1_sel, br_rs2_sel
);

  logic ld_nop;
  logic br_nop;


  always_comb begin: FORWARD_TO_RS1
    if (EX_rs1_addr != 5'b0) begin
      if      (MEM_rd_wren && (MEM_rd_addr == EX_rs1_addr)) forward_rs1_sel = `forwardMEM;
      else if ( WB_rd_wren && ( WB_rd_addr == EX_rs1_addr)) forward_rs1_sel = `forwardWB;  // must be else: MEMstage's data (n-1) is the meaning data to EXstage's instrc (n), not WBstage's (n-2)
      else                                                  forward_rs1_sel = `NOforward;
      end
    else forward_rs1_sel = `NOforward;
  end
  
  always_comb begin: FORWARD_TO_RS2
    if (EX_rs2_addr != 5'b0) begin
       if      (MEM_rd_wren && (MEM_rd_addr == EX_rs2_addr)) forward_rs2_sel = `forwardMEM;
       else if ( WB_rd_wren && ( WB_rd_addr == EX_rs2_addr)) forward_rs2_sel = `forwardWB;
       else                                                  forward_rs2_sel = `NOforward;
      end
    else forward_rs2_sel = `NOforward;
  end
/*
  always_comb begin: FORWARD_TO_RS1
    if (EX_rs1_addr != 5'b0) begin
      if      (MEM_rd_wren && (MEM_rd_addr == EX_rs1_addr)) forward_rs1_sel = `forwardMEM;
      else begin 
           if      ( WB_rd_wren && ( WB_rd_addr == EX_rs1_addr)) forward_rs1_sel = `forwardWB;  // must be else: MEMstage's data (n-1) is the meaning data to EXstage's instrc (n), not WBstage's (n-2)
           else if ( WB_rd_wren && ( WB_rd_addr == ID_rs1_addr)) forward_rs1_sel = `forwardWB;  // Hazard occurs if instr< a > 's rd_addr and instr< a+3 > 's rs_addr
      else                                                  forward_rs1_sel = `NOforward;
      end
    else forward_rs1_sel = `NOforward;
  end
  
  always_comb begin: FORWARD_TO_RS2
    if (EX_rs2_addr != 5'b0) begin
       if      (MEM_rd_wren && (MEM_rd_addr == EX_rs2_addr)) forward_rs2_sel = `forwardMEM;
       else if ( WB_rd_wren && ( WB_rd_addr == EX_rs2_addr)) forward_rs2_sel = `forwardWB;
       else                                                  forward_rs2_sel = `NOforward;
      end
    else forward_rs2_sel = `NOforward;
  end*/

  always_comb begin: RS_SEL_FOR_BRCOMP
    br_rs1_sel = 2'b00;
    br_rs2_sel = 2'b00;
  
    if (ID_rs1_addr != 5'b0) begin
      if (EX_rd_wren && (EX_rd_addr == ID_rs1_addr))
        br_rs1_sel = 2'b01;   // EX_alu_data
      else if (MEM_rd_wren && (MEM_rd_addr == ID_rs1_addr)) begin
        if (is_load)
          br_rs1_sel = 2'b11; // MEM_ld_data
        else
          br_rs1_sel = 2'b10; // MEM_alu_data
      end
      else
        br_rs1_sel = 2'b00;   // ID_rs_data
    end
  
    if (ID_rs2_addr != 5'b0) begin
      if (EX_rd_wren && (EX_rd_addr == ID_rs2_addr))
        br_rs2_sel = 2'b01;
      else if (MEM_rd_wren && (MEM_rd_addr == ID_rs2_addr)) begin
        if (is_load)
          br_rs2_sel = 2'b11;
        else
          br_rs2_sel = 2'b10;
      end
      else
        br_rs2_sel = 2'b00;
    end
  end

  // Load detect: use wb_sel[0] to indicate 'isload', since writeback ld_data if wb_sel = 2'b01 (else: 00, 10)
  assign ld_nop = is_load & ((ID_rs1_addr == EX_rd_addr) | (ID_rs2_addr == EX_rd_addr));

  //Branch detect: 1: branch, 0: pc4
  assign br_nop = EX_br_sel;

  assign stall_IF = ld_nop;
  assign stall_ID = ld_nop;
  assign flush_ID = br_nop;
  assign flush_EX = br_nop | ld_nop;

endmodule: hazard_unit_forwarding