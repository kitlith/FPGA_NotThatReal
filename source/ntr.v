`include "up_counter.v"
module ntr(
    input clk,
    input cs1,
    input [7:0] data,
    output reg [63:0] command,
    output reg ready,
    output reg [2:0] count
);

    // reg [3:0] count;
    wire overflow;
    reg cnt_rst;
    wire cnt_en;
    assign cnt_en = ~cs1;
    up_counter #(.WIDTH(3), .MAX(7)) counter(clk, cnt_en, cnt_rst, count, overflow);

    initial begin
        command = 0;
        // count = 0;
        ready = 0;
    end

    always @(posedge clk) begin
        if (cs1) command <= command;
        else begin
            command <= {data[7:0], command[63:8]};
            // count <= count + 1;
        end
    end

    always @* begin
        if (overflow) ready = 1;
        else if (count == 1) ready = 0;

        if (overflow) cnt_rst = 1;
        else cnt_rst = 0;
    end

endmodule
