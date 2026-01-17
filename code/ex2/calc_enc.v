// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 2. CALCULATOR_ENCODER (CALC_ENC) MODULE

module calc_enc (
    input btnl,
    input btnr,
    input btnd,
    output [3:0] alu_op
);
    // Ενδιάμεσα σήματα (wires) για τις συνδέσεις των πυλών
    wire not_btnl, not_btnr, not_btnd;
    wire and0_top, and0_mid, and0_bot;
    wire or1_mid;
    wire and2_top, xor2_mid, not_xor2, and2_bot;
    wire and3_top, and3_bot;

    // Πύλες NOT για την αντιστροφή των εισόδων 
    not (not_btnl, btnl);
    not (not_btnr, btnr);
    not (not_btnd, btnd);

    // --- alu_op[0] (Σχήμα 2) ---
    and (and0_top, not_btnl, btnd);
    and (and0_mid, btnl, btnr);     
    and (and0_bot, and0_mid, not_btnd);
    or  (alu_op[0], and0_top, and0_bot);

    // --- alu_op[1] (Σχήμα 3) ---
    or  (or1_mid, not_btnr, not_btnd);
    and (alu_op[1], btnl, or1_mid);

    // --- alu_op[2] (Σχήμα 4) ---
    and (and2_top, not_btnl, btnr);
    xor (xor2_mid, btnr, btnd);
    not (not_xor2, xor2_mid);
    and (and2_bot, btnl, not_xor2);
    or  (alu_op[2], and2_top, and2_bot);

    // --- alu_op[3] (Σχήμα 5) ---
    and (and3_top, btnl, btnr);
    and (and3_bot, btnl, btnd);
    or  (alu_op[3], and3_top, and3_bot);

endmodule