module imm_gen (
    input [6:0] opcode,
    input [31:0] instruction,
    output reg [31:0] immediate
);

    always @(*) begin
        case (opcode)
            7'b0000011: begin // load word
                immediate = {{20{instruction[31]}}, instruction[31:20]}; // sign-extend the immediate
            end
            7'b0100011: begin // store word
                immediate = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; 
            end
            7'b1100011: begin // branch
                immediate = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0}; 
            end
            7'b0010011: begin // addi and other I-type instructions
                immediate = {{20{instruction[31]}}, instruction[31:20]}; 
            end
            7'b1100111: begin // jalr
                immediate = {{20{instruction[31]}}, instruction[31:20]};
            end
            7'b1101111: begin // jal
                immediate = {{11{instruction[31]}}, instruction[31], instruction[19:12], instruction[20], instruction[30:21], 1'b0};
            end
            default: begin
                immediate = 32'b0; 
            end
        endcase
    end
    
endmodule
