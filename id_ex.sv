module id_ex (
    input  logic        clk,
    input  logic        reset,
    input  logic        stall,
    input logic         flush,
    // from ID stage (data)
    input  logic [31:0] id_rs1_val,
    input  logic [31:0] id_rs2_val,
    input  logic [31:0] id_imm,
    input  logic [4:0]  id_shamt,
    input  logic [4:0]  id_rs,
    input  logic [4:0]  id_rt,
    input  logic [4:0]  id_rd,

    // from ID stage (control)
    input  logic [3:0]  id_alu_ctrl,
    input  logic        id_alu_src,

    input  logic        id_mem_read,
    input  logic        id_mem_write,

    input  logic        id_reg_write,
    input  logic        id_mem_to_reg,
    input  logic        id_reg_dst,
    input  logic        id_is_branch,
    input  logic        id_is_branch_ne,
    input  logic        id_jump,
    //input  logic        id_is_jr,
    input  logic        id_jal,
    // inputs
    input  logic [31:0] id_pc_plus4,
    output logic [31:0] ex_pc_plus4,

    // to EX stage (data)
    output logic [31:0] ex_rs1_val,
    output logic [31:0] ex_rs2_val,
    output logic [31:0] ex_imm,
    output logic [4:0]  ex_shamt,

    output logic [4:0]  ex_rs,
    output logic [4:0]  ex_rt,
    output logic [4:0]  ex_rd,

    // to EX stage (control)
    output logic [3:0]  ex_alu_ctrl,
    output logic        ex_alu_src,

    output logic        ex_mem_read,
    output logic        ex_mem_write,

    output logic        ex_reg_write,
    output logic        ex_mem_to_reg,
    output logic        ex_reg_dst,
    output logic        ex_is_branch,
    output logic        ex_is_branch_ne,
    output logic        ex_jump,
    //output logic        ex_is_jr,
    output logic        ex_jal
);

    always_ff @(posedge clk or posedge reset) begin

        if (reset) begin
            // 真正的全局复位
            ex_rs1_val    <= 32'b0;
            ex_rs2_val    <= 32'b0;
            ex_imm        <= 32'b0;

            ex_rs         <= 5'b0;
            ex_rt         <= 5'b0;
            ex_rd         <= 5'b0;

            ex_alu_ctrl   <= 4'b0;
            ex_alu_src    <= 1'b0;

            ex_mem_read   <= 1'b0;
            ex_mem_write  <= 1'b0;

            ex_reg_write  <= 1'b0;
            ex_mem_to_reg <= 1'b0;
            ex_reg_dst    <= 1'b0;
            ex_shamt      <= 5'b0;
            ///控制信号
            ex_is_branch    <= 1'b0;
            ex_is_branch_ne <= 1'b0;
            ex_jump         <= 1'b0;
            //ex_is_jr        <= 1'b0;
            ex_jal          <= 1'b0;
            ex_pc_plus4     <= 32'b0;

        end else if (flush) begin
            // 插入 bubble（NOP）
            // 数据无所谓，控制信号必须清零
            ex_alu_ctrl   <= 4'b0;
            ex_alu_src    <= 1'b0;

            ex_mem_read   <= 1'b0;
            ex_mem_write  <= 1'b0;

            ex_reg_write  <= 1'b0;
            ex_mem_to_reg <= 1'b0;
            ex_reg_dst    <= 1'b0;
            ex_shamt      <= 5'b0;
            ex_is_branch    <= 1'b0;
            ex_is_branch_ne <= 1'b0;
            ex_jump         <= 1'b0;
            //ex_is_jr        <= 1'b0;
            ex_jal          <= 1'b0;
            ex_pc_plus4     <= 32'b0;
        end 
        else if (stall) begin
    // 插入 bubble（NOP）
            ex_alu_ctrl   <= 4'b0;
            ex_alu_src    <= 1'b0;

            ex_mem_read   <= 1'b0;   // ⭐ 关键
            ex_mem_write  <= 1'b0;

            ex_reg_write  <= 1'b0;
            ex_mem_to_reg <= 1'b0;
            ex_reg_dst    <= 1'b0;

            ex_is_branch    <= 1'b0;
            ex_is_branch_ne <= 1'b0;
            ex_jump         <= 1'b0;
            //ex_is_jr        <= 1'b0;
            ex_jal          <= 1'b0;

            ex_shamt      <= 5'b0;
            ex_pc_plus4   <= 32'b0;
        end  else begin
            // 正常流水
            ex_rs1_val    <= id_rs1_val;
            ex_rs2_val    <= id_rs2_val;
            ex_imm        <= id_imm;

            ex_rs         <= id_rs;
            ex_rt         <= id_rt;
            ex_rd         <= id_rd;

            ex_alu_ctrl   <= id_alu_ctrl;
            ex_alu_src    <= id_alu_src;

            ex_mem_read   <= id_mem_read;
            ex_mem_write  <= id_mem_write;

            ex_reg_write  <= id_reg_write;
            ex_mem_to_reg <= id_mem_to_reg;
            ex_reg_dst    <= id_reg_dst;
            ex_shamt      <= id_shamt;
            ex_is_branch    <= id_is_branch;
            ex_is_branch_ne <= id_is_branch_ne;
            ex_jump         <= id_jump;
            //ex_is_jr        <= id_is_jr;
            ex_jal          <= id_jal;
            ex_pc_plus4   <= id_pc_plus4;
        end
        $display("[PIPE] id_jal=%b ex_jal=%b",
         id_jal, ex_jal);
    
end

endmodule
