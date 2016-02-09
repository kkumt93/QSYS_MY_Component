/*memory map*/
/*----------------------------------------
1~640 		line buffer1
641~1280	line buffer2
1281		ControlReg 0...1 flame get
1282		StatusReg
1283        FilterSelect 0...raw data
                         1...gray data
                         2...binary data
1284        Threshold
1285        HSV Threshold 0~255
1286        HSV Threshold range 1~255
1287		Frame Number 0~7
------------------------------------------*/
module Avalon_MM_Camera_Controller(
  input wire        reset,
  input wire        clk,
  input wire 		clk_50,
  input wire [10:0] address,
  input wire        read,
  output reg [31:0] readdata,
  input wire        write,
  input wire [31:0] writedata,
  input wire        PCLK,
  input wire        CamHsync,
  input wire        CamVsync,
  input wire [7:0]  CamData_in,
  output wire       XCLK,
  output wire       SCL,
  output wire       SDA
  );

  wire [15:0]   ConvertedData;
  wire [15:0]   CamData_out;
  wire [31:0]   CamData_32bit;

  //filter wire
  wire [7:0]    CamData_r;
  wire [7:0]    CamData_g;
  wire [7:0]    CamData_b;
  wire [7:0]    CamData_r2;
  wire [7:0]    CamData_g2;
  wire [7:0]    CamData_b2;
  wire [7:0]    CamData_gray;
  wire [7:0] 	max;
  wire [7:0] 	min;
  wire [7:0] 	dif_gb;
  wire [7:0] 	dif_br;
  wire [7:0] 	dif_rg;
  wire [7:0]    s;
  wire [7:0]    v;
  wire [7:0] 	CamData_h;
  wire [15:0]	CamData_binary;
  wire [15:0]   CamData_h_binary;
  wire [15:0]   CamData_h_binary_median;
  wire [15:0]   HSV_Threshold_low;
  wire [15:0]   HSV_Threshold_high;
  wire [15:0]   MovingAverage_wire;

  reg 			clk_25;
  //Camera IP reg
  reg  [15:0]   ControlReg;   
  reg  [15:0] 	StatusReg;
  reg  [15:0]   FilterSelect;
  reg  [15:0]   Threshold;
  reg  [15:0]   HSV_Threshold;
  reg  [15:0]   HSV_Threshold_range;
  reg  [7:0]    HSV_Threshold_S_low;
  reg  [7:0]    HSV_Threshold_S_high;
  reg  [7:0]    HSV_Threshold_V_low;
  reg  [7:0]    HSV_Threshold_V_high;
  reg  [15:0]   FrameNumber;
  reg  [15:0] 	Mem [1281:0];
  reg  [15:0]   Threshold_counter1;
  reg  [15:0]   Threshold_counter2;
  reg  [319:0]  MovingAverage;
  reg  [15:0]   Threshold_counter [639:0];
  //CamData store wire
  wire [9:0]    CamHsync_count;
  wire [9:0]    CamHsync_count_out;
  wire [9:0]    CamHsync_count_out_delay;
  wire [10:0]   CamPix_count;
  wire [10:0]   CamPix_count_out;
  wire [10:0]   CamPix_count_out_delay;
  wire          CamData_enable;
  wire          CamData_enable_out;
  wire          CamData_enable_out_delay;
  wire [15:0]   Mem_wire;
  wire          Cam_enable;

  //25mhz generate
  always @(negedge clk_50) begin
  	clk_25 <= ~clk_25;
  end
  assign XCLK = clk_25;

  //Avalon bus write
  always @(posedge clk) begin
    if (write) begin
    	if(address == 1281) begin
    		ControlReg <= writedata[15:0];
    	end else if(address == 1283) begin
    		FilterSelect <= writedata[15:0];
    	end else if(address == 1284) begin
    		Threshold <= writedata[15:0];
    	end else if(address == 1285) begin
    		HSV_Threshold <= writedata[15:0];
    	end else if(address == 1286) begin
    		HSV_Threshold_range <= writedata[15:0];
    	end else if(address == 1287) begin
    		FrameNumber <= writedata[15:0];
    	end else if(address == 1288) begin
    		HSV_Threshold_S_low <= writedata[7:0];
    	end else if(address == 1289) begin
    		HSV_Threshold_S_high <= writedata[7:0];
    	end else if(address == 1290) begin
        HSV_Threshold_V_low <= writedata[7:0];
      end else if(address == 1291) begin
        HSV_Threshold_V_high <= writedata[7:0];
      end
    end
  end

  //Avalon bus read
  always @* begin
    if (read) begin
      if(address == 639) begin
      	readdata <= {16'h0,MovingAverage_wire};
      end else if(address == 1279) begin
      	readdata <= {16'h0,MovingAverage_wire};
      end else if(address == 1282) begin
        readdata <= {16'h0000,StatusReg};
      end else if(address == 1284) begin
      	readdata <= {16'h0000,Threshold};
      end else if(address == 1287) begin
       	readdata <= {16'h0000,FrameNumber};
      end else if(CamHsync_count == 480) begin
      	readdata <= {16'h0000,Threshold_counter[address]};
      end else begin
        readdata <= CamData_32bit;
      end
    end
  end
  assign Mem_wire = Mem[address];
  assign CamData_32bit = (Mem_wire == 16'hffff) ? 32'h00ffffff : 
                         ((Mem_wire == 16'h0000) ? 32'h00000000 : {8'h00,Mem_wire[15:11],3'b000,Mem_wire[10:5],2'b00,Mem_wire[4:0],3'b000});

  //Camera data store
  always @(negedge clk) begin
    if((CamHsync_count[0] == 0) && (Cam_enable == 1)) begin
		Mem[(CamPix_count>>1)] <= ConvertedData;
	end else if((CamHsync_count[0] == 1) && (Cam_enable == 1)) begin
		Mem[(CamPix_count>>1)+640] <= ConvertedData;
  	end
  end

  //Camera timing signal 
  assign CamHsync_count = (FilterSelect == 4) ? CamHsync_count_out_delay : CamHsync_count_out; 
  assign CamPix_count   = (FilterSelect == 4) ? CamPix_count_out_delay   : CamPix_count_out;
  assign CamData_enable = (FilterSelect == 4) ? CamData_enable_out_delay : CamData_enable_out;
  assign Cam_enable     = CamData_enable & ControlReg[0];

  //Threshold_counter
  always @(posedge clk) begin
  	if(CamHsync_count == 1) begin
  		MovingAverage <= 0;
  	end else if((CamHsync_count[0] == 0) && ((CamPix_count>>1) == 1)) begin
  		Threshold_counter1 <= 0;
  	end else if((CamHsync_count[0] == 0) && ((CamPix_count>>1) == 639)) begin
  		MovingAverage <= {Threshold_counter1,MovingAverage[319:16]};
  	end else if((CamHsync_count[0] == 0) && (Cam_enable == 1)) begin
  		if(ConvertedData == 16'hffff) begin
			Threshold_counter1 <= Threshold_counter1 + 1;
		end
  	end else if((CamHsync_count[0] == 1) && ((CamPix_count>>1) == 1)) begin
  		Threshold_counter2 <= 0;
  	end else if((CamHsync_count[0] == 1) && ((CamPix_count>>1) == 639)) begin
  		MovingAverage <= {Threshold_counter2,MovingAverage[319:16]};
  	end else if((CamHsync_count[0] == 1) && (Cam_enable == 1)) begin
  		if(ConvertedData == 16'hffff) begin
			Threshold_counter2 <= Threshold_counter2 + 1;
		end
  	end
  end
  assign MovingAverage_wire = (MovingAverage[319:304] + MovingAverage[303:288] + MovingAverage[287:272] + MovingAverage[271:256] + MovingAverage[255:240] +
                               MovingAverage[239:224] + MovingAverage[223:208] + MovingAverage[207:192] + MovingAverage[191:176] + MovingAverage[175:160] +
                               MovingAverage[159:144] + MovingAverage[143:128] + MovingAverage[127:112] + MovingAverage[111:96] + MovingAverage[95:80] +
                               MovingAverage[79:64] + MovingAverage[63:48] + MovingAverage[47:32] + MovingAverage[31:16] + MovingAverage[15:0]) / 20;

  always @(posedge clk) begin
  	if((CamHsync_count == 1) && (Cam_enable == 1))begin
  		Threshold_counter[(CamPix_count>>1)] <= 0;  		
  	end else if(Cam_enable == 1) begin
  		if(ConvertedData == 16'hffff) begin
  			Threshold_counter[(CamPix_count>>1)] <= Threshold_counter[(CamPix_count>>1)] + 1;
  		end
  	end
  end

  /*Threshold_counter2
  always @(posedge clk) begin
  	if((CamHsync_count[0] == 1) && ((CamPix_count>>1) == 1)) begin
  		Threshold_counter2 <= 0;
  	end else if((CamHsync_count[0] == 1) && (Cam_enable == 1)) begin
  		if(ConvertedData == 16'hffff) begin
			Threshold_counter2 <= Threshold_counter2 + 1;
		end
  	end
  end
  */
  //StatusReg
  always @(posedge clk) begin
    StatusReg <= { 5'b00000, ControlReg[0], CamHsync_count};
  end

  //CamData Convert
  //RGB 
  assign CamData_r = {CamData_out[15:11],3'b000};
  assign CamData_g = {CamData_out[10:5],2'b00};
  assign CamData_b = {CamData_out[4:0],3'b000};
  //Gray
  assign CamData_r2 = (77*CamData_r)>>8;
  assign CamData_g2 = (150*CamData_g)>>8;
  assign CamData_b2 = (29*CamData_b)>>8;

  assign CamData_gray = CamData_r2 + CamData_g2 + CamData_b2;
  //Binary
  assign CamData_binary = (Threshold <= CamData_gray[7:3]) ? 16'hffff : 16'h0000;
  //HSV
  assign max = ((CamData_r >= CamData_g) && (CamData_r >= CamData_b)) ? CamData_r :
               ((CamData_g >= CamData_r) && (CamData_g >= CamData_b)) ? CamData_g :
               ((CamData_b >= CamData_r) && (CamData_b >= CamData_g)) ? CamData_b : 0;

  assign min = ((CamData_r <= CamData_g) && (CamData_r <= CamData_b)) ? CamData_r :
               ((CamData_g <= CamData_r) && (CamData_g <= CamData_b)) ? CamData_g :
               ((CamData_b <= CamData_r) && (CamData_b <= CamData_g)) ? CamData_b : 0;

  assign dif_gb = (CamData_g >= CamData_b) ? CamData_g - CamData_b : CamData_b - CamData_g;
  assign dif_br = (CamData_b >= CamData_r) ? CamData_b - CamData_r : CamData_r - CamData_b;
  assign dif_rg = (CamData_r >= CamData_g) ? CamData_r - CamData_g : CamData_g - CamData_r;

  assign CamData_h = ((max == CamData_r) && (CamData_g >= CamData_b)) ? (dif_gb*43) / (max - min)       :
  					 ((max == CamData_r) && (CamData_b >= CamData_g)) ? 255 - (dif_gb*43) / (max - min) :
                     ((max == CamData_g) && (CamData_b >= CamData_r)) ? (dif_br*43) / (max - min) + 85  :
                     ((max == CamData_g) && (CamData_r >= CamData_b)) ? 85 - (dif_br*43) / (max - min)  :
                     ((max == CamData_b) && (CamData_r >= CamData_g)) ? (dif_rg*43) / (max - min) + 170 :
                     ((max == CamData_b) && (CamData_g >= CamData_r)) ? 170 - (dif_rg*43) / (max - min) : 0;

  assign s = max-min;
  assign v = max;
  assign HSV_Threshold_low  = HSV_Threshold - HSV_Threshold_range;
  assign HSV_Threshold_high = HSV_Threshold + HSV_Threshold_range;

  assign CamData_h_binary = (HSV_Threshold > HSV_Threshold_range) ?
  			 ((HSV_Threshold_low <= CamData_h && CamData_h <= HSV_Threshold_high && HSV_Threshold_S_low <= s && s <= HSV_Threshold_S_high && HSV_Threshold_V_low <= v && v <= HSV_Threshold_V_high) ? 16'hffff : 16'h0000 ) :
  			 ((((255 - HSV_Threshold_range <= CamData_h) || (CamData_h <= HSV_Threshold_range - HSV_Threshold)) && HSV_Threshold_S_low <= s && s <= HSV_Threshold_S_high && HSV_Threshold_V_low <= v && v <= HSV_Threshold_V_high) ? 16'hffff : 16'h0000);

  //Converted Data
  assign ConvertedData = (FilterSelect == 0) ? CamData_out                                                  :
                         (FilterSelect == 1) ? {CamData_gray[7:3],CamData_gray[7:3],1'b1,CamData_gray[7:3]} :
                         (FilterSelect == 2) ? CamData_binary                                               :
                         (FilterSelect == 3) ? CamData_h_binary                                             :
                         (FilterSelect == 4) ? CamData_h_binary_median                                      : CamData_out;

  Camera_Controller Camera_Controller_inst(
    .reset(reset),
    .PCLK(PCLK),
    .CamHsync(CamHsync),
    .CamVsync(CamVsync),
    .CamData_in(CamData_in),
    .CamData_out(CamData_out),
    .CamHsync_count(CamHsync_count_out),
    .CamPix_count(CamPix_count_out),
    .CamData_enable(CamData_enable_out)
  );


  median_1x15 median_1x15_inst(
    .clk(PCLK),
    .reset(reset),
    .Cam_enable_in(CamData_enable_out),
    .Cam_enable_out(CamData_enable_out_delay),
    .CamHsync_count_in(CamHsync_count_out),
    .CamHsync_count_out(CamHsync_count_out_delay),
    .CamPix_count_in(CamPix_count_out),
    .CamPix_count_out(CamPix_count_out_delay),
    .data_in(CamData_h_binary),
    .data_out(CamData_h_binary_median)
  );

endmodule
