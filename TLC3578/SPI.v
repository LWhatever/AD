module SPI(
input clk, 
input rst,
output SIMO,
output SCLK,
input SOMI,
output reg CS, 
output reg [15:0] data0,data1,data2,data3,
output reg [13:0] MAX1, MAX2
);

reg [7:0]cnt = 0;
reg start=0;
reg [15:0] CFR = 16'hA000;
reg [2:0] state;
wire done;
wire [15:0] rddat;
wire srt;
wire clk_1M;
reg start_end1, start_end2;


clkdiv clkdiv_inst
(
	.clk(clk) ,	// input  clk_sig
	.div(12'd10) ,	// input [11:0] div_sig
	.clkdiv(clk_1M) 	// output  clkdiv_sig
);

AD a1(clk_1M,1'b1,start,CFR,rddat,done,SIMO,SCLK,SOMI);
reg [15:0] CNT1, CNT2;
reg [13:0] max1, max2;

always@(posedge clk_1M or negedge rst)
begin
	if(!rst)
	begin
		state <= 3'b000;
		CNT1 <= 0;
		start_end1 <= 1'b0;
		start_end2 <= 1'b0;
	end
	else
	case(state)
	3'b000:begin
		if(cnt<=50)
		begin
			cnt<=cnt+1'b1;
			CS<=1'b1;
		end
		else if(cnt>50&&cnt<70)
		begin
			CS<=1'b0;
			CFR <= 16'hA000;
			start<=1'b1;
			cnt<=cnt+1'b1;
		end
		else if(cnt>=70)
		begin
			CS<=1'b1;
			start<=0;
			cnt<=0;
			state <= 3'b001;
		end
	end
	3'b001:begin
		if(cnt<=50)
		begin
			cnt<=cnt+1'b1;
			CS<=1'b1;
		end
		else if(cnt>50&&cnt<70)
		begin
			CS<=1'b0;
			CFR <= 16'hAA00;
			start<=1'b1;
			cnt<=cnt+1'b1;
		end
		else if(cnt>=70)
		begin
			CS<=1'b1;
			start<=0;
			cnt<=0;
			state <= 3'b010;
		end
	end
	3'b010:begin
		if(CNT1 == 0)
		begin
			start_end1 <= 1'b1;
		end
		if(cnt<=50)
		begin
			cnt<=cnt+1'b1;
			CS<=1'b1;
		end
		else if(cnt>50&&cnt<70)
		begin
			CS<=1'b0;
			CFR <= 16'h0000;
			start<=1'b1;
			cnt<=cnt+1'b1;
		end
		else if(cnt>=70)					//Sample Rate = 17857Hz
		begin
			CNT1 <= CNT1 + 16'd1;			//判断是否完成一周期
			if(CNT1 == 16'd17857)
			begin
				start_end1 <= 1'b0;
				CNT1 <= 0;
			end
			CS<=1'b1;
			start<=0;
			cnt<=0;
			state <= 3'b011;
			data0 <= rddat;
		end
	end
	3'b011:begin
		if(cnt<=50)
		begin
			cnt<=cnt+1'b1;
			CS<=1'b1;
		end
		else if(cnt>50&&cnt<70)
		begin
			CS<=1'b0;
			CFR <= 16'h1000;
			start<=1'b1;
			cnt<=cnt+1'b1;
		end
		else if(cnt>=70)
		begin
			CS<=1'b1;
			start<=0;
			cnt<=0;
			state <= 3'b100;
			data1 <= rddat;
		end
	end
	3'b100:begin
		if(cnt<=50)
		begin
			cnt<=cnt+1'b1;
			CS<=1'b1;
		end
		else if(cnt>50&&cnt<70)
		begin
			CS<=1'b0;
			CFR <= 16'h5000;
			start<=1'b1;
			cnt<=cnt+1'b1;
		end
		else if(cnt>=70)
		begin
			CS<=1'b1;
			start<=0;
			cnt<=0;
			state <= 3'b101;
			data2 <= rddat;
		end
	end
	3'b101:begin
		if(CNT2 == 0)
		begin
			start_end2 <= 1'b1;
		end
		if(cnt<=50)
		begin
			cnt<=cnt+1'b1;
			CS<=1'b1;
		end
		else if(cnt>50&&cnt<70)
		begin
			CS<=1'b0;
			CFR <= 16'h6000;
			start<=1'b1;
			cnt<=cnt+1'b1;
		end
		else if(cnt>=70)
		begin
			CNT2 <= CNT2 + 16'd1;
			if(CNT2 == 16'd17857)
			begin
				start_end2 <= 1'b0;
				CNT2 <= 0;
			end
			CS<=1'b1;
			start<=0;
			cnt<=0;
			state <= 3'b010;
			data3 <= rddat;
		end
	end
	endcase
end

always@(posedge CS)
begin
if(state == 3'b010)
begin
	if(start_end1 == 1)
	begin
		if(data0[15:2]>max1)
			max1<=data0[15:2];
	end
	else if(start_end1 == 0)
	begin
		MAX1 <= max1;
		max1 <= 0;
	end
end
else if(state == 3'b101)
begin
	if(start_end2 == 1)
	begin
		if(data3[15:2]>max2)
			max2<=data3[15:2];
	end
	else if(start_end2 == 0)
	begin
		MAX2 <= max2;
		max2 <= 0;
	end
end
end

endmodule