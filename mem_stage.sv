module mem_stage (
    input  logic        clk,
    input  logic        memread,
    input  logic        memwrite,
    input  logic [31:0] addr,
    input  logic [31:0] wd,
    output logic [31:0] rd
);
    dmem u_dmem (
        .clk      (clk),
        .addr     (addr),
        .wd       (wd),
        .memread  (memread),
        .memwrite (memwrite),
        .rd       (rd)
    );
endmodule
