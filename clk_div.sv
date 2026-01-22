module clk_div #(
    parameter DIV = 100_000_000   // 100MHz → 1Hz
)(
    input  logic clk_in,   // 100MHz
    input  logic reset,
    output logic clk_out
);

    localparam CNT_WIDTH = $clog2(DIV);
    logic [CNT_WIDTH-1:0] cnt;

    always_ff @(posedge clk_in or posedge reset) begin
        if (reset) begin
            cnt     <= 0;
            clk_out <= 1'b0;
        end else if (cnt == DIV/2 - 1) begin
            cnt     <= 0;
            clk_out <= ~clk_out;   // 翻转 → 方波
        end else begin
            cnt <= cnt + 1;
        end
    end

endmodule
