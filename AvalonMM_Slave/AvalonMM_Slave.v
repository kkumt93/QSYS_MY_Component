module AvalonMM_Slave(
  input wire reset,
  input wire clk,
  input wire[3:0] address,
  input wire read,
  output reg[31:0] readdata,
  input wire write,
  input wire [31:0] writedata
);

reg [31:0] Mem [3:0];

//Avalon bus write
always@(posedge clk,posedge reset) begin
  if (reset) begin
  //reset event
  end
  else begin
    if (write) begin
      Mem[address] <= writedata;
    end
  end
end

//Avalon bus read
always@(posedge clk,posedge reset) begin
  if (reset) begin
  //reset event
  end
  else begin
    if (read) begin
      readdata <= Mem[address];
    end
  end
end

endmodule

      
    