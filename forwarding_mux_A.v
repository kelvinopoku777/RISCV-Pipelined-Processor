// This module implements a forwarding multiplexer for the A input of the ALU in the EX stage of a pipelined RISC-V processor.
// It selects the appropriate data to forward to the ALU based on the forwarding control signals.
// The forwarding logic is necessary to resolve data hazards that occur when an instruction depends on the result of a previous instruction that has not yet completed its execution.
module forwarding_mux_A (   
    input [31:0] reg_data1_ex,
    input [31:0] ex_mem_data,
    input [31:0] mem_wb_data,
    input [1:0] forward_a,
    output reg [31:0] forwarded_data_a
);
    always @(*) begin
        case (forward_a)
            2'b10: forwarded_data_a = ex_mem_data;
            2'b01: forwarded_data_a = mem_wb_data;
            default: forwarded_data_a = reg_data1_ex;
        endcase
    end
endmodule
