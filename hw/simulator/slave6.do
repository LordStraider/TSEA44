onerror {resume}
quietly WaveActivateNextPane {} 0

add wave -noupdate -divider {Slave 6 (DCT)}
add wave -noupdate -format Logic -radix hexadecimal -label ack {/dafk_tb/computer0/dafk_top/Sx[6]/ack}
add wave -noupdate -format Literal -radix hexadecimal -label adr {/dafk_tb/computer0/dafk_top/Sx[6]/adr}
add wave -noupdate -format Logic -radix hexadecimal -label cyc {/dafk_tb/computer0/dafk_top/Sx[6]/cyc}
add wave -noupdate -format Literal -radix hexadecimal -label dat_i {/dafk_tb/computer0/dafk_top/Sx[6]/dat_i}
add wave -noupdate -format Literal -radix hexadecimal -label dat_o {/dafk_tb/computer0/dafk_top/Sx[6]/dat_o}
add wave -noupdate -format Literal -radix hexadecimal -label sel {/dafk_tb/computer0/dafk_top/Sx[6]/sel}
add wave -noupdate -format Logic -radix hexadecimal -label stb {/dafk_tb/computer0/dafk_top/Sx[6]/stb}
add wave -noupdate -format Logic -radix hexadecimal -label we {/dafk_tb/computer0/dafk_top/Sx[6]/we}
TreeUpdate [SetDefaultTree]
update
