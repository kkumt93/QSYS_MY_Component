
module Camera_Controller(
	input 				reset,
	input 				PCLK,
	input 				CamHsync,
	input 				CamVsync,
	input  		[7:0]	CamData_in,
	output reg 	[9:0] 	CamHsync_count,
	output reg 	[10:0] 	CamPix_count,
	output reg	[15:0]	CamData_out,
	output reg 			CamData_enable
	);


	always @(posedge PCLK or posedge reset) begin
		if(reset == 1) begin
			CamPix_count <= 0;
		end else if(CamHsync == 0) begin
			CamPix_count <= 0;
		end else if(CamPix_count == 1568) begin
			CamPix_count <= 0;
		end else begin
			CamPix_count <= CamPix_count + 1;
		end
	end

	//CamData convert 8bit to 16 bit 
	always @(posedge PCLK) begin
		if(CamPix_count[0] == 1) begin
			CamData_out[15:8] <= CamData_in;
		end else if(CamPix_count[0] == 0) begin
			CamData_out[7:0] <= CamData_in;
		end
	end

	//error
	always @(negedge CamHsync or posedge CamVsync) begin
		if(CamVsync == 1) begin
			CamHsync_count <= 0;
		end else begin
			CamHsync_count <= CamHsync_count + 1;
		end
	end

	//data enable signal
	always @(posedge PCLK) begin
		if(CamPix_count[1:0] == 2'b11) begin
			CamData_enable <= 1;
		end else if(CamPix_count[1:0] == 2'b01) begin
			CamData_enable <= 1;
		end else begin
			CamData_enable <= 0;
		end
	end

endmodule
