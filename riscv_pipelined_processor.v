module riscv_pipelined_processor (
    input clk,
    input rst_n
);
    // INSTRUCTION FETCH STAGE
    // Internal signals
    wire [31:0] current_pc_if;
    wire [31:0] next_pc;
    wire [31:0] instruction_if;
    wire [31:0] instruction_wb;
    wire halt_wb;
    // internal signals for instruction fetch stage

    instr_mem instr_mem_inst (
        .address(current_pc_if),
        .instruction(instruction_if)
    );

    halt_detector halt_detector_inst (
        .instruction(instruction_wb),
        .halt(halt_wb)
    );

    // program counter instance
    program_counter program_counter_inst (
        .clk(clk),
        .rst_n(rst_n),
        .next_pc(next_pc),
        .stall(stall_pc),
        .current_pc(current_pc_if),
        // Only stop once a halt has reached the committed side of the pipe.
        .halt(halt_wb)
    );

    // IF/ID pipeline register
    // internal signals for if/id pipeline register
    wire [31:0] instruction_id;
    wire [31:0] current_pc_id;

    if_id if_id_inst (
        .instruction_in(instruction_if),
        .instruction_out(instruction_id),
        .clk(clk),
        .rst_n(rst_n),
        .stall(stall_if_id),
        .flush(flush_if_id),
        .pc_in(current_pc_if),
        .pc_out(current_pc_id)
    );

    // INSTRUCTION DECODE STAGE
    // Internal signals for instruction decode stage
    // decoder outputs
    wire [6:0] opcode_id;
    wire [2:0] func3_id;
    wire [6:0] func7_id;
    wire [4:0] rd_id;
    wire [4:0] rs1_id;
    wire [4:0] rs2_id;

    decoder decoder_inst (
        .instruction(instruction_id),
        .opcode(opcode_id),
        .func3(func3_id),
        .func7(func7_id),
        .rd(rd_id),
        .rs1(rs1_id),
        .rs2(rs2_id)
    );

    // signals for immediate generator
    wire [31:0] imm_id;

    imm_gen imm_gen_inst (
        .opcode(opcode_id),
        .instruction(instruction_id),
        .immediate(imm_id)
    );

    // signals for control unit
    wire reg_write_id;
    wire mem_to_reg_id;
    wire mem_write_id;
    wire alu_src_id;
    wire [1:0] alu_op_id;
    wire branch_id;
    wire bne_id;
    wire jump_id;
    wire jalr_id;
    wire link_id;

    ctrl_unit ctrl_unit_inst (
        .opcode(opcode_id),
        .reg_write(reg_write_id),
        .mem_to_reg(mem_to_reg_id),
        .mem_write(mem_write_id),
        .alu_src(alu_src_id),
        .alu_op(alu_op_id),
        .branch(branch_id),
        .bne(bne_id),
        .jump(jump_id),
        .jalr(jalr_id),
        .link(link_id),
        .func3(func3_id)
    );

    // signals for register file
    wire [31:0] reg_data1_id;
    wire [31:0] reg_data2_id;
    wire [31:0] write_back_data_wb;
    wire [4:0] rd_wb;
    wire reg_write_wb;

    // Hazard management
    wire stall_pc;
    wire stall_if_id;
    wire flush_if_id;
    wire flush_id_ex;
    wire flush_ex_mem;

    reg_file reg_file_inst (
        .clk(clk),
        .rs1(rs1_id),
        .rs2(rs2_id),
        .rd(rd_wb),
        .reg_write(reg_write_wb),
        .write_data(write_back_data_wb),
        .reg_data1(reg_data1_id),
        .reg_data2(reg_data2_id)
    );

    // ID/EX pipeline register
    // internal signals for id/ex pipeline register
    wire [31:0] instruction_ex;
    wire [31:0] current_pc_ex;
    wire [6:0] opcode_ex;
    wire [2:0] func3_ex;
    wire [6:0] func7_ex;
    wire [4:0] rd_ex;
    wire [4:0] rs1_ex;
    wire [4:0] rs2_ex;
    wire [31:0] imm_ex;
    wire reg_write_ex;
    wire mem_to_reg_ex;
    wire mem_write_ex;
    wire alu_src_ex;
    wire [1:0] alu_op_ex;
    wire branch_ex;
    wire bne_ex;
    wire jump_ex;
    wire jalr_ex;
    wire link_ex;
    wire [31:0] reg_data1_ex;
    wire [31:0] reg_data2_ex;

    id_ex id_ex_inst (
        .instruction_in(instruction_id),
        .instruction_out(instruction_ex),
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_id_ex),
        .pc_in(current_pc_id),
        .pc_out(current_pc_ex),
        .opcode_in(opcode_id),
        .opcode_out(opcode_ex),
        .func3_in(func3_id),
        .func3_out(func3_ex),
        .func7_in(func7_id),
        .func7_out(func7_ex),
        .rd_in(rd_id),
        .rd_out(rd_ex),
        .rs1_in(rs1_id),
        .rs1_out(rs1_ex),
        .rs2_in(rs2_id),
        .rs2_out(rs2_ex),
        .immediate_in(imm_id),
        .immediate_out(imm_ex),
        .reg_write_in(reg_write_id),
        .reg_write_out(reg_write_ex),
        .mem_to_reg_in(mem_to_reg_id),
        .mem_to_reg_out(mem_to_reg_ex),
        .mem_write_in(mem_write_id),
        .mem_write_out(mem_write_ex),
        .alu_src_in(alu_src_id),
        .alu_src_out(alu_src_ex),
        .alu_op_in(alu_op_id),
        .alu_op_out(alu_op_ex),
        .branch_in(branch_id),
        .branch_out(branch_ex),
        .bne_in(bne_id),
        .bne_out(bne_ex),
        .jump_in(jump_id),
        .jump_out(jump_ex),
        .jalr_in(jalr_id),
        .jalr_out(jalr_ex),
        .link_in(link_id),
        .link_out(link_ex),
        .reg_data1_in(reg_data1_id),
        .reg_data1_out(reg_data1_ex),
        .reg_data2_in(reg_data2_id),
        .reg_data2_out(reg_data2_ex)
    );

    // EXECUTE STAGE

    // signals for alu control unit
    wire [3:0] alu_control_ex;
    
    alu_control alu_control_inst (
        .opcode(opcode_ex),
        .func3(func3_ex),
        .func7(func7_ex),
        .alu_ctrl(alu_control_ex),
        .alu_op(alu_op_ex)
    );

    // signals for alu mux
    wire [31:0] alu_mux_out_ex;
    wire [31:0] forwarded_reg_data1_ex;
    wire [31:0] forwarded_reg_data2_ex;
    wire [1:0] forward_a;
    wire [1:0] forward_b;
    wire [31:0] ex_mem_forward_data;
    wire [31:0] current_pc_mem_plus4;

    forwarding_unit forwarding_unit_inst (
        .rs1_ex(rs1_ex),
        .rs2_ex(rs2_ex),
        .rd_mem(rd_mem),
        .rd_wb(rd_wb),
        .reg_write_mem(reg_write_mem),
        .reg_write_wb(reg_write_wb),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );

    pc_plus4_calc current_pc_mem_plus4_inst (
        .pc_in(current_pc_mem),
        .pc_plus4(current_pc_mem_plus4)
    );

    ex_mem_forward_mux ex_mem_forward_mux_inst (
        .alu_out_mem(alu_out_mem),
        .pc_plus4_mem(current_pc_mem_plus4),
        .link_mem(link_mem),
        .ex_mem_forward_data(ex_mem_forward_data)
    );

    forwarding_mux_A forwarding_mux_A_inst (
        .reg_data1_ex(reg_data1_ex),
        .ex_mem_data(ex_mem_forward_data),
        .mem_wb_data(write_back_data_wb),
        .forward_a(forward_a),
        .forwarded_data_a(forwarded_reg_data1_ex)
    );

    forwarding_mux_B forwarding_mux_B_inst (
        .reg_data2_ex(reg_data2_ex),
        .ex_mem_data(ex_mem_forward_data),
        .mem_wb_data(write_back_data_wb),
        .forward_b(forward_b),
        .forwarded_data_b(forwarded_reg_data2_ex)
    );

    alu_mux alu_mux_inst (
        .reg_data(forwarded_reg_data2_ex),
        .imm_data(imm_ex),
        .alu_src(alu_src_ex),
        .alu_mux_out(alu_mux_out_ex)
    );

    // signals for alu
    wire [31:0] alu_out_ex;
    wire zero_ex;

    alu alu_inst (
        .a(forwarded_reg_data1_ex),
        .b(alu_mux_out_ex),
        .alu_ctrl(alu_control_ex),
        .alu_out(alu_out_ex),
        .zero(zero_ex)
    );

    // signals for jalr target calculation
    wire [31:0] jalr_target_ex;

    jalr_target_calc jalr_target_calc_inst (
        .base(forwarded_reg_data1_ex),
        .offset(imm_ex),
        .target(jalr_target_ex)
    );

    // signals for branch target calculation
    wire [31:0] branch_target_ex;

    branch_target_adder branch_target_calc_inst (
        .current_pc(current_pc_ex),
        .branch_offset(imm_ex),
        .branch_target(branch_target_ex)
    );

    // EX/MEM pipeline register
    // internal signals for ex/mem pipeline register
    wire [31:0] instruction_mem;
    wire [31:0] current_pc_mem;
    wire reg_write_mem;
    wire mem_to_reg_mem;
    wire mem_write_mem;
    wire branch_mem;
    wire bne_mem;
    wire jump_mem;
    wire jalr_mem;
    wire link_mem;
    wire [31:0] alu_out_mem;
    wire zero_mem;
    wire [31:0] reg_data2_mem;
    wire [31:0] branch_target_mem;
    wire [31:0] jalr_target_mem;
    wire [4:0] rd_mem;

    ex_mem ex_mem_inst (
        .instruction_in(instruction_ex),
        .instruction_out(instruction_mem),
        .clk(clk),
        .rst_n(rst_n),
        .flush(flush_ex_mem),
        .pc_in(current_pc_ex),
        .pc_out(current_pc_mem),
        .reg_write_in(reg_write_ex),
        .reg_write_out(reg_write_mem),
        .mem_to_reg_in(mem_to_reg_ex),
        .mem_to_reg_out(mem_to_reg_mem),
        .mem_write_in(mem_write_ex),
        .mem_write_out(mem_write_mem),
        .branch_in(branch_ex),
        .branch_out(branch_mem),
        .bne_in(bne_ex),
        .bne_out(bne_mem),
        .jump_in(jump_ex),
        .jump_out(jump_mem),
        .jalr_in(jalr_ex),
        .jalr_out(jalr_mem),
        .link_in(link_ex),
        .link_out(link_mem),
        .alu_out_in(alu_out_ex),
        .alu_out_out(alu_out_mem),
        .zero_in(zero_ex),
        .zero_out(zero_mem),
        .reg_data2_in(forwarded_reg_data2_ex),
        .reg_data2_out(reg_data2_mem),
        .branch_target_in(branch_target_ex),
        .branch_target_out(branch_target_mem),
        .jalr_target_in(jalr_target_ex),
        .jalr_target_out(jalr_target_mem),
        .rd_in(rd_ex),
        .rd_out(rd_mem)
    );

    // MEMORY ACCESS STAGE
    // signals for data memory
    wire [31:0] mem_read_data_mem;

    data_mem data_mem_inst (
        .mem_address(alu_out_mem),
        .write_data(reg_data2_mem),
        .mem_write(mem_write_mem),
        .read_data(mem_read_data_mem),
        .clk(clk)
    );

    // branching unit instance
    wire take_branch_mem;

    branching_unit branching_unit_inst (
        .zero(zero_mem),
        .branch(branch_mem),
        .bne(bne_mem),
        .take_branch(take_branch_mem)
    );

    hazard_unit hazard_unit_inst (
        .rs1_id(rs1_id),
        .rs2_id(rs2_id),
        .rd_ex(rd_ex),
        .mem_to_reg_ex(mem_to_reg_ex),
        .reg_write_ex(reg_write_ex),
        .take_branch_mem(take_branch_mem),
        .jump_mem(jump_mem),
        .jalr_mem(jalr_mem),
        .stall_pc(stall_pc),
        .stall_if_id(stall_if_id),
        .flush_if_id(flush_if_id),
        .flush_id_ex(flush_id_ex),
        .flush_ex_mem(flush_ex_mem)
    );

    // signals for pc mux
    pc_mux pc_mux_inst (
        // Use the fetch-stage PC for normal sequential flow; branch/jump
        // targets still come from MEM because control resolves there today.
        .current_pc(current_pc_if),
        .branch_target(branch_target_mem),
        .jalr_target(jalr_target_mem),
        .jump(jump_mem),
        .jalr(jalr_mem),
        .take_branch(take_branch_mem),
        .next_pc(next_pc)
    );

    // MEM/WB pipeline register
    // internal signals for mem/wb pipeline register
    wire [31:0] current_pc_wb;
    wire [31:0] current_pc_wb_plus4;
    wire mem_to_reg_wb;
    wire link_wb;
    wire [31:0] alu_out_wb;
    wire [31:0] mem_read_data_wb;

    mem_wb mem_wb_inst (
        .instruction_in(instruction_mem),
        .instruction_out(instruction_wb),
        .clk(clk),
        .rst_n(rst_n),
        .pc_in(current_pc_mem),
        .pc_out(current_pc_wb),
        .rd_in(rd_mem),
        .rd_out(rd_wb),
        .reg_write_in(reg_write_mem),
        .reg_write_out(reg_write_wb),
        .mem_to_reg_in(mem_to_reg_mem),
        .mem_to_reg_out(mem_to_reg_wb),
        .link_in(link_mem),
        .link_out(link_wb),
        .alu_out_in(alu_out_mem),
        .alu_out_out(alu_out_wb),
        .mem_read_data_in(mem_read_data_mem),
        .mem_read_data_out(mem_read_data_wb)
    );

    pc_plus4_calc current_pc_wb_plus4_inst (
        .pc_in(current_pc_wb),
        .pc_plus4(current_pc_wb_plus4)
    );

    // WRITE BACK STAGE

    regfile_mux regfile_mux_inst (
        .alu_result(alu_out_wb),
        .mem_data(mem_read_data_wb),
        .mem_to_reg(mem_to_reg_wb),
        .link(link_wb),
        .pc_plus4(current_pc_wb_plus4),
        .write_data(write_back_data_wb)
    );
endmodule
