module MainController (
    input [6:0] op_code,
    input [2:0] func3,
    input [6:0] func7,
    output reg reg_wr,
    output reg mem_rd,
    output reg mem_wr,
    output reg mem2reg,
    output reg [3:0] alu_ctrl,
    output reg alu_src_sel,
    output reg branch_en,
    output reg jump_en,
    output reg [1:0] pc_sel
);
    always @(*) begin
        $display("ControlUnit: Cycle=%0d, opcode=%b, funct3=%b, funct7=%b, reg_write=%b, alu_src=%b, alu_op=%b",
                 $time/10, op_code, func3, func7, reg_wr, alu_src_sel, alu_ctrl);
        reg_wr = 1'b0;
        mem_rd = 1'b0;
        mem_wr = 1'b0;
        mem2reg = 1'b0;
        alu_ctrl = 4'b0000;
        alu_src_sel = 1'b0;
        branch_en = 1'b0;
        jump_en = 1'b0;
        pc_sel = 2'b00; // PC + 4

        casez (op_code)
            7'b0000011: begin // Load (LW)
                reg_wr = 1'b1;
                mem_rd = 1'b1;
                mem2reg = 1'b1;
                alu_src_sel = 1'b1;
                alu_ctrl = 4'b0000; // ADD
            end
            7'b0100011: begin // Store (SW)
                mem_wr = 1'b1;
                alu_src_sel = 1'b1;
                alu_ctrl = 4'b0000; // ADD
            end
            7'b0110011: begin // R-type
                reg_wr = 1'b1;
                alu_src_sel = 1'b0;
                case ({func3, func7})
                    {3'b000, 7'h00}: alu_ctrl = 4'b0000; // ADD
                    {3'b000, 7'h20}: alu_ctrl = 4'b0001; // SUB
                    {3'b001, 7'h00}: alu_ctrl = 4'b0101; // SLL
                    {3'b010, 7'h00}: alu_ctrl = 4'b1000; // SLT
                    {3'b011, 7'h00}: alu_ctrl = 4'b1001; // SLTU
                    {3'b100, 7'h00}: alu_ctrl = 4'b0100; // XOR
                    {3'b101, 7'h00}: alu_ctrl = 4'b0110; // SRL
                    {3'b101, 7'h20}: alu_ctrl = 4'b0111; // SRA
                    {3'b110, 7'h00}: alu_ctrl = 4'b0011; // OR
                    {3'b111, 7'h00}: alu_ctrl = 4'b0010; // AND
                endcase
            end
            7'b0010011: begin // I-type (ADDI, etc.)
                reg_wr = 1'b1;
                alu_src_sel = 1'b1;
                case (func3)
                    3'b000: alu_ctrl = 4'b0000; // ADDI
                    3'b111: alu_ctrl = 4'b0010; // ANDI
                    3'b110: alu_ctrl = 4'b0011; // ORI
                    3'b100: alu_ctrl = 4'b0100; // XORI
                    3'b001: alu_ctrl = 4'b0101; // SLLI
                    3'b101: alu_ctrl = (func7 == 7'h00) ? 4'b0110 : 4'b0111; // SRLI, SRAI
                    3'b010: alu_ctrl = 4'b1000; // SLTI
                    3'b011: alu_ctrl = 4'b1001; // SLTIU
                endcase
            end
            7'b1100011: begin // Branch (BEQ, etc.)
                branch_en = 1'b1;
                alu_ctrl = 4'b0001; // SUB
                pc_sel = 2'b01; // PC + imm (if branch taken)
            end
            7'b1101111: begin // JAL
                reg_wr = 1'b1;
                jump_en = 1'b1;
                pc_sel = 2'b01; // PC + imm
                alu_ctrl = 4'b0000;
            end
            7'b1100111: begin // JALR
                reg_wr = 1'b1;
                jump_en = 1'b1;
                pc_sel = 2'b10; // rs1 + imm
                alu_ctrl = 4'b0000;
                alu_src_sel = 1'b1;
            end
            7'b0110111: begin // LUI
                reg_wr = 1'b1;
                alu_src_sel = 1'b1;
                alu_ctrl = 4'b0000; // Pass immediate
            end
            7'b0010111: begin // AUIPC
                reg_wr = 1'b1;
                alu_src_sel = 1'b1;
                alu_ctrl = 4'b0000; // ADD PC + imm
            end
            default: begin
                $display("Unknown opcode: %b", op_code);
            end
        endcase
    end
endmodule