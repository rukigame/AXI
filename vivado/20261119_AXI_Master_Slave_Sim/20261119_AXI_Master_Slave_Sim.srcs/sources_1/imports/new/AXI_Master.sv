`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/18 14:14:06
// Design Name: 
// Module Name: AXI_Master
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


module AXI_Master(
    input logic ACLK,
    input logic ARESETn,
    // AW channel
    output logic [31:0] AWADDR,
    output logic AWVALID,
    input logic AWREADY,
    // W channel
    output logic [31:0] WDATA,
    output logic WVALID,
    input logic WREADY,
    // B channel
    input logic [1:0] BRESP,
    input logic BVALID,
    output logic BREADY,
    // AR channel
    output logic [31:0] ARADDR,
    output logic ARVALID,
    input logic ARREADY,
    // R channel
    input logic [31:0] RDATA,
    input logic RVALID,
    output logic RREADY,
    input logic [1:0] RRESP,

    //internal signals
    input logic transfer,
    output logic ready,
    input logic [31:0] addr,
    input logic [31:0] wdata,
    output logic [31:0] rdata,
    input logic write
);

    logic w_ready;
    logic r_ready;
    assign ready =  w_ready|r_ready;

/************* Write Transaction ****************/
    //AW channel
    typedef enum logic{
        AW_IDLE = 0,
        AW_VALID
    } aw_state_e;

    aw_state_e aw_state, aw_state_next;

    always_ff @( posedge ACLK ) begin
        if(!ARESETn) begin
            aw_state <= AW_IDLE;
        end else begin
            aw_state <= aw_state_next;
        end 
        
    end

    always_comb begin 
        AWADDR = addr;
        AWVALID =  1'b0;
        aw_state_next = aw_state;
        case(aw_state)
        AW_IDLE:begin
            AWVALID = 1'b0;
            if(transfer & write)begin
                aw_state_next = AW_VALID;
            end
        end
        AW_VALID:begin
            AWADDR = addr;
            AWVALID = 1'b1;
            if(AWREADY)begin
                aw_state_next = AW_IDLE;
            end
        end
        default:begin
            AWADDR = addr;
            AWVALID = 1'b0;
            aw_state_next = AW_IDLE;
        end
        endcase
    end

    //W channel
    typedef enum logic{
        W_IDLE = 0,
        W_VALID
    } w_state_e;

    w_state_e w_state, w_state_next;

    always_ff @( posedge ACLK ) begin
        if(!ARESETn) begin
            w_state <= W_IDLE;
        end else begin
            w_state <= w_state_next;
        end 
    end

    always_comb begin 
        WDATA = wdata;
        WVALID =  1'b0;
        w_state_next = w_state;
        case(w_state)
        W_IDLE:begin
            WVALID = 1'b0;
            if(transfer & write)begin
                w_state_next = W_VALID;
            end
        end
        W_VALID:begin
            WDATA = wdata;
            WVALID = 1'b1;
            if(WREADY)begin
                w_state_next = W_IDLE;
            end
        end
        default:begin
            WDATA = wdata;
            WVALID = 1'b0;
            w_state_next = W_IDLE;
        end
        endcase
    end

    //B channel
    typedef enum logic{
        B_IDLE = 0,
        B_READY
    } b_state_e;

    b_state_e b_state, b_state_next;
    

    always_ff @( posedge ACLK ) begin
        if(!ARESETn) begin
            b_state <= B_IDLE;
        end else begin
            b_state <= b_state_next;
        end 
    end

    always_comb begin 
        BREADY = 1'b0;
        b_state_next = b_state;
        w_ready = 1'b0;
        case(b_state)
        B_IDLE:begin
            BREADY = 1'b0;
            if(WVALID)begin
                b_state_next = B_READY;
            end
        end
        B_READY:begin
            BREADY = 1'b1;
            if(BVALID & BREADY)begin
                b_state_next = B_IDLE;
                w_ready = 1'b1;
            end
        end
        default:begin
            BREADY = 1'b0;
            b_state_next = B_IDLE;
            w_ready = 1'b0;
        end
        endcase
    end

/*************** Read Transaction *****************/

    //AR channel
    typedef enum logic{
        AR_IDLE = 0,
        AR_VALID
    } ar_state_e;

    ar_state_e ar_state, ar_state_next;

    always_ff @( posedge ACLK ) begin
        if(!ARESETn) begin
            ar_state <= AR_IDLE;
        end else begin
            ar_state <= ar_state_next;
        end 
    end

    always_comb begin 
        ARADDR = addr;
        ARVALID =  1'b0;
        ar_state_next = ar_state;
        case(ar_state)
        AR_IDLE:begin
            ARVALID = 1'b0;
            if(transfer & !write)begin
                ar_state_next = AR_VALID;
            end
        end
        AR_VALID:begin
            ARADDR = addr;
            ARVALID = 1'b1;
            if(ARREADY)begin
                ar_state_next = AR_IDLE;
            end
        end
        default:begin
            ARADDR = addr;
            ARVALID = 1'b0;
            ar_state_next = AR_IDLE;
        end
        endcase
    end

    //R channel
    typedef enum logic{
        R_IDLE = 0,
        R_READY
    } r_state_e;

    r_state_e r_state, r_state_next;
    

    always_ff @( posedge ACLK ) begin
        if(!ARESETn) begin
            r_state <= R_IDLE;
        end else begin
            r_state <= r_state_next;
        end 
    end

    always_comb begin 
        RREADY = 1'b0;
        rdata = 32'd0;
        r_ready = 1'b0;
        r_state_next = r_state;
        case(r_state)
        R_IDLE:begin
            RREADY = 1'b0;
            if(ARVALID)begin
                r_state_next = R_READY;
            end
        end
        R_READY:begin
            RREADY = 1'b1;
            if(RVALID & RREADY)begin
                r_state_next = R_IDLE;
                rdata = RDATA;
                r_ready = 1'b1;
            end
        end
        default:begin
            RREADY = 1'b0;
            r_state_next = R_IDLE;
        end
        endcase
    end


endmodule