//`include "D:/BKU/CTMT/2011919_Pipelined_Processor/Struct.sv"
`timescale 1ns/1ps

module tb_ipc;

  // Inputs
  reg clk_i;
  reg rstF_ni;
  reg rst_ni;
  reg rstN_ni;
  reg [31:0] io_sw_i;
  reg [31:0] io_push_i;

  // Outputs
  wire [31:0] n_ledr_o;
  wire [ 6:0] n_hex0_o;
  wire [ 6:0] n_hex1_o;
  wire [ 6:0] n_hex2_o;
  wire [ 6:0] n_hex3_o;

  wire [31:0] f_ledr_o;
  wire [ 6:0] f_hex0_o;
  wire [ 6:0] f_hex1_o;
  wire [ 6:0] f_hex2_o;
  wire [ 6:0] f_hex3_o;
  
  wire [31:0] pc_F;
  wire [31:0] pc_N;
  reg  [31:0] prev_pc_F;
  reg  [31:0] prev_pc_N;
  
  // Variables for IPC calculation
  integer inF_count;
  integer inN_count;
  integer cycle_count;
  integer stopF;

  assign rstF_ni = rst_ni & stopF;
  assign rstN_ni = rst_ni ;
  assign  rst_ni = io_sw_i[17] ;

  // Instantiate the singlecycle module
  forwarding_pipeline dut_f (
  .clk_i    ( clk_i   ),
  .rst_ni   ( rstF_ni  ),
  .io_sw_i  ( io_sw_i ),
  .io_ledr_o( f_ledr_o ),
  .io_hex0_o( f_hex0_o ),
  .io_hex1_o( f_hex1_o ),
  .io_hex2_o( f_hex2_o ),
  .io_hex3_o( f_hex3_o ),
  .pc_debug ( pc_F  ));
  
  nop_pipeline dut_n (
  .clk_i    ( clk_i   ),
  .rst_ni   ( rstN_ni  ),
  .io_sw_i  ( io_sw_i ),
  .io_ledr_o( n_ledr_o ),
  .io_hex0_o( n_hex0_o ),
  .io_hex1_o( n_hex1_o ),
  .io_hex2_o( n_hex2_o ),
  .io_hex3_o( n_hex3_o ),
  .pc_debug ( pc_N  ));
  
  function real calculate_ipc;
    input integer instr_count;
    input integer clk_count;
    begin
      calculate_ipc = $itor(instr_count) / $itor(clk_count); // Convert to real for decimal division
    end
  endfunction
  
  // Clock generation
  always #5 clk_i = ~clk_i;

  // Monitor pc_debug to count instructions
  always_ff @(posedge clk_i, negedge rst_ni) begin
    if ( !rst_ni ) begin 
      cycle_count <= cycle_count ;
      inF_count   <= inF_count ;
      inN_count   <= inN_count;
    end
    if (  rst_ni ) begin
      prev_pc_F   <= pc_F;
      prev_pc_N   <= pc_N;
      cycle_count <= cycle_count + 1;
    if ( ( pc_F != prev_pc_F ) & ( pc_F != 0 ) ) begin
      inF_count   <= inF_count + 1;
    end
    if ( ( pc_N != prev_pc_N ) & ( pc_N != 0 ) ) begin
      inN_count   <= inN_count + 1;
    end
    if ( ( f_hex3_o == 7'he ) & ( stopF ) ) begin
        stopF = 0;
        $display("_______________________FORWARDING IPC_______________________");
        $display("Number of Instructions: %d \nNumber of CLKs: %d \nIPC: %f", inF_count, cycle_count, calculate_ipc( inF_count, cycle_count));
    end
    if ( n_hex3_o == 7'he ) begin
        $display("_______________________NOPPING IPC_______________________");
        $display("Number of Instructions: %d \nNumber of CLKs: %d \nIPC: %f", inN_count, cycle_count, calculate_ipc( inN_count, cycle_count));
        $finish;
    end
    end
  end
  
  // Reset generation
  initial begin
    clk_i = 0;
    inF_count = 0;
    stopF = 1;
    inN_count = 0;
    cycle_count = 0;
    io_sw_i = 18'b0; // rst_ni = 1'b0;
    #3;
    io_sw_i = 18'b10_1111_1111_1111_1111;
    #3;
    io_sw_i = 18'b11_1111_1111_1111_1111;
    /*$finish;*/ // using finish_detect instead
  end

endmodule
