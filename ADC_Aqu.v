module ADC_Aqu (
	input adc_dco,
	      adc_d0a,
	      adc_d0b,
	      adc_d1a,
	      adc_d1b,
	      adc_d2a,
	      adc_d2b,
	      adc_d3a,
	      adc_d3b,
	      adc_d4a,
	      adc_d4b,
	      adc_d5a,
	      adc_d5b,
	      adc_d6a,
	      adc_d6b,
	      adc_d7a,
	      adc_d7b,
    input [15:0] decimation,
	output reg [7:0] adc_data,
	output reg decim_clk = 1'b1
);

reg [32:0] counter;
reg [7:0] dc;

always @(adc_dco) begin
	counter <= counter + 1;
	if (counter > decimation) begin
			counter <= 0;
			//adc_data[0] <= adc_dco ? adc_d0a : adc_d0b;
			//adc_data[1] <= adc_dco ? adc_d1a : adc_d1b;
			//adc_data[2] <= adc_dco ? adc_d2a : adc_d2b;
			//adc_data[3] <= adc_dco ? adc_d3a : adc_d3b;
			//adc_data[4] <= adc_dco ? adc_d4a : adc_d4b;
			//adc_data[5] <= adc_dco ? adc_d5a : adc_d5b;
			//adc_data[6] <= adc_dco ? adc_d6a : adc_d6b;
			//adc_data[7] <= adc_dco ? adc_d7a : adc_d7b;
			decim_clk <= 0;
			adc_data[0] <= dc[0];
			adc_data[1] <= dc[1];
			adc_data[2] <= dc[2];
			adc_data[3] <= dc[3];
			adc_data[4] <= dc[4];
			adc_data[5] <= dc[5];
			adc_data[6] <= dc[6];
			adc_data[7] <= dc[7];
			decim_clk <= 1;
			dc <= dc + 1;
	end
	else decim_clk <= 0;
end

endmodule
