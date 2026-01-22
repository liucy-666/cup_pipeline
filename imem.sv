//拿AI写了一个imem用于测试功能
module imem (
    input  logic [31:0] addr,
    output logic [31:0] instr
);

    logic [31:0] mem [0:255];

    initial begin
        integer i;
        for (i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000000;
        end
    (* ram_style = "block" *)

    initial begin
        $readmemh("C:\\Users\\admin\\Desktop\\pipline_cpu\\prog.mem", mem);
    end
        
    assign instr = mem[addr[9:2]];

endmodule
