
module median_1x9(
	input wire 			clk,
	input wire          reset,
	input wire       	Cam_enable_in,
	output wire         Cam_enable_out,
	input wire  [9:0]  	CamHsync_count_in,
	output wire [9:0]	CamHsync_count_out,
	input wire  [10:0] 	CamPix_count_in,
	output wire [10:0] 	CamPix_count_out,
	input wire 	[15:0]	data_in,
	output wire	[15:0]	data_out
	);

	reg  [8:0]   Cam_enable_delay;
	reg  [8:0] 	 data_delay; 
	reg  [89:0]  CamHsync_count_delay;
	reg  [98:0]  CamPix_count_delay;

	always @(negedge clk or posedge reset) begin
		if (reset ==1) begin
			Cam_enable_delay <= 0;
		end	else begin
			Cam_enable_delay <= {Cam_enable_in,Cam_enable_delay[8:1]};
		end
	end

	always @(negedge clk or posedge reset) begin
		if (reset == 1) begin
			CamHsync_count_delay <= 0;
		end	else begin
			CamHsync_count_delay <= {CamHsync_count_in,CamHsync_count_delay[89:10]};
		end
	end

	always @(negedge clk or posedge reset) begin
		if (reset ==1) begin
			CamPix_count_delay <= 0;
		end else begin
			CamPix_count_delay <= {CamPix_count_in,CamPix_count_delay[98:11]};			
		end
	end

	always @(negedge clk or posedge reset) begin
		if (reset == 1) begin
			data_delay <= 0;
		end else begin
			data_delay <= {data_in[15],data_delay[8:1]};
		end 
	end

	//median
	assign data_out = (data_delay[8]+data_delay[7]+data_delay[6]+data_delay[5]+data_delay[4]+data_delay[3]+data_delay[2]+data_delay[1]+data_delay[0] == 9) ? 16'hffff : 16'h0000;

	assign Cam_enable_out = Cam_enable_delay[0];
	assign CamHsync_count_out = CamHsync_count_delay[9:0];
	assign CamPix_count_out = CamPix_count_delay[10:0];

endmodule