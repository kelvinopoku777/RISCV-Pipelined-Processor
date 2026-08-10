module reg_file (
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    input reg_write,
    output reg [31:0] reg_data1,
    output reg [31:0] reg_data2,
    input clk
);

    reg [31:0] registers [0:31]; // 32 registers of 32 bits each

    integer i;

    initial begin
        for (i = 0; i < 32; i = i + 1)
            registers[i] = 32'b0;
    end

    always @(posedge clk) begin
        if (reg_write && rd != 0) begin
            registers[rd] <= write_data; // Write data to register (x0 is always 0)
        end
    end

    always @(*) begin
        // Let decode observe the value being written back in the same cycle.
        reg_data1 = (reg_write && (rd != 0) && (rd == rs1)) ? write_data : registers[rs1];
        reg_data2 = (reg_write && (rd != 0) && (rd == rs2)) ? write_data : registers[rs2];
    end
    
endmodule
