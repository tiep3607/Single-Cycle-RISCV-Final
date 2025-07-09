module IMEM (
    input [31:0] addr,
    output [31:0] inst
);
    reg [31:0] memory [0:255]; // 256 words
    
    assign inst = memory[addr[31:2]]; // Word-aligned address

    initial begin
        if ($test$plusargs("NOIMEM") == 0) begin
            $display("IMEM: Loading instructions from mem/imem.hex");
            $readmemh("mem/imem.hex", memory);
        end else begin
            $display("IMEM: Skipping instruction memory load (NOIMEM set)");
        end
    end

    always @(*) begin
        $display("IMEM: Cycle=%0d, addr=%h, inst=%h", $time/10, addr, inst);
    end
endmodule