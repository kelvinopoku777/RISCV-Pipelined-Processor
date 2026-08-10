/* this module is responsible for updating the program 
 * counter (PC) based on the next PC value calculated in the execute stage.
 * It also handles reset and halt conditions.
 */
module program_counter (
    input [31:0] next_pc,
    input clk,
    input rst_n,
    input stall,
    output reg [31:0] current_pc,
    input halt
);
    reg halted;

    always @(posedge clk) begin
        if (!rst_n) begin
            current_pc <= 32'b0;
            halted <= 1'b0;
        end else if (halted) begin
            current_pc <= current_pc;
            halted <= halted;
        end else if (stall) begin
            current_pc <= current_pc;
            halted <= halted;
        end else if (halt) begin
            current_pc <= current_pc;
            halted <= 1'b1;
        end else begin
            current_pc <= next_pc; // Update PC on clock edge
            halted <= 1'b0;
        end
    end
    
endmodule
