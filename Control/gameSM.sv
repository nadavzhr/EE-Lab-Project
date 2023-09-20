

module gameSM	
 ( 
	input	logic  clk,
	input	logic  resetN, 
	input logic GameStart_key,
	input	logic SingleHitPulse_player_flames,
	input	logic collision_player_pizza,
	input	logic OneSecPulse, 	// countdown
	input logic time_end,
	input logic life_over,
	
	output logic loser_st	,
	output logic winner_st,
	output logic game_over

  ) ;

enum logic [2:0] {start_s, game_s, loser_s, winner_s} pres_st, next_st; //State Machine Declaration
logic timer_ns, timer_ps;

always_ff @(posedge clk or negedge resetN)
begin //	fsm_sync_proc

	if (!resetN) begin 
		timer_ps <= 1'b0; 
		pres_st <= start_s ; 
	end 	
	else begin 
		timer_ps <= timer_ns;
		pres_st <= next_st ;
	end ; 
end // end fsm_sync_proc
  
always_comb 
begin
//Defaults
	timer_ns = timer_ps;
	next_st =pres_st;
	loser_st=1'b0;
	winner_st=1'b0;
	game_over=1'b0;
		
	case(pres_st)
		start_s: begin // start screen
//---------------
			timer_ns= 1'b0;
			if(GameStart_key) 
				next_st = game_s;
		end 

		game_s: begin // give starting postion and speed
//---------------	
			if(collision_player_pizza)	// win condition
				next_st=winner_s;
			else if(SingleHitPulse_player_flames || time_end || life_over)	// lose condition
				next_st=loser_s;
		end 
		
		winner_s: begin 
//---------------
			winner_st = 1'b1;
			if(OneSecPulse == 1'b1)
				timer_ns=timer_ps + 1'b1;
			if(timer_ps== 1'b1)			
				game_over=1'b1;
		end  
				
		loser_s: begin 
//---------------		
			loser_st =1'b1;
			if(OneSecPulse == 1'b1)
				timer_ns=timer_ps + 1'b1;
			if(timer_ps== 1'b1)			
				game_over=1'b1;
		end
		
	endcase  
end 

endmodule

