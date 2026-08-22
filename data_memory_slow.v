module data_mem_slow (
    input clk,
    input rst_n,
    input mem_read_en,
    input mem_write_en,
    input [31:0] mem_address,
    input [31:0] write_data,
    output reg [31:0] read_data,
    output reg mem_ready
);
    localparam READ_LATENCY = 2;

    reg [31:0] memory [0:255];
    reg pending_read;
    reg [31:0] pending_address;
    reg [1:0] wait_count;
    reg mem_read_en_prev;
    integer i;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            read_data <= 32'h0;
            mem_ready <= 1'b0;
            pending_read <= 1'b0;
            pending_address <= 32'h0;
            wait_count <= 2'h0;
            mem_read_en_prev <= 1'b0;
            for (i = 0; i < 256; i = i + 1)
                memory[i] <= 32'h0;
        end else begin
            mem_ready <= 1'b0;

            if (mem_write_en) begin
                memory[mem_address[9:2]] <= write_data;
            end

            // Treat mem_read_en as a request pulse. The cache keeps it high
            // while waiting, so edge-detecting here prevents the same miss
            // from being reissued after the response is already on the way.
            if (!pending_read && mem_read_en && !mem_read_en_prev) begin
                pending_read <= 1'b1;
                pending_address <= mem_address;
                wait_count <= READ_LATENCY - 1;
            end else if (pending_read) begin
                if (wait_count == 0) begin
                    read_data <= memory[pending_address[9:2]];
                    mem_ready <= 1'b1;
                    pending_read <= 1'b0;
                end else begin
                    wait_count <= wait_count - 1'b1;
                end
            end

            mem_read_en_prev <= mem_read_en;
        end
    end
endmodule
