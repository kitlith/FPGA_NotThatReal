`include "up_counter.v"
`include "byte_shifter.v"
module parallel(clk, data, par_clk, command, ready, rst, state);
    parameter DAT_WIDTH = 8;
    parameter CMD_WIDTH = 8;
    parameter init = 0, wait_high = 2, sample = 1, wait_low = 4,
              dat_ready = 3;

    input clk, par_clk;
    input [7:0] data;
    input rst;
    output [63:0] command;
    output reg ready;

    output reg [2:0] state;

    wire [3:0] count;
    reg enable, count_rst;
    byte_shifter shift(clk, data, enable, 1'b0, command);
    up_counter #(4) counter(clk, enable, count_rst, count);

    initial begin
        state <= init;
    end

    always @(posedge clk) begin
        // if (rst) state <= init;
        // else begin
            case (state)
                init: begin
                    if (par_clk == 1) state <= wait_low;
                    else state <= init;
                end
                wait_high: begin
                    if (par_clk == 1) state <= sample;
                    else state <= state;
                end
                sample: begin
                    if (count == 7) state <= dat_ready;
                    else state <= wait_low;
                end
                wait_low, dat_ready: begin
                    if (par_clk == 0) state <= wait_high;
                    else state <= state;
                end
            endcase
        // end
    end

    always @* begin
        if (state == dat_ready) ready = 1;
        else ready = 0;

        if (state == dat_ready || state == init) count_rst = 1;
        else count_rst = 0;

        if (state == sample) enable = 1;
        else enable = 0;
    end

endmodule // parallel
