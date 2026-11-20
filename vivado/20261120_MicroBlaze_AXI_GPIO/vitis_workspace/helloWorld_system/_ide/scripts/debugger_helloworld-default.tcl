# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: D:\AXI\vivado\20261120_MicroBlaze_AXI_GPIO\vitis_workspace\helloWorld_system\_ide\scripts\debugger_helloworld-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source D:\AXI\vivado\20261120_MicroBlaze_AXI_GPIO\vitis_workspace\helloWorld_system\_ide\scripts\debugger_helloworld-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Basys3 210183BB7A1BA" && level==0 && jtag_device_ctx=="jsn-Basys3-210183BB7A1BA-0362d093-0"}
fpga -file D:/AXI/vivado/20261120_MicroBlaze_AXI_GPIO/vitis_workspace/helloWorld/_ide/bitstream/gpio_design_1_wrapper.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw D:/AXI/vivado/20261120_MicroBlaze_AXI_GPIO/vitis_workspace/gpio_design_1_wrapper/export/gpio_design_1_wrapper/hw/gpio_design_1_wrapper.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow D:/AXI/vivado/20261120_MicroBlaze_AXI_GPIO/vitis_workspace/helloWorld/Debug/helloWorld.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
