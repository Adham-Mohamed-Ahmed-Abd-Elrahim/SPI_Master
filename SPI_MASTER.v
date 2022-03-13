module spi_master
(input i_clk,
input reset,
//for TX 
input [7:0] tx_byte,
input TX_DV,//transmitted data is valid (for 1 clock cycle) //acknowlegment from RX to TX that the data sent is valid
output  reg tx_ready, //outputs 1 when transmition is finished and ready for another transmission
//for RX
output reg rx_dv, // Recieved data is valid (for 1 clock cycle) //acknowlegment from TX to RX that  the recieved data is valid 
output reg [7:0] rx_byte,//outputs 1 when receiving is finished and ready for another recieveing process
//clocking 
output  o_spi_clk,
//in/out
input MISO,
output transrecieve ,
output reg MOSI,
//slave select
output reg ss //(Active low)
);
//internal wires 
//For clock
wire r_spi_clk;//output from clk divider
wire leading_edge;
wire trailing_edge;
//Data
reg [2:0] TX_bit_count;//8 counts
reg [2:0] RX_bit_count;//8 counts
wire [7:0] r_TX_Byte;
initial begin
TX_bit_count=3'b111;
RX_bit_count=3'b111;
end
//transmission
//wire transrecieve ; //gives one when transreciving is finsihed
//-------------------------------------------------
//States 
localparam [1:0] idle_state=2'b00;
localparam [1:0] Transrecieving=2'b01;
localparam [1:0] last_state=2'b10;
reg [1:0] current_state;
reg [1:0] next_state;
//Instantiaions
clk_divider clk
(.clk(i_clk), //main clk
 .reset(reset),	
 .trigger(TX_DV), //Enable spi_clock for transmitting or recieving 
 .data_ready(transrecieve), 
 .trailing_edge(trailing_edge),
 .leading_edge(leading_edge),
 .out_clk(r_spi_clk) //divided clk
);
//for aliment to avoid metastability of the clock
meta_harden synchronizer
(.i_clk(i_clk),
 .r_spi_clk(r_spi_clk),
 .reset(reset),
 .o_spi_clk(o_spi_clk)
);
buffer tx_byt 
(.i_clk(i_clk),
 .reset(reset) ,
 .i_byte(tx_byte),
 .r_byte(r_TX_Byte)
);


//Transition between states
always @ (posedge i_clk ,posedge reset)
begin 
if(reset==1)
current_state<=idle_state;
else 
current_state<=next_state;
end

//Moor finite state machine
always @ (current_state,TX_DV,transrecieve)
begin
case(current_state)
//idle state and ready to transmit
idle_state:begin
ss=1'b1;
next_state=(TX_DV==1'b1) ? Transrecieving:idle_state; //TX_DV for one cycle
end

Transrecieving:begin
ss<=1'b0;
if (transrecieve==1)
next_state=idle_state;
else
next_state=Transrecieving;
end
default:begin
next_state=idle_state;
end
endcase
end
//generating mosi 
always @ (posedge i_clk,posedge reset)begin
if(reset==1)begin
MOSI<=0;
end
else if (leading_edge==1)begin
MOSI<=r_TX_Byte[TX_bit_count];
TX_bit_count<=TX_bit_count-1;
end
end
//generating miso make sure[]
always @ (posedge i_clk)begin
if(reset)begin
rx_dv<=1;
end
else begin 
if (trailing_edge==1)begin
rx_byte[RX_bit_count]<=MISO;
RX_bit_count<=RX_bit_count-1;
end
end
end

endmodule
