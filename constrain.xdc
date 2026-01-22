# Basys3 流水线设计约束文件（对照手册/原理图验证无误）
set_property PART XC7A35T-1CPG236C [current_design]

# 1. 时钟约束
set_property PACKAGE_PIN W5 [get_ports clk_100mhz]
set_property IOSTANDARD LVCMOS33 [get_ports clk_100mhz]
create_clock -period 10.000 -name clk_100mhz [get_ports clk_100mhz]

# 2. 复位按键约束
set_property PACKAGE_PIN U18 [get_ports btn_reset]
set_property IOSTANDARD LVCMOS33 [get_ports btn_reset]
set_property PULLUP true [get_ports btn_reset]

# 3. 拨码开关约束
set_property PACKAGE_PIN V17 [get_ports {sw[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw[1]}]
set_property PACKAGE_PIN W16 [get_ports {sw[2]}]
set_property PACKAGE_PIN W17 [get_ports {sw[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {sw[*]}]
set_property PULLUP true [get_ports {sw[*]}]

# 4. LED 约束
set_property PACKAGE_PIN U16 [get_ports {led[0]}]
set_property PACKAGE_PIN E19 [get_ports {led[1]}]
set_property PACKAGE_PIN U19 [get_ports {led[2]}]
set_property PACKAGE_PIN V19 [get_ports {led[3]}]
set_property PACKAGE_PIN W18 [get_ports {led[4]}]
set_property PACKAGE_PIN U15 [get_ports {led[5]}]
set_property PACKAGE_PIN U14 [get_ports {led[6]}]
set_property PACKAGE_PIN V14 [get_ports {led[7]}]
set_property PACKAGE_PIN V13 [get_ports {led[8]}]
set_property PACKAGE_PIN V3  [get_ports {led[9]}]
set_property PACKAGE_PIN W3  [get_ports {led[10]}]
set_property PACKAGE_PIN U3  [get_ports {led[11]}]
set_property PACKAGE_PIN P3  [get_ports {led[12]}]
set_property PACKAGE_PIN N3  [get_ports {led[13]}]
set_property PACKAGE_PIN P1  [get_ports {led[14]}]
set_property PACKAGE_PIN L1  [get_ports {led[15]}]
set_property IOSTANDARD LVCMOS33 [get_ports {led[*]}]
set_property DRIVE 8 [get_ports {led[*]}]

# 5. 七段数码管约束
# 段选 seg[6:0] (CA-CG)
set_property PACKAGE_PIN W7  [get_ports {seg[0]}]
set_property PACKAGE_PIN W6  [get_ports {seg[1]}]
set_property PACKAGE_PIN U8  [get_ports {seg[2]}]
set_property PACKAGE_PIN V8  [get_ports {seg[3]}]
set_property PACKAGE_PIN U5  [get_ports {seg[4]}]
set_property PACKAGE_PIN V5  [get_ports {seg[5]}]
set_property PACKAGE_PIN U7  [get_ports {seg[6]}]

# 位选 an[3:0] (AN3-AN0)
set_property PACKAGE_PIN U2  [get_ports {an[3]}]
set_property PACKAGE_PIN U4  [get_ports {an[2]}]
set_property PACKAGE_PIN V4  [get_ports {an[1]}]
set_property PACKAGE_PIN W4  [get_ports {an[0]}]

set_property IOSTANDARD LVCMOS33 [get_ports {seg[*]}]
set_property IOSTANDARD LVCMOS33 [get_ports {an[*]}]
set_property DRIVE 8 [get_ports {seg[*]} {an[*]}]

# 6. 全局约束
set_property PULLDOWN true [get_ports -filter {DIRECTION == "IN" && !NAME =~ "clk_100mhz" && !NAME =~ "btn_reset" && !NAME =~ "sw[*]"}]