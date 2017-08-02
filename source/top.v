// `include "parallel.v"
`include "ntr.v"
`include "debouncer.v"
`include "ppio.v"

module top(
    input clk,
    inout [7:0] ntr_data,
    input ntr_clk,
    input ntr_cs1,
    output [3:0] leds);

    parameter init = 0, wait_ready = 1, set_led = 2, wait_next = 3;

    wire [7:0] ntr_data_in;
    reg [7:0] ntr_data_out;
    reg ntr_dir;

    reg led;

    wire [63:0] command;

    reg [2:0] state;

    wire ready, enable;
    wire [3:0] count;
    wire [2:0] debug;
    wire debounced_ntr_clk, debounced_ntr_cs1;

    // assign enable = ~ntr_cs1; // CS1 is active low.
    assign ntr_dir = 1'b0;

    debouncer #(0,2) debounce_clk(clk, ntr_clk, debounced_ntr_clk);
    debouncer #(0,2) debounce_cs1(clk, ntr_cs1, debounced_ntr_cs1);
    ppio #(8) ntr_bus(ntr_dir, ntr_data, ntr_data_in, ntr_data_out);
    // parallel ntr_decode(clk, debounced_ntr_clk, debounced_ntr_cs1, ntr_data_in, command, ready, count);
    ntr ntr_decode(debounced_ntr_clk, debounced_ntr_cs1, ntr_data_in, command, ready, count);

    initial begin
        state = init;
        $monitor("command: %x, cs1: %b, ready: %b, led: %b, count: %d", command, ntr_cs1, ready, led, count);
        //led = 0;
    end

    always @(posedge clk) begin
        case (state)
            init: state <= wait_ready;
            wait_ready: begin
                if (ready == 1'b1) state <= set_led;
                else state <= wait_ready;
            end
            set_led: state <= wait_next;
            wait_next: begin
                if (ready == 1'b0) state <= wait_ready;
                else state <= wait_next;
            end
        endcase
    end

    always @* begin
        if (state == init) led = 0;
        else if (state == set_led) begin
            if (command[15:8] == 8'hff) led = command[56];
            else led = led;
        end else led = led;
    end

    assign leds = {led, count[3:1]};

endmodule
