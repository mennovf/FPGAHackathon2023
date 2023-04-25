//----------------------------------------------------------------------------------------
// TASK 9: 1/SQRT(X) 
// 
//----------------------------------------------------------------------------------------
module reciprocal_sqrt(i_clk, i_rst, i_enb, i_data, o_valid, o_data);
localparam ALEN = 40;

//-----		INPUTS		------------------------------------------------------------------	
		input i_clk;
		input i_rst;
		input i_enb;
		input [7:0] i_data;
//-----		OUTPUTS		------------------------------------------------------------------		
		output o_valid;
		output [31:0] o_data;
//-----    WIRES         -----------------------------------------------------------------
//-----    REGS         ------------------------------------------------------------------
reg signed [7:0] ps[ALEN];
reg [7:0] index;
reg r_ovalid;
reg [31:0] r_odata;

reg [31:0] fpu_in = 32'd0;
reg [31:0] result;
reg enable = 1'b0;

reg [7:0] counter = 0;
//========================================================================================
//    		MODULE CONTENT		
//========================================================================================
typedef enum {s_RECEIVING, s_INV, s_WAIT_INV} invsqrt_state;
invsqrt_state 					           state          = s_RECEIVING;

fpu fpuinst (
		.clk (i_clk),    //    clk.clk
		.areset(1'b0), // areset.reset
		.a(fpu_in),      //      a.a
		.q(result)       //      q.q
	);



//-----------------------------------------------------------------------------
//-----		MODULE CONTENT		-------------------------------------------------
//-----------------------------------------------------------------------------

always @(posedge i_clk) begin
	if (i_rst) begin
		state <= s_RECEIVING;
		index <= 0;
		r_ovalid <= 1'b0;
		fpu_in <= 32'd0;
		
	end else begin
		r_ovalid <= 1'b0;
		case (state)
			s_RECEIVING: begin
				r_ovalid <= 1'b0;
				if (i_enb) begin
					ps[index] <= i_data;
					if (index == ALEN - 1) begin
						index <= 0;
						state <= s_INV;
					end else
						index <= index + 1'b1;
				end
			end
			
			
			s_INV: begin
				fpu_in[7:0] <= ps[index + 3];
				fpu_in[15:8] <= ps[index + 2];
				fpu_in[23:16] <= ps[index + 1];
				fpu_in[31:24] <= ps[index + 0];
			
				counter <= 0;
				state <= s_WAIT_INV;
			end
			
			s_WAIT_INV: begin
				if (counter == 20) begin
					r_odata <= result;
					r_ovalid <= 1'b1;
					
					if (index == ALEN - 4) begin
						state <= s_RECEIVING;
						index <= 0;
					end else begin
						state <= s_INV;
						index <= index + 4;
					end
				end else begin
					counter <= counter + 1;
				end
			end
		endcase
	end
end
	
	assign o_data = r_odata; // Just a dummy assignement. Replace with your code.
	assign o_valid = r_ovalid; // Just a dummy assignement. Replace with your code.
		
endmodule 