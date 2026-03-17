// Top-level module for T1C RISC-V CPU with external memory interface
// also integrated instruction and data memories
module t1c_riscv_cpu (
    input         clk, reset,
    input         Ext_MemWrite,
    input  [31:0] Ext_WriteData, Ext_DataAdr,
    output        MemWrite,
    output [31:0] WriteData, DataAdr, ReadData,
    output [31:0] PC, Result
);

wire [31:0] Instr;
wire [31:0] DataAdr_rv32, WriteData_rv32;
wire        MemWrite_rv32;

// instantiate processor and memories
riscv_cpu rvcpu    (clk, reset, PC, Instr,
                    MemWrite_rv32, DataAdr_rv32,
                    WriteData_rv32, ReadData, Result);
instr_mem instrmem (PC, Instr);
data_mem  datamem  (clk, MemWrite, Instr[14:12], DataAdr, WriteData, ReadData);

assign MemWrite  = (Ext_MemWrite && reset) ? 1 : MemWrite_rv32; // prioritize external memory write 
assign WriteData = (Ext_MemWrite && reset) ? Ext_WriteData : WriteData_rv32; // prioritize external write data
assign DataAdr   = reset ? Ext_DataAdr : DataAdr_rv32; // prioritize external data address

endmodule