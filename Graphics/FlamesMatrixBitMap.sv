// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Apr  2023  
// (c) Technion IIT, Department of Electrical Engineering 2023 



module	FlamesMatrixBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] OffsetX,
					input logic	[10:0] OffsetY,
					input logic	[10:0] BombX,// offset from top left  position 
					input logic	[10:0] BombY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 
					input logic random_flame,
					input logic Fire_on,

					input logic collision_landmines_1,
					input logic collision_landmines_2,
					input logic OneSecPulse, 	// countdown
					
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 

// Size represented as Number of X and Y bits 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 
logic enable_fire;



// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 16*16 and use only the top left 16*15 squares 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the  understanding 

	logic [0:15] [0:15] [3:0]  MazeBiMapMask= 
{{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00}};

 logic [0:31] [0:31] [7:0]  object_colors  = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'hf1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'hed,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'he4,8'he4,8'hf6,8'he4,8'he4,8'he4,8'hf1,8'hff,8'hff,8'hff,8'hff,8'hfa,8'he4,8'he4,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hed,8'he4,8'he4,8'he4,8'he4,8'hec,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'hf0,8'he4,8'he4,8'he4,8'hfd,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'hfd,8'he4,8'he4,8'hfd,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hed,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'hfd,8'hfc,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hf1,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hfd,8'hfc,8'hfc,8'hfc,8'hfd,8'hfd,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'he4,8'he4,8'hfd,8'hfd,8'hfd,8'hfc,8'hfc,8'hfd,8'hfd,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf1,8'he4,8'he4,8'he4,8'hf0,8'hfc,8'hfc,8'hfc,8'hfd,8'hfc,8'hfc,8'hf9,8'he4,8'he4,8'he4,8'he4,8'hed,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf1,8'he4,8'he4,8'he4,8'hf9,8'hfd,8'hfc,8'hfc,8'hfd,8'hfd,8'hfd,8'hfc,8'hfd,8'hfd,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hf1,8'he4,8'he4,8'he4,8'hf5,8'hf9,8'he4,8'hfd,8'hfd,8'hfc,8'hfc,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hed,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hfc,8'hfc,8'he4,8'hfd,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hfd,8'hfc,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hf1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'hfa,8'hff,8'hff,8'hff,8'he4,8'he4,8'hf0,8'hf9,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'he4,8'he4,8'hfa,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfa,8'he4,8'he4,8'he4,8'hed,8'hff,8'hff,8'hff,8'hff,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'he4,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hfa,8'he4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};
 
// pipeline (ff) to get the pixel color from the array 	

 enum logic [2:0] {s_idle, s_fire, s_extra1, s_extra2} flames_ps, flames_ns;
 logic timer_ns, timer_ps; // ADDED COD
 logic extra_fire_PS, extra_fire_NS;
 


//--------------------------------------------------------------------------------------------
//  1.  syncronous code:  executed once every clock to update the current state 
always @(posedge clk or negedge resetN)
   begin
			
		if ( !resetN ) begin  // Asynchronic reset
			flames_ps <= s_idle;
			timer_ps <= 2'b0; // ADDED CODE
			extra_fire_PS <= 0;
		end
		
		else begin		// Synchronic logic FSM
			flames_ps <= flames_ns;
			timer_ps <= timer_ns; // ADDED CODE
			extra_fire_PS <= extra_fire_NS;
			
		end	
	end // always sync


	
always_comb begin
		flames_ns = flames_ps; 
		timer_ns = timer_ps;
		extra_fire_NS = extra_fire_PS;

		MazeBiMapMask= 
						{{4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00}};
								
		
	case (flames_ps)
	
		s_idle: begin
			
			timer_ns= 1'b0;
				
			if (Fire_on == 1'b1) begin
				
				if (collision_landmines_1) begin 
						flames_ns = s_extra1;
						extra_fire_NS=1'b1;
				end
				
				else if (collision_landmines_2) begin 
						flames_ns = s_extra2;
						extra_fire_NS=1'b1;
				end
				
				else
					flames_ns = s_fire; 
			end
		end // idle
				
		s_fire: begin
				
				if(random_flame == 1'b1) begin
					// horizontal explosion
					MazeBiMapMask[BombY[8:5]][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]+1] =4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]-1] =4'h01;
				end
				
				else if (random_flame == 1'b0) begin
					// vertical explosion
					MazeBiMapMask[BombY[8:5]][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]+1][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]-1][BombX[8:5]] =4'h01;
				end
						
				if (collision_landmines_1) begin 
					flames_ns = s_extra1;
					extra_fire_NS=1'b1;
				end
					
				else if (collision_landmines_2) begin
					flames_ns = s_extra2;	
					extra_fire_NS=1'b1;
				end
					
				else flames_ns = s_idle;
								
		end // fire
		
		// landmine #1
		s_extra1: begin
			if(random_flame == 1'b1) begin
					// expand the horizontal explosion
					MazeBiMapMask[BombY[8:5]][BombX[8:5]] = 4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]+1] = 4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]-1] = 4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]+2] = 4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]-2] = 4'h01;
			end
			else if(random_flame == 1'b0) begin
					// expand the vertical explosion
					MazeBiMapMask[BombY[8:5]][BombX[8:5]] = 4'h01;
					MazeBiMapMask[BombY[8:5]+1][BombX[8:5]] = 4'h01;
					MazeBiMapMask[BombY[8:5]-1][BombX[8:5]] = 4'h01;
					MazeBiMapMask[BombY[8:5]+2][BombX[8:5]] = 4'h01;
					MazeBiMapMask[BombY[8:5]-2][BombX[8:5]] = 4'h01;					
			end
			
			// display the flames only for 1 second
			if(OneSecPulse == 1'b1)
					timer_ns=timer_ps + 1'b1;
					
			if(timer_ps== 1'b1) 
					flames_ns = s_idle;
	
		end

		
		// landmine #2
		s_extra2: begin
		
			if(random_flame == 1'b1) begin
					// expand the horizontal explosion	
					MazeBiMapMask[BombY[8:5]][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]+1] =4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]-1] =4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]+2] =4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]-2] =4'h01;
					MazeBiMapMask[BombY[8:5]+1][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]-1][BombX[8:5]] =4'h01;
			end
			else if(random_flame == 1'b0) begin
					// expand the vertical explosion
					MazeBiMapMask[BombY[8:5]][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]+1][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]-1][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]+2][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]-2][BombX[8:5]] =4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]+1] =4'h01;
					MazeBiMapMask[BombY[8:5]][BombX[8:5]-1] =4'h01;					
			end
			
			// display the flames only for 1 second
			if(OneSecPulse == 1'b1)
					timer_ns=timer_ps + 1'b1;
					
			if(timer_ps== 1'b1) 
					flames_ns = s_idle;
		end
	
	endcase
end // always comb

//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
	end
	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default 

		if ((InsideRectangle == 1'b1 )		& 	// only if inside the external bracket 
		   (MazeBiMapMask[OffsetY[8:5] ][OffsetX[8:5]] == 4'h01 )) // take bits 5,6,7,8,9,10 from address to select  position in the maze    
						RGBout <= object_colors[OffsetY[4:0]][OffsetX[4:0]] ; 
	end 
end

//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 

assign enable_fire = ( Fire_on || extra_fire_PS );

assign drawingRequest = ((RGBout != TRANSPARENT_ENCODING )&& enable_fire) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap 
  

endmodule

