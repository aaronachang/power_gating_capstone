TEST_INPUT=$(TEST)
ifdef TEST_INPUT
	DEFINE := +define+$(TEST_INPUT)
else
	DEFINE=""
endif

all: clean softlink_verilog vcs dve

softlink_verilog:
	ln -s ../../src/rtl/* .
	ln -s ../../src/assembler/*.v .

vcs:
	vcs -f cpu.include +v2k -R -sverilog -full64 -debug_pp -timescale=1ns/10ps -l cpu.log $(DEFINE)

dve:
	dve -vpd vcdplus.vpd -full64 &

clean:
	mkdir ../temp
	cp Makefile ../temp
	rm -r ./*
	cp ../temp/Makefile .
	rm -r ../temp
