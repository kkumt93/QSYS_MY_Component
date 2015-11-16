
module DE1_SoC_Board_7SEG(
  input wire reset,
  input wire clk,
  input wire[1:0] address,
  input wire read,
  output reg[31:0] readdata,
  input wire write,
  input wire [31:0] writedata,
  output wire[6:0] HEX0,
  output wire[6:0] HEX1,
  output wire[6:0] HEX2,
  output wire[6:0] HEX3,
  output wire[6:0] HEX4,
  output wire[6:0] HEX5
);

reg [7:0]HEX0_value;
reg [7:0]HEX1_value;
reg [7:0]HEX2_value;
reg [7:0]HEX3_value;
reg [7:0]HEX4_value;
reg [7:0]HEX5_value;

//Avalon bus write
//HEX0
always@(posedge clk,posedge reset) begin
	if (reset) begin
		HEX0_value <= 8'd0;
	end
	else begin
		if (write) begin
			case (writedata[3:0])
				4'h0		: HEX0_value <= 8'b11000000;
				4'h1		: HEX0_value <= 8'b11111001;
				4'h2		: HEX0_value <= 8'b10100100;
				4'h3		: HEX0_value <= 8'b10110000;
				4'h4		: HEX0_value <= 8'b10011001;
				4'h5		: HEX0_value <= 8'b10010010;
				4'h6		: HEX0_value <= 8'b10000010;
				4'h7		: HEX0_value <= 8'b11111000;
				4'h8		: HEX0_value <= 8'b10000000;
				4'h9		: HEX0_value <= 8'b10010000;
				4'ha		: HEX0_value <= 8'b10001000;
				4'hb		: HEX0_value <= 8'b10000011;
				4'hc		: HEX0_value <= 8'b10100111;
				4'hd		: HEX0_value <= 8'b10100001;
				4'he		: HEX0_value <= 8'b10000110;
				4'hf		: HEX0_value <= 8'b10001110;
				default  : HEX0_value <= 8'b00000000;
			endcase
		end
	end
end

//HEX1
always@(posedge clk,posedge reset) begin
	if (reset) begin
		HEX1_value <= 8'd0;
	end
	else begin
		if (write) begin
			case (writedata[7:4])
				4'h0		: HEX1_value <= 8'b11000000;
				4'h1		: HEX1_value <= 8'b11111001;
				4'h2		: HEX1_value <= 8'b10100100;
				4'h3		: HEX1_value <= 8'b10110000;
				4'h4		: HEX1_value <= 8'b10011001;
				4'h5		: HEX1_value <= 8'b10010010;
				4'h6		: HEX1_value <= 8'b10000010;
				4'h7		: HEX1_value <= 8'b11111000;
				4'h8		: HEX1_value <= 8'b10000000;
				4'h9		: HEX1_value <= 8'b10010000;
				4'ha		: HEX1_value <= 8'b10001000;
				4'hb		: HEX1_value <= 8'b10000011;
				4'hc		: HEX1_value <= 8'b10100111;
				4'hd		: HEX1_value <= 8'b10100001;
				4'he		: HEX1_value <= 8'b10000110;
				4'hf		: HEX1_value <= 8'b10001110;
				default  : HEX1_value <= 8'b00000000;
			endcase
		end
	end
end

//HEX2
always@(posedge clk,posedge reset) begin
	if (reset) begin
		HEX2_value <= 8'd0;
	end
	else begin
		if (write) begin
			case (writedata[11:8])
				4'h0		: HEX2_value <= 8'b11000000;
				4'h1		: HEX2_value <= 8'b11111001;
				4'h2		: HEX2_value <= 8'b10100100;
				4'h3		: HEX2_value <= 8'b10110000;
				4'h4		: HEX2_value <= 8'b10011001;
				4'h5		: HEX2_value <= 8'b10010010;
				4'h6		: HEX2_value <= 8'b10000010;
				4'h7		: HEX2_value <= 8'b11111000;
				4'h8		: HEX2_value <= 8'b10000000;
				4'h9		: HEX2_value <= 8'b10010000;
				4'ha		: HEX2_value <= 8'b10001000;
				4'hb		: HEX2_value <= 8'b10000011;
				4'hc		: HEX2_value <= 8'b10100111;
				4'hd		: HEX2_value <= 8'b10100001;
				4'he		: HEX2_value <= 8'b10000110;
				4'hf		: HEX2_value <= 8'b10001110;
				default  : HEX2_value <= 8'b00000000;
			endcase
		end
	end
end

//HEX3
always@(posedge clk,posedge reset) begin
	if (reset) begin
		HEX3_value <= 8'd0;
	end
	else begin
		if (write) begin
			case (writedata[15:12])
				4'h0		: HEX3_value <= 8'b11000000;
				4'h1		: HEX3_value <= 8'b11111001;
				4'h2		: HEX3_value <= 8'b10100100;
				4'h3		: HEX3_value <= 8'b10110000;
				4'h4		: HEX3_value <= 8'b10011001;
				4'h5		: HEX3_value <= 8'b10010010;
				4'h6		: HEX3_value <= 8'b10000010;
				4'h7		: HEX3_value <= 8'b11111000;
				4'h8		: HEX3_value <= 8'b10000000;
				4'h9		: HEX3_value <= 8'b10010000;
				4'ha		: HEX3_value <= 8'b10001000;
				4'hb		: HEX3_value <= 8'b10000011;
				4'hc		: HEX3_value <= 8'b10100111;
				4'hd		: HEX3_value <= 8'b10100001;
				4'he		: HEX3_value <= 8'b10000110;
				4'hf		: HEX3_value <= 8'b10001110;
				default  : HEX3_value <= 8'b00000000;
			endcase
		end
	end
end

//HEX4
always@(posedge clk,posedge reset) begin
	if (reset) begin
		HEX4_value <= 8'd0;
	end
	else begin
		if (write) begin
			case (writedata[19:16])
				4'h0		: HEX4_value <= 8'b11000000;
				4'h1		: HEX4_value <= 8'b11111001;
				4'h2		: HEX4_value <= 8'b10100100;
				4'h3		: HEX4_value <= 8'b10110000;
				4'h4		: HEX4_value <= 8'b10011001;
				4'h5		: HEX4_value <= 8'b10010010;
				4'h6		: HEX4_value <= 8'b10000010;
				4'h7		: HEX4_value <= 8'b11111000;
				4'h8		: HEX4_value <= 8'b10000000;
				4'h9		: HEX4_value <= 8'b10010000;
				4'ha		: HEX4_value <= 8'b10001000;
				4'hb		: HEX4_value <= 8'b10000011;
				4'hc		: HEX4_value <= 8'b10100111;
				4'hd		: HEX4_value <= 8'b10100001;
				4'he		: HEX4_value <= 8'b10000110;
				4'hf		: HEX4_value <= 8'b10001110;
				default  : HEX4_value <= 8'b00000000;
			endcase
		end
	end
end

//HEX5
always@(posedge clk,posedge reset) begin
	if (reset) begin
		HEX5_value <= 8'd0;
	end
	else begin
		if (write) begin
			case (writedata[23:20])
				4'h0		: HEX5_value <= 8'b11000000;
				4'h1		: HEX5_value <= 8'b11111001;
				4'h2		: HEX5_value <= 8'b10100100;
				4'h3		: HEX5_value <= 8'b10110000;
				4'h4		: HEX5_value <= 8'b10011001;
				4'h5		: HEX5_value <= 8'b10010010;
				4'h6		: HEX5_value <= 8'b10000010;
				4'h7		: HEX5_value <= 8'b11111000;
				4'h8		: HEX5_value <= 8'b10000000;
				4'h9		: HEX5_value <= 8'b10010000;
				4'ha		: HEX5_value <= 8'b10001000;
				4'hb		: HEX5_value <= 8'b10000011;
				4'hc		: HEX5_value <= 8'b10100111;
				4'hd		: HEX5_value <= 8'b10100001;
				4'he		: HEX5_value <= 8'b10000110;
				4'hf		: HEX5_value <= 8'b10001110;
				default  : HEX5_value <= 8'b00000000;
			endcase
		end
	end
end

//Avalon bus read
always @* begin
	readdata[31:24] = 0;
	readdata[23:0] <= writedata[23:0];
end

assign HEX0 = HEX0_value;
assign HEX1 = HEX1_value;
assign HEX2 = HEX2_value;
assign HEX3 = HEX3_value;
assign HEX4 = HEX4_value;
assign HEX5 = HEX5_value;

endmodule

      
    