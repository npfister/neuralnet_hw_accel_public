module demo ( 
	CLOCK_50 , SW , KEY, LEDG, LEDR , DRAM_CLK, DRAM_CKE, DRAM_ADDR ,
	DRAM_BA,  DRAM_CS_N , DRAM_CAS_N , DRAM_RAS_N, DRAM_WE_N, 
	DRAM_DQ, DRAM_DQM,  SRAM_ADDR, SRAM_DQ , SRAM_WE_N, 
	SRAM_OE_N, SRAM_UB_N,SRAM_LB_N,SRAM_CE_N, FL_ADDR, FL_DQ, 
	FL_CE_N,FL_OE_N,FL_RST_N,FL_WE_N, FL_WP_N, VGA_R,VGA_G,VGA_B , 
	VGA_BLANK,VGA_HS,VGA_VS,VGA_SYNC , VGA_CLK );		
	

	input CLOCK_50 ;
	input [17:0] SW ; 
	input [3:0] KEY ;
	output [8:0] LEDG ; 
	output [17:0] LEDR ;

	output [12:0]	DRAM_ADDR;
	output	[1:0]		DRAM_BA;
	output	DRAM_CAS_N;
	output	DRAM_CKE;
	output	DRAM_CLK;
	output	DRAM_CS_N;
	inout	[31:0] DRAM_DQ;
	output	[3:0]  DRAM_DQM;
	output	DRAM_RAS_N;
	output	DRAM_WE_N;

	output [17:0] SRAM_ADDR;  
	inout [15:0] SRAM_DQ ; 
	output SRAM_WE_N,SRAM_OE_N,SRAM_UB_N,SRAM_LB_N,SRAM_CE_N;


//////////// Flash //////////
output		 [22:0]		FL_ADDR;
output		          	FL_CE_N;
inout		    [7:0]		FL_DQ;
output		          	FL_OE_N;
output		          	FL_RST_N;
//input		          		FL_RY;
output		          	FL_WE_N;
output		          	FL_WP_N;



	output [9:0] VGA_R,VGA_G,VGA_B;
	output 	VGA_BLANK,VGA_HS,VGA_VS,VGA_SYNC;
	output 	VGA_CLK; 



	wire soc_clk ; 
	wire temp_vga_clk; 
	wire  abcd ;
	assign VGA_CLK  = temp_vga_clk ;
 pll pll_inst(
	.inclk0( CLOCK_50) ,
	.c1( temp_vga_clk ) ,
	.c0(DRAM_CLK ) ,	
	.c2( soc_clk) );


nios_system nios_sytem_inst ( 


		.clk_clk( soc_clk) ,                                         //                                       clk.clk
		.reset_reset_n( KEY[0] ),                                   //                                     reset.reset_n
		.new_sdram_controller_0_wire_addr(DRAM_ADDR),                //               new_sdram_controller_0_wire.addr
		.new_sdram_controller_0_wire_ba( DRAM_BA)   ,               //                                          .ba
		.new_sdram_controller_0_wire_cas_n( DRAM_CAS_N) ,               //                                          .cas_n
		.new_sdram_controller_0_wire_cke(DRAM_CKE) ,                 //                                          .cke
		.new_sdram_controller_0_wire_cs_n(DRAM_CS_N) ,                //                                          .cs_n\
		.new_sdram_controller_0_wire_dq(DRAM_DQ),                  //                                          .dq
		.new_sdram_controller_0_wire_dqm(DRAM_DQM),                 //                                          .dqm
		.new_sdram_controller_0_wire_ras_n(DRAM_RAS_N),               //                                          .ras_n
		.new_sdram_controller_0_wire_we_n(DRAM_WE_N),                //                                          .we_n
		.rleds_external_connection_export(LEDR),                //                 rleds_external_connection.export
		.gleds_external_connection_export(LEDG),                //                 gleds_external_connection.export
		.switches_external_connection_export(SW),             //              switches_external_connection.export
		//.video_vga_controller_0_external_interface_CLK(  temp_vga_clk ),   // video_vga_controller_0_external_interface.CLK
		//below was commented out because of VGA removal for neunet_accel project
		//.video_vga_controller_0_external_interface_HS( VGA_HS),    //                                          .HS
		//.video_vga_controller_0_external_interface_VS( VGA_VS),    //                                          .VS
		//.video_vga_controller_0_external_interface_BLANK(VGA_BLANK), //                                          .BLANK
		//.video_vga_controller_0_external_interface_SYNC( VGA_SYNC),  //                                          .SYNC
		//.video_vga_controller_0_external_interface_R( VGA_R),     //                                          .R
		//.video_vga_controller_0_external_interface_G( VGA_G),     //                                          .G
		//.video_vga_controller_0_external_interface_B(VGA_B) ,    //                                          .B
		.tristate_conduit_bridge_0_out_tcm_address_out(FL_ADDR),      // tristate_conduit_bridge_0_out.tcm_address_out
		.tristate_conduit_bridge_0_out_tcm_read_n_out(FL_OE_N),       //                              .tcm_read_n_out
		.tristate_conduit_bridge_0_out_tcm_write_n_out(FL_WE_N),      //                              .tcm_write_n_out
		.tristate_conduit_bridge_0_out_tcm_data_out(FL_DQ),         //                              .tcm_data_out
		.tristate_conduit_bridge_0_out_tcm_chipselect_n_out(FL_CE_N)  
	);
	assign FL_RST_N = 1'b1;
	assign FL_WP_N = 1'b1;

endmodule 












