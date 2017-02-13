//Original Author: Nicholas A. Pfister
//dualport ram memory controller
//purely combinational controller

//150000 bytes
//37,500 32bit words available from either port

module dualport_ram (
	//ACTIVE high because that's what avalon gives us
	input  logic		clk   ,
	input  logic        wen_a , 
	input  logic        wen_b ,
	input  logic        ren_a ,
	input  logic        ren_b ,
	input  logic [31:0] din_a ,
	input  logic [31:0] din_b ,
	input  logic [15:0] addr_a,
	input  logic [15:0] addr_b,

	output logic [31:0] dout_a, //1 cycle later than wen_a
	output logic [31:0] dout_b //1 cycle later than wen_b
	//output logic        memwait //1 not done, 0 free
);
  parameter INIT_FILE = "nios_system_onchip_memory2_0.hex";
/*typedef enum logic {
    FREE,
    ACCESS
  } ramstate_t;

ramstate_t rstate, n_rstate;

always_ff @ (posedge clk) begin
	if (nRST == 1) begin
		rstate = FREE;		
	end
	else begin
		rstate = n_rstate;
	end
end

always_comb
	begin
		if ((ren_a | ren_b) & (rstate == FREE))
		begin
			n_rstate = ACCESS; //new mem request
		end
		else begin //ram takes 1 cycle to read a value, 0 to write
			n_rstate = FREE;
		end
	end

always_comb
    begin
    	if()
    end*/

  altsyncram altsyncram_component
    (
      .address_a (addr_a),
      .address_b (addr_b),
      .byteena_a (4'hF),
      .byteena_b (4'hF),
      .clock0 (clk),
      .clock1 (clk),
      .clocken0 (1'b1),
      .clocken1 (1'b1),
      .data_a (din_a),
      .data_b (din_b),
      .q_a (dout_a),
      .q_b (dout_b),
      .wren_a (wen_a),
      .wren_b (wen_b),
      .rden_a (ren_a),
      .rden_b (ren_b)
    );
  defparam altsyncram_component.address_reg_b = "CLOCK1",
           altsyncram_component.byte_size = 8,
           altsyncram_component.byteena_reg_b = "CLOCK1",
           altsyncram_component.indata_reg_b = "CLOCK1",
           altsyncram_component.init_file = INIT_FILE,
           altsyncram_component.lpm_type = "altsyncram",
           altsyncram_component.maximum_depth = 37500,
           altsyncram_component.numwords_a = 37500,
           altsyncram_component.numwords_b = 37500,
           altsyncram_component.operation_mode = "BIDIR_DUAL_PORT",
           altsyncram_component.outdata_reg_a = "UNREGISTERED",
           altsyncram_component.outdata_reg_b = "UNREGISTERED",
           altsyncram_component.ram_block_type = "M9K",
           altsyncram_component.read_during_write_mode_mixed_ports = "DONT_CARE",
           altsyncram_component.width_a = 32,
           altsyncram_component.width_b = 32,
           altsyncram_component.width_byteena_a = 4,
           altsyncram_component.width_byteena_b = 4,
           altsyncram_component.widthad_a = 16,
           altsyncram_component.widthad_b = 16,
           altsyncram_component.wrcontrol_wraddress_reg_b = "CLOCK1";


endmodule