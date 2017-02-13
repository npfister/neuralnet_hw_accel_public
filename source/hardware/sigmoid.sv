//Sigmoid
//Original Author: Nicholas A. Pfister

`include "sigmoid_if.vh"

module neunet_sigmoid(
	input logic clk,
	input logic reset,
	sigmoid_if.sigin in,
	sigmoid_if.sigout out
	);

//internal
logic [31:0]	exp_out_p0;
logic [31:0]	exp_out_p1;
logic [31:0]	exp_out_p2;
logic [31:0]	exp_out_p3;

logic [31:0]	sub_out_p0;
logic [31:0]	sub_out_p1;
logic [31:0]	sub_out_p2;
logic [31:0]	sub_out_p3;

logic			div0_p0;//divide by zero error, pipe 0
logic			div0_p1;
logic			div0_p2;
logic			div0_p3;

logic			nan_p0;//not a number was produced or input error pipe 0
logic			nan_p1;
logic			nan_p2;
logic			nan_p3;

logic [3:0]     word_sel0  ;
logic [3:0]     word_sel1  ;
logic [3:0]     word_sel2  ;
logic [3:0]     word_sel3  ;
logic [3:0]     word_sel4  ;
logic [3:0]     word_sel5  ;
logic [3:0]     word_sel6  ;
logic [3:0]     word_sel7  ;
logic [3:0]     word_sel8  ;
logic [3:0]     word_sel9  ;
logic [3:0]     word_sel10 ;
logic [3:0]     word_sel11 ;
logic [3:0]     word_sel12 ;
logic [3:0]     word_sel13 ;
logic [3:0]     word_sel14 ;
logic [3:0]     word_sel15 ;
logic [3:0]     word_sel16 ;
logic [3:0]     word_sel17 ;
logic [3:0]     word_sel18 ;
logic [3:0]     word_sel19 ;
logic [3:0]     word_sel20 ;
logic [3:0]     word_sel21 ;
logic [3:0]     word_sel22 ;
logic [3:0]     word_sel23 ;
logic [3:0]     word_sel24 ;
logic [3:0]     word_sel25 ;
logic [3:0]     word_sel26 ;
logic [3:0]     word_sel27 ;
logic [3:0]     word_sel28 ;
logic [3:0]     word_sel29 ;

logic [4:0]     index0  ;
logic [4:0]     index1  ;
logic [4:0]     index2  ;
logic [4:0]     index3  ;
logic [4:0]     index4  ;
logic [4:0]     index5  ;
logic [4:0]     index6  ;
logic [4:0]     index7  ;
logic [4:0]     index8  ;
logic [4:0]     index9  ;
logic [4:0]     index10 ;
logic [4:0]     index11 ;
logic [4:0]     index12 ;
logic [4:0]     index13 ;
logic [4:0]     index14 ;
logic [4:0]     index15 ;
logic [4:0]     index16 ;
logic [4:0]     index17 ;
logic [4:0]     index18 ;
logic [4:0]     index19 ;
logic [4:0]     index20 ;
logic [4:0]     index21 ;
logic [4:0]     index22 ;
logic [4:0]     index23 ;
logic [4:0]     index24 ;
logic [4:0]     index25 ;
logic [4:0]     index26 ;
logic [4:0]     index27 ;
logic [4:0]     index28 ;
logic [4:0]     index29 ;

logic      reg_wen0  ;
logic      reg_wen1  ;
logic      reg_wen2  ;
logic      reg_wen3  ;
logic      reg_wen4  ;
logic      reg_wen5  ;
logic      reg_wen6  ;
logic      reg_wen7  ;
logic      reg_wen8  ;
logic      reg_wen9  ;
logic      reg_wen10 ;
logic      reg_wen11 ;
logic      reg_wen12 ;
logic      reg_wen13 ;
logic      reg_wen14 ;
logic      reg_wen15 ;
logic      reg_wen16 ;
logic      reg_wen17 ;
logic      reg_wen18 ;
logic      reg_wen19 ;
logic      reg_wen20 ;
logic      reg_wen21 ;
logic      reg_wen22 ;
logic      reg_wen23 ;
logic      reg_wen24 ;
logic      reg_wen25 ;
logic      reg_wen26 ;
logic      reg_wen27 ;
logic      reg_wen28 ;
logic      reg_wen29 ;

//e^-z
ieee754_exp exp0 (//17 cycles 
	.clock(clk),
	.data({~in.dataa_0[31],in.dataa_0[30:0]}),//negative z
	.nan(),
	.result(exp_out_p0)
	);
ieee754_exp exp1 (
	.clock(clk),
	.data({~in.dataa_1[31],in.dataa_1[30:0]}),//negative z
	.nan(),
	.result(exp_out_p1)
	);
ieee754_exp exp2 (
	.clock(clk),
	.data({~in.dataa_2[31],in.dataa_2[30:0]}),//negative z
	.nan(),
	.result(exp_out_p2)
	);
ieee754_exp exp3 (
	.clock(clk),
	.data({~in.dataa_3[31],in.dataa_3[30:0]}),//negative z
	.nan(),
	.result(exp_out_p3)
	);
//subtractors
ieee754_add sub0 ( //7 cycles
	.add_sub(1'b1),//low=subtractor
	.clock(clk),
	.dataa( 32'h3f800000 ),//one in ieee754
	.datab( exp_out_p0 ),//e^-z
	.nan(),//dont care yet
	.overflow(),//dont care
	.result(sub_out_p0),
	.underflow(),//dont care
	.zero());//dont care
ieee754_add sub1 ( //7 cycles
	.add_sub(1'b1),//low=subtractor
	.clock(clk),
	.dataa( 32'h3f800000 ),//one in ieee754
	.datab( exp_out_p1 ),//e^-z
	.nan(),//dont care yet
	.overflow(),//dont care
	.result(sub_out_p1),
	.underflow(),//dont care
	.zero());//dont care
ieee754_add sub2 ( //7 cycles
	.add_sub(1'b1),//low=subtractor
	.clock(clk),
	.dataa( 32'h3f800000 ),//one in ieee754
	.datab( exp_out_p2 ),//e^-z
	.nan(),//dont care yet
	.overflow(),//dont care
	.result(sub_out_p2),
	.underflow(),//dont care
	.zero());//dont care
ieee754_add sub3 ( //7 cycles
	.add_sub(1'b1),//low=subtractor
	.clock(clk),
	.dataa( 32'h3f800000 ),//one in ieee754
	.datab( exp_out_p3 ),//e^-z
	.nan(),//dont care yet
	.overflow(),//dont care
	.result(sub_out_p3),
	.underflow(),//dont care
	.zero());//dont care
//dividers
ieee754_div div0 (//1 divide by sub out, 6 cycles
	.clock(clk),
	.dataa( 32'h3f800000 ),
	.datab( sub_out_p0 ),
	.division_by_zero( div0_p0 ),
	.nan( nan_p0 ),
	.result( out.result_0 ));
ieee754_div div1 (//1 divide by sub out, 6 cycles
	.clock(clk),
	.dataa( 32'h3f800000 ),
	.datab( sub_out_p1 ),
	.division_by_zero( div0_p1 ),
	.nan( nan_p1 ),
	.result( out.result_1 ));
ieee754_div div2 (//1 divide by sub out, 6 cycles
	.clock(clk),
	.dataa( 32'h3f800000 ),
	.datab( sub_out_p2 ),
	.division_by_zero( div0_p2 ),
	.nan( nan_p2 ),
	.result( out.result_2 ));
ieee754_div div3 (//1 divide by sub out, 6 cycles
	.clock(clk),
	.dataa( 32'h3f800000 ),
	.datab( sub_out_p3 ),
	.division_by_zero( div0_p3 ),
	.nan( nan_p3 ),
	.result( out.result_3 ));

always @ ( posedge clk )
begin
	if( reset == 1 ) begin
		word_sel0 <= '0;
		word_sel1 <= '0;
		word_sel2 <= '0;
		word_sel3 <= '0;
		word_sel4 <= '0;
		word_sel5 <= '0;
		word_sel6 <= '0;
		word_sel7 <= '0;
		word_sel8 <= '0;
		word_sel9 <= '0;
		word_sel10<= '0;
		word_sel11<= '0;
		word_sel12<= '0;
		word_sel13<= '0;
		word_sel14<= '0;
		word_sel15<= '0;
		word_sel16<= '0;
		word_sel17<= '0;
		word_sel18<= '0;
		word_sel19<= '0;
		word_sel20<= '0;
		word_sel21<= '0;
		word_sel22<= '0;
		word_sel23<= '0;
		word_sel24<= '0;
		word_sel25<= '0;
		word_sel26<= '0;
		word_sel27<= '0;
		word_sel28<= '0;
		word_sel29<= '0;

		index0 <= '0;
		index1 <= '0;
		index2 <= '0;
		index3 <= '0;
		index4 <= '0;
		index5 <= '0;
		index6 <= '0;
		index7 <= '0;
		index8 <= '0;
		index9 <= '0;
		index10<= '0;
		index11<= '0;
		index12<= '0;
		index13<= '0;
		index14<= '0;
		index15<= '0;
		index16<= '0;
		index17<= '0;
		index18<= '0;
		index19<= '0;
		index20<= '0;
		index21<= '0;
		index22<= '0;
		index23<= '0;
		index24<= '0;
		index25<= '0;
		index26<= '0;
		index27<= '0;
		index28<= '0;
		index29<= '0;

		reg_wen0 <= '0;
		reg_wen1 <= '0;
		reg_wen2 <= '0;
		reg_wen3 <= '0;
		reg_wen4 <= '0;
		reg_wen5 <= '0;
		reg_wen6 <= '0;
		reg_wen7 <= '0;
		reg_wen8 <= '0;
		reg_wen9 <= '0;
		reg_wen10<= '0;
		reg_wen11<= '0;
		reg_wen12<= '0;
		reg_wen13<= '0;
		reg_wen14<= '0;
		reg_wen15<= '0;
		reg_wen16<= '0;
		reg_wen17<= '0;
		reg_wen18<= '0;
		reg_wen19<= '0;
		reg_wen20<= '0;
		reg_wen21<= '0;
		reg_wen22<= '0;
		reg_wen23<= '0;
		reg_wen24<= '0;
		reg_wen25<= '0;
		reg_wen26<= '0;
		reg_wen27<= '0;
		reg_wen28<= '0;
		reg_wen29<= '0;//'
	end
	else begin
		word_sel0 <= in.word_sel;
		word_sel1 <= word_sel0;
		word_sel2 <= word_sel1;
		word_sel3 <= word_sel2;
		word_sel4 <= word_sel3;
		word_sel5 <= word_sel4;
		word_sel6 <= word_sel5;
		word_sel7 <= word_sel6;
		word_sel8 <= word_sel7;
		word_sel9 <= word_sel8;
		word_sel10<= word_sel9;
		word_sel11<= word_sel10;
		word_sel12<= word_sel11;
		word_sel13<= word_sel12;
		word_sel14<= word_sel13;
		word_sel15<= word_sel14;
		word_sel16<= word_sel15;
		word_sel17<= word_sel16;
		word_sel18<= word_sel17;
		word_sel19<= word_sel18;
		word_sel20<= word_sel19;
		word_sel21<= word_sel20;
		word_sel22<= word_sel21;
		word_sel23<= word_sel22;
		word_sel24<= word_sel23;
		word_sel25<= word_sel24;
		word_sel26<= word_sel25;
		word_sel27<= word_sel26;
		word_sel28<= word_sel27;
		word_sel29<= word_sel28;

		index0 <= in.index;
		index1 <= index0;
		index2 <= index1;
		index3 <= index2;
		index4 <= index3;
		index5 <= index4;
		index6 <= index5;
		index7 <= index6;
		index8 <= index7;
		index9 <= index8;
		index10<= index9;
		index11<= index10;
		index12<= index11;
		index13<= index12;
		index14<= index13;
		index15<= index14;
		index16<= index15;
		index17<= index16;
		index18<= index17;
		index19<= index18;
		index20<= index19;
		index21<= index20;
		index22<= index21;
		index23<= index22;
		index24<= index23;
		index25<= index24;
		index26<= index25;
		index27<= index26;
		index28<= index27;
		index29<= index28;

		reg_wen0 <= in.reg_wen;
		reg_wen1 <= reg_wen0;
		reg_wen2 <= reg_wen1;
		reg_wen3 <= reg_wen2;
		reg_wen4 <= reg_wen3;
		reg_wen5 <= reg_wen4;
		reg_wen6 <= reg_wen5;
		reg_wen7 <= reg_wen6;
		reg_wen8 <= reg_wen7;
		reg_wen9 <= reg_wen8;
		reg_wen10<= reg_wen9;
		reg_wen11<= reg_wen10;
		reg_wen12<= reg_wen11;
		reg_wen13<= reg_wen12;
		reg_wen14<= reg_wen13;
		reg_wen15<= reg_wen14;
		reg_wen16<= reg_wen15;
		reg_wen17<= reg_wen16;
		reg_wen18<= reg_wen17;
		reg_wen19<= reg_wen18;
		reg_wen20<= reg_wen19;
		reg_wen21<= reg_wen20;
		reg_wen22<= reg_wen21;
		reg_wen23<= reg_wen22;
		reg_wen24<= reg_wen23;
		reg_wen25<= reg_wen24;
		reg_wen26<= reg_wen25;
		reg_wen27<= reg_wen26;
		reg_wen28<= reg_wen27;
		reg_wen29<= reg_wen28;
	end
end

assign out.error_0 = div0_p0 | nan_p0;
assign out.error_1 = div0_p1 | nan_p1;
assign out.error_2 = div0_p2 | nan_p2;
assign out.error_3 = div0_p3 | nan_p3;

assign out.index_o    = index29;
assign out.word_sel_o = word_sel29;
assign out.reg_wen_o  = reg_wen29;//30 cycle latency
assign out.empty      = !(reg_wen0 |reg_wen1 |reg_wen2 |
					 	  reg_wen3 |reg_wen4 |reg_wen5 |
					 	  reg_wen6 |reg_wen7 |reg_wen8 |
					 	  reg_wen9 |reg_wen10|reg_wen11|
					 	  reg_wen12|reg_wen13|reg_wen14|
					 	  reg_wen15|reg_wen16|reg_wen17|
					 	  reg_wen18|reg_wen19|reg_wen20|
					 	  reg_wen21|reg_wen22|reg_wen23|
					 	  reg_wen24|reg_wen25|reg_wen26|
					 	  reg_wen27|reg_wen28|reg_wen29);

endmodule
