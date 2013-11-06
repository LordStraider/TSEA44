virtual type { \
J\
JAL\
{0x3 BNF}\
{0x4 BF}\
{0x5 NOP}\
{0x6 MOVHI}\
{0x8 XSYNC}\
{0x9 RFE}\
{0x11 JR}\
{0x12 JALR}\
{0x13 MACI}\
{0x21 LWZ}\
{0x23 LBZ}\
{0x24 LBS}\
{0x25 LHZ}\
{0x26 LHS}\
{0x20 LBIT}\
{0x27 ADDI}\
{0x28 ADDIC}\
{0x29 ANDI}\
{0x2a ORI}\
{0x2b XORI}\
{0x2c MULI}\
{0x2d MFSPR}\
{0x2e SH}\
{0x2f SFXXI}\
{0x30 MTSPR}\
{0x31 MACMSB}\
{0x35 SW}\
{0x36 SB}\
{0x37 SH}\
{0x34 SBIT}\
{0x38 ALU}\
{0x39 SFXX}\
{0x3c CUST5}\
} instr_op_map
virtual type { \
NOP\
{0x2 LBZ}\
{0x3 LBS}\
{0x4 LHZ}\
{0x5 LHS}\
{0x6 LWZ}\
{0x7 LWS}\
{0x1 LD}\
SD\
{0xa SB}\
{0xc SH}\
{0xe SW}\
{0x10 LBIT}\
{0x18 SBIT}\
} lsu_op_map
quietly virtual signal -install /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_rf -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_rf/rf_a/ramb16_s36_s36   {mem[31:0]} virtual_rf
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_genpc {pcreg & 2'b00} virtual_pcreg
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl {if_insn[31:26]} virtual_if_opcode
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl {id_insn[31:26]} virtual_id_opcode
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl {ex_insn[31:26]} virtual_ex_opcode
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl {wb_insn[31:26]} virtual_wb_opcode
quietly virtual function -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl { (instr_op_map)virtual_if_opcode} virtual_if_insn
quietly virtual function -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl { (instr_op_map)virtual_id_opcode} virtual_id_insn
quietly virtual function -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl { (instr_op_map)virtual_ex_opcode} virtual_ex_insn
quietly virtual function -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl { (instr_op_map)virtual_wb_opcode} virtual_wb_insn
