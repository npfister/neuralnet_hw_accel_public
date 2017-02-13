//Original Author: Nicholas A. Pfister
//quadport ram memory controller
//purely combinational controller

//300000 bytes
//70,000 32bit words available

`include "quadport_ram_if.vh"

module quadport_ram (
	input logic	clk, reset,
	quadport_ram_if.quadram qram
	);

//declarations
//ram 0
logic 			wen_a;
logic 			wen_b;
logic 			ren_a;
logic 			ren_b;
logic [31:0]	din_a;
logic [31:0]	din_b;
logic [15:0]	addr_a;
logic [15:0]	addr_b;
logic [31:0]	dout_a;
logic [31:0]	dout_b;
//ram 1
logic 			wen_c;
logic 			wen_d;
logic 			ren_c;
logic 			ren_d;
logic [31:0]	din_c;
logic [31:0]	din_d;
logic [15:0]	addr_c;
logic [15:0]	addr_d;
logic [31:0]	dout_c;
logic [31:0]	dout_d;

logic [31:0] addr_flop;
logic four_flop;

always @ (posedge clk, posedge reset) begin
  if(reset) begin
    addr_flop <= 0;
    four_flop <= 0;
  end else begin 
    addr_flop <= qram.addr;
    four_flop <= qram.four;
  end
end


//set signals for cycle 2 (reading)
always_comb begin
  if(!four_flop) begin
    if(addr_flop[1]) begin
      qram.dout_a = dout_c;//read port single mode is dout_a
			qram.dout_b = 32'h0;
			qram.dout_c = 32'h0;
			qram.dout_d = 32'h0;
    end else begin
			qram.dout_a = dout_a;//read port single mode is dout_a
			qram.dout_b = 32'h0;
			qram.dout_c = 32'h0;
			qram.dout_d = 32'h0;
    end
  end else begin
		qram.dout_a = dout_a;
		qram.dout_b = dout_b;
		qram.dout_c = dout_c;
		qram.dout_d = dout_d;
  end
end

//set signals for cycle 1
always_comb
begin
	if( (qram.wen | qram.ren) & ~qram.four) begin //normal one byte operation
		//banked ram
		//  address remap --> native to ramX internal address
		//	addr[15:0] --> 0,addr[15:2],addr[0]

		//ram 0 --> "a or b"
		//ram 1 --> "c or d"		

		if ( qram.addr[1] ) begin//ram 1, i.e. addr[1:0] is 2 or 3
			if(qram.wen) begin
				wen_a = 1'b0;
				wen_b = 1'b0;
				wen_c = 1'b1;//single port mode
				wen_d = 1'b0;
				ren_a = 1'b0;
				ren_b = 1'b0;
				ren_c = 1'b0;
				ren_d = 1'b0;
				addr_a = 16'h0;
				addr_b = 16'h0;
				addr_c = {1'b0,qram.addr[15:2],qram.addr[0]};
				addr_d = 16'h0;
				din_a = 32'h0;
				din_b = 32'h0;
				din_c = qram.din_a;//write port for single mode is din_a
				din_d = 32'h0;
			end
			else begin//ren
				wen_a = 1'b0;
				wen_b = 1'b0;
				wen_c = 1'b0;
				wen_d = 1'b0;
				ren_a = 1'b0;
				ren_b = 1'b0;
				ren_c = 1'b1;//single port mode
				ren_d = 1'b0;
				addr_a = 16'h0;
				addr_b = 16'h0;
				addr_c = {1'b0,qram.addr[15:2],qram.addr[0]};
				addr_d = 16'h0;
				din_a = 32'h0;
				din_b = 32'h0;
				din_c = 32'h0;
				din_d = 32'h0;
			end
		end
		else begin//ram 0
			if(qram.wen) begin
				wen_a = 1'b1;//single port mode
				wen_b = 1'b0;
				wen_c = 1'b0;
				wen_d = 1'b0;
				ren_a = 1'b0;
				ren_b = 1'b0;
				ren_c = 1'b0;
				ren_d = 1'b0;
				addr_a = {1'b0,qram.addr[15:2],qram.addr[0]};
				addr_b = 16'h0;
				addr_c = 16'h0;
				addr_d = 16'h0;
				din_a = qram.din_a;//write port for single mode is din_a
				din_b = 32'h0;
				din_c = 32'h0;
				din_d = 32'h0;
			end
			else begin//ren
				wen_a = 1'b0;
				wen_b = 1'b0;
				wen_c = 1'b0;
				wen_d = 1'b0;
				ren_a = 1'b1;//single port mode
				ren_b = 1'b0;
				ren_c = 1'b0;
				ren_d = 1'b0;
				addr_a = {1'b0,qram.addr[15:2],qram.addr[0]};
				addr_b = 16'h0;
				addr_c = 16'h0;
				addr_d = 16'h0;
				din_a = 32'h0;
				din_b = 32'h0;
				din_c = 32'h0;
				din_d = 32'h0;
			end
		end
	end 
	else if ( qram.wen | qram.ren ) begin //four words to read or write
		//banked ram
		//  address remap --> native to ramX internal address
		//	addr[15:0] --> 0,addr[15:2],addr[0]

		//ram 0 --> "a or b"
		//ram 1 --> "a or b"		
			if(qram.wen) begin
				wen_a = 1'b1;
				wen_b = 1'b1;
				wen_c = 1'b1;
				wen_d = 1'b1;
				ren_a = 1'b0;
				ren_b = 1'b0;
				ren_c = 1'b0;
				ren_d = 1'b0;
				addr_a = {1'b0,qram.addr[15:2],1'b0};
				addr_b = {1'b0,qram.addr[15:2],1'b1};
				addr_c = {1'b0,qram.addr[15:2],1'b0};
				addr_d = {1'b0,qram.addr[15:2],1'b1};
				din_a = qram.din_a;
				din_b = qram.din_b;
				din_c = qram.din_c;
				din_d = qram.din_d;
			end
			else begin//ren
				wen_a = 1'b0;
				wen_b = 1'b0;
				wen_c = 1'b0;
				wen_d = 1'b0;
				ren_a = 1'b1;
				ren_b = 1'b1;
				ren_c = 1'b1;
				ren_d = 1'b1;
				addr_a = {1'b0,qram.addr[15:2],1'b0};
				addr_b = {1'b0,qram.addr[15:2],1'b1};
				addr_c = {1'b0,qram.addr[15:2],1'b0};
				addr_d = {1'b0,qram.addr[15:2],1'b1};
				din_a = 32'h0;
				din_b = 32'h0;
				din_c = 32'h0;
				din_d = 32'h0;
			end
	end
	else begin
		wen_a = 1'b0;
		wen_b = 1'b0;
		wen_c = 1'b0;
		wen_d = 1'b0;
		ren_a = 1'b0;
		ren_b = 1'b0;
		ren_c = 1'b0;
		ren_d = 1'b0;
		addr_a = 32'h0;
		addr_b = 32'h0;
		addr_c = 32'h0;
		addr_d = 32'h0;
		din_a = 16'h0;
		din_b = 16'h0;
		din_c = 16'h0;
		din_d = 16'h0;
	end
end

dualport_ram ram0 (
	.clk(clk),
	.wen_a(wen_a),
	.wen_b(wen_b),
	.ren_a(ren_a),
	.ren_b(ren_b),
	.din_a(din_a),
	.din_b(din_b),
	.addr_a(addr_a),
	.addr_b(addr_b),
	.dout_a(dout_a),
	.dout_b(dout_b)
	);

dualport_ram ram1 (
	.clk(clk),
	.wen_a(wen_c),
	.wen_b(wen_d),
	.ren_a(ren_c),
	.ren_b(ren_d),
	.din_a(din_c),
	.din_b(din_d),
	.addr_a(addr_c),
	.addr_b(addr_d),
	.dout_a(dout_c),
	.dout_b(dout_d)
	);

endmodule
