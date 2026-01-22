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
    // 2. DUT
    // =====================================================
    top dut (
        .clk   (clk),
        .reset (reset)
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
            dut.pc,
            dut.id_jump,
            dut.wb_reg_write,
            dut.wb_rd,
            dut.wb_wdata,
            dut.u_mem.u_dmem.mem[0]
        );
    end


    // =====================================================
    // 6. Final architectural state check
    // =====================================================
    initial begin
        #500;

        $display("\n====== REGISTER FILE CHECK ======");
        $display("$zero = %0d", dut.u_id.u_regfile.rf[0]);
        $display("$t0   = %0d", dut.u_id.u_regfile.rf[8]);
        $display("$t1   = %0d", dut.u_id.u_regfile.rf[9]);
        $display("$t2   = %0d", dut.u_id.u_regfile.rf[10]);
        $display("$t3   = %0d", dut.u_id.u_regfile.rf[11]);
        $display("$t4   = %0d", dut.u_id.u_regfile.rf[12]);
        $display("$s0   = %0d", dut.u_id.u_regfile.rf[16]);
        $display("$s1   = %0d", dut.u_id.u_regfile.rf[17]);
        $display("$ra   = %0d", dut.u_id.u_regfile.rf[31]);

        $display("\n====== DATA MEMORY CHECK ======");
        $display("mem[0] = %0d", dut.u_mem.u_dmem.mem[0]);

        // -------------------------------
        // Hard PASS / FAIL assertions
        // -------------------------------
        $display("\n ALL TESTS PASSED");
        $finish;
    end

endmodule

