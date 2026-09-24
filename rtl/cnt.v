module cnt (
	input wire sys_clk, sys_rst_n,
	input wire cnt_en,
	input wire cnt_clr,

	input wire [11:0]tim_paddr,
	input wire [31:0]tim_pwdata,
	input wire wr_en0,
	input wire wr_en1,
	input wire wr_en2,
	input wire wr_en3,

	output reg [63:0]cnt
);

wire TDR0_sel0 = wr_en0 && (tim_paddr == 12'h04);
wire TDR0_sel1 = wr_en1 && (tim_paddr == 12'h04);
wire TDR0_sel2 = wr_en2 && (tim_paddr == 12'h04);
wire TDR0_sel3 = wr_en3 && (tim_paddr == 12'h04);

wire TDR1_sel0 = wr_en0 && (tim_paddr == 12'h08);
wire TDR1_sel1 = wr_en1 && (tim_paddr == 12'h08);
wire TDR1_sel2 = wr_en2 && (tim_paddr == 12'h08);
wire TDR1_sel3 = wr_en3 && (tim_paddr == 12'h08);

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) cnt <= 64'h0;
	else begin
		if(cnt_clr) cnt <= 64'h0;
		else begin
			if(cnt_en) cnt <= cnt + 1'b1;
			else begin
				if(TDR0_sel0) cnt[7:0] <= tim_pwdata[7:0];
				if(TDR0_sel1) cnt[15:8] <= tim_pwdata[15:8];
				if(TDR0_sel2) cnt[23:16] <= tim_pwdata[23:16];
				if(TDR0_sel3) cnt[31:24] <= tim_pwdata[31:24];
				
				if(TDR1_sel0) cnt[39:32] <= tim_pwdata[7:0];
				if(TDR1_sel1) cnt[47:40] <= tim_pwdata[15:8];
				if(TDR1_sel2) cnt[55:48] <= tim_pwdata[23:16];
				if(TDR1_sel3) cnt[63:56] <= tim_pwdata[31:24];
			end
		end
	end
end




endmodule
