//----------------------------------------------------------------------------------------
// TASK 10: DEMODULATOR QAM16
// 
//----------------------------------------------------------------------------------------
module demod16(i_clk, i_data, i_rst, i_enb, o_data, o_valid);
localparam ALEN = 256;
//-----		INPUTS		----------------------------------------------------------	
	input i_clk;
	input [7:0] i_data;
	input i_rst;
	input i_enb;
//-----		OUTPUTS		----------------------------------------------------------		
	output [7:0] o_data;
	output o_valid;
//-----    WIRES         -----------------------------------------------------------------
wire signed [7:0] wi0;
wire signed [7:0] wq0;
wire signed [7:0] wi1;
wire signed [7:0] wq1;

//-----    REGS         ------------------------------------------------------------------
reg r_ovalid;
reg [7:0] r_odata;
reg signed [7:0] ps[ALEN];
reg [7:0] index = 0;

/*
reg signed [10:0] pi0;
reg signed [10:0] pq0;

reg signed [10:0] pi1;
reg signed [10:0] pq1;
*/
reg signed [1:0] bi0;
reg signed [1:0] bq0;
reg signed [1:0] bi1;
reg signed [1:0] bq1;

reg [7:0] counter;

reg signed [31:0] num[4];
reg signed [31:0] denom[4];
wire signed [31:0] result[4];

//========================================================================================
//    		MODULE CONTENT		
//========================================================================================
typedef enum {s_RECEIVING, s_QAM, s_QAMW} qam_state;
qam_state 					           state          = s_RECEIVING;

//-----------------------------------------------------------------------------
//-----		MODULE CONTENT		-------------------------------------------------
//-----------------------------------------------------------------------------

/*
lpmdiv div0 (
	.aclr(i_rst),
	.clock(i_clk),
	.denom(denom[0]),
	.numer(num[0]),
	.quotient(result[0])
	);
	
lpmdiv div1 (
	.aclr(i_rst),
	.clock(i_clk),
	.denom(denom[1]),
	.numer(num[1]),
	.quotient(result[1])
	);
	
lpmdiv div2 (
	.aclr(i_rst),
	.clock(i_clk),
	.denom(denom[2]),
	.numer(num[2]),
	.quotient(result[2])
	);
	
lpmdiv div3 (
	.aclr(i_rst),
	.clock(i_clk),
	.denom(denom[3]),
	.numer(num[3]),
	.quotient(result[3])
	);
	
*/

always @(posedge i_clk) begin
	if (i_rst) begin
		state <= s_RECEIVING;
		index <= 0;
		r_ovalid <= 1'b0;
		
	end else begin
	
		r_ovalid <= 1'b0;
		case (state)
			s_RECEIVING: begin
				r_ovalid <= 1'b0;
				if (i_enb) begin
					ps[index] <= i_data;
					if (index == ALEN - 1) begin
						index <= 0;
						state <= s_QAM;
					end else
						index <= index + 1'b1;
				end
			end
			
			s_QAM: begin
			
			/*
				r_ovalid <= 1'b0;
				
				
				pi0 = wi0 + 10'sd170;
				pq0 = wq0 + 10'sd170;
				
				num[0] <= pi0;
				denom[0] <= 32'd84;
				
				num[1] <= pq0;
				denom[1] <= 32'd84;
				
				pi1 = wi1 + 10'sd170;
				pq1 = wq1 + 10'sd170;
				
				num[2] <= pi1;
				denom[2] <= 32'd84;
				
				num[3] <= pq1;
				denom[3] <= 32'd84;
				
				state <= s_QAMW;
				counter <= 0;
			end
			
			s_QAMW: begin
				if (counter == 11) begin
					r_ovalid <= 1'b1;
					r_odata <= {result[2][1:0], ~(result[3][1:0]), result[0][1:0], ~(result[1][1:0])};
					
					if (index == ALEN - 4) begin
						state <= s_RECEIVING;
						index <= 0;
					end else begin
						index <= index + 4;
						state <= s_QAM;
					end
				end else begin
					counter = counter + 1;
				end
				*/
				
				if (wq0 < -84)
					bq0 = 2'b11;
				else if (wq0 < 0)
					bq0 = 2'b10;
				else if (wq0 < 85)
					bq0 = 2'b01;
				else
					bq0 = 2'b00;
					
				if (wi0 < -84)
					bi0 = 2'b00;
				else if (wi0 < 0)
					bi0 = 2'b01;
				else if (wi0 < 85)
					bi0 = 2'b10;
				else
					bi0 = 2'b11;
					
				if (wq1 < -84)
					bq1 = 2'b11;
				else if (wq1 < 0)
					bq1 = 2'b10;
				else if (wq1 < 85)
					bq1 = 2'b01;
				else
					bq1 = 2'b00;
					
				if (wi1 < -84)
					bi1 = 2'b00;
				else if (wi1 < 0)
					bi1 = 2'b01;
				else if (wi1 < 85)
					bi1 = 2'b10;
				else
					bi1 = 2'b11;
				
				r_ovalid <= 1'b1;
				r_odata <= {bi1, bq1, bi0, bq0};
				
				if (index == ALEN - 4) begin
					state <= s_RECEIVING;
					index <= 0;
				end else begin
					index <= index + 4;
					state <= s_QAM;
				end
			end
		endcase
		
	end
end
	
	assign wi0 = ps[index];
	assign wq0 = ps[index + 1];
	assign wi1 = ps[index + 2];
	assign wq1 = ps[index + 3];
	assign o_data = r_odata;
	assign o_valid = r_ovalid;
	
endmodule
