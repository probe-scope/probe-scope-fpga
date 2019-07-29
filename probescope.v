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
	
	//inout fpio0,
	//inout fpio1,
	//inout fpio2,
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
	output reg fled0,
	output reg fled1,
	output reg fled2
);

RAM_PLL ram_pll(adc_dco, mem_ck);

reg [32:0] counter;

wire [7:0] adc_data;

wire ADC_CLK;
wire decim_clk;

ADC_Aqu ADC_A(adc_dco, adc_d0a, adc_d0b, adc_d1a, adc_d1b, adc_d2a, adc_d2b, adc_d3a, adc_d3b, adc_d4a, adc_d4b, adc_d5a, adc_d5b, adc_d6a, adc_d6b, adc_d7a, adc_d7b, 8'h0, adc_data, decim_clk);
pic_simple out(.adc_data(adc_data), .decim_clk(decim_clk), .pmp_d0(pmd0), .pmp_d1(pmd1), .pmp_d2(pmd2), .pmp_d3(pmd3), .pmp_d4(pmd4), .pmp_d5(pmd5), .pmp_d6(pmd6), .pmp_d7(pmd7), .pmp_dreq(pmdc), .pmp_drdy(pmcs1));


//ADC_PLL A_PLL(adc_dco, ADC_CLK);

//ADC_FIFO ADC_F (adc_data, ADC_CLK);

always @(posedge mem_ck) begin
    counter <= counter + 1;
    if (counter > 82000000) begin
        counter <= 0;
        if (fled0) begin
            fled0 <= 0;
            fled2 <= 1;
        end
        else begin
            fled0 <= 1;
            fled2 <= 0;
        end
    end
end

always @(posedge adc_dco) begin
    if (~fpga_sw)
        fled1 <= 1;
    else
        fled1 <= 0;
end

endmodule
	