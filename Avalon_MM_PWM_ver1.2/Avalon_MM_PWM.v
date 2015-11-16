/*memory map*/
/*----------------------------------------
0     period1
1     period2
2     period3
3     period4
4     comparison_value1
5     comparison_value2
6     comparison_value3
7     comparison_value4
8     division_clock
------------------------------------------*/
module Avalon_MM_PWM(
  input wire        reset,
  input wire        clk,
  input wire [3:0]  address,
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
  reg [7:0]	 division_value;

  wire division_clock;


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
  		division_value <= 7'h0;
	end else begin
		if(write) begin
        	case (address)
          		4'b0000	:
          			period1 <= writedata;
          		4'b0001 :
          			period2 <= writedata;
          		4'b0010 :
          		 	period3 <= writedata;
          		4'b0011 :
          			period4 <= writedata;
          		4'b0100 :
          			comparison_value1 <= writedata;
          		4'b0101 :
          			comparison_value2 <= writedata;
          		4'b0110 :
          			comparison_value3 <= writedata;
          		4'b0111 :
          			comparison_value4 <= writedata;
          		4'b1000 :
          			division_value <= writedata[7:0];
        	endcase
      	end
    end
  end

  //Avalon bus read
  always@(posedge clk) begin
	if(read) begin
       	case (address)
       		4'b0000	:
       			readdata <= period1;
       		4'b0001 :
       			readdata <= period2;
       		4'b0010 :
      		 	readdata <= period3;
       		4'b0011 :
       			readdata <= period4;
       		4'b0100 :
       			readdata <= comparison_value1;
       		4'b0101 :
       			readdata <= comparison_value2;
       		4'b0110 :
       			readdata <= comparison_value3;
       		4'b0111 :
       			readdata <= comparison_value4;
       		4'b1000 :
       			readdata <= division_value;
      	endcase
    end
  end

  PWM_Clock_Divider PWM_Clock_Divider_inst(
	.clock_in(clk),
	.reset(reset),
	.division_value(division_value),
	.clock_out(division_clock)
	);

  PWM_Controller PWM_Controller_inst1(
    .clock(division_clock),
    .reset(reset),
    .comparison_value(comparison_value1),
    .period(period1),
    .pwm_out(export1)
  );

  PWM_Controller PWM_Controller_inst2(
    .clock(division_clock),
    .reset(reset),
    .comparison_value(comparison_value2),
    .period(period2),
    .pwm_out(export2)
  );

  PWM_Controller PWM_Controller_inst3(
    .clock(division_clock),
    .reset(reset),
    .comparison_value(comparison_value3),
    .period(period3),
    .pwm_out(export3)
  );

  PWM_Controller PWM_Controller_inst4(
    .clock(division_clock),
    .reset(reset),
    .comparison_value(comparison_value4),
    .period(period4),
    .pwm_out(export4)
  );

  
endmodule
