// (c) Technion IIT, Department of Electrical Engineering 2018 
// Updated by Mor Dahan - January 2022
// 
// Implements the state machine of the gameTimer mini-project
// FSM, with present and next states

module timer
	(
	input logic clk, 
	input logic resetN, 
	input logic startN,  
	input logic timerEnd,
	
	output logic countLoadN, 
	output logic countEnable, 

	output logic endCount   
   );

//-------------------------------------------------------------------------------------------

// state machine decleration 
	enum logic [2:0] {s_idle, s_run, s_Off } gameTimer_ps, gameTimer_ns;



 	
//--------------------------------------------------------------------------------------------
//  1.  syncronous code:  executed once every clock to update the current state 
always @(posedge clk or negedge resetN)
   begin
			
		if ( !resetN ) begin  // Asynchronic reset
			gameTimer_ps <= s_idle;

		end
		
		else begin		// Synchronic logic FSM
			gameTimer_ps <= gameTimer_ns;

		end	
	end // always sync
	
//--------------------------------------------------------------------------------------------
//  2.  asynchornous code: logically defining what is the next state, and the ouptput 
//      							(not seperating to two different always sections)  	
always_comb // Update next state and outputs
	begin
	// set all default values 
		gameTimer_ns = gameTimer_ps; 
		countEnable = 1'b0;
		countLoadN = 1'b1;
		endCount = 1'b0;
		
			
		case (gameTimer_ps)
		
			//Note: the implementation of the idle state is already given you as an example
			s_idle: begin

				
				if (startN == 1'b0) begin
					countLoadN = 1'b0;
					gameTimer_ns = s_run;
				end
			end // idle
						

			s_run: begin
				
				countEnable = 1'b1;
			
				
				if (timerEnd == 1'b1)
					gameTimer_ns = s_Off;		
				
			end // run
					

			
						
			s_Off: begin
					

					endCount = 1'b1;

					
			end // Off

						
						
		endcase
	end // always comb
	
endmodule
