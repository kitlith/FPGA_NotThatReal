// `include "up_counter.v"
module ntr_respond(
    input clk,
    input en,
    input [31:0] data,
    output reg [7:0] out,
    output reg request);

    wire [4:0] count; // Max greater than (2^WIDTH)-1 should overflow.
    up_counter #(.WIDTH(2), .MAX(4)) data_pos(clk, en, 1'b0, count[4:3]);

    assign count[2:0] = 0;

    always @(negedge clk) begin
        $display("count: %d", count);
        if (en) begin
            out <= (data >> (24 - count)) & 8'hFF;
        end
    end

    always @* begin
        if (count == 3) request = 1;
        else request = 0;
    end

endmodule
