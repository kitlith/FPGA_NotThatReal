`include "top.v"

module testbench();

    reg clk;

    reg ntr_clk, ntr_cs1;
    reg [7:0] ntr_data;
    wire [3:0] led;

    top test(clk, ntr_data, ntr_clk, ntr_cs1, led);

    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        $monitor("ntr_clk: %b, ntr_data: %x, led: %b",
                ntr_clk, ntr_data, led);
        ntr_clk = 1;
        ntr_cs1 = 1;
        #10 ntr_cs1 = 0;
        #0  ntr_data = 8'hFF;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #5 ntr_data = 0;
        #5 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #5 ntr_data = 8'h01;
        #5 ntr_clk = 1;
        #20 ntr_cs1 = 1;

        #20 ntr_cs1 = 0;
        #10 ntr_clk = 0;
        #5 ntr_data = 8'hFF;
        #5 ntr_clk = 1;
        #10 ntr_clk = 0;
        #5 ntr_data = 0;
        #5 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #5 ntr_data = 8'h00;
        #5 ntr_clk = 1;
        #10 ntr_clk = 0;
        #20 $finish;

    end

endmodule
