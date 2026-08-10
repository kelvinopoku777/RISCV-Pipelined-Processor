module testbench;

    reg clk;
    reg rst_n;

    riscv_pipelined_processor dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    initial begin
        $dumpfile("processor.vcd");
        $dumpvars(0, testbench);

        clk = 0;
        rst_n = 0;

        dut.program_counter_inst.current_pc = 32'b0;

        #10;
        rst_n = 1;

        // Recursive factorial still needs a generous simulation window.
        #5000;

        $display("Final PC = %h", dut.current_pc_if);
        $display("Instruction = %h", dut.instruction_if);
        $display("x10/a0 = %h", dut.reg_file_inst.registers[10]);
        $display("data_mem[0] = %h", dut.data_mem_inst.memory[0]);

        $finish;
    end

endmodule
