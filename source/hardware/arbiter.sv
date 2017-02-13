//Original Author: John J. Skubic
`include "quadport_ram_if.vh"

module arbiter (
  quadport_ram_if qrif1,
  quadport_ram_if qrif2,
  quadport_ram_if qrifo
);

  //static priority given to qrif1

  always_comb begin
    if(qrif1.ren | qrif1.wen) begin
      qrifo.addr  = qrif1.addr;
      qrifo.wen   = qrif1.wen;
      qrifo.ren   = qrif1.ren;
      qrifo.din_a = qrif1.din_a;
      qrifo.din_b = qrif1.din_b;
      qrifo.din_c = qrif1.din_c;
      qrifo.din_d = qrif1.din_d;
      qrifo.four  = qrif1.four;
    end  
    else begin
      qrifo.addr  = qrif2.addr;
      qrifo.wen   = qrif2.wen;
      qrifo.ren   = qrif2.ren;
      qrifo.din_a = qrif2.din_a;
      qrifo.din_b = qrif2.din_b;
      qrifo.din_c = qrif2.din_c;
      qrifo.din_d = qrif2.din_d;
      qrifo.four  = qrif2.four;
    end
  end

  assign qrif1.dout_a = qrifo.dout_a;
  assign qrif1.dout_b = qrifo.dout_b;
  assign qrif1.dout_c = qrifo.dout_c;
  assign qrif1.dout_d = qrifo.dout_d;

  assign qrif2.dout_a = qrifo.dout_a;
  assign qrif2.dout_b = qrifo.dout_b;
  assign qrif2.dout_c = qrifo.dout_c;
  assign qrif2.dout_d = qrifo.dout_d;
endmodule
