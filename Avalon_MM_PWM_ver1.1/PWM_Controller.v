module PWM_Controller(
	input wire			clock,
	input wire			reset,
	input wire [15:0] 	comparison_value,
	input wire [15:0]	period,
	output wire			pwm_out
	); 

	reg [15:0]	counter;

	always @(posedge clock or posedge reset) begin
		if (reset == 1) begin
			counter <= 1;
		end else if(counter == period) begin
			counter <= 1;
		end else begin
			counter <= counter + 16'h0001;
		end
	end

	assign pwm_out = (counter <= comparison_value) ? 1'b1 : 1'b0;

endmodule
