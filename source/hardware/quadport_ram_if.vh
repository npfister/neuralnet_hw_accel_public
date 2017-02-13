//Original Author: Nicholas A. Pfister
//interface file
//quadport ram memory controller

`ifndef QUADPORT_RAM_IF_VH
`define QUADPORT_RAM_IF_VH

interface quadport_ram_if;//single cycle latency, this is onchip ram

	logic [15:0] addr;//2^16=65536 words, individual words
	logic		wen;
	logic		ren;
	logic		four;//w/r address plus it's 3 other neighbors with in the 2bit [1:0] field
					 //can either w/r four or one at a time
	logic [31:0] din_a ;//only relevant port for w/r one at a time
	logic [31:0] din_b ;
	logic [31:0] din_c ;
	logic [31:0] din_d ;
	logic [31:0] dout_a ;//only relevant port for w/r one at a time
	logic [31:0] dout_b ;
	logic [31:0] dout_c ;
	logic [31:0] dout_d ;		
//00 native in sram0
//01 native in sram0
//10 translates to 00 internal to sram1
//11 translates to 01 internal to sram1
//must do translation both on the way in (write) and the way out (read)

modport quadram (
	input addr, wen, ren, four,
	input din_a,din_b,din_c,din_d,
	output dout_a,dout_b,dout_c,dout_d
	);

endinterface

`endif