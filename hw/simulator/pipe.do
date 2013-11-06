onerror {resume}
quietly WaveActivateNextPane {} 0
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
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_genpc {pc} virtual_pc
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl {if_insn[31:26]} virtual_if_opcode
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl {id_insn[31:26]} virtual_id_opcode
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl {ex_insn[31:26]} virtual_ex_opcode
quietly virtual signal -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl {wb_insn[31:26]} virtual_wb_opcode
quietly virtual function -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl { (instr_op_map)virtual_if_opcode} virtual_if_insn
quietly virtual function -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl { (instr_op_map)virtual_id_opcode} virtual_id_insn
quietly virtual function -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl { (instr_op_map)virtual_ex_opcode} virtual_ex_insn
quietly virtual function -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl { (instr_op_map)virtual_wb_opcode} virtual_wb_insn

quietly virtual signal   -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_lsu {lsu_op}      virtual_lsu_opcode
quietly virtual function -env /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_lsu { (lsu_op_map)virtual_lsu_opcode} virtual_lsu_insn

add wave -noupdate -format Logic -label clk /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_if/clk
add wave -noupdate -divider pipe
add wave -noupdate -color yellow -format Literal -label pc -radix hexadecimal /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_genpc/virtual_pc
add wave -noupdate -color Yellow -format Literal -label if_insn /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl/virtual_if_insn
add wave -noupdate -color Yellow -format Literal -label id_insn /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl/virtual_id_insn
add wave -noupdate -color Yellow -format Literal -label ex_insn /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl/virtual_ex_insn
add wave -noupdate -color Yellow -format Literal -label wb_insn /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_ctrl/virtual_wb_insn
add wave -noupdate -divider ALU
add wave -noupdate -format Literal -label operand_a -radix hexadecimal /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_operandmuxes/operand_a
add wave -noupdate -format Literal -label operand_b -radix hexadecimal /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_operandmuxes/operand_b
add wave -noupdate -format Literal -label alu_dataout -radix hexadecimal /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/alu_dataout
add wave -noupdate -divider LSU
add wave -noupdate -format Literal -label addrbase -radix hexadecimal /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_lsu/addrbase
add wave -noupdate -format Literal -label addrofs -radix hexadecimal /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_lsu/addrofs
add wave -noupdate -format Literal -label lsu_datain -radix hexadecimal /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_lsu/lsu_datain
add wave -noupdate -format Literal -label lsu_dataout -radix hexadecimal /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/lsu_dataout
add wave -noupdate -color Yellow -format Literal -label lsu_insn /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_lsu/virtual_lsu_insn
add wave -noupdate -divider RF
add wave -noupdate -format Literal -label RF -radix hexadecimal /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_rf/virtual_rf
add wave -noupdate -format Logic -label flag /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_sprs/flag
add wave -noupdate -divider stall
add wave -noupdate -format Logic -label ifstall /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_freeze/if_stall
add wave -noupdate -format Literal -label multicycle -radix unsigned /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_freeze/multicycle
add wave -noupdate -format Logic -label lsu_stall /dafk_tb/computer0/dafk_top/cpu/or1200_cpu/or1200_freeze/lsu_stall
add wave -noupdate -divider {I bus & Cache}
add wave -noupdate -format Logic -label m0_adr -radix hexadecimal {/dafk_tb/computer0/dafk_top/Mx[0]/adr}
add wave -noupdate -format Logic -label m0_dat_i -radix hexadecimal {/dafk_tb/computer0/dafk_top/Mx[0]/dat_i}
add wave -noupdate -format Logic -label m0_cyc  {/dafk_tb/computer0/dafk_top/Mx[0]/cyc}
add wave -noupdate -format Logic -label m0_stb  {/dafk_tb/computer0/dafk_top/Mx[0]/stb}
add wave -noupdate -format Logic -label m0_ack  {/dafk_tb/computer0/dafk_top/Mx[0]/ack}
add wave -noupdate -format Literal -label state -radix unsigned {/dafk_tb/computer0/dafk_top/cpu/or1200_ic_top/or1200_ic_fsm/state}
add wave -noupdate -divider {D bus & Cache}
add wave -noupdate -format Logic -label m1_adr -radix hexadecimal {/dafk_tb/computer0/dafk_top/Mx[1]/adr}
add wave -noupdate -format Logic -label m1_dat_i -radix hexadecimal {/dafk_tb/computer0/dafk_top/Mx[1]/dat_i}
add wave -noupdate -format Logic -label m1_dat_o -radix hexadecimal {/dafk_tb/computer0/dafk_top/Mx[1]/dat_o}
add wave -noupdate -format Logic -label m1_cyc  {/dafk_tb/computer0/dafk_top/Mx[1]/cyc}
add wave -noupdate -format Logic -label m1_stb  {/dafk_tb/computer0/dafk_top/Mx[1]/stb}
add wave -noupdate -format Logic -label m1_ack  {/dafk_tb/computer0/dafk_top/Mx[1]/ack}
add wave -noupdate -format Literal -label state -radix unsigned {/dafk_tb/computer0/dafk_top/cpu/or1200_dc_top/or1200_dc_fsm/state}
add wave -noupdate -divider {Par port}
add wave -noupdate -format Logic -label out_reg -radix hexadecimal {/dafk_tb/computer0/dafk_top/pia/out_reg}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {786954718 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 58
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {787238946 ps} {788255388 ps}
