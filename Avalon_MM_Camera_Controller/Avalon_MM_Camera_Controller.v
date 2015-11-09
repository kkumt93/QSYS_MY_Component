/*memory map*/
/*----------------------------------------
0~639 		line buffer1
640~1279	line buffer2
1280		ControlReg
1281		StatusReg




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
  input wire [7:0]  CamData,
  output wire       XCLK,
  output wire       SCL,
  output wire       SDA
  );

  wire [15:0] ControlReg;
  wire [15:0] StatusReg;
  reg [15:0] Mem [2047:0];


  //Avalon bus write
  always @(negedge clk) begin
    if (write) begin
      Mem[address] <= writedata;
    end
  end

  //Avalon bus read
  always @(posedge clk) begin
    if (read) begin
       readdata <= Mem[address];
    end
  end

  assign ControlReg = Mem[1280];
  assign StatusReg  = Mem[1281];

endmodule
