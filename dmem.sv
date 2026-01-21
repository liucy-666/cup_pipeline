module dmem (
    input  logic        memread,
    input  logic        clk,
    input  logic        memwrite,
    input  logic [31:0] addr,
    input  logic [31:0] wd,
    output logic [31:0] rd
);
    // 简单数据存储器：256 个 word
    logic [31:0] mem [0:255];

    // 写：同步（sw）
    always_ff @(posedge clk) begin
        if (memwrite)
            mem[addr[9:2]] <= wd;
    end

    // 读：组合（lw）
    always_comb begin
        if (memread)
            rd = mem[addr[9:2]];
        else
            rd = 32'b0;
    end
endmodule

