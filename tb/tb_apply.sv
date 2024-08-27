`include "D:/BKU/CTMT/2011919_Pipelined_Processor/Struct.sv"
`timescale 1ns/1ps

module tb_apply;

  // Inputs
  reg clk_i;
  reg rst_ni;
  reg [17:0] io_sw_i;
  reg [ 4:0] io_push_i;

  // Outputs
  wire [31:0] io_lcd_o;
  wire [ 7:0] LCD_DATA;
  wire  LCD_RW;
  wire  LCD_RS;
  wire  LCD_EN;
  wire  LCD_ON;
  wire [8:0] io_ledg_o;
  wire [17:0] io_ledr_o;
  wire [6:0] io_hex0_o;
  wire [6:0] io_hex1_o;
  wire [6:0] io_hex2_o;
  wire [6:0] io_hex3_o;
  wire [6:0] io_hex4_o;
  wire [6:0] io_hex5_o;
  wire [6:0] io_hex6_o;
  wire [6:0] io_hex7_o;
  wire [6:0] pc_debug;

  // Instantiate the singlecycle module
  wrapper_2011919_pipelined_processsor dut
(
  .CLOCK_50(clk_i),
  .SW(io_sw_i),
  .KEY(io_push_i),
  .LEDR(io_ledr_o),
  .LEDG(io_ledg_o),
  .HEX0(io_hex0_o),
  .HEX1(io_hex1_o),
  .HEX2(io_hex2_o),
  .HEX3(io_hex3_o),
  .HEX4(io_hex4_o),
  .HEX5(io_hex5_o),
  .HEX6(io_hex6_o),
  .HEX7(io_hex7_o),
  .LCD_DATA(LCD_DATA),
  .LCD_RW(LCD_RW),
  .LCD_RS(LCD_RS),
  .LCD_EN(LCD_EN),
  .LCD_ON(LCD_ON));
  
  
/*  task show_reg;

    $display("[%3d] a_i = %10h, b_i = %10h, sll_x = %10h, sll_o = %10h", $time, a_i, b_i, sll_x, sll_o ); 
    assert( (sll_x == sll_o)) else begin
      $display("TEST FAILED");
    end
  endtask*/
  
  // Clock generation
  always #10 clk_i = ~clk_i;

  // Reset generation
  initial begin
    clk_i = 0;
    io_sw_i = 18'b0; // rst_ni = 1'b0;
    #55;
    io_sw_i = 18'b10_0000_0000_0000_0000; // rst_ni = 1'b1;
    #15;
    io_sw_i = 18'b10_1010_1011_1100_1101;
    #15;
    io_sw_i = 18'b11_1010_1011_1100_1111;
    #10000;
    io_sw_i = 18'b10_1010_1010_1010_1010;
    #300;
    io_sw_i = 18'b10_1010_1011_1100_1101;
    #15;
    io_sw_i = 18'b11_1111_1010_1111_1010;
    #10000;
    io_sw_i = 18'b0; // rst_ni = 1'b0;
    #55;
    io_sw_i = 18'b11_0000_0001_0010_0011; // rst_ni = 1'b1;
    #10000;
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
