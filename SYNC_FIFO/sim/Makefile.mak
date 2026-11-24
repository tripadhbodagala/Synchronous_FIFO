 
#Makefile for UVM Testbench - fifo

# SIMULATOR = Questa for Mentor's Questasim
# SIMULATOR = VCS for Synopsys's VCS

SIMULATOR = VCS# Makefile for UVM Testbench - sync FIFO
#
# Run from the sub-directory that the ../ paths below are relative to.
#
#   VCS   (default) : make run_test
#   Questa          : make run_test SIMULATOR=Questa

# SIMULATOR = Questa for Mentor's Questasim
# SIMULATOR = VCS    for Synopsys's VCS
SIMULATOR ?= VCS

FSDB_PATH = /home/cad/eda/SYNOPSYS/VERDI_2022/verdi/T-2022.06-SP1/share/PLI/VCS/LINUX64

# ---------------------------- Source files (order matters) ----------------------------
RTL   = ../sync_fifo.sv
INTF  = ../fifo_if.sv
SVTB2 = ../fifo_pkg.sv
SVTB1 = ../top.sv
INC   = +incdir+../../fifo

# Questa library name (no trailing comment on this line, it would add a space)
work  = work

# ---------------------------- Test names (replace with your FIFO tests) ----------------------------
TEST  = test
TEST1 = test
TEST2 = test
TEST3 = test

# ---------------------------- Questa options ----------------------------
VSIMOPT    = -vopt -voptargs=+acc
VSIMCOV    = -coverage -sva
VSIMBATCH1 = -c -do "log -r /* ;coverage save -onexit mem_cov1;run -all; exit"
VSIMBATCH2 = -c -do "log -r /* ;coverage save -onexit mem_cov2;run -all; exit"
VSIMBATCH3 = -c -do "log -r /* ;coverage save -onexit mem_cov3;run -all; exit"

.PHONY: help clean sv_cmp run_test run_test1 run_test2 run_test3 \
        view_wave1 view_wave2 view_wave3 view_wave4 regress report cov \
        sv_cmp_VCS run_test_VCS run_test1_VCS run_test2_VCS run_test3_VCS \
        report_VCS clean_VCS cov_VCSVSIMBATCH4 = -c -do "log -r /* ;coverage save -onexit mem_cov4;run -all; exit"




help:
        @echo "=============================================================================================================="
        @echo "! USAGE   --  make target [SIMULATOR=VCS|Questa]   (default: VCS)                                              !"
        @echo "! clean      =>  clean the earlier log and intermediate files.                                                !"
        @echo "! sv_cmp     =>  compile the code (creates the library for Questa).                                           !"
        @echo "! run_test   =>  clean, compile & run $(TEST) in batch mode.                                                  !"
        @echo "! run_test1  =>  run $(TEST1) in batch mode (needs a prior compile).                                          !"
        @echo "! run_test2  =>  run $(TEST2) in batch mode (needs a prior compile).                                          !"
        @echo "! run_test3  =>  run $(TEST3) in batch mode (needs a prior compile).                                          !"
        @echo "! view_wave1 =>  view the waveform of run_test                                                                !"
        @echo "! view_wave2 =>  view the waveform of run_test1                                                               !"
        @echo "! view_wave3 =>  view the waveform of run_test2                                                               !"
        @echo "! view_wave4 =>  view the waveform of run_test3                                                               !"
        @echo "! regress    =>  clean, compile and run all testcases in batch mode.                                          !"
        @echo "! report     =>  merge coverage of all testcases and convert to html format.                                  !"
        @echo "! cov        =>  open the merged coverage report.                                                             !"
        @echo "=============================================================================================================="

clean      : clean_$(SIMULATOR)
sv_cmp     : sv_cmp_$(SIMULATOR)
run_test   : run_test_$(SIMULATOR)
run_test1  : run_test1_$(SIMULATOR)
run_test2  : run_test2_$(SIMULATOR)
run_test3  : run_test3_$(SIMULATOR)
view_wave1 : view_wave1_$(SIMULATOR)
view_wave2 : view_wave2_$(SIMULATOR)
view_wave3 : view_wave3_$(SIMULATOR)
view_wave4 : view_wave4_$(SIMULATOR)
regress    : regress_$(SIMULATOR)
report     : report_$(SIMULATOR)
cov        : cov_$(SIMULATOR)

# ----------------------------- Mentor's Questa targets -------------------------------#

sv_cmp_Questa:
        vlib $(work)
        vmap work $(work)
        vlog -work $(work) +cover=bcesf $(RTL) $(INTF) $(INC) $(SVTB2) $(SVTB1)

run_test_Questa: clean_Questa sv_cmp_Questa
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH1) -wlf wave_file1.wlf -l test1.log -sv_seed random work.top +UVM_TESTNAME=$(TEST)
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov1

run_test1_Questa:
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH2) -wlf wave_file2.wlf -l test2.log -sv_seed random work.top +UVM_TESTNAME=$(TEST1)
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov2

run_test2_Questa:
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH3) -wlf wave_file3.wlf -l test3.log -sv_seed random work.top +UVM_TESTNAME=$(TEST2)
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov3

run_test3_Questa:
        vsim -cvgperinstance $(VSIMOPT) $(VSIMCOV) $(VSIMBATCH4) -wlf wave_file4.wlf -l test4.log -sv_seed random work.top +UVM_TESTNAME=$(TEST3)
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov4

view_wave1_Questa:
        vsim -view wave_file1.wlf

view_wave2_Questa:
        vsim -view wave_file2.wlf

view_wave3_Questa:
        vsim -view wave_file3.wlf

view_wave4_Questa:
        vsim -view wave_file4.wlf

report_Questa:
        vcover merge mem_cov mem_cov1 mem_cov2 mem_cov3 mem_cov4
        vcover report -cvg -details -nocompactcrossbins -codeAll -assert -directive -html mem_cov

regress_Questa: clean_Questa sv_cmp_Questa run_test_Questa run_test1_Questa run_test2_Questa run_test3_Questa report_Questa cov_Questa

cov_Questa:
        firefox covhtmlreport/index.html &

clean_Questa:
        rm -rf transcript* *log* fcover* covhtml* mem_cov* *.wlf modelsim.ini work
        -@clear

# ----------------------------- Synopsys's VCS targets ------------------------------- #

# Coverage metrics
CM = line+cond+fsm+tgl+branch+assert

# Compile-time coverage database
CM_COMPILE = ./simv.vdb

# Individual runtime coverage databases
CM_RUN1 = ./mem_cov1
CM_RUN2 = ./mem_cov2
CM_RUN3 = ./mem_cov3
CM_RUN4 = ./mem_cov4


# ----------------------------- Compilation ------------------------------------------- #

sv_cmp_VCS:
        vcs -l vcs.log \
            -timescale=1ns/1ps \
            -sverilog \
            -ntb_opts uvm \
            -debug_access+all \
            -full64 \
            -kdb \
            -lca \
            -cm $(CM) \
            -cm_dir $(CM_COMPILE) \
            -P $(FSDB_PATH)/novas.tab \
            $(FSDB_PATH)/pli.a \
            $(RTL) $(INTF) $(INC) $(SVTB2) $(SVTB1)


# ----------------------------- Test 1 ----------------------------------------------- #

run_test_VCS: clean_VCS sv_cmp_VCS
        ./simv -a simv1.log \
            +fsdbfile+wave1.fsdb \
            -cm $(CM) \
            -cm_dir $(CM_RUN1) \
            +ntb_random_seed_automatic \
            +UVM_TESTNAME=$(TEST)

        urg -full64 \
            -dir $(CM_COMPILE) $(CM_RUN1).vdb \
            -format both \
            -report urgReport1


# ----------------------------- Test 2 ----------------------------------------------- #

run_test1_VCS:
        ./simv -a simv2.log \
            +fsdbfile+wave2.fsdb \
            -cm $(CM) \
            -cm_dir $(CM_RUN2) \
            +ntb_random_seed_automatic \
            +UVM_TESTNAME=$(TEST1)

        urg -full64 \
            -dir $(CM_COMPILE) $(CM_RUN2).vdb \
            -format both \
            -report urgReport2


# ----------------------------- Test 3 ----------------------------------------------- #

run_test2_VCS:
        ./simv -a simv3.log \
            +fsdbfile+wave3.fsdb \
            -cm $(CM) \
            -cm_dir $(CM_RUN3) \
            +ntb_random_seed_automatic \
            +UVM_TESTNAME=$(TEST2)

        urg -full64 \
            -dir $(CM_COMPILE) $(CM_RUN3).vdb \
            -format both \
            -report urgReport3


# ----------------------------- Test 4 ----------------------------------------------- #

run_test3_VCS:
        ./simv -a simv4.log \
            +fsdbfile+wave4.fsdb \
            -cm $(CM) \
            -cm_dir $(CM_RUN4) \
            +ntb_random_seed_automatic \
            +UVM_TESTNAME=$(TEST3)

        urg -full64 \
            -dir $(CM_COMPILE) $(CM_RUN4).vdb \
            -format both \
            -report urgReport4


# ----------------------------- Waveform Viewing ------------------------------------- #

view_wave1_VCS:
        verdi -ssf wave1.fsdb

view_wave2_VCS:
        verdi -ssf wave2.fsdb

view_wave3_VCS:
        verdi -ssf wave3.fsdb

view_wave4_VCS:
        verdi -ssf wave4.fsdb


# ----------------------------- Coverage Merge --------------------------------------- #

report_VCS:
        urg -full64 \
            -dir $(CM_COMPILE) \
                 $(CM_RUN1).vdb \
                 $(CM_RUN2).vdb \
                 $(CM_RUN3).vdb \
                 $(CM_RUN4).vdb \
            -dbname merged_dir/merged_test \
            -format both \
            -report urgReport


# ----------------------------- Regression ------------------------------------------- #

regress_VCS: clean_VCS sv_cmp_VCS run_test_VCS run_test1_VCS run_test2_VCS run_test3_VCS report_VCS


# ----------------------------- Coverage GUI ----------------------------------------- #

cov_VCS:
        verdi -cov -covdir merged_dir/merged_test.vdb


# ----------------------------- Clean ------------------------------------------------ #

clean_VCS:
        rm -rf simv simv.daidir csrc *.tmp *.vpd *.vdb *.key *.log
        rm -rf urgReport* merged_dir *.fsdb novas* verdi*
        -@clear
        clear                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    