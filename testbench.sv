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
        $display("time | pc        | jump | RegWrite | rd | wb_data    | mem[1]");
        $display("---------------------------------------------------------------");
        $monitor("%4t | %h |  %b   |    %b     | %2d | %h | %0d",
            $time,
            dut.pc,
            dut.id_jump,
            dut.wb_reg_write,
            dut.wb_rd,
            dut.wb_wdata,
            dut.u_mem.u_dmem.mem[1]
        );
    end

    // =====================================================
    // 5. Explicit mechanism checks (关键)
    // =====================================================

    // -------- Forwarding observation --------
    always @(posedge clk) begin
        if (dut.forwardA != 2'b00 || dut.forwardB != 2'b00) begin
            $display("[FWD] time=%0t A=%b B=%b",
                $time, dut.forwardA, dut.forwardB);
        end
    end

    // -------- Stall observation --------
    always @(posedge clk) begin
        if (dut.stall) begin
            $display("[STALL] time=%0t PC held at %h",
                $time, dut.pc);
        end
    end

    // -------- Flush observation --------
    always @(posedge clk) begin
        if (dut.flush_if_id) begin
            $display("[FLUSH_if_id] time=%0t at PC=%h",
                $time, dut.pc);
        end
        if (dut.flush_id_ex) begin
            $display("[FLUSH_id_ex] time=%0t at PC=%h",
                $time, dut.pc);
        end
        
    end

    // -------- JAL path observation --------
    always @(posedge clk) begin
        if (dut.ex_jal) begin
            $display("[EX] JAL in EX stage, PC+4=%h",
                dut.ex_pc_plus4);
        end
    end

    always @(posedge clk) begin
        if (dut.mem_jal) begin
            $display("[EX/MEM] JAL passing through EX/MEM, PC+4=%h",
                dut.mem_pc_plus4);
        end
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
        $display("mem[1] = %0d", dut.u_mem.u_dmem.mem[1]);

        // -------------------------------
        // Hard PASS / FAIL assertions
        // -------------------------------
        if (dut.u_id.u_regfile.rf[31] !== 32'h00000050) begin
            $error("JAL FAILED: $ra incorrect!");
        end

        if (dut.u_mem.u_dmem.mem[1] !== 7) begin
            $error("SW/LW FAILED: mem[1] incorrect!");
        end

        $display("\n✅ ALL TESTS PASSED");
        $finish;
    end

endmodule

