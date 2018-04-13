module PCM(
	input CLK_68KCLKB,
	input nSDROE, SDRMPX,
	input nSDPOE, SDPMPX,
	inout [7:0] SDRAD,
	input [9:8] SDRA_L,
	input [23:20] SDRA_U,
	inout [7:0] SDPAD,
	input [11:8] SDPA,
	input [7:0] D,
	output [23:0] A
	);

	reg [1:0] COUNT;
	reg [7:0] RDLATCH;
	reg [7:0] PDLATCH;
	reg [23:0] RALATCH;
	reg [23:0] PALATCH;
	
	assign nSDRMPX = ~SDRMPX;
	assign nSDPMPX = ~SDPMPX;
	assign SDPOE = ~nSDPOE;
	assign CEN = ~COUNT[1];
	
	always @(posedge CLK_68KCLKB or negedge nSDPOE)
	begin
		if (!nSDPOE)
			COUNT <= 0;
		else
			if (CEN) COUNT <= COUNT + 1'b1;
	end
	
	assign SDRAD = nSDROE ? 8'bzzzzzzzz : RDLATCH;
	always @(*)
		if (COUNT[1]) RDLATCH <= D;
	
	assign SDPAD = nSDPOE ? 8'bzzzzzzzz : PDLATCH;
	always @(*)
		if (!nSDPOE) PDLATCH <= D;
	
	assign A = nSDPOE ? RALATCH : PALATCH;
	
	always @(posedge nSDRMPX)
	begin
		RALATCH[7:0] <= SDRAD[7:0];
		RALATCH[9:8] <= SDRA_L[9:8];
	end
	always @(posedge SDRMPX)
	begin
		RALATCH[17:10] <= SDRAD[7:0];
		RALATCH[23:18] <= {SDRA_U[23:20], SDRA_L[9:8]};
	end
	
	always @(posedge nSDPMPX)
	begin
		PALATCH[7:0] <= SDPAD[7:0];
		PALATCH[11:8] <= SDPA[11:8];
	end
	always @(posedge SDPMPX)
	begin
		PALATCH[19:12] <= SDPAD[7:0];
		PALATCH[23:20] <= SDPA[11:8];
	end

endmodule

