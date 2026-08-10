// This module implements the forwarding unit for a pipelined RISC-V processor.
// The forwarding unit detects data hazards and generates control signals to forward data from later pipeline stages (EX and MEM) to the ID stage when necessary, allowing the processor to avoid stalls and maintain performance

module forwarding_unit (
    input [4:0] rs1_ex,
    input [4:0] rs2_ex,
    input [4:0] rd_mem,
    input [4:0] rd_wb,
    input reg_write_mem,
    input reg_write_wb,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    always @(*) begin
        // Default to no forwarding
        forward_a = 2'b00;
        forward_b = 2'b00;

        // Prefer the newest result in EX/MEM over MEM/WB.
        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs1_ex)) 
            begin
                forward_a = 2'b10; // Forward from EX/MEM stage
            end 
        else if (reg_write_wb && (rd_wb != 0) && (rd_wb == rs1_ex))
            begin
                forward_a = 2'b01; // Forward from MEM/WB stage
            end

        if (reg_write_mem && (rd_mem != 0) && (rd_mem == rs2_ex))
            begin
                forward_b = 2'b10; // Forward from EX/MEM stage
            end
        else if (reg_write_wb && (rd_wb != 0) && (rd_wb == rs2_ex))
            begin
                forward_b = 2'b01; // Forward from MEM/WB stage
            end
    end
    
endmodule
