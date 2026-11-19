`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/19 15:47:05
// Design Name: 
// Module Name: tb_AXI_Lite_Slave
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_AXI_Lite_Slave ();

    // Parameters
    localparam integer C_S00_AXI_DATA_WIDTH = 32;
    localparam integer C_S00_AXI_ADDR_WIDTH = 4;

    // DUT inputs (driven by the testbench)
    logic                                   s00_axi_aclk;
    logic                                   s00_axi_aresetn;
    logic [C_S00_AXI_ADDR_WIDTH-1 : 0]      s00_axi_awaddr;
    logic [2 : 0]                           s00_axi_awprot;
    logic                                   s00_axi_awvalid;
    logic [C_S00_AXI_DATA_WIDTH-1 : 0]      s00_axi_wdata;
    logic [(C_S00_AXI_DATA_WIDTH/8)-1 : 0]  s00_axi_wstrb;
    logic                                   s00_axi_wvalid;
    logic                                   s00_axi_bready;
    logic [C_S00_AXI_ADDR_WIDTH-1 : 0]      s00_axi_araddr;
    logic [2 : 0]                           s00_axi_arprot;
    logic                                   s00_axi_arvalid;
    logic                                   s00_axi_rready;

    // DUT outputs
    logic                                   s00_axi_awready;
    logic                                   s00_axi_wready;
    logic [1 : 0]                           s00_axi_bresp;
    logic                                   s00_axi_bvalid;
    logic                                   s00_axi_arready;
    logic [C_S00_AXI_DATA_WIDTH-1 : 0]      s00_axi_rdata;
    logic [1 : 0]                           s00_axi_rresp;
    logic                                   s00_axi_rvalid;

    logic [C_S00_AXI_DATA_WIDTH-1 : 0] rdata;

    // DUT instance
    myip_v1_0 #
        (C_S00_AXI_DATA_WIDTH,
        C_S00_AXI_ADDR_WIDTH)
     dut (.*);

    always #5 s00_axi_aclk = ~s00_axi_aclk;

    task axi_write(logic [31:0] addr, logic [31:0]data);
        //AW
        s00_axi_awaddr <= addr;
        s00_axi_awvalid <= 1'b1;
        //W
        s00_axi_wdata <= data;
        s00_axi_wvalid <= 1'b1;
        s00_axi_wstrb <= 4'b1111;
        //B
        s00_axi_bready <= 1'b1;
        wait (s00_axi_awready & s00_axi_wready);
        @(posedge s00_axi_aclk);
        s00_axi_awvalid <= 1'b0;
        s00_axi_wvalid <= 1'b0;
        wait (s00_axi_bvalid);
        @(posedge s00_axi_aclk);
        s00_axi_bready <= 1'b0;
        @(posedge s00_axi_aclk);
        $display("[%t] WRITE AWADDR = 0x%0h, WDATA = 0x%0h", $time, addr, data);
    endtask 

    task axi_read(logic[31:0]addr);
        @(posedge s00_axi_aclk);
        // AR
        s00_axi_araddr <= addr;
        s00_axi_arvalid <= 1'b1;
        // R
        s00_axi_rready <= 1'b1;
        wait(s00_axi_arready);
        @(posedge s00_axi_aclk);
        s00_axi_arvalid <= 1'b0;
        wait(s00_axi_rvalid);
        @(posedge s00_axi_aclk);
        s00_axi_rready <=1'b0;
        rdata <= s00_axi_rdata;

        @(posedge s00_axi_aclk);
        $display("[%t] READ ARADDR = 0x%0h, RDATA = 0x%0h", $time, addr, rdata);
    endtask

    initial begin
        s00_axi_aclk = 0;
        s00_axi_aresetn = 0;
        repeat (3) @(posedge s00_axi_aclk);
        s00_axi_aresetn = 1;
        
        repeat (1) @(posedge s00_axi_aclk);
        axi_write(32'h00000000, 32'hDEADBEEF);
        axi_write(32'h00000004, 32'hCAFEBABE);
        axi_write(32'h00000008, 32'h12345678);
        axi_write(32'h0000000C, 32'hAAAABBBB);

        repeat (2) @(posedge s00_axi_aclk);
        axi_read(32'h00000000);
        axi_read(32'h00000004);
        axi_read(32'h00000008);
        axi_read(32'h0000000C);

        repeat (2) @(posedge s00_axi_aclk);
        $finish;
    end
endmodule