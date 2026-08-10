module id_ex (
    input [31:0] instruction_in,
    output reg [31:0] instruction_out,
    input clk,
    input rst_n,
    input flush,
    input [31:0] pc_in,
    output reg [31:0] pc_out,
    input [31:0] reg_data1_in,
    input [31:0] reg_data2_in,
    output reg [31:0] reg_data1_out,
    output reg [31:0] reg_data2_out,
    input [31:0] immediate_in,
    output reg [31:0] immediate_out,
    input [2:0] func3_in,
    input [6:0] func7_in,
    output reg [2:0] func3_out,
    output reg [6:0] func7_out,
    input [6:0] opcode_in,
    output reg [6:0] opcode_out,
    // Register addresses
    input [4:0] rd_in,
    input [4:0] rs1_in,
    input [4:0] rs2_in,
    output reg [4:0] rd_out,
    output reg [4:0] rs1_out,
    output reg [4:0] rs2_out,
    // control signals_in
    input reg_write_in,
    input [1:0] alu_op_in,
    input mem_write_in,
    input mem_to_reg_in, 
    input alu_src_in,
    input branch_in,
    input bne_in,
    input jump_in,
    input link_in,
    input jalr_in,
    //control signals_out
    output reg reg_write_out,
    output reg [1:0] alu_op_out,
    output reg mem_write_out,
    output reg mem_to_reg_out, 
    output reg alu_src_out,
    output reg branch_out,
    output reg bne_out,
    output reg jump_out,
    output reg link_out,
    output reg jalr_out
);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        instruction_out <= 32'h0;
        pc_out <= 32'h0;
        reg_data1_out <= 32'h0;
        reg_data2_out <= 32'h0;
        immediate_out <= 32'h0;
        reg_write_out <= 1'b0;
        alu_op_out <= 2'b00;
        mem_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0; 
        alu_src_out <= 1'b0;
        branch_out <= 1'b0;
        bne_out <= 1'b0;
        jump_out <= 1'b0;
        link_out <= 1'b0;
        jalr_out <= 1'b0;
        opcode_out <= 7'h0;
        func3_out <= 3'h0;
        func7_out <= 7'h0;
        rd_out <= 5'h0;
        rs1_out <= 5'h0;
        rs2_out <= 5'h0;
    end else if (flush) begin
        // Inject a bubble on hazards or control-flow redirects.
        instruction_out <= 32'h0;
        pc_out <= 32'h0;
        reg_data1_out <= 32'h0;
        reg_data2_out <= 32'h0;
        immediate_out <= 32'h0;
        reg_write_out <= 1'b0;
        alu_op_out <= 2'b00;
        mem_write_out <= 1'b0;
        mem_to_reg_out <= 1'b0; 
        alu_src_out <= 1'b0;
        branch_out <= 1'b0;
        bne_out <= 1'b0;
        jump_out <= 1'b0;
        link_out <= 1'b0;
        jalr_out <= 1'b0;
        opcode_out <= 7'h0;
        func3_out <= 3'h0;
        func7_out <= 7'h0;
        rd_out <= 5'h0;
        rs1_out <= 5'h0;
        rs2_out <= 5'h0;
    end else begin
        // instruction and PC
        instruction_out <= instruction_in;
        pc_out <= pc_in;
        reg_data1_out <= reg_data1_in;
        reg_data2_out <= reg_data2_in;
        immediate_out <= immediate_in;
        // Control signals
        reg_write_out <= reg_write_in;
        alu_op_out <= alu_op_in;
        mem_write_out <= mem_write_in;
        mem_to_reg_out <= mem_to_reg_in; 
        alu_src_out <= alu_src_in;
        branch_out <= branch_in;
        bne_out <= bne_in;
        jump_out <= jump_in;
        link_out <= link_in;
        jalr_out <= jalr_in;
        // decoded fields
        opcode_out <= opcode_in;
        func3_out <= func3_in;
        func7_out <= func7_in;
        // Register addresses
        rd_out <= rd_in;
        rs1_out <= rs1_in;
        rs2_out <= rs2_in;
    end
end
    
endmodule
