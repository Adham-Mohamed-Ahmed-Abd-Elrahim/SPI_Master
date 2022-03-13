module clk_divider
#(parameter clks_per_half_bit=2,parameter clk_idle_state=1)
(input clk, //main clk
 input reset,	
 input trigger, //Enable spi_clock for transmitting or recieving 
 output reg data_ready, 
 output reg out_clk ,//divided clk
 output reg trailing_edge,
 output reg leading_edge
 
);
reg [4:0] edges_num;//there is 16 edge in 8 bits 
reg [clks_per_half_bit*2-1:0] clks_count;
initial begin
edges_num=16;
clks_count=0;
out_clk=clk_idle_state;
data_ready=0;
end
always @ (posedge clk,posedge (reset))begin
if(reset==1)begin
out_clk<=clk_idle_state;//idle state of clk
data_ready<=0;
end
else begin	
trailing_edge<=0;
leading_edge<=0;
               if (trigger==1) //TX_DV (Lasts for 1 clock cycle)
               begin
	       data_ready<=1'b0;
	       edges_num<=16;
		end
		  else if(edges_num>0)begin
			data_ready<=0;
			if(clks_count==2*clks_per_half_bit-1) begin//end of a bit 
			out_clk<=~out_clk;
			clks_count<=0;
			edges_num<=edges_num-1; 
			trailing_edge<=1;
			end
			else if (clks_count==clks_per_half_bit-1)begin
			out_clk<=~out_clk;
			clks_count<=clks_count+1;
			edges_num<=edges_num-1; 
			leading_edge<=1;
			end
			else begin
			clks_count<=clks_count+1;
			end
		end
		else begin
			data_ready<=1'b1;
		end
end
end

endmodule 