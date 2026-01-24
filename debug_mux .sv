module debug_mux (
    input  logic [3:0]  sel,          // SW[3:0]
    input  logic [31:0] regs [0:31],
    input  logic [31:0] dbg_pc,
    output logic [31:0] dbg_data
);

always_comb begin
    case (sel)
        4'h0: dbg_data = regs[0];   // $zero
        4'h1: dbg_data = regs[8];   // $t0
        4'h2: dbg_data = regs[9];   // $t1
        4'h3: dbg_data = regs[10];  // $t2
        4'h4: dbg_data = regs[11];  // $t3
        4'h5: dbg_data = regs[12];  // $t4
        4'h6: dbg_data = regs[31];  // $ra
        default: dbg_data = 32'hDEADBEEF;
    endcase
end
endmodule
