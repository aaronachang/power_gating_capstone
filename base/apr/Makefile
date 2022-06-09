all: clean softlink apr

RESULTDIR=./results
REPORTDIR=./reports
LOGDIR=./results

softlink:
	ln -s ../syn/results/cpu_top.syn.v
	ln -s ../syn/results/cpu_top.syn.sdc
	ln -s ../src/apr/pin_placement.txt

apr:
	if [ ! -d $(RESULTDIR) ]; then mkdir $(RESULTDIR); fi
	if [ ! -d $(REPORTDIR) ]; then mkdir $(REPORTDIR); fi
	icc_shell -64bit -shared_license -f ../src/apr/apr.tcl | tee $(LOGDIR)/apr.log

clean:
	cp Makefile ../Makefile
	rm -r ./*
	cp ../Makefile .
	rm ../Makefile

