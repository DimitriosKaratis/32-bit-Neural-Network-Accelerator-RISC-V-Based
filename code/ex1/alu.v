// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 1. ALU MODULE

module alu
    #(parameter op_width = 32,
      parameter alu_op_width = 4)
    (
        input [op_width-1:0] op1, 
        input [op_width-1:0] op2,
        input [alu_op_width-1:0] alu_op,
        output zero,
        output reg [op_width-1:0] result,
        output reg ovf
    );

    // Ορισμός παραμέτρων βάσει του πίνακα alu_op 
    parameter [3:0] ALUOP_AND  = 4'b1000;
    parameter [3:0] ALUOP_OR   = 4'b1001;
    parameter [3:0] ALUOP_NOR  = 4'b1010;
    parameter [3:0] ALUOP_NAND = 4'b1011;
    parameter [3:0] ALUOP_XOR  = 4'b1100;
    parameter [3:0] ALUOP_ADD  = 4'b0100;
    parameter [3:0] ALUOP_SUB  = 4'b0101;
    parameter [3:0] ALUOP_MUL  = 4'b0110;
    parameter [3:0] ALUOP_SRL  = 4'b0000;
    parameter [3:0] ALUOP_SLL  = 4'b0001;
    parameter [3:0] ALUOP_SRA  = 4'b0010;
    parameter [3:0] ALUOP_SLA  = 4'b0011;

    always @(*) begin
        // Αρχικοποίηση εξόδων
        result = {op_width{1'b0}};
        ovf = 1'b0;

        case (alu_op)
            // Λογικές πύλες bit-προς-bit
            ALUOP_AND:  result = op1 & op2;
            ALUOP_OR:   result = op1 | op2;
            ALUOP_NOR:  result = ~(op1 | op2);
            ALUOP_NAND: result = ~(op1 & op2);
            ALUOP_XOR:  result = op1 ^ op2;

            // Πρόσθεση με έλεγχο υπερχείλισης προσήμου
            ALUOP_ADD: begin
                result = $signed(op1) + $signed(op2);
                ovf = (op1[31] == op2[31]) && (result[31] != op1[31]);
            end
            
            // Αφαίρεση με έλεγχο υπερχείλισης προσήμου
            ALUOP_SUB: begin
                result = $signed(op1) - $signed(op2);
                ovf = (op1[31] != op2[31]) && (result[31] != op1[31]);
            end

            // Πολλαπλασιασμός και έλεγχος αν χωράει στα 32-bit
            ALUOP_MUL: begin
                result = $signed(op1) * $signed(op2);
                if ($signed(op1) != 0 && ($signed(result) / $signed(op1) != $signed(op2)))
                    ovf = 1'b1;
                else
                    ovf = 1'b0;
            end

            // Πράξεις ολίσθησης
            ALUOP_SRL: result = op1 >> op2[4:0];
            ALUOP_SLL: result = op1 << op2[4:0];
            ALUOP_SRA: result = $signed(op1) >>> op2[4:0];
            ALUOP_SLA: result = $signed(op1) <<< op2[4:0];

            default: begin
                result = {op_width{1'b0}};
                ovf = 1'b0;
            end
        endcase
    end

    // Σήμα εξόδου αν το αποτέλεσμα είναι μηδέν
    assign zero = (result == {op_width{1'b0}});

endmodule