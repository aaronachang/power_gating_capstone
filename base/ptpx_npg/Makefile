all: clean ptpx

ptpx:
	pt_shell -f my_pt.tcl | tee ptpx.log

clean:
	mkdir ../temp
	cp Makefile ../temp
	cp my_pt.tcl ../temp
	rm -r ./*
	cp ../temp/* .
	rm -r ../temp
