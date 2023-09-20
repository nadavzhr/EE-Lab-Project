// (c) Technion IIT, Department of Electrical Engineering 2018 
// Updated by Mor Dahan - January 2022
// 
// Implements the state machine of the bomb mini-project
// FSM, with present and next states

module bomb
	(
	input logic clk, 
	input logic resetN, 
	input logic enter, 		// trigger for displaying the bomb
	input logic [10:0] offsetX,
	input logic [10:0] offsetY,
	
 
	input logic OneSecPulse, 	// countdown
	input logic timerEnd,		// for exploding
	
	output logic countLoadN, 
	output logic countEnable, 


	output logic signed [10:0] bombX,
	output logic signed [10:0] bombY,
	
	output logic bomb_DrawReq,
	output logic flames_DrawReq,
	
	// used to enable the destruction of only ONE layer of walls
	output logic enable_wall_destruct
   );
	
	
//-------------------------------------------------------------------------------------------

// state machine decleration 
	enum logic [2:0] {s_idle, s_arm, s_display, s_wait, s_explode} bomb_ps, bomb_ns;	// bomb's states
	logic timer_ns, timer_ps; // For the bomb's delay before exploding
	

	int bombX_PS, bombX_NS;
	int bombY_PS, bombY_NS;



 	
//--------------------------------------------------------------------------------------------
//  1.  syncronous code:  executed once every clock to update the current state 
always @(posedge clk or negedge resetN)
   begin
			
		if ( !resetN ) begin  // Asynchronic reset
			bomb_ps <= s_idle;
			timer_ps <= 2'b0; 
			bombX_PS <= 0;
			bombY_PS <= 0;
		end
		
		else begin		// Synchronic logic FSM
			bomb_ps <= bomb_ns;
			timer_ps <= timer_ns; 
			bombX_PS <= bombX_NS;
			bombY_PS <= bombY_NS;
			
		end	
	end // always sync
	
//--------------------------------------------------------------------------------------------
//  2.  asynchornous code: logically defining what is the next state, and the ouptput 
//      							(not seperating to two different always sections)  	
always_comb // Update next state and outputs
	begin
	// set all default values 
		bomb_ns = bomb_ps; 
		timer_ns = timer_ps;
		bombX_NS = bombX_PS;
		bombY_NS = bombY_PS;
		countEnable = 1'b0;
		countLoadN = 1'b1;
		bomb_DrawReq = 1'b0;
		flames_DrawReq = 1'b0;
		enable_wall_destruct = 1'b0;
		
		/**  IDLE - ENTER NOT PRESSED, DISPLAY - SHOW BOMB AT CURRENT LOCATION, WAIT - 3 SECONDS, EXPLODE - BOOM  **/
		
		
		case (bomb_ps)
		
			//Note: the implementation of the idle state is already given you as an example
			s_idle: begin
			
				timer_ns= 1'b0;
				if (enter == 1'b1) // enter is pressed
					bomb_ns = s_arm; 
				end // idle
						
			s_arm: begin
				
				countLoadN = 1'b0;
				
				if (enter == 1'b0)	// enter is released
					bomb_ns = s_display;
					
				end // arm
						
			s_display: begin
				
				// draw the bomb at the player's current location
				bomb_DrawReq = 1'b1;	
				bombX_NS = offsetX + 11'h16;	// center of player block
				bombY_NS = offsetY + 11'h16;	// center of player block
				bomb_ns = s_wait;
				
			end // display

			
			// wait for 3 seconds
			s_wait: begin
				
					countEnable = 1'b1;	// start counting down
				
					bomb_DrawReq = 1'b1;	// bomb is still displayed
					
					if (timerEnd == 1'b1)
						bomb_ns = s_explode;
						
				
			end // wait
			
			
			s_explode: begin
					
					flames_DrawReq = 1'b1;
					
					if(OneSecPulse == 1'b1)
						timer_ns=timer_ps + 1'b1;
					
					if(timer_ps== 1'b1) begin
						enable_wall_destruct = 1'b1;		// enable the destruction of only ONE layer of walls
						bomb_ns = s_idle;
					end
					
			end // explode
				
		
		endcase
	end // always comb

assign bombX = {bombX_PS[10:5], 5'b00000};	// center of block
assign bombY = {bombY_PS[10:5], 5'b00000};	// center of block
endmodule
