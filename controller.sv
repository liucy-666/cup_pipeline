module controller (
    input  logic [31:0] instr,

    output logic        is_branch,
    output logic        is_branch_ne, ///branch
    output logic        alusrc,
    output logic [3:0]  alu_ctrl,
    output logic        jump,
    output logic        is_jr,
    output logic        jal,    //jump
    output logic        regwrite,
    output logic        memwrite,
    output logic        memtoreg,
    output logic        memread,
    output logic        regdst,
    output logic        is_shift,

    output logic regdst_ra,   // 写 $31寄存器
    output logic wb_pc_plus4
    
);

    logic [5:0] opcode;
    logic [5:0] funct;

    assign opcode = instr[31:26];
    assign funct  = instr[5:0];

    localparam ALU_AND = 4'b0000;
    localparam ALU_OR  = 4'b0001;
    localparam ALU_ADD = 4'b0010;
    localparam ALU_XOR = 4'b0011;
    localparam ALU_SUB = 4'b0110;
    localparam ALU_SLT = 4'b0111;
    localparam ALU_SLL = 4'b1000;
    localparam ALU_LUI = 4'b1001;
    localparam ALU_SRL = 4'b1010;
    localparam ALU_SRA = 4'b1011;

    always_comb begin
        // 默认值
        is_branch   = 0;
        is_branch_ne = 0;
        alusrc  = 0;
        alu_ctrl= ALU_ADD;
        is_shift=0;
        regwrite= 0;
        memwrite= 0;
        memtoreg= 0;
        memread = 0;
        regdst  = 0;
        jump = 0;
        jal  = 0;
        is_jr = 0;
        regdst_ra   = 0;
        wb_pc_plus4 = 0;
        if (instr == 32'b0) begin
    // 教学 NOP
end else begin 
        case (opcode)
            // R-type指令
            6'b000000: begin
                regwrite = 1;
                regdst   = 1;
                alusrc   = 0;
                memtoreg = 0;

                case (funct)
                    6'b100000: alu_ctrl = ALU_ADD; // add
                    6'b100010: alu_ctrl = ALU_SUB; // sub
                    6'b100100: alu_ctrl = ALU_AND; // and
                    6'b100101: alu_ctrl = ALU_OR;  // or
                    6'b100110: alu_ctrl = ALU_XOR; // xor
                    6'b101010: alu_ctrl = ALU_SLT; // slt
                    6'b000000: begin alu_ctrl = 4'b1000; is_shift = 1; end // sll
                    6'b000010: begin alu_ctrl = 4'b1010; is_shift = 1; end // srl
                    6'b000011: begin alu_ctrl = 4'b1011; is_shift = 1; end // sra
                    6'b001000: begin                                       // jr
                    is_jr    = 1;
                    regwrite = 0;
                    jump=1;
                    end
                    default:   alu_ctrl = ALU_ADD;
                endcase 
            end

            // addi
            6'b001000: begin
                alusrc   = 1;
                alu_ctrl = ALU_ADD;
                regwrite = 1;
                regdst   = 0;
            end

            // ori
            6'b001101: begin
                alusrc   = 1;
                alu_ctrl = ALU_OR;
                regwrite = 1;
                regdst   = 0;
            end

            // xori
            6'b001110: begin
                alusrc   = 1;
                alu_ctrl = ALU_XOR;
                regwrite = 1;
                regdst   = 0;
            end

            // lui
            6'b001111: begin
                alusrc   = 1;
                alu_ctrl = ALU_LUI;  // lui
                regwrite = 1;
                regdst   = 0;
            end

            // lw
            6'b100011: begin
                alusrc   = 1;
                alu_ctrl =  ALU_ADD;
                regwrite = 1;
                memtoreg = 1;
                memread  = 1;
                regdst   = 0;
            end

            // sw
            6'b101011: begin
                alusrc   = 1;
                alu_ctrl = ALU_ADD;
                memwrite = 1;
            end

            //beq
            6'b000100: begin
                alusrc   = 0;
                alu_ctrl = ALU_SUB;
                is_branch   = 1;
            end

            //bne
            6'b000101: begin // bne
                alusrc   = 0;
                alu_ctrl = ALU_SUB;
                is_branch   = 1;
                is_branch_ne= 1;
            end
            //jump
             6'b000011: begin // jal
                jump     = 1;
                jal      = 1;
                regwrite = 1;
                regdst_ra  = 1;
                wb_pc_plus4= 1;
            end
            // j
            6'b000010: begin
                jump     = 1'b1;
                regwrite = 1'b0;
                memwrite = 1'b0;
                memread  = 1'b0;
                memtoreg = 1'b0;
                regdst   = 1'b0;
            end
            default: begin
                // NOP
            end
        endcase
         if (opcode == 6'b000011) begin // jal
        $display(
            "[ID] time=%0t JAL detected |  instr=%h",
            $time,  instr
        );
    end
    end
end


endmodule
