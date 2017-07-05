module up_counter(clk, en, rst, out);
    parameter WIDTH = 8, MAX = 255;

    input clk, en, rst;
    output reg [WIDTH-1:0] out;

    initial begin
        out = 0;
    end

    always @(posedge clk) begin
        if (rst) out <= 0;
        else begin
            if (en) begin
                if (out >= MAX) out <= 0;
                else out <= out + 1;
            end
            else out <= out;
        end
    end
endmodule
