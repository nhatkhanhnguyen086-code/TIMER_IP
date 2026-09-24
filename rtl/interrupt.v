module interrupt(
	input wire sys_clk, sys_rst_n,
	input wire set_int,
	input wire clear_int,
	input wire int_en,
	
	output reg int_st,
	output wire tim_int
);

always @(posedge sys_clk or negedge sys_rst_n) begin
	if(!sys_rst_n) int_st <= 1'b0;
	else begin
		if(clear_int) int_st <= 1'b0;
		else begin
			if(set_int) int_st <= 1'b1;
			else int_st <= int_st;
		end
	end
end

assign tim_int = int_en && int_st;

endmodule
