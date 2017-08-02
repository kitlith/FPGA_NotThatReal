`include "up_counter.v"
`include "byte_shifter.v"
module ntr #(parameter CMD_CYCLES = 8) (
    input clk,
    input cs1,
    input [7:0] data,
    output reg [63:0] command,
    output reg ready,
    output [3:0] count
);

    // reg [3:0] count;
    wire cnt_en;
    assign cnt_en = ~cs1;
    up_counter #(.WIDTH(4), .MAX(CMD_CYCLES)) counter(clk, cnt_en, cs1, count);
    byte_shifter shift(clk, data, cnt_en, 1'b0, command);

    initial begin
        // command = 64'd0;
        ready = 0;
    end

    // always @(posedge clk) begin
    //     if (cs1 == 1'b0) begin
    //         command <= {data[7:0], command[63:8]};
    //     end
    // end

    always @* begin
        if (count == CMD_CYCLES) ready = 1;
        else ready = 0;
    end

endmodule
