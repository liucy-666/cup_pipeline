module if_stage (
    input  logic [31:0] pc,
    output logic [31:0] instr
);
    imem u_imem (
        .addr  (pc),
        .instr (instr)
    );
endmodule
