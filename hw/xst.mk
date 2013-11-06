# Makefile rules for synthesizing a project using XST
$(WD)/%.scr $(WD)/%.prj: $(VERILOGFILES)
	rm -f $(WD)/$*.prj; touch $(WD)/$*.prj
	if test -f /usr/bin/cygpath;then PATHCONV="cygpath -w";else PATHCONV=echo;fi;\
		for i in $(VERILOGFILES); do echo "verilog work \"`$$PATHCONV $$PWD/$$i`\"" >> $(WD)/$*.prj; done
	echo 'set -tmpdir tmpdir' > $(WD)/$*.scr
	echo 'set -xsthdpdir xst' >> $(WD)/$*.scr
	echo 'run -ifn $*.prj'							\
		'-ifmt mixed -ofn $*'						\
		'-ofmt NGC -p $(PART)'						\
		'-top $*'							\
		'-opt_mode Speed'						\
		'-opt_level 1'							\
		'-iuc NO'							\
		'-keep_hierarchy YES'						\
		'-rtlview Yes'							\
		'-glob_opt AllClockNets'					\
		'-read_cores YES'						\
		'-write_timing_constraints NO'					\
		'-cross_clock_analysis NO'					\
		'-hierarchy_separator /'					\
		'-bus_delimiter <>'						\
		'-case maintain'						\
		'-slice_utilization_ratio 100'					\
		'-verilog2001 YES'						\
		'-fsm_extract YES'						\
		'-fsm_encoding Auto'						\
		'-safe_implementation No'					\
		'-fsm_style lut'						\
		'-ram_extract Yes'						\
		'-ram_style Auto'						\
		'-rom_extract Yes'						\
		'-mux_style Auto'						\
		'-decoder_extract YES'						\
		'-priority_extract YES'						\
		'-shreg_extract NO'						\
		'-shift_extract YES'						\
		'-xor_collapse YES'						\
		'-rom_style Auto'						\
		'-mux_extract YES'						\
		'-resource_sharing YES '					\
		'-iobuf $(IOBUFINSERTION)'					\
		'-max_fanout 500'						\
		'-bufg 16'							\
		'-register_duplication YES'					\
		'-register_balancing No'					\
		'-slice_packing YES'						\
		'-optimize_primitives NO'					\
		'-use_clock_enable Auto'					\
		'-use_sync_set Auto'						\
		'-use_sync_reset Auto'						\
		'-iob true'							\
		'-equivalent_register_removal YES'				\
		'-slice_utilization_ratio_maxmargin 5' >> $(WD)/$*.scr


$(WD)/%.ngc: $(WD)/%.scr $(WD)/%.prj
	rm -rf $(WD)/tmpdir
	mkdir $(WD)/tmpdir
	rm -rf $(WD)/xst
	mkdir $(WD)/xst
	cd $(WD); $(NICE) xst -ifn $*.scr -ofn $*.syr

$(WD)/%.ngd: $(WD)/%.ngc %.ucf
	rm -rf $(WD)/_ngo
	mkdir $(WD)/_ngo
	cd $(WD); $(NICE) ngdbuild -sd . -dd _ngo -nt timestamp -p $(PART) -uc ../$*.ucf $*.ngc  $*.ngd

