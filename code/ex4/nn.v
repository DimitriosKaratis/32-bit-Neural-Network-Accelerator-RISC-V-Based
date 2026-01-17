// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 4. AI ACCELERATOR MODULE

`include "../ex3/regfile.v"
`include "mac_unit.v" 
`include "rom.v"

module nn (
    input [31:0] input_1,
    input [31:0] input_2,
    input clk,
    input resetn,
    input enable,
    output reg [31:0] final_output,
    output reg total_ovf,
    output reg total_zero,
    output reg [2:0] ovf_fsm_stage,
    output reg [2:0] zero_fsm_stage
);

    // Ορισμός Καταστάσεων FSM (3-bit)
    localparam DEACTIVATED = 3'b000;
    localparam LOADING     = 3'b001;
    localparam PRE_PROC    = 3'b010;
    localparam INPUT_LAYER = 3'b011;
    localparam OUT_LAYER   = 3'b100;
    localparam POST_PROC   = 3'b101;
    localparam IDLE        = 3'b110;

    reg [2:0] current_state, next_state;
    reg [7:0] rom_addr1, rom_addr2;
    wire [31:0] rom_dout1, rom_dout2;
    
    // Σήματα Register File 
    reg [3:0] readReg1, readReg2, readReg3, readReg4;
    reg [3:0] writeReg1, writeReg2;
    reg [31:0] writeData1, writeData2;
    reg rf_write;
    wire [31:0] rf_rd1, rf_rd2, rf_rd3, rf_rd4;

    // Σήματα MAC και ALU 
    reg [31:0] mac1_op1, mac1_op2, mac1_op3;
    reg [31:0] mac2_op1, mac2_op2, mac2_op3;
    wire [31:0] mac1_res, mac2_res;
    wire m1_z_mul, m1_z_add, m1_o_mul, m1_o_add;
    wire m2_z_mul, m2_z_add, m2_o_mul, m2_o_add;

    reg [31:0] alu1_op1, alu1_op2, alu2_op1, alu2_op2;
    reg [3:0] alu1_op, alu2_op;
    wire [31:0] alu1_res, alu2_res;
    wire alu1_z, alu1_o, alu2_z, alu2_o;

    // Ενδιάμεσοι καταχωρητές 
    reg [31:0] inter_1, inter_2, inter_3, inter_4, inter_5;
    reg [7:0] load_counter;

    // --- INSTANTIATIONS ---
    WEIGHT_BIAS_MEMORY rom_inst (
        .clk(clk), .addr1(rom_addr1), .addr2(rom_addr2),
        .dout1(rom_dout1), .dout2(rom_dout2)
    );

    regfile rf_inst (
        .clk(clk), .resetn(resetn),
        .readReg1(readReg1), .readReg2(readReg2), .readReg3(readReg3), .readReg4(readReg4),
        .writeReg1(writeReg1), .writeReg2(writeReg2),
        .writeData1(writeData1), .writeData2(writeData2),
        .write(rf_write),
        .readData1(rf_rd1), .readData2(rf_rd2), .readData3(rf_rd3), .readData4(rf_rd4)
    );

    mac_unit mac1 (.op1(mac1_op1), .op2(mac1_op2), .op3(mac1_op3), .total_result(mac1_res), 
                   .zero_mul(m1_z_mul), .zero_add(m1_z_add), .ovf_mul(m1_o_mul), .ovf_add(m1_o_add));
    
    mac_unit mac2 (.op1(mac2_op1), .op2(mac2_op2), .op3(mac2_op3), .total_result(mac2_res), 
                   .zero_mul(m2_z_mul), .zero_add(m2_z_add), .ovf_mul(m2_o_mul), .ovf_add(m2_o_add));

    alu alu1 (.op1(alu1_op1), .op2(alu1_op2), .alu_op(alu1_op), .zero(alu1_z), .result(alu1_res), .ovf(alu1_o));
    alu alu2 (.op1(alu2_op1), .op2(alu2_op2), .alu_op(alu2_op), .zero(alu2_z), .result(alu2_res), .ovf(alu2_o));

    // --- ΣΥΓΧΡΟΝΗ ΛΟΓΙΚΗ ---
    always @(posedge clk or negedge resetn) begin
        if (!resetn) begin
            current_state <= DEACTIVATED;
            load_counter <= 8'd0;
            inter_1 <= 0; inter_2 <= 0; inter_3 <= 0; inter_4 <= 0; inter_5 <= 0;
            total_ovf <= 0; total_zero <= 0;
            final_output <= 0;
            ovf_fsm_stage <= 3'b111; zero_fsm_stage <= 3'b111;
        end else begin
            current_state <= next_state;
            
            case (current_state)
                LOADING: load_counter <= load_counter + 1;
                PRE_PROC: begin
                    inter_1 <= alu1_res;
                    inter_2 <= alu2_res;
                end
                INPUT_LAYER: begin
                    inter_3 <= mac1_res;
                    inter_4 <= mac2_res;
                end
                OUT_LAYER: begin
                    inter_5 <= mac1_res + mac2_res;
                end
                POST_PROC: final_output <= alu1_res;
                IDLE: begin
                    load_counter <= 0;
                    if (total_ovf) final_output <= 32'hFFFFFFFF; // Overflow: -1
                    if (enable) begin
                        total_ovf <= 0; total_zero <= 0;
                        ovf_fsm_stage <= 3'b111; zero_fsm_stage <= 3'b111;
                    end
                end
            endcase

            // Καταγραφή Flags
            if (alu1_o || alu2_o || m1_o_mul || m1_o_add || m2_o_mul || m2_o_add) begin
                if (!total_ovf) begin
                    total_ovf <= 1'b1;
                    ovf_fsm_stage <= current_state;
                end
            end
            if (alu1_z || alu2_z || m1_z_mul || m1_z_add || m2_z_mul || m2_z_add) begin
                if (!total_zero) begin
                    total_zero <= 1'b1;
                    zero_fsm_stage <= current_state;
                end
            end
        end
    end

    // --- ΣΥΝΔΥΑΣΤΙΚΗ ΛΟΓΙΚΗ ---
    always @(*) begin
        next_state = current_state;
        rf_write = 0; writeReg1 = 0; writeReg2 = 0; writeData1 = 0; writeData2 = 0;
        rom_addr1 = 0; rom_addr2 = 0;
        readReg1 = 0; readReg2 = 0; readReg3 = 0; readReg4 = 0;
        alu1_op1 = 0; alu1_op2 = 0; alu1_op = 0;
        alu2_op1 = 0; alu2_op2 = 0; alu2_op = 0;
        mac1_op1 = 0; mac1_op2 = 0; mac1_op3 = 0;
        mac2_op1 = 0; mac2_op2 = 0; mac2_op3 = 0;

        case (current_state)
            DEACTIVATED: if (enable) next_state = LOADING;
            
            LOADING: begin
                // Διευθύνσεις ROM βάσει byte-addressing
                rom_addr1 = 8 + (load_counter * 8); 
                rom_addr2 = 12 + (load_counter * 8);
                
                // Εγγραφή στο RegFile ΜΕΤΑ τον πρώτο κύκλο για να προλάβουν τα δεδομένα της ROM
                if (load_counter > 0) begin
                    rf_write = 1;
                    writeReg1 = ((load_counter-1) * 2) + 2; 
                    writeReg2 = ((load_counter-1) * 2) + 3;
                    writeData1 = rom_dout1;
                    writeData2 = rom_dout2;
                end
                
                if (load_counter == 6) next_state = PRE_PROC; 
            end

            PRE_PROC: begin
                readReg1 = 4'd2; readReg2 = 4'd3; // shift_bias_1, 2 
                alu1_op1 = input_1; alu1_op2 = rf_rd1; alu1_op = 4'b0010; 
                alu2_op1 = input_2; alu2_op2 = rf_rd2; alu2_op = 4'b0010;
                next_state = INPUT_LAYER;
            end

            INPUT_LAYER: begin
                readReg1 = 4'd4; readReg2 = 4'd5; // w1, b1
                readReg3 = 4'd6; readReg4 = 4'd7; // w2, b2 
                mac1_op1 = inter_1; mac1_op2 = rf_rd1; mac1_op3 = rf_rd2; 
                mac2_op1 = inter_2; mac2_op2 = rf_rd3; mac2_op3 = rf_rd4; 
                next_state = OUT_LAYER;
            end

            OUT_LAYER: begin
                readReg1 = 4'd8; readReg2 = 4'd9; readReg3 = 4'd10; // w3, w4, b3 
                mac1_op1 = inter_3; mac1_op2 = rf_rd1; mac1_op3 = 32'd0;
                mac2_op1 = inter_4; mac2_op2 = rf_rd2; mac2_op3 = rf_rd3;
                next_state = POST_PROC;
            end

            POST_PROC: begin
                readReg1 = 4'd11; // shift_bias_3 
                alu1_op1 = inter_5; alu1_op2 = rf_rd1; alu1_op = 4'b0011; 
                next_state = IDLE;
            end

            IDLE: if (enable) next_state = PRE_PROC;
        endcase

        if (total_ovf && current_state != IDLE) next_state = IDLE; 
    end
endmodule