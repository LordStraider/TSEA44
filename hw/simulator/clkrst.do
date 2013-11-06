onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock and reset)}
add wave -noupdate -format Logic -label sys_clk {/dafk_tb/computer0/dafk_top/sys_clk}
add wave -noupdate -format Logic -label rst {/dafk_tb/computer0/dafk_top/sys_rst}
TreeUpdate [SetDefaultTree]
update
