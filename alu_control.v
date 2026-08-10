module alu_control (
    input [6:0] opcode,
    input [2:0] func3,
    input [6:0] func7,
    output reg [3:0] alu_ctrl,
    input [1:0] alu_op
);
always @(*) begin
    case (alu_op)
        2'b00: alu_ctrl = 4'b0010; // Load/Store: ALU performs addition
        2'b01: alu_ctrl = 4'b0110; // Branch: ALU performs subtraction
        2'b10: begin // R-type: Determine operation based on func3 and func7
            case (func3)
                3'b000: begin
                    if (func7 == 7'b0000000) begin
                        alu_ctrl = 4'b0010; // ADD
                    end else if (func7 == 7'b0100000) begin
                        alu_ctrl = 4'b0110; // SUB
                    end else if (func7 == 7'b0000001) begin
                        alu_ctrl = 4'b1111; // MUL
                    end else begin
                        alu_ctrl = 4'b0000;
                    end
                end
                3'b111: alu_ctrl = 4'b0000; // AND
                3'b110: alu_ctrl = 4'b0001; // OR
                3'b100: alu_ctrl = 4'b1000; // SLL
                //3'b101: alu_ctrl = (func7 == 0) ? 4'b0010 : 4'b1010; // SRL/SRA
                default: alu_ctrl = 4'b0000; // Default to AND for unsupported func3
            endcase
        end
        default: alu_ctrl = 4'b0000; // Default to AND for unsupported alu_op
    endcase
end
    
endmodule
