// (c) Technion IIT, Department of Electrical Engineering 2020 

// Implements a slow clock as an one-second counter
// Turbo input sets output 10 times faster
// Updated by Mor Dahan - January 2022

 
 module one_sec_counter      	
	(
   // Input, Output Ports
	input  logic clk, 
	input  logic resetN,
	output logic one_sec
   );
	
	int oneSecCount ;
	int sec ;		 

 
	
//       ----------------------------------------------	
	localparam oneSecVal = 26'd31_500_000; // for DE10 board un-comment this line 
//	localparam oneSecVal = 26'd20; // for quartus simulation un-comment this line 
//       ----------------------------------------------	
	
	assign  sec = oneSecVal; 


	
   always_ff @( posedge clk or negedge resetN )
   begin
	
		// asynchronous reset
		if ( !resetN ) begin
			one_sec <= 1'b0;
			oneSecCount <= 26'd0;
		end // if reset
		
		// executed once every clock 	
		else begin
			if (oneSecCount >= sec) begin
				one_sec <= 1'b1;
				oneSecCount <= 0;
			end
			else begin
				oneSecCount <= oneSecCount + 1;
				one_sec		<= 1'b0;
			end
		end // else clk
		
	end // always
endmodule