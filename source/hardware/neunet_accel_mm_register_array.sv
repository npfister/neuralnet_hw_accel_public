//Original Authors(s):Nicholas A. Pfister AND John J. Skubic

// interface
`include "mac_if.vh"
`include "sigmoid_if.vh"
`include "quadport_ram_if.vh"

module neunet_accel_mm_register_array (clk,
                      reset,
                      address,
                      writedata,
                      write,
                      read,
                      chipselect,
                      readdata                      	
			);

//supported control commands through address 0
localparam CLEAR        = 32'h00000001;//START_PROGRAMMING
localparam START_W0     = 32'h00000002;//store start ptr to weight hidden layer
localparam START_B0     = 32'h00000003;//store start ptr to bias   hidden layer
localparam START_W1     = 32'h00000004;//store start ptr to weight output layer
localparam START_B1     = 32'h00000005;//store start ptr to bias   output layer
localparam SAVE_IN_ADDR = 32'h00000006;//save current address (to 4 word boundary) to begin of input ptr register
localparam START_RD_OUT = 32'h00000007;//move begin of input ptr to working mem pointer, reg6
localparam ADVN_PTR_4WD = 32'h00000008;//advance internal pointer to next set of 4 words, [1:0]=xx -> [1:0]=00
localparam START_COMPUTE= 32'h00000009;//make one bit start signal to 
localparam ADVN_PTR_1WD = 32'h0000000a;

//TOP Level Interfaces
quadport_ram_if qram_ffc();//feed forward ctrl to arb
quadport_ram_if qram_slv();//slave to arb
quadport_ram_if	qram_arbo();//output of arbiter
sigmoid_if sigif();
mac_if macif();

// AVALON-MM Interface signals
input logic  clk;   // this is the clock coming in from the avalon bus
input logic  reset ; // reset from the avalon bus
input logic  [2:0] address ;  // 3-bit address coming from the avalon system bus (need only 3 bits to address 8 memory-mapped registers)
input logic  [31:0] writedata ; // 32 bit write data line
input logic   write ;	//write request
input logic  read ;	//read request
input logic chipselect;	//becomes 1 when this component is accessed by an Avalon transactions
output logic [31:0] readdata ;

// Registers
reg [31:0] register_bank [7 :0] ;
integer loop_index;

logic ff_done;

//SLAVE Original Author: Nicholas A. Pfister
// This is a application specific custom Avalon Slave
// that contains 8  memory-mapped 32 bit registers
// A 3-bit address is used to access the registers

/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// SLAVE WRITE Logic //////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

// reg0 --> write=command   ,read=status register
// reg1 --> write=input data,read=output data, send START_RD_OUT command first to set the address ptr correctly, reg1 itself is used for input data ptr
// reg2 --> start ptr weight hidden layer
// reg3 --> start ptr bias   hidden layer
// reg4 --> start ptr weight output layer
// reg5 --> start ptr bias   output layer
// reg6 --> running / working / current pointer value
// reg7 --> top 16 bits are size of , bottom 16 bit are size of layer

always @ ( posedge clk, posedge reset )
begin
	if( reset == 1 )
	begin 
		for( loop_index = 0; loop_index < 8; loop_index = loop_index + 1 ) begin 
			register_bank [ loop_index ] <= 0 ;  
		end
	end
	else
	begin 
		if( write && chipselect )
		begin

			if(address == 3'd0)//command address
			begin
				case (writedata)
					CLEAR        : begin 
						register_bank [3'd0] <= 32'h00000000;
						register_bank [3'd1] <= 32'h00000000;
						register_bank [3'd2] <= 32'h00000000;
						register_bank [3'd3] <= 32'h00000000;
						register_bank [3'd4] <= 32'h00000000;
						register_bank [3'd5] <= 32'h00000000;
						register_bank [3'd6] <= 32'h00000000;
						register_bank [3'd7] <= 32'h00000000;
					end
					START_W0     : 
						register_bank [3'd2] <= register_bank [3'd6];//this will be hidden layer weights base 
					START_B0     : 
						register_bank [3'd3] <= register_bank [3'd6];//this will be hidden layer bias    base
					START_W1     :
						register_bank [3'd4] <= register_bank [3'd6];//this will be output layer weights base
					START_B1     :
						register_bank [3'd5] <= register_bank [3'd6];//this will be output layer bias    base
					SAVE_IN_ADDR :
						register_bank [3'd1] <= register_bank [3'd6];//this will be data input layer weights base
					START_RD_OUT ://move input data ptr to working mem pointer, reg6
						register_bank [3'd6] <= register_bank [3'd1];
						//use this to set working ptr to beginning of input data
						//	1) use b4 read output, input data is output data after computation
						//	2) use b4 write in new input data
					ADVN_PTR_4WD :
						register_bank [3'd6] <= (register_bank [3'd6] + 32'h00000004) & 32'hFFFFFFFC;//move to next highest 4 word boundary addresss
					START_COMPUTE:
						//do nothing, used in port map of feed_forward_controller to start it (move from idle state)
						register_bank [3'd0] <= 32'h00000000;//clear status register
					ADVN_PTR_1WD :
						register_bank[3'd6] <= register_bank[3'd6] + 1;
					default:
						register_bank [address] <= register_bank [address];
				endcase
			end
			else if (address == 3'd1) begin //reg1 written through command "SAVE_IN_ADDR"
				register_bank [3'd6] <= register_bank[3'd6] + 32'h00000001;
				//data being written, advance write/working ptr
			end
			else if ((address == 3'd2)|(address == 3'd3)|(address == 3'd4)|(address == 3'd5)|(address == 3'd6)) //regs are not directly
			begin 
				//these regsvwritten through commands to address 0
				register_bank [address] <= register_bank [address];
			end
			else begin//address 7
				//reg7 is stores: 31:16 num neurons in out layer, 15:0 num neurons in hidden layer
				//the data arrangement is handled and written in through external software
				register_bank [address] <= writedata;
			end 
		end
		/*else if (read && chipselect) begin
			if (address == 3'd1) begin //data being read advance read/working ptr
				register_bank [3'd6] <= register_bank[3'd6] + 32'h00000001;
			end
		end*/
		
		if (ff_done) begin
				register_bank [3'b0] <= {32{ff_done}};//all ones is done, will reset to all zeros on CLEAR command
		end			
	end
end

/////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////// SLAVE READ Logic ///////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////


always_comb
begin
	//read from internal ram
	if ( ( read && chipselect ) && (address == 3'd1) ) begin //data being read advance read/working ptr, done in above flop
			readdata = qram_slv.dout_a; //from quadport ram
			qram_slv.addr  = register_bank[3'd6];//working pointer
			qram_slv.wen   = 1'b0;
			qram_slv.ren   = 1'b1;
			qram_slv.four  = 1'b0;
			qram_slv.din_a = 32'h00000000;
			qram_slv.din_b = 32'h00000000;
			qram_slv.din_c = 32'h00000000;
			qram_slv.din_d = 32'h00000000;
	end
	else if ( write && chipselect && (address == 3'd1)) begin
			readdata = 32'h11111111;
			qram_slv.addr  = register_bank[3'd6];//working pointer
			qram_slv.wen   = 1'b1;
			qram_slv.ren   = 1'b0;
			qram_slv.four  = 1'b0;
			qram_slv.din_a = writedata;
			qram_slv.din_b = 32'h00000000;
			qram_slv.din_c = 32'h00000000;
			qram_slv.din_d = 32'h00000000; 
	end
	else begin	
		readdata = register_bank[address];//mm registers out
		qram_slv.addr  = register_bank[3'd6];//working pointer
		qram_slv.wen   = 1'b0;
		qram_slv.ren   = 1'b1;
		qram_slv.four  = 1'b0;
		qram_slv.din_a = 32'h00000000;
		qram_slv.din_b = 32'h00000000;
		qram_slv.din_c = 32'h00000000;
		qram_slv.din_d = 32'h00000000;
	end
end

//**************************************************************************
//TOP LEVEL Original Author(s): Nicholas A. Pfister AND John J. Skubic

/////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////  NEUNET_ACCEL TOP LEVEL  //////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////

//Feed Forward Compute Controller
logic regfile_syn_rst;
logic load_act;
logic [4:0] reg_sel_acc;
logic [3:0] reg_word_sel;
logic add_en;
logic mac_en;
logic sig_en;
logic [31:0] reg_act;
logic [3:0][31:0] reg_acc;

assign macif.reg_wen = add_en | mac_en;
assign macif.add_sub = 1'b1;//always add
assign macif.add_only = add_en;
assign macif.index = reg_sel_acc;
assign macif.word_sel = reg_word_sel;

assign macif.dataa_0 = qram_ffc.dout_a;
assign macif.dataa_1 = qram_ffc.dout_b;
assign macif.dataa_2 = qram_ffc.dout_c;
assign macif.dataa_3 = qram_ffc.dout_d;

assign macif.datab_0 = (add_en) ? reg_acc[0] : reg_act;
assign macif.datab_1 = (add_en) ? reg_acc[1] : reg_act;
assign macif.datab_2 = (add_en) ? reg_acc[2] : reg_act;
assign macif.datab_3 = (add_en) ? reg_acc[3] : reg_act;

assign macif.datac_0 = reg_acc[0];
assign macif.datac_1 = reg_acc[1];
assign macif.datac_2 = reg_acc[2];
assign macif.datac_3 = reg_acc[3];

//sigmoid pipe
assign sigif.reg_wen = sig_en;
assign sigif.index = reg_sel_acc;
assign sigif.word_sel = reg_word_sel;

assign sigif.dataa_0 = reg_acc[0];
assign sigif.dataa_1 = reg_acc[1];
assign sigif.dataa_2 = reg_acc[2];
assign sigif.dataa_3 = reg_acc[3];

//Quadport Ram Controller
quadport_ram ram4 (
	.clk   (clk),
  .reset (reset),
	.qram(qram_arbo)
	/*
    .addr  (arb_o_addr  ),//use address from reg6 on read or write from addr1
    .wen   (arb_o_wen   ),
    .ren   (arb_o_ren   ),
    .four  (arb_o_four  ),

    .din_a (arb_o_din_a ),//on a write from addr 1, put writedata in ram
    .din_b (arb_o_din_b ),
    .din_c (arb_o_din_c ),
    .din_d (arb_o_din_d ),

	.dout_a(arb_o_dout_a),//on a read from addr 1, connect to readdata flop
	.dout_b(arb_o_dout_b),
	.dout_c(arb_o_dout_c),
	.dout_d(arb_o_dout_d)*/
    );
	 
feedforward_controller ffctrl (
	.CLK(clk),
	.RST(reset),
	.start_flg( (address == 3'h0) & (write&chipselect) & (writedata == START_COMPUTE) ),//writing command addr and START_COMPUTE command
	.mac_pipe_clr(macif.empty),
	.sigmoid_pipe_clr(sigif.empty),
	.addr_w1(register_bank[2]),
	.addr_w2(register_bank[4]),
	.addr_b1(register_bank[3]),
	.addr_b2(register_bank[5]),
	.addr_act(register_bank[1]),
	.size_l0(16'd784),
	.size_l1(register_bank[7][15:0]),
	.size_l2(register_bank[7][31:16]),
	.done_flg(ff_done),
	.layer_prep_stb(regfile_syn_rst),
	.issue_mac(mac_en),
	.issue_add(add_en),
	.load_act_flg(load_act),
	.issue_sigmoid(sig_en),
	.word_sel(reg_word_sel),
	.reg_sel(reg_sel_acc),
  .ram_store(reg_acc),
	.qrif(qram_ffc)
	);

//Quadport Register File
regfile reg4 (
	.CLK(clk),
	.RST(reset),
	.rst_syn(regfile_syn_rst),
	.wdata(macif.reg_wen_o ? {macif.result_3,macif.result_2,macif.result_1,macif.result_0} :(load_act ? {qram_slv.dout_d, qram_slv.dout_c, qram_slv.dout_b, qram_slv.dout_a} : {sigif.result_3,sigif.result_2,sigif.result_1,sigif.result_0})), //set by mac/sigmoid
	.word_en(macif.reg_wen_o ? macif.word_sel_o : (load_act ? 4'hf : sigif.word_sel_o)), //set by mac/sigmoid
	.act_wen(load_act), 
	.acc_wen(macif.reg_wen_o | sigif.reg_wen_o), //set by mac/sigmoid
	.acc_sel_w(macif.reg_wen_o ? macif.index_o : sigif.index_o), //set by mac/sigmoid
	.acc_sel_r(reg_sel_acc),
	.rdata_act(reg_act), //to mac
	.rdata_acc(reg_acc)  //to mac/sigmoid
);

//Quadport Ram Arbiter
//Arbitrate between: 
//Feed forward controller and slave
arbiter arb (
	qram_ffc,//feed forward ctrl takes priority (static)
	qram_slv,//slave gets 2nd priority
	qram_arbo//arb out to qram
	);



//4x SIMD multiple accumulate
neunet_mac mac(//4 parallel mac pipes
	.clk(clk),
	.reset(reset),
	.in(macif),
	.out(macif)
	);

//4x SIMD sigmoid
neunet_sigmoid sigmoid(//4 parallel sigmoid pipes
	//could be one for area constraints, not well utilized
	.clk(clk),
	.reset(reset),
	.in(sigif),
	.out(sigif)
	);

endmodule

