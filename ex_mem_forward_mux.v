module ex_mem_forward_mux (
    input [31:0] alu_out_mem,
    input [31:0] pc_plus4_mem,
    input link_mem,
    output reg [31:0] ex_mem_forward_data
);
    always @(*) begin
        if (link_mem) begin
            ex_mem_forward_data = pc_plus4_mem;
        end else begin
            ex_mem_forward_data = alu_out_mem;
        end
    end
endmodule
