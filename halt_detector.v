module halt_detector (
    input [31:0] instruction,
    output halt
);
    assign halt = (instruction == 32'h0000007f);
endmodule
