`timescale 1ps/1ps

module tb_REGFILE;

  logic [31:0] rd_data;
  logic clk_i, rst_ni, rd_wren;
  logic [4:0] rs1_addr, rs2_addr, rd_addr; 
  logic [31:0] rs1_data, rs2_data;

  regfile dut (
      .clk_i( clk_i ), 
      .rst_ni( rst_ni ), 
      .rd_wren_i( rd_wren ),
      .rd_addr_i( rd_addr ), 
      .rs1_addr_i( rs1_addr ), 
      .rs2_addr_i( rs2_addr ), 
      .rd_data_i( rd_data ), 
      .rs1_data_o( rs1_data ), 
      .rs2_data_o( rs2_data )
  );

  initial begin
    rst_ni   = 1'b0;  // Reset active low
    rd_wren  = 1'b0;
    rd_data  = 32'h0;
    rs1_addr = 5'd0;
    rs2_addr = 5'd0;
    rd_addr  = 5'd0;
  end

  initial begin
    clk_i = 1'b0;
    forever #5 clk_i = ~clk_i;  // Clock period 10ps
  end

  task automatic check_data(input [31:0] expected_data);
    begin
      if (rs1_data !== expected_data || rs2_data !== expected_data) begin
        $error("Test FAILED: rs1_data or rs2_data != expected_data (0x%h), rs1_data=0x%h, rs2_data=0x%h", expected_data, rs1_data, rs2_data);
      end else begin
        $display("Test PASSED: Data matches expected value 0x%h", expected_data);
      end
    end
  endtask

  initial begin
    integer i;
    rst_ni = 1'b1;

    for (i = 0; i < 1000; i = i + 1) begin
      #10;
      rd_wren  = 1'b1;  // Enable write
      rd_addr  = $urandom_range(0, 31);
      rd_data  = $urandom;

      #10;
      rd_wren  = 1'b0;  // Disable write
      rs1_addr = rd_addr;
      rs2_addr = rd_addr;
      
      #10;
      check_data(rd_data);
    end
    
    #10;
    $finish;
  end

endmodule
