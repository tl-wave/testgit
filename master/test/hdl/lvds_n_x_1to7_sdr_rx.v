//-----------------------------------------------------------------------------
//
// (c) Copyright 2013 Tronlong, Inc. All rights reserved.
//
//-----------------------------------------------------------------------------
`timescale 1ps/1ps

module lvds_n_x_1to7_sdr_rx #(
	// Parameters
	parameter integer	N = 3,				// Set the number of channels
	parameter integer	X = 4				// Set the number of data lines per channel
)(
	input				delay_refclk_in,	// Clock for input delay control: 200MHz or 300Hz clk is needed
	input				reset_n,			// Active low reset

	input	[N-1:0]		clk_in_p,			// Input from LVDS clock receiver pin
	input	[N-1:0]		clk_in_n,			// Input from LVDS clock receiver pin
	input	[N*X-1:0]	data_in_p,			// Input from LVDS data pins
	input	[N*X-1:0]	data_in_n,			// Input from LVDS data pins
	
	output	[N*X*7-1:0]	data_out,			// Serial to parallel data output
	output				pixel_clk			// Pixel clock output
 );

wire	rxclk_div;		// Global/Regional clock output of lvds serdes module
wire	delay_ready;	// input delays are ready

// Instantiate input delay control block, 200MHz or 300MHz clk is needed
IDELAYCTRL icontrol (
	.REFCLK(delay_refclk_in),
	.RST(!reset_n),
	.RDY(delay_ready)
);

//  Output the pixel clk
assign pixel_clk = rxclk_div;

// serdes for 1 to 7
n_x_serdes_1_to_7_mmcm_idelay_sdr #(
	.N(N),								// Set the number of channels
	.SAMPL_CLOCK("BUF_G"),				// Parameter to set sampling clock buffer type, BUFIO, BUF_H, BUF_G
	.PIXEL_CLOCK("BUF_G"),				// Parameter to set pixel clock buffer type, BUF_R, BUF_H, BUF_G
	.USE_PLL("FALSE"), 					// Parameter to enable PLL use rather than MMCM use, overides SAMPL_CLOCK and INTER_CLOCK to be both BUFH
	.HIGH_PERFORMANCE_MODE("FALSE"),	// Parameter Used to determine method for mapping input parallel word to output serial words
	.D(X),								// Set the number of data lines per channel
	.CLKIN_PERIOD(11.765),				// Set input clock period, period = 1 / 85MHz
	.MMCM_MODE(2),						// Parameter to set multiplier for MMCM to get VCO in correct operating range. 1 multiplies input clock by 7, 2 multiplies clock by 14, etc
	.DIFF_TERM("TRUE"),					// Parameter to enable internal differential termination
	.DATA_FORMAT("PER_CHANL")			// PER_CLOCK or PER_CHANL data formatting
) rx0 (
	.clkin_p(clk_in_p),					// Input from LVDS clock receiver pin
	.clkin_n(clk_in_n),					// Input from LVDS clock receiver pin
	.datain_p(data_in_p),				// Input from LVDS data pins
	.datain_n(data_in_n), 				// Input from LVDS data pins
	.enable_phase_detector(1'b1),		// Enables the phase detector logic when high
	.enable_monitor(1'b1),				// Enables the monitor logic when high, note time-shared with phase detector function
	.reset(!reset_n),					// Reset line
	.idelay_rdy(delay_ready),			// input delays are ready
	.rxclk_div(rxclk_div),				// Global/Regional clock output
	.rx_data(data_out),					// Output the received Data
	.bit_rate_value(16'h0595)			// Bit rate in Mbps, for example 16'h0595 (85MHz x 7 = 595Mbps)
);

endmodule
