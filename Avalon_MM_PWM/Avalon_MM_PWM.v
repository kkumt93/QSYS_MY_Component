`default_nettype none
module Avalon_MM_PWM(
  input wire        reset,
  input wire        clk,
  input wire [2:0]  address,
  input wire        read,
  output reg [15:0] readdata,
  input wire        write,
  input wire [15:0] writedata,
  output wire       export1,
  output wire       export2,
  output wire       export3,
  output wire       export4
  );

  reg [15:0] period1;
  reg [15:0] period2;
  reg [15:0] period3;
  reg [15:0] period4;
  reg [15:0] comparison_value1;
  reg [15:0] comparison_value2;
  reg [15:0] comparison_value3;
  reg [15:0] comparison_value4;


  //Avalon bus write
  always@(posedge clk,posedge reset) begin
  	if(reset) begin
  		period1 <= 16'hffff;
  		period2 <= 16'hffff;
  		period3 <= 16'hffff;
  		period4 <= 16'hffff;
  		comparison_value1 <= 16'h0;
  		comparison_value2 <= 16'h0;
  		comparison_value3 <= 16'h0;
  		comparison_value4 <= 16'h0;
	end else begin
		if(write) begin
        	case (address)
          		3'b000	:
          			comparison_value1 <= writedata;
          		3'b001	:
          		 	comparison_value2 <= writedata;
          		3'b010 	:
          		 	comparison_value3 <= writedata;
          		3'b011 	:
          			comparison_value4 <= writedata;
          		3'b100 	:
          			period1 <= writedata;
          		3'b101  :
          			period2 <= writedata;
          		3'b110  :
          			period3 <= writedata;
          		3'b111  :
          			period4 <= writedata;
        	endcase
      	end
    end
  end

  //Avalon bus read
  always @* begin
    readdata <= 16'h0;
  end

  PWM_Controller PWM_Controller_inst1(
    .clock(clk),
    .reset(reset),
    .comparison_value(comparison_value1),
    .period(period1),
    .pwm_out(export1)
  );

  PWM_Controller PWM_Controller_inst2(
    .clock(clk),
    .reset(reset),
    .comparison_value(comparison_value2),
    .period(period2),
    .pwm_out(export2)
  );

  PWM_Controller PWM_Controller_inst3(
    .clock(clk),
    .reset(reset),
    .comparison_value(comparison_value3),
    .period(period3),
    .pwm_out(export3)
  );

  PWM_Controller PWM_Controller_inst4(
    .clock(clk),
    .reset(reset),
    .comparison_value(comparison_value4),
    .period(period4),
    .pwm_out(export4)
  );

  
endmodule
