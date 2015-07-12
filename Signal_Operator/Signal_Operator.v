module Signal_Operator(
  input         clk,
  input         reset,
  input         avalonst_sink_valid,
  input  [31:0] avalonst_sink_data,
  output        avalon_sink_ready,
  output        avalonst_source_valid,
  output [31:0] avalonst_source_data,
  input         avalonst_source_ready
  );

  parameter addition = 0;
  parameter subtraction = 0;
  parameter multiplication = 1;
  parameter division = 1;


  reg              out_valid;
  reg     [ 31: 0] out_data;
  

  //AvalonST out
  always @(negedge clk or posedge reset) begin
    if (reset == 1'b1) begin
      out_valid <= 1'b0;
      out_data  <= 32'b0;
    end else if (avalonst_source_ready == 1'b1) begin 
      out_valid <= 1'b1;
      out_data  <= avalonst_sink_data * multiplication / division + addition - subtraction; 
    end
  end
  
  assign avalonst_source_valid = out_valid;
  assign avalonst_source_data  = out_data;
  assign avalon_sink_ready = avalonst_source_ready;

endmodule