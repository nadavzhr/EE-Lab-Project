

module	game_controller	(	
			input	logic	clk,
			input	logic	resetN,
			input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
			input	logic	drawing_request_player,
			input	logic	drawing_request_static_walls,
			input logic drawing_request_dynamic_walls,
			input logic drawing_request_mine1,
			input logic drawing_request_mine2,
			input logic drawing_request_flames,
			input logic drawing_request_pizza,
			input logic drawing_request_sewer,
			input logic drawing_request_potion,
			input logic drawing_request_money,

	

			
			output logic player_anywall_collision, 		//  PLAYER-WALL COLLISION
			
			
			
			output logic collision_player_static_walls,
			output logic collision_player_dynamic_walls,
			output logic collision_player_flames,
			output logic collision_player_mine1,
			output logic collision_player_mine2,
			output logic collision_player_pizza,
			output logic collision_player_sewer,
			output logic collision_player_potion,
			output logic collision_player_money,
			
			output logic collision_flames_dynamic_walls,
			output logic collision_flames_mine1,
			output logic collision_flames_mine2,
			
			
			// critical code, generating A single pulse in a frame
			
			output logic SingleHitPulseLandmine,  
			output logic SingleHitPulseWall,
			output logic SingleHitPulse_player_flames,
			output logic SingleHitPulsePotion,
			output logic SingleHitPulseMoney
			
);
		
		
		
always_comb
begin

		// PLAYER - OBJECT COLLISIONS
		collision_player_static_walls = drawing_request_player && drawing_request_static_walls;
		collision_player_dynamic_walls = drawing_request_player && drawing_request_dynamic_walls;
		collision_player_flames = drawing_request_player && drawing_request_flames;
		collision_player_mine1 = drawing_request_player && drawing_request_mine1;
		collision_player_mine2 = drawing_request_player && drawing_request_mine2;
		collision_player_pizza = drawing_request_player && drawing_request_pizza;
		collision_player_sewer = drawing_request_player && drawing_request_sewer;
		collision_player_potion = drawing_request_player && drawing_request_potion;
		collision_player_money = drawing_request_player && drawing_request_money;

		// FLAMES COLLISIONS
		collision_flames_dynamic_walls = drawing_request_flames && drawing_request_dynamic_walls;
		collision_flames_mine1 = drawing_request_flames && drawing_request_mine1;
		collision_flames_mine2 = drawing_request_flames && drawing_request_mine2;


		player_anywall_collision = ( collision_player_static_walls || collision_player_dynamic_walls);

end
		


logic flag_landmine ; // a semaphore to set the output only once per frame / regardless of the number of collisions 
logic flag_wall;
logic flag_player_flames;
logic flag_potion;
logic flag_money;

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN)
	begin 
		flag_landmine	<= 1'b0;
		flag_wall<=1'b0;
		flag_player_flames <= 1'b0;
		flag_potion <= 1'b0;
		flag_money <= 1'b0;
		
		SingleHitPulseLandmine <= 1'b0 ; 
		SingleHitPulseWall <= 1'b0;
		SingleHitPulse_player_flames <= 1'b0 ; 
		SingleHitPulsePotion <= 1'b0;
		SingleHitPulseMoney <=1'b0;
	end 
	
	else begin 

			SingleHitPulseLandmine <= 1'b0 ; // default 
			SingleHitPulseWall<=1'b0;
			SingleHitPulse_player_flames <= 1'b0 ; 
			SingleHitPulsePotion <= 1'b0;
			SingleHitPulseMoney <=1'b0;
			
			if(startOfFrame) 
				flag_landmine <= 1'b0 ; // reset for next time 
				flag_wall <=1'b0;
				flag_player_flames <= 1'b0;
				flag_potion <= 1'b0;
				flag_money <= 1'b0;				


			
			if ( (collision_flames_mine1 || collision_flames_mine2) && (flag_landmine == 1'b0)) begin 
					flag_landmine	<= 1'b1; // to enter only once 
					SingleHitPulseLandmine <= 1'b1 ; 
			end 
		
			if ( collision_flames_dynamic_walls && (flag_wall == 1'b0))
				begin 
					flag_wall	<= 1'b1; // to enter only once 
					SingleHitPulseWall <= 1'b1 ; 
				end
				
			if (collision_player_flames && (flag_player_flames == 1'b0))
				begin 
					flag_player_flames	<= 1'b1; // to enter only once 
					SingleHitPulse_player_flames <= 1'b1 ; 
				end		 
		
			if (collision_player_potion && (flag_potion == 1'b0))
				begin 
					flag_potion	<= 1'b1; // to enter only once 
					SingleHitPulsePotion <= 1'b1 ; 
				end	
			if (collision_player_money && (flag_money == 1'b0))
				begin 
					flag_money	<= 1'b1; // to enter only once 
					SingleHitPulseMoney <= 1'b1 ; 
				end
	end
	
	
end

endmodule
