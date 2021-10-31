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
            $display(" [ GEN ] - Random data OK.");
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

class driver;
    transaction t;
    mailbox mbx;
    virtual multiplier16bits_intf vif;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction //new()

    task  run();
        t = new();
        forever begin
            mbx.get(t);
            vif.a = t.a;
            vif.b = t.b;
            $display(" [ DRV ] - Driver send the data to interface.");
            #10;
            ->done;
        end
    endtask //
endclass //driver

class monitor;
    transaction t;
    mailbox mbx;
    virtual multiplier16bits_intf vif;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction //new()

    task  run();
        t = new();
        forever begin
            t.a = vif.a;
            t.b = vif.b;
            t.y = vif.y;
            mbx.put(t);
            $display(" [ MON ] - Monitor receive the data from interface and send to scoreboard.");
            #10; 
        end
    endtask //
endclass //monitor

class scoreboard;
    transaction t;
    mailbox mbx;
    virtual multiplier16bits_intf vif;
    bit [31:0] temp;

    function new(mailbox mbx);
        this.mbx = mbx;
    endfunction //new()

    task  run();
        t = new();
        forever begin
            mbx.get(t);
            temp = t.a * t.b;
            if (temp == t.y) begin
                $display(" [ SCO ] - TEST PASSED!");
            end
            else begin
                display(" [ SCO ] - TEST FAIL!");
            end
        end
    endtask //
endclass //scoreboard

class environment;

    generator gen;
    driver drv;
    monitor mon;
    scoreboard sco;
    mailbox gdmbx, msmbx;
    virtual multiplier16bits_intf vif;
    event ggdone;

    function new(mailbox gdmbx, mailbox msmbx);
        this.gdmbx = gdmbx;
        this.msmbx = msmbx;

        gen = new(gdmbx);
        drv = new(gdmbx);

        mon = new(msmbx);
        sco = new(msmbx);
    endfunction //new()

    task  run();
        mon.vif = vif;
        dri.vif = vif;

        gen.done = ggdone;
        drv.done = ggdone;   

        fork
            gen.run();
            drv.run();
            mon.run();
            sco.run();
        join_any   
    endtask //
endclass //environment

mudole tb();
    environment env;
    mailbox gdmbx, msmbx;
    multiplier16bits_intf vif();

    multiplier16bits dut (vif.a, vif.b, vif.y);

    initial begin
        gdmbx = new();
        msmbx = new();
        env = new(gdmbx, msmbx)
        env.vif = vif;
        env.run();
        #10;
    end
endmodule