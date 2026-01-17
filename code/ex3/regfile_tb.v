// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 3. REGISTER FILE TESTBENCH


`timescale 1ns/1ps

module regfile_tb;
    parameter DATAWIDTH = 32;

    // Σήματα εισόδου
    reg clk;
    reg resetn;
    reg [3:0] readReg1, readReg2, readReg3, readReg4;
    reg [3:0] writeReg1, writeReg2;
    reg [DATAWIDTH-1:0] writeData1, writeData2;
    reg write;

    // Σήματα εξόδου
    wire [DATAWIDTH-1:0] readData1, readData2, readData3, readData4;

    // Instantiation του Module
    regfile #(DATAWIDTH) dut (
        .clk(clk), .resetn(resetn),
        .readReg1(readReg1), .readReg2(readReg2), .readReg3(readReg3), .readReg4(readReg4),
        .writeReg1(writeReg1), .writeReg2(writeReg2),
        .writeData1(writeData1), .writeData2(writeData2),
        .write(write),
        .readData1(readData1), .readData2(readData2), .readData3(readData3), .readData4(readData4)
    );

    // Παραγωγή ρολογιού (Περίοδος 10ns)
    always #5 clk = ~clk;

    initial begin
        // Αρχικοποίηση σημάτων
        clk = 0; resetn = 1; write = 0;
        readReg1 = 0; readReg2 = 1; readReg3 = 2; readReg4 = 3;
        writeReg1 = 0; writeReg2 = 0; writeData1 = 0; writeData2 = 0;

        $dumpfile("regfile_simulation.vcd");
        $dumpvars(0, regfile_tb);

        // 1. Έλεγχος Ασύγχρονου Reset
        #5 resetn = 0; // Ενεργοποίηση reset
        #5 resetn = 1; // Απενεργοποίηση reset
        #2;
        if (readData1 == 0 && readData2 == 0)
            $display("1. Reset Test: PASSED");
        else
            $display("1. Reset Test: FAILED");

        // 2. Έλεγχος Σύγχρονης Εγγραφής
        // Γράφουμε στον Reg 5 την τιμή 0xAAAA και στον Reg 6 την τιμή 0xBBBB
        @(posedge clk);
        write = 1;
        writeReg1 = 4'd5; writeData1 = 32'hAAAA_AAAA;
        writeReg2 = 4'd6; writeData2 = 32'hBBBB_BBBB;
        #10; // Αναμονή για την ακμή του ρολογιού
        write = 0;

        // Ανάγνωση των τιμών
        readReg1 = 4'd5; readReg2 = 4'd6;
        #2; // Ασύγχρονη ανάγνωση 
        if (readData1 == 32'hAAAA_AAAA && readData2 == 32'hBBBB_BBBB)
            $display("2. Write Test: PASSED");
        else
            $display("2. Write Test: FAILED (Data: %h, %h)", readData1, readData2);

        // 3. Έλεγχος Προτεραιότητας Εγγραφής (Internal Forwarding)
        // Θέλουμε να διαβάσουμε τον Reg 10 την ίδια στιγμή που του γράφουμε νέα τιμή
        @(posedge clk);
        readReg3 = 4'd10; // Ζητάμε τον Reg 10
        write = 1;
        writeReg1 = 4'd10; writeData1 = 32'h1234_5678; // Του γράφουμε ταυτόχρονα
        
        #2; // Εδώ ελέγχουμε την ΑΣΥΓΧΡΟΝΗ απόκριση πριν το επόμενο ρολόι
        if (readData3 == 32'h1234_5678)
            $display("3. Internal Forwarding Test: PASSED (Data available before clk)");
        else
            $display("3. Internal Forwarding Test: FAILED");

        #20;
        $finish;
    end
endmodule