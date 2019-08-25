module probescope (
	input wire adc_d0a,
	input wire adc_d0b,
	input wire adc_d1a,
	input wire adc_d1b,
	input wire adc_d2a,
	input wire adc_d2b,
	input wire adc_d3a,
	input wire adc_d3b,
	input wire adc_d4a,
	input wire adc_d4b,
	input wire adc_d5a,
	input wire adc_d5b,
	input wire adc_d6a,
	input wire adc_d6b,
	input wire adc_d7a,
	input wire adc_d7b,
	input wire adc_dco,
	
	//inout mem_d0,
	//inout mem_d1,
	//inout mem_d2,
	//inout mem_d3,
	//inout mem_d4,
	//inout mem_d5,
	//inout mem_d6,
	//inout mem_d7,
	//output mem_csn,
	//output mem_reset,
	//output mem_rwds,
	//output mem_psc,
	//output mem_ck,
	
	output pmd0,
	output pmd1,
	output pmd2,
	output pmd3,
	output pmd4,
	output pmd5,
	output pmd6,
	output pmd7,
	//input pmenb,
	//input pmwrn,
	input wire pmdc,
	output pmcs1,
	
	//input sck3,
	//output sdi3,
	//input sdo3,
	//input ss3n,
	
	//input fdio0,
	//output fdio1,
	
	output fpio0,
	input fpio1,
	output reg fpio2,
	//inout fpio3,
	//inout fpio4,
	
	//output fxio0,
	//output fxio1,
	//output fxio2,
	//output fxio3,
	//output fxio4,
	//output fxio5,
	//output fxio6,
	//output fxio7,
	
	//input fpga_sw,
	output reg fled0,
	output fled1,
	output fled2
);

//RAM_PLL ram_pll(adc_dco, mem_ck);

reg [32:0] counter;

reg [15:0] samples_in   = 16'h0000;
reg [15:0] samples_left = 16'hFFFF;
reg [15:0] samples_out  = 16'h0000;

wire [7:0] adc_data, good_data;

wire ADC_CLK;
wire decim_clk;
wire trig;
wire adc_dbl;

wire wren, rdinter, rden;
assign wren = (samples_left > 16'h0);
assign rden = (fpio2 & (samples_out < 16'd8192));

assign pmcs1 = 1;

reg reset_so = 0;

assign fled1 = fpio0;
assign fled2 = fpio1;
assign fpio0 = 1;

wire trash1, trash2, trash3, trash4;

ADC_PLL doubler(adc_dco, adc_dbl);
ADC_Aqu ADC_A(adc_dbl, adc_dco, adc_d0a, adc_d0b, adc_d1a, adc_d1b, adc_d2a, adc_d2b, adc_d3a, adc_d3b, adc_d4a, adc_d4b, adc_d5a, adc_d5b, adc_d6a, adc_d6b, adc_d7a, adc_d7b, 16'h0010, adc_data, decim_clk);
Sample_Data SD(adc_data, decim_clk, pmdc, wren, rden, 1'b0, 1'b0, good_data, trash1, trash2, trash3, trash4);
pic_simple out(.adc_data(good_data), .decim_clk(decim_clk), .pmp_d0(pmd0), .pmp_d1(pmd1), .pmp_d2(pmd2), .pmp_d3(pmd3), .pmp_d4(pmd4), .pmp_d5(pmd5), .pmp_d6(pmd6), .pmp_d7(pmd7), .pmp_dreq(pmdc));
Trigger trigger (decim_clk, fpio1, adc_data, 8'h0, trig);


always @(posedge adc_dbl) begin
    counter <= counter + 1;
    if (counter > 125000000) begin
        counter <= 0;
        if (fled0) begin
            fled0 <= 0;
        end
        else begin
            fled0 <= 1;
        end
    end
end

always @(posedge decim_clk) begin
	// readout sequence:
	// a. At startup: samples_left is 8192 (the size of the buffer) and samples_in and samples_out are both 0. trig should be 0.
	// b. The FIFO fills up with samples continuously, triggers are ignored. Each incoming sample increases samples_in by 1 until it reaches 4096.
	// c. samples_in reaches 4096 (half the FIFO), enabling triggering.
	// d. A trigger condition occurs and trig is set to 1 briefly. Samples_left is set to 4096 (half the FIFO).
	// e. The FIFO recieves more samples, decrementing samples_left by 1 each time.
	// f. samples_left reaches 0. samples_out is set to 0. FIFO writing is disabled, FPIO2 goes high to indicate the buffer is triggered and full, and FIFO reading is enabled.
	// g. The PIC begins clocking samples out of the FIFO. Each samples it clocks out increases samples_out by 1 until 8192.
	// h. samples_out reaches 8192. FIFO reading is disabled. FPIO2 goes low. samples_in is set to 0, samples_left is set to 0xFFFF, samples_out is set to 0. FIFO writing is enabled. Return to step b.
	
	if (fpio0)
		if ((samples_left == 16'hFFFF) & (samples_in >= 16'd4096)) begin
			samples_left = 16'd4096;
		end
	
	if (samples_left < 16'hFFFF)
		if (samples_left > 16'h0)
			samples_left = samples_left - 16'd1;
	if (samples_in < 16'd4096)
		samples_in = samples_in + 16'd1;
	
	if (samples_left == 16'h0) begin
		if (samples_out >= 16'd8192) begin
			samples_left = 16'hFFFF;
			samples_in   = 16'd0;
			reset_so = 1;
			fpio2 = 0;
		end
		else begin
			reset_so = 0;
			fpio2 = 1;
		end
	end
	else
		fpio2 = 0;
end
	
always @(posedge pmdc or posedge reset_so) begin
	if (~reset_so)
		samples_out = samples_out + 16'd1;
	else
		samples_out = 16'd0;
end

endmodule
	