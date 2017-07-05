module byte_shifter(clk, in, en, rst, out);
    parameter WIDTH = 8;
    parameter SIZE = 8;

    input clk, en, rst;
    input [WIDTH-1:0] in;
    output reg [WIDTH*SIZE-1:0] out;

    initial begin
        out <= 0;
    end

    always @(posedge clk) begin
        if (rst) out <= 0;
        else begin
            if (en) begin
                out[63:0] <= {in, out[63:8]};
            end
            else out <= out;
        end
    end


endmodule
