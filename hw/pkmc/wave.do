onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -format Logic -label clk /clock/uut/dafk_top0/dct0/clk_i
add wave -noupdate -format Logic -label rst /clock/uut/dafk_top0/dct0/rst_i
add wave -noupdate -format Logic /clock/uut/dafk_top0/stx_pad_o
add wave -noupdate -divider {WB slave interface}
add wave -noupdate -format Literal -label wb_adr_i -radix hexadecimal /clock/uut/dafk_top0/dct0/wb_adr_i
add wave -noupdate -format Literal -label wb_dat_i -radix hexadecimal /clock/uut/dafk_top0/dct0/wb_dat_i
add wave -noupdate -format Logic -label wb_stb_i /clock/uut/dafk_top0/dct0/wb_stb_i
add wave -noupdate -format Logic -label wb_we_i /clock/uut/dafk_top0/dct0/wb_we_i
add wave -noupdate -format Logic -label wb_ack_o /clock/uut/dafk_top0/dct0/wb_ack_o
add wave -noupdate -format Literal -label state_wb -radix hexadecimal /clock/uut/dafk_top0/dct0/state_wb
add wave -noupdate -format Literal -label wb_dat_o -radix hexadecimal /clock/uut/dafk_top0/dct0/wb_dat_o
add wave -noupdate -divider {Control Unit}
add wave -noupdate -format Literal -label state -radix hexadecimal /clock/uut/dafk_top0/dct0/state
add wave -noupdate -divider FIFO
add wave -noupdate -format Logic -label wr /clock/uut/dafk_top0/dct0/wr
add wave -noupdate -format Logic -label full /clock/uut/dafk_top0/dct0/full
add wave -noupdate -format Literal -label dout_fifo -radix hexadecimal /clock/uut/dafk_top0/dct0/dout_fifo
add wave -noupdate -format Logic -label empty /clock/uut/dafk_top0/dct0/empty
add wave -noupdate -format Logic -label rd /clock/uut/dafk_top0/dct0/rd
add wave -noupdate -divider DCT2
add wave -noupdate -format Logic -label rfd /clock/uut/dafk_top0/dct0/rfd
add wave -noupdate -format Logic -label nd /clock/uut/dafk_top0/dct0/nd
add wave -noupdate -format Literal -label din_dct -radix hexadecimal /clock/uut/dafk_top0/dct0/din_dct
add wave -noupdate -format Logic -label rdy /clock/uut/dafk_top0/dct0/rdy
add wave -noupdate -format Literal -label dout_dct -radix hexadecimal /clock/uut/dafk_top0/dct0/dout_dct
add wave -noupdate -divider QUANT
add wave -noupdate -format Literal -label nr -radix unsigned /clock/uut/dafk_top0/dct0/nr
add wave -noupdate -format Literal -label ex_reg -radix hexadecimal /clock/uut/dafk_top0/dct0/ex_reg
add wave -noupdate -format Literal -label dout_coeff -radix hexadecimal /clock/uut/dafk_top0/dct0/dout_coeff
add wave -noupdate -format Literal -label dout_quant -radix hexadecimal /clock/uut/dafk_top0/dct0/dout_quant
add wave -noupdate -format Literal -label result -radix unsigned /clock/uut/dafk_top0/dct0/result
add wave -noupdate -divider ZigZag
add wave -noupdate -format Logic -label rdy2 /clock/uut/dafk_top0/dct0/rdy2
add wave -noupdate -format Literal -label nr2 -radix unsigned /clock/uut/dafk_top0/dct0/nr2
add wave -noupdate -format Literal -label addr -radix hexadecimal /clock/uut/dafk_top0/dct0/addr
add wave -noupdate -format Logic -label stb /clock/uut/dafk_top0/dct0/wb_stb_i
add wave -noupdate -format Logic -label we /clock/uut/dafk_top0/dct0/wb_we_i
add wave -noupdate -format Literal -label cs_reg -radix hexadecimal /clock/uut/dafk_top0/dct0/cs_reg
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {234323239 ps} 0}
configure wave -namecolwidth 40
configure wave -valuecolwidth 40
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
update
WaveRestoreZoom {0 ps} {1172850 ns}
