module testbench_data_cache;

    reg clk;
    reg rst_n;
    reg read_en;
    reg write_en;
    reg [31:0] address;
    reg [31:0] write_data;
    wire [31:0] read_data;
    wire cpu_ready;
    wire cache_hit;
    wire [31:0] hit_count;
    wire [31:0] miss_count;
    wire mem_read_en;
    wire mem_write_en;
    wire [31:0] mem_address;
    wire [31:0] mem_write_data;
    wire [31:0] mem_read_data;
    wire mem_ready;

    data_cache dut (
        .clk(clk),
        .rst_n(rst_n),
        .cpu_read_en(read_en),
        .cpu_write_en(write_en),
        .cpu_address(address),
        .cpu_write_data(write_data),
        .mem_read_data(mem_read_data),
        .mem_ready(mem_ready),
        .cpu_read_data(read_data),
        .cpu_ready(cpu_ready),
        .cache_hit(cache_hit),
        .hit_count(hit_count),
        .miss_count(miss_count),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .mem_address(mem_address),
        .mem_write_data(mem_write_data)
    );

    data_mem_slow backing_mem (
        .clk(clk),
        .rst_n(rst_n),
        .mem_read_en(mem_read_en),
        .mem_write_en(mem_write_en),
        .mem_address(mem_address),
        .write_data(mem_write_data),
        .read_data(mem_read_data),
        .mem_ready(mem_ready)
    );

    always #5 clk = ~clk;

    task do_read;
        input [31:0] addr;
        input expected_hit;
        input [31:0] expected_data;
    begin
        address = addr;
        read_en = 1'b1;
        write_en = 1'b0;
        if (expected_hit) begin
            #1;
            if (cpu_ready !== 1'b1 || cache_hit !== 1'b1 || read_data !== expected_data) begin
                $display("FAIL read-hit addr=%h ready=%b hit=%b data=%h expected_data=%h",
                         addr, cpu_ready, cache_hit, read_data, expected_data);
                $finish;
            end
            #9;
        end else begin
            #1;
            if (cpu_ready !== 1'b0 || cache_hit !== 1'b0) begin
                $display("FAIL miss-start addr=%h ready=%b hit=%b", addr, cpu_ready, cache_hit);
                $finish;
            end
            wait (cpu_ready === 1'b1);
            #1;
            if (read_data !== expected_data) begin
                $display("FAIL miss-refill addr=%h data=%h expected_data=%h",
                         addr, read_data, expected_data);
                $finish;
            end
        end
        read_en = 1'b0;
        #9;
    end
    endtask

    task do_write;
        input [31:0] addr;
        input [31:0] data;
    begin
        address = addr;
        write_data = data;
        read_en = 1'b0;
        write_en = 1'b1;
        #10;
        write_en = 1'b0;
    end
    endtask

    initial begin
        clk = 0;
        rst_n = 0;
        read_en = 0;
        write_en = 0;
        address = 32'h0;
        write_data = 32'h0;

        #12;
        rst_n = 1;

        // Preload backing memory with known values after reset, since the slow
        // memory model clears its contents while reset is asserted.
        backing_mem.memory[0] = 32'h11111111; // address 0x00000000
        backing_mem.memory[1] = 32'h22222222; // address 0x00000004
        backing_mem.memory[4] = 32'h33333333; // address 0x00000010, same index as 0x0

        // Miss then hit on same line.
        do_read(32'h00000000, 1'b0, 32'h11111111);
        do_read(32'h00000000, 1'b1, 32'h11111111);

        // Different line, again miss then hit.
        do_read(32'h00000004, 1'b0, 32'h22222222);
        do_read(32'h00000004, 1'b1, 32'h22222222);

        // Conflict miss: address 0x10 maps to the same line index as 0x0.
        do_read(32'h00000010, 1'b0, 32'h33333333);
        do_read(32'h00000010, 1'b1, 32'h33333333);

        // The earlier 0x0 line was evicted, so this should miss again.
        do_read(32'h00000000, 1'b0, 32'h11111111);

        // Write-allocate/write-through: write a value, then read it back as a hit.
        do_write(32'h00000008, 32'hdeadbeef);
        do_read(32'h00000008, 1'b1, 32'hdeadbeef);

        if (hit_count !== 32'd4 || miss_count !== 32'd4) begin
            $display("FAIL counters hits=%0d misses=%0d", hit_count, miss_count);
            $finish;
        end

        if (backing_mem.memory[2] !== 32'hdeadbeef) begin
            $display("FAIL backing memory write-through value=%h", backing_mem.memory[2]);
            $finish;
        end

        $display("PASS data cache");
        $display("cache hits = %0d", hit_count);
        $display("cache misses = %0d", miss_count);
        $finish;
    end

endmodule
