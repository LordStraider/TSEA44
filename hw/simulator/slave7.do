onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Slave 7 (Parport)}
add wave -noupdate -format Logic -radix hexadecimal -label ack {/dafk_tb/computer0/dafk_top/Sx[7]/ack}
add wave -noupdate -format Literal -radix hexadecimal -label adr {/dafk_tb/computer0/dafk_top/Sx[7]/adr}
add wave -noupdate -format Logic -radix hexadecimal -label cyc {/dafk_tb/computer0/dafk_top/Sx[7]/cyc}
add wave -noupdate -format Literal -radix hexadecimal -label dat_i {/dafk_tb/computer0/dafk_top/Sx[7]/dat_i}
add wave -noupdate -format Literal -radix hexadecimal -label dat_o {/dafk_tb/computer0/dafk_top/Sx[7]/dat_o}
add wave -noupdate -format Logic -radix hexadecimal -label stb {/dafk_tb/computer0/dafk_top/Sx[7]/stb}
add wave -noupdate -format Logic -radix hexadecimal -label we {/dafk_tb/computer0/dafk_top/Sx[7]/we}
TreeUpdate [SetDefaultTree]
update
