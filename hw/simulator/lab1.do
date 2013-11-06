onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Wishbone
add wave -noupdate -radix hexadecimal /lab1_tb/computer0/dafk_top/uart/wb/clk
add wave -noupdate -radix hexadecimal /lab1_tb/computer0/dafk_top/uart/wb/rst
add wave -noupdate -radix hexadecimal /lab1_tb/computer0/dafk_top/uart/wb/adr
add wave -noupdate -radix hexadecimal /lab1_tb/computer0/dafk_top/uart/wb/dat_o
add wave -noupdate -radix hexadecimal /lab1_tb/computer0/dafk_top/uart/wb/dat_i
add wave -noupdate -radix hexadecimal /lab1_tb/computer0/dafk_top/uart/wb/stb
add wave -noupdate -radix hexadecimal /lab1_tb/computer0/dafk_top/uart/wb/cyc
add wave -noupdate -radix hexadecimal /lab1_tb/computer0/dafk_top/uart/wb/we
add wave -noupdate -radix hexadecimal -childformat {{{/lab1_tb/computer0/dafk_top/uart/wb/sel[3]} -radix hexadecimal} {{/lab1_tb/computer0/dafk_top/uart/wb/sel[2]} -radix hexadecimal} {{/lab1_tb/computer0/dafk_top/uart/wb/sel[1]} -radix hexadecimal} {{/lab1_tb/computer0/dafk_top/uart/wb/sel[0]} -radix hexadecimal}} -subitemconfig {{/lab1_tb/computer0/dafk_top/uart/wb/sel[3]} {-height 13 -radix hexadecimal} {/lab1_tb/computer0/dafk_top/uart/wb/sel[2]} {-height 13 -radix hexadecimal} {/lab1_tb/computer0/dafk_top/uart/wb/sel[1]} {-height 13 -radix hexadecimal} {/lab1_tb/computer0/dafk_top/uart/wb/sel[0]} {-height 13 -radix hexadecimal}} /lab1_tb/computer0/dafk_top/uart/wb/sel
add wave -noupdate -radix hexadecimal /lab1_tb/computer0/dafk_top/uart/wb/ack
add wave -noupdate -divider UART
add wave -noupdate -radix unsigned /lab1_tb/computer0/dafk_top/uart/internal_clock
add wave -noupdate -divider TX
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/wr
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/end_char_tx
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/tx_empty
add wave -noupdate -height 16 /lab1_tb/computer0/dafk_top/uart/t_state
add wave -noupdate -radix ascii /lab1_tb/computer0/dafk_top/uart/tx_reg
add wave -noupdate -radix ascii /lab1_tb/computer0/dafk_top/uart/t_buf
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/send_flag
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/send
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/stx_pad_o
add wave -noupdate -radix unsigned /lab1_tb/computer0/dafk_top/uart/t_data_ctr
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/next_t_state
add wave -noupdate -divider RX
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/srx_pad_i
add wave -noupdate -radix ascii /lab1_tb/computer0/dafk_top/uart/output_logic
add wave -noupdate -height 16 /lab1_tb/computer0/dafk_top/uart/r_state
add wave -noupdate -radix ascii /lab1_tb/computer0/dafk_top/uart/rx_reg
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/rx_full
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/end_char_rx
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/rd
add wave -noupdate -radix ascii -childformat {{{/lab1_tb/computer0/dafk_top/uart/r_buf[7]} -radix ascii} {{/lab1_tb/computer0/dafk_top/uart/r_buf[6]} -radix ascii} {{/lab1_tb/computer0/dafk_top/uart/r_buf[5]} -radix ascii} {{/lab1_tb/computer0/dafk_top/uart/r_buf[4]} -radix ascii} {{/lab1_tb/computer0/dafk_top/uart/r_buf[3]} -radix ascii} {{/lab1_tb/computer0/dafk_top/uart/r_buf[2]} -radix ascii} {{/lab1_tb/computer0/dafk_top/uart/r_buf[1]} -radix ascii} {{/lab1_tb/computer0/dafk_top/uart/r_buf[0]} -radix ascii}} -subitemconfig {{/lab1_tb/computer0/dafk_top/uart/r_buf[7]} {-radix ascii} {/lab1_tb/computer0/dafk_top/uart/r_buf[6]} {-radix ascii} {/lab1_tb/computer0/dafk_top/uart/r_buf[5]} {-radix ascii} {/lab1_tb/computer0/dafk_top/uart/r_buf[4]} {-radix ascii} {/lab1_tb/computer0/dafk_top/uart/r_buf[3]} {-radix ascii} {/lab1_tb/computer0/dafk_top/uart/r_buf[2]} {-radix ascii} {/lab1_tb/computer0/dafk_top/uart/r_buf[1]} {-radix ascii} {/lab1_tb/computer0/dafk_top/uart/r_buf[0]} {-radix ascii}} /lab1_tb/computer0/dafk_top/uart/r_buf
add wave -noupdate -radix unsigned /lab1_tb/computer0/dafk_top/uart/r_data_ctr
add wave -noupdate /lab1_tb/computer0/dafk_top/uart/next_r_state
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {368450653 ps} 0} {{Cursor 2} {445068418 ps} 0}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
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
WaveRestoreZoom {6288347473 ps} {6289075347 ps}
