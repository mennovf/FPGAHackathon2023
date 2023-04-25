//----------------------------------------------------------------------------------------
// TASK 8: BUTTERFLY 
// 
//----------------------------------------------------------------------------------------
module butterfly(i_clk, i_rst, i_data, i_enb, o_valid, o_A_re, o_A_im, o_B_re, o_B_im);
localparam ALEN = 240;
//-----		INPUTS		------------------------------------------------------------------	
	input i_clk;
	input i_rst;
	input i_enb;
	input [7:0]  i_data;
//-----		OUTPUTS		------------------------------------------------------------------	
	output [31:0] o_A_re;
	output [31:0] o_A_im;
	output [31:0] o_B_re;
	output [31:0] o_B_im;
	output o_valid;
//-----    WIRES         -----------------------------------------------------------------
//-----    REGS         ------------------------------------------------------------------

reg [7:0] ps[ALEN];
reg [7:0] index;
reg r_ovalid;

reg [31:0] fpu_mul_a[4];
reg [31:0] fpu_mul_b[4];
reg [31:0] fpu_mul_out[4];
reg [7:0] fpu_wait;

reg [31:0] fpu_sub_a[2];
reg [31:0] fpu_sub_b[2];
reg [31:0] fpu_sub_out[2];
reg [31:0] fpu_add_a[2];
reg [31:0] fpu_add_b[2];
reg [31:0] fpu_add_out[2];

reg [31:0] a_re;
reg [31:0] a_im;
reg [31:0] b_re;
reg [31:0] b_im;

wire [31:0] x_re;
wire [31:0] x_im;
wire [31:0] y_re;
wire [31:0] y_im;
wire [31:0] w_re;
wire [31:0] w_im;

genvar i;
//========================================================================================
//    		MODULE CONTENT		
//========================================================================================	
typedef enum {s_RECEIVING, s_MULTS, s_WAIT_MULTS, s_ADDS, s_WAIT_ADDS, s_ADDS2, s_WAIT_ADDS2} invsqrt_state;
invsqrt_state 					           state          = s_RECEIVING;

/*
generate
	for(i=0;i<4;i++) begin: fpumuls
	fpumul fpumulinst (
		.clk (i_clk),    //    clk.clk
		.areset(1'b0), // areset.reset
		.a(fpu_mul_a[i]),
		.b(fpu_mul_b[i]),//      a.a
		.q(fpu_mul_out[i])       //      q.q
	);
	end
endgenerate

fpusub fpusub0 (
		.clk (i_clk),    //    clk.clk
		.areset(1'b0), // areset.reset
		.a(fpu_sub_a[0]),
		.b(fpu_sub_b[0]),//      a.a
		.q(fpu_sub_out[0]) 
);
fpusub fpusub1 (
		.clk (i_clk),    //    clk.clk
		.areset(1'b0), // areset.reset
		.a(fpu_sub_a[1]),
		.b(fpu_sub_b[1]),//      a.a
		.q(fpu_sub_out[1]) 
);

fpuadd fpuadd0 (
		.clk (i_clk),    //    clk.clk
		.areset(1'b0), // areset.reset
		.a(fpu_add_a[0]),
		.b(fpu_add_b[0]),//      a.a
		.q(fpu_add_out[0]) 
);
fpuadd fpuadd1 (
		.clk (i_clk),    //    clk.clk
		.areset(1'b0), // areset.reset
		.a(fpu_add_a[1]),
		.b(fpu_add_b[1]),//      a.a
		.q(fpu_add_out[1]) 
);


//-----------------------------------------------------------------------------
//-----		MODULE CONTENT		-------------------------------------------------
//-----------------------------------------------------------------------------

always @(posedge i_clk) begin
	if (i_rst) begin
		state <= s_RECEIVING;
		index <= 0;
		r_ovalid <= 1'b0;
		fpu_wait <= 0;
		
	end else begin
		r_ovalid <= 1'b0;
		case (state)
			s_RECEIVING: begin
				r_ovalid <= 1'b0;
				if (i_enb) begin
					ps[index] <= i_data;
					if (index == ALEN - 1) begin
						index <= 0;
						state <= s_MULTS;
					end else
						index <= index + 1'b1;
				end
			end
			
			s_MULTS: begin
				fpu_mul_a[0] <= y_re;
				fpu_mul_b[0] <= w_re;
				
				fpu_mul_a[1] <= w_im;
				fpu_mul_b[1] <= y_im;
				
				fpu_mul_a[2] <= w_re;
				fpu_mul_b[2] <= y_im;
				
				fpu_mul_a[3] <= y_re;
				fpu_mul_b[3] <= w_im;
				
				state <= s_WAIT_MULTS;
				fpu_wait <= 0;
			end
			
			s_WAIT_MULTS: begin
				if (fpu_wait == 20) begin
					state <= s_ADDS;
				end else begin
					fpu_wait <= fpu_wait + 1;
				end
			end
			
			s_ADDS: begin
				fpu_sub_a[0] <= fpu_mul_out[0];
				fpu_sub_b[0] <= fpu_mul_out[1];
				
				fpu_add_a[0] <= fpu_mul_out[2];
				fpu_add_b[0] <= fpu_mul_out[3];
				
				state <= s_WAIT_ADDS;
				fpu_wait <= 0;
			end
			
			s_WAIT_ADDS: begin
				if (fpu_wait == 20) begin
					state <= s_ADDS2;
				end else begin
					fpu_wait <= fpu_wait + 1;
				end
			end
			
			s_ADDS2: begin
				fpu_add_a[0] <= x_re;
				fpu_add_b[0] <= fpu_sub_out[0];
				fpu_add_a[1] <= x_im;
				fpu_add_b[1] <= fpu_add_out[0];
				
				fpu_sub_a[0] <= x_re;
				fpu_sub_b[0] <= fpu_sub_out[0];
				fpu_sub_a[1] <= x_im;
				fpu_sub_b[1] <= fpu_add_out[0];
				
				state <= s_WAIT_ADDS2;
				fpu_wait <= 0;
			end
			
			s_WAIT_ADDS2: begin
				if (fpu_wait == 20) begin
					a_re <= fpu_add_out[0];
					a_im <= fpu_add_out[1];
					b_re <= fpu_sub_out[0];
					b_im <= fpu_sub_out[1];
					r_ovalid <= 1'b1;
						
					if (index == ALEN - 24) begin
						state <= s_RECEIVING;
						index <= 0;
					end else begin
						index <= index + 24;
						state <= s_MULTS;
					end
				end else begin
					fpu_wait <= fpu_wait + 1;
				end
			end
			
		endcase
	end
end
	*/
	assign x_re = {ps[index], ps[index + 1], ps[index + 2], ps[index + 3]};
	assign x_im = {ps[index + 4], ps[index + 5], ps[index + 6], ps[index + 7]};
	assign y_re = {ps[index + 8], ps[index + 9], ps[index + 10], ps[index + 11]};
	assign y_im = {ps[index + 12], ps[index + 13], ps[index + 14], ps[index + 15]};
	assign w_re = {ps[index + 16], ps[index + 17], ps[index + 18], ps[index + 19]};
	assign w_im = {ps[index + 20], ps[index + 21], ps[index + 22], ps[index + 23]};
	
	assign o_A_re = a_re; 	// Just a dummy assignement. Replace with your code.
	assign o_A_im = a_im; 	// Just a dummy assignement. Replace with your code.
	assign o_B_re = b_re; 	// Just a dummy assignement. Replace with your code.
	assign o_B_im = b_im; 	// Just a dummy assignement. Replace with your code.
	assign o_valid = r_ovalid;		// Just a dummy assignement. Replace with your code.	
	
endmodule 