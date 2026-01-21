`timescale 1ns/1ps

module tb_top;

    // =========================
    // 1. 时钟 & 复位
    // =========================
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

    // =========================
    // 2. 实例化 DUT
    // =========================
    top dut (
        .clk   (clk),
        .reset (reset)
    );

    // =========================
    // 3. 波形导出（关键）
    // =========================
    initial begin
        $dumpfile("pipeline_cpu.vcd");
        $dumpvars(0, tb_top);   // dump 整个层级
    end

    // =========================
    // 4. 每拍打印 WB 行为
    // =========================
    initial begin
        $display("time | pc       | RegWrite | rd | wb_data");
        $display("--------------------------------------------");
        $monitor("%4t | %h |     %b     | %2d | %h",
            $time,
            dut.pc,
            dut.wb_reg_write,
            dut.wb_rd,
            dut.wb_wdata
        );
    end

    // =========================
    // 5. 仿真结束后的状态检查
    // =========================
    initial begin
        #500;

        $display("\n====== REGISTER FILE CHECK ======");
        $display("\n====== REGISTER FILE CHECK ======");
        $display("$zero = %0d", dut.u_id.u_regfile.rf[0]);
        $display("$t0   = %0d", dut.u_id.u_regfile.rf[8]);
        $display("$t1   = %0d", dut.u_id.u_regfile.rf[9]);
        $display("$t2   = %0d", dut.u_id.u_regfile.rf[10]);
        $display("$t3   = %0d", dut.u_id.u_regfile.rf[11]);
        $display("$s0   = %0d", dut.u_id.u_regfile.rf[16]);
        $display("$s1   = %0d", dut.u_id.u_regfile.rf[17]);
       

        $display("\n====== DATA MEMORY CHECK ======");
        $display("mem[1] = %0d", dut.u_mem.u_dmem.mem[1]);
        $finish;
    end

endmodule

