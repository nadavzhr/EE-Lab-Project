

module sounds_mux

		(
		input logic clk,
		input logic resetN,
		
		// damage inflicted sound
		input logic player_flames_col,
		input logic player_mine1_col,
		input logic player_mine2_col,
		
		// explosion sound
		input logic flames_draw_req,
		
		// potion sound
		input logic player_potion_col,
		
		// money sound
		input logic player_money_col,
		
		
		// victory sound
		input logic player_pizza_col, 
		
		output logic [3:0] freq,
		output logic enable_sound
		);
		
		
logic sound_time_flag;
logic enable_counter;
logic oneSec;


one_sec_counter sound_time_counter (
									.clk(clk),
									.resetN(!enable_counter),
									.one_sec(oneSec)
										);


		
always_ff @( posedge clk or negedge resetN )
begin
      
      if ( !resetN ) begin // Asynchronic reset
			freq	<= 4'h0;
			enable_sound <= 1'b0;
			
			sound_time_flag <= 1'b0;	// default value and the starting value once game starts - counter starts counting right ahead
			enable_counter <= 1'b0;
		end
		
      else 	begin	// posedge clk
		
			enable_counter <= 1'b0;
			
			// damage sound - -1 life
			if ( ( player_flames_col || player_mine1_col || player_mine2_col ) && sound_time_flag == 1'b0 ) begin
				freq <= 4'h7;
				enable_sound <= 1'b1;
				sound_time_flag <= 1'b1; // raise flag
				enable_counter <= 1'b1;	// reset the oneSecCounter and start counting
			end
			
			
			
			
			// flames sound
			else if ( flames_draw_req && sound_time_flag == 1'b0 ) begin
				freq <= 4'h6;
				enable_sound <= 1'b1;
				sound_time_flag <= 1'b1; // raise flag
				enable_counter <= 1'b1;	// reset the oneSecCounter and start counting
			end
			
			
			
			// potion sound
			else if ( player_potion_col && sound_time_flag == 1'b0 ) begin
				freq <= 4'h3;
				enable_sound <= 1'b1;
				sound_time_flag <= 1'b1; // raise flag
				enable_counter <= 1'b1;	// reset the oneSecCounter and start counting
			end
			
			
			// money sound
			else if ( player_money_col && sound_time_flag == 1'b0 ) begin
				freq <= 4'h2;
				enable_sound <= 1'b1;
				sound_time_flag <= 1'b1; // raise flag
				enable_counter <= 1'b1;	// reset the oneSecCounter and start counting
			end
			
			
			// victory sound
			else if ( player_pizza_col && sound_time_flag == 1'b0 ) begin
				freq <= 4'h1;
				enable_sound <= 1'b1;
				sound_time_flag <= 1'b1; // raise flag
				enable_counter <= 1'b1;	// reset the oneSecCounter and start counting
			end
			
			
			
			
			else begin // check for the passing of 1 second and disable sound and flag
			 	
				
				if ( sound_time_flag == 1'b1 && oneSec ) begin
					sound_time_flag <= 1'b0;	// lower flag
					enable_sound <= 1'b0;	// disable sound after 1 second has passed
				end

			end
			
			
		end // posedge clk
    
	 end // always
	 
endmodule
