// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 4. MAC (Multiply and Accumulate) UNIT MODULE

`include "../ex1/alu.v"


module mac_unit (
    input [31:0] op1,    
    input [31:0] op2,        
    input [31:0] op3,        
    output [31:0] total_result,
    output zero_mul,         
    output zero_add,         
    output ovf_mul,          
    output ovf_add           
);

    wire [31:0] mul_res;

    // ALU 1: Πολλαπλασιασμός (alu_op = 4'b0110)
    alu alu_mul (
        .op1(op1),
        .op2(op2),
        .alu_op(4'b0110),
        .zero(zero_mul),
        .result(mul_res),
        .ovf(ovf_mul)
    );

    // ALU 2: Πρόσθεση (alu_op = 4'b0100)
    alu alu_add (
        .op1(mul_res),
        .op2(op3),
        .alu_op(4'b0100),
        .zero(zero_add),
        .result(total_result),
        .ovf(ovf_add)
    );

endmodule