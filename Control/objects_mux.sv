

module	objects_mux	(	
//		--------	Clock Input	 	
					input		logic	clk,
					input		logic	resetN,
					
			// win
					input		logic winner,
					input		logic win_DrawingRequest,
					input 	logic	[7:0] winRGB,
					
			// lose
					input		logic loser,
					input		logic lose_DrawingRequest,
					input 	logic	[7:0] loseRGB,
					
					
		   // player
					input		logic	playerDrawingRequest, // two set of inputs per unit
					input		logic	[7:0] playerRGB, 
					 

			  
		  ////////////////////////
		  // background 
					input    logic dynamic_bg_DrawingRequest, 
					input		logic	[7:0] dynamic_bg_RGB,
					input		logic	static_bg_DrawingRequest,
					input		logic	[7:0] static_bg_RGB, 
 
								
		  // BOMB
					input logic 	bomb_DrawingRequest,
					input logic 	[7:0] bombRGB,
					
		  // FIRE
					input logic 	fire_DrawingRequest,
					input logic 	[7:0] fireRGB,
						
		  // MINES
					input logic		landmines_1_DrawingRequest,
					input logic		landmines_2_DrawingRequest,
					input logic		[7:0] landmines_RGB,
					
		  // PIZZA
					input logic		pizza_DrawingRequest,
					input logic		[7:0] pizzaRGB,
					
		  // SEWERS
					input logic		sewer_DrawingRequest,
					input logic		[7:0] sewerRGB,

			
		 // POTION
					input logic		potion_DrawingRequest,
					input logic		[7:0] potionRGB,		
		
		
		 // POTION
					input logic		money_DrawingRequest,
					input logic		[7:0] moneyRGB,	
					
						
		  // counter (timer) 
					input		logic countH_DrawingRequest,
					input		logic	[7:0] countH_RGB,
					
					input		logic countM_DrawingRequest,
					input		logic	[7:0] countM_RGB,
					
					input		logic countL_DrawingRequest,
					input		logic	[7:0] countL_RGB,
					
			// score counter
					input		logic highScore_DrawingRequest,
					input		logic	[7:0] highScore_RGB,
					
					input		logic lowScore_DrawingRequest,
					input		logic	[7:0] lowScore_RGB,
					
					
			// life bar counter
					input		logic life_DrawingRequest,
					input		logic	[7:0] life_RGB,
					
			// MIF file
					input 	logic [7:0] RGB_MIF,
					
		  //  outputs
				   output	logic	[7:0] RGBOut
);

always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
			RGBOut	<= 8'b0;
	end
	
	else begin
	
	
		// win
		if (win_DrawingRequest == 1'b1 && winner)   
			RGBOut <= winRGB;  //first priority besides game_over screens
		
		
		
		// lose
		else if (lose_DrawingRequest == 1'b1 && loser)   
			RGBOut <= loseRGB;  //first priority besides game_over screens
	
		// player
		else if (playerDrawingRequest == 1'b1 )   
			RGBOut <= playerRGB;  //first priority besides game_over screens
		
		// static walls
		else if (static_bg_DrawingRequest == 1'b1)
				RGBOut <= static_bg_RGB;
				
				
		// flames
		else if (fire_DrawingRequest == 1'b1)
			RGBOut <= fireRGB;	
				
				
		// dynamic walls
		else if (dynamic_bg_DrawingRequest == 1'b1)
				RGBOut <= dynamic_bg_RGB ;
		

				
		// bomb
		else if (bomb_DrawingRequest == 1'b1)
			RGBOut <= bombRGB;
		

		// mine 2 
		else if (landmines_1_DrawingRequest == 1'b1 || landmines_2_DrawingRequest == 1'b1)
			RGBOut <= landmines_RGB;

	
		// pizza
		else if (pizza_DrawingRequest == 1'b1)
			RGBOut <= pizzaRGB;
			
			
		// sewer
		else if (sewer_DrawingRequest == 1'b1)
			RGBOut <= sewerRGB;
			
		// potion
		else if (potion_DrawingRequest == 1'b1)
			RGBOut <= potionRGB;
			
		// money
		else if (money_DrawingRequest == 1'b1)
			RGBOut <= moneyRGB;
	
		// timer 
		else if (countH_DrawingRequest == 1'b1 )   
			RGBOut <= countH_RGB; 
		
		else if (countM_DrawingRequest == 1'b1 )   
			RGBOut <= countM_RGB;
		
		else if (countL_DrawingRequest == 1'b1 )
			RGBOut <= countL_RGB;
		
		// score
		else if (highScore_DrawingRequest == 1'b1 )   
			RGBOut <= highScore_RGB;
		
		else if (lowScore_DrawingRequest == 1'b1 )
			RGBOut <= lowScore_RGB;
		
		// life bar
		else if (life_DrawingRequest == 1'b1 )
			RGBOut <= life_RGB;

		// background color
		else RGBOut <= RGB_MIF;
	end 
end

endmodule


