`include "parallel.v"

module top(clk, ntr_data, ntr_clk, leds);

    parameter init = 0, wait_ready = 1, set_led = 2, wait_next = 3;

    input clk, ntr_clk;
    input [7:0] ntr_data;
    output [3:0] leds;

    reg led;

    wire [63:0] command;

    reg [2:0] state;
    wire ready;

    parallel ntr_bus(clk, ntr_data, ntr_clk, command, ready);

    initial begin
        state = init;
        //led = 0;
    end

    always @(posedge clk) begin
        case (state)
            init: state <= wait_ready;
            wait_ready: begin
                if (ready) state <= set_led;
                else state <= state;
            end
            set_led: state <= wait_next;
            wait_next: begin
                if (ready) state <= state;
                else state <= wait_ready;
            end
        endcase
    end

    always @* begin
        if (state == init) led = 1;
        if (state == set_led) begin
            if (command[7:0] == 8'h00) led = 0;
        end
    end

    assign leds = {led, led, led, led};

endmodule
