module single_cycle_processor (
    input clk,
    input rst_n
);
    // Internal signals
    wire [31:0] current_pc;
    wire [31:0] next_pc;
    wire [31:0] instruction;
    wire [31:0] reg_data1, reg_data2;
    wire [31:0] mem_read_data;

    // Control signals
    wire reg_write;
    wire mem_to_reg;
    wire mem_write;
    wire alu_src;
    wire [1:0] alu_op;
    wire branch;
    wire bne;
    wire take_branch;
    wire jump;
    wire jalr;
    wire link;

    // internal signals for decoder outputs
    wire [6:0] func7;
    wire [4:0] rd, rs1, rs2;
    wire [6:0] opcode;
    wire [2:0] func3;

    
    // Instantiate components

    decoder dec (
        .instruction(instruction),
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2)
    );

    pc_mux pcm (
        .current_pc(current_pc),
        .branch_target(branch_target),
        .jalr_target(jalr_target),
        .take_branch(take_branch),
        .jump(jump),
        .jalr(jalr),
        .next_pc(next_pc)
    );

    program_counter pc (
        .next_pc(next_pc),
        .clk(clk),
        .rst_n(rst_n),
        .current_pc(current_pc),
        .opcode(opcode)
    );
    
    instr_mem im (
        .address(current_pc),
        .instruction(instruction)
    );
    
    ctrl_unit cu (
        .opcode(opcode),
        .func3(func3),
        .reg_write(reg_write),
        .mem_to_reg(mem_to_reg),
        .mem_write(mem_write),
        .alu_src(alu_src),
        .alu_op(alu_op),
        .branch(branch),
        .bne(bne),
        .jump(jump),
        .jalr(jalr),
        .link(link)
    );
    
    // more internal signals for register file and ALU
    wire [31:0] regfile_mux_out;
    wire [31:0] alu_result;
    wire zero_flag;

    regfile_mux rfm (
        .alu_result(alu_result),
        .mem_data(mem_read_data),
        .pc_plus4(current_pc + 32'd4),
        .mem_to_reg(mem_to_reg),
        .link(link),
        .write_data(regfile_mux_out)
    );

    reg_file rf (
        .rs1(rs1),
        .rs2(rs2),
        .rd(rd),
        .reg_write(reg_write),
        .write_data(regfile_mux_out),
        .reg_data1(reg_data1),
        .reg_data2(reg_data2),
        .clk(clk)
    );

    //internal signals for immediate generator and ALU mux and control
    wire [31:0] imm_data;
    wire [31:0] alu_mux_out;
    wire [3:0] alu_ctrl;
    wire [31:0] jalr_target;


    imm_gen ig (
        .instruction(instruction),
        .immediate(imm_data),
        .opcode(opcode)
    );

    alu_control acu (
        .opcode(opcode),
        .func3(func3),
        .func7(func7),
        .alu_op(alu_op),
        .alu_ctrl(alu_ctrl)
    );
    
    alu_mux am (
        .reg_data(reg_data2),
        .imm_data(imm_data),
        .alu_src(alu_src),
        .alu_mux_out(alu_mux_out)
    );
    
    alu alu_unit (
        .a(reg_data1),
        .b(alu_mux_out),
        .alu_ctrl(alu_ctrl),
        .alu_out(alu_result),
        .zero(zero_flag)
    );
    
    data_mem dm (
        .mem_address(alu_result),
        .write_data(reg_data2),
        .mem_write(mem_write),
        .read_data(mem_read_data),
        .clk(clk)
    );
    
    branching_unit bu (
        .zero(zero_flag),
        .branch(branch),
        .bne(bne),
        .take_branch(take_branch)
    );

    // internal signal for branch target adder
    wire [31:0] branch_target;
    
    branch_target_adder bta (
        .current_pc(current_pc),
        .branch_offset(imm_data),
        .branch_target(branch_target)
    );

    jalr_target_calc jtc (
        .base(reg_data1),
        .offset(imm_data),
        .target(jalr_target)
    );
endmodule
