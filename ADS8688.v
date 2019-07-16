module ADS8688
(
input wire rst_n,
input CLK_50M,
output clk_100,
output reg CS,
output wire SCLK,
output reg SDI,
input SDO,
output reg RST=1,
output reg [15:0] rddat7,rddat6,rddat5,rddat0,rddat4,rddat3,outRMS,
//output reg [15:0] rddat0,rddat7,rddat5,rddat1,rddat4,rddat3,outRMS,
input [11:0] dataAddr,
input RDdata
);

reg [6:0] cnt;
reg [3:0] order=0;
reg [15:0] PRC=16'h0B00;     //program register configure
reg [15:0] ch_sel;		//channel select
reg [15:0] rddat;

assign SCLK=~CS&CLK_16_7M;

wire CLK_16_7M;
clkdiv clk_inst
(
	.clk(CLK_50M),
	.div(15'd3),
	.clkout(CLK_16_7M)
);
////////////msp430 read data//////////////////
always@(posedge CLK_50M or negedge rst_n)
begin
	if(!rst_n)
		outRMS <= 0;
	else if(RDdata)
	begin
		case(dataAddr[7:0])				//dataAddr决定取出的V_RMS数据段
		8'd0:outRMS <= Power_7[47:32];
		8'd1:outRMS <= Power_7[31:16];
		8'd2:outRMS <= Power_7[15:0];
		8'd3:outRMS <= Power_6[47:32];
		8'd4:outRMS <= Power_6[31:16];
		8'd5:outRMS <= Power_6[15:0];
		8'd6:outRMS <= Power_5[47:32];
		8'd7:outRMS <= Power_5[31:16];
		8'd8:outRMS <= Power_5[15:0];
		8'd9:outRMS <= Power_0[47:32];
		8'd10:outRMS <= Power_0[31:16];
		8'd11:outRMS <= Power_0[15:0];
		8'd12:outRMS <= Power_4[47:32];
		8'd13:outRMS <= Power_4[31:16];
		8'd14:outRMS <= Power_4[15:0];
		8'd15:outRMS <= Power_3[47:32];
		8'd16:outRMS <= Power_3[31:16];
		8'd17:outRMS <= Power_3[15:0];
		8'd18:outRMS <= max_cnt[15:0];
		default: outRMS<=0;
		endcase
	end
end

////////////////SPI/////////////////
always@(posedge CLK_16_7M or negedge rst_n)
begin
	if(!rst_n)
	begin
		cnt <= 1'd0;
		CS <= 1'd0;
		RST <= 0;
		order <= 4'd0;
	end
	else 
	begin
		RST<=1'd1;
		if(cnt<7'd50)
		begin
			CS<=1'd1;
			cnt<=cnt+1'd1;
		end
		else if(cnt>=7'd50&&cnt<=7'd82)
		begin
			CS<=0;
			cnt<=cnt+1'd1;
		end
		if(cnt>7'd82)
		begin
			if(order==4'd0)
			begin
				PRC<=16'h1901;					//channel7 0 +-2.5*Vref
//				PRC<=16'h0B01;					//channel0 0 +-2.5*Vref
				order<=4'd1;
			end
			if(order==4'd1)
			begin
				PRC<=16'h1701;             //channel6 0 +-2.5*Vref
//				PRC<=16'h1901;					//channel7 0 +-2.5*Vref
				order<=4'd2;
			end
			if(order==4'd2)
			begin
				PRC<=16'h1501;             //channel5 0 +-2.5*Vref
				order<=4'd3;
			end
			if(order==4'd3)
			begin
				PRC<=16'h0B01;					//channel0 0 +-2.5*Vref
//				PRC<=16'h1701;             //channel6 0 +-2.5*Vref
				order<=4'd4;
			end
			if(order==4'd4)
			begin
				PRC<=16'h1301;             //channel4 0 +-2.5*Vref
				order<=4'd5;
			end
			if(order==4'd5)
			begin
				PRC<=16'h1101;             //channel3 0 +-2.5*Vref
				order<=4'd6;
			end
			else if(order==4'd6)
			begin
				ch_sel<=16'hDC00;				//channel7
//				ch_sel<=16'hC000;				//channel0
				order<=4'd7;
			end
			else if(order==4'd7)
			begin
				ch_sel<=16'hD800;          //channel6
//				ch_sel<=16'hDC00;				//channel7
				order<=4'd8;
				rddat3<=rddat;
			end
			else if(order==4'd8)
			begin 
				ch_sel<=16'hD400;          //channel5
				order<=4'd9;
				rddat7<=rddat;
			end
			else if(order==4'd9)
			begin
				ch_sel<=16'hC000;          //channel0
//				ch_sel<=16'hD800;          //channel6
				order<=4'd10;
				rddat6<=rddat;
			end
			else if(order==4'd10)
			begin 
				ch_sel<=16'hD000;          //channel4
				order<=4'd11;
				rddat5<=rddat;
			end
			else if(order==4'd11)
			begin 
				ch_sel<=16'hCC00;          //channel3
				order<=4'd12;
				rddat0<=rddat;
			end
			else if(order==4'd12)
			begin
				ch_sel<=16'hDC00;				//channel7
//				ch_sel<=16'hC000;          //channel0
				order<=4'd7;
				rddat4<=rddat;
			end
			CS<=1'd1;
			cnt<=7'd40;
		end
	end
end

always@(posedge CLK_16_7M or negedge rst_n) 
begin
	if(!rst_n)
	begin
		SDI<=0;
	end
	else if(order<=4'd6)
	begin
		case(cnt)
			7'd50:SDI <= PRC[15];
			7'd51:SDI <= PRC[14];
			7'd52:SDI <= PRC[13];
			7'd53:SDI <= PRC[12];
			7'd54:SDI <= PRC[11];
			7'd55:SDI <= PRC[10];
			7'd56:SDI <= PRC[9];
			7'd57:SDI <= PRC[8];
			7'd58:SDI <= PRC[7];
			7'd59:SDI <= PRC[6];
			7'd60:SDI <= PRC[5];
			7'd61:SDI <= PRC[4];
			7'd62:SDI <= PRC[3];
			7'd63:SDI <= PRC[2];
			7'd64:SDI <= PRC[1];
			7'd65:SDI <= PRC[0];
		endcase
	end
	else 
	begin
		case(cnt)
			7'd50:SDI <= ch_sel[15];
			7'd51:SDI <= ch_sel[14];
			7'd52:SDI <= ch_sel[13];
			7'd53:SDI <= ch_sel[12];
			7'd54:SDI <= ch_sel[11];
			7'd55:SDI <= ch_sel[10];
			7'd56:SDI <= ch_sel[9];
			7'd57:SDI <= ch_sel[8];
			7'd58:SDI <= ch_sel[7];
			7'd59:SDI <= ch_sel[6];
			7'd60:SDI <= ch_sel[5];
			7'd61:SDI <= ch_sel[4];
			7'd62:SDI <= ch_sel[3];
			7'd63:SDI <= ch_sel[2];
			7'd64:SDI <= ch_sel[1];
			7'd65:SDI <= ch_sel[0];
		endcase
	end
end

always@(negedge CLK_16_7M or negedge rst_n) 
begin
	if(!rst_n)
	begin
		rddat<=0;
	end
	else if(order>4'd6)
	begin
		case(cnt)
			7'd67:rddat[15]=SDO;
			7'd68:rddat[14]=SDO;
			7'd69:rddat[13]=SDO;
			7'd70:rddat[12]=SDO;
			7'd71:rddat[11]=SDO;
			7'd72:rddat[10]=SDO;
			7'd73:rddat[9]=SDO;
			7'd74:rddat[8]=SDO;
			7'd75:rddat[7]=SDO;
			7'd76:rddat[6]=SDO;
			7'd77:rddat[5]=SDO;
			7'd78:rddat[4]=SDO;
			7'd79:rddat[3]=SDO;
			7'd80:rddat[2]=SDO;
			7'd81:rddat[1]=SDO;
			7'd82:rddat[0]=SDO;
		endcase
	end	
end

// calculate the RMS
reg [15:0] cnt50 = 0;
reg [47:0] power_7/*synthesis noprune*/;
reg [47:0] power_6/*synthesis noprune*/;
reg [47:0] power_5/*synthesis noprune*/;
reg [47:0] power_0/*synthesis noprune*/;
reg [47:0] power_4/*synthesis noprune*/;
reg [47:0] power_3/*synthesis noprune*/;
reg [47:0] Power_7/*synthesis noprune*/;
reg [47:0] Power_6/*synthesis noprune*/;
reg [47:0] Power_5/*synthesis noprune*/;
reg [47:0] Power_0/*synthesis noprune*/;
reg [47:0] Power_4/*synthesis noprune*/;
reg [47:0] Power_3/*synthesis noprune*/;
reg [15:0] max_cnt = 0;
reg r1,r2/*synthesis noprune*/;
reg [15:0] data7_abs,data6_abs,data5_abs,data0_abs,data4_abs,data3_abs;

	// over-zero check
	OverZero OverZero_inst
	(
		.datain(rddat6) ,	// input [15:0] datain_sig
		.zero(16'd32768) ,	// input [15:0] zero_sig
		.flag(clk_100) 	// output  flag_sig
	);
	
always@(posedge CS )
begin
	r1 <= clk_100;
	r2 <= r1; 
	if(r1==1&&r2==0&&cnt50>7'd100)									//66270/100 = 662, find the posedge of clk_100
	begin
		Power_7 <= power_7;
		Power_6 <= power_6;
		Power_5 <= power_5;
		Power_0 <= power_0;
		Power_4 <= power_4;
		Power_3 <= power_3;
		power_7 <= 0;
		power_6 <= 0;
		power_5 <= 0;
		power_0 <= 0;
		power_4 <= 0;
		power_3 <= 0;
		max_cnt <= cnt50;
		cnt50 <= 0;
	end
	else
	begin
		//****** get ABS ******
		data7_abs = (rddat7 > 16'd32768)?(rddat7 - 16'd32768):(16'd32768 - rddat7);
		                                                                        
		data6_abs = (rddat6 > 16'd32768)?(rddat6 - 16'd32768):(16'd32768 - rddat6);
		                                                                        
		data5_abs = (rddat5 > 16'd32768)?(rddat5 - 16'd32768):(16'd32768 - rddat5);
			                                                                     
		data0_abs = (rddat0 > 16'd32768)?(rddat0 - 16'd32768):(16'd32768 - rddat0);
		                                                                        
		data4_abs = (rddat4 > 16'd32768)?(rddat4 - 16'd32768):(16'd32768 - rddat4);
		                                                                        
		data3_abs = (rddat3 > 16'd32768)?(rddat3 - 16'd32768):(16'd32768 - rddat3);
		
		//****** get power ******
		power_7 <= power_7 + data7_abs * data7_abs;
		                                     
		power_6 <= power_6 + data6_abs * data6_abs;
		                                      
		power_5 <= power_5 + data5_abs * data5_abs;
		                                      
		power_0 <= power_0 + data0_abs * data0_abs;
		                                      
		power_4 <= power_4 + data4_abs * data4_abs;
		                                      
		power_3 <= power_3 + data3_abs * data3_abs;
			
		cnt50 <= cnt50 + 1'b1;
	end
end

endmodule