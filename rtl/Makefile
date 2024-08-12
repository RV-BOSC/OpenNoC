VCS ?= vcs
FILE_LIST_TB = file_list_tb.f
TOP_SRC = hnf
TOP_TB = tb_hnf
SIMV = simv
VCS_OPTS ?= -full64 +v2k -q -sverilog -fsdb +incdir+include+misc -Mupdate
VCS_OPTS += -debug_acc+dmptf -debug_region+cell+encrypt \
-pvalue+CHIE_REQ_ADDR_WIDTH_PARAM=44\
-pvalue+CHIE_SNP_ADDR_WIDTH_PARAM=41\
-pvalue+CHIE_NID_WIDTH_PARAM=7\
-pvalue+CHIE_DATA_WIDTH_PARAM=256\
-pvalue+CHIE_BE_WIDTH_PARAM=32\
-pvalue+CHIE_DATACHECK_WIDTH_PARAM=32\
-pvalue+CHIE_POISON_WIDTH_PARAM=4\
-pvalue+HNF_MSHR_RNF_NUM_PARAM=4\
-pvalue+RNF_NID_LIST_PARAM=100930568\
-pvalue+HNF_NID_PARAM=0\
-pvalue+SNF_NID_PARAM=32\
-pvalue+XP_LCRD_NUM_PARAM=15\
-pvalue+HNF_SF_ENTRIES_NUM_PARAM=131072\
-pvalue+HNF_SF_WAY_NUM_PARAM=16\
-pvalue+HNF_MSHR_EXCL_RN_NUM_PARAM=32\
-pvalue+HNF_MSHR_EXCL_RN_WIDTH_PARAM=5\
-pvalue+HNF_MSHR_ENTRIES_NUM_PARAM=32\
-pvalue+HNF_MSHR_ENTRIES_WIDTH_PARAM=5\
-pvalue+HNF_L3_CACHE_SIZE_PARAM=4096\
-pvalue+HNF_L3_WAY_NUM_PARAM=16
VCS_V2005 = -full64 +v2k -q -v2005 -fsdb +incdir+include+misc -debug_acc+dmptf -debug_region+cell+encrypt -Mupdate
VCS_OPTS_SRC := $(VCS_OPTS) -top $(TOP_SRC)
VCS_OPTS_TB  := $(VCS_OPTS) +incdir+src+misc -top $(TOP_TB)
all:com sim
com:
	$(VCS) $(VCS_OPTS_TB) -o $(SIMV) -f $(FILE_LIST_TB)
sim:
	./simv -l sim.log
run_dve:
	dve -full64 -vpd vcdplus.vpd &
clean:
	rm -rf csrc *.vpd *.fsdb *.daidir *.log simv* *.key DVEfiles vivado_syn_output *.conf *.rc verdiLog
