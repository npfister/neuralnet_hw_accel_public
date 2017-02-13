//Sigmoid interface
//Nicholas A. Pfister

`ifndef SIGMOID_IF_VH
`define SIGMOID_IF_VH

interface sigmoid_if;

  // mac signals
  //ctrl input
  logic				reg_wen;//reg write enable in
  logic [3:0]		word_sel;//1 hot enable for four reg writes ports input
  logic [4:0]		index;//base register to write to input
  //data input
  logic [31:0]		dataa_0;//e^a
  logic [31:0]		dataa_1;//e^a
  logic [31:0]		dataa_2;//e^a
  logic [31:0]		dataa_3;//e^a
  //output
  logic [31:0]		result_0;
  logic [31:0]		result_1;
  logic [31:0]		result_2;
  logic [31:0]		result_3;
  
  logic 			empty;//all pipe stages in all 4 pipes empty
  logic				reg_wen_o;//reg write enable output
  logic [3:0]		word_sel_o;//1 hot enable for four reg writes ports output
  logic [4:0]		index_o;//base register to write to output

  logic				error_0;//error in pipe 0
  logic				error_1;//error in pipe 1
  logic				error_2;//error in pipe 2
  logic				error_3;//error in pipe 3


modport sigin (
	input reg_wen, word_sel, index,
	input dataa_0,dataa_1,dataa_2,dataa_3
	);

modport sigout (
	output  result_0,result_1,result_2,result_3,
	output  error_0, error_1, error_2, error_3,
    output  empty, reg_wen_o, word_sel_o, index_o
	);

endinterface

`endif