module ctrl_unit (
    input [6:0] opcode,
    output reg reg_write,
    output reg mem_to_reg,
    output reg mem_write,
    output reg alu_src,
    output reg [1:0] alu_op,
    output reg branch,
    output reg bne,
    output reg jump,
    output reg jalr,
    output reg link,
    input [2:0] func3
);
    always @(*) begin
        reg_write  = 1'b0;
        mem_write  = 1'b0;
        mem_to_reg = 1'b0;
        alu_src    = 1'b0;
        alu_op     = 2'b11; // Default to an invalid ALU operation
        branch     = 1'b0;
        bne        = 1'b0;
        jump       = 1'b0;
        jalr       = 1'b0;
        link       = 1'b0;
        case (opcode)
            7'b0110011: begin // R-type
                reg_write = 1;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                alu_op = 2'b10;
                branch = 0;
                bne = 0;
            end
            7'b0000011: begin // I-type (load)
                reg_write = 1;
                mem_to_reg = 1;
                mem_write = 0;
                alu_src = 1;
                alu_op = 2'b00;
                branch = 0;
                bne = 0;
            end
            7'b0100011: begin // S-type (store)
                reg_write = 0;
                mem_to_reg = 0; // Don't care
                mem_write = 1;
                alu_src = 1;
                alu_op = 2'b00;
                branch = 0;
            end
            7'b1100011: begin // B-type (branch)
                reg_write = 0;
                mem_to_reg = 0;// Don't care
                mem_write = 0;
                alu_src = 0;
                alu_op = 2'b01; // Use ALU for comparison
                branch = 1;
                case (func3)
                    3'b000: bne = 0; // BEQ
                    3'b001: bne = 1; // BNE
                    default: bne = 0;
                endcase
            end
            7'b0010011: begin // I-type ALU (e.g. ADDI)
                reg_write = 1;
                alu_src = 1;
                alu_op = 2'b00;
            end
            7'b1101111: begin // JAL
                reg_write = 1;
                jump = 1;
                link = 1;
            end
            7'b1100111: begin // JALR
                reg_write = 1;
                alu_src = 1;
                alu_op = 2'b00;
                jalr = 1;
                link = 1;
            end
            default: begin
                reg_write = 0;
                mem_to_reg = 0;
                mem_write = 0;
                alu_src = 0;
                alu_op = 2'b11; // Default to an invalid ALU operation
                branch = 0;
            end
        endcase
    end
    
endmodule
