`timescale 1ns / 1ps

`ifndef CONST_VALUES

`define CONST_VALUES
// PC_select
  `define pc4    1'b0
  `define branch 1'b1
// Forwarding[1:0]
  `define NOforward  2'b00
  `define forwardWB  2'b01
  `define forwardMEM 2'b10
// ALU_select [3:0]
  `define ADD   4'd0
  `define SUB   4'd1
  `define SLL   4'd2
  `define SLT   4'd3
  `define SLTU  4'd4
  `define XOR   4'd5
  `define SRL   4'd6
  `define SRA   4'd7
  `define OR    4'd8
  `define AND   4'd9
  `define LUI   4'd10
//ImmType[2:0]
  `define RTYPE  3'd0
  `define ITYPE  3'd1
  `define STYPE  3'd2
  `define BTYPE  3'd3
  `define UTYPE  3'd4
  `define JTYPE  3'd5
  
`endif
