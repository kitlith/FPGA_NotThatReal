`include "top.v"

module testbench();

    reg clk;

    reg ntr_clk, ntr_cs1;
    wire [7:0] ntr_data;
    wire [7:0] dat_in;
    reg [7:0] dat_out;

    parameter INPUT=1, OUTPUT=0;
    reg ntr_dir;

    reg rx;
    wire tx;

    // assign ntr_data = dat_out;

    ppio #(8) bus(ntr_dir, ntr_data, dat_out, dat_in);

    // assign dat_in = ntr_data;
    // assign ntr_data = out_en ? dat_out : 8'bzzzzzzzz;


    wire [3:0] led;

    top test(clk, ntr_data, ntr_clk, ntr_cs1, rx, tx, led);

    initial begin
        clk = 0;
        forever begin
            #1 clk = ~clk;
        end
    end

    initial begin
        $monitor("ntr_clk: %b, ntr_cs1: %b, ntr_data: %x, led: %b",
                ntr_clk, ntr_cs1, ntr_data, led);
        ntr_clk = 0;
        ntr_cs1 = 0;
        ntr_dir = OUTPUT;
        #5 ntr_cs1 = 1;
        #5 ntr_clk = 1;
        #10 ntr_cs1 = 0;
        #10 ntr_clk = 0;

        // #10 ntr_clk = 1; // Extra clk to match random cycle that happens
        // #10 ntr_clk = 0; // deterministically sometimes?

        #0  dat_out = 8'h90;
        #10 ntr_clk = 1; // sample 0xFF

        #10 ntr_clk = 0;
        #0 dat_out = 0;
        #10 ntr_clk = 1; // sample 0x00

        #10 ntr_clk = 0;
        #10 ntr_clk = 1; // sample 0x00
        #10 ntr_clk = 0;
        #10 ntr_clk = 1; // sample 0x00
        #10 ntr_clk = 0;
        #10 ntr_clk = 1; // sample 0x00
        #10 ntr_clk = 0;
        #10 ntr_clk = 1; // sample 0x00
        #10 ntr_clk = 0;
        #10 ntr_clk = 1; // sample 0x00
        #10 ntr_clk = 0;
        #0 dat_out = 8'h00;
        #10 ntr_clk = 1; // sample 0x01

        #10 ntr_clk = 0; // response
        #0  ntr_dir = INPUT;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #10 ntr_clk = 1;

        #20 ntr_cs1 = 1;
        #0  ntr_dir = OUTPUT;

        #100 ntr_cs1 = 0;
        #10 ntr_clk = 0;

        // #10 ntr_clk = 1; // See above comment.
        // #10 ntr_clk = 0;

        #0 dat_out = 8'hFF;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #0 dat_out = 0;
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
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #0 dat_out = 8'h01;
        #10 ntr_clk = 1;
        #10 ntr_clk = 0;
        #20 $finish;

    end

endmodule
