

module	player_move	(	
 
					input	logic	clk,
					input	logic	resetN,
					input	logic	startOfFrame,  // short pulse every start of frame 30Hz 
					input	logic	key_up,    
					input	logic	key_down,
					input	logic	key_left,
					input	logic	key_right,
					input logic collision,  //collision if smiley hits an object
					input	logic	[3:0] HitEdgeCode, //one bit per edge
					input logic col_player_sewer,
					input logic star,
					input logic GameOver,

					output	 logic signed 	[10:0]	topLeftX, // output the top left corner 
					output	 logic signed	[10:0]	topLeftY  // can be negative , if the object is partliy outside 
					
);


// a module used to generate the  ball trajectory.  

parameter int INITIAL_X = 280;
parameter int INITIAL_Y = 185;
parameter int INITIAL_X_SPEED = 40;
parameter int INITIAL_Y_SPEED = 20;
const int	FIXED_POINT_MULTIPLIER	=	64; // note it must be 2^n 
// FIXED_POINT_MULTIPLIER is used to enable working with integers in high resolution so that 
// we do all calculations with topLeftX_FixedPoint to get a resolution of 1/64 pixel in calcuatuions,
// we devide at the end by FIXED_POINT_MULTIPLIER which must be 2^n, to return to the initial proportions


// movement limits 
const int   OBJECT_WIDTH_X = 32;
const int   OBJECT_HIGHT_Y = 32;
const int	SafetyMargin_LT =	33;
const int	SafetyMargin_R =	90;
const int	SafetyMargin_B =	33;

const int	x_FRAME_LEFT	=	(SafetyMargin_LT)* FIXED_POINT_MULTIPLIER; 
const int	x_FRAME_RIGHT	=	(639 -SafetyMargin_R - OBJECT_WIDTH_X)* FIXED_POINT_MULTIPLIER; 
const int	y_FRAME_TOP		=	(SafetyMargin_LT) * FIXED_POINT_MULTIPLIER;
const int	y_FRAME_BOTTOM	=	(479 -SafetyMargin_B - OBJECT_HIGHT_Y ) * FIXED_POINT_MULTIPLIER; //- OBJECT_HIGHT_Y

enum  logic [2:0] {IDLE_ST, // initial state
					MOVE_ST, // moving no colision
					TELEPORT_ST,
					WAIT_FOR_EOF_ST, // change speed done, wait for startOfFrame  
					POSITION_CHANGE_ST,// position interpolate 
					POSITION_LIMITS_ST //check if inside the frame  
					}  SM_PS, 
						SM_NS ;

 int Xspeed_PS,  Xspeed_NS  ; // speed    
 int Yspeed_PS,  Yspeed_NS  ; 
 int Xposition_PS, Xposition_NS ; //position   
 int Yposition_PS, Yposition_NS ;  

 //---------
 
 always_ff @(posedge clk or negedge resetN)
		begin : fsm_sync_proc
			if (resetN == 1'b0) begin 
				SM_PS <= IDLE_ST ; 
				Xspeed_PS <= 0   ; 
				Yspeed_PS <= 0  ; 
				Xposition_PS <= 0  ; 
				Yposition_PS <= 0   ; 
	
			
			end 	
			else begin 
				SM_PS  <= SM_NS ;
				Xspeed_PS   <= Xspeed_NS    ; 
				Yspeed_PS    <=   Yspeed_NS  ; 
				Xposition_PS <=  Xposition_NS    ; 
				Yposition_PS <=  Yposition_NS    ; 

			end ; 
		end // end fsm_sync

 
 ///-----------------
 
 
always_comb 
begin
	// set default values 
		 SM_NS = SM_PS  ;
		 Xspeed_NS  = Xspeed_PS ; 
		 Yspeed_NS  = Yspeed_PS  ; 
		 Xposition_NS =  Xposition_PS ; 
		 Yposition_NS  = Yposition_PS  ; 
	 	

	case(SM_PS)
//------------
		IDLE_ST: begin
//------------
		 Xspeed_NS  = INITIAL_X_SPEED ; 
		 Yspeed_NS  = INITIAL_Y_SPEED  ; 
		 Xposition_NS = INITIAL_X * FIXED_POINT_MULTIPLIER; 
		 Yposition_NS = INITIAL_Y * FIXED_POINT_MULTIPLIER; 

		 if (startOfFrame) 
				SM_NS = MOVE_ST ;
 	
	end
	
//------------
		MOVE_ST:  begin     // moving no colision 
//------------		
			Xspeed_NS  = 0; 
			Yspeed_NS  = 0; 
	
			if (key_up && !GameOver)
					Yspeed_NS=-INITIAL_Y_SPEED;
			if (key_down && !GameOver)
					Yspeed_NS =INITIAL_Y_SPEED; 
			if(key_right && !GameOver)
					Xspeed_NS = INITIAL_X_SPEED;
			if(key_left && !GameOver)
					Xspeed_NS = -INITIAL_X_SPEED;

			if (collision) begin  //any collision was detected 
				
					if (HitEdgeCode [2] == 1)  // hit top border of brick  
						if (key_up) // while moving up
								Yspeed_NS = 0 ; 
					
					if ( HitEdgeCode [0] == 1)// hit bottom border of brick  
						if (key_down)//  while moving down
								Yspeed_NS = 0 ; 
		
					 if (HitEdgeCode [3] == 1)   
						if (key_left) // while moving left
								Xspeed_NS = 0 ; // positive move right 
									
					if ( HitEdgeCode [1] == 1)   // hit right border of brick  
							if (key_right) //  while moving right
									Xspeed_NS = 0 ;  // negative move left   
								
					SM_NS = WAIT_FOR_EOF_ST ; 
				end 	
				
			// teleport through the sewers
			if ( col_player_sewer && star && !GameOver ) begin		
				SM_NS = TELEPORT_ST;
			end	
				
				
			if (startOfFrame) 
						SM_NS = POSITION_CHANGE_ST ; 
		end 
		
		
//--------------------
		TELEPORT_ST: begin
		
			if ( col_player_sewer && !star ) begin
			
			
				if ((topLeftX >= 32) && (topLeftX <= 64) && (topLeftY >= 400) && (topLeftY <= 448))	// bottom-left sewer
				begin
					 // teleport - values accounted for x64 factor
					 Xposition_NS = 30720;	// 480x64
					 Yposition_NS = 2048;	// 32x64
				end
				
				else if ((topLeftX >= 480) && (topLeftX <= 512) && (topLeftY >= 32) && (topLeftY <= 64))	// top-right sewer
				begin
					 // teleport - values accounted for x64 factor
					 Xposition_NS = 2048;	// 32x64
					 Yposition_NS = 28672;	// 448x64
				end
				
				SM_NS = MOVE_ST;
			end	


		
		end
//--------------------		
		
				
//--------------------
		WAIT_FOR_EOF_ST: begin  // change speed already done once, now wait for EOF 
//--------------------
									
			if (startOfFrame) 
				SM_NS = POSITION_CHANGE_ST ; 
		end 

//------------------------
 		POSITION_CHANGE_ST : begin  // position interpolate 
//------------------------
	
			 Xposition_NS =  Xposition_PS + Xspeed_PS; 
			 Yposition_NS  = Yposition_PS + Yspeed_PS ;
			 

			 SM_NS = POSITION_LIMITS_ST ; 
		end
		
		
//------------------------
		POSITION_LIMITS_ST : begin  //check if still inside the frame 
//------------------------
		
		
				 if (Xposition_PS < x_FRAME_LEFT ) begin  
							Xposition_NS = x_FRAME_LEFT; 
							if (key_left ) // moving to the left 
									Xspeed_NS = 0 ; // change direction 
				end 
	
				if (Xposition_PS > x_FRAME_RIGHT) begin 
							Xposition_NS = x_FRAME_RIGHT; 
							if (key_right ) // moving to the right 
									Xspeed_NS = 0 ; // change direction 
				end
							
				if (Yposition_PS < y_FRAME_TOP ) begin  
							Yposition_NS = y_FRAME_TOP; 
							if (key_up ) // moving to the top 
									Yspeed_NS = 0 ; // change direction 
				end 
	
				if (Yposition_PS > y_FRAME_BOTTOM) begin  
							Yposition_NS = y_FRAME_BOTTOM; 
							if ( key_down ) // moving to the bottom 
									Yspeed_NS = 0 ; // change direction 
				end

			SM_NS = MOVE_ST ; 
			
		end
		
endcase  // case 
end		
//return from FIXED point  trunc back to prame size parameters 
  
assign 	topLeftX = Xposition_PS / FIXED_POINT_MULTIPLIER ;   // note it must be 2^n 
assign 	topLeftY = Yposition_PS / FIXED_POINT_MULTIPLIER ;    

	

endmodule	
//---------------
 
