// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9  down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module down_counter
	(
	input logic clk, 
	input logic resetN, 
	input logic loadN, 
	input logic enable1,
	input logic enable2, 
	input logic enable3, 
	input logic [3:0] datain,
	
	output logic [3:0] count,
	output logic tc
   );

// Down counter
always_ff @(posedge clk or negedge resetN)
   begin
	      
      if ( !resetN )	begin// Asynchronic reset
			
			count <= 4'h0000;
			
		end
				
      else if (!loadN) begin		// Synchronic logic	// MAYBE DATAIN = +3	
				count <= datain;									// INCASE OF A SUCCESSFUL EXPLOSION COUNT <= COUNT + DATAIN
		end
			
		else if ( enable1 && enable2 && enable3 ) begin
			
				if (count == 4'b0000) begin
					count <= 4'h9;				// WE WILL WANT TO END THE GAME AND NOT LOOP OVER - WILL CHANGE
				end
				
				else begin
					count <= count-1;
				end
				
		end //Synch
	end //always

	
	
	// Asynchronic tc
	
	assign tc = count ? 0 : 1;

	
	
endmodule
