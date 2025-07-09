module ImmediateGenerator (
    input [31:0] instruction,
    output reg [31:0] immediate
);
    always @(*) begin
	$display("ImmGen: Cycle=%0d, inst=%h, imm=%h", $time/10, instruction, immediate);
        casez (instruction[6:0]) // Opcode
            7'b0010011: // I-type (ADDI, etc.)
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            7'b0000011: // Load (LW)
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: // Store (SW)
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: // Branch (BEQ, etc.)
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            7'b1101111: // JAL
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            7'b0110111: // LUI
                immediate = {instruction[31:12], 12'h000};
            7'b0010111: // AUIPC
                immediate = {instruction[31:12], 12'h000};
            default: immediate = 32'h00000000;
        endcase
    end
endmodule