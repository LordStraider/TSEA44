onerror {resume}
virtual type { 
{0x0 NO}\
{0x1 M0}\
{0x2 M1}\
{0x3 M0M1}\
{0x4 M2}\
{0x5 M2M0}\
{0x6 M2M1}\
{0x7 M2M1M0}\
{0x40 M6}\
{0x41 M6M0}\
{0x42 M6M1}\
{0x43 M6M1M0}\
{0x44 M6M2}\
{0x45 M6M2M0}\
{0x46 M6M2M1}\
{0x47 M6M2M1M0}\
} req_map

quietly virtual signal -install /dafk_tb/computer0/dafk_top/wb_conbus {/dafk_tb/computer0/dafk_top/wb_conbus/req  } virtual_req
quietly virtual function -install /dafk_tb/computer0/dafk_top/wb_conbus -env /dafk_tb/computer0/dafk_top/wb_conbus { (req_map)virtual_req} virtual_req_signal

quietly WaveActivateNextPane {} 0
add wave -noupdate -label clk_i /dafk_tb/computer0/dafk_top/wb_conbus/clk_i
add wave -noupdate -label rst_i /dafk_tb/computer0/dafk_top/wb_conbus/rst_i
add wave -noupdate -divider Arbiter
add wave -noupdate -label req /dafk_tb/computer0/dafk_top/wb_conbus/virtual_req_signal
add wave -noupdate -label gnt -radix unsigned /dafk_tb/computer0/dafk_top/wb_conbus/gnt
add wave -noupdate -divider {m0 - Instruction}
add wave -noupdate -label {Mx[0].cyc} {/dafk_tb/computer0/dafk_top/Mx[0]/cyc}
add wave -noupdate -label {Mx[0].stb} {/dafk_tb/computer0/dafk_top/wb_conbus/Mx[0]/stb}
add wave -noupdate -label {Mx[0].ack} {/dafk_tb/computer0/dafk_top/wb_conbus/Mx[0]/ack}
add wave -noupdate -divider {m1 - Data}
add wave -noupdate -label {Mx[1].adr} -radix hexadecimal {/dafk_tb/computer0/dafk_top/Mx[1]/adr}
add wave -noupdate -label {Mx[1].we} {/dafk_tb/computer0/dafk_top/Mx[1]/we}
add wave -noupdate -label {Mx[1].cyc} {/dafk_tb/computer0/dafk_top/Mx[1]/cyc}
add wave -noupdate -label {Mx[1].stb} {/dafk_tb/computer0/dafk_top/wb_conbus/Mx[1]/stb}
add wave -noupdate -label {Mx[1].ack} {/dafk_tb/computer0/dafk_top/wb_conbus/Mx[1]/ack}
add wave -noupdate -divider {m6 - DMA}
add wave -noupdate -label {Mx[6].adr} -radix hexadecimal {/dafk_tb/computer0/dafk_top/Mx[6]/adr}
add wave -noupdate -label {Mx[6].we} {/dafk_tb/computer0/dafk_top/Mx[6]/we}
add wave -noupdate -label {Mx[6].cyc} {/dafk_tb/computer0/dafk_top/Mx[6]/cyc}
add wave -noupdate -label {Mx[6].stb} {/dafk_tb/computer0/dafk_top/Mx[6]/stb}
add wave -noupdate -label {Mx[6].ack} {/dafk_tb/computer0/dafk_top/Mx[6]/ack}
add wave -noupdate -divider parport
add wave -noupdate -label out_pad_o -radix hexadecimal /dafk_tb/computer0/dafk_top/pia/out_pad_o
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {222882500 ps} 0} {{Cursor 2} {875282500 ps} 0}
configure wave -namecolwidth 319
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
WaveRestoreZoom {0 ps} {1050 us}
