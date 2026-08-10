module alu_mux (
    input [31:0] reg_data,
    input [31:0] imm_data,
    input alu_src,
    output reg [31:0] alu_mux_out
);
    always @(*) begin
        alu_mux_out = alu_src ? imm_data : reg_data;
    end
    
endmodule