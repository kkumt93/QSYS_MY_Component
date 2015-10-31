module PWM_Clock_Divider(
	input 			clock_in,
	input 			reset,
	input  [7:0] 	division_value,
	output 			clock_out
	);
	
	reg [7:0] counter;

	always @(posedge clock_in or posedge reset) begin
		if(reset) begin
			counter <= 0;
		end else if(counter == division_value * 2 + 1) begin
			counter <= 0;
		end else begin
			counter <= counter + 1;
		end
	end
	
	assign clock_out = (division_value == 0) ? clock_in : ((counter <= division_value) ? 1 : 0);

endmodule
