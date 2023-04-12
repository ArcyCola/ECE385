# Legal Notice: (C)2023 Altera Corporation. All rights reserved.  Your
# use of Altera Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any
# output files any of the foregoing (including device programming or
# simulation files), and any associated documentation or information are
# expressly subject to the terms and conditions of the Altera Program
# License Subscription Agreement or other applicable license agreement,
# including, without limitation, that your use is for the sole purpose
# of programming logic devices manufactured by Altera and sold by Altera
# or its authorized distributors.  Please refer to the applicable
# agreement for further details.

#**************************************************************
# Timequest JTAG clock definition
#   Uncommenting the following lines will define the JTAG
#   clock in TimeQuest Timing Analyzer
#**************************************************************

#create_clock -period 10MHz {altera_reserved_tck}
#set_clock_groups -asynchronous -group {altera_reserved_tck}

#**************************************************************
# Set TCL Path Variables 
#**************************************************************

set 	FP_TLOZ_soc_nios2_gen2_0_cpu 	FP_TLOZ_soc_nios2_gen2_0_cpu:*
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_oci 	FP_TLOZ_soc_nios2_gen2_0_cpu_nios2_oci:the_FP_TLOZ_soc_nios2_gen2_0_cpu_nios2_oci
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_oci_break 	FP_TLOZ_soc_nios2_gen2_0_cpu_nios2_oci_break:the_FP_TLOZ_soc_nios2_gen2_0_cpu_nios2_oci_break
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_ocimem 	FP_TLOZ_soc_nios2_gen2_0_cpu_nios2_ocimem:the_FP_TLOZ_soc_nios2_gen2_0_cpu_nios2_ocimem
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_oci_debug 	FP_TLOZ_soc_nios2_gen2_0_cpu_nios2_oci_debug:the_FP_TLOZ_soc_nios2_gen2_0_cpu_nios2_oci_debug
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_wrapper 	FP_TLOZ_soc_nios2_gen2_0_cpu_debug_slave_wrapper:the_FP_TLOZ_soc_nios2_gen2_0_cpu_debug_slave_wrapper
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_tck 	FP_TLOZ_soc_nios2_gen2_0_cpu_debug_slave_tck:the_FP_TLOZ_soc_nios2_gen2_0_cpu_debug_slave_tck
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sysclk 	FP_TLOZ_soc_nios2_gen2_0_cpu_debug_slave_sysclk:the_FP_TLOZ_soc_nios2_gen2_0_cpu_debug_slave_sysclk
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_oci_path 	 [format "%s|%s" $FP_TLOZ_soc_nios2_gen2_0_cpu $FP_TLOZ_soc_nios2_gen2_0_cpu_oci]
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_oci_break_path 	 [format "%s|%s" $FP_TLOZ_soc_nios2_gen2_0_cpu_oci_path $FP_TLOZ_soc_nios2_gen2_0_cpu_oci_break]
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_ocimem_path 	 [format "%s|%s" $FP_TLOZ_soc_nios2_gen2_0_cpu_oci_path $FP_TLOZ_soc_nios2_gen2_0_cpu_ocimem]
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_oci_debug_path 	 [format "%s|%s" $FP_TLOZ_soc_nios2_gen2_0_cpu_oci_path $FP_TLOZ_soc_nios2_gen2_0_cpu_oci_debug]
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_tck_path 	 [format "%s|%s|%s" $FP_TLOZ_soc_nios2_gen2_0_cpu_oci_path $FP_TLOZ_soc_nios2_gen2_0_cpu_wrapper $FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_tck]
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sysclk_path 	 [format "%s|%s|%s" $FP_TLOZ_soc_nios2_gen2_0_cpu_oci_path $FP_TLOZ_soc_nios2_gen2_0_cpu_wrapper $FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sysclk]
set 	FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sr 	 [format "%s|*sr" $FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_tck_path]

#**************************************************************
# Set False Paths
#**************************************************************

set_false_path -from [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_oci_break_path|break_readreg*] -to [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sr*]
set_false_path -from [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_oci_debug_path|*resetlatch]     -to [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sr[33]]
set_false_path -from [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_oci_debug_path|monitor_ready]  -to [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sr[0]]
set_false_path -from [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_oci_debug_path|monitor_error]  -to [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sr[34]]
set_false_path -from [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_ocimem_path|*MonDReg*] -to [get_keepers *$FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sr*]
set_false_path -from *$FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sr*    -to *$FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sysclk_path|*jdo*
set_false_path -from sld_hub:*|irf_reg* -to *$FP_TLOZ_soc_nios2_gen2_0_cpu_jtag_sysclk_path|ir*
set_false_path -from sld_hub:*|sld_shadow_jsm:shadow_jsm|state[1] -to *$FP_TLOZ_soc_nios2_gen2_0_cpu_oci_debug_path|monitor_go
