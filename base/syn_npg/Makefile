.PHONY: clean syn

all: syn

RESULTDIR=./results
REPORTDIR=./reports
LOGDIR=./results

syn:
	if [ ! -d $(RESULTDIR) ]; then mkdir $(RESULTDIR); fi
	if [ ! -d $(REPORTDIR) ]; then mkdir $(REPORTDIR); fi
	dc_shell -f ../src/syn_npg/syn.tcl | tee $(LOGDIR)/syn.log

clean:
	cp Makefile ../.
	rm -r ./*
	cp ../Makefile .
	rm ../Makefile
