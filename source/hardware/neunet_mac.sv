//MAC
//Nicholas A. Pfister

`include "mac_if.vh"

module neunet_mac(
	input logic clk,
	input logic reset,//is active
	mac_if.macin in,
	mac_if.macout out
	);

//internal
logic [31:0] datac_p0_0;
logic [31:0] datac_p0_1;
logic [31:0] datac_p0_2;
logic [31:0] datac_p0_3;
logic [31:0] datac_p0_4;
logic [31:0] datac_p0_5;
logic [31:0] datac_p0_6;
logic [31:0] datac_p0_7;
logic [31:0] datac_p0_8;
logic [31:0] datac_p0_9;
logic [31:0] datac_p0_10;
logic [31:0] datac_p0_11;

logic [31:0] datac_p1_0;
logic [31:0] datac_p1_1;
logic [31:0] datac_p1_2;
logic [31:0] datac_p1_3;
logic [31:0] datac_p1_4;
logic [31:0] datac_p1_5;
logic [31:0] datac_p1_6;
logic [31:0] datac_p1_7;
logic [31:0] datac_p1_8;
logic [31:0] datac_p1_9;
logic [31:0] datac_p1_10;
logic [31:0] datac_p1_11;

logic [31:0] datac_p2_0;
logic [31:0] datac_p2_1;
logic [31:0] datac_p2_2;
logic [31:0] datac_p2_3;
logic [31:0] datac_p2_4;
logic [31:0] datac_p2_5;
logic [31:0] datac_p2_6;
logic [31:0] datac_p2_7;
logic [31:0] datac_p2_8;
logic [31:0] datac_p2_9;
logic [31:0] datac_p2_10;
logic [31:0] datac_p2_11;

logic [31:0] datac_p3_0;
logic [31:0] datac_p3_1;
logic [31:0] datac_p3_2;
logic [31:0] datac_p3_3;
logic [31:0] datac_p3_4;
logic [31:0] datac_p3_5;
logic [31:0] datac_p3_6;
logic [31:0] datac_p3_7;
logic [31:0] datac_p3_8;
logic [31:0] datac_p3_9;
logic [31:0] datac_p3_10;
logic [31:0] datac_p3_11;

logic [31:0] mul_result_p0;
logic [31:0] mul_result_p1;
logic [31:0] mul_result_p2;
logic [31:0] mul_result_p3;

logic 		 add_sub0;
logic 		 add_sub1;
logic 		 add_sub2;
logic 		 add_sub3;
logic 		 add_sub4;		 

logic        reg_wen0;
logic        reg_wen1;
logic        reg_wen2;
logic        reg_wen3;
logic        reg_wen4;
logic        reg_wen5;
logic        reg_wen6;
logic        reg_wen7;
logic        reg_wen8;
logic        reg_wen9;
logic        reg_wen10;
logic        reg_wen11;
logic [ 3:0] word_sel0;
logic [ 3:0] word_sel1;
logic [ 3:0] word_sel2;
logic [ 3:0] word_sel3;
logic [ 3:0] word_sel4;
logic [ 3:0] word_sel5;
logic [ 3:0] word_sel6;
logic [ 3:0] word_sel7;
logic [ 3:0] word_sel8;
logic [ 3:0] word_sel9;
logic [ 3:0] word_sel10;
logic [ 3:0] word_sel11;
logic [ 4:0] index0;
logic [ 4:0] index1;
logic [ 4:0] index2;
logic [ 4:0] index3;
logic [ 4:0] index4;
logic [ 4:0] index5;
logic [ 4:0] index6;
logic [ 4:0] index7;
logic [ 4:0] index8;
logic [ 4:0] index9;
logic [ 4:0] index10;
logic [ 4:0] index11;

//multipliers
ieee754_mul mul0 ( //5 cycles
	.clock(clk),
	.dataa(in.dataa_0),
	.datab(in.datab_0),
	.nan(),//dont care, if nan to add, nan will come out of add's nan port
	.overflow(),//dont care
	.result(mul_result_p0),//*** to fp adder
	.underflow(),//dont care
	.zero());//dont care

ieee754_mul mul1 ( //5 cycles
	.clock(clk),
	.dataa(in.dataa_1),
	.datab(in.datab_1),
	.nan(),//dont care, if nan to add, nan will come out of add's nan port
	.overflow(),//dont care
	.result(mul_result_p1),//*** to fp adder
	.underflow(),//dont care
	.zero());//dont care

ieee754_mul mul2 ( //5 cycles
	.clock(clk),
	.dataa(in.dataa_2),
	.datab(in.datab_2),
	.nan(),//dont care, if nan to add, nan will come out of add's nan port
	.overflow(),//dont care
	.result(mul_result_p2),//*** to fp adder
	.underflow(),//dont care
	.zero());//dont care

ieee754_mul mul3 ( //5 cycles
	.clock(clk),
	.dataa(in.dataa_3),
	.datab(in.datab_3),
	.nan(),//dont care, if nan to add, nan will come out of add's nan port
	.overflow(),//dont care
	.result(mul_result_p3),//*** to fp adder
	.underflow(),//dont care
	.zero());//dont care

// "Control Pipe"
// to end of mul
always_ff @ ( posedge clk )
begin
	if( reset == 1 ) begin
		datac_p0_0 <= '0;//p0 pipe stage 0, and so on
		datac_p0_1 <= '0;
		datac_p0_2 <= '0;
		datac_p0_3 <= '0;
		datac_p0_4 <= '0;

		datac_p1_0 <= '0;
		datac_p1_1 <= '0;
		datac_p1_2 <= '0;
		datac_p1_3 <= '0;
		datac_p1_4 <= '0;

		datac_p2_0 <= '0;
		datac_p2_1 <= '0;
		datac_p2_2 <= '0;
		datac_p2_3 <= '0;
		datac_p2_4 <= '0;

		datac_p3_0 <= '0;
		datac_p3_1 <= '0;
		datac_p3_2 <= '0;
		datac_p3_3 <= '0;
		datac_p3_4 <= '0;

		add_sub0 <= '0;
		add_sub1 <= '0;
		add_sub2 <= '0;
		add_sub3 <= '0;
		add_sub4 <= '0;

		reg_wen0 <= '0;
		reg_wen1 <= '0;
		reg_wen2 <= '0;
		reg_wen3 <= '0;
		reg_wen4 <= '0;

		word_sel0 <= '0;
		word_sel1 <= '0;
		word_sel2 <= '0;
		word_sel3 <= '0;
		word_sel4 <= '0;

		index0 <= '0;
		index1 <= '0;
		index2 <= '0;
		index3 <= '0;
		index4 <= '0;//'
	end
	else begin
		datac_p0_0 <= in.datac_0;
		datac_p0_1 <= datac_p0_0;
		datac_p0_2 <= datac_p0_1;
		datac_p0_3 <= datac_p0_2;
		datac_p0_4 <= datac_p0_3;

		datac_p1_0 <= in.datac_1;
		datac_p1_1 <= datac_p1_0;
		datac_p1_2 <= datac_p1_1;
		datac_p1_3 <= datac_p1_2;
		datac_p1_4 <= datac_p1_3;

		datac_p2_0 <= in.datac_2;
		datac_p2_1 <= datac_p2_0;
		datac_p2_2 <= datac_p2_1;
		datac_p2_3 <= datac_p2_2;
		datac_p2_4 <= datac_p2_3;

		datac_p3_0 <= in.datac_3;
		datac_p3_1 <= datac_p3_0;
		datac_p3_2 <= datac_p3_1;
		datac_p3_3 <= datac_p3_2;
		datac_p3_4 <= datac_p3_3;

		add_sub0 <= in.add_sub;
		add_sub1 <= add_sub0;
		add_sub2 <= add_sub1;
		add_sub3 <= add_sub2;
		add_sub4 <= add_sub3;

		reg_wen0 <= (in.add_only) ? (1'b0) : (in.reg_wen);//disable simultaneous mac start with addonly
		reg_wen1 <= reg_wen0;
		reg_wen2 <= reg_wen1;
		reg_wen3 <= reg_wen2;
		reg_wen4 <= reg_wen3;

		word_sel0 <= (in.add_only) ? (1'b0) : (in.word_sel);//disable simultaneous mac start with addonly
		word_sel1 <= word_sel0;
		word_sel2 <= word_sel1;
		word_sel3 <= word_sel2;
		word_sel4 <= word_sel3;

		index0 <= in.index;
		index1 <= index0;
		index2 <= index1;
		index3 <= index2;
		index4 <= index3;
	end
end

//end of mul to end of add (end of mac)
always @ ( posedge clk )
begin
	if( reset == 1 ) begin
		reg_wen5 <= '0;
		reg_wen6 <= '0;
		reg_wen7 <= '0;
		reg_wen8 <= '0;
		reg_wen9 <= '0;
		reg_wen10<= '0;
		reg_wen11<= '0;

		word_sel5 <= '0;
		word_sel6 <= '0;
		word_sel7 <= '0;
		word_sel8 <= '0;
		word_sel9 <= '0;
		word_sel10<= '0;
		word_sel11<= '0;

		index5 <= '0;
		index6 <= '0;
		index7 <= '0;
		index8 <= '0;
		index9 <= '0;
		index10<= '0;
		index11<= '0;//'
	end
	else begin
		reg_wen5 <= (in.add_only) ? (in.reg_wen) : (reg_wen4);//addonly skip mul stage, mul stage is disabled to avoid starting false mac
		reg_wen6 <= reg_wen5;
		reg_wen7 <= reg_wen6;
		reg_wen8 <= reg_wen7;
		reg_wen9 <= reg_wen8;
		reg_wen10<= reg_wen9;
		reg_wen11<= reg_wen10;

		word_sel5 <= (in.add_only) ? (in.word_sel) : (word_sel4);//addonly skip mul stage, mul stage is disabled to avoid starting false mac
		word_sel6 <= word_sel5;
		word_sel7 <= word_sel6;
		word_sel8 <= word_sel7;
		word_sel9 <= word_sel8;
		word_sel10<= word_sel9;
		word_sel11<= word_sel10;

		index5 <= (in.add_only) ? (in.index) : (index4);//addonly skip mul stage, mul stage is disabled to avoid starting false mac
		index6 <= index5;
		index7 <= index6;
		index8 <= index7;
		index9 <= index8;
		index10<= index9;
		index11<= index10;
	end
end
//adders
ieee754_add add0 ( //7 cycles
	.add_sub( (in.add_only) ? (in.add_sub) : (add_sub4) ),//addsub high=add  low=sub, addonly high bypass mul
	.clock(clk),
	.dataa( (in.add_only) ? (in.dataa_0) : (mul_result_p0) ),
	.datab( (in.add_only) ? (in.datab_0) : (datac_p0_4) ),
	.nan(out.nan_0),//error
	.overflow(),//dont care
	.result(out.result_0),
	.underflow(),//dont care
	.zero());//dont care

ieee754_add add1 ( //7 cycles
	.add_sub( (in.add_only) ? (in.add_sub) : (add_sub4) ),//addsub high=add  low=sub, addonly high bypass mul
	.clock(clk),
	.dataa( (in.add_only) ? (in.dataa_1) : (mul_result_p1) ),
	.datab( (in.add_only) ? (in.datab_1) : (datac_p1_4) ),
	.nan(out.nan_1),//error
	.overflow(),//dont care
	.result(out.result_1),
	.underflow(),//dont care
	.zero());//dont care

ieee754_add add2 ( //7 cycles
	.add_sub( (in.add_only) ? (in.add_sub) : (add_sub4) ),//addsub high=add  low=sub, addonly high bypass mul
	.clock(clk),
	.dataa( (in.add_only) ? (in.dataa_2) : (mul_result_p2 ) ),
	.datab( (in.add_only) ? (in.datab_2) : (datac_p2_4) ),
	.nan(out.nan_2),//error
	.overflow(),//dont care
	.result(out.result_2),
	.underflow(),//dont care
	.zero());//dont care

ieee754_add add3 ( //7 cycles
	.add_sub( (in.add_only) ? (in.add_sub) : (add_sub4) ),//addsub high=add  low=sub, addonly high bypass mul
	.clock(clk),
	.dataa( (in.add_only) ? (in.dataa_3) : (mul_result_p3) ),
	.datab( (in.add_only) ? (in.datab_3) : (datac_p3_4) ),
	.nan(out.nan_3),//error
	.overflow(),//dont care
	.result(out.result_3),
	.underflow(),//dont care
	.zero());//dont care

//output
assign out.reg_wen_o  = reg_wen11 ;
assign out.word_sel_o = word_sel11;
assign out.index_o    = index11   ;
assign out.empty = !(reg_wen0|reg_wen1 |reg_wen2 |
					 reg_wen3|reg_wen4 |reg_wen5 |
					 reg_wen6|reg_wen7 |reg_wen8 |
					 reg_wen9|reg_wen10|reg_wen11);
//regwen11 is included because result_x isn't yet written into regfile

endmodule
