module data_cache (
    input clk,
    input rst_n,
    input cpu_read_en,
    input cpu_write_en,
    input [31:0] cpu_address,
    input [31:0] cpu_write_data,
    input [31:0] mem_read_data,
    input mem_ready,
    output reg [31:0] cpu_read_data,
    output reg cpu_ready,
    output reg cache_hit,
    output reg [31:0] hit_count,
    output reg [31:0] miss_count,
    output reg mem_read_en,
    output mem_write_en,
    output reg [31:0] mem_address,
    output [31:0] mem_write_data
);
    localparam NUM_LINES = 4;
    localparam STATE_IDLE = 1'b0;
    localparam STATE_REFILL = 1'b1;

    reg [31:0] data_array [0:NUM_LINES-1];
    reg [27:0] tag_array [0:NUM_LINES-1];
    reg valid_array [0:NUM_LINES-1];

    reg state;
    reg [31:0] miss_address;
    reg [1:0] miss_line_index;
    reg [27:0] miss_tag;

    wire [1:0] line_index;
    wire [27:0] address_tag;
    wire line_hit;
    wire request_fire;
    integer i;

    assign line_index = cpu_address[3:2];
    assign address_tag = cpu_address[31:4];
    assign line_hit = valid_array[line_index] && (tag_array[line_index] == address_tag);
    assign request_fire = cpu_read_en || cpu_write_en;

    assign mem_write_en = cpu_write_en;
    assign mem_write_data = cpu_write_data;

    always @(*) begin
        cpu_read_data = 32'h0;
        cpu_ready = 1'b1;
        cache_hit = 1'b0;
        mem_read_en = 1'b0;
        mem_address = cpu_address;

        case (state)
            STATE_IDLE: begin
                cache_hit = line_hit;
                if (cpu_read_en) begin
                    if (line_hit) begin
                        cpu_read_data = data_array[line_index];
                    end else begin
                        // Start the backing-memory read after the miss has been
                        // registered. This avoids a new miss observing the
                        // previous refill's ready/data pulse.
                        cpu_ready = 1'b0;
                    end
                end
            end

            STATE_REFILL: begin
                cpu_ready = 1'b0;
                mem_read_en = 1'b1;
                mem_address = miss_address;
                if (mem_ready) begin
                    cpu_read_data = mem_read_data;
                end
            end
        endcase
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= STATE_IDLE;
            miss_address <= 32'h0;
            miss_line_index <= 2'h0;
            miss_tag <= 28'h0;
            hit_count <= 32'h0;
            miss_count <= 32'h0;
            for (i = 0; i < NUM_LINES; i = i + 1) begin
                data_array[i] <= 32'h0;
                tag_array[i] <= 28'h0;
                valid_array[i] <= 1'b0;
            end
        end else begin
            case (state)
                STATE_IDLE: begin
                    if (cpu_write_en) begin
                        // Write-through, write-allocate keeps stores coherent
                        // without requiring a dirty/write-back path.
                        data_array[line_index] <= cpu_write_data;
                        tag_array[line_index] <= address_tag;
                        valid_array[line_index] <= 1'b1;
                    end

                    if (request_fire && cpu_read_en) begin
                        if (line_hit) begin
                            hit_count <= hit_count + 32'd1;
                        end else begin
                            miss_count <= miss_count + 32'd1;
                            miss_address <= cpu_address;
                            miss_line_index <= line_index;
                            miss_tag <= address_tag;
                            state <= STATE_REFILL;
                        end
                    end
                end

                STATE_REFILL: begin
                    if (mem_ready) begin
                        data_array[miss_line_index] <= mem_read_data;
                        tag_array[miss_line_index] <= miss_tag;
                        valid_array[miss_line_index] <= 1'b1;
                        state <= STATE_IDLE;
                    end
                end
            endcase
        end
    end
endmodule
