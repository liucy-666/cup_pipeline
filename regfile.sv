module regfile (
    input  logic        clk,

    input  logic [4:0]  ra1,
    input  logic [4:0]  ra2,
    output logic [31:0] rd1,
    output logic [31:0] rd2,

    input  logic        we,
    input  logic [4:0]  wa,
    input  logic [31:0] wd,

    // debug: 纯观察口
    output logic [31:0] dbg_regs [0:31]
);
    logic [31:0] rf [31:0];

    assign rd1 = (ra1 == 5'd0) ? 32'b0 : rf[ra1];
    assign rd2 = (ra2 == 5'd0) ? 32'b0 : rf[ra2];

    always_ff @(negedge clk) begin
        if (we && (wa != 5'd0))
            rf[wa] <= wd;
    end

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            rf[i] = 32'b0;
    end

    genvar g;
    generate
        for (g = 0; g < 32; g = g + 1) begin
            assign dbg_regs[g] = (g == 0) ? 32'b0 : rf[g];
        end
    endgenerate
endmodule

