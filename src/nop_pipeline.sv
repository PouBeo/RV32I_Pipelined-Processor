import StructPkg::*;
module nop_pipeline(
  input  logic  clk_i,
  input  logic  rst_ni,
  input  logic [31:0] io_sw_i,
  input  logic [31:0] io_push_i,

  output logic [31:0] io_lcd_o,
  output logic [31:0] io_ledg_o,
  output logic [31:0] io_ledr_o,

  output logic [31:0] io_hex0_o,
  output logic [31:0] io_hex1_o,
  output logic [31:0] io_hex2_o,
  output logic [31:0] io_hex3_o,
  output logic [31:0] io_hex4_o,
  output logic [31:0] io_hex5_o,
  output logic [31:0] io_hex6_o,
  output logic [31:0] io_hex7_o,
  output logic [31:0] pc_debug
);
  
  // STALL and FLUSH logics
  logic stall_IF, stall_ID;
  logic flush_ID, flush_EX;
  
  // STAGE Structions
  IF_stage_struct  IF;
  ID_stage_struct  ID;
  EX_stage_struct  EX;
  MEM_stage_struct  MEM;
  WB_stage_struct  WB;

  //////////////////////////////*   FLIP-FLOPS IN/OUT   *//////////////////////////////
  // IF-ID
  FF_IF_ID stageF_stageD ( .clk_i    ( clk_i     ),
                           .en_i     ( ~stall_ID ),
                           .synclr_ni( rst_ni    ),
                           .asynclr_i( flush_ID  ),
                           .IF_i     ( IF.IF_o   ),
                           .ID_o     ( ID.ID_i   ));
  
  // ID-EX
  FF_ID_EX stageD_stageE ( .clk_i    ( clk_i    ),
                           .en_i     ( 1'b1     ),
                           .synclr_ni( rst_ni   ),
                           .asynclr_i( flush_EX ),
                           .ID_i     ( ID.ID_o  ),
                           .EX_o     ( EX.EX_i  ));
  
  // EX-MEM
  FF_EX_MEM stageE_stageM ( .clk_i    ( clk_i     ),
                            .en_i     ( 1'b1      ),
                            .synclr_ni( rst_ni    ),
                            .asynclr_i( 1'b0      ),
                            .EX_i     ( EX.EX_o   ),
                            .MEM_o    ( MEM.MEM_i ));
  
  // MEM-WB
  FF_MEM_WB stageM_stageW ( .clk_i    ( clk_i     ),
                            .en_i     ( 1'b1      ),
                            .synclr_ni( rst_ni    ),
                            .asynclr_i( 1'b0      ),
                            .MEM_i    ( MEM.MEM_o ),
                            .WB_o     ( WB.WB_i   ));

  ////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////*   STAGES: IN to OUT   *//////////////////////////////
  
    // IF STAGE: none
    // ID STAGE:
  assign ID.ID_o.pc       = ID.ID_i.pc;
  assign ID.ID_o.pc4      = ID.ID_i.pc4;
  assign ID.ID_o.rs1_addr = ID.ID_i.instr[19:15];
  assign ID.ID_o.rs2_addr = ID.ID_i.instr[24:20];
  assign ID.ID_o.rd_addr  = ID.ID_i.instr[11: 7];
  
    // EX STAGE:
  assign EX.EX_o.mem_wren    = EX.EX_i.mem_wren;
  assign EX.EX_o.wb_sel      = EX.EX_i.wb_sel;
  assign EX.EX_o.ld_unsigned = EX.EX_i.ld_unsigned;
  assign EX.EX_o.rd_wren     = EX.EX_i.rd_wren;
  assign EX.EX_o.byte_num    = EX.EX_i.byte_num;
  assign EX.EX_o.pc4         = EX.EX_i.pc4;
  assign EX.EX_o.rd_addr     = EX.EX_i.rd_addr;
  assign EX.EX_o.rs2_data    = EX.EX_i.rs2_data;

    // MEM STAGE:
  assign MEM.MEM_o.wb_sel   = MEM.MEM_i.wb_sel;
  assign MEM.MEM_o.rd_wren  = MEM.MEM_i.rd_wren;
  assign MEM.MEM_o.pc4      = MEM.MEM_i.pc4;
  assign MEM.MEM_o.rd_addr  = MEM.MEM_i.rd_addr;
  assign MEM.MEM_o.alu_data = MEM.MEM_i.alu_data;
  
    // WB STAGE: none

  ////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////*       DATAPATH       *//////////////////////////////

  /// INSTRUCTION FETCH STAGE ///
  PC_block PC ( .clk_i     ( clk_i     ),
                .rst_ni    ( rst_ni    ),
                .en_i      ( ~stall_IF ),
                .br_sel_i  ( EX.EX_i.br_sel   ),
                .alu_data_i( EX.EX_o.alu_data ),
                .pc4_o     ( IF.IF_o.pc4      ),
                .pc_o      ( IF.IF_o.pc       ));
  
  imem I_MEM ( .imem_addr_i( IF.IF_o.pc     ),
               .instruct_o ( IF.IF_o.instr  ));
  
  /// INSTRUCTION DECODE STAGE ///
  regfile REG_FILE ( .clk_i     ( clk_i    ), 
                     .rst_ni    ( rst_ni   ), 
                     .rd_wren_i ( WB.WB_i.rd_wren  ),
                     .rd_addr_i ( WB.WB_i.rd_addr  ),
                     .rd_data_i ( WB.wb_data       ),
                     .rs1_addr_i( ID.ID_o.rs1_addr ),
                     .rs2_addr_i( ID.ID_o.rs2_addr ),
                     .rs1_data_o( ID.ID_o.rs1_data ),
                     .rs2_data_o( ID.ID_o.rs2_data ));
  
  Imm_gen IMM ( .instr_i( ID.ID_i.instr[31:7] ),
                .type_i ( ID.imm_sel          ),
                .imm_o  ( ID.ID_o.imm         ));
  
  BRCOMP BR_COMP ( .rs1_data_i   ( ID.ID_o.rs1_data    ),
                   .rs2_data_i   ( ID.ID_o.rs2_data    ),
                   .br_unsigned_i( ID.br_unsigned ),
                   .br_less_o    ( ID.br_less     ),
                   .br_equal_o   ( ID.br_equal    ));
  
  ctrl_unit CTRL_UNIT ( .instr_i      ( ID.ID_i.instr       ),
                        .br_less_i    ( ID.br_less          ),
                        .br_equal_i   ( ID.br_equal         ),
                        .br_sel_o     ( ID.ID_o.br_sel      ),
                        .br_unsigned_o( ID.br_unsigned      ),
                        .imm_sel_o    ( ID.imm_sel          ),
                        .alu_op_o     ( ID.ID_o.alu_op      ),
                        .rd_wren_o    ( ID.ID_o.rd_wren     ),
                        .mem_wren_o   ( ID.ID_o.mem_wren    ),
                        .mem_us_o     ( ID.ID_o.ld_unsigned ),
                        .mem_wrnum_o  ( ID.ID_o.byte_num    ),
                        .op_a_sel_o   ( ID.ID_o.op_a_sel    ),
                        .op_b_sel_o   ( ID.ID_o.op_b_sel    ),
                        .wb_sel_o     ( ID.ID_o.wb_sel      ));
  
  /// EXECUTE STAGE ///
  ALU ALU ( .operand1_i( EX.operand_a     ),
            .operand2_i( EX.operand_b     ),
            .alu_op_i  ( EX.EX_i.alu_op   ),
            .alu_data_o( EX.EX_o.alu_data ));
  
  mux2to1_32b OP_A_MUX( .sel_i  ( EX.EX_i.op_a_sel ),
                        .data0_i( EX.EX_i.rs1_data   ),
                        .data1_i( EX.EX_i.pc       ),
                        .data_o ( EX.operand_a     ));
  
  mux2to1_32b OP_B_MUX( .sel_i  ( EX.EX_i.op_b_sel    ),
                        .data0_i( EX.EX_i.rs2_data ),
                        .data1_i( EX.EX_i.imm         ),
                        .data_o ( EX.operand_b       ));
  
  /// MEMORY STAGE ///
  lsu  LSU  ( .clk_i     ( clk_i  ),
              .rst_ni    ( rst_ni ),
              .sten_i    ( MEM.MEM_i.mem_wren    ),
              .ld_us_i   ( MEM.MEM_i.ld_unsigned ),
              .byte_num_i( MEM.MEM_i.byte_num    ),
              .addr_i    ( MEM.MEM_i.alu_data    ),
              .st_data_i ( MEM.MEM_i.rs2_data    ),
              .ld_data_o ( MEM.MEM_o.ld_data     ),
              .io_sw_i   ( io_sw_i     ),
              .io_push_i ( io_push_i   ),
              .io_lcd_o  ( io_lcd_o    ),
              .io_ledg_o ( io_ledg_o   ),
              .io_ledr_o ( io_ledr_o   ),
              .io_hex0_o ( io_hex0_o   ),
              .io_hex1_o ( io_hex1_o   ),
              .io_hex2_o ( io_hex2_o   ),
              .io_hex3_o ( io_hex3_o   ),
              .io_hex4_o ( io_hex4_o   ),
              .io_hex5_o ( io_hex5_o   ),
              .io_hex6_o ( io_hex6_o   ),
              .io_hex7_o ( io_hex7_o   ));
  
  /// WRITEBACK STAGE ///
  mux3to1_32b WB_MUX ( .sel_i  ( WB.WB_i.wb_sel   ),
                       .data0_i( WB.WB_i.alu_data ),
                       .data1_i( WB.WB_i.ld_data  ),
                       .data2_i( WB.WB_i.pc4      ),
                       .data_o ( WB.wb_data       ));
  
  /// Hazard unit ///
  hazard_unit_nop         HAZARD_UNIT ( .EX_br_sel  ( EX.EX_i.br_sel    ),
                                        .EX_rd_wren ( EX.EX_i.rd_wren   ),
                                        .EX_rs1_addr( EX.EX_i.rs1_addr  ),
                                        .EX_rs2_addr( EX.EX_i.rs2_addr  ),
                                        .EX_rd_addr ( EX.EX_i.rd_addr   ),
                                        .is_load    ( EX.EX_i.wb_sel[0] ),
                                        .MEM_rd_wren( MEM.MEM_i.rd_wren ),
                                        .MEM_rd_addr( MEM.MEM_i.rd_addr ),
                                        .ID_rs1_addr( ID.ID_o.rs1_addr  ),
                                        .ID_rs2_addr( ID.ID_o.rs2_addr  ),
                                        .ID_rd_addr ( ID.ID_o.rd_addr   ),
                                        .WB_rd_addr ( WB.WB_i.rd_addr   ),
                                        .stall_IF   ( stall_IF        ),
                                        .stall_ID   ( stall_ID        ),
                                        .flush_ID   ( flush_ID        ),
                                        .flush_EX   ( flush_EX        ));
  
  assign pc_debug = IF.IF_o.pc ;
  
endmodule: nop_pipeline