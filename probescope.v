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
	output mem_ck,
	
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
	
	output reg fpio0,
	input fpio1,
	output fpio2,
	//inout fpio3,
	//inout fpio4,
	
	//inout fxio0,
	//inout fxio1,
	//inout fxio2,
	//inout fxio3,
	//inout fxio4,
	//inout fxio5,
	//inout fxio6,
	//inout fxio7,
	
	input fpga_sw,
	output fled0,
	output fled1,
	output fled2
);

//RAM_PLL ram_pll(adc_dco, mem_ck);

reg [31:0] counter = 32'b0;

wire [7:0] adc_data;
wire [7:0] fifo_out;

reg [15:0] trig_ctr = 16'b0;

wire ADC_CLK;
wire decim_clk;
wire trig;
reg trig_i = 1'b0, triggered = 1'b0, ready = 1'b0, trig_s = 1'b0;
wire pic_rdck, fifo_empty, fifo_ae, fifo_af, fifo_full;
reg fifo_wren = 1'b1, fifo_rden = 1'b0, fifo_reset = 1'b1, fifo_rdck = 1'b0;

assign fpio2 =  fifo_rden;
assign fled0 =  fifo_wren;
assign fled1 =  fifo_empty;
assign fled2 =  fifo_rden;

localparam decim_factor = 16'hFFFF;

ADC_Aqu ADC_A(adc_dco, adc_d0a, adc_d0b, adc_d1a, adc_d1b, adc_d2a, adc_d2b, adc_d3a, adc_d3b, adc_d4a, adc_d4b, adc_d5a, adc_d5b, adc_d6a, adc_d6b, adc_d7a, adc_d7b, decim_factor, adc_data, decim_clk);
pic_simple out(fifo_out, pic_rdck, fifo_rden, pmd0, pmd1, pmd2, pmd3, pmd4, pmd5, pmd6, pmd7, pmdc, pmcs1, adc_dco);
Trigger trigger (decim_clk, 1'b0, adc_data, 8'sh0, trig);


//ADC_PLL A_PLL(adc_dco, ADC_CLK);

alt_fifo ADC_F (adc_data, decim_clk, fifo_rdck, fifo_wren, fifo_rden, fifo_reset, 1'b0, fifo_out, fifo_empty, fifo_full, fifo_ae, fifo_af);

/*
always @(negedge decim_clk) begin
	counter <= counter + 1;
	if (counter > (62500000/decim_factor)) begin
		counter <= 0;
		if (fled2) begin
			fled2 <= 0;
		end
		else begin
			fled2 <= 1;
		end
	end
end
*/

always @(posedge adc_dco) begin	
	if (~fpga_sw) begin
		fpio0 <= 1;
	end
    else begin
		fpio0 <= trig;
	end
	
	if (trig_i) begin
		trig_ctr <= 0;
		triggered <= 1;
	end
	
	if (pic_rdck)
		fifo_rdck <= 1;
	else
		fifo_rdck <= 0;
	
	if (fifo_rden) begin
		if (fifo_empty | ~fpio1) begin
			fifo_rden <= 0;
			fifo_wren <= 1;
		end
	end
	
	if (triggered) begin
		trig_ctr <= trig_ctr + 1;
		if (trig_ctr >= 16'd4096) begin
			if (fpio1) begin // pic ready to receive
				fifo_wren <= 0;
				fifo_rden <= 1;
				fifo_rdck <= 1;
			end
			
			trig_ctr <= 0;
			triggered <= 0;
		end
	end
	
	fifo_reset <= 0;
end

always @(negedge adc_dco) begin
	if (~fpga_sw)
		if (~trig_s) begin
			trig_i <= 1;
			trig_s <= 1;
		end
	else
		trig_s <= 0;
	if (trig)
		trig_i <= 1;
	if (triggered)
		trig_i <= 0;
end

endmodule
	