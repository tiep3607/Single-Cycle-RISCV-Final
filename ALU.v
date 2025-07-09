module MyALU (
    output reg [31:0] alu_out,
    output reg is_zero,
    input [31:0] srcA,
    input [31:0] srcB,
    input [3:0] op_code
);
    reg [31:0] temp_result; // Biến trung gian cho kết quả
    always @(*) begin
        // Hiển thị thông tin debug
        $display("MyALU: Cycle=%0d, srcA=%h, srcB=%h, op_code=%b, alu_out=%h", $time/10, srcA, srcB, op_code, alu_out);
        case (op_code)
            4'b0000: temp_result = srcA + srcB; // Cộng
            4'b0001: temp_result = srcA - srcB; // Trừ
            4'b0010: temp_result = srcA & srcB; // AND
            4'b0011: temp_result = srcA | srcB; // OR
            4'b0100: temp_result = srcA ^ srcB; // XOR
            4'b0101: temp_result = srcA << srcB[4:0]; // Dịch trái
            4'b0110: temp_result = srcA >> srcB[4:0]; // Dịch phải logic
            4'b0111: temp_result = $signed(srcA) >>> srcB[4:0]; // Dịch phải số học
            4'b1000: temp_result = ($signed(srcA) < $signed(srcB)) ? 32'h1 : 32'h0; // SLT
            4'b1001: temp_result = (srcA < srcB) ? 32'h1 : 32'h0; // SLTU
            default: temp_result = 32'hDEADBEEF; // Giá trị mặc định khác biệt
        endcase
        alu_out = temp_result;
        is_zero = (alu_out == 0) ? 1'b1 : 1'b0; // Đặt lại cách kiểm tra zero
    end
endmodule