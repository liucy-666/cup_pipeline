module dmem (
    input  logic        memread,
    input  logic        clk,
    input  logic        reset,
    input  logic        memwrite,
    input  logic [31:0] addr,
    input  logic [31:0] wd,
    output logic [31:0] rd
);
    // 简单数据存储器：256 个 word
    logic [31:0] mem [0:255];
    ///初始化；
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            // 复位时初始化所有存储单元
            for (int i = 0; i < 256; i++) begin
                mem[i] <= 32'b0; // 或者其他初始值
            end
        end else if (memwrite) begin
            mem[addr[9:2]] <= wd;
        end
    end

    // 写：同步（sw）
    always_ff @(posedge clk) begin
        if (memwrite)
            mem[addr[9:2]] <= wd;
        if (memread) begin
        $display("[DMEM][%0t] LW  addr=%h rd=%h",
                 $time, addr, rd);
        end
    end

    // 读：组合（lw）
    always_comb begin
        if (memread)
            rd = mem[addr[9:2]];
        else
            rd = 32'b0;
        if (memread) begin
        $display("[DMEM][%0t] LW  addr=%h rd=%h",
                 $time, addr, rd);
        end
    end
    

endmodule

