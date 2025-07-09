module ProgramCounter (
    input clk_in,
    input rst_active_low,
    input [31:0] next_pc,
    input enable_pc_update,
    output reg [31:0] current_pc
);
    always @(posedge clk_in or negedge rst_active_low) begin
        if (rst_active_low == 1'b0) begin
            current_pc <= 32'h00000000;
        end else begin
            if (enable_pc_update)
                current_pc <= next_pc;
        end
    end
endmodule