module Trigger (
	input clk,
          rising, // True if rising false if falling
    input signed [7:0] data,
				 level,
	output reg trig
);

reg signed [7:0] buff [14:0];

wire signed [15:0] first, second, third;

assign first = buff[0] + buff[1] + buff[2] + buff[3] + buff[4];
assign second = buff[5] + buff[6] + buff[7] + buff[8] + buff[9];
assign third = buff[10] + buff[11] + buff[12] + buff[13] + buff[14];

always @(posedge clk) begin
	buff[0]  <= buff[1];
	buff[1]  <= buff[2];
	buff[2]  <= buff[3];
	buff[3]  <= buff[4];
	buff[4]  <= buff[5];
	buff[5]  <= buff[6];
	buff[6]  <= buff[7];
	buff[7]  <= buff[8];
	buff[8]  <= buff[9];
	buff[9]  <= buff[10];
	buff[10] <= buff[11];
	buff[11] <= buff[12];
	buff[12] <= buff[13];
	buff[13] <= buff[14];
	buff[14] <= data;
	
	if (rising) begin
		trig <= (first / 5) < level && (third / 5) > level;
	end else begin
		trig <= (first / 5) > level && (third / 5) < level;
	end
end

endmodule
