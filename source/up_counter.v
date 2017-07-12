module up_counter(clk, en, rst, out, overflow);
    parameter WIDTH = 8, MAX = 255;

    input clk, en, rst;
    output reg [WIDTH-1:0] out;
    output reg overflow;

    initial begin
        out = 0;
    end

    always @(posedge clk) begin
        if (rst) begin
            overflow <= 0;
        end
        if (en) begin
            if (out >= MAX) begin
                overflow <= 1;
                out <= 0;
            end
            else out <= out + 1;
        end
        else out <= out;
    end
endmodule
