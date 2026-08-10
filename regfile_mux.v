module regfile_mux (
    input [31:0] alu_result,
    input [31:0] mem_data,
    input [31:0] pc_plus4,
    input mem_to_reg,
    input link,
    output reg [31:0] write_data
);
    always @(*) begin
        if (link) begin
            write_data = pc_plus4;
        end else begin
            write_data = mem_to_reg ? mem_data : alu_result;
        end
    end
    
endmodule
