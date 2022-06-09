TEST_INPUT=$(TEST)
ifdef TEST_INPUT
	DEFINE := +define+$(TEST_INPUT)
else
	DEFINE=""
endif

all: softlink_syn vcs dve

softlink_syn: softlink
	ln -s ../../src/assembler/*.v .
	ln -s ../../syn/results/cpu_top.syn.v .
	ln -s ../../syn/results/cpu_top.syn.sdf .
	ln -s ../../src/rtl/tb_cpu_top.syn.sv .

softlink:
	ln -s ../../src/rtl/datamem.sv .
	ln -s ../../src/rtl/instructmem.sv .
	ln -s ../../src/rtl/cpu_global_define.vh .

vcs:
	vcs -f cpu_syn.include +v2k -R -sverilog -full64 -debug_pp -timescale=1ns/10ps -l cpu.log $(DEFINE)

dve:
	dve -vpd vcdplus.vpd -full64 &

clean:
	mkdir ../temp
	cp Makefile ../temp
	cp cpu_syn.include ../temp
	rm -r ./*
	cp ../temp/Makefile .
	cp ../temp/cpu_syn.include .
	rm -r ../temp
