module meta_harden
#(parameter clk_idle_state=1)
(input i_clk,
 input r_spi_clk,
 input reset,
 output reg o_spi_clk
);
always @ (posedge i_clk, posedge reset)
begin
if(reset==1)begin
o_spi_clk<=clk_idle_state;
end
else begin
o_spi_clk<=r_spi_clk;
end
end
endmodule