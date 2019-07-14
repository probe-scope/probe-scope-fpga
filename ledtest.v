module ledtest (
	input clk,
	
	input sw,
	
	output reg led1,
	output reg led2,
	output reg led3,
	output reg extra
);

reg [32:0] counter;

initial
	extra <= 0;

always @(posedge clk) begin
	if (~sw)
		led2 <= 1;
	else
		led2 <= 0;
	if (extra)
		extra <= 0;
	else
		extra <= 1;
	
	counter <= counter + 1;
	if (counter > 62500000) begin
		counter <= 0;
		if (led1) begin
			led1 <= 0;
			led3 <= 1;
		end
		else begin
			led1 <= 1;
			led3 <= 0;
		end
	end
end

endmodule
	