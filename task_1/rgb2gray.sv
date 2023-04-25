//----------------------------------------------------------------------------------------
// TASK 1: RGB 2 Grayscale 
// 
//----------------------------------------------------------------------------------------
module rgb2gray(i_clk, i_rst, i_enb, i_RGB, o_gray, o_valid);

  localparam INPUT_LENGTH = 243;
   
//-----		INPUTS		------------------------------------------------------------------
	input i_clk;
	input i_rst;
	input i_enb;
	input [7:0] i_RGB;
//-----		OUTPUTS		------------------------------------------------------------------
	output [7:0] o_gray;
	output o_valid;
//-----    WIRES         -----------------------------------------------------------------
	reg [31:0] result;
//-----    REGS         ------------------------------------------------------------------
	reg [7:0] index;
   reg [7:0] ps[INPUT_LENGTH];
	reg [7:0] r_gray;
	reg [22:0] r;
	reg [22:0] g;
	reg [22:0] b;
	reg r_valid;
	
	wire [7:0] inr;
	wire [7:0] ing;
	wire [7:0] inb;
   
//-----    OTHERS         ------------------------------------------------------------------
  typedef enum {s_RECEIVING, s_PROCESSING} dir_state;
  dir_state state = s_RECEIVING;
   
   
//========================================================================================
//    		MODULE CONTENT		
//========================================================================================

   always @(posedge i_clk) begin
      if (i_rst) begin
         index <= 0;
         state <= s_RECEIVING;
         r_valid <= 1'b0;
      end
		else begin
			r_valid <= 1'b0;
        case (state)
          s_RECEIVING: begin
				 r_valid <= 1'b0;
             if (i_enb) begin
                ps[index][7:0] <= i_RGB;
                if (index == INPUT_LENGTH - 1) begin
                   index <= 0;
                   state <= s_PROCESSING;
					 end
                else begin
                  index <= index + 1'b1;
                end
             end
          end

          s_PROCESSING: begin
				r = inr * 22'd1225;
				g = ing * 22'd2404;
				b = inb * 22'd467;
				
				r_gray <= (22'd2048 + r + g + b) >> 12;
							
				r_valid <= 1'b1;
				
				
				if (index == INPUT_LENGTH-3) begin
					state <= s_RECEIVING;
					index <= 0;
				end else begin
					index <= index + 3;
				end
          end
          
        endcase
      end
   end // always @ (posedge i_clk)
	
	assign inr = ps[index+0];
	assign ing = ps[index+1];
	assign inb = ps[index+2];
	assign o_gray = r_gray;
	assign o_valid = r_valid;
endmodule 