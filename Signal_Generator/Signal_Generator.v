module Signal_Generator(
  input         clk,
  input         reset,
  output        avalonst_source_valid,
  output [31:0] avalonst_source_data,
  input         avalonst_source_ready
  );

  parameter start_value = 0;
  parameter end_value = 255;
  
  reg           out_valid;
  reg	[31:0]	out_data;
  

  //AvalonST out
  always @(posedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      out_valid <= 1'b0;
      out_data  <= start_value;
    end else if(out_data == end_value) begin
    	out_data  <= start_value;
    end else if (avalonst_source_ready == 1'b1) begin 
      out_valid <= 1'b1;
      out_data  <= out_data + 1; 
    end
  end
  
  assign avalonst_source_valid = out_valid;
  assign avalonst_source_data  = out_data;

endmodule