/*
 *  Register File containing:
 *    4 regs -> activations from last stage
 *    32 regs -> accumulator for current stage 
 *     
 *  QuadPort Writes (must be concurrent) 
 *  QuadPort Reads  (must be concurrent)
 */

module regfile (
  input logic CLK, RST,
  input logic rst_syn,
  input logic [3:0][31:0] wdata,
  input logic [3:0] word_en, //for writes
  input logic act_wen,
  input logic acc_wen,
  input logic [4:0] acc_sel_w,
  input logic [4:0] acc_sel_r,
  output logic [31:0] rdata_act,
  output logic [3:0][31:0] rdata_acc
);

  // Registers
  logic [31:0] act_data;
  logic [31:0][31:0] acc_data;

  // Write Ports
  always_ff @ (posedge CLK, posedge RST) begin
    if(RST) begin
      acc_data <= '0;
    end else if (rst_syn) begin
      acc_data <= '0;
    end else if (acc_wen) begin
      if(word_en == 4'h1) begin
        acc_data[acc_sel_w] <= wdata[0];
      end else if (word_en == 4'h3) begin
        {acc_data[acc_sel_w +1], acc_data[acc_sel_w]} <= wdata[1:0];
      end else if (word_en == 4'h7) begin 
        {acc_data[acc_sel_w +2], acc_data[acc_sel_w +1], acc_data[acc_sel_w]} <= wdata[2:0];
      end else if (word_en == 4'hf) begin
        {acc_data[acc_sel_w +3], acc_data[acc_sel_w +2], acc_data[acc_sel_w +1], acc_data[acc_sel_w]} <= wdata[3:0];
      end
    end
  end

  always_ff @ (posedge CLK, posedge RST) begin
    if(RST) begin 
      act_data <= '0;
    end else if (rst_syn) begin
      act_data <= '0;
    end else if (act_wen) begin
      act_data <= wdata[0];
    end
  end

  // Read Ports
  assign rdata_act = act_data;
  assign rdata_acc = {acc_data[acc_sel_r+3], acc_data[acc_sel_r+2], acc_data[acc_sel_r+1], acc_data[acc_sel_r]};

endmodule
