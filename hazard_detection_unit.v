// This module is responsible for detecting load-use hazards in the pipelined RISC-V processor.
// A load-use hazard occurs when an instruction tries to use a register that is being loaded 
// from memory by a previous instruction that has not yet completed. The hazard detection unit
// generates control signals to stall the pipeline when such hazards are detected, allowing the
// load instruction to complete and the data to be available before the dependent instruction is executed.
// It also checks for control hazards caused by branches and jumps, and can generate flush signals to handle those cases as well.
module hazard_unit(
    input [4:0] rs1_id,
    input [4:0] rs2_id,
    input [4:0] rd_ex,
    input mem_to_reg_ex,
    input reg_write_ex,
    input take_branch_mem,
    input jump_mem,
    input jalr_mem,
    input cache_stall_mem,
    output reg stall_pc,
    output reg stall_if_id,
    output reg stall_id_ex,
    output reg stall_ex_mem,
    output reg stall_mem_wb,
    output reg flush_if_id,
    output reg flush_id_ex,
    output reg flush_ex_mem
);
    always @(*) begin
        // Default to no stalls or flushes
        stall_pc = 0;
        stall_if_id = 0;
        stall_id_ex = 0;
        stall_ex_mem = 0;
        stall_mem_wb = 0;
        flush_if_id = 0;
        flush_id_ex = 0;
        flush_ex_mem = 0;

        // Redirects are resolved in MEM, so squash all younger instructions.
        if (take_branch_mem || jump_mem || jalr_mem) begin
            flush_if_id = 1;
            flush_id_ex = 1;
            flush_ex_mem = 1;
        // Load-use hazard detection: if the instruction in EX stage is a load (mem_to_reg_ex is true)
        // and it writes to a register (reg_write_ex is true), and the destination register (rd_ex) is not zero, 
        //and it matches either source register of the instruction in ID stage
        end else if (mem_to_reg_ex && reg_write_ex && (rd_ex != 0) &&
                     ((rd_ex == rs1_id) || (rd_ex == rs2_id))) begin
            // Freeze fetch/decode and inject one bubble so the load can reach WB.
            stall_pc = 1;
            stall_if_id = 1;
            flush_id_ex = 1;
        end else if (cache_stall_mem) begin
            // Hold the whole pipeline while a blocking data-cache miss refills.
            stall_pc = 1;
            stall_if_id = 1;
            stall_id_ex = 1;
            stall_ex_mem = 1;
            stall_mem_wb = 1;
        end 
    end
    
endmodule
