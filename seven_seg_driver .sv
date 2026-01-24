module seg7_driver (
    input  logic        clk,        // 板载时钟（100MHz 或分频后）
    input  logic        reset,
    input  logic [31:0] data,       // 要显示的数据（dbg_data）
    output logic [6:0]  seg,        // a b c d e f g（低有效）
    output logic [3:0]  an          // 数码管使能（低有效）
);

    /* ===============================
       1. 时分复用扫描（~1kHz）
       =============================== */
    logic [15:0] scan_cnt;
    logic [1:0]  scan_sel;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            scan_cnt <= 16'd0;
        else
            scan_cnt <= scan_cnt + 1;
    end

    assign scan_sel = scan_cnt[15:14]; // 约 1kHz 切换

    /* ===============================
       2. 取低 16 bit 显示
       =============================== */
    logic [3:0] hex;

    always_comb begin
    case (scan_sel)
        2'd0: hex = data[15:12]; // 最右显示最高 nibble
        2'd1: hex = data[11:8];
        2'd2: hex = data[7:4];
        2'd3: hex = data[3:0];   // 最左显示最低 nibble
        default: hex = 4'h0;
    endcase
end

    /* ===============================
       3. 数码管使能（低有效）
       =============================== */
    always_comb begin
        case (scan_sel)
            2'd0: an = 4'b1110; // 最右
            2'd1: an = 4'b1101;
            2'd2: an = 4'b1011;
            2'd3: an = 4'b0111; // 最左
            default: an = 4'b1111;
        endcase
    end

    /* ===============================
       4. HEX → 七段译码（低有效）
       =============================== */
    always_comb begin
        case (hex)
            4'h0: seg = 7'b1000000;
            4'h1: seg = 7'b1111001;
            4'h2: seg = 7'b0100100;
            4'h3: seg = 7'b0110000;
            4'h4: seg = 7'b0011001;
            4'h5: seg = 7'b0010010;
            4'h6: seg = 7'b0000010;
            4'h7: seg = 7'b1111000;
            4'h8: seg = 7'b0000000;
            4'h9: seg = 7'b0010000;
            4'hA: seg = 7'b0001000;
            4'hB: seg = 7'b0000011;
            4'hC: seg = 7'b1000110;
            4'hD: seg = 7'b0100001;
            4'hE: seg = 7'b0000110;
            4'hF: seg = 7'b0001110;
            default: seg = 7'b1111111;
        endcase
    end

endmodule

