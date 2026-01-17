// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 1. ALU TESTBENCH


`timescale 1ns / 1ps

module alu_tb();
    reg [31:0] op1, op2;
    reg [3:0] alu_op;
    wire [31:0] result;
    wire zero, ovf;

    // Δημιουργία στιγμιότυπου (Instance) της ALU
    alu dut (
        .op1(op1), .op2(op2), .alu_op(alu_op),
        .zero(zero), .result(result), .ovf(ovf)
    );

    initial begin
        $dumpfile("alu_simulation.vcd");
        $dumpvars(0, alu_tb);

        // 1. Πρόσθεση
        op1 = 32'd5; op2 = 32'd10; alu_op = 4'b0100; #10;
        $display("ADD: %d + %d = %d (ovf: %b)", $signed(op1), $signed(op2), $signed(result), ovf);

        // 2. Υπερχείλιση (Max Positive + 1)
        op1 = 32'h7FFFFFFF; op2 = 32'd1; alu_op = 4'b0100; #10;
        $display("OVF: %d + %d = %d (ovf: %b)", $signed(op1), $signed(op2), $signed(result), ovf);

        // 3. Αφαίρεση (SUB)
        op1 = 32'd20; op2 = 32'd30; alu_op = 4'b0101; #10;
        $display("SUB: %d - %d = %d (ovf: %b)", $signed(op1), $signed(op2), $signed(result), ovf);

        // 4. Πολλαπλασιασμός (MUL)
        op1 = 32'd3; op2 = 32'd4; alu_op = 4'b0110; #10;
        $display("MUL: %d * %d = %d (ovf: %b)", $signed(op1), $signed(op2), $signed(result), ovf);
        
        // 5. Αριθμητική Ολίσθηση Δεξιά (SRA) - Εκτύπωση σε Hex και Dec
        op1 = -32'd16; op2 = 32'd2; alu_op = 4'b0010; #10;
        $display("SRA: %h >>> %d = %h (Decimal: %d)", op1, op2, result, $signed(result));

        // 6. Λογική NAND
        op1 = 32'hF0F0F0F0; op2 = 32'h0F0F0F0F; alu_op = 4'b1011; #10;
        $display("NAND: %h NAND %h = %h", op1, op2, result);

        $finish;
    end
endmodule