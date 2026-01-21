module id_stage (
    input  logic        clk,
    input  logic [31:0] instr,

    // WB
    input  logic        wb_reg_write,
    input  logic [4:0]  wb_rd,
    input  logic [31:0] wb_wd,

    // outputs to ID/EX
    output logic [31:0] rs_val,
    output logic [31:0] rt_val,
    output logic [31:0] imm_ext,
    output logic [4:0]  shamt,

    output logic [4:0]  rs,
    output logic [4:0]  rt,
    output logic [4:0]  rd
);

    // instruction fields
    logic [5:0] opcode;

    assign opcode = instr[31:26];
    assign rs     = instr[25:21];
    assign rt     = instr[20:16];
    assign rd     = instr[15:11];
    assign shamt  = instr[10:6];

    // register file
    regfile u_regfile (
        .clk (clk),
        .we  (wb_reg_write),
        .ra1 (rs),
        .ra2 (rt),
        .wa  (wb_rd),
        .wd  (wb_wd),
        .rd1 (rs_val),
        .rd2 (rt_val)
    );

    // immediate extension
    always_comb begin
        case (opcode)
            6'b001100, // andi
            6'b001101, // ori
            6'b001110: // xori
                imm_ext = {16'b0, instr[15:0]};

            6'b001111: // lui
                imm_ext = {instr[15:0], 16'b0};

            default:   // addi, lw, sw, beq, bne
                imm_ext = {{16{instr[15]}}, instr[15:0]};
        endcase
    end

endmodule
