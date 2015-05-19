`default_nettype none

module module_name(
  input wire reset,
  input wire clk,
  input wire[x:0] address,
  input wire read,
  output reg[31:0] readdata,
  input wire write,
  input wire [31:0] writedata,
  output wire[x:0] export
);

reg [x:0] export;

//Avalon bus write
always@(posedge clk,posedge reset) begin
  if (reset) begin
    /*---Event---*/
  end
  else begin
    if (write) begin
      case(address)
      /*---Event---*/
      endcase
    end
  end
end

//Avalon bus read
always @* begin
  /*---Event---*/
  endcase
end

endmodule
    

      
    