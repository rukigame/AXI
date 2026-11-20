# Usage with Vitis IDE:
# In Vitis IDE create a Single Application Debug launch configuration,
# change the debug type to 'Attach to running target' and provide this 
# tcl script in 'Execute Script' option.
# Path of this script: D:\AXI\vivado\20261120_MicroBlaze_AXI_GPIO\vitis_workspace2\led_button_system\_ide\scripts\debugger_led_button-default.tcl
# 
# 
# Usage with xsct:
# To debug using xsct, launch xsct and run below command
# source D:\AXI\vivado\20261120_MicroBlaze_AXI_GPIO\vitis_workspace2\led_button_system\_ide\scripts\debugger_led_button-default.tcl
# 
connect -url tcp:127.0.0.1:3121
targets -set -filter {jtag_cable_name =~ "Digilent Basys3 210183BB7A1BA" && level==0 && jtag_device_ctx=="jsn-Basys3-210183BB7A1BA-0362d093-0"}
fpga -file D:/AXI/vivado/20261120_MicroBlaze_AXI_GPIO/vitis_workspace2/led_button/_ide/bitstream/gpio_design_1_wrapper_16led_4button.bit
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
loadhw -hw D:/AXI/vivado/20261120_MicroBlaze_AXI_GPIO/vitis_workspace2/gpio_design_1_wrapper_16led_4button/export/gpio_design_1_wrapper_16led_4button/hw/gpio_design_1_wrapper_16led_4button.xsa -regs
configparams mdm-detect-bscan-mask 2
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
rst -system
after 3000
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
dow D:/AXI/vivado/20261120_MicroBlaze_AXI_GPIO/vitis_workspace2/led_button/Debug/led_button.elf
targets -set -nocase -filter {name =~ "*microblaze*#0" && bscan=="USER2" }
con
