//拿AI写了一个imem用于测试功能
module imem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] mem [0:255];

initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000000;

        // =====================================================
        // 测试程序（MIPS）
        // =====================================================
        // 地址 = PC >> 2

        // 0x0000
        // addi $t0, $zero, 5
        mem[0]  = 32'h20080005;

        // addi $t1, $zero, 10
        mem[1]  = 32'h2009000A;

        // add  $t2, $t0, $t1   ; forwarding EX→EX
        mem[2]  = 32'h01095020;

        // sw   $t2, 0($zero)
        mem[3]  = 32'hAC0A0000;

        // lw   $t3, 0($zero)
        mem[4]  = 32'h8C0B0000;

        // add  $t4, $t3, $t0   ; load-use hazard（必须 stall）
        mem[5]  = 32'h01686020;

        // =====================================================
        // 分支测试
        // =====================================================

        // beq  $t4, $t2, label_equal
        mem[6]  = 32'h118A0002;

        // addi $t5, $zero, 1   ; 不应执行
        mem[7]  = 32'h200D0001;

        // addi $t5, $zero, 2   ; label_equal
        mem[8]  = 32'h200D0002;

        // =====================================================
        // jal / jr 测试
        // =====================================================

        // jal  func
        mem[9]  = 32'h0C00000C;   // 跳到 mem[12]

        // addi $t6, $zero, 99  ; jal 返回后执行
        mem[10] = 32'h200E0063;

        // nop
        mem[11] = 32'h00000000;

        // ---------- func ----------
        // addi $t7, $zero, 7
        mem[12] = 32'h200F0007;

        // jr   $ra
        mem[13] = 32'h03E00008;
    end

    // 指令取值（word aligned）
    assign instr = mem[addr[9:2]];

endmodule
