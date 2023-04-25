//-----------------------------------------------------------------------------
// TASK 4: DIRECTION DETECTOR
//
//-----------------------------------------------------------------------------
module dir_detector(i_clk, i_rst, i_enb, o_dir, i_data, o_valid);
localparam ALEN = 240;

localparam C = 9'd437;
//-----		INPUTS		-------------------------------------------------------
	input i_clk;
	input i_rst;
	input i_enb;
	input signed [7:0] i_data;
//-----		OUTPUTS		-------------------------------------------------------	
   output [2:0] o_dir;
   output o_valid;
//-----		WIRES			-------------------------------------------------------


wire signed [7:0] w_vx;
wire signed [7:0] w_vy;
reg signed [16:0] w_vx2;
reg signed [16:0] w_vy2;
reg signed [17:0] w_vxy2;
reg signed [26:0] w_cvxy2;
reg signed [26:0] w_svx2;
reg signed [26:0] w_svy2;

//-----		REGS			-------------------------------------------------------
reg signed [7:0] ps[ALEN];
reg [7:0] index;
reg r_ovalid;
reg [2:0] r_dout;
//-----		OTHERS      -------------------------------------------------------

typedef enum {s_RECEIVING, s_PROCESSING0, s_PROCESSING1} dir_state;
dir_state 					           state          = s_RECEIVING;

//-----------------------------------------------------------------------------
//-----		MODULE CONTENT		-------------------------------------------------
//-----------------------------------------------------------------------------

always @(posedge i_clk) begin
	if (i_rst) begin
		state <= s_RECEIVING;
		index <= 0;
		r_ovalid <= 1'b0;
	end else begin
		case (state)
			s_RECEIVING: begin
				r_ovalid <= 1'b0;
				if (i_enb) begin
					ps[index] <= i_data;
					if (index == ALEN - 1) begin
						index <= 0;
						state <= s_PROCESSING0;
					end else
						index <= index + 1'b1;
				end
			end
			

			s_PROCESSING0: begin
				w_vx2 = w_vx * w_vx;
				w_vy2 = w_vy * w_vy;
				w_vxy2 <= w_vx2 + w_vy2;
				state <= s_PROCESSING1;
				r_ovalid <= 1'b0;
			end
			
			s_PROCESSING1: begin
				w_cvxy2 = C * w_vxy2;
				w_svx2 = w_vx2 << 9;
				w_svy2 = w_vy2 << 9;
				
				if (w_svy2 >= w_cvxy2)
					r_dout <= 3'b010;
				else if (w_svx2 >= w_cvxy2)
					r_dout <= 3'b001;
				else if (w_vx[7] ^ w_vy[7])
					r_dout <= 3'b011;
				else
					r_dout <= 3'b100;
				
				r_ovalid <= 1'b1;
				if (index == ALEN - 2) begin
					state <= s_RECEIVING;
					index <= 0;
				end else	begin
					index <= index + 2'b10;
					state <= s_PROCESSING0;
				end
			end
		endcase
	end
end


assign w_vx = ps[index];
assign w_vy = ps[index+1];
assign o_dir = r_dout;
assign o_valid = r_ovalid;
	
endmodule 