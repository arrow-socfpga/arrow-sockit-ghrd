# 50MHz board input clock
create_clock -period 20 [get_ports clk_bot1]
create_clock -period 40 [get_ports hps_i2c1_SCL]
create_clock -period 40 [get_ports hps_usb1_CLK]
# for enhancing USB BlasterII to be reliable, 25MHz
create_clock -name {altera_reserved_tck} -period 40 {altera_reserved_tck}

derive_pll_clocks

# Clock Tree	
#	u0|pll_stream|altera_pll_i|general[0].gpll~FRACTIONAL_PLL|vcoph[0]
#	u0|pll_stream|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|vco0ph[0]
#	{ u0|pll_stream|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk }	

set tx_pclk_name "vga_clk"
create_generated_clock -name $tx_pclk_name -source [get_pins { u0|pll_stream|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk } ] [get_ports $tx_pclk_name]

#**************************************************************
# Set Clock Uncertainty
#**************************************************************  
derive_clock_uncertainty

#**************************************************************
# The following constraints are for miscelaneous input and 
# output pins in the design that are not constrained elsewhere.
#**************************************************************

# jtag interface
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdi]
set_input_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tms]
set_output_delay -clock altera_reserved_tck -clock_fall 3 [get_ports altera_reserved_tdo]

# *************************************************************
# VGA Outputs
# Constraining source synch interfaces: 
# https://www.altera.com/en_US/pdfs/literature/an/an433.pdf
# Single Data Rate with common data and output clocks
# Same edge capture edge aligned output
# *************************************************************
set_output_delay -max 2.6 -clock [get_clocks {vga_clk}] [get_ports {vga_b[*]}] 
set_output_delay -max 2.6 -clock [get_clocks {vga_clk}] [get_ports {vga_g[*]}] 
set_output_delay -max 2.6 -clock [get_clocks {vga_clk}] [get_ports {vga_r[*]}] 
set_output_delay -max 2.6 -clock [get_clocks {vga_clk}] [get_ports {vga_hs}] 
set_output_delay -max 2.6 -clock [get_clocks {vga_clk}] [get_ports {vga_vs}] 
 
# Zero hold at external capture register:
set_output_delay -min 0 -clock [get_clocks {vga_clk}] [get_ports {vga_b[*]}] -add_delay
set_output_delay -min 0 -clock [get_clocks {vga_clk}] [get_ports {vga_g[*]}] -add_delay 
set_output_delay -min 0 -clock [get_clocks {vga_clk}] [get_ports {vga_r[*]}] -add_delay  
set_output_delay -min 0 -clock [get_clocks {vga_clk}] [get_ports {vga_hs}] -add_delay 
set_output_delay -min 0 -clock [get_clocks {vga_clk}] [get_ports {vga_vs}] -add_delay 

# Same edge capture edge aligned output exceptions:
set_false_path -setup -rise_from [get_clocks {vga_clk}] -fall_to [get_clocks {vga_clk}]
set_false_path -setup -fall_from [get_clocks {vga_clk}] -rise_to [get_clocks {vga_clk}]
set_false_path -hold -rise_from [get_clocks {vga_clk}] -rise_to [get_clocks {vga_clk}]
set_false_path -hold -fall_from [get_clocks {vga_clk}] -fall_to [get_clocks {vga_clk}]

# FPGA IO port constraints
set_false_path -from [get_ports {user_pb_fpga[0]}] -to *
set_false_path -from [get_ports {user_pb_fpga[1]}] -to *
set_false_path -from [get_ports {user_pb_fpga[2]}] -to *
set_false_path -from [get_ports {user_pb_fpga[3]}] -to *
set_false_path -from [get_ports {user_dipsw_fpga[0]}] -to *
set_false_path -from [get_ports {user_dipsw_fpga[1]}] -to *
set_false_path -from [get_ports {user_dipsw_fpga[2]}] -to *
set_false_path -from [get_ports {user_dipsw_fpga[3]}] -to *
set_false_path -from * -to [get_ports {user_led_fpga[0]}]
set_false_path -from * -to [get_ports {user_led_fpga[1]}]
set_false_path -from * -to [get_ports {user_led_fpga[2]}]
set_false_path -from * -to [get_ports {user_led_fpga[3]}]

# HPS peripherals port false path setting to workaround the unconstraint path (setting false_path for hps_0 ports will not affect the routing as it is hard silicon)

set_false_path -from * -to [get_ports {hps_usb1_CLK}]
set_false_path -from * -to [get_ports {hps_emac1_TX_CLK}] 
set_false_path -from * -to [get_ports {hps_emac1_TXD0}] 
set_false_path -from * -to [get_ports {hps_emac1_TXD1}] 
set_false_path -from * -to [get_ports {hps_emac1_TXD2}] 
set_false_path -from * -to [get_ports {hps_emac1_TXD3}] 
set_false_path -from * -to [get_ports {hps_emac1_MDC}] 
set_false_path -from * -to [get_ports {hps_emac1_TX_CTL}] 
set_false_path -from * -to [get_ports {hps_qspi_SS0}] 
set_false_path -from * -to [get_ports {hps_qspi_CLK}] 
set_false_path -from * -to [get_ports {hps_sdio_CLK}] 
set_false_path -from * -to [get_ports {hps_usb1_STP}] 
set_false_path -from * -to [get_ports {hps_spim0_CLK}] 
set_false_path -from * -to [get_ports {hps_spim0_MOSI}] 
set_false_path -from * -to [get_ports {hps_spim0_SS0}] 
set_false_path -from * -to [get_ports {hps_spim1_CLK}] 
set_false_path -from * -to [get_ports {hps_spim1_MOSI}] 
set_false_path -from * -to [get_ports {hps_spim1_SS0}] 
set_false_path -from * -to [get_ports {hps_spim1_MISO}] 
set_false_path -from * -to [get_ports {hps_uart0_TX}] 
set_false_path -from * -to [get_ports {hps_can0_TX}] 

set_false_path -from * -to [get_ports {hps_emac1_MDIO}] 
set_false_path -from * -to [get_ports {hps_qspi_IO0}] 
set_false_path -from * -to [get_ports {hps_qspi_IO1}] 
set_false_path -from * -to [get_ports {hps_qspi_IO2}] 
set_false_path -from * -to [get_ports {hps_qspi_IO3}] 
set_false_path -from * -to [get_ports {hps_sdio_CMD}] 
set_false_path -from * -to [get_ports {hps_sdio_D0}] 
set_false_path -from * -to [get_ports {hps_sdio_D1}] 
set_false_path -from * -to [get_ports {hps_sdio_D2}] 
set_false_path -from * -to [get_ports {hps_sdio_D3}] 
set_false_path -from * -to [get_ports {hps_usb1_D0}] 
set_false_path -from * -to [get_ports {hps_usb1_D1}] 
set_false_path -from * -to [get_ports {hps_usb1_D2}] 
set_false_path -from * -to [get_ports {hps_usb1_D3}] 
set_false_path -from * -to [get_ports {hps_usb1_D4}] 
set_false_path -from * -to [get_ports {hps_usb1_D5}] 
set_false_path -from * -to [get_ports {hps_usb1_D6}] 
set_false_path -from * -to [get_ports {hps_usb1_D7}] 
set_false_path -from * -to [get_ports {hps_i2c0_SDA}] 
set_false_path -from * -to [get_ports {hps_i2c1_SDA}] 
set_false_path -from * -to [get_ports {hps_i2c1_SCL}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO00}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO09}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO35}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO48}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO53}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO54}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO55}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO56}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO61}] 
set_false_path -from * -to [get_ports {hps_gpio_GPIO62}] 

set_false_path -from [get_ports {hps_emac1_MDIO}] -to *
set_false_path -from [get_ports {hps_qspi_IO0}] -to *
set_false_path -from [get_ports {hps_qspi_IO1}] -to *
set_false_path -from [get_ports {hps_qspi_IO2}] -to *
set_false_path -from [get_ports {hps_qspi_IO3}] -to *
set_false_path -from [get_ports {hps_sdio_CMD}] -to *
set_false_path -from [get_ports {hps_sdio_D0}] -to *
set_false_path -from [get_ports {hps_sdio_D1}] -to *
set_false_path -from [get_ports {hps_sdio_D2}] -to *
set_false_path -from [get_ports {hps_sdio_D3}] -to *
set_false_path -from [get_ports {hps_usb1_D0}] -to *
set_false_path -from [get_ports {hps_usb1_D1}] -to *
set_false_path -from [get_ports {hps_usb1_D2}] -to *
set_false_path -from [get_ports {hps_usb1_D3}] -to *
set_false_path -from [get_ports {hps_usb1_D4}] -to *
set_false_path -from [get_ports {hps_usb1_D5}] -to *
set_false_path -from [get_ports {hps_usb1_D6}] -to *
set_false_path -from [get_ports {hps_usb1_D7}] -to *
set_false_path -from [get_ports {hps_i2c0_SCL}] -to *
set_false_path -from [get_ports {hps_i2c1_SCL}] -to *
set_false_path -from [get_ports {hps_i2c1_SDA}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO00}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO09}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO35}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO48}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO53}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO54}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO55}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO56}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO61}] -to *
set_false_path -from [get_ports {hps_gpio_GPIO62}] -to *

set_false_path -from [get_ports {hps_emac1_RX_CTL}] -to *
set_false_path -from [get_ports {hps_emac1_RX_CLK}] -to *
set_false_path -from [get_ports {hps_emac1_RXD0}] -to *
set_false_path -from [get_ports {hps_emac1_RXD1}] -to *
set_false_path -from [get_ports {hps_emac1_RXD2}] -to *
set_false_path -from [get_ports {hps_emac1_RXD3}] -to *
set_false_path -from [get_ports {hps_usb1_CLK}] -to *
set_false_path -from [get_ports {hps_usb1_DIR}] -to *
set_false_path -from [get_ports {hps_usb1_NXT}] -to *
set_false_path -from [get_ports {hps_spim0_MISO}] -to *
set_false_path -from [get_ports {hps_spim1_MISO}] -to *
set_false_path -from [get_ports {hps_uart0_RX}] -to *
set_false_path -from [get_ports {hps_can0_RX}] -to *
