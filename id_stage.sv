module id_stage (
    input  logic        clk,
    input  logic [31:0] instr,

    // WB
    input  logic        wb_reg_write,
    /////
    //input  logic [4:0]  wb_rd,
    //////
    input  logic [31:0] wb_wd,
    input  logic [4:0]  wb_waddr, 

    // outputs to ID/EX
    output logic [31:0] rs_val,
    output logic [31:0] rt_val,
    output logic [31:0] imm_ext,
    output logic [4:0]  shamt,

    output logic [4:0]  rs,
    output logic [4:0]  rt,
    output logic [4:0]  rd,
    //////////jump
    input  logic [31:0] pc_plus4,
    output logic [31:0] jump_target  
);

    // instruction fields
    logic [5:0] opcode;

    assign opcode = instr[31:26];
    assign rs     = instr[25:21];
    assign rt     = instr[20:16];
    assign rd     = instr[15:11];
    assign shamt  = instr[10:6];
    //jump跳转
    assign jump_target = { pc_plus4[31:28], instr[25:0], 2'b00 };
    ////////////////debuging
    logic [31:0] rs_raw, rt_raw;
    ////////////////
    // register file
    regfile u_regfile (
        .clk (clk),
        .we  (wb_reg_write),
        .ra1 (rs),
        .ra2 (rt),
        .wa  (wb_waddr),
        .wd  (wb_wd),
        .rd1 (rs_raw),
        .rd2 (rt_raw)
        //.rd1 (rs_val),
       // .rd2 (rt_val)
    );
    assign rs_val = (wb_reg_write && wb_waddr != 0 && wb_waddr == rs)
                ? wb_wd : rs_raw;

    assign rt_val = (wb_reg_write && wb_waddr != 0 && wb_waddr == rt)
                ? wb_wd : rt_raw;


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
    always_ff @(negedge clk) begin
    if (wb_reg_write) begin
        $display(
          "[RF WRITE] time=%0t wa=%0d wd=%h",
          $time, wb_waddr, wb_wd
        );
    end
end

endmodule
