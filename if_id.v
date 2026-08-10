module if_id (
    // instruction and PC
    input [31:0] instruction_in,
    output reg [31:0] instruction_out,
    input clk,
    input rst_n,
    input stall,
    input flush,
    input [31:0] pc_in,
    output reg [31:0] pc_out
);
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            instruction_out <= 32'h0;
            pc_out <= 32'h0;
        end else if (flush) begin
            instruction_out <= 32'h0;
            pc_out <= 32'h0;
        end else if (!stall) begin
            instruction_out <= instruction_in;
            pc_out <= pc_in;
        end
    end
    
endmodule
