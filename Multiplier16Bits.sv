module multiplier16bits(
    input [15:0] a,
    input [15:0] b,
    output[31:0] y
);

assign y = a * b;

endmodule

class transaction;
    randc bit [15:0] a;
    randc bit [15:0] b;
    bit [31:0] y;
endclass //transaction


class generator;
    transaction t;
    event done;
    integer i;
    mailbox mbx;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction //new()

    task  run();
        t = new();
        for (i = o; i < 50; i++) begin
            t.randomize();
            mbx.put(t);
            $display(" [ GEN ] - Generator send data.");
            #10;
            @(done);
        end
    endtask //
endclass //generator

interface multiplier16bits_intf();
    logic [15:0] a;
    logic [15:0] b;
    logic [31:0] y;    
endinterface //multiplier16bits_intf()

