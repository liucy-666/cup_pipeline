module regfile (
    input  logic        clk,

    // 读端口
    input  logic [4:0]  ra1,
    input  logic [4:0]  ra2,
    output logic [31:0] rd1,
    output logic [31:0] rd2,

    // 写端口
    input  logic        we,
    input  logic [4:0]  wa,
    input  logic [31:0] wd
);
    logic [31:0] rf [31:0];

    // combinational read
    assign rd1 = (ra1 == 5'd0) ? 32'b0 : rf[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'b0 : rf[ra2];

    // write on falling edge
    always_ff @(negedge clk) begin
        if (we && (wa != 5'd0)) begin
            rf[wa] <= wd;
        end
    end

    // simulation-friendly init
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            rf[i] = 32'b0;
    end

endmodule
