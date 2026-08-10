
/* this module is responsible for selecting the next program counter (PC)
 * value based on the control signals.
 if the instruction is a jump and link register (JALR), the next PC is the JALR target address.
 if the instruction is a branch and the branch condition is met (take_branch is true) 
 or if it's an unconditional jump, the next PC is the branch target address.
 otherwise, the next PC is simply the current PC plus 4, which points to the next sequential instruction in memory.
 */
module pc_mux (
    input [31:0] current_pc,
    input [31:0] branch_target,
    input [31:0] jalr_target,
    input take_branch,
    input jump,
    input jalr,
    output reg [31:0] next_pc
);
always @(*) begin
    if (jalr) begin
        next_pc = jalr_target;
    end else if (take_branch || jump) begin
        next_pc = branch_target; // Branch target address
    end else begin
        next_pc = current_pc + 4; // Next sequential instruction
    end
end
    
endmodule
