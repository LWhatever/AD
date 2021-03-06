module ADS_8SPI
(
input clk,rst_n,
input go,
input [7:0]wrdat,
output reg [7:0]rddat,
output reg ok,
output reg mosi,
output  sclk,
input miso
);

reg [4:0]i;

always @(posedge clk or negedge rst_n)
if(!rst_n)
i<=5'd0;
else if(!go)
i<=5'd0;
else if(i<5'd23)
i<=i+1'b1;

reg [7:0]r_wrdat;
always @(posedge clk or negedge rst_n)
if(!rst_n)begin
r_wrdat<=8'd0;
mosi<=1'b0;
end
else begin
case(i)
5'd0:begin r_wrdat<=wrdat;mosi<=1'b0;end
5'd1:mosi<=r_wrdat[7];
5'd2:mosi<=r_wrdat[6];
5'd3:mosi<=r_wrdat[5];
5'd4:mosi<=r_wrdat[4];
5'd5:mosi<=r_wrdat[3];
5'd6:mosi<=r_wrdat[2];
5'd7:mosi<=r_wrdat[1];
5'd8:mosi<=r_wrdat[0];
default:mosi<=1'b0;
endcase
end

reg  [7:0]r_rddat;
reg  cke;
always @(negedge clk or negedge rst_n)
if(!rst_n)begin
r_rddat<=8'd0;
cke<=1'b0;
ok<=1'b0;
end
	else begin
case(i)
5'd0:begin cke<=1'b0;ok<=1'b0;end
5'd1:cke<=1'b1;
5'd2:r_rddat[7]<=miso;
5'd3:r_rddat[6]<=miso;
5'd4:r_rddat[5]<=miso;
5'd5:r_rddat[4]<=miso;
5'd6:r_rddat[3]<=miso;
5'd7:r_rddat[2]<=miso;
5'd8:r_rddat[1]<=miso;
5'd9:begin r_rddat[0]<=miso; cke<=1'b0;end
5'd10:begin rddat<=r_rddat;ok<=1'b1;end
default:;
endcase
end 
assign sclk=cke&clk;

endmodule
