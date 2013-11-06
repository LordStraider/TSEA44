
# For precision:
$(WD)/%.scr: $(VERILOGFILES)
	rm -f $(WD)/$*.scr;
	echo set_results_dir $(WD) > $(WD)/$*.scr
	echo -n 'add_input_file {' >> $(WD)/$*.scr
	if test -f /usr/bin/cygpath;then PATHCONV="cygpath -m";else PATHCONV=echo;fi;\
		for i in $(VERILOGFILES); do echo -n " \"`$$PATHCONV "$$PWD/$$i"`\"" >> $(WD)/$*.scr; done
	echo '}' >> $(WD)/$*.scr
	echo 'setup_design -design $*' >> $(WD)/$*.scr
	echo 'setup_design -frequency 40' >> $(WD)/$*.scr
	echo 'setup_design -manufacturer Xilinx -family VIRTEX-II -part 2V4000ff1152 -speed 4' >> $(WD)/$*.scr
	echo 'compile' >> $(WD)/$*.scr
	echo 'synthesize' >> $(WD)/$*.scr

$(WD)/%.edf: $(WD)/%.scr
	$(NICE) $(PRECISION) -shell -file $(WD)/$*.scr

$(WD)/%.ngd: $(WD)/%.edf %.ucf
	rm -rf $(WD)/_ngo
	mkdir $(WD)/_ngo
	cp *.edn $(WD)
	cd $(WD); $(XILINX_INIT) ngdbuild -dd _ngo -nt timestamp -p $(PART) -uc $(PWD)/$*.ucf $*.edf  $*.ngd
