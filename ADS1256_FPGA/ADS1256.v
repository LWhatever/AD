module ADS1256(
input  CLK_50M,
input  wire rst_n,
output wire SCLK,//4
output MOSI,		//main out, slave in 3
input  MISO,//2
output reg CS,//1
input DRDY,
output reg [23:0] outrddat,
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
reg [23:0] rddat1/*synthesis noprune*/;
reg [23:0] wrdat;
reg [2:0] order=3'd0;

clkdiv clkdiv_inst(
.clk(CLK_50M),
.div(16'd20),
.clkout(CLK_10M)
);

////////////////msp430 read data//////////////////
always@(posedge CLK_50M or negedge rst_n)
begin
	if(!rst_n)
		outrddat<=24'd0;
	else if(datacs&RDdata)
	begin
		case(dataAddr[7:0])
		8'd0:outrddat<=result0[23:0];
		8'd1:outrddat<=result1[23:0];
		default: outrddat<=24'd0;
		endcase
	end
end

ADS1256_SPI ADC1256_SPI_inst
(
	.clk(CLK_10M) ,	// input  clk_sig
	.rst_n(rst_n) ,	// input  rst_n_sig
	.go(start) ,	// input  start_sig
	.wrdat(wrdat) ,	// input [15:0] wrdat_sig
	.rddat(rddat) ,	// output [15:0] rddat_sig
	.ok(done),
	.mosi(MOSI) ,	// input  MISO_sig
	.sclk(SCLK) ,	// output  MOSI_sig
	.miso(MISO)
);


always@(negedge CLK_10M or negedge rst_n)
begin
	if(!rst_n)
	begin
		cnt<=16'd0;
		order<=3'd0;
		CS<=1'b1;
	end
	else begin 
		if(cnt<120)
		begin
			cnt<=cnt+1'd1;
			CS<=1'b1;
		end
		//写Mux
		else if(cnt>=120&&cnt<148&&(!DRDY))
		begin
			CS<=1'b0;
			cnt<=cnt+1'b1;
			start<=1'd1;
			if(order==3'd0)
			wrdat<=24'h510008;
			else
			wrdat<=24'h510018;
		end
		else if(cnt>=148&&cnt<150)
		begin	
			start<=1'b0;
			cnt<=cnt+1'b1;
		end
		//写sync wakeup
		else if(cnt>=150&&cnt<178&&(!DRDY))
		begin
			cnt<=cnt+1'b1;
			start<=1'd1;
			wrdat<=24'hfc0001;
		end
		else if(cnt>=178&&cnt<180)
		begin	
			start<=1'b0;
			cnt<=cnt+1'b1;
		end
		//读数据
		else if(cnt>=180&&cnt<208&&(!DRDY))
		begin
			cnt<=cnt+1'b1;
			start<=1'd1;
			wrdat<=24'h000000;
			if(order==3'd0)
			rddat0<=rddat;
			else
			rddat1<=rddat;
		end
		else if(cnt>=208&&cnt<210)
		begin	
			start<=1'b0;
			cnt<=cnt+1'b1;
		end
      //换通道		
		else if(cnt>=210)
		begin
		   cnt<=115;
			if(order==3'd0)
				order<=3'd1;
			else
				order<=3'd0;
			CS<=1'b1;
		end
	end
end
///////////////////////////////////////////////////////////
reg [23:0] result0=24'd0/*synthesis noprune*/;
reg [23:0] result1=24'd0/*synthesis noprune*/;
always@(posedge CS )
begin
	result0<=rddat0;
	result1<=rddat1;
end
endmodule 
		
			