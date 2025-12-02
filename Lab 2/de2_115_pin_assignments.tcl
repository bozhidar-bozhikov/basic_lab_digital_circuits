# Pin Assignment Script for DE2-115 Board
# Keyboard Driver with Display Project
# Matches keyboard_driver_display entity with 4 displays

# Clock (50 MHz)
set_location_assignment PIN_Y2 -to clock
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clock

# Reset button (KEY0)
set_location_assignment PIN_M23 -to reset
set_instance_assignment -name IO_STANDARD "2.5 V" -to reset

# PS/2 Keyboard Interface
set_location_assignment PIN_G6 -to ps2_clk
set_location_assignment PIN_H5 -to ps2_data
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ps2_clk
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to ps2_data

# 7-Segment Display HEX7 (seg_h_h - High nibble, high digit)
set_location_assignment PIN_H22 -to seg_h_h[0]
set_location_assignment PIN_J22 -to seg_h_h[1]
set_location_assignment PIN_L25 -to seg_h_h[2]
set_location_assignment PIN_L26 -to seg_h_h[3]
set_location_assignment PIN_E17 -to seg_h_h[4]
set_location_assignment PIN_F22 -to seg_h_h[5]
set_location_assignment PIN_G18 -to seg_h_h[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to seg_h_h

# 7-Segment Display HEX6 (seg_h_l - High nibble, low digit)
set_location_assignment PIN_U24 -to seg_h_l[0]
set_location_assignment PIN_U23 -to seg_h_l[1]
set_location_assignment PIN_W25 -to seg_h_l[2]
set_location_assignment PIN_W22 -to seg_h_l[3]
set_location_assignment PIN_W21 -to seg_h_l[4]
set_location_assignment PIN_Y22 -to seg_h_l[5]
set_location_assignment PIN_M24 -to seg_h_l[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to seg_h_l

# 7-Segment Display HEX5 (seg_l_h - Low nibble, high digit)
set_location_assignment PIN_W28 -to seg_l_h[0]
set_location_assignment PIN_W27 -to seg_l_h[1]
set_location_assignment PIN_Y26 -to seg_l_h[2]
set_location_assignment PIN_W26 -to seg_l_h[3]
set_location_assignment PIN_Y25 -to seg_l_h[4]
set_location_assignment PIN_AA26 -to seg_l_h[5]
set_location_assignment PIN_AA25 -to seg_l_h[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to seg_l_h

# 7-Segment Display HEX4 (seg_l_l - Low nibble, low digit)
set_location_assignment PIN_Y19 -to seg_l_l[0]
set_location_assignment PIN_AF23 -to seg_l_l[1]
set_location_assignment PIN_AD24 -to seg_l_l[2]
set_location_assignment PIN_AA21 -to seg_l_l[3]
set_location_assignment PIN_AB20 -to seg_l_l[4]
set_location_assignment PIN_U21 -to seg_l_l[5]
set_location_assignment PIN_V21 -to seg_l_l[6]
set_instance_assignment -name IO_STANDARD "2.5 V" -to seg_l_l