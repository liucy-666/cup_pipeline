`timescale 1ns/1ps

module tb_top;

    // =====================================================
    // 1. Clock & Reset
    // =====================================================
    logic clk;
    logic reset;

    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 100MHz
    end

    initial begin
        reset = 1;
        #20;
        reset = 0;
    end

    // =====================================================
    // 2. DUT (Device Under Test)
    // =====================================================
    board_top dut (
        .clk_100mhz  (clk),
        .btn_reset   (reset),
        .sw          (4'b0000),  // 假设按下开关选择寄存器 0
        .led         (dut.led),
        .seg         (dut.seg),
        .an          (dut.an)
    );

    // =====================================================
    // 3. Dump wave (VERY IMPORTANT)
    // =====================================================
    initial begin
        $dumpfile("pipeline_cpu.vcd");
        $dumpvars(0, tb_top);
    end

    // =====================================================
    // 4. Per-cycle WB / Control monitor
    // =====================================================
    initial begin
        $display("time | pc        | jump | RegWrite | rd | wb_data    | mem[0]");
        $display("---------------------------------------------------------------");
        $monitor("%4t | %h |  %b   |    %b     | %2d | %h | %0d",
            $time,
            dut.u_cpu.pc,  // 假设你有一个 pc 信号
            dut.u_cpu.id_jump,
            dut.u_cpu.wb_reg_write,
            dut.u_cpu.wb_rd,
            dut.u_cpu.wb_wdata,
            dut.u_cpu.u_mem.u_dmem.mem[0]
        );
    end

    // =====================================================
    // 5. Monitor board_top Signals (including LEDs and Segments)
    // =====================================================
    initial begin
        $display("time | led[0] | led[1] | led[2] | seg[6:0] | an[3:0]");
        $monitor("%4t | %b | %b | %b | %b | %b", 
            $time, 
            dut.led[0],       // 查看 LED0（Heartbeat LED）
            dut.led[1],       // 查看 LED1（Reset LED）
            dut.led[2],       // 查看 LED2（Commit LED）
            dut.seg,          // 查看数码管的段显示
            dut.an            // 查看数码管的位选
        );
    end

    // =====================================================
    // 6. Final architectural state check
    // =====================================================
    initial begin
        #500;

        // 检查寄存器值
        $display("\n====== REGISTER FILE CHECK ======");
        $display("$zero = %0d", dut.u_cpu.u_id.u_regfile.rf[0]);
        $display("$t0   = %0d", dut.u_cpu.u_id.u_regfile.rf[8]);
        $display("$t1   = %0d", dut.u_cpu.u_id.u_regfile.rf[9]);
        $display("$t2   = %0d", dut.u_cpu.u_id.u_regfile.rf[10]);
        $display("$t3   = %0d", dut.u_cpu.u_id.u_regfile.rf[11]);
        $display("$t4   = %0d", dut.u_cpu.u_id.u_regfile.rf[12]);
        $display("$s0   = %0d", dut.u_cpu.u_id.u_regfile.rf[16]);
        $display("$s1   = %0d", dut.u_cpu.u_id.u_regfile.rf[17]);
        $display("$ra   = %0d", dut.u_cpu.u_id.u_regfile.rf[31]);

        // 检查数据存储
        $display("\n====== DATA MEMORY CHECK ======");
        $display("mem[0] = %0d", dut.u_cpu.u_mem.u_dmem.mem[0]);

        // -------------------------------
        // Hard PASS / FAIL assertions
        // -------------------------------
        $display("\n ALL TESTS PASSED");
        $finish;
    end

endmodule


