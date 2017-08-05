`include "up_counter.v"
`include "byte_shifter.v"
module parallel #(parameter CMD_CYCLES = 9) (
    input clk,
    input ntr_clk,
    input ntr_cs1,
    input [7:0] ntr_data,
    output wire [63:0] command,
    output reg ready);

    parameter init = 0, wait_high = 2, sample = 1, wait_low = 4,
              cmd_ready = 3;

    reg [2:0] state;

    wire [3:0] count;
    reg enable, count_rst;
    byte_shifter shift(clk, ntr_data, enable, 1'b0, command);
    up_counter #(4, CMD_CYCLES - 1) counter(clk, enable, count_rst, count);

    initial begin
        state <= init;
        // $monitor("state: %d, ntr_clk: %b, cs1: %b, data: %x, ready: %b, count: %d",
        //         state, ntr_clk, ntr_cs1, ntr_data, ready, count);
    end

    always @(posedge clk) begin
        if (ntr_cs1) state <= init;
        else begin
            case (state)
                init: begin
                    if (ntr_cs1 == 0) state <= wait_low;
                    else state <= init;
                end
                wait_high: begin
                    if (ntr_clk == 1) state <= sample;
                    else state <= state;
                end
                sample: begin
                    if (count == CMD_CYCLES - 1) state <= cmd_ready;
                    else state <= wait_low;
                end
                wait_low: begin
                    if (ntr_clk == 0) state <= wait_high;
                    else state <= wait_low;
                end
                cmd_ready: begin
                    state <= cmd_ready; // rely on cs1 going high
                end
            endcase
        end
    end

    always @* begin
        if (state == cmd_ready) ready = 1;
        else ready = 0;

        if (state == init) count_rst = 1;
        else count_rst = 0;

        if (state == sample) enable = 1;
        else enable = 0;
    end

endmodule // parallel
