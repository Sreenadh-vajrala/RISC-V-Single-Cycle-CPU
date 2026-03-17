// RISC-V CPU module integrating controller and datapath
module riscv_cpu (
    input         clk, reset,
    output [31:0] PC, // To instruction memory
    input  [31:0] Instr, // From instruction memory
    output        MemWrite, // Memory write enable 
    output [31:0] Mem_WrAddr, Mem_WrData, // Memory write address and data
    input  [31:0] ReadData, // Data read from Data memory
    output [31:0] Result
);

wire        ALUSrc, RegWrite, jarl, Zero;
wire [1:0]  ResultSrc, ImmSrc;
wire [3:0]  ALUControl;

controller  c   (Instr[6:0], Instr[14:12], Instr[30], Zero,
                ResultSrc, MemWrite, PCSrc, ALUSrc, RegWrite, jarl,
                ImmSrc, ALUControl);

datapath    dp  (clk, reset, ResultSrc, PCSrc,
                ALUSrc, RegWrite, ImmSrc, ALUControl, jarl,
                Zero, PC, Instr, Mem_WrAddr, Mem_WrData, ReadData, Result);

endmodule