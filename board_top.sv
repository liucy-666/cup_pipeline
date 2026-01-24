module board_top #(
    parameter SIM = 0   // =1 用于仿真，=0 用于上板
)(
    input  logic        clk_100mhz,
    input  logic        btn_reset,
    input  logic [3:0]  sw,

    output logic [15:0] led,
    output logic [6:0]  seg,
    output logic [3:0]  an
);
   
    /* ===============================
       1. Reset sync (推荐)
       =============================== */
    logic reset;
    logic reset_ff1, reset_ff2;

    always_ff @(posedge clk_100mhz) begin
        reset_ff1 <= btn_reset;
        reset_ff2 <= reset_ff1;
    end
assign reset = reset_ff2;

    /* ===============================
       2. Clock generation
       =============================== */
    logic cpu_clk;
    logic slow_clk;

    // CPU 用快时钟（仿真 & 上板都 OK）
    assign cpu_clk = clk_100mhz;

    // 慢时钟：给 heartbeat / 可选调试
    clk_div #(.DIV(50_000_000)) u_clk_div (
        .clk_in  (clk_100mhz),
        .reset   (reset),
        .clk_out (slow_clk)     // ~1Hz
    );

    /* ===============================
       3. CPU instance
       =============================== */
    logic [31:0] dbg_regs [0:31];
    logic        dbg_commit;
    logic [31:0] dbg_pc;

    top u_cpu (
        .clk        (cpu_clk),
        .reset      (reset),
        .dbg_commit (dbg_commit),
        .dbg_regs   (dbg_regs),
        .dbg_pc     (dbg_pc)//接住pc
    );

    /* ===============================
       4. Debug mux
       =============================== */
    logic [31:0] dbg_data;
    //assign dbg_data = dbg_regs[8]; 
    debug_mux u_debug_mux (
        .sel      (sw),
        .regs     (dbg_regs),
        .dbg_data (dbg_data),
        .dbg_pc     (dbg_pc)
        //.dbg_data ()
    );


    /* ===============================
       5. Seven-seg driver
       ⚠️ 注意：绝对不要用 cpu_clk
       =============================== */
    seg7_driver u_seg7 (
        .clk   (clk_100mhz),   // 数码管用快时钟
        .reset (reset),
        .data  (dbg_data),
        .seg   (seg),
        .an    (an)
    );

    /* ===============================
       6. Heartbeat LED (必闪)
       =============================== */
    logic heartbeat_led;

    led_heartbeat u_heartbeat (
        .clk   (slow_clk),     // 1Hz
        .reset (reset),
        .led   (heartbeat_led)
    );

    /* ===============================
       7. LEDs
       =============================== */
    assign led[0] = heartbeat_led; // 心跳（必闪）
    assign led[1] = reset;         // reset 状态
    assign led[2] = dbg_commit;    // CPU 提交
    assign led[15:3] = 13'b0;
endmodule



