// WARNING - THE FOLLOWING ALU WAS GENERATED - 
// IT MAY HAVE BUGS, IT MAY NOT ...

module ALU_16bit(
    input [15:0] A,
    input [15:0] B,
    input [3:0] opcode,
    input [6:0] shift_amt,  // Allows for 0-16 bit shifts
    output reg [15:0] result,
    output reg [31:0] mul_result,  // Dedicated 32-bit result for multiplication
    output reg carry_out,
    output reg zero_flag,
    output reg negative_flag,
    output reg overflow_flag
);

// Define operation codes
parameter ADD = 4'b0000;
parameter SUB = 4'b0001;
parameter MUL = 4'b0010;
parameter AND = 4'b0011;
parameter OR  = 4'b0100;
parameter NOT = 4'b0101;
parameter SHL = 4'b0110; // Shift left
parameter SHR = 4'b0111; // Shift right

always @(A, B, opcode, shift_amt) begin
    carry_out = 0;
    zero_flag = 0;
    negative_flag = 0;
    overflow_flag = 0;
    result = 16'b0;
    mul_result = 32'b0; // Ensure mul_result is reset
    
    case (opcode)
        ADD: {carry_out, result} = A + B;
        SUB: {carry_out, result} = A - B;
        MUL: mul_result = A * B; // Full 32-bit result
        AND: result = A & B;
        OR:  result = A | B;
        NOT: result = ~A; // Assuming one operand operation
        SHL: result = A << shift_amt;
        SHR: result = A >> shift_amt;
        default: result = 16'b0;
    endcase

    // Update flags based on result for non-multiplication operations, and based on mul_result for multiplication
    if (opcode == MUL) begin
        zero_flag = (mul_result == 32'b0);
        negative_flag = mul_result[31]; // MSB of the 32-bit result for negativity
        // Overflow flag handling might need to be reconsidered for multiplication
    end else begin
        zero_flag = (result == 16'b0);
        negative_flag = result[15];
        overflow_flag = (opcode == ADD && carry_out != result[15]) || (opcode == SUB && carry_out != result[15]);
    end
end

endmodule