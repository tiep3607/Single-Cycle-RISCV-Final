module ImmGen  (
    output reg [31:0] immediate,
    input [31:0] instruction
);
    reg [31:0] imm_temp; // Biến trung gian cho immediate
    always @(*) begin
        // Debug thông tin sinh immediate
        $display("ImmediateGenerator: Cycle=%0d, instruction=%h, immediate=%h", $time/10, instruction, immediate);
        case (instruction[6:0]) // Xét opcode
            7'b0010011: // I-type (ADDI, v.v.)
                imm_temp = {{20{instruction[31]}}, instruction[31:20]};
            7'b0000011: // Load (LW)
                imm_temp = {{20{instruction[31]}}, instruction[31:20]};
            7'b0100011: // Store (SW)
                imm_temp = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011: // Branch (BEQ, v.v.)
                imm_temp = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            7'b1101111: // JAL
                imm_temp = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            7'b0110111: // LUI
                imm_temp = {instruction[31:12], 12'h000};
            7'b0010111: // AUIPC
                imm_temp = {instruction[31:12], 12'h000};
            default: imm_temp = 32'hA5A5A5A5; // Giá trị mặc định khác biệt
        endcase
        immediate = imm_temp;
    end
endmodule