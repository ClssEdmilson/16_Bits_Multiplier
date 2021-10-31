module multiplier16bits(
    input [15:0] a,
    input [15:0] b,
    output[31:0] y;
);

assign y = a * b;

endmodule

class transaction;
    randc bit [15:0] a,
    randc bit [15:0] b,
    bit [31:0] y;
endclass //transaction
