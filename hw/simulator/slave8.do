onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Slave 8 (Leela)}
add wave -noupdate -format Logic -radix hexadecimal -label ack {/dafk_tb/computer0/dafk_top/Sx[8]/ack}
add wave -noupdate -format Literal -radix hexadecimal -label adr {/dafk_tb/computer0/dafk_top/Sx[8]/adr}
add wave -noupdate -format Literal -radix hexadecimal -label bte {/dafk_tb/computer0/dafk_top/Sx[8]/bte}
add wave -noupdate -format Literal -radix hexadecimal -label cti {/dafk_tb/computer0/dafk_top/Sx[8]/cti}
add wave -noupdate -format Logic -radix hexadecimal -label cyc {/dafk_tb/computer0/dafk_top/Sx[8]/cyc}
add wave -noupdate -format Literal -radix hexadecimal -label dat_i {/dafk_tb/computer0/dafk_top/Sx[8]/dat_i}
add wave -noupdate -format Literal -radix hexadecimal -label dat_o {/dafk_tb/computer0/dafk_top/Sx[8]/dat_o}
add wave -noupdate -format Logic -radix hexadecimal -label err {/dafk_tb/computer0/dafk_top/Sx[8]/err}
add wave -noupdate -format Literal -radix hexadecimal -label sel {/dafk_tb/computer0/dafk_top/Sx[8]/sel}
add wave -noupdate -format Logic -radix hexadecimal -label stb {/dafk_tb/computer0/dafk_top/Sx[8]/stb}
add wave -noupdate -format Logic -radix hexadecimal -label we {/dafk_tb/computer0/dafk_top/Sx[8]/we}
TreeUpdate [SetDefaultTree]
update
