module register(
	input wire sys_clk, sys_rst_n,
	input wire wr_en0,
	input wire wr_en1,
	input wire wr_en2,
	input wire wr_en3,

	input wire rd_en,
	input wire [11:0]tim_paddr,
	input wire [31:0]tim_pwdata,
	input wire [63:0]cnt,

	input wire int_st,

	input wire halt_ack,

	output reg halt_req,
	output reg timer_en,
	output reg div_en,
	output reg [3:0]div_val,
	output wire wr_err,
	output wire neg_timer_en,

	output wire set_int,
	output wire clear_int,
	output reg int_en,

	output reg [31:0]tim_prdata
);

wire div_en_err; // Error: div_en changes while timer_en is high
wire div_val_err0; // Error: div_val changes while timer_en is high
wire div_val_err1; // Error: write prohibit div_val

wire timer_en_sel;
wire div_en_sel;
wire div_val_sel;
wire int_en_sel;

reg [31:0]TCMP0;
reg [31:0]TCMP1;
wire [63:0]tcmp;

//Total error
assign wr_err = div_en_err || div_val_err0 || div_val_err1;

//Timer_en
assign timer_en_sel = wr_en0 && (tim_paddr == 12'h0) && !wr_err;
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		timer_en <= 1'b0;
	end else begin
		if(timer_en_sel) begin
			timer_en <= tim_pwdata[0];
		end else begin
			timer_en <= timer_en;
		end
	end
end

//Div_en
assign div_en_sel = wr_en0 && (tim_paddr == 12'h0);
assign div_en_err = div_en_sel && timer_en && (tim_pwdata[1] != div_en);
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		div_en <= 1'b0;
	end else begin
		if(div_en_sel && !wr_err) begin
			div_en <= tim_pwdata[1];
		end else begin
			div_en <= div_en;
		end
	end
end

//Div_val
assign div_val_sel = wr_en1 && (tim_paddr == 12'h0);
assign div_val_err0 = div_val_sel && timer_en && (tim_pwdata[11:8] != div_val);
assign div_val_err1 = div_val_sel && (tim_pwdata[11:8] > 4'h8);
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		div_val <= 4'h1;
	end else begin
		if(div_val_sel && !wr_err) begin
			div_val <= tim_pwdata[11:8];
		end else begin
			div_val <= div_val;
		end
	end
end

//Halt_req
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) halt_req <= 1'b0;
	else begin
		if(wr_en0 && (tim_paddr == 12'h1c)) halt_req <= tim_pwdata[0];
	end
end

//Neg_timer_en
assign neg_timer_en = timer_en && (tim_paddr == 12'h0) && wr_en0 && !tim_pwdata[0];

//TCMP
assign TCMP0_sel0 = wr_en0 && (tim_paddr == 12'hc); 
assign TCMP0_sel1 = wr_en1 && (tim_paddr == 12'hc); 
assign TCMP0_sel2 = wr_en2 && (tim_paddr == 12'hc); 
assign TCMP0_sel3 = wr_en3 && (tim_paddr == 12'hc); 

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		TCMP0 <= 32'hffff_ffff;
	end else begin
		if(TCMP0_sel0) TCMP0[7:0] <= tim_pwdata[7:0];
		if(TCMP0_sel1) TCMP0[15:8] <= tim_pwdata[15:8];
		if(TCMP0_sel2) TCMP0[23:16] <= tim_pwdata[23:16];
		if(TCMP0_sel3) TCMP0[31:24] <= tim_pwdata[31:24];
	end
end

assign TCMP1_sel0 = wr_en0 && (tim_paddr == 12'h10); 
assign TCMP1_sel1 = wr_en1 && (tim_paddr == 12'h10); 
assign TCMP1_sel2 = wr_en2 && (tim_paddr == 12'h10); 
assign TCMP1_sel3 = wr_en3 && (tim_paddr == 12'h10); 

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) begin
		TCMP1 <= 32'hffff_ffff;
	end else begin
		if(TCMP1_sel0) TCMP1[7:0] <= tim_pwdata[7:0];
		if(TCMP1_sel1) TCMP1[15:8] <= tim_pwdata[15:8];
		if(TCMP1_sel2) TCMP1[23:16] <= tim_pwdata[23:16];
		if(TCMP1_sel3) TCMP1[31:24] <= tim_pwdata[31:24];
	end
end

assign tcmp = {TCMP1, TCMP0};

//int clear and set
assign set_int = (tcmp == cnt);
assign clear_int = wr_en0 && (tim_paddr == 12'h18) && tim_pwdata[0];

//int_en
assign int_en_sel = wr_en0 && (tim_paddr == 12'h14);
always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) int_en <= 1'b0;
	else begin
		if(int_en_sel) int_en <= tim_pwdata[0];
		else int_en <= int_en;
	end
end

//read

always @(*) begin
	if(!rd_en) tim_prdata = 32'h0;
	else begin
		case (tim_paddr)
			12'h0: tim_prdata = {20'h0, div_val, 6'h0, div_en, timer_en};
			12'h4: tim_prdata = cnt[31:0];
			12'h8: tim_prdata = cnt[63:32];
			12'hC: tim_prdata = TCMP0;
			12'h10: tim_prdata = TCMP1;
			12'h14: tim_prdata = {31'h0, int_en};
			12'h18: tim_prdata = {31'h0, int_st};
			12'h1c: tim_prdata = {30'h0, halt_ack, halt_req};
			default: tim_prdata = 32'h0;
		endcase
	end	
end
	


endmodule
