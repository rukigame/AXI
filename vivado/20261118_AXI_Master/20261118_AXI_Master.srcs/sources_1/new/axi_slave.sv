`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2026/11/18 15:45:04
// Design Name: 
// Module Name: axi_slave
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


module axi_slave(
    input logic ACLK,
    input logic ARESETn,
    // AW channel
    input logic [31:0] AWADDR,
    input logic AWVALID,
    output logic AWREADY,
    // W channel
    input logic [31:0] WDATA,
    input logic WVALID,
    output logic WREADY,
    // B channel
    output logic [1:0] BRESP,
    output logic BVALID,
    input logic BREADY,
    // AR channel
    input logic [31:0] ARADDR,
    input logic ARVALID,
    output logic ARREADY,
    // R channel
    output logic [31:0] RDATA,
    output logic RVALID,
    input logic RREADY,
    output logic RRESP
    );

    logic [31:0] slv_reg0, slv_reg1, slv_reg2, slv_reg3;

    // 핸드셰이크
    logic [31:0] aw_addr_reg, w_data_reg, ar_addr_reg;
    logic aw_done, w_done, ar_done;   // 핸드셰이크 완료 
    logic reg_we;                     // 레지스터 쓰기 펄스 (B 채널에서 발생)
    logic r_start;                    // 읽기 응답 시작 펄스 (R 채널에서 발생)

/************* Write Transaction ****************/
    //AW channel
    typedef enum logic{
        AW_IDLE = 0,
        AW_READY
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
        AWREADY = 1'b0;
        aw_state_next = aw_state;
        case(aw_state)
        AW_IDLE:begin
            AWREADY = 1'b0;
            if(AWVALID & !aw_done)begin
                aw_state_next = AW_READY;
            end
        end
        AW_READY:begin
            AWREADY = 1'b1;
            if(AWVALID)begin
                aw_state_next = AW_IDLE;
            end
        end
        default:begin
            AWREADY = 1'b0;
            aw_state_next = AW_IDLE;
        end
        endcase
    end

    // AW 주소 저장
    always_ff @( posedge ACLK ) begin
        if(!ARESETn) begin
            aw_addr_reg <= 32'd0;
            aw_done     <= 1'b0;
        end else if(AWVALID & AWREADY) begin
            aw_addr_reg <= AWADDR;
            aw_done     <= 1'b1;
        end else if(reg_we) begin
            aw_done     <= 1'b0;
        end
    end

    //W channel
    typedef enum logic{
        W_IDLE = 0,
        W_READY
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
        WREADY = 1'b0;
        w_state_next = w_state;
        case(w_state)
        W_IDLE:begin
            WREADY = 1'b0;
            if(WVALID & !w_done)begin
                w_state_next = W_READY;
            end
        end
        W_READY:begin
            WREADY = 1'b1;
            if(WVALID)begin
                w_state_next = W_IDLE;
            end
        end
        default:begin
            WREADY = 1'b0;
            w_state_next = W_IDLE;
        end
        endcase
    end

    // W 데이터 저장
    always_ff @( posedge ACLK ) begin
        if(!ARESETn) begin
            w_data_reg <= 32'd0;
            w_done     <= 1'b0;
        end else if(WVALID & WREADY) begin
            w_data_reg <= WDATA;
            w_done     <= 1'b1;
        end else if(reg_we) begin
            w_done     <= 1'b0;
        end
    end

    //B channel
    typedef enum logic{
        B_IDLE = 0,
        B_VALID
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
        BVALID = 1'b0;
        BRESP  = 2'b00;
        reg_we = 1'b0;
        b_state_next = b_state;
        case(b_state)
        B_IDLE:begin
            BVALID = 1'b0;
            if(aw_done & w_done)begin   
                reg_we = 1'b1;          
                b_state_next = B_VALID;
            end
        end
        B_VALID:begin
            BVALID = 1'b1;
            BRESP  = 2'b00;             
            if(BREADY)begin
                b_state_next = B_IDLE;
            end
        end
        default:begin
            BVALID = 1'b0;
            b_state_next = B_IDLE;
        end
        endcase
    end

   
    always_ff @( posedge ACLK ) begin
        if(!ARESETn) begin
            slv_reg0 <= 32'd0;
            slv_reg1 <= 32'd0;
            slv_reg2 <= 32'd0;
            slv_reg3 <= 32'd0;
        end else if(reg_we) begin
            case(aw_addr_reg[3:2])
                2'd0: slv_reg0 <= w_data_reg;
                2'd1: slv_reg1 <= w_data_reg;
                2'd2: slv_reg2 <= w_data_reg;
                2'd3: slv_reg3 <= w_data_reg;
            endcase
        end
    end

/*************** Read Transaction *****************/
    //AR channel
    typedef enum logic{
        AR_IDLE = 0,
        AR_READY
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
        ARREADY = 1'b0;
        ar_state_next = ar_state;
        case(ar_state)
        AR_IDLE:begin
            ARREADY = 1'b0;
            if(ARVALID & !ar_done)begin
                ar_state_next = AR_READY;
            end
        end
        AR_READY:begin
            ARREADY = 1'b1;
            if(ARVALID)begin
                ar_state_next = AR_IDLE;
            end
        end
        default:begin
            ARREADY = 1'b0;
            ar_state_next = AR_IDLE;
        end
        endcase
    end

    // AR 주소 저장
    always_ff @( posedge ACLK ) begin
        if(!ARESETn) begin
            ar_addr_reg <= 32'd0;
            ar_done     <= 1'b0;
        end else if(ARVALID & ARREADY) begin
            ar_addr_reg <= ARADDR;
            ar_done     <= 1'b1;
        end else if(r_start) begin
            ar_done     <= 1'b0;
        end
    end

    //R channel
    typedef enum logic{
        R_IDLE = 0,
        R_VALID
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
        RVALID  = 1'b0;
        RRESP   = 1'b0;
        r_start = 1'b0;
        r_state_next = r_state;
        case(r_state)
        R_IDLE:begin
            RVALID = 1'b0;
            if(ar_done)begin    
                r_start = 1'b1;
                r_state_next = R_VALID;
            end
        end
        R_VALID:begin
            RVALID = 1'b1;
            RRESP  = 1'b0;              // OKAY
            if(RREADY)begin
                r_state_next = R_IDLE;
            end
        end
        default:begin
            RVALID = 1'b0;
            r_state_next = R_IDLE;
        end
        endcase
    end

    // 주소
    always_comb begin
        case(ar_addr_reg[3:2])
            2'd0: RDATA = slv_reg0;
            2'd1: RDATA = slv_reg1;
            2'd2: RDATA = slv_reg2;
            2'd3: RDATA = slv_reg3;
            default: RDATA = 32'd0;
        endcase
    end

endmodule
