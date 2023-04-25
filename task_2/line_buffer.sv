//-----------------------------------------------------------------
// TASK 2: LINE BUFFER
//
//-----------------------------------------------------------------
module line_buffer (i_clk, i_rst, i_data, i_enb, o_valid, o_data);
localparam ALEN = 25;
//-----		INPUTS		-------------------------------------------	
	input i_clk;
	input i_rst;
	input i_enb;
	input [7:0] i_data;
//-----		OUTPUTS		-------------------------------------------	
	output o_valid;
	output [7:0] o_data[9];
//-----		WIRES			-------------------------------------------	

//-----		REGS			-------------------------------------------
reg [7:0] ps[ALEN];
reg [4:0] index;

reg [2:0] x;
reg [2:0] y;

reg [7:0] line[9];

reg r_ovalid;

//-----		OTHERS      -------------------------------------------
typedef enum {s_RECEIVING, s_PROCESSING} lb_state;
lb_state state = s_RECEIVING;

//-----------------------------------------------------------------
//-----		MODULE CONTENT		-------------------------------------
//-----------------------------------------------------------------


always @(posedge i_clk) begin
	if (i_rst) begin
		index <= 0;
		state <= s_RECEIVING;
		r_ovalid <= 1'b0;
	end else begin
		r_ovalid <= 1'b0;
		case (state)
			s_RECEIVING: begin
				if (i_enb) begin
					ps[index] <= i_data;
					
					if (index == ALEN - 1) begin
						state <= s_PROCESSING;
						index <= 0;
						x <= 0;
						y <= 0;
						r_ovalid <= 1'b1;
					end else begin
						index <= index + 1;
					end
				end
			end
			
			s_PROCESSING: begin
				r_ovalid <= 1'b1;
				
				if (x == 2) begin
					if (y == 2) begin
						r_ovalid <= 1'b0;
						state <= s_RECEIVING;
					end else begin
						y <= y + 1;
						x <= 0;
					end
				end else begin
					x <= x + 1;
				end
			end
		endcase
	end
end
	
	assign o_valid = r_ovalid;   	// Just a dummy assignement. Replace with your code.
	assign o_data[0] = ps[y * 5 + x];	// Just a dummy assignement. Replace with your code.
	assign o_data[1] = ps[y * 5 + x + 1];	// Just a dummy assignement. Replace with your code.
	assign o_data[2] = ps[y * 5 + x + 2];	// Just a dummy assignement. Replace with your code.
	assign o_data[3] = ps[y * 5 + x + 5];	// Just a dummy assignement. Replace with your code.
	assign o_data[4] = ps[y * 5 + x + 6];	// Just a dummy assignement. Replace with your code.
	assign o_data[5] = ps[y * 5 + x + 7];	// Just a dummy assignement. Replace with your code.
	assign o_data[6] = ps[y * 5 + x + 10];	// Just a dummy assignement. Replace with your code.
	assign o_data[7] = ps[y * 5 + x + 11];	// Just a dummy assignement. Replace with your code.
	assign o_data[8] = ps[y * 5 + x + 12];	// Just a dummy assignement. Replace with your code.
	
endmodule 