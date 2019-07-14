module probescope (
	//input adc_d0a,
	//input adc_d0b,
	//input adc_d1a,
	//input adc_d1b,
	//input adc_d2a,
	//input adc_d2b,
	//input adc_d3a,
	//input adc_d3b,
	//input adc_d4a,
	//input adc_d4b,
	//input adc_d5a,
	//input adc_d5b,
	//input adc_d6a,
	//input adc_d6b,
	//input adc_d7a,
	//input adc_d7b,
	input adc_dco,
	
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
	
	//output pmd0,
	//output pmd1,
	//output pmd2,
	//output pmd3,
	//output pmd4,
	//output pmd5,
	//output pmd6,
	//output pmd7,
	//input pmenb,
	//input pmwrn,
	//input pmdc,
	//input pmcs1,
	
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
	