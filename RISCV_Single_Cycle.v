module RISCV_Single_Cycle (
    input clk,
    input rst_n,
    output [31:0] PC_out_top,
    output [31:0] Instruction_out_top
);

    // Wires
    wire [31:0] pc_out, pc_in, inst, imm, read_data1, read_data2, alu_result, mem_read_data, write_data;
    wire [31:0] alu_operand2, pc_plus_4, branch_target, jalr_target;
    wire reg_write, mem_read, mem_write, mem_to_reg, alu_src, branch, jump, zero;
    wire [3:0] alu_op;
    wire [1:0] pc_src;
    wire pc_write;

    // PC
    wire enable_pc_update = pc_write;
    wire [31:0] next_pc = pc_in;
    wire clk_in = clk;
    wire rst_active_low = rst_n;
    wire [31:0] current_pc;
    ProgramCounter pc_inst (
        .clk_in(clk_in),
        .rst_active_low(rst_active_low),
        .next_pc(next_pc),
        .enable_pc_update(enable_pc_update),
        .current_pc(current_pc)
    );
    assign pc_out = current_pc;

    // IMEM
    IMEM IMEM_inst (
        .addr(pc_out),
        .inst(inst)
    );

    // Control Unit
    wire [6:0] op_code = inst[6:0];
    wire [2:0] func3 = inst[14:12];
    wire [6:0] func7 = inst[31:25];
    wire reg_wr, mem_rd, mem_wr, mem2reg, alu_src_sel, branch_en, jump_en;
    wire [3:0] alu_ctrl;
    wire [1:0] pc_sel;
    MainController ctrl_inst (
        .op_code(op_code),
        .func3(func3),
        .func7(func7),
        .reg_wr(reg_wr),
        .mem_rd(mem_rd),
        .mem_wr(mem_wr),
        .mem2reg(mem2reg),
        .alu_ctrl(alu_ctrl),
        .alu_src_sel(alu_src_sel),
        .branch_en(branch_en),
        .jump_en(jump_en),
        .pc_sel(pc_sel)
    );

    // Register File
    RegisterFile Reg_inst (
        .clk(clk),
        .rst_n(rst_n),
        .rs1(inst[19:15]),
        .rs2(inst[24:20]),
        .rd(inst[11:7]),
        .write_data(write_data),
        .reg_write(reg_write),
        .read_data1(read_data1),
        .read_data2(read_data2)
    );

    // Immediate Generator
    wire [31:0] instruction = inst;
    wire [31:0] immediate;
    ImmediateGenerator imm_gen_inst (
        .instruction(instruction),
        .immediate(immediate)
    );
    assign imm = immediate;

    // ALU
    wire [31:0] srcA = read_data1;
    wire [31:0] srcB = alu_src_sel ? immediate : read_data2;
    wire [3:0] alu_ctrl_sig = alu_ctrl;
    wire [31:0] alu_result_sig;
    wire is_zero;
    ArithmeticLogicUnit alu_inst (
        .srcA(srcA),
        .srcB(srcB),
        .alu_ctrl(alu_ctrl_sig),
        .alu_result(alu_result_sig),
        .is_zero(is_zero)
    );
    assign alu_result = alu_result_sig;
    assign zero = is_zero;

    // Data Memory
    DMEM DMEM_inst (
        .clk(clk),
        .addr(alu_result),
        .write_data(read_data2),
        .mem_write(mem_write),
        .mem_read(mem_read),
        .read_data(mem_read_data)
    );

    // Write-back
    assign write_data = mem_to_reg ? mem_read_data : 
                        (jump ? pc_plus_4 : alu_result);

    // Outputs for testbench
    assign PC_out_top = pc_out;
    assign Instruction_out_top = inst;

    always @(posedge clk) begin
        $display("Cycle=%0d, PC=%h, Inst=%h, x3=%h, imm=%h, alu_result=%h, reg_write=%b, alu_src=%b, alu_op=%b",
                 $time/10, pc_out, inst, Reg_inst.registers[3], imm, alu_result,
                 ctrl_inst.reg_wr, ctrl_inst.alu_src_sel, ctrl_inst.alu_ctrl);
    end

    // Sửa lại các tín hiệu kết nối với các module mới
    assign reg_write = reg_wr;
    assign mem_read = mem_rd;
    assign mem_write = mem_wr;
    assign mem_to_reg = mem2reg;
    assign alu_src = alu_src_sel;
    assign branch = branch_en;
    assign jump = jump_en;
    assign alu_op = alu_ctrl;
    assign pc_src = pc_sel;
endmodule