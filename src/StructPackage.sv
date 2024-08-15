// File: StructPackage.sv
package StructPkg;

  // Flip-flop: IF to ID
  typedef struct {
      logic [31:0] pc;
      logic [31:0] pc4;
      logic [31:0] instr;
  } IF_ID_ff;

  // Flip-flop: ID to EX
  typedef struct {
      //control logics:
      logic mem_wren;
      logic op_a_sel;
      logic op_b_sel;
      logic rd_wren;
      logic br_sel;
      logic ld_unsigned;
      logic [ 1:0] wb_sel;
      logic [ 3:0] alu_op;
      logic [ 3:0] byte_num;
      //datapaths:
      logic [31:0] pc;
      logic [31:0] pc4;
      logic [ 4:0] rs1_addr;
      logic [ 4:0] rs2_addr;
      logic [ 4:0] rd_addr;
      logic [31:0] rs1_data;
      logic [31:0] rs2_data;
      logic [31:0] imm;
  } ID_EX_ff;

  // Flip-flop: EX to MEM
  typedef struct {
      //control logics:
      logic mem_wren;
      logic rd_wren;
      logic ld_unsigned;
      logic [ 1:0] wb_sel;
      logic [ 3:0] byte_num;
      //datapaths:
      logic [31:0] pc4;
      logic [ 4:0] rd_addr;
      logic [31:0] rs2_forward;
      logic [31:0] alu_data;
  } EX_MEM_ff;

  // Flip-flop: MEM to WB
  typedef struct {
      //control logics:
      logic rd_wren;
      logic [ 1:0] wb_sel;
      //datapaths:
      logic [31:0] pc4;
      logic [ 4:0] rd_addr;
      logic [31:0] ld_data;
      logic [31:0] alu_data;
  } MEM_WB_ff;

  // Struct: FETCH STAGE
  typedef struct {
      IF_ID_ff  IF_o;
  } IF_stage_struct;

  // Struct: DECODE STAGE
  typedef struct {
      IF_ID_ff  ID_i;
      ID_EX_ff  ID_o;
      logic [ 2:0] imm_sel;
      logic br_unsigned;
      logic br_equal;
      logic br_less;
  } ID_stage_struct;

  // Struct: EXECUTE STAGE
  typedef struct {
      ID_EX_ff  EX_i;
      EX_MEM_ff EX_o;
      logic [31:0] rs1_forward;
      logic [31:0] operand_a;
      logic [31:0] operand_b;
  } EX_stage_struct;

  // Define memory stage struct
  typedef struct {
      EX_MEM_ff MEM_i;
      MEM_WB_ff MEM_o;
  } MEM_stage_struct;

  // Define writeback stage struct
  typedef struct {
      MEM_WB_ff WB_i;
      logic [31:0] wb_data;
  } WB_stage_struct;

endpackage: StructPkg
