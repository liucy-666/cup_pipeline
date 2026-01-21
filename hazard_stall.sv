module hazard_unit (
    input  logic        idex_memread,   // EX 阶段是 lw
    input  logic [4:0]  idex_rt,          // lw 的目的寄存器
    input  logic [4:0]  ifid_rs,
    input  logic [4:0]  ifid_rt,

    output logic        stall
);
    assign stall =
        idex_memread &&
        ((idex_rt == ifid_rs) || (idex_rt == ifid_rt)) &&
        (idex_rt != 0);
endmodule
