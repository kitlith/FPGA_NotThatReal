`include "up_counter.v"
module ntr(
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
    up_counter #(.WIDTH(4), .MAX(9)) counter(clk, cnt_en, cs1, count);

    initial begin
        command = 64'd0;
        ready = 0;
    end

    always @(posedge clk) begin
        if (cs1 == 1'b0) begin
            command <= {data[7:0], command[63:8]};
            // count <= count + 1;
        end
    end

    always @* begin
        if (count == 9) ready = 1;
        else ready = 0;

        // if (overflow) cnt_rst = 1;
        // else cnt_rst = 0;
    end

endmodule
