##################################################################################
# The part we are going to run the design on
PART=xc2v4000-4-ff1152
##################################################################################

##################################################################################
# Initialize the Xilinx tools by sourcing settings.sh before starting
# the respective tool.
# The reason for doing this is that Xilinx is using its own libraries which
# don't match the system libraries.
##################################################################################

# in Muxen
XILINX_INIT=. /sw/xilinx/ise_10.1i-x86_64/ISE/settings64.csh;$(NICE)
SIMLIB=/sw/xilinx/ise_11.1i/ISE/verilog/mti_se
NOBACKUPDIR=/nobackup/local/$(USER)

# on Olles computer
#XILINX_INIT=. /opt/Xilinx/10.1/ISE/settings64.sh;$(NICE)
#SIMLIB=/opt/Xilinx/10.1/ISE/verilog/mti_se
#NOBACKUPDIR=/nobackup/local/$(USERNAME)

##################################################################################
# Here is a list of the files needed for various parts of the design
##################################################################################


PROCESSOR_FILES= or1200/or1200_alu.sv or1200/or1200_except.v			\
	or1200/or1200_mem2reg.v							\
	or1200/or1200_amultp2_32x32.v or1200/or1200_freeze.v			\
	or1200/or1200_mult_mac.v or1200/or1200_sprs.sv or1200/or1200_cfgr.v	\
	or1200/or1200_genpc.v or1200/or1200_operandmuxes.v or1200/or1200_top.sv	\
	or1200/or1200_cpu.v or1200/or1200_gmultp2_32x32.v			\
	or1200/or1200_pic.v							\
	or1200/or1200_tt.v or1200/or1200_ctrl.sv or1200/or1200_ic_fsm.v		\
	or1200/or1200_pm.v or1200/or1200_dc_fsm.v				\
	or1200/or1200_ic_ram.v or1200/or1200_qmem_top.v				\
	or1200/or1200_dc_ram.v or1200/or1200_ic_tag.v				\
	or1200/or1200_reg2mem.v or1200/or1200_wb_biu.v or1200/or1200_dc_tag.v	\
	or1200/or1200_ic_top.v							\
	or1200/or1200_wbmux.v or1200/or1200_dc_top.v or1200/or1200_if.v		\
	or1200/or1200_rf.v							\
	or1200/or1200_dmmu_tlb.v or1200/or1200_immu_tlb.v			\
	or1200/or1200_sb_fifo.v  or1200/or1200_dmmu_top.v			\
	or1200/or1200_immu_top.v or1200/or1200_sb.v				\
	or1200/or1200_dpram_32x32.v or1200/or1200_iwb_biu.v			\
	or1200/or1200_du.v or1200/or1200_lsu.sv or1200/or1200_spram_2048x32.v	\
	or1200/or1200_spram_2048x32_bw.v or1200/or1200_spram_512x20.v		\
	or1200/or1200_vlx_ctrl.sv or1200/or1200_vlx_dp.sv or1200/or1200_vlx_su.sv	\
	or1200/or1200_vlx_top.sv

DCT_FILES=jpeg/dct.sv jpeg/q2.sv jpeg/jpeg_dma.sv jpeg/jpeg_top.sv jpeg/transpose.sv	\
	jpeg/addrgen.sv

DCM_FILES=clk/clkdel.v  clk/clkdiv.v  clk/sys_sig_gen.v

VGA_FILES=dvga/dpram512w.v dvga/dvga_reg.v dvga/dvga_sprite_post.v	        \
	dvga/dvga_sprite_rend.v dvga/dvga_top.sv dvga/dvga_fifo64x32.v	        \
	dvga/dvga_renderer.v dvga/dvga_sprite_pre.v dvga/dvga_sprite.v

ETHERNET_FILES=eth/eth_clockgen.v eth/eth_outputcontrol.v			\
	eth/eth_rxethmac.v eth/eth_txethmac.v eth/eth_cop.v eth/eth_random.v	\
	eth/eth_rxstatem.v eth/eth_txstatem.v eth/eth_crc.v			\
	eth/eth_receivecontrol.v eth/eth_shiftreg.v eth/eth_wishbone.v		\
	eth/eth_fifo.v eth/eth_registers.v eth/eth_spram_256x32.v		\
	eth/timescale.v eth/eth_maccontrol.v eth/eth_register.v			\
	eth/eth_top.sv eth/xilinx_dist_ram_16x32.v eth/eth_macstatus.v		\
	eth/eth_rxaddrcheck.v eth/eth_transmitcontrol.v eth/eth_miim.v		\
	eth/eth_rxcounters.v eth/eth_txcounters.v

LEELA_FILES=leela/generic_dpram.v leela/leela_cam_cam.v				\
	leela/leela_cam_sprite.v leela/leela_mc.v leela/leela_top.sv		\
	leela/generic_fifo_sc_a.v leela/leela_cam_sim.v leela/leela_cam.v	\
	leela/leela_reg.v

MONITOR_FILES=monitor/mon_prog_bram.sv  monitor/romram.sv

PKMC_FILES=pkmc/pkmc_sdramctrl_addgen.v						\
	pkmc/pkmc_sdramctrl_refcount.v pkmc/pkmc_commanddecoder.v		\
	pkmc/pkmc_sdramctrl_centralctrl.v pkmc/pkmc_sdramctrl_top.v		\
	pkmc/pkmc_flashctrl.v pkmc/pkmc_sdramctrl_fsm_all_one.v			\
	pkmc/pkmc_sramctrl.v pkmc/pkmc_mem_fpga_board_if.v			\
	pkmc/pkmc_sdramctrl_fsm_command.v pkmc/pkmc_top.sv pkmc/pkmc_rowcheck.v	\
	pkmc/pkmc_sdramctrl_fsm_sdramIRQ.v pkmc/pkmc_wbmemctrl_addrdecoder.v	\
	pkmc/pkmc_sdramctrl_ackgen.v pkmc/pkmc_sdramctrl_fsm.v			\
	pkmc/pkmc_wbmemctrl.v pkmc/pkmc_sdramctrl_activebanks.v			\
	pkmc/pkmc_sdramctrl_initcount.v


UART_FILES=uart/raminfr.v uart/uart_receiver.v uart/uart_rfifo.v		\
	uart/uart_top.sv uart/uart_wb.v uart/uart_debug_if.v uart/uart_regs.v	\
	uart/uart_tfifo.v uart/uart_transmitter.v


WB_FILES=wb/wb_arb_rr.sv wb/wb_arb_prio.sv wb/wb_top.sv interfaces/wishbone.sv

PARPORT_FILES=parport.sv

PERF_FILES=perf_top.sv

COMMON_FILES=$(PROCESSOR_FILES) $(MONITOR_FILES) $(WB_FILES)	\
	$(PARPORT_FILES) $(PERF_FILES) $(UART_FILES) $(DCM_FILES)


DAFK_FILES = dafk.sv $(COMMON_FILES) $(DCT_FILES) $(VGA_FILES) $(ETHERNET_FILES) $(LEELA_FILES) $(PKMC_FILES)

LAB0_FILES = lab0.sv
LAB1_FILES = lab1.sv $(LAB0_FILES) lab1/lab1_uart_top.sv $(PROCESSOR_FILES) \
	$(MONITOR_FILES) $(DCM_FILES) $(PARPORT_FILES) $(WB_FILES) $(PERF_FILES) \
	$(PKMC_FILES)

VERILOG_HEADERS=include/dafk_defines.v include/pkmc_flash_defines.v	\
	include/pkmc_memctrl_defines.v					\
	include/dvga_defines.v include/pkmc_sdram_commands.v		\
	include/timescale.v include/eth_defines.v			\
	include/pkmc_sdramctrl_fsm_parameters.v include/uart_defines.v	\
	include/eth_phy_defines.v include/pkmc_sdram_defines.v		\
	include/wb_conbus_defines.v include/or1200_defines.v		\
	include/pkmc_sram_defines.v include/wb_def.v


##################################################################################
# The work directory we are storing temporary files in
# We do this because Xilinx' tools has a tendency to spew
# out a lot of temporary files which would clutter up our main
# source directory.

WD=$(NOBACKUPDIR)/synthdir
#
# This is the location where ModelSim stores compiled modules
SIM_WD=$(NOBACKUPDIR)/work
##################################################################################

##################################################################################
# The niceness level you want to use for CPU demanding tools
# FIXME - might want to consider ionice here as well
NICE=nice -n 19
##################################################################################

##################################################################################
IOBUFINSERTION?=YES
PRECISION = precision
include precision.mk

# Rules for using XST to synthesize the design
# Use this instead if you want to use XST to synthesize the design
# (XST does not support System Verilog yet though...)
#include xst.mk
##################################################################################


all: dafk

# Use the "order-only" type prerequisite to insure that the firmware is
# built before dafk.bit

dafk: | check_workdirs fw buildnum dafk.bit
lab1: | check_workdirs fw buildnum lab1.bit
lab0: | check_workdirs fw buildnum lab0.bit

# Bump the build number
buildnum:
	i=$$(cut -d d -f 3 < include/buildnum.v);i=$$(($$i+1));echo "\`define BUILDREV 16'd$$i" > include/buildnum.v

# Shouldn't be required since dafk rules always calls
# the fw rule first...
monitor/firmware/src/mon_prog_bram_contents.v:
	make -C monitor/firmware/src

# Build the firmware directory
fw:
	make -C monitor/firmware/src


$(WD)/dafk.scr: VERILOGFILES=$(DAFK_FILES)
$(WD)/dafk.scr: $(DAFK_FILES) $(VERILOG_HEADERS) monitor/firmware/src/mon_prog_bram_contents.v

$(WD)/lab0.scr: VERILOGFILES= $(LAB0_FILES) 
$(WD)/lab0.scr: $(LAB0_FILES)

$(WD)/lab1.scr: VERILOGFILES= $(LAB1_FILES) 
$(WD)/lab1.scr: $(LAB1_FILES) $(VERILOG_HEADERS) monitor/firmware/src/mon_prog_bram_contents.v

###################################################################################
# There are no user servicable parts below this line...
###################################################################################

check_workdirs: | check_nobackupdir $(WD) $(SIM_WD)

# Make sure that we own $(NOBACKUPDIR). If it doesn't exist, create
# it. (And we will get an error message from mkdir and abort the
# compilation if we could not create it for some reason.
check_nobackupdir:
	@if ! test -O $(NOBACKUPDIR);\
	then\
		if ! mkdir $(NOBACKUPDIR);\
		then \
			echo "ERROR: You are not the owner of $(WD)";\
			false;\
		fi;\
	fi

# No need for intricate checks here since check_workdirs checks
# check_nobackupdir rule first.
$(WD):
	mkdir $(WD)

$(SIM_WD):
	mkdir $(SIM_WD)


# Do not remove these intermediate files since they are very time consuming to create
# (There is a little chance for mistakes here if (for example) a .ngd file is only
# partially written when the user interrupts ngdbuild with a ctrl-c. In this case
# make will erroneously think the .ngd file is ok and continue with the next step
# in the process instead of remaking the .ngd. make clean is your friend if this
# occurs...
.PRECIOUS: $(WD)/%.scr $(WD)/%.prj %.ncd $(WD)/%.ngc $(WD)/%.ngd $(WD)/%_map.ncd $(WD)/%.ncd $(WD)/%.edf  %.ncd %.bit

# The rules for creating a .bit file out of a synthesized design (see xst.mk or precision.mk for
# the synthesize rules)

# Map a design into the FPGA components
$(WD)/%_map.ncd: $(WD)/%.ngd
	cd $(WD); if test -f $*_old.ncd;then MAPOPTS="-smartguide $*_old.ncd";fi;$(XILINX_INIT) map $$MAPOPTS -detail -u -p  $(PART) -cm speed -pr b -k 4 -c 100 -o $*_map.ncd $*.ngd $*.pcf

# Rule for placing and routing a design
$(WD)/%.ncd: $(WD)/%_map.ncd
	cd $(WD); if test -f $*_old.ncd;then PAROPTS="-smartguide $*_old.ncd";fi;$(XILINX_INIT) par $$MAPOPTS -nopad -rl high -w  -ol high -pl high -t 1 $*_map.ncd $*.ncd $*.pcf 
	cd $(WD); cp $*.ncd $*_old.ncd

# Include the following if you need a timing report
# (Not really needed for this course since we do not expect to ever
# fail timing at 25 MHz)
#	cd $(WD); $(XILINX_INIT) trce -v 1000 $*.ncd $*.pcf


%.ncd: $(WD)/%.ncd
	cp $(WD)/$*.ncd .

# Generate a configuration file for the FPGA out of the Native Circuit Description
%.bit: %.ncd
	$(XILINX_INIT) bitgen -w $*.ncd $*.bit -g StartupClk:JtagClk


clean:
	rm -f *~ */*~
	rm -rf $(WD)/*
	rm -f *.bit *.ncd *.xdl *.cmd *.log *.drc *.bgn


##################################################################################
# Update the monitor inside dafk*.bit and name them as updated_dafk*.bit
# Useful if you want to try some changes in the monitor without having to
# synthesize the entire design.
##################################################################################
updatebit: fw
	for i in dafk.bit lab1.bit; do \
		if test -f $$i; then\
			echo Updating $$i;\
			$(XILINX_INIT) data2mem -bm monitor/firmware/d2m/memorymap.bmm -bd monitor/firmware/src/mon2.mem -bt $$i -o b updated_$$i;\
		fi;\
	done


##################################################################################
# Some stuff related to simulation
##################################################################################
LAB0_SIMFILES = dafk_tb/lab0_tb.sv $(LAB0_FILES)

SIMFILES=dafk_tb/128Kx8.v dafk_tb/adv_bb.v 	\
	dafk_tb/eth_phy.v			\
	dafk_tb/flash.v dafk_tb/mt48lc16m16a2.v dafk_tb/sdram.v		\
	dafk_tb/sram_1MB.v dafk_tb/uart_tasks.sv \
	dafk_tb/dafk_tb.sv dafk_tb/wishbone_tasks.sv $(COMMON_FILES)	\
	$(DCT_FILES) $(PKMC_FILES) $(ETHERNET_FILES) $(VGA_FILES)	\
	$(LEELA_FILES) dafk.sv jpeg/jpeg_top_tb.sv	\
	lab1.sv dafk_tb/lab1_tb.sv lab1/lab1_uart_top.sv lab1/uart_tb.sv \
	$(LAB0_SIMFILES)

# Actually we don't need to recompile all verilog files in some cases
# but it does not take a long time to do so. And in my defense, ISE
# recompiles all verilog files as well :)
#
# vmake in Modelsim can also be used to automatically generate a
# Makefile as well, but you will have to do some ugly stuff if a new
# source code file is added in that case.

UNISIMS=$(SIMLIB)/unisims_ver
XILINXCORELIB=$(SIMLIB)/xilinxcorelib_ver
SIMPRIMS=$(SIMLIB)/simprims_ver
SRC=$(SIMLIB)/../src

simfiles: check_workdirs  monitor/firmware/src/mon_prog_bram_contents.v
	cd simulator;vlib $(SIM_WD);vlog -work $(SIM_WD) +acc $(SRC)/glbl.v;for i in $(SIMFILES); do if ! vlog -work $(SIM_WD) +acc -sv +incdir+.. ../$$i; then exit 1;fi;done
	cp *.mif simulator

# tests the whole computer
sim:  |  fw simfiles
	cd simulator;if test -f /usr/bin/cygpath;then VSIM="cmd /c start vsim";else VSIM=vsim;fi;\
		$$VSIM -L $(UNISIMS) -L $(XILINXCORELIB) -lib $(SIM_WD) -t 1ps dafk_tb glbl

# tests the whole computer (no DCT, no eth, no VGA) with student UART
sim_lab1: | fw simfiles
	cd simulator;if test -f /usr/bin/cygpath;then VSIM="cmd /c start vsim";else VSIM=vsim;fi;\
		$$VSIM -L $(UNISIMS) -L $(XILINXCORELIB) -lib $(SIM_WD) -t 1ps lab1_tb glbl

# tests the JPEG acc (with WB interface)
sim_jpeg:  simfiles
	cd simulator;if test -f /usr/bin/cygpath;then VSIM="cmd /c start vsim";else VSIM=vsim;fi;\
		$$VSIM -L $(UNISIMS) -L $(XILINXCORELIB) -lib $(SIM_WD) -t 1ps jpeg_top_tb glbl

# tests the student UART (with WB interface)
sim_uart:  simfiles
	cd simulator;if test -f /usr/bin/cygpath;then VSIM="cmd /c start vsim";else VSIM=vsim;fi;\
		$$VSIM -L $(UNISIMS) -L $(XILINXCORELIB) -lib $(SIM_WD) -t 1ps suart_tb glbl

# tests lab0, part of UART
sim_lab0: | check_workdirs  $(LAB0_FILES) $(LAB0_SIMFILES)
	cd simulator;vlib $(SIM_WD); for i in $(LAB0_SIMFILES); do if ! vlog -work $(SIM_WD) -sv +acc ../$$i; then exit 1; fi ;done
	cd simulator;if test -f /usr/bin/cygpath;then VSIM="cmd /c start vsim";else VSIM=vsim;fi;\
		$$VSIM -lib $(SIM_WD) -t 1ps lab0_tb

prog:	
	utils/download.sh dafk.bit

prog_lab0:
	utils/download.sh lab0.bit

prog_lab1:
	utils/download.sh lab1.bit

##################################################################################
# Useful to see if we forgot to remove the complete solutions before creating a
# lab skeleton of the design :)
##################################################################################
fixme:
	@echo 'Checking for fixmes...'
	@if ! grep -r FIXME .| grep -v 'grep FIXME'|grep -v .svn; then echo No FIXMEs found.;fi
