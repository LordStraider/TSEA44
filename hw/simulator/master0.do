onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Master 0 (ICache)}
add wave -noupdate -format Logic -radix hexadecimal -label ack {/dafk_tb/computer0/dafk_top/Mx[0]/ack}
add wave -noupdate -format Literal -radix hexadecimal -label adr {/dafk_tb/computer0/dafk_top/Mx[0]/adr}
add wave -noupdate -format Literal -radix hexadecimal -label bte {/dafk_tb/computer0/dafk_top/Mx[0]/bte}
add wave -noupdate -format Literal -radix hexadecimal -label cti {/dafk_tb/computer0/dafk_top/Mx[0]/cti}
add wave -noupdate -format Logic -radix hexadecimal -label cyc {/dafk_tb/computer0/dafk_top/Mx[0]/cyc}
add wave -noupdate -format Literal -radix hexadecimal -label dat_i {/dafk_tb/computer0/dafk_top/Mx[0]/dat_i}
add wave -noupdate -format Literal -radix hexadecimal -label dat_o {/dafk_tb/computer0/dafk_top/Mx[0]/dat_o}
add wave -noupdate -format Logic -radix hexadecimal -label err {/dafk_tb/computer0/dafk_top/Mx[0]/err}
add wave -noupdate -format Logic -radix hexadecimal -label rty {/dafk_tb/computer0/dafk_top/Mx[0]/rty}
add wave -noupdate -format Literal -radix hexadecimal -label sel {/dafk_tb/computer0/dafk_top/Mx[0]/sel}
add wave -noupdate -format Logic -radix hexadecimal -label stb {/dafk_tb/computer0/dafk_top/Mx[0]/stb}
add wave -noupdate -format Logic -radix hexadecimal -label we {/dafk_tb/computer0/dafk_top/Mx[0]/we}
TreeUpdate [SetDefaultTree]
update
