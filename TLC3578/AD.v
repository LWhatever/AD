module AD
(
input clk,rst_n,
input go,
input [15:0]wrdat,
output reg [15:0]rddat,
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

reg [15:0]r_wrdat;
always @(posedge clk or negedge rst_n)
if(!rst_n)begin
r_wrdat<=16'd0;
mosi<=1'b0;
end
else begin
case(i)
5'd0:begin r_wrdat<=wrdat;mosi<=1'b0;end
5'd1:mosi<=r_wrdat[15];
5'd2:mosi<=r_wrdat[14];
5'd3:mosi<=r_wrdat[13];
5'd4:mosi<=r_wrdat[12];
5'd5:mosi<=r_wrdat[11];
5'd6:mosi<=r_wrdat[10];
5'd7:mosi<=r_wrdat[9];
5'd8:mosi<=r_wrdat[8];
5'd9:mosi<=r_wrdat[7];
5'd10:mosi<=r_wrdat[6];
5'd11:mosi<=r_wrdat[5];
5'd12:mosi<=r_wrdat[4];
5'd13:mosi<=r_wrdat[3];
5'd14:mosi<=r_wrdat[2];
5'd15:mosi<=r_wrdat[1];
5'd16:mosi<=r_wrdat[0];
default:mosi<=1'b0;
endcase
end

reg  [15:0]r_rddat;
reg  cke;
always @(negedge clk or negedge rst_n)
if(!rst_n)begin
r_rddat<=16'd0;
cke<=1'b0;
ok<=1'b0;
end
else begin
case(i)
5'd0:begin cke<=1'b0;ok<=1'b0;end
5'd1:cke<=1'b1;
5'd2:r_rddat[15]<=miso;
5'd3:r_rddat[14]<=miso;
5'd4:r_rddat[13]<=miso;
5'd5:r_rddat[12]<=miso;
5'd6:r_rddat[11]<=miso;
5'd7:r_rddat[10]<=miso;
5'd8:r_rddat[9]<=miso;
5'd9:r_rddat[8]<=miso;
5'd10:r_rddat[7]<=miso;
5'd11:r_rddat[6]<=miso;
5'd12:r_rddat[5]<=miso;
5'd13:r_rddat[4]<=miso;
5'd14:r_rddat[3]<=miso;
5'd15:r_rddat[2]<=miso;
5'd16:r_rddat[1]<=miso;
5'd17:begin r_rddat[0]<=miso; cke<=1'b0;end
5'd18:begin rddat<=r_rddat;ok<=1'b1;end
default:;
endcase
end 
assign sclk=cke&clk;

endmodule
