module data_mem (
    input [31:0] mem_address, // 8-bit address for 256 words
    input [31:0] write_data,
    input mem_write,
    output reg [31:0] read_data,
    input clk
);

    reg [31:0] memory [0:255]; // 256 words of memory

    integer i;

    initial begin
        for (i = 0; i < 256; i = i + 1)
            memory[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (mem_write) begin
            memory[mem_address[9:2]] <= write_data; // Write data to memory (word-aligned)
        end
    end
    
    always @(*) begin
        read_data <= memory[mem_address[9:2]]; // Read data from memory (word-aligned)
    end
    // assign read_data = memory[mem_address[9:2]]; // Continuous read for load instructions
    
endmodule