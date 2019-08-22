module pic_simple (
    input [7:0] adc_data,
	output reg   fifo_rdck,
	input        fifo_rden,
	output reg   pmp_d0,
	output reg   pmp_d1,
	output reg   pmp_d2,
	output reg   pmp_d3,
	output reg   pmp_d4,
	output reg   pmp_d5,
	output reg   pmp_d6,
	output reg   pmp_d7,
	input        pmp_dreq,
	output reg   pmp_drdy,
	input        delay_clock
);

always @(pmp_dreq) begin
	if (pmp_dreq & fifo_rden) begin
		if (~pmp_drdy) begin
			fifo_rdck <= 1;
			@(delay_clock);
			@(delay_clock);
			fifo_rdck <= 0;
			pmp_d0 <= adc_data[0];
			pmp_d1 <= adc_data[1];
			pmp_d2 <= adc_data[2];
			pmp_d3 <= adc_data[3];
			pmp_d4 <= adc_data[4];
			pmp_d5 <= adc_data[5];
			pmp_d6 <= adc_data[6];
			pmp_d7 <= adc_data[7];
			pmp_drdy <= 1;
		end
	end
	else begin
		pmp_d0 <= 0;
		pmp_d1 <= 0;
		pmp_d2 <= 0;
		pmp_d3 <= 0;
		pmp_d4 <= 0;
		pmp_d5 <= 0;
		pmp_d6 <= 0;
		pmp_d7 <= 0;
		pmp_drdy <= 0;
	end
end

endmodule
