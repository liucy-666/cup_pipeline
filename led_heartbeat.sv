module led_heartbeat (
    input  logic clk,      // 慢时钟（推荐 1~10Hz）
    input  logic reset,
    output logic led
);

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            led <= 1'b0;
        else
            led <= ~led;   // 每个时钟翻转
    end

endmodule
