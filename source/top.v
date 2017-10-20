`include "parallel.v"
// `include "ntr.v"
`include "ntr_respond.v"
`include "debouncer.v"
`include "ppio.v"
`include "fifo.v"

`include "uart_rx.v"
`include "uart_tx.v"

module top(
    input clk,
    inout [7:0] ntr_data,
    input ntr_clk,
    input ntr_cs1,
    input rx,
    output tx,
    output [3:0] leds);

    parameter init = 0, wait_ready = 1, do_command = 2, wait_next = 3;

    wire debounced_ntr_clk, debounced_ntr_cs1;
    debouncer #(0,2) debounce_clk(clk, ntr_clk, debounced_ntr_clk);
    debouncer #(0,2) debounce_cs1(clk, ntr_cs1, debounced_ntr_cs1);

    wire [7:0] ntr_data_in;
    wire [7:0] ntr_data_out;
    reg in_en;
    ppio #(8) ntr_bus(in_en, ntr_data, ntr_data_out, ntr_data_in);

    wire [63:0] command;
    wire ready;
    parallel #(8) ntr_decode(clk, debounced_ntr_clk, debounced_ntr_cs1, ntr_data_in, command, ready);
    // ntr #(9) ntr_decode(debounced_ntr_clk, debounced_ntr_cs1, ntr_data_in, command, ready, count);

    reg [31:0] data_word;
    wire request_word;
    ntr_respond respond(debounced_ntr_clk, ready, data_word, ntr_data_out, request_word);

    wire [7:0] serial_data;
    wire serial_ready, serial_done;
    uart_in serial_rx(rx, serial_data, clk, 1'b0, serial_ready);
    // uart_out serial_tx(serial_data, serial_ready, 1'b0, tx, serial_done, clk);

    wire fifo_empty, fifo_full;
    wire [7:0] fifo_data;
    reg fifo_rd_en, fifo_reset;
    aFifo #(.DATA_WIDTH(8), .ADDRESS_WIDTH(9)) serial_buffer(fifo_data, fifo_empty, fifo_rd_en, clk,
                                                             serial_data, fifo_full, serial_ready, clk, fifo_reset);

    reg [2:0] state;
    reg led;

    // assign in_en = 1'b1;
    // assign ntr_data_in = ntr_data;

    initial begin
        state = init;
        // ntr_data_out = 8'h34;
        // $monitor("command: %x, cs1: %b, ready: %b, led: %b, count: %d", command, ntr_cs1, ready, led, count);
        //led = 0;
    end

    always @(posedge clk) begin
        case (state)
            init: state <= wait_ready;
            wait_ready: begin
                if (ready == 1'b1) state <= do_command;
                else state <= wait_ready;
            end
            do_command: state <= wait_next;
            wait_next: begin
                if (ready == 1'b0) state <= wait_ready;
                else state <= wait_next;
            end
        endcase
    end

    always @* begin
        if (state == init) led = 0;
        else if (state == do_command) begin
            case (command[7:0])
                8'hFF: begin
                    led = command[56];
                    data_word = 32'd1;
                end
                8'h22: begin
                    data_word = {7'b0, fifo_empty, 16'b0, fifo_data};
                end
                8'h90: data_word = 32'h807F01E0; // chipid
                8'h9F: data_word = 32'hFFFFFFFF;
                default: data_word = 32'd0;
            endcase
        end

        // Ew, but...
        if ((state == do_command) && (command[7:0] == 8'h22)) fifo_rd_en = 1;
        else fifo_rd_en = 0;

        if (state == init) fifo_reset = 1;
        else fifo_reset = 0;

        if (ready) in_en = 0;
        else in_en = 1;
    end

    assign leds = {led, fifo_empty, fifo_full, 1'b0};

endmodule
