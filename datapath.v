// Datapath module for a simple RISC-V processor
module datapath (
    input         clk, reset,
    input [1:0]   ResultSrc,
    input         PCSrc, ALUSrc,
    input         RegWrite,
    input [1:0]   ImmSrc,
    input [3:0]   ALUControl,
    input         jarl,
    output        Zero,
    output [31:0] PC, // To instruction memory
    input  [31:0] Instr, // From instruction memory
    output [31:0] Mem_WrAddr, Mem_WrData, // Memory write address and data
    input  [31:0] ReadData, // Data read from Data memory
    output [31:0] Result
);

wire [31:0] PCNext, PCPlus4, PCTarget;
wire [31:0] ImmExt, SrcA, SrcB, WriteData, ALUResult, out;
wire [31:0] lui, auipc, LUIOrAUIPCResult;

// next PC logic
mux2 #(32)     pcmux(PCPlus4, PCTarget, PCSrc, PCNext);
reset_ff #(32) pcreg(clk, reset, PCNext, PC);
adder          pcadd4(PC, 32'd4, PCPlus4);
mux2 #(32)     jarlmux(PC, SrcA, jarl, out); // MUX to select between PC and SrcA for jalr instruction  
adder          pcaddbranch(out, ImmExt, PCTarget);

// register file logic
reg_file       rf (clk, RegWrite, Instr[19:15], Instr[24:20], Instr[11:7], Result, SrcA, WriteData);
imm_extend     ext (Instr[31:7], ImmSrc, ImmExt);

// ALU logic
mux2 #(32)     srcbmux(WriteData, ImmExt, ALUSrc, SrcB);
alu            alu (SrcA, SrcB, ALUControl, Instr[14:12], ALUResult, Zero);

// U-Type instructions lui and auipc
assign lui = {Instr[31:12], 12'b0};
adder auipc_adder(PC, lui, auipc);
mux2 #(32)     lui_auipc_mux(auipc, lui, Instr[5], LUIOrAUIPCResult);

// MUX to select between ALUResult, ReadData, PCPlus4, and LUI/AUIPC result
mux4 #(32)     resultmux(ALUResult, ReadData, PCPlus4, LUIOrAUIPCResult, ResultSrc, Result);

assign Mem_WrData = WriteData;
assign Mem_WrAddr = ALUResult;

endmodule