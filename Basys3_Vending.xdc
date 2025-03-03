###############################################################################
# Basys 3 Constraints for VendingMachineController
###############################################################################

## 1 Clock signal (100 MHz on Basys 3)
set_property PACKAGE_PIN W5 [get_ports {clk}]
set_property IOSTANDARD LVCMOS33 [get_ports {clk}]
create_clock -period 10.000 -name sys_clk -waveform {0 5} [get_ports {clk}]

## 2 Reset signal (map to an unused switch, e.g. SW15)
set_property PACKAGE_PIN R2 [get_ports {rst}]
set_property IOSTANDARD LVCMOS33 [get_ports {rst}]

## 3 Slide Switches for item selection (sw_item[1:0])
set_property PACKAGE_PIN V17 [get_ports {sw_item[0]}]  ;# SW0
set_property IOSTANDARD LVCMOS33 [get_ports {sw_item[0]}]
set_property PACKAGE_PIN V16 [get_ports {sw_item[1]}]  ;# SW1
set_property IOSTANDARD LVCMOS33 [get_ports {sw_item[1]}]

## 4 Push Buttons
# Basys 3 has 5 push buttons: 
#  - BTNU (Up)   on T18
#  - BTNL (Left) on W19
#  - BTNR (Right)on T17
#  - BTND (Down) on U17
#  - BTNC (Center) on U18

set_property PACKAGE_PIN T18 [get_ports {btnU}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnU}]

set_property PACKAGE_PIN W19 [get_ports {btnL}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnL}]

set_property PACKAGE_PIN T17 [get_ports {btnR}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnR}]

set_property PACKAGE_PIN U17 [get_ports {btnD}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnD}]

set_property PACKAGE_PIN U18 [get_ports {btnC}]
set_property IOSTANDARD LVCMOS33 [get_ports {btnC}]

## 5 On-board LEDs
# Use any two of the 16 LEDs for 'led_purchase' and 'led_insuff'
# Example: LED0 at U16, LED1 at E19
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN V13 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN V3 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN W3 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN U3 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN P3 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN N3 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN P1 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]
set_property -dict { PACKAGE_PIN L1 IOSTANDARD LVCMOS33 } [get_ports {led_purchase}]


#Insuffiencient LEDs lgiht u
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports {led_insuff}]

## 6) Seven-Segment Display (4 digits, common anode)
# segments: seg[7:0] => {CA,CB,CC,CD,CE,CF,CG,DP}
# anodes: an[3:0]

# Segment pins:
set_property PACKAGE_PIN W7 [get_ports {seg[0]}]  ;# CA
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]
set_property PACKAGE_PIN W6 [get_ports {seg[1]}]  ;# CB
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property PACKAGE_PIN U8 [get_ports {seg[2]}]  ;# CC
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property PACKAGE_PIN V8 [get_ports {seg[3]}]  ;# CD
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property PACKAGE_PIN U5 [get_ports {seg[4]}]  ;# CE
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property PACKAGE_PIN V5 [get_ports {seg[5]}]  ;# CF
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property PACKAGE_PIN U7 [get_ports {seg[6]}]  ;# CG
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
set_property PACKAGE_PIN V7 [get_ports {seg[7]}]  ;# DP
set_property IOSTANDARD LVCMOS33 [get_ports {seg[7]}]

# Digit anodes:
set_property PACKAGE_PIN U2 [get_ports {an[0]}]  ;# AN0 (rightmost)
set_property IOSTANDARD LVCMOS33 [get_ports {an[0]}]
set_property PACKAGE_PIN U4 [get_ports {an[1]}]  ;# AN1
set_property IOSTANDARD LVCMOS33 [get_ports {an[1]}]
set_property PACKAGE_PIN V4 [get_ports {an[2]}]  ;# AN2
set_property IOSTANDARD LVCMOS33 [get_ports {an[2]}]
set_property PACKAGE_PIN W4 [get_ports {an[3]}]  ;# AN3 (leftmost)
set_property IOSTANDARD LVCMOS33 [get_ports {an[3]}]

###############################################################################
# SPI Flash and other pins are not used here, so we leave them commented out.
# Also ensure these generic settings at the bottom:
###############################################################################

# Basic configuration
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO    [current_design]
set_property CONFIG_MODE SPIx4 [current_design]