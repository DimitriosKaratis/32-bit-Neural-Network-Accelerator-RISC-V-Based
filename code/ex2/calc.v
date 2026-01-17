// ΚΑΡΑΤΗΣ ΔΗΜΗΤΡΙΟΣ 10775
// 2. CALCULATOR MODULE

`include "../ex1/alu.v"
`include "calc_enc.v"

module calc (
    input clk,
    input btnc,     
    input btnac,   
    input btnl,
    input btnr,
    input btnd,
    input [15:0] sw,    
    output [15:0] led   
);

    reg [15:0] accumulator; 
    wire [31:0] op1, op2, alu_result;
    wire [3:0] alu_op;
    wire alu_zero, alu_ovf;

    // Sign extension 16-bit -> 32-bit με χρήση concatenation 
    assign op1 = {{16{accumulator[15]}}, accumulator}; 
    assign op2 = {{16{sw[15]}}, sw};                   

    // Σύνδεση Κωδικοποιητή
    calc_enc encoder_inst (
        .btnl(btnl),
        .btnr(btnr),
        .btnd(btnd),
        .alu_op(alu_op)
    );

    // Σύνδεση ALU 
    alu alu_inst (
        .op1(op1),
        .op2(op2),
        .alu_op(alu_op),
        .zero(alu_zero),
        .result(alu_result),
        .ovf(alu_ovf)
    );

    // Σύγχρονη λογική Συσσωρευτή 
    always @(posedge clk) begin
        if (btnac) begin
            accumulator <= 16'h0000; // Σύγχρονος μηδενισμός 
        end else if (btnc) begin
            accumulator <= alu_result[15:0]; // Ενημέρωση με τα 16 LSB 
        end
    end

    // Σύνδεση accumulator με LEDs 
    assign led = accumulator;

endmodule