onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Slave 0 (SDRAM)}
add wave -noupdate -format Logic -radix hexadecimal -label ack {/dafk_tb/computer0/dafk_top/Sx[0]/ack}
add wave -noupdate -format Literal -radix hexadecimal -label addr {/dafk_tb/computer0/dafk_top/Sx[0]/adr}
add wave -noupdate -format Logic -radix hexadecimal -label cyc {/dafk_tb/computer0/dafk_top/Sx[0]/cyc}
add wave -noupdate -format Literal -radix hexadecimal -label dat_i {/dafk_tb/computer0/dafk_top/Sx[0]/dat_i}
add wave -noupdate -format Literal -radix hexadecimal -label dat_o {/dafk_tb/computer0/dafk_top/Sx[0]/dat_o}
add wave -noupdate -format Logic -radix hexadecimal -label err {/dafk_tb/computer0/dafk_top/Sx[0]/err}
add wave -noupdate -format Literal -radix hexadecimal -label sel {/dafk_tb/computer0/dafk_top/Sx[0]/sel}
add wave -noupdate -format Logic -radix hexadecimal -label stb {/dafk_tb/computer0/dafk_top/Sx[0]/stb}
add wave -noupdate -format Logic -radix hexadecimal -label we {/dafk_tb/computer0/dafk_top/Sx[0]/we}
TreeUpdate [SetDefaultTree]
update
