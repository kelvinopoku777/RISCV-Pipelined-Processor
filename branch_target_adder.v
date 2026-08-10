module branch_target_adder (
    input [31:0] current_pc,
    input [31:0] branch_offset,
    output reg [31:0] branch_target
);
    always @(*) begin
        branch_target <= current_pc + branch_offset; // Calculate branch target address
    end
    
endmodule