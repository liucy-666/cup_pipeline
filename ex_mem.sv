module ex_mem (
    input  logic        clk,
    input  logic        reset,

    // from EX stage
    input  logic [31:0] ex_alu_result,
    input  logic [31:0] ex_rs2_val,
    input  logic [4:0]  ex_rd,

    input  logic        ex_mem_read,
    input  logic        ex_mem_write,

    input  logic        ex_reg_write,
    input  logic        ex_mem_to_reg,
    input  logic        ex_branch_taken,
    input  logic [31:0] ex_jump_target,
    input  logic        ex_jal,
    input  logic [31:0] ex_pc_plus4,
    // to MEM stage
    output logic [31:0] mem_alu_result,
    output logic [31:0] mem_rs2_val,
    output logic [4:0]  mem_rd,

    output logic        mem_mem_read,
    output logic        mem_mem_write,

    output logic        mem_reg_write,
    output logic        mem_mem_to_reg,
    output logic        mem_branch_taken,
    output logic [31:0] mem_jump_target,
    output logic        mem_jal,
    output logic [31:0] mem_pc_plus4
);
always_ff @(posedge clk or posedge reset)
begin
    if (reset) begin
        mem_alu_result <= 32'b0;
        mem_rs2_val    <= 32'b0;
        mem_rd         <= 5'b0;

        mem_mem_read   <= 1'b0;
        mem_mem_write  <= 1'b0;

        mem_reg_write  <= 1'b0;
        mem_mem_to_reg <= 1'b0;
        mem_branch_taken <= 1'b0;
        mem_jump_target  <= 32'b0;
        mem_jal          <= 1'b0;
        mem_pc_plus4  <= 32'b0;
    end 
    else begin
        mem_alu_result <= ex_alu_result;
        mem_rs2_val    <= ex_rs2_val;
        mem_rd         <= ex_rd;

        mem_mem_read   <= ex_mem_read;
        mem_mem_write  <= ex_mem_write;

        mem_reg_write  <= ex_reg_write;
        mem_mem_to_reg <= ex_mem_to_reg;
        mem_branch_taken <= ex_branch_taken;
        mem_jump_target  <= ex_jump_target;
        mem_jal          <= ex_jal;
        mem_pc_plus4  <= ex_pc_plus4;
    end
end
endmodule