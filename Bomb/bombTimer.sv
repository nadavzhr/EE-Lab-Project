// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9  down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module bombTimer
	(
	input logic clk, 
	input logic resetN, 
	input logic loadN, 
	input logic enable1,
	input logic enable2, 

	
	output logic [3:0] count,
	output logic tc
   );

	
	
	parameter  logic [3:0] datain = 4'h3 ; 
// Down counter
always_ff @(posedge clk or negedge resetN)
   begin
	      
      if ( !resetN )	begin// Asynchronic reset
			
			count <= 4'h0000;
			
		end
				
      else if (!loadN) begin		// Synchronic logic		
				count <= datain;									
		end
			
		else if ( enable1 && enable2 ) begin

					count <= count-1;
		end //Synch
	end //always

	
	
	// Asynchronic tc
	
	assign tc = count ? 0 : 1;

	
	
endmodule
