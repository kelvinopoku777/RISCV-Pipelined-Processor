module instr_mem (
    input [31:0] address,
    output reg [31:0] instruction
);

    reg [31:0] rom [0:255]; // 256 words of instruction memory
    integer i;

    initial begin
        // Load the assembled program from program.hex.
        for (i = 0; i < 256; i = i + 1)
            rom[i] = 32'h00000013;
        $readmemh("program.hex", rom);
    end

    always @(*) begin
        instruction = rom[address[7:2]]; // Fetch instruction based on address
    end
    
endmodule
