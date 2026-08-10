module jalr_target_calc (
    input [31:0] base,
    input [31:0] offset,
    output [31:0] target
);
    assign target = (base + offset) & 32'hffff_fffe;
endmodule
