//MAC interface
//Nicholas A. Pfister

`ifndef MAC_IF_VH
`define MAC_IF_VH

interface mac_if;
  
  // mac signals
  //ctrl input
  logic				  reg_wen;//reg write enable in
  logic [3:0]		word_sel;//1 hot enable for four reg writes ports input
  logic [4:0]		index;//base register to write to input
  logic         add_sub;//1 is add, 0 is sub, can be used with mac and add_only
  logic         add_only;//skip the multiplier, only use if pipe is empty first to avoid:
                         //data collisions, structural hazard, data dependencies
                         //add_only will take precedence and delete any mac it collides with
                         //active high, inputs are DATAA and DATAB
                         //latency will be 7 instead of 12
  //data input
  logic [31:0]		dataa_0;//mul a
  logic [31:0]		datab_0;//mul b
  logic [31:0]		datac_0;//accumulator value to be added to mul result
  
  logic [31:0]		dataa_1;//mul a
  logic [31:0]		datab_1;//mul b
  logic [31:0]		datac_1;//accumulator value to be added to mul result
  
  logic [31:0]		dataa_2;//mul a
  logic [31:0]		datab_2;//mul b
  logic [31:0]		datac_2;//accumulator value to be added to mul result
  
  logic [31:0]		dataa_3;//mul a
  logic [31:0]		datab_3;//mul b
  logic [31:0]		datac_3;//accumulator value to be added to mul result
  //output
  logic [31:0]		result_0;
  logic [31:0]		result_1;
  logic [31:0]		result_2;
  logic [31:0]		result_3;
  
  logic 			  empty;//all pipe stages in all 4 pipes empty
  logic				  reg_wen_o;//reg write enable output
  logic [3:0]		word_sel_o;//1 hot enable for four reg writes ports output
  logic [4:0]		index_o;//base register to write to output

  logic				nan_0;//error in pipe 0
  logic				nan_1;//error in pipe 1
  logic				nan_2;//error in pipe 2
  logic				nan_3;//error in pipe 3

  // ctrl to mac ports
  modport macin (
    input   reg_wen, word_sel, index, add_sub, add_only,
    input	dataa_0, datab_0, datac_0,
    input	dataa_1, datab_1, datac_1,
    input	dataa_2, datab_2, datac_2,
    input	dataa_3, datab_3, datac_3    
  );

  // mac to reg file ports
  modport macout (
    output  result_0, result_1, result_2, result_3,
    output  nan_0, nan_1, nan_2, nan_3,
    output  empty, reg_wen_o, word_sel_o, index_o
  );

endinterface

`endif //MAC_IF_VH

