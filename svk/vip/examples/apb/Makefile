#***********************************************************
# *  Copyright (C) 2023 by JakodYuan (JakodYuan@outlook.com).
# *  All right reserved.
#************************************************************

default:run

cmp:
	vcs -full64 -sverilog -ntb_opts uvm-1.2 -f tb.f -l cmp.log -o simv -debug_access+all -kdb -lca -timescale=1ns/1ps -P ${VERDI_HOME}/share/PLI/VCS/LINUX64/novas.tab ${VERDI_HOME}/share/PLI/VCS/LINUX64/pli.a

run:cmp
	./simv +UVM_TESTNAME=apb_sanity -l sim.log

clean:
	rm -rf cmp.log
	rm -rf ./csrc
	rm -rf novas*
	rm -rf simv*
	rm -rf *.log
	rm -rf *.h
	rm -rf *.key
	rm -rf *.fsdb
