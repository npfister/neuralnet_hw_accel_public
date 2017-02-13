/*
 * Created By: John Skubic
 * Controller for the feedforward algorithm 
 */

`include "quadport_ram_if.vh"

module feedforward_controller (
  input logic CLK, RST,
  input logic start_flg, mac_pipe_clr, sigmoid_pipe_clr, 
  input logic [15:0] addr_w1, addr_w2, addr_b1, addr_b2, addr_act,
  input logic [15:0] size_l0, size_l1, size_l2,
  output logic done_flg, layer_prep_stb, issue_mac, issue_add, issue_sigmoid, load_act_flg, 
  output logic [4:0] reg_sel,
  output logic [3:0] word_sel,
  input logic [3:0][31:0] ram_store,
  quadport_ram_if qrif
);

  typedef enum logic [3:0] {
    IDLE=4'h0, 
    CALC_LAYER_PREP,  //this state resets all registers and fetches base addr
    LOAD_ACT,         //reset of MAC cnt happens here
    MAC_ISSUE,        //loops until all MACS are issued
    MAC_WAIT,         //waits until all MACS are cleared
    BIAS_PREP,
    BIAS_ISSUE,
    BIAS_WAIT,
    SIGMOID_PREP,
    SIGMOID_ISSUE,    //loops until all sigmoids are issued (adds bias and sigmoid)
    SIGMOID_WAIT,     // waits until all MACS are cleared
    STORE_PREP,       //get ready to store output activations
    STORE_OUTPUT,     //loops and stores all output activations
    LAYER_DONE,        //finished, checks if more layers are left
    DONE
  } state_t;

  state_t curr_state, next_state;
  logic issues_remaining; // indicates there are outstanding issue requests
  logic mac_pipe_clear; //indicates no operations are present in the MAC units
  logic [4:0] pending_issues, pending_issues_next;
  logic [4:0] curr_layer_size, curr_layer_size_next;
  logic [2:0] nlayers, nlayers_next;
  logic [2:0] curr_layer, curr_layer_next;

  logic [15:0] weight_base_addr, act_base_addr, curr_addr_w, curr_addr_a;
  logic [15:0] bias_base_addr, curr_addr_b, curr_addr_b_next, bias_base_addr_next;
  logic [15:0] curr_addr_w_next, curr_addr_a_next, weight_base_addr_next, act_base_addr_next;

  logic [15:0] acts_remaining, acts_remaining_next;

  logic layers_pending;
  logic [3:0][31:0] ram_load;
  logic [15:0] ram_addr;

  
  assign ram_load[0] = qrif.dout_a;
  assign ram_load[1] = qrif.dout_b; 
  assign ram_load[2] = qrif.dout_c;
  assign ram_load[3] = qrif.dout_d;

  assign qrif.din_a = ram_store[0];
  assign qrif.din_b = ram_store[1]; 
  assign qrif.din_c = ram_store[2];
  assign qrif.din_d = ram_store[3];

  assign qrif.addr = ram_addr;

  always_ff @ (posedge CLK, posedge RST) begin
    if(RST) begin
      curr_state <= IDLE;
      curr_layer_size <= 0;
      nlayers <= 0;
      curr_layer <= 0;
      pending_issues <= 0;
      weight_base_addr <= 0;
      act_base_addr <= 0;
      curr_addr_w <= 0;
      curr_addr_a <= 0;
      acts_remaining <= 0;
      bias_base_addr <= 0;
      curr_addr_b <= 0;
    end else begin/*All activations used*/
      curr_state <= next_state;
      curr_layer_size <= curr_layer_size_next;
      nlayers <= nlayers_next;
      curr_layer <= curr_layer_next;
      pending_issues <= pending_issues_next;
      weight_base_addr <= weight_base_addr_next;
      act_base_addr <= act_base_addr_next;
      curr_addr_w <= curr_addr_w_next;
      curr_addr_a <= curr_addr_a_next;
      acts_remaining <= acts_remaining_next;
      bias_base_addr <= bias_base_addr_next;
      curr_addr_b <= curr_addr_b_next;
    end  
  end

  /* NEXT STATE LOGIC */

  always_comb begin
    next_state = curr_state;
    casez (curr_state) 
      IDLE : begin
        if (start_flg) next_state = CALC_LAYER_PREP; 
      end
      CALC_LAYER_PREP : begin
        next_state = LOAD_ACT;
      end
      LOAD_ACT : begin
        next_state = MAC_ISSUE;
      end
      MAC_ISSUE : begin
        if(!issues_remaining) next_state = MAC_WAIT;
      end
      MAC_WAIT : begin
        if(mac_pipe_clr) begin
            if(acts_remaining == 0)
              next_state = BIAS_PREP;
            else
              next_state = LOAD_ACT;
        end  
      end
      BIAS_PREP : begin
        next_state = BIAS_ISSUE;
      end
      BIAS_ISSUE : begin
        if(!issues_remaining) next_state = BIAS_WAIT;
      end
      BIAS_WAIT : begin
        if(mac_pipe_clr) begin
          next_state = SIGMOID_PREP; 
        end
      end 
      SIGMOID_PREP : begin
        next_state = SIGMOID_ISSUE;
      end
      SIGMOID_ISSUE : begin
        if(!issues_remaining) next_state = SIGMOID_WAIT;
      end
      SIGMOID_WAIT : begin
        if(sigmoid_pipe_clr) next_state = STORE_PREP;
      end
      STORE_PREP : begin
        next_state = STORE_OUTPUT;
      end
      STORE_OUTPUT : begin
        if(!issues_remaining) next_state = LAYER_DONE;
      end
      LAYER_DONE : begin
        if(!layers_pending) next_state = DONE;
        else next_state = CALC_LAYER_PREP;
      end
      DONE : begin
        next_state = IDLE;
      end
      default : begin
        next_state = IDLE;
      end
    endcase  
  end

  /* OUTPUT LOGIC */

  always_comb begin
    layer_prep_stb = 0;
    ram_addr = 0;
    nlayers_next = nlayers;
    curr_layer_next = curr_layer;
    curr_layer_size_next = curr_layer_size;
    weight_base_addr_next = weight_base_addr;
    act_base_addr_next = act_base_addr;
    curr_addr_a_next = curr_addr_a;
    pending_issues_next = pending_issues;
    acts_remaining_next = acts_remaining;
    bias_base_addr_next = bias_base_addr;
    curr_addr_b_next = curr_addr_b;
    curr_addr_w_next = curr_addr_w;
    issue_mac = 0;
    reg_sel = 0;
    issues_remaining = 1;
    issue_sigmoid = 0;
    issue_add = 0;
    done_flg = 0;
    qrif.ren = 0;
    qrif.wen = 0;
    load_act_flg = 0;
    word_sel = 0;
    qrif.four = 1; 

    casez (curr_state) 
      IDLE : begin
        nlayers_next = 2;
        curr_layer_next = 1; 
      end
      CALC_LAYER_PREP : begin
        // Loads the number of neurons in the current layer
        // Loads the base address of the weights
        // Loads the base address of input activations
        layer_prep_stb = 1;
        if(curr_layer == 1) begin
          curr_layer_size_next = size_l1;
          weight_base_addr_next = addr_w1;
          bias_base_addr_next = addr_b1;
          acts_remaining_next = size_l0;
          curr_addr_w_next = addr_w1;
        end else begin
          curr_layer_size_next = size_l2; 
          weight_base_addr_next = addr_w2;
          bias_base_addr_next = addr_b2;
          acts_remaining_next = size_l1;
          curr_addr_w_next = addr_w2;
        end
        act_base_addr_next = addr_act;
        ram_addr = addr_act;
        curr_addr_a_next = addr_act;
        qrif.four = 0;
        qrif.ren = 1;
      end
      LOAD_ACT : begin
        // Loads the next four input activations
        // Increments the pointer to the activations by 4
        // resets the neuron counter
        qrif.ren = 1;
        load_act_flg = 1;
        ram_addr = curr_addr_w;
        curr_addr_w_next = curr_addr_w + 4;
        curr_addr_a_next = curr_addr_a + 1; 
        acts_remaining_next = acts_remaining - 1;
        pending_issues_next = curr_layer_size;
      end
      MAC_ISSUE : begin
        // Issues up to 4 MACS into the pipe (must set addr and word_en)
        //    - Sets the read sel to the reg file
        // Decrements the remaining mac counter and sets issues_remaining
        // Sets the ram address to get the next weights

        issue_mac = 1;
        reg_sel = curr_layer_size - pending_issues;
        if(pending_issues >= 4) begin
          // issue 4 MACS
          pending_issues_next = pending_issues - 4;
          word_sel = 4'hf;
        end else begin
          pending_issues_next = 0;
          casez (pending_issues)
            1 : word_sel = 4'h1;
            2 : word_sel = 4'h3;
            3 : word_sel = 4'h7;
            default : word_sel = 4'h0;
          endcase
        end
        issues_remaining = (pending_issues_next != 0);
        ram_addr = curr_addr_w;
        curr_addr_w_next = issues_remaining ? curr_addr_w + 4 : curr_addr_w;
        qrif.ren = 1;
      end
      MAC_WAIT : begin
        ram_addr = curr_addr_a;
        qrif.ren = 1;
        qrif.four = 0;
      end 
      BIAS_PREP : begin
        qrif.ren = 1;
        ram_addr = bias_base_addr;
        curr_addr_b_next = bias_base_addr+4;
        pending_issues_next = curr_layer_size;
      end
      BIAS_ISSUE : begin
        qrif.ren = 1;
        ram_addr = curr_addr_b;
        curr_addr_b_next = curr_addr_b+4;
        issue_add = 1;
        reg_sel = curr_layer_size - pending_issues;
        if(pending_issues >= 4) begin
          pending_issues_next = pending_issues - 4;
          word_sel = 4'hf;
        end else begin
          pending_issues_next = 0;
          casez (pending_issues)
            1 : word_sel = 4'h1;
            2 : word_sel = 4'h3;
            3 : word_sel = 4'h7;
            default : word_sel = 4'h0;
          endcase
        end
        issues_remaining = (pending_issues_next != 0);
      end
      BIAS_WAIT : begin
        //nothing
      end 
      SIGMOID_PREP : begin
        // Resets the neuron counter
        pending_issues_next = curr_layer_size;
      end
      SIGMOID_ISSUE : begin
        // Issues sigmoid functions (up to 4)
        //    - Sets the read sel to the reg file
        // Decrements remaining counter and sets issues_remaining
        issue_sigmoid = 1;
        reg_sel = curr_layer_size - pending_issues;
        if(pending_issues >= 4) begin
          // issue 4 SIGMOID
          pending_issues_next = pending_issues - 4;
          word_sel = 4'hf;
        end else begin
          pending_issues_next = 0;
          casez (pending_issues)
            1 : word_sel = 4'h1;
            2 : word_sel = 4'h3;
            3 : word_sel = 4'h7;
            default : word_sel = 4'h0;
          endcase
        end
        issues_remaining = (pending_issues_next != 0);
      end
      STORE_PREP : begin
        // Resets the neuron Counter
        pending_issues_next = curr_layer_size;
        curr_addr_a_next = addr_act;
      end
      STORE_OUTPUT : begin
        // Issues up to 4 activation writes to scratch
        // Decrements remaining counter and sets issues remaining 
        // Sets the ram address to store the next output activations
        qrif.wen = 1;
        reg_sel = curr_layer_size - pending_issues;
        ram_addr = curr_addr_a;
        curr_addr_a_next = curr_addr_a + 4;
        if(pending_issues >= 4) begin
          pending_issues_next = pending_issues - 4;
        end else begin
          pending_issues_next = 0;
        end
        issues_remaining = (pending_issues_next != 0);
      end
      LAYER_DONE : begin
        // Increment the layer counter
        // Sets layers pending
        curr_layer_next = curr_layer + 1;
      end
      DONE : begin
        done_flg = 1;
      end
    endcase  
  end

  assign layers_pending = (curr_layer != nlayers);

endmodule
