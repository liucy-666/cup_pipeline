module forward_unit (
    input  logic [4:0] idex_rs,
    input  logic [4:0] idex_rt,

    input  logic [4:0] exmem_rd,
    input  logic       exmem_regwrite,

    input  logic [4:0] memwb_rd,
    input  logic       memwb_regwrite,

    output logic [1:0] forwardA,
    output logic [1:0] forwardB
);

always_comb begin
    // 默认：不转发
    forwardA = 2'b00;
    forwardB = 2'b00;

    // EX hazard（优先级最高）
    if (exmem_regwrite && exmem_rd != 0 && exmem_rd == idex_rs)
        forwardA = 2'b10;
    if (exmem_regwrite && exmem_rd != 0 && exmem_rd == idex_rt)
        forwardB = 2'b10;

    // MEM hazard
    if (memwb_regwrite && memwb_rd != 0 &&
        !(exmem_regwrite && exmem_rd != 0 && exmem_rd == idex_rs) &&
        memwb_rd == idex_rs)
        forwardA = 2'b01;

    if (memwb_regwrite && memwb_rd != 0 &&
        !(exmem_regwrite && exmem_rd != 0 && exmem_rd == idex_rt) &&
        memwb_rd == idex_rt)
        forwardB = 2'b01;
end

endmodule
