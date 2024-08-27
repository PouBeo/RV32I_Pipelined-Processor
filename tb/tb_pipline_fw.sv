`include "D:/BKU/CTMT/2011919_Pipelined_Processor/Struct.sv"
`timescale 1ns/1ps

module tb_pipe;

  // Inputs
  reg clk_i;
  reg rst_ni;
  reg [31:0] io_sw_i;
  reg [31:0] io_push_i;

  // Outputs
  wire [31:0] io_lcd_o;
  wire [31:0] io_ledg_o;
  wire [31:0] io_ledr_o;
  wire [31:0] io_hex0_o;
  wire [31:0] io_hex1_o;
  wire [31:0] io_hex2_o;
  wire [31:0] io_hex3_o;
  wire [31:0] io_hex4_o;
  wire [31:0] io_hex5_o;
  wire [31:0] io_hex6_o;
  wire [31:0] io_hex7_o;
  wire [31:0] pc_debug;

  // Instantiate the singlecycle module
  forwarding_pipeline dut (
    .clk_i(clk_i),
    .rst_ni(rst_ni),
    .io_sw_i(io_sw_i),
    .io_push_i(io_push_i),
    .io_lcd_o(io_lcd_o),
    .io_ledg_o(io_ledg_o),
    .io_ledr_o(io_ledr_o),
    .io_hex0_o(io_hex0_o),
    .io_hex1_o(io_hex1_o),
    .io_hex2_o(io_hex2_o),
    .io_hex3_o(io_hex3_o),
    .io_hex4_o(io_hex4_o),
    .io_hex5_o(io_hex5_o),
    .io_hex6_o(io_hex6_o),
    .io_hex7_o(io_hex7_o)
    //.pc_debug(pc_debug)
  );
  
  // Clock generation
  always #10 clk_i = ~clk_i;

  // Reset generation
  initial begin
    clk_i = 0;
    rst_ni = 1'b0;
    #55;
    rst_ni = 1'b1;
    #50000;//;
    rst_ni = 1'b0;
    #55;
    rst_ni = 1'b1;
    #15000;
    $finish;
  end

  // Stimulus
  /*initial begin
    // Initialize inputs
    io_sw_i = 32'h0000_0000;
    io_push_i = 32'h0000_0000;
    // Wait for some time before starting clock
    #5000;
    
    $finish;
  end*/

endmodule
