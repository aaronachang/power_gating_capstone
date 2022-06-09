TEST_INPUT=$(TEST)
ifdef TEST_INPUT
	DEFINE := +define+$(TEST_INPUT)
else
	DEFINE=""
endif

all: clean softlink_apr vcs dve

softlink_apr: softlink
	ln -s ../../src/assembler/*.v .
	ln -s ../../apr/results/cpu_top.apr.v .
	ln -s ../../apr/results/cpu_top.apr.sdf .
	ln -s ../../src/rtl/tb_cpu_top.apr.sv .

softlink:
	ln -s ../../src/rtl/datamem.sv .
	ln -s ../../src/rtl/instructmem.sv .
	ln -s ../../src/rtl/cpu_global_define.vh .

vcs:
	vcs -f cpu_apr.include +v2k -R -sverilog -full64 -debug_pp -timescale=1ns/10ps -l cpu.log $(DEFINE)

dve:
	dve -vpd vcdplus.vpd -full64 &

clean:
	mkdir ../temp
	cp Makefile ../temp
	cp cpu_apr.include ../temp
	rm -r ./*
	cp ../temp/Makefile .
	cp ../temp/cpu_apr.include .
	rm -r ../temp
