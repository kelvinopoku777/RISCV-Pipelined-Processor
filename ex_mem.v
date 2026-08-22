module ex_mem (
    input [31:0] instruction_in,
    output reg [31:0] instruction_out,
    input clk,
    input rst_n,
    input stall,
    input flush,
    // PC for control-flow and link write-back
    input [31:0] pc_in,
    output reg [31:0] pc_out,
    // alu result
    input [31:0] alu_out_in,
    output reg [31:0] alu_out_out,
    // reg data 2 for store instructions
    input [31:0] reg_data2_in,
    output reg [31:0] reg_data2_out,
    input zero_in,
    output reg zero_out,
    // control signals
    input reg_write_in,
    input mem_write_in,
    input mem_to_reg_in,
    input branch_in,
    input bne_in,
    input jump_in,
    input link_in,
    input jalr_in,
    output reg reg_write_out,
    output reg mem_write_out,
    output reg mem_to_reg_out,
    output reg branch_out,
    output reg bne_out,
    output reg jump_out,
    output reg link_out,
    output reg jalr_out,
    input [31:0] branch_target_in,
    output reg [31:0] branch_target_out,
    input [31:0] jalr_target_in,
    output reg [31:0] jalr_target_out,

    input [4:0] rd_in,
    output reg [4:0] rd_out

);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instruction_out <= 32'h0;
            pc_out <= 32'h0;
            alu_out_out <= 32'h0;
            reg_data2_out <= 32'h0;
            zero_out <= 1'b0;
            reg_write_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            branch_out <= 1'b0;
            bne_out <= 1'b0;
            jump_out <= 1'b0;
            link_out <= 1'b0;
            jalr_out <= 1'b0;
            branch_target_out <= 32'h0;
            jalr_target_out <= 32'h0;
            rd_out <= 5'h0;
        end else if (flush) begin
            // Squash the instruction currently in EX after a taken redirect.
            instruction_out <= 32'h0;
            pc_out <= 32'h0;
            alu_out_out <= 32'h0;
            reg_data2_out <= 32'h0;
            zero_out <= 1'b0;
            reg_write_out <= 1'b0;
            mem_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            branch_out <= 1'b0;
            bne_out <= 1'b0;
            jump_out <= 1'b0;
            link_out <= 1'b0;
            jalr_out <= 1'b0;
            branch_target_out <= 32'h0;
            jalr_target_out <= 32'h0;
            rd_out <= 5'h0;
        end else if (stall) begin
            instruction_out <= instruction_out;
            pc_out <= pc_out;
            alu_out_out <= alu_out_out;
            reg_data2_out <= reg_data2_out;
            zero_out <= zero_out;
            reg_write_out <= reg_write_out;
            mem_write_out <= mem_write_out;
            mem_to_reg_out <= mem_to_reg_out;
            branch_out <= branch_out;
            bne_out <= bne_out;
            jump_out <= jump_out;
            link_out <= link_out;
            jalr_out <= jalr_out;
            branch_target_out <= branch_target_out;
            jalr_target_out <= jalr_target_out;
            rd_out <= rd_out;
        end else begin
            instruction_out <= instruction_in;
            pc_out <= pc_in;
            branch_target_out <= branch_target_in;
            jalr_target_out <= jalr_target_in;
            alu_out_out <= alu_out_in;
            reg_data2_out <= reg_data2_in;
            zero_out <= zero_in;
            reg_write_out <= reg_write_in;
            mem_write_out <= mem_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            branch_out <= branch_in;
            bne_out <= bne_in;
            jump_out <= jump_in;
            link_out <= link_in;
            jalr_out <= jalr_in;
            rd_out <= rd_in;
        end
    end

endmodule
