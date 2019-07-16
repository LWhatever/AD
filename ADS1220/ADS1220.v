/*
 *  ADS1220.v
 *
 *  Created on: 2019年5月5日
 *  Author: ZZX
 */
module ADS1220(
input  CLK_50M,
input  wire rst_n,
output wire SCLK,
output MOSI,	
input  MISO,
output reg CS,
input DRDY,
output reg [15:0] outrddat,
input datacs,
input RDdata,
input [11:0] dataAddr
);
wire CLK_10M;
////////////////msp430 read data//////////////////
reg [15:0]cnt=16'd210;
reg start=0;
wire done;

wire [23:0] rddat;
reg [23:0] rddat0/*synthesis noprune*/;
reg [23:0] wrdat;

reg [7:0] wrdat_8;
wire [7:0] rddat_8;
wire SCLK_8;
wire MOSI_8;
wire done_8;
reg start_8=1'd0;
wire SCLK_24;
wire MOSI_24;
wire done_24;
assign MOSI=MOSI_8|MOSI_24;
assign SCLK=SCLK_8|SCLK_24;


clkdiv clkdiv_inst(
.clk(CLK_50M),
.div(16'd25),
.clkout(CLK_10M)
);

////////////////msp430 read data//////////////////
always@(posedge CLK_50M or negedge rst_n)
begin
	if(!rst_n)
		outrddat<=16'd0;
	else if(datacs&RDdata)
	begin
		case(dataAddr[7:0])
		8'd0:outrddat<=result0[15:0];
		8'd1:outrddat<=result0[23:16];
		default: outrddat<=16'd0;
		endcase
	end
end

ADS_24SPI ADS_24SPI_inst
(
	.clk(CLK_10M) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.go(start) ,	// input  start_sig
	.wrdat(wrdat) ,	// input [15:0] wrdat_sig
	.rddat(rddat) ,	// output [15:0] rddat_sig
	.ok(done_24),
	.mosi(MOSI_24) ,	// input  MISO_sig
	.sclk(SCLK_24) ,	// output  MOSI_sig
	.miso(MISO)
);
ADS_8SPI ADS_8SPI_inst
(
	.clk(CLK_10M) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.go(start_8) ,	// input  start_sig
	.wrdat(wrdat_8) ,	// input [15:0] wrdat_sig
	.rddat(rddat_8) ,	// output [15:0] rddat_sig
	.ok(done_8),
	.mosi(MOSI_8) ,	// input  MISO_sig
	.sclk(SCLK_8) ,	// output  MOSI_sig
	.miso(MISO)
);

reg state0=1'd0,state1=1'd0;
always@(negedge CLK_10M or negedge rst_n)
begin
	if(!rst_n)
	begin
		cnt<=16'd0;
		CS<=1'b1;
		start<=1'd0;
		start_8<=1'b0;
		state0=1'd0;
		state1=1'd0;
	end
	else begin 
		if(cnt<88)
		begin
			cnt<=cnt+1'd1;
			CS<=1'b0;
		end
		//reset
		else if(cnt<100)
		begin
			cnt<=cnt+1'b1;
			start_8<=1'd1;
			wrdat_8<=8'h06;
		end
		else if(cnt<300)
		begin	
			cnt<=cnt+1'b1;
			start_8<=1'b0;
		end
		//wreg
		else if(cnt<327)
		begin
			cnt<=cnt+1'b1;
			start<=1'd1;
			wrdat=24'h4190C4;//AIN1-AVSS,Gain=1,Continuous conversion mode,1000sps,其他default,Vref=2.048V
		end
		else if(cnt<330)
		begin	
			start<=1'b0;
			cnt<=cnt+1'b1;
		end
		//start
		else if(cnt<342)
		begin
			cnt<=cnt+1'b1;
			start_8<=1'd1;
			wrdat_8<=8'h08;
		end
		else if(cnt<345)
		begin	
			start_8<=1'b0;
			cnt<=cnt+1'b1;
			CS<=1'b1;
		end
		//rdata 
		else if(cnt==345)
		begin
			state0<=DRDY;
			state1<=state0;
			if((!state0)&state1)
			//if(!state0)
				cnt<=cnt+1'd1;
		end
		else if(cnt>=346&&cnt<350)
		begin
			CS<=1'b0;
			cnt<=cnt+1'd1;
		end
		else if(cnt>=350&&cnt<377)//&&(!DRDY))
		begin
			cnt<=cnt+1'b1;
			start<=1'd1;
			wrdat<=24'h000000;
			rddat0<=rddat;
		end
		else if(cnt>=377&&cnt<380)
		begin	
			start<=1'b0;
			CS<=1'd1;
			cnt<=cnt+1'b1;
		end
      //loop		
		else if(cnt>=380)
		begin
		   cnt<=345;
		end
	end
end
///////////////////////////////////////////////////////////
reg [23:0] result0=24'd0/*synthesis noprune*/;
always@(posedge CS )
begin
	result0<=rddat0;
end
endmodule 
		
			