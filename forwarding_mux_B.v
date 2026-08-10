module forwarding_mux_B (
    input [31:0] reg_data2_ex,
    input [31:0] ex_mem_data,
    input [31:0] mem_wb_data,
    input [1:0] forward_b,
    output reg [31:0] forwarded_data_b
);
    always @(*) begin
        case (forward_b)
            2'b10: forwarded_data_b = ex_mem_data;
            2'b01: forwarded_data_b = mem_wb_data;
            default: forwarded_data_b = reg_data2_ex;
        endcase
    end
endmodule
