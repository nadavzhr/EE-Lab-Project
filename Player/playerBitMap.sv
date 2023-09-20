// System-Verilog 'written by Alex Grinshpun May 2018
// New bitmap dudy February 2021
// (c) Technion IIT, Department of Electrical Engineering 2021 



module	playerBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 

					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout,  //rgb value from the bitmap 
					output	logic	[3:0] HitEdgeCode //one bit per edge 
 ) ;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_NUMBER_OF_Y_BITS = 5;  // 2^5 = 32 
localparam  int OBJECT_NUMBER_OF_X_BITS = 5;  // 2^5 = 32 


localparam  int OBJECT_HEIGHT_Y = 1 <<  OBJECT_NUMBER_OF_Y_BITS ;
localparam  int OBJECT_WIDTH_X = 1 <<  OBJECT_NUMBER_OF_X_BITS;

// this is the devider used to acess the right pixel 
localparam  int OBJECT_HEIGHT_Y_DIVIDER = OBJECT_NUMBER_OF_Y_BITS - 2; //how many pixel bits are in every collision pixel
localparam  int OBJECT_WIDTH_X_DIVIDER =  OBJECT_NUMBER_OF_X_BITS - 2;

// generating a smiley bitmap

localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 

logic[0:31][0:31][7:0] object_colors = {
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hd8,8'hd8,8'hdc,8'hdc,8'hfc,8'hfc,8'hfc,8'hfc,8'hfc,8'hdc,8'hdc,8'hdc,8'hd8,8'hd8,8'hd8,8'hb4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hd8,8'hd9,8'hd9,8'hd9,8'hd8,8'hdc,8'hfc,8'hfc,8'hfc,8'hfc,8'hdc,8'hd8,8'hd9,8'hd9,8'hd9,8'hb4,8'h6c,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h21,8'h25,8'h20,8'h20,8'h24,8'h25,8'h25,8'hb2,8'hb5,8'hb5,8'h8d,8'h66,8'h26,8'h21,8'h21,8'h21,8'h21,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h8e,8'h8e,8'h8e,8'h8e,8'hb2,8'h8e,8'h92,8'h25,8'h66,8'h66,8'h24,8'h8e,8'hb2,8'h8e,8'h8e,8'h8e,8'h6e,8'h00,8'hb6,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h00,8'h00,8'h8e,8'h86,8'h92,8'h91,8'h65,8'h6e,8'h92,8'h00,8'h00,8'h00,8'h00,8'h92,8'h6e,8'h91,8'h65,8'h66,8'h66,8'h6e,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'h6d,8'h00,8'h8e,8'h8e,8'h6d,8'h6d,8'h25,8'h92,8'h92,8'h24,8'h20,8'h24,8'h20,8'h92,8'h6d,8'h6d,8'h6c,8'h6d,8'h8e,8'h6e,8'h00,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h00,8'h8e,8'h8e,8'h6d,8'h6d,8'h24,8'h8e,8'h92,8'h21,8'h66,8'h66,8'h20,8'h8e,8'h65,8'h6c,8'h24,8'h6e,8'h8e,8'h25,8'h21,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'h91,8'h00,8'h8e,8'h8e,8'h8e,8'h8e,8'h6d,8'h24,8'h91,8'hd9,8'hd9,8'h24,8'h6d,8'h8e,8'h8e,8'h8e,8'h6e,8'h6d,8'h00,8'hb5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb4,8'hb4,8'h90,8'h90,8'h90,8'h90,8'hb4,8'hd8,8'hdc,8'hfc,8'hdc,8'hd8,8'hb4,8'h6c,8'h6c,8'h2c,8'h6c,8'h90,8'h90,8'h6d,8'h01,8'h21,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb4,8'hd8,8'hb4,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hb4,8'hb4,8'hb4,8'hb4,8'h64,8'h21,8'h01,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hb4,8'hd8,8'hb8,8'hd8,8'hd8,8'hd8,8'hd8,8'hd8,8'hb8,8'hb4,8'hb4,8'hb4,8'hb4,8'h90,8'hd8,8'hb4,8'h90,8'h01,8'h01,8'h01,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'h90,8'h90,8'h90,8'h94,8'hb4,8'hb4,8'hb8,8'hb4,8'hb4,8'hb4,8'hb4,8'hb4,8'hb4,8'hb4,8'h90,8'h90,8'h6c,8'hff,8'hff,8'h20,8'h21,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h24,8'h24,8'h6c,8'h04,8'h00,8'h24,8'h04,8'h24,8'h24,8'h00,8'h00,8'h00,8'h01,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h6d,8'h00,8'h90,8'h90,8'h90,8'hb5,8'hda,8'h24,8'h64,8'h00,8'hb5,8'h6c,8'h00,8'h01,8'h01,8'h01,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hd8,8'h6c,8'hb4,8'h6c,8'h21,8'h90,8'h6c,8'hb0,8'hd5,8'hfe,8'h00,8'h64,8'h20,8'hd9,8'h90,8'hff,8'hda,8'h01,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hb8,8'h6c,8'hb4,8'hd8,8'h90,8'h60,8'hac,8'h8c,8'hf4,8'hb5,8'h8c,8'hd4,8'h20,8'h20,8'h90,8'h01,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h20,8'hb1,8'hac,8'hf9,8'hf8,8'hf9,8'hf4,8'h00,8'h00,8'h00,8'h94,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h00,8'h20,8'h24,8'h24,8'h24,8'h91,8'h6d,8'h6d,8'h6d,8'h20,8'h94,8'h22,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h64,8'h24,8'h04,8'h91,8'h8d,8'h6d,8'h8e,8'h6d,8'h64,8'hff,8'h84,8'h90,8'hb8,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hd8,8'hb0,8'hf4,8'hd4,8'hd0,8'h70,8'h94,8'hb6,8'hff,8'h6c,8'hd4,8'hd5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h21,8'hd5,8'h90,8'h64,8'hd5,8'h6c,8'hb4,8'h21,8'h66,8'h22,8'h91,8'h24,8'hcc,8'hf5,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h22,8'h22,8'h22,8'h25,8'hff,8'hff,8'hff,8'h21,8'h21,8'h62,8'h21,8'hff,8'hff,8'hff,8'hff,8'hf0,8'hd1,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'h22,8'h22,8'h21,8'hff,8'hff,8'hff,8'hff,8'hfe,8'h6c,8'h20,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hac,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb8,8'h90,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'h94,8'hb4,8'hfe,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb8,8'hd8,8'hb4,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hd8,8'hd8,8'h94,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hd8,8'hb8,8'h90,8'hff,8'hff,8'hff,8'hff,8'hff,8'hb4,8'hb4,8'hb8,8'hd8,8'hb4,8'hb4,8'hd9,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff},
	{8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff,8'hff}};


//////////--------------------------------------------------------------------------------------------------------------=
//hit bit map has one bit per edge:  hit_colors[3:0] =   {Left, Top, Right, Bottom}	
//there is one bit per edge, in the corner two bits are set  


logic [0:3] [0:3] [3:0] hit_colors = 
		  {16'he447,     
			16'h8C67,    
			16'h8932,
			16'h9113};

 

// pipeline (ff) to get the pixel color from the array 	 

//////////--------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
	if(!resetN) begin
		RGBout <=	8'h00;
		HitEdgeCode <= 4'h0;

	end

	else begin
		RGBout <= TRANSPARENT_ENCODING ; // default  
		HitEdgeCode <= 4'h0;

		if (InsideRectangle == 1'b1 ) 
		begin // inside an external bracket 
			HitEdgeCode <= hit_colors[offsetY >> OBJECT_HEIGHT_Y_DIVIDER][offsetX >> OBJECT_WIDTH_X_DIVIDER];	//get hitting edge from the colors table  
			RGBout <= object_colors[offsetY][offsetX];
		end  	
	end
		
end

//////////--------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmpap   

endmodule