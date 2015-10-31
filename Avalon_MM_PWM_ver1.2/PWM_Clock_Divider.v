module PWM_Clock_Divider(
	input 			clock_in,
	input 			reset,
	input  [7:0] 	division_value,
	output			clock_out
	);
	
	reg [7:0] counter;
	reg divided_clock;

	always @(posedge clock_in or posedge reset) begin
		if(reset) begin
			counter <= 0;
		end else begin
			counter <= counter + 1;
		end
	end

	always @(posedge clock_in) begin
		case (division_value)
			1 : divided_clock <= counter[0];
			2 : divided_clock <= counter[1];
			3 : divided_clock <= counter[2];
			4 : divided_clock <= counter[3];
			5 : divided_clock <= counter[4];
			6 : divided_clock <= counter[5];
			7 : divided_clock <= counter[6];
			8 : divided_clock <= counter[7];
			default : divided_clock <= counter[0];
		endcase
	end

	assign clock_out = (division_value == 0) ? clock_in : divided_clock;

endmodule
