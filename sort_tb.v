`timescale 1ns / 1ps

module tb_ram_sorting;

    reg clk;
    reg rst;
    wire [7:0]m0,m1,m2,m3;
    wire [7:0]r1, r2, r3, r4;
    wire wren, rden, r2_inc, swap;
    wire done;
    wire [2:0] p_s;
    wire [2:0] r1_count, r2_count;
    wire lt, gt, eq;
    wire [7:0] dataout;
    wire [1:0] address;
    // Instantiate DUT
    sort uut (
        .clk(clk),
        .rst(rst),
        .dataout(dataout),
        .wren(wren),
        .rden(rden),
        .r2_inc(r2_inc),
        .swap(swap),
        .address(address),
        .done(done),
        .p_s(p_s),
        .n_s(n_s),
        .lt(lt),
        .gt(gt),.eq(eq),
        .r1(r1),
        .r2(r2),
        .r3(r3),
        .r4(r4),
        .r1_count(r1_count),
        .r2_count(r2_count),
        .m1(m1),.m2(m2),.m3(m3),.m0(m0)
    );

    // Clock generation: 10ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Simulation control
    initial begin
        rst = 1;
        #20 rst = 0; // release reset

        // Wait until sorting is done
        //wait(done);

      
    end

endmodule
