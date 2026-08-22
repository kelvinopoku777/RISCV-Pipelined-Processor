module testbench_pipeline_features;

    reg clk;
    reg rst_n;
    integer i;

    riscv_pipelined_processor dut (
        .clk(clk),
        .rst_n(rst_n)
    );

    always #5 clk = ~clk;

    task clear_state;
    begin
        for (i = 0; i < 256; i = i + 1) begin
            dut.instr_mem_inst.rom[i] = 32'h00000013;
            dut.data_mem_inst.memory[i] = 32'h0;
        end

        for (i = 0; i < 32; i = i + 1) begin
            dut.reg_file_inst.registers[i] = 32'h0;
        end
    end
    endtask

    task reset_dut;
    begin
        rst_n = 0;
        dut.program_counter_inst.current_pc = 32'h0;
        #12;
        rst_n = 1;
    end
    endtask

    initial begin
        clk = 0;

        // Test 1: load-use stall plus EX/MEM and MEM/WB forwarding.
        clear_state();
        dut.instr_mem_inst.rom[0] = 32'h00002283; // lw x5, 0(x0)
        dut.instr_mem_inst.rom[1] = 32'h00528333; // add x6, x5, x5
        dut.instr_mem_inst.rom[2] = 32'h005303b3; // add x7, x6, x5
        dut.instr_mem_inst.rom[3] = 32'h0000007f; // halt

        reset_dut();
        dut.data_mem_inst.memory[0] = 32'd11;
        // The blocking cache now waits for the slow backing memory refill,
        // so give the dependent forwarded result enough time to reach WB.
        #140;

        if (dut.reg_file_inst.registers[6] !== 32'd22 ||
            dut.reg_file_inst.registers[7] !== 32'd33) begin
            $display("FAIL forwarding/stall: x6=%0d x7=%0d",
                     dut.reg_file_inst.registers[6],
                     dut.reg_file_inst.registers[7]);
            $finish;
        end

        // Test 2: flush wrong-path instructions after jal and taken beq.
        clear_state();
        dut.instr_mem_inst.rom[0] = 32'h00100293; // addi x5, x0, 1
        dut.instr_mem_inst.rom[1] = 32'h00c000ef; // jal x1, target
        dut.instr_mem_inst.rom[2] = 32'h06300293; // addi x5, x0, 99 (must flush)
        dut.instr_mem_inst.rom[3] = 32'h04d00313; // addi x6, x0, 77 (must flush)
        dut.instr_mem_inst.rom[4] = 32'h005283b3; // target: add x7, x5, x5
        dut.instr_mem_inst.rom[5] = 32'h00000463; // beq x0, x0, +8
        dut.instr_mem_inst.rom[6] = 32'h03700413; // addi x8, x0, 55 (must flush)
        dut.instr_mem_inst.rom[7] = 32'h0000007f; // halt

        reset_dut();
        #140;

        if (dut.reg_file_inst.registers[5] !== 32'd1 ||
            dut.reg_file_inst.registers[6] !== 32'd0 ||
            dut.reg_file_inst.registers[7] !== 32'd2 ||
            dut.reg_file_inst.registers[8] !== 32'd0 ||
            dut.reg_file_inst.registers[1] !== 32'd8) begin
            $display("FAIL flushing: x1=%0d x5=%0d x6=%0d x7=%0d x8=%0d",
                     dut.reg_file_inst.registers[1],
                     dut.reg_file_inst.registers[5],
                     dut.reg_file_inst.registers[6],
                     dut.reg_file_inst.registers[7],
                     dut.reg_file_inst.registers[8]);
            $finish;
        end

        $display("PASS pipeline features");
        $finish;
    end

endmodule
