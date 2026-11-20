`timescale 1ns / 1ps



module gpio(
    //internal port
    input wire [3:0] cr,
    input wire [3:0] odr,
    output wire [3:0] idr,
    //external port
    inout wire [3:0] io_port

);
    genvar i;

    generate
        for(i=0; i<4; i=i+1)begin
            assign io_port[i] = cr[i] ? odr[i] : 1'bz;
            assign idr[i] = ~cr[i] ? io_port[i] : 1'bz;
        end
    endgenerate

    // assign io_port[0] = cr[0] ? odr[0] : 1'bz;
    // assign idr[0] = ~cr[0] ? io_port[0] : 1'bz;

    // assign io_port[1] = cr[1] ? odr[1] : 1'bz;
    // assign idr[1] = ~cr[1] ? io_port[1] : 1'bz;

    // assign io_port[2] = cr[2] ? odr[2] : 1'bz;
    // assign idr[2] = ~cr[2] ? io_port[2] : 1'bz;

    // assign io_port[3] = cr[3] ? odr[3] : 1'bz;
    // assign idr[3] = ~cr[3] ? io_port[3] : 1'bz;

endmodule
