module instr_mem (
    input [31:0] address,
    output reg [31:0] instruction
);

    reg [31:0] rom [0:255]; // 256 words of instruction memory

    initial begin
        // Compact factorial program. The pipeline is now expected to handle
        // the data and control hazards here without hand-inserted nops.
        rom[0]  = 32'h40000113;
        rom[1]  = 32'h00600513;
        rom[2]  = 32'h00c000ef;
        rom[3]  = 32'h00a02023;
        rom[4]  = 32'h04000063;
        rom[5]  = 32'hff810113;
        rom[6]  = 32'h00112223;
        rom[7]  = 32'h00a12023;
        rom[8]  = 32'h00100293;
        rom[9]  = 32'h00551863;
        rom[10] = 32'h00100513;
        rom[11] = 32'h00810113;
        rom[12] = 32'h00008067;
        rom[13] = 32'hfff50513;
        rom[14] = 32'hfddff0ef;
        rom[15] = 32'h00012303;
        rom[16] = 32'h00412083;
        rom[17] = 32'h00810113;
        rom[18] = 32'h02650533;
        rom[19] = 32'h00008067;
        rom[20] = 32'h0000007f;
    end

    always @(*) begin
        instruction = rom[address[7:2]]; // Fetch instruction based on address
    end
    
endmodule
