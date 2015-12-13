/*memory map*/
/*----------------------------------------
1~640 		line buffer1
641~1280	line buffer2
1281		ControlReg 0...1フレーム取得命令
1282		StatusReg
1283        FilterSelect 0...raw data
                         1...gray data
                         2...binary data
1284        Threshold
1285        h Threshold
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

  wire          CamData_enable;
  wire [10:0] 	CamPix_count;
  reg  [15:0] 	StatusReg;
  wire [23:0]   ConvertedData;
  wire [15:0]   CamData_out;
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
  wire [7:0] 	CamData_h;
  wire [23:0]	CamData_binary;
  wire [23:0]   CamData_h_binary;
  reg 			clk_25;
  reg  [23:0] 	Mem [1299:0];
  wire [9:0]    CamHsync_count;
  reg           Capture_flag;
  wire 			Cam_enable;

  //25mhz generate
  always @(negedge clk_50) begin
  	clk_25 <= ~clk_25;
  end

  //Avalon bus write
  always @(posedge clk) begin
    if (write) begin
        Mem[address] <= writedata[23:0];
    end else begin
      if((CamHsync_count[0] == 0) && (Cam_enable == 1)) begin
        Mem[(CamPix_count>>1)] <= ConvertedData;
      end else if((CamHsync_count[0] == 1) && (Cam_enable == 1)) begin
        Mem[(CamPix_count>>1)+640] <= ConvertedData;
      end
    end
  end

  //Avalon bus read
  always @(posedge clk) begin
    if (read) begin
      if(address == 1282) begin
        readdata <= {16'h0000,StatusReg};
      end else begin
        readdata <= {Mem[address],8'h00};
      end
    end
  end

  //Capture_flag
  always @(posedge CamVsync) begin
    if(Mem[1281] == 1) begin
    	Capture_flag <= 1;
    end else begin
    	Capture_flag <= 0;
    end
  end

  always @(posedge clk) begin
    StatusReg <= { 5'b00000, Capture_flag, CamHsync_count};
  end

  assign XCLK = clk_25;
  assign Cam_enable = CamData_enable & Capture_flag;


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
  assign CamData_binary = (Mem[1284] <= CamData_gray[7:3]) ? 24'hffffff : 24'h000000;
  //HSV
  assign max = ((CamData_r >= CamData_g) && (CamData_r >= CamData_b)) ? CamData_r :
               ((CamData_g >= CamData_r) && (CamData_g >= CamData_b)) ? CamData_g :
               ((CamData_b >= CamData_r) && (CamData_b >= CamData_g)) ? CamData_b : 0;

  assign min = ((CamData_r <= CamData_g) && (CamData_r <= CamData_b)) ? CamData_r :
               ((CamData_g <= CamData_r) && (CamData_g <= CamData_b)) ? CamData_g :
               ((CamData_b <= CamData_r) && (CamData_b <= CamData_g)) ? CamData_b : 0;

  assign dif_gb = (CamData_g >= CamData_b) ? CamData_g - CamData_b : 255 + CamData_g - CamData_b;
  assign dif_br = (CamData_b >= CamData_r) ? CamData_b - CamData_r : 255 + CamData_b - CamData_r;
  assign dif_rg = (CamData_r >= CamData_g) ? CamData_r - CamData_g : 255 + CamData_r - CamData_g;

  assign CamData_h = (max == CamData_r) ? (dif_gb*43) / (max - min)       :
                     (max == CamData_g) ? (dif_br*43) / (max - min) + 85  :
                     (max == CamData_b) ? (dif_rg*43) / (max - min) + 170 : 0;

  assign CamData_h_binary = ((Mem[1285] <= CamData_h) && (Mem[1286] >= CamData_h)) ? 24'hffffff : 24'h000000;

  //Converted Data
  assign ConvertedData = (Mem[1283] == 0) ? {CamData_r,CamData_g,CamData_b} 		 :
                         (Mem[1283] == 1) ? {CamData_gray,CamData_gray,CamData_gray} :
                         (Mem[1283] == 2) ? CamData_binary                           :
                         (Mem[1283] == 3) ? CamData_h_binary                         : {CamData_r,CamData_g,CamData_b};

  Camera_Controller Camera_Controller_inst(
    .reset(reset),
    .PCLK(PCLK),
    .CamHsync(CamHsync),
    .CamVsync(CamVsync),
    .CamData_in(CamData_in),
    .CamData_out(CamData_out),
    .CamHsync_count(CamHsync_count),
    .CamPix_count(CamPix_count),
    .CamData_enable(CamData_enable)
  );

endmodule
