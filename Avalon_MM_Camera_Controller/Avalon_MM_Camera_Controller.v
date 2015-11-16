/*memory map*/
/*----------------------------------------
0~639 		line buffer1
640~1279	line buffer2
1280		ControlReg 0...1フレーム取得命令
1281		StatusReg
Camera IP完成まで[■■■■■　　　　　　　　　　　　　　　]25%
------------------------------------------*/
module Avalon_MM_Camera_Controller(
  input wire        reset,
  input wire        clk,
  input wire [10:0] address,
  input wire        read,
  output reg [15:0] readdata,
  input wire        write,
  input wire [15:0] writedata,
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
  reg  [15:0] 	ControlReg;
  wire [15:0] 	StatusReg;
  wire [15:0]   CamData_out;
  reg 			    clk_25=1;
  reg  [15:0] 	Mem [2047:0];
  wire [8:0]    CamHsync_count;
  reg           Capture_flag;

  //test clk
  always @(negedge clk) begin
  	clk_25 <= ~clk_25;
  end

  //Avalon bus write
  always @(posedge clk) begin
    if (write) begin
        Mem[address] <= writedata;
    end else begin
      if (CamHsync_count == 501) begin
        Mem[1280] <= 0;
      end
      if((CamHsync_count[0] == 0) && (CamData_enable == 1) && (Capture_flag == 1)) begin
        Mem[(CamPix_count>>1)-1] <= CamData_out;
      end else if((CamHsync_count[0] == 1) && (CamData_enable == 1) && (Capture_flag == 1)) begin
        Mem[(CamPix_count>>1)+639] <= CamData_out;
      end
    end
  end

  //Avalon bus read
  always @(posedge clk) begin
    if (read) begin
      if(address == 1280) begin
        readdata <= ControlReg;
      end else if(address == 1281) begin
        readdata <= StatusReg;
      end else begin
        readdata <= Mem[address];
      end
    end
  end

  //ControlReg


  //Capture_flag
  always @(negedge CamVsync) begin
    ControlReg <= Mem[1280];
    if(ControlReg == 1) begin
    	Capture_flag <= 1;
      ControlReg <= 0;
    end else begin
    	Capture_flag <= 0;
    end
  end

  assign StatusReg = { 5'b00000, Capture_flag, (CamHsync_count - 1)};
  assign XCLK = clk_25;

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
