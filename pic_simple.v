module pic_simple (
    input [7:0] adc_data,
	input        decim_clk,
	output reg   pmp_d0,
	output reg   pmp_d1,
	output reg   pmp_d2,
	output reg   pmp_d3,
	output reg   pmp_d4,
	output reg   pmp_d5,
	output reg   pmp_d6,
	output reg   pmp_d7,
	input        pmp_dreq
);

always @(posedge (pmp_dreq & decim_clk)) begin
	pmp_d0 <= adc_data[0];
	pmp_d1 <= adc_data[1];
	pmp_d2 <= adc_data[2];
	pmp_d3 <= adc_data[3];
	pmp_d4 <= adc_data[4];
	pmp_d5 <= adc_data[5];
	pmp_d6 <= adc_data[6];
	pmp_d7 <= adc_data[7];
end

endmodule
