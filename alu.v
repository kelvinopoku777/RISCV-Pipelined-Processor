module alu (
    input [31:0] a,
    input [31:0] b,
    input [3:0] alu_ctrl,
    output reg [31:0] alu_out,
    output zero
);
    always @(*) begin
        case (alu_ctrl)
            4'b0000: alu_out = a & b;// AND
            4'b0001: alu_out = a | b;// OR
            4'b0010: alu_out = a + b;// ADD
            4'b0110: alu_out = a - b;// SUB
            4'b1000: alu_out = a << b[4:0];// SLL
            4'b1111: alu_out = a * b; // MUL
            //4'b1010: alu_out = (a >> b[4:0]) | (a[31] ? ~(32'hFFFFFFFF >> b[4:0]) : 0); // SRA
            default: alu_out = 32'b0;
        endcase
    end

    assign zero = (alu_out == 32'b0);
endmodule