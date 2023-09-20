// (c) Technion IIT, Department of Electrical Engineering 2022 
// Updated by Mor Dahan - January 2022

// Implements a 4 bits down counter 9  down to 0 with several enable inputs and loadN data.
// It outputs count and asynchronous terminal count, tc, signal 

module lives_counter
	(
	input logic clk, 
	input logic resetN, 
	input logic hpLoss_trigger, 
	input logic oneSecPulse,
	input logic end_life,
	input logic LifeBonus,
	
	output logic [3:0] count,
	output logic life_over
   );



logic life_flag;
logic enable_counter;
logic reset_flag;



	// after a collision - start counting 1 sec before decrementing 1HP again
	one_sec_counter hp_d_counter (
											.clk(clk),
											.resetN(!enable_counter),
											.one_sec(reset_flag)
											);



always_ff @(posedge clk or negedge resetN)
   begin
	      
	
			
			
      if ( !resetN )	begin// Asynchronic reset
			
			count <= 4'h2; // WILL CHANGE TO THE AMOUNT OF LIVES AT THE BEGINNING
			life_flag <= 1'b0;
			enable_counter <= 1'b0; // default value

			
		end
			
		else begin
			enable_counter <= 1'b0; // default value
			if (end_life && life_flag == 1'b0 ) begin 
					life_flag <= 1'b1;
					count<=0;
			end
				
			if (LifeBonus && life_flag == 1'b0 ) begin 
					life_flag <= 1'b1;
					count<=count+1;
			end
			
			if ( hpLoss_trigger && count >= 4'h1 && life_flag == 1'b0 ) begin 
		
					count <= count-1;
					life_flag <= 1'b1;
					enable_counter <= 1'b1;
				
			end //  decrement hp
		
		
			if (reset_flag == 1'b1) begin
			life_flag <= 1'b0;
			end
			
		end
		
end //always

	
	
	// Asynchronic tc
	
	assign life_over = count ? 0 : 1;

	
	
endmodule
