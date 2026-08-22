module mem_wb (
    input [31:0] instruction_in,
    output reg [31:0] instruction_out,
    input clk,
    input rst_n,
    input stall,
    input [31:0] pc_in,
    output reg [31:0] pc_out,
    // control signals
    input reg_write_in,
    input mem_to_reg_in,
    input link_in,
    output reg reg_write_out,
    output reg mem_to_reg_out,
    output reg link_out,
    // ALU result and load data for write-back
    input [31:0] alu_out_in,
    input [31:0] mem_read_data_in,
    output reg [31:0] alu_out_out,
    output reg [31:0] mem_read_data_out,
    // Register address for write-back
    input [4:0] rd_in,
    output reg [4:0] rd_out 
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instruction_out <= 32'h0;
            pc_out <= 32'h0;
            reg_write_out <= 1'b0;
            mem_to_reg_out <= 1'b0;
            link_out <= 1'b0;
            alu_out_out <= 32'h0;
            mem_read_data_out <= 32'h0;
            rd_out <= 5'h0;
        end else if (stall) begin
            instruction_out <= instruction_out;
            pc_out <= pc_out;
            reg_write_out <= reg_write_out;
            mem_to_reg_out <= mem_to_reg_out;
            link_out <= link_out;
            alu_out_out <= alu_out_out;
            mem_read_data_out <= mem_read_data_out;
            rd_out <= rd_out;
        end else begin
            instruction_out <= instruction_in;
            pc_out <= pc_in;
            reg_write_out <= reg_write_in;
            mem_to_reg_out <= mem_to_reg_in;
            link_out <= link_in;
            alu_out_out <= alu_out_in;
            mem_read_data_out <= mem_read_data_in;
            rd_out <= rd_in;
        end
    end
    
endmodule
