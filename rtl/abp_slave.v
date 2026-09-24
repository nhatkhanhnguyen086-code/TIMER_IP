module apb_slave(
	input wire sys_clk, sys_rst_n,
	input wire tim_pwrite,
	input wire tim_psel,
	input wire tim_penable,
	input wire wr_err,
	input wire [3:0]tim_pstrb,

	output wire wr_en0,
	output wire wr_en1,
	output wire wr_en2,
	output wire wr_en3,
	output reg tim_pready,
	output wire tim_pslverr,
	output wire rd_en
);

assign wr_en0 = tim_pwrite && tim_psel && tim_penable && tim_pready && tim_pstrb[0];
assign wr_en1 = tim_pwrite && tim_psel && tim_penable && tim_pready && tim_pstrb[1];
assign wr_en2 = tim_pwrite && tim_psel && tim_penable && tim_pready && tim_pstrb[2];
assign wr_en3 = tim_pwrite && tim_psel && tim_penable && tim_pready && tim_pstrb[3];
assign rd_en = !tim_pwrite && tim_psel && tim_penable && tim_pready;
assign tim_pslverr = wr_err;

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) tim_pready <= 1'b0;
	else begin
		if(tim_pready) tim_pready <= 1'b0;
		else begin
			tim_pready <= (tim_psel && tim_penable);
		end
	end
end

endmodule
