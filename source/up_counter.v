module up_counter(clk, en, rst, out);
    parameter WIDTH = 8, MAX = 255;

    input clk, en, rst;
    output reg [WIDTH-1:0] out;

    initial begin
        out = 0;
    end

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            out <= 0;
        end
        else if (en) begin
            if (out < MAX) out <= out + 1;
            else out <= out;
        end
        else out <= out;
    end
endmodule
