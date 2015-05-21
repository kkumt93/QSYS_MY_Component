module Signal_Generator(
  clk,
  reset,
  
  avalonst_source_valid,
  avalonst_source_data,
  avalonst_source_error,
  avalonst_source_ready
);

  input            clk;
  input            reset;
  
  output           avalonst_source_valid;
  output  [ 31: 0] avalonst_source_data;
  output  [  7: 0] avalonst_source_error;
  input            avalonst_source_ready;

  reg              out_valid;
  reg     [ 31: 0] out_data;
  reg     [  7: 0] out_error;
  
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      out_valid <= 1'b0;
      out_data <= 32'b0;
      out_error <= 8'b0;
    end else if (avalonst_source_ready) begin 
      out_valid <= 1'b1;
      out_data <= out_data + 1;
      out_error <= 8'b0;
    end
  end
  
  assign avalonst_source_valid = out_valid;
  assign avalonst_source_data  = out_data;
  assign avalonst_source_error = out_error;

endmodule