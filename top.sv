module top (
    input  logic clk,
    input  logic reset,
    ////////输出
    output logic dbg_commit,
    output logic [31:0] dbg_regs [0:31]//寄存器数据输出
);

    /* =======================
       IF stage
    ======================= */
    logic [31:0] pc, pc_next, pc_plus4;
    logic [31:0] instr;
    logic pc_write, ifid_write;

    if_stage u_if (
        .pc    (pc),
        .instr (instr)
    );

    assign pc_plus4 = pc + 4;

    /* =======================
       IF / ID
    ======================= */
    logic [31:0] ifid_instr, ifid_pc4;
    //////////////新增flush控制
    //logic flush;
    logic flush_if_id,flush_id_ex;
    ///////////////////////
    
    if_id u_ifid (
        .clk      (clk),
        .reset    (reset),
        .if_instr (instr),
        .if_pc4   (pc_plus4),
        .stall    (~ifid_write),
        .flush    (flush_if_id ),
        .id_instr (ifid_instr),
        .id_pc4   (ifid_pc4),
        .ex_pc4   ()           // unused
    );

    /* =======================
       ID stage
    ======================= */
    logic [31:0] id_rs_val, id_rt_val, id_imm;
    logic [4:0]  id_rs, id_rt, id_rd, id_shamt;
    logic [31:0] wb_wdata;
    logic wb_mem_to_reg, wb_reg_write;
    logic [4:0] wb_rd;
    logic [31:0] id_jump_target;
    logic        id_jump;
    logic        id_jal;
    logic [4:0] wb_writereg;
    logic wb_jal;
    logic wb_reg_write_final;
    assign wb_writereg = wb_jal ? 5'd31 : wb_rd;
    id_stage u_id (
        .clk          (clk),
        .instr        (ifid_instr),
        .wb_reg_write (wb_reg_write_final),
        //.wb_rd        (wb_rd),
        .wb_waddr     (wb_writereg),
        .wb_wd        (wb_wdata),
        .rs_val       (id_rs_val),
        .rt_val       (id_rt_val),
        .imm_ext      (id_imm),
        .shamt        (id_shamt),
        .rs           (id_rs),
        .rt           (id_rt),
        .rd           (id_rd),
        ////
        .pc_plus4     (ifid_pc4),   
        .jump_target  (id_jump_target),
        .dbg_regs (dbg_regs)
    );

    /* =======================
       Controller
    ======================= */
    logic id_alusrc;
    logic [3:0] id_alu_ctrl;
    logic id_regwrite, id_memwrite, id_memread;
    logic id_memtoreg, id_regdst;
    logic id_is_branch, id_is_branch_ne;
    logic id_is_jr;
    
    controller u_ctrl (
        .instr          (ifid_instr),
        .alusrc         (id_alusrc),
        .alu_ctrl       (id_alu_ctrl),
        .regwrite       (id_regwrite),
        .memwrite       (id_memwrite),
        .memread        (id_memread),
        .memtoreg       (id_memtoreg),
        .regdst         (id_regdst),
        .is_branch      (id_is_branch),
        .is_branch_ne   (id_is_branch_ne),
        .jump           (id_jump),
        .jal            (id_jal), 
        .is_jr          (id_is_jr),
        .is_shift       (),
        .regdst_ra      (),
        .wb_pc_plus4    ()
    );

    /* =======================
       Hazard (load-use only)
    ======================= */
    logic stall;
    logic [4:0] ex_rs, ex_rt;
    logic ex_mem_read;

    hazard_unit u_hazard (
        .idex_memread (ex_mem_read),
        .idex_rt      (ex_rt),
        .ifid_rs      (id_rs),
        .ifid_rt      (id_rt),
        .stall        (stall)
    );

    assign pc_write = ~stall & ~id_is_jr;
    assign ifid_write = ~stall & ~id_is_jr;

    /* =======================
       ID / EX
    ======================= */
    logic [31:0] ex_rs1, ex_rs2, ex_imm;
    logic [4:0]  ex_shamt, ex_rd;
    logic [3:0]  ex_alu_ctrl;
    logic ex_alusrc;
    logic ex_reg_write, ex_mem_to_reg, ex_reg_dst;
    logic ex_is_branch, ex_is_branch_ne;
    logic ex_mem_write;
    logic ex_jal;
    logic [31:0] ex_pc_plus4;
    logic ex_is_jr;
    id_ex u_idex (
        .clk             (clk),
        .reset           (reset),
        .stall           (stall),
        .flush           (flush_id_ex),   
        .id_rs1_val      (id_rs_val),
        .id_rs2_val      (id_rt_val),
        .id_imm          (id_imm),
        .id_shamt        (id_shamt),
        .id_rs           (id_rs),
        .id_rt           (id_rt),
        .id_rd           (id_rd),
        .id_alu_ctrl     (id_alu_ctrl),
        .id_alu_src      (id_alusrc),
        .id_mem_read     (id_memread),
        .id_mem_write    (id_memwrite),
        .id_reg_write    (id_regwrite),
        .id_mem_to_reg   (id_memtoreg),
        .id_reg_dst      (id_regdst),
        .id_is_branch    (id_is_branch),
        .id_is_branch_ne (id_is_branch_ne),
        .id_jump   (id_jump),
        //.id_is_jr  (),
        .id_jal    (id_jal),
        .id_pc_plus4   (ifid_pc4),
        .ex_rs1_val      (ex_rs1),
        .ex_rs2_val      (ex_rs2),
        .ex_imm          (ex_imm),
        .ex_shamt        (ex_shamt),
        .ex_rs           (ex_rs),
        .ex_rt           (ex_rt),
        .ex_rd           (ex_rd),
        .ex_alu_ctrl     (ex_alu_ctrl),
        .ex_alu_src      (ex_alusrc),
        .ex_mem_read     (ex_mem_read),
        .ex_mem_write    (ex_mem_write),
        .ex_reg_write    (ex_reg_write),
        .ex_mem_to_reg   (ex_mem_to_reg),
        .ex_reg_dst      (ex_reg_dst),
        .ex_is_branch    (ex_is_branch),
        .ex_is_branch_ne (ex_is_branch_ne),
        .ex_jump         (),
        //.ex_is_jr        (),
        .ex_jal          (ex_jal),
        .ex_pc_plus4     (ex_pc_plus4)
    );

    /* =======================
       Forwarding
    ======================= */
    logic [1:0] forwardA, forwardB;
    logic [31:0] mem_alu_result;
    logic [4:0]  mem_rd;
    logic mem_reg_write;

    forward_unit u_fwd (
        .idex_rs        (ex_rs),
        .idex_rt        (ex_rt),
        .exmem_rd       (mem_rd),
        .exmem_regwrite (mem_reg_write),
        .memwb_rd       (wb_writereg),
        .memwb_regwrite (wb_reg_write_final),
        .forwardA       (forwardA),
        .forwardB       (forwardB)
    );

    /* =======================
       EX stage
    ======================= */
    logic [31:0] alu_result;
    logic alu_zero;
    logic [4:0] ex_writereg;
    logic ex_branch_taken;
    logic [31:0] ex_branch_target;
    logic [31:0] store_data;
    logic [31:0] ex_rs1_fwd;

    always_comb begin
    case (forwardA)
        2'b00: ex_rs1_fwd = ex_rs1;         // ID/EX.rs1 原值
        2'b10: ex_rs1_fwd = mem_alu_result; // EX/MEM.ALU
        2'b01: ex_rs1_fwd = wb_wdata;       // MEM/WB 写回数据
        default: ex_rs1_fwd = ex_rs1;
    endcase
    end
    
    ex_stage u_ex (
        .rd1            (ex_rs1),
        .rd2            (ex_rs2),
        .imm            (ex_imm),
        .shamt          (ex_shamt),
        .rt             (ex_rt),
        .rd             (ex_rd),
        .alusrc         (ex_alusrc),
        .regdst         (ex_reg_dst),
        .alu_ctrl       (ex_alu_ctrl),
        .forwardA       (forwardA),
        .forwardB       (forwardB),
        .exmem_aluout   (mem_alu_result),
        .memwb_wdata    (wb_wdata),
        .is_branch      (ex_is_branch),
        .is_branch_ne   (ex_is_branch_ne),
        .jump           (1'b0),
        .is_jr          (1'b0),
        .jal            (ex_jal),
        .alu_result     (alu_result),
        .alu_zero       (alu_zero),
        .writereg       (ex_writereg),
        .branch_taken   (ex_branch_taken),
        .jump_target    (ex_branch_target),
        .store_data     (store_data)
    );

    //assign flush = ex_branch_taken | id_jump;

    /* =======================
       EX / MEM
    ======================= */
    logic mem_mem_read, mem_mem_write;
    logic [31:0] mem_rs2_val;
    logic mem_jal;
    logic [31:0] mem_pc_plus4;
    
    ex_mem u_exmem (
    .clk            (clk),
    .reset          (reset),
    .ex_alu_result  (alu_result),
    .ex_rs2_val     (store_data),
    .ex_rd          (ex_writereg),
    .ex_mem_read    (ex_mem_read),
    .ex_mem_write   (ex_mem_write),
    .ex_reg_write   (ex_reg_write),
    .ex_mem_to_reg  (ex_mem_to_reg),
    .ex_branch_taken(ex_branch_taken),
    .ex_jump_target (ex_branch_target),

    // 新增 jal 数据
    .ex_jal         (ex_jal),
    .ex_pc_plus4    (ex_pc_plus4),

    .mem_alu_result (mem_alu_result),
    .mem_rs2_val    (mem_rs2_val),
    .mem_rd         (mem_rd),
    .mem_mem_read   (mem_mem_read),
    .mem_mem_write  (mem_mem_write),
    .mem_reg_write  (mem_reg_write),

    // 新增 jal 输出
    .mem_jal        (mem_jal),
    .mem_pc_plus4   (mem_pc_plus4)
);

    /* =======================
       MEM stage
    ======================= */
    logic [31:0] mem_data;

    mem_stage u_mem (
        .clk      (clk),
        .memread  (mem_mem_read),
        .memwrite (mem_mem_write),
        .addr     (mem_alu_result),
        //.wd       (store_data),
        .wd       (mem_rs2_val),
        .rd       (mem_data),
        .reset    (reset)
    );

    /* =======================
       MEM / WB
    ======================= */
    logic [31:0] wb_mem_data, wb_alu_result;
    logic wb_mem_to_reg, wb_reg_write;
    logic [4:0] wb_rd;
    logic [31:0] wb_pc_plus4;
    mem_wb u_memwb (
    .clk            (clk),
    .reset          (reset),
    .mem_data       (mem_data),
    .mem_alu_result (mem_alu_result),
    .mem_rd         (mem_rd),
    .mem_reg_write  (mem_reg_write),
    .mem_mem_to_reg (mem_mem_to_reg),

    // jal 数据
    .mem_jal        (mem_jal),
    .mem_pc_plus4   (mem_pc_plus4),

    .wb_mem_data    (wb_mem_data),
    .wb_alu_result  (wb_alu_result),
    .wb_rd          (wb_rd),
    .wb_reg_write   (wb_reg_write),
    .wb_mem_to_reg  (wb_mem_to_reg),
    .wb_jal         (wb_jal),
    .wb_pc_plus4    (wb_pc_plus4)
);
    assign wb_reg_write_final = wb_reg_write | wb_jal;

    /* =======================
       WB stage
    ======================= */
   wb_stage u_wb (
        .memtoreg   (wb_mem_to_reg),
        .jal        (wb_jal),
        .alu_result (wb_alu_result),
        .mem_data   (wb_mem_data),
        .pc_plus4   (wb_pc_plus4),
        .wb_data    (wb_wdata)
    );

    /* =======================
       PC register
    ======================= */
    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'b0;
        else if (pc_write)
            pc <= pc_next;
    end

    /* =======================
       PC select
    ======================= */
    always_comb begin
    if (id_is_jr) begin
        pc_next = id_rs_val;
    end else if (ex_branch_taken) begin
        pc_next = ex_branch_target;
    end else if (id_jump) begin
        pc_next = id_jump_target;
    end else begin
        pc_next = pc_plus4;
    end
end


assign flush_if_id = id_jump || id_is_jr || ex_branch_taken;
assign flush_id_ex = ex_branch_taken;


///////
assign dbg_commit = wb_reg_write_final;
endmodule



