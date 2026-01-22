module board_top (
    input  logic        clk_100mhz,    // 100 MHz 时钟
    input  logic        btn_reset,     // Reset 按键
    input  logic [3:0]  sw,            // 选择寄存器的开关
    output logic [15:0] led,           // LED 显示
    output logic [6:0]  seg,           // 七段数码管段选
    output logic [3:0]  an             // 七段数码管位选
);

    /* ===============================
       1. Clock divider: 100MHz → ~1Hz
       =============================== */
    logic cpu_clk;

    clk_div #(.DIV(100_000_000)) u_clk_div (
        .clk_in  (clk_100mhz),
        .reset   (btn_reset),
        .clk_out (cpu_clk)
    );

    /* ===============================
       2. CPU instance (your top.sv)
       =============================== */
    logic [31:0] dbg_regs [0:31];
    logic dbg_commit;

    top u_cpu (
        .clk        (cpu_clk),
        .reset      (btn_reset),
        .dbg_commit (dbg_commit),
        .dbg_regs   (dbg_regs)
    );

    /* ===============================
       3. debug_mux instance
       =============================== */
    logic [31:0] dbg_data;

    debug_mux u_debug_mux (
        .sel        (sw),            // 从 SW 选择寄存器
        .regs       (dbg_regs),      // 从 CPU 获取寄存器堆
        .dbg_data   (dbg_data)       // 输出选中的寄存器值
    );

    /* ===============================
       4. seg7_driver instance
       =============================== */
    seg7_driver u_seg7_driver (
        .clk        (cpu_clk),       // 使用 CPU 时钟
        .reset      (btn_reset),
        .data       (dbg_data),      // 将 debug_mux 输出的数据传给数码管
        .seg        (seg),           // 七段显示数据
        .an         (an)             // 数码管的使能
    );

    /* ===============================
       5. LED debug
       =============================== */
    assign led[0] = cpu_clk;        // LED0: CPU 时钟
    assign led[1] = btn_reset;      // LED1: Reset 状态
    assign led[2] = dbg_commit;     // LED2: 提交指令状态
    assign led[15:3] = 13'b0;       // 其余 LED 关闭\
    /* ===============================
       6. Heartbeat LED
       =============================== */
    logic heartbeat_led;
    
    led_heartbeat u_led_heartbeat (
        .clk    (cpu_clk),      // 使用 CPU 时钟作为心跳时钟
        .reset  (btn_reset),    // Reset 按钮
        .led    (heartbeat_led) // 输出到 LED
    );

    assign led[0] = heartbeat_led;    // LED0: CPU 心跳

endmodule


