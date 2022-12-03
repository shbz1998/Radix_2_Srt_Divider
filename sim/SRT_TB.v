`timescale 1ns / 1ps
`define PERIOD 10

module SRT_TB(

    );
    
//input wire[8:0] z, //0.x1x2x3x4x5...
//input wire[4:0] d, //0.d1d2d3d4....
//output wire [3:0] q,
//output wire[8:0] s,
//input wire clk,
//input wire rst,
//output wire done    

reg [8:0] z;
reg [4:0] d;
reg clk;
reg rst;

wire done;
wire [3:0] q;
wire [8:0] s;

SRT s0(.clk(clk), .rst(rst), .q(q), .s(s), .z(z), .d(d), .done(done));

// NON_RESTORING s1(.clk(clk), .rst(rst), .q(q), .s(s), .z(z), .d(d), .done(done));

initial 
begin
clk <= 0;
forever #(`PERIOD/2) clk = ~clk;
end


initial
begin


z= 117;

d=14;


rst = 1;
#(`PERIOD);

rst = 0;
#(`PERIOD);





end


endmodule


