`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.10.2025 19:22:57
// Design Name: 
// Module Name: sort
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


module sort(
    input  wire       clk,
    input  wire       rst,
    output reg  [7:0] dataout,
    output reg wren, rden, r2_inc, swap,comp,
    output reg [1:0] address,
    output reg done,
    output reg [2:0] p_s, n_s,
    output lt, gt, eq,
    output [7:0]r1,r2,
    output reg [7:0]r3, r4,
    output reg [2:0] r1_count, r2_count,
    output [7:0]m0,m1,m2,m3,
    output reg wren1
);

parameter s0=3'd0, s1=3'd1, s2=3'd2, s3=3'd3, s4=3'd4, s5=3'd5 ,s6=3'd6, s7=3'd7;
// FSM Sequential
always @(posedge clk or posedge rst)
if (rst)
p_s <= s0;
else
p_s <= n_s;

// FSM Next State Logic
always @(*) begin
case (p_s)
s0:n_s<=rst?s0:s1;
s1:n_s<=s2;
s2:n_s<=s3;
s3: if(lt | eq)
    n_s<=s4;
    else if(gt)
    n_s<=s5;
    else
    n_s<=s3; 
s4:n_s<=s6;
s5:n_s<=s6;
s6:n_s<=done?s7:s1;
s7:n_s<=s7;
default: n_s<=s0;
endcase
end
//Control Signal Generation
always @(*) begin
wren = 0; rden = 0; r2_inc = 0; swap = 0;
case(p_s)
s0: begin wren=0; rden=0; r2_inc=0; swap=0; comp=0; end
s1: begin wren=0; rden=1; r2_inc=0; swap=0; comp=0; end
s2: begin wren=0; rden=0; r2_inc=0; swap=0; comp=0; end
s3: begin wren=0; rden=0; r2_inc=0; swap=0; comp=0; end
s4: begin wren=0; rden=0; r2_inc=1; swap=0; comp=0; end
s5: begin wren=0; rden=0; r2_inc=1; swap=1; comp=0; end
s6: begin wren=1; rden=0; r2_inc=0; swap=0; comp=0; end
s7: begin wren=0; rden=1; r2_inc=0; swap=0; comp=1; end
default: begin wren=0; rden=0; r2_inc=0; swap=0; comp=0;end
endcase
end

always @(posedge clk or posedge rst) begin
if (rst) 
begin
r1_count <= 3'd0;
r2_count <= 3'd1;
end 
else if(comp) 
begin
if(r1_count == 3'd3 | r1_count == 3'd4 )
r1_count <= 3'd0;
else
r1_count <= r1_count + 1'b1;
end 
else 
begin
if(r2_count >= 3'd4) 
begin
r1_count<=r1_count+1;
r2_count<=r1_count+1;  // reset r2_count for next inner loop
end 
else if(r2_inc) 
begin
r2_count <= r2_count + 1;
end
end
end


always @(*) 
begin
if (rst)
done <= 0;
else if (r1_count==3'd3&r2_count==3'd4)
done <= 1;
else
done <=0;
end

magnitude_comp c1(clk,r1,r2,lt,gt,eq);
ram_4x8_dualport mem(clk,rst,wren,rden,r1_count,r2_count-1,r1_count,r2_count,r3,r4,r1,r2,m0,m1,m2,m3);

always @ (posedge clk)
if(swap)
begin
r3<=r2;
r4<=r1;
end
else
begin
r3<=r1;
r4<=r2;
end

always @ (*)
if(comp)
dataout<=r1;
else
dataout<=0;

always @(posedge clk)
if(comp)
address<=r1_count;
else
address<=0;

endmodule

module magnitude_comp(input clk,
    input [7:0] r1, r2,
    output reg lt, gt, eq
);
always @(posedge clk) 
begin
if (r1 > r2)
begin
lt=0;gt=1;eq=0;
end
else if (r1 < r2) 
begin
lt=1;gt=0;eq=0;
end 
else 
begin
lt=0;gt=0;eq=1;
end
end
endmodule

module ram_4x8_dualport (
    input clk,
    input rst,                  // Reset signal
    input wren,                 // Write enable
    input rden,                 // Read enable
    input [1:0] wr_addr1,       // Write address 1
    input [1:0] wr_addr2,       // Write address 2
    input [1:0] rd_addr1,       // Read address 1
    input [1:0] rd_addr2,       // Read address 2
    input [7:0] datain1,        // Data input 1
    input [7:0] datain2,        // Data input 2
    output reg [7:0] dataout1,  // Data output 1
    output reg [7:0] dataout2,   // Data output 2
    output reg [7:0] m0,m1,m2,m3
);

    // Memory array
    reg [7:0] mem [0:3];

    // Initialize memory
    initial begin
        mem[0] = 8'h25;
        mem[1] = 8'h19;
        mem[2] = 8'h74;
        mem[3] = 8'h97;
       
    end

    always @(posedge clk) begin
        if (rst) begin
            // Reset memory and outputs
        mem[0] = 8'h25;
        mem[1] = 8'h19;
        mem[2] = 8'h74;
        mem[3] = 8'h97;
        end
        else begin
            // Write operations
            if (wren) begin
                mem[wr_addr1] <= datain1;
                if (wr_addr2 != wr_addr1)
                    mem[wr_addr2] <= datain2;
            end

            // Read operations
            if (rden) begin
                dataout1 <= mem[rd_addr1];
                dataout2 <= mem[rd_addr2];
            end
        end
    end
    always @(*)
begin
m0<=mem[0];
m1<=mem[1];
m2<=mem[2];
m3<=mem[3];
end

endmodule