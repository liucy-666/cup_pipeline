module mem_wb (
    input  logic        clk,
    input  logic        reset,

    // from MEM stage
    input  logic [31:0] mem_data,
    input  logic [31:0] mem_alu_result,
    input  logic [4:0]  mem_rd,

    input  logic        mem_reg_write,
    input  logic        mem_mem_to_reg,
    input  logic        mem_jal,
    input  logic [31:0] mem_pc_plus4,

    // to WB stage
    output logic [31:0] wb_mem_data,
    output logic [31:0] wb_alu_result,
    output logic [4:0]  wb_rd,
    output logic        wb_reg_write,
    output logic        wb_mem_to_reg,
    output logic        wb_jal,
    output logic [31:0] wb_pc_plus4,

    // new signals for jal handling
    output logic [4:0]  wb_writereg,          // 实际写回寄存器
    output logic        wb_reg_write_final    // 实际写回使能
);

always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
        wb_mem_data    <= 32'b0;
        wb_alu_result  <= 32'b0;
        wb_rd          <= 5'b0;
        wb_reg_write   <= 1'b0;
        wb_mem_to_reg  <= 1'b0;
        wb_jal         <= 1'b0;
        wb_pc_plus4    <= 32'b0;
        wb_writereg    <= 5'b0;
        wb_reg_write_final <= 1'b0;
    end else begin
        wb_mem_data    <= mem_data;
        wb_alu_result  <= mem_alu_result;
        wb_rd          <= mem_rd;
        wb_reg_write   <= mem_reg_write;
        wb_mem_to_reg  <= mem_mem_to_reg;
        wb_jal         <= mem_jal;
        wb_pc_plus4    <= mem_pc_plus4;

        // -------------------------------
        // jal 写回处理
        wb_writereg        <= mem_jal ? 5'd31 : mem_rd;
        wb_reg_write_final  <= mem_reg_write | mem_jal;
    end
end
endmodule

