module ArithmeticLogicUnit (
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] alu_ctrl,
    output reg [31:0] alu_result,
    output reg is_zero
);
    always @(*) begin
	$display("ALU: Cycle=%0d, op1=%h, op2=%h, alu_op=%b, result=%h",
                 $time/10, srcA, srcB, alu_ctrl, alu_result);
        casez (alu_ctrl)
            4'b0000: alu_result = srcA + srcB; // ADD
            4'b0001: alu_result = srcA - srcB; // SUB
            4'b0010: alu_result = srcA & srcB; // AND
            4'b0011: alu_result = srcA | srcB; // OR
            4'b0100: alu_result = srcA ^ srcB; // XOR
            4'b0101: alu_result = srcA <<< srcB[4:0]; // SLL
            4'b0110: alu_result = srcA >> srcB[4:0]; // SRL
            4'b0111: alu_result = $signed(srcA) >>> srcB[4:0]; // SRA
            4'b1000: alu_result = ($signed(srcA) < $signed(srcB)) ? 32'h1 : 32'h0; // SLT
            4'b1001: alu_result = (srcA < srcB) ? 32'h1 : 32'h0; // SLTU
            default: alu_result = 32'h00000000;
        endcase
        is_zero = (alu_result == 32'h00000000);
    end
endmodule