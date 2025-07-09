module IMEM (
    input [31:0] addr,
    output [31:0] inst
);
    reg [31:0] memory [0:255]; // 256 words

    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'h00000013; // NOP (ADDI x0, x0, 0)
        // Nếu muốn test lệnh khác, có thể gán trực tiếp ở đây
        // memory[0] = 32'hXXXXXXXX; // Lệnh 1
        // memory[1] = 32'hYYYYYYYY; // Lệnh 2
    end

    assign inst = memory[addr[31:2]]; // Word-aligned address

    always @(*) begin
        $display("IMEM: Cycle=%0d, addr=%h, inst=%h", $time/10, addr, inst);
    end
endmodule