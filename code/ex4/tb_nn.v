// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 4. AI ACCELERATOR TESTBENCH

`timescale 1ns / 1ps

module tb_nn();
    reg [31:0] input_1, input_2;
    reg clk, resetn, enable;
    wire [31:0] final_output;
    wire total_ovf, total_zero;
    wire [2:0] ovf_fsm_stage, zero_fsm_stage;

    // Μεταβλητές για τον έλεγχο
    reg [31:0] expected_output;
    integer pass_count = 0;
    integer test_count = 0;
    integer i;

    // Ενσωμάτωση του nn_model.v
    `include "nn_model.v"

    // Instantiation του νευρωνικού 
    nn dut (
        .input_1(input_1), .input_2(input_2),
        .clk(clk), .resetn(resetn), .enable(enable),
        .final_output(final_output),
        .total_ovf(total_ovf), .total_zero(total_zero),
        .ovf_fsm_stage(ovf_fsm_stage), .zero_fsm_stage(zero_fsm_stage)
    );

    // Παραγωγή ρολογιού περιόδου 10ns (50% duty cycle) 
    always #5 clk = ~clk;

    initial begin
        // Αρχικοποίηση σημάτων
        clk = 0; resetn = 0; enable = 0;
        input_1 = 0; input_2 = 0;

        $dumpfile("nn_simulation.vcd");
        $dumpvars(0, tb_nn);

        // 1. Φάση Επαναφοράς (Reset) 
        #10 resetn = 0; 
        #20 resetn = 1; // Active-low reset απενεργοποιείται
        
        // 2. Ενεργοποίηση Loading 
        @(posedge clk);
        enable = 1;
        @(posedge clk);
        enable = 0;

        // Αναμονή για ολοκλήρωση του LOADING (χρειάζεται τουλάχιστον 5 κύκλους) 
        repeat (15) @(posedge clk);

        $display("--- Starting 100 Test Cases ---");

        for (i = 0; i < 100; i = i + 1) begin
            test_count = test_count + 1;

            // Παραγωγή τυχαίων εισόδων βάσει των απαιτήσεων 
            if (i < 40) begin
                input_1 = $urandom_range(4095, -4096); // Εύρος [-4096, 4095] 
                input_2 = $urandom_range(4095, -4096);
            end 
            else if (i < 70) begin
                input_1 = $urandom_range(32'h7FFFFFFF, 32'h3FFFFFFF); // Θετική υπερχείλιση 
                input_2 = $urandom_range(32'h7FFFFFFF, 32'h3FFFFFFF);
            end 
            else begin
                input_1 = $urandom_range(32'hC0000000, 32'h80000000); // Αρνητική υπερχείλιση 
                input_2 = $urandom_range(32'hC0000000, 32'h80000000);
            end

            // Έναρξη κύκλου υπολογισμού 
            @(posedge clk);
            enable = 1;
            @(posedge clk);
            enable = 0;

            // Αναμονή για την ολοκλήρωση της FSM (7 στάδια + 1 idle) 
            repeat (10) @(posedge clk);

            // Υπολογισμός αναμενόμενου αποτελέσματος 
            expected_output = nn_model(input_1, input_2);

            // Έλεγχος αποτελέσματος
            if (final_output === expected_output) begin
                pass_count = pass_count + 1;
            end 
            else begin
                $display("ERROR at %0t ns: In1=%d, In2=%d | Got=%h, Expected=%h", 
                         $time, $signed(input_1), $signed(input_2), final_output, expected_output);
            end
        end

        // Τελική αναφορά 
        $display("---------------------------------------");
        $display("Final Score: %d / %d PASS", pass_count, test_count);
        $display("---------------------------------------");

        $finish;
    end
endmodule