`include "ntr.v"
`include "debouncer.v"

module top(clk, ntr_data, ntr_clk, ntr_cs1, leds);

    parameter init = 0, wait_ready = 1, set_led = 2, wait_next = 3;

    input clk, ntr_clk, ntr_cs1;
    input [7:0] ntr_data;
    output [3:0] leds;

    reg led;

    wire [63:0] command;

    reg [2:0] state;
    wire ready, enable;
    wire [2:0] count;
    wire [2:0] debug;
    wire debounced_ntr_clk;

    // assign enable = ~ntr_cs1; // CS1 is active low.

    // parallel ntr_bus(clk, ntr_data, ntr_clk, command, ready, ntr_cs1, debug);
    debouncer #(0,2) debonce(clk, ntr_clk, debounced_ntr_clk);
    ntr ntr_bus(debounced_ntr_clk, ntr_cs1, ntr_data, command, ready, count);

    initial begin
        state = init;
        // $monitor("command: %x, ready: %b, led: %b, count: %d", command, ready, command[56], count);
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
        if (state == init) led = 0;
        if (state == set_led) begin
            if (command[7:0] == 8'hff) led = command[56];
        end
    end

    assign leds = {led, count};

endmodule
