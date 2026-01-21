module wb_stage (
    input  logic        memtoreg,
    input  logic        jal,
    input  logic [31:0] alu_result,
    input  logic [31:0] mem_data,
    input  logic [31:0] pc_plus4,
    output logic [31:0] wb_data
);
    always_comb begin
        if (jal)
            wb_data = pc_plus4;
        else if (memtoreg)
            wb_data = mem_data;
        else
            wb_data = alu_result;
    end
endmodule
