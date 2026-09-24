module timer_top(
	input wire sys_clk, sys_rst_n,
	input wire tim_psel,
	input wire tim_pwrite,
	input wire tim_penable,
	input wire [11:0]tim_paddr,
	input wire [31:0]tim_pwdata,
	input wire [3:0]tim_pstrb,
	input wire dbg_mode,

	output wire [31:0]tim_prdata,
	output wire tim_pready,
	output wire tim_pslverr,
	output tim_int
);

wire wr_err;
wire rd_en;
wire wr_en0;
wire wr_en1;
wire wr_en2;
wire wr_en3;
wire [63:0]cnt;
wire int_st;
wire halt_ack;
wire halt_req;
wire int_en;
wire cnt_en;
wire cnt_clr;
wire timer_en;
wire div_en;
wire [3:0]div_val;
wire neg_timer_en;
wire clear_int;
wire set_int;

apb_slave apb_slave_u(
	.sys_clk (sys_clk),
	.sys_rst_n (sys_rst_n),
	.tim_pwrite (tim_pwrite),
	.tim_penable (tim_penable),
	.tim_psel (tim_psel),
	.wr_err (wr_err),
	.tim_pstrb (tim_pstrb),
	.tim_pslverr (tim_pslverr),
	.tim_pready (tim_pready),
	.rd_en (rd_en),
	.wr_en0 (wr_en0),
	.wr_en1 (wr_en1),
	.wr_en2 (wr_en2),
	.wr_en3 (wr_en3)
);

register register_u(
	.sys_clk (sys_clk),
	.sys_rst_n (sys_rst_n),
	.wr_err (wr_err),
	.rd_en (rd_en),
	.wr_en0 (wr_en0),
	.wr_en1 (wr_en1),
	.wr_en2 (wr_en2),
	.wr_en3 (wr_en3),
	.cnt (cnt),
	.timer_en (timer_en),
	.div_en (div_en),
	.div_val (div_val),
	.halt_req (halt_req),
	.halt_ack (halt_ack),
	.neg_timer_en (neg_timer_en),
	.set_int (set_int),
	.clear_int (clear_int),
	.int_en (int_en),
	.int_st (int_st),
	.tim_prdata (tim_prdata),
	.tim_paddr (tim_paddr),
	.tim_pwdata (tim_pwdata)
);

cnt_ctrl cnt_ctrl_u(
	.sys_clk (sys_clk),
	.sys_rst_n (sys_rst_n),
	.timer_en (timer_en),
	.div_en (div_en),
	.dbg_mode (dbg_mode),
	.div_val (div_val),
	.halt_req (halt_req),
	.halt_ack (halt_ack),
	.neg_timer_en (neg_timer_en),
	.cnt_en (cnt_en),
	.cnt_clr (cnt_clr)
);

cnt cnt_u(
	.sys_clk (sys_clk),
	.sys_rst_n (sys_rst_n),
	.cnt_en (cnt_en),
	.cnt_clr (cnt_clr),
	.tim_paddr (tim_paddr),
	.tim_pwdata (tim_pwdata),
	.cnt (cnt),
	.wr_en0 (wr_en0),
	.wr_en1 (wr_en1),
	.wr_en2 (wr_en2),
	.wr_en3 (wr_en3)
);

interrupt interrupt_u(
	.sys_clk (sys_clk),
	.sys_rst_n (sys_rst_n),
	.set_int (set_int),
	.clear_int (clear_int),
	.int_en (int_en),
	.tim_int (tim_int),
	.int_st (int_st)
);

endmodule
