// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 2. CALCULATOR TESTBENCH


`timescale 1ns/1ps

module calc_tb;
    reg clk, btnc, btnac, btnl, btnr, btnd;
    reg [15:0] sw;
    wire [15:0] led;

    calc dut (
        .clk(clk), .btnc(btnc), .btnac(btnac), 
        .btnl(btnl), .btnr(btnr), .btnd(btnd), 
        .sw(sw), .led(led)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("calc_simulation.vcd");
        $dumpvars(0, calc_tb);
        clk = 0; btnc = 0; btnac = 0; btnl = 0; btnr = 0; btnd = 0; sw = 0;

        // 1. Reset (btnac) 
        #10 btnac = 1; #10 btnac = 0; #10;
        $display("1. Reset: LED=%h (Expected: 0000)", led);

        // 2. ADD: Acc(0) + sw(285a) = 285a 
        #10 sw = 16'h285a; btnl = 0; btnr = 1; btnd = 0;
        #10 btnc = 1; #10 btnc = 0; #10;
        $display("2. ADD: LED=%h (Expected: 285a)", led);

        // 3. XOR: Acc(285a) XOR sw(04c8) = 2c92 
        #10 sw = 16'h04c8; btnl = 1; btnr = 1; btnd = 1;
        #10 btnc = 1; #10 btnc = 0; #10;
        $display("3. XOR: LED=%h (Expected: 2c92)", led);

        // 4. SRL: Acc(2c92) >> sw(0005) = 0164 
        #10 sw = 16'h0005; btnl = 0; btnr = 0; btnd = 0;
        #10 btnc = 1; #10 btnc = 0; #10;
        $display("4. SRL: LED=%h (Expected: 0164)", led);

        // 5. NOR: Acc(0164) NOR sw(a085) = 5e1a 
        #10 sw = 16'ha085; btnl = 1; btnr = 0; btnd = 1;
        #10 btnc = 1; #10 btnc = 0; #10;
        $display("5. NOR: LED=%h (Expected: 5e1a)", led);

        // 6. MULT: Acc(5e1a) * sw(07fe) = 13cc 
        #10 sw = 16'h07fe; btnl = 1; btnr = 0; btnd = 0;
        #10 btnc = 1; #10 btnc = 0; #10;
        $display("6. MUL: LED=%h (Expected: 13cc)", led);

        // 7. SLL: Acc(13cc) << sw(0004) = 3cc0 
        #10 sw = 16'h0004; btnl = 0; btnr = 0; btnd = 1;
        #10 btnc = 1; #10 btnc = 0; #10;
        $display("7. SLL: LED=%h (Expected: 3cc0)", led);

        // 8. NAND: Acc(3cc0) NAND sw(fa65) = c7bf 
        #10 sw = 16'hfa65; btnl = 1; btnr = 1; btnd = 0;
        #10 btnc = 1; #10 btnc = 0; #10;
        $display("8. NAND: LED=%h (Expected: c7bf)", led);

        // 9. SUB: Acc(c7bf) - sw(b2e4) = 14db 
        #10 sw = 16'hb2e4; btnl = 0; btnr = 1; btnd = 1;
        #10 btnc = 1; #10 btnc = 0; #10;
        $display("9. SUB: LED=%h (Expected: 14db)", led);

        #50 $finish;
    end
endmodule