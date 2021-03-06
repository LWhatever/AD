module Display(CLOCK, set_s, set_m, set_h, rst, S0, S1, M0, M1, H0, H1, W, ld0, ld1,CLK);
	input CLOCK, set_s, set_m, set_h, rst;
	input [3:0] ld0, ld1;
	output [3:0] S0, S1, M0, M1, H0, H1, W;
	output CLK;
	wire clk, done_s, done_m, done_d;
	reg Done_S, Done_M, Done_D;
	always@(*) begin
		Done_S <= done_s;
		Done_M <= done_m;
		Done_D <= done_d;
	end
	div_clk Clk(CLOCK,clk);
	Counter1 cnt_s(clk, rst, set_s, ld0, ld1, S0, S1, done_s);
	Counter1 cnt_m(Done_S, rst, set_m, ld0, ld1, M0, M1, done_m);
	Counter2 cnt_h(Done_M, rst, set_h, ld0, ld1, H0, H1, done_d);
	Sound sd(CLOCK, S0, S1, M0, M1, CLK);
	Week wk(Done_D, rst, W);
endmodule

/*module Display(CLOCK, set, rst, S0, S1, M0, M1, H0, H1, ld0, ld1);
	input CLOCK, set, rst;
	input [3:0] ld0, ld1;
	output [3:0] S0, S1, M0, M1, H0, H1;
	wire clk, done_s, done_m;
	reg Done_S, Done_M;
	wire [2:0] ld;               //new add
	
	always@(*) begin
		Done_S <= done_s;
		Done_M <= done_m;
	end

	Select s(set, ld);                  //new add
	div_clk Clk(CLOCK,clk);
	Counter1 cnt_s(clk, rst, ld[0], ld0, ld1, S0, S1, done_s);
	Counter1 cnt_m(Done_S, rst, ld[1], ld0, ld1, M0, M1, done_m);
	Counter2 cnt_h(Done_M, rst, ld[2], ld0, ld1, H0, H1);
endmodule*/

module Select(set, ld);
	input set;
	output [2:0] ld;
	reg [1:0] cnt;
	reg [2:0] ld;
	always @(posedge set) begin
		cnt = set? cnt + 2'b01 : cnt;
		case(cnt)
			2'b00: ld = 3'b000;
			2'b01: ld = 3'b001;
			2'b10: ld = 3'b010;
			2'b11: ld = 3'b100;
			default ld = 3'b000;
		endcase
	end
endmodule

module Counter1(clk, rst, ld, d0, d1, c0, c1, done);							//0~60 counter
	input rst, clk, ld; 												// reset, clock and load
	input [3:0] d0, d1;
	output [3:0] c0, c1;
	output done;
	wire [3:0] next0 = (c0 == 4'b1001)? 4'b0000 : c0 + 4'b0001 ;	//low bit
	wire [3:0] next1 = ((c0 == 4'b1001)&(c1 == 4'b0101))? 4'b0000 : (c0 == 4'b1001)? c1 + 4'b0001 : c1 ;//hight bit
	//wire [3:0] next0 = rst? 0 : (c0 == max0)? 4'b0000 : c0 + 4'b0001 ;	//low bit
	//wire [3:0] next1 = rst? 0 : ((c0 == max0)&(c1 == max1))? 4'b0000 : (c0 == max0)? c1 + 4'b0001 : c1 ;//hight bit
	assign done = (c0 == 4'b1001) & (c1 == 4'b0101);
	D_FF #(4) count0(rst, clk, ld, d0, next0, c0) ;
	D_FF #(4) count1(rst, clk, ld, d1, next1, c1) ;
endmodule

module Counter2(clk, rst, ld, d0, d1, c0, c1, done);
	input rst, clk, ld; 												// reset, clock and load
	input [3:0] d0, d1;
	output [3:0] c0, c1;
	output done;
	wire [3:0] next0 = ((c1 == 4'b0010)&(c0 == 4'b0011)|(c0 == 4'b1001))?4'b0000:c0 + 4'b0001;
	wire [3:0] next1 = ((c1 == 4'b0010)&(c0 == 4'b0011))?4'b0000:(c0 == 4'b1001)? c1 + 4'b0001 : c1 ;
	D_FF #(4) count0(rst, clk, ld, d0, next0, c0) ;
	D_FF #(4) count1(rst, clk, ld, d1, next1, c1) ;
	assign done = (c0 == 4'b0011) & (c1 == 4'b0010);
endmodule

module Week(clk, rst, d);
	input rst, clk; 												// reset, clock and load
	output [3:0] d;
	wire [3:0] next0 = (d == 4'b0110)? 4'b1000 : (d == 4'b1000)? 4'b0001 : d + 4'b0001;
	D_FF #(4) count0(rst, clk, 0, 4'b0000, next0, d) ;
endmodule

module D_FF(rst, clk, ld, d, in, out);
	parameter n = 1;
	input clk, rst, ld;
	input [n-1:0] in, d;
	output [n-1:0] out;
	reg [n-1:0] out;
	always @(negedge clk or posedge rst or posedge ld)begin
		//out = rst? 0 :ld? d : in;
		if(rst)
			out <= 0;
		else if(ld)
			out <= d;
		else
			out <= in;
	end
endmodule

module div_clk(CLOCK,clk);
	input CLOCK;//40000000
	output clk;
	reg clk;
	reg [24:0] Count;
	always@(posedge CLOCK)
	begin
		Count <= Count + 25'h0000001;
		if(Count == 25'd20000000)
		begin
			clk <=~clk;			
			Count <= 25'h0000000;
		end	
	end
endmodule

module Sound(CLOCK, s0, s1, m0, m1, CLK);
	input CLOCK;//40000000
	input [3:0] s0, s1, m0, m1;
	output CLK;
	reg clk1, clk2;
	reg [15:0] count1;   //500Hz(40000)
	always@(posedge CLOCK)
	begin
		count1 <= count1 + 16'h0001;
		if(count1 == 16'd20000)
		begin
			clk1 <=~clk1;			
			count1 <= 16'h0000;
		end
	end
	always@(posedge clk1)
	begin
		clk2 <= ~clk2;
	end
	wire CLK = (m0 == 4'b1001)&(m1 == 4'b0101)&(s1 == 4'b0101)&(s0 != 4'b1001)&s0[0]? clk2 :
	(m0 == 4'b1001)&(m1 == 4'b0101)&(s1 == 4'b0101)&(s0 == 4'b1001)&s0[0]?clk1:0;
endmodule