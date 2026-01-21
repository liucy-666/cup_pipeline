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
        // lw  $t0, 0($zero)
        mem[0] = 32'h8c080000;
        // add $t1, $t0, $t0   -> 10
        mem[1] = 32'h01084820;
        // add $t2, $t0, $t0   -> 10
        mem[2] = 32'h01085020;
        // addi $t3, $zero, 3
        mem[3] = 32'h200b0003;
        // andi $t4, $t3, 1   -> 1
        mem[4] = 32'h316c0001;
        // ori  $t5, $t3, 2   -> 3
        mem[5] = 32'h356d0002;

        // xor  $t6, $t4, $t5 -> 2
        mem[6] = 32'h018d7026;
        // lui $t7, 0x1234 -> 0x12340000
        mem[7] = 32'h3c0f1234;
        // slt $s0, $t4, $t5  (1 < 3) -> 1
        mem[8] = 32'h018d802a;
        // beq $s0, $t4, +1
        mem[9] = 32'h120c0001;
        // addi $s1, $zero, 99
        mem[10] = 32'h20110063;
        // addi $s1, $zero, 7
        mem[11] = 32'h20110007;
        // sw $s1, 4($zero)
        mem[12] = 32'hac110004;
        // lw $s2, 4($zero)
        mem[13] = 32'h8c120004;
        // addi $t0, $zero, 1
        mem[14] = 32'h20080001;
        // j target (target = mem[17])
        mem[15] = 32'h08000011;
        // addi $t0, $zero, 99
        mem[16] = 32'h20080063;
        // addi $t1, $zero, 7
        mem[17] = 32'h20090007;
        mem[18] = 32'h20080005; // addi $t0, $zero, 5
        mem[19] = 32'h0c000016; // jal func (func = 22)
        mem[20] = 32'h20090063; // addi $t1, 99  (❌ should flush)
        mem[21] = 32'h200a0007; // addi $t2, 7   (return 后执行)

        // func:
        mem[22] = 32'h200b002a; // addi $t3, 42
        mem[23] = 32'h03e00008; // jr $ra
        mem[24] = 32'h200c0058; // addi $t4, 88 (❌ should flush)
    end

    // 指令取值（word aligned）
    assign instr = mem[addr[9:2]];

endmodule
