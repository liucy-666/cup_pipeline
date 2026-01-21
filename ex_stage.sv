module ex_stage (
    input  logic [31:0] rd1,
    input  logic [31:0] rd2,
    input  logic [31:0] imm,
    input  logic [4:0]  shamt,   

    input  logic [4:0]  rt,
    input  logic [4:0]  rd,

    input  logic        alusrc,
    input  logic        regdst,
    input  logic [3:0]  alu_ctrl,

    input  logic [1:0]  forwardA,
    input  logic [1:0]  forwardB,
    input  logic [31:0] exmem_aluout,
    input  logic [31:0] memwb_wdata,

    input logic         is_branch,
    input logic         is_branch_ne,
    input logic         jump,
    input logic         is_jr,
    input logic         jal,

    output logic [31:0] alu_result,
    output logic        alu_zero,
    output logic [4:0]  writereg,
    output logic branch_taken,
    output logic [31:0] jump_target,
    output logic [31:0] store_data
);

    logic [31:0] alu_in1, alu_in2;
    logic [31:0] alu_src_b;
    /////////debug。。。。
    assign branch_taken = (is_branch    &&  alu_zero) || (is_branch_ne && !alu_zero);
    
    assign jump_target = rd1;
    
    // forwarding
    always_comb begin
        case (forwardA)
            2'b00: alu_in1 = rd1;
            2'b10: alu_in1 = exmem_aluout;
            2'b01: alu_in1 = memwb_wdata;
            default: alu_in1 = rd1;
        endcase

        case (forwardB)
            2'b00: alu_in2 = rd2;
            2'b10: alu_in2 = exmem_aluout;
            2'b01: alu_in2 = memwb_wdata;
            default: alu_in2 = rd2;
        endcase
    end

    // ALU B 输入选择
    // 对移位指令：b = shamt
    always_comb begin
        if (alu_ctrl == 4'b1000 || // sll
            alu_ctrl == 4'b1010 || // srl
            alu_ctrl == 4'b1011)   // sra
            alu_src_b = {27'b0, shamt};
        else
            alu_src_b = alusrc ? imm : alu_in2;
    end

    alu u_alu (
        .a        (alu_in1),
        .b        (alu_src_b),
        .alu_ctrl (alu_ctrl),
        .result   (alu_result),
        .zero     (alu_zero)
    );
    assign store_data = alu_in2;
    assign writereg = regdst ? rd : rt;

endmodule
