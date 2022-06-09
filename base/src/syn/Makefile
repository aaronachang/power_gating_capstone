.PHONY: syn clean

RESULTDIR=./results
REPORTDIR=./reports
LOGDIR=./results

syn:
	if [ ! -d $(RESULTDIR) ]; then mkdir $(RESULTDIR); fi
	if [ ! -d $(REPORTDIR) ]; then mkdir $(REPORTDIR); fi
	dc_shell -f ../src/syn/syn.tcl | tee $(LOGDIR)/syn.log

clean:
	-@ rm -rf $(LOGDIR) \
			  $(RESULTDIR) \
			  $(REPORTDIR) \
			  *defineVarRoute* \
			  *.db \
			  *.svf \
			  *.log \
			  Milkyway.* \
			  alib-52 \
			  WORK
