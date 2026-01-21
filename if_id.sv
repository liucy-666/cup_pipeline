module if_id (
    input  logic        clk,
    input  logic        reset,

    // from IF stage
    input  logic [31:0] if_instr,
    input  logic [31:0] if_pc4,

    input  logic        stall,
    // to ID stage
    output logic [31:0] id_instr,
    output logic [31:0] id_pc4, 
    output logic [31:0] ex_pc4,
    input  logic        flush //刷新,
   
);
always_ff @(posedge clk or posedge reset)
    begin
        if (reset) begin
            id_instr <= 32'b0;
            id_pc4   <= 32'b0;
            ex_pc4   <= 32'b0;
        end 
        else if (flush) begin
        // 👇 插入 NOP
            id_instr <= 32'b0;
            id_pc4   <= 32'b0;
            ex_pc4   <= 32'b0;
        end
        else  if(!stall) begin
            id_instr <= if_instr;
            id_pc4   <= if_pc4;
            ex_pc4 <= id_pc4;
        end
        
    end
    

endmodule