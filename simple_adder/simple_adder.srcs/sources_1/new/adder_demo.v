module adder_demo(a,b,out);
input [31:0] a,b;
output reg [31:0] out;

always@(a,b) begin
    out = a + b;
end
endmodule
