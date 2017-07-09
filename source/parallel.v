`include "up_counter.v"
`include "byte_shifter.v"
module parallel(clk, data, par_clk, command, ready);
    parameter DAT_WIDTH = 8;
    parameter CMD_WIDTH = 8;
    parameter init = 0, wait_high = 2, sample = 1, wait_low = 4,
              dat_ready = 3;

    input clk, par_clk;
    input [7:0] data;
    output [63:0] command;
    output reg ready;

    reg [2:0] state;

    wire [7:0] count;
    reg enable, count_rst;
    byte_shifter shift(clk, data, enable, 1'b0, command);
    up_counter counter(clk, enable, count_rst, count);

    initial begin
        state <= init;
    end

    always @(posedge clk) begin
        case (state)
            init: begin
                if (par_clk == 1) state <= wait_low;
                else state <= init;
            end
            wait_high, dat_ready: begin
                if (par_clk == 1) state <= sample;
                else state <= state;
            end
            sample: state <= wait_low;
            wait_low: begin
                if (par_clk == 0) begin
                    if (count >= 8) state <= dat_ready;
                    else state <= wait_high;
                end
                else state <= wait_low;
            end
        endcase
    end

    always @* begin
        if (state == dat_ready) ready = 1;
        else ready = 0;

        if (state == dat_ready) count_rst = 1;
        else count_rst = 0;

        if (state == sample) enable = 1;
        else enable = 0;
    end

endmodule // parallel
