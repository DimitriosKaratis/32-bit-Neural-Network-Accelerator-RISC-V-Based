// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 4. MAC (Multiply and Accumulate) UNIT TESTBENCH


`timescale 1ns/1ps

module mac_unit_tb;
    reg [31:0] op1, op2, op3;
    wire [31:0] total_result;
    wire zero_mul, zero_add, ovf_mul, ovf_add;

    // Instantiation της μονάδας MAC
    mac_unit dut (
        .op1(op1),
        .op2(op2),
        .op3(op3),
        .total_result(total_result),
        .zero_mul(zero_mul),
        .zero_add(zero_add),
        .ovf_mul(ovf_mul),
        .ovf_add(ovf_add)
    );

    initial begin
        $dumpfile("mac_unit_simulation.vcd");
        $dumpvars(0, mac_unit_tb);

        $display("--- Starting MAC Unit Test ---");

        // Τέστ 1: Απλή πράξη
        op1 = 32'd2; op2 = 32'd3; op3 = 32'd4;
        #10;
        $display("Test 1: (%d * %d) + %d = %d | Zero_mul: %b", 
                 $signed(op1), $signed(op2), $signed(op3), $signed(total_result), zero_mul);

        // Τέστ 2: Αρνητικοί αριθμοί
        op1 = -32'd5; op2 = 32'd4; op3 = 32'd10;
        #10;
        $display("Test 2: (%d * %d) + %d = %d | Zero_mul: %b", 
                 $signed(op1), $signed(op2), $signed(op3), $signed(total_result), zero_mul);

        // Τέστ 3: Έλεγχος Υπερχείλισης
        op1 = 32'h40000000; op2 = 32'd4; op3 = 32'd1;
        #10;
        $display("Test 3: (%d * %d) + %d = %d | Ovf_mul: %b", 
                 $signed(op1), $signed(op2), $signed(op3), $signed(total_result), ovf_mul);

        // Τέστ 4: Μηδενικό αποτέλεσμα στον πολλαπλασιασμό
        op1 = 32'd0; op2 = 32'd100; op3 = 32'd50;
        #10;
        $display("Test 4: (%d * %d) + %d = %d | Zero_mul: %b", 
                 $signed(op1), $signed(op2), $signed(op3), $signed(total_result), zero_mul);

        #10;
        $display("--- MAC Unit Test Completed ---");
        $finish;
    end

endmodule