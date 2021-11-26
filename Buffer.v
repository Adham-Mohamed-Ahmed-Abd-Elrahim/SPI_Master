module buffer 
#(parameter width=8)
(input i_clk,
input reset ,
input [width-1:0] i_byte,
output reg [width-1:0] r_byte
);
always @ (posedge i_clk,posedge reset)begin
if(reset==1)
r_byte<=8'b0;
else 
r_byte<=i_byte;
end
endmodule