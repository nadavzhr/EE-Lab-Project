// HartsMatrixBitMap File 
// A two level bitmap. dosplaying harts on the screen Apr  2023  
// (c) Technion IIT, Department of Electrical Engineering 2023 



module	DynamicWallsBitMap	(	
					input	logic	clk,
					input	logic	resetN,
					input logic	[10:0] offsetX,// offset from top left  position 
					input logic	[10:0] offsetY,
					input	logic	InsideRectangle, //input that the pixel is within a bracket 

					
					input logic collision_flames_dynamic_walls,

					input logic enable_wall_destruct,
					input	logic	SingleHitPulseWall,
					
					output	logic	drawingRequest, //output that the pixel should be dispalyed 
					output	logic	[7:0] RGBout  //rgb value from the bitmap 
 ) ;
 

// Size represented as Number of X and Y bits 
localparam logic [7:0] TRANSPARENT_ENCODING = 8'hFF ;// RGB value in the bitmap representing a transparent pixel 
 /*  end generated by the tool */


// the screen is 640*480  or  20 * 15 squares of 32*32  bits ,  we wiil round up to 16*16 and use only the top left 16*15 squares 
// this is the bitmap  of the maze , if there is a specific value  the  whole 32*32 rectange will be drawn on the screen
// there are  16 options of differents kinds of 32*32 squares 
// all numbers here are hard coded to simplify the  understanding 



logic [0:14] [0:16] [3:0] MazeBitMapMask = 
{	// DYNAMIC WALLS - GRID
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00},
 {4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00},
 {4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00},
 {4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00},
 {4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00},
 {4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00},
 {4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h00},
 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00}
};





logic [0:2] [0:31] [0:31] [7:0]  object_colors  = {
	// STRONGEST WALL - STONE ( 03 CODE )
  {{8'h6d,8'h6d,8'h25,8'h25,8'h00,8'h25,8'h6d,8'hb6,8'hb6,8'h96,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h92,8'h92,8'h92,8'hb6,8'hb6,8'h92,8'hb6,8'hb6,8'h92,8'h91,8'h92,8'hb6,8'h92,8'h6d,8'h6d,8'h6d},
	{8'hb6,8'hb6,8'h92,8'h6d,8'h92,8'h96,8'hb6,8'hb6,8'h92,8'h92,8'hb6,8'hb6,8'hb6,8'h96,8'h92,8'h92,8'h92,8'h92,8'h92,8'h92,8'hb6,8'h92,8'hb6,8'h96,8'hb6,8'hb6,8'hdb,8'hba,8'hdb,8'hda,8'hda,8'hba},
	{8'hb6,8'hb6,8'hdb,8'hff,8'hba,8'hff,8'hdb,8'hdb,8'hdb,8'hff,8'h25,8'h00,8'h00,8'h00,8'h00,8'h24,8'h24,8'h25,8'h24,8'hdb,8'hdb,8'hdb,8'hdb,8'hdb,8'hdf,8'hff,8'hdf,8'hdf,8'hda,8'hb6,8'hda,8'hda},
	{8'hda,8'hda,8'hdb,8'hdb,8'hdb,8'hba,8'hb6,8'hb6,8'hba,8'hda,8'hb6,8'hb6,8'h92,8'h92,8'h91,8'h91,8'h92,8'h92,8'h6d,8'hdb,8'h6d,8'hda,8'hda,8'hda,8'hda,8'hdb,8'hdb,8'hdb,8'hb6,8'hb6,8'hb6,8'hda},
	{8'hda,8'hba,8'hdb,8'hff,8'hdb,8'hdb,8'hdf,8'hb6,8'hda,8'hda,8'hb6,8'hb6,8'h96,8'hb6,8'hda,8'h96,8'hb6,8'hb6,8'h71,8'hdb,8'hba,8'hda,8'hda,8'hb6,8'hff,8'hda,8'hff,8'hdf,8'hb6,8'hb6,8'hb6,8'hda},
	{8'hb6,8'hff,8'hff,8'hdf,8'hdb,8'hdb,8'hdb,8'hff,8'hdb,8'hda,8'hb6,8'hba,8'hb6,8'hb6,8'hdb,8'hdb,8'hda,8'hb6,8'h92,8'hdf,8'hda,8'hdf,8'hdf,8'hdb,8'hdb,8'hff,8'hff,8'hba,8'h91,8'hb6,8'hda,8'hda},
	{8'hff,8'hff,8'hff,8'hda,8'hdb,8'hdb,8'hdf,8'hdb,8'hda,8'hda,8'hb6,8'hba,8'hdb,8'hda,8'hdf,8'hb6,8'hdb,8'hb6,8'h92,8'hda,8'hda,8'hda,8'hdb,8'hff,8'hdb,8'hff,8'hff,8'hff,8'h92,8'h96,8'hb6,8'hda},
	{8'hdf,8'hdf,8'hdb,8'hda,8'hff,8'hff,8'hdb,8'hdb,8'hb6,8'hb6,8'h92,8'hda,8'hda,8'hdb,8'hdb,8'hba,8'hb6,8'h92,8'h92,8'h2d,8'h25,8'h25,8'h6d,8'hda,8'hdb,8'hff,8'hff,8'hda,8'h91,8'h92,8'hb6,8'hda},
	{8'hda,8'hdb,8'hda,8'hda,8'hdf,8'hdb,8'hdb,8'hda,8'h96,8'hb6,8'h92,8'hb6,8'hb6,8'hb6,8'hb6,8'h92,8'h92,8'h92,8'h72,8'h25,8'h92,8'h92,8'h6e,8'hdb,8'hb6,8'hdb,8'hdb,8'hda,8'h91,8'h6e,8'hb6,8'hda},
	{8'hdb,8'hda,8'hff,8'hda,8'hdf,8'hdb,8'hdb,8'hb6,8'h96,8'hb6,8'h92,8'h6d,8'hff,8'hdb,8'hdb,8'hda,8'hdb,8'hdb,8'hda,8'hb6,8'hb6,8'hb6,8'h92,8'hda,8'h92,8'h92,8'hb6,8'h6d,8'h91,8'h92,8'hb6,8'hb6},
	{8'hdb,8'hdb,8'hdb,8'hda,8'hdb,8'hdb,8'hdb,8'hff,8'hff,8'hb6,8'hb6,8'h6d,8'hff,8'hff,8'hff,8'hff,8'hff,8'hdf,8'hff,8'hda,8'hb6,8'h91,8'h92,8'h6d,8'h25,8'h25,8'h6d,8'h6d,8'h2d,8'h96,8'hb6,8'hb6},
	{8'hda,8'hb6,8'hda,8'h6d,8'hb6,8'h92,8'hb6,8'hdb,8'hdb,8'hb6,8'hb6,8'h25,8'hdf,8'hdb,8'hb6,8'hb6,8'hb6,8'hba,8'hb6,8'hb6,8'h91,8'h6d,8'h96,8'h92,8'h6d,8'h92,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6},
	{8'hb6,8'hb6,8'h6d,8'h25,8'h25,8'h24,8'h25,8'h25,8'h2d,8'h6d,8'hb6,8'h25,8'hda,8'hdb,8'hb6,8'hb6,8'hb6,8'hda,8'hda,8'hda,8'h91,8'h6d,8'h96,8'h92,8'h6d,8'h91,8'h92,8'hb6,8'hba,8'hb6,8'h96,8'h92},
	{8'h92,8'h96,8'h92,8'h92,8'h96,8'h92,8'h92,8'h92,8'h92,8'hb6,8'hb6,8'h25,8'hdb,8'hb6,8'hb6,8'hb6,8'hda,8'hdb,8'hdb,8'hda,8'h91,8'h25,8'h92,8'hb6,8'hb6,8'h92,8'h92,8'hb6,8'hba,8'hb6,8'hb6,8'h91},
	{8'h92,8'h92,8'h92,8'hb6,8'hb6,8'hb6,8'hb6,8'h92,8'h92,8'h92,8'hb6,8'h25,8'hdb,8'hb6,8'hdb,8'hda,8'hb6,8'hb6,8'hb6,8'hba,8'h91,8'h25,8'hb6,8'hb6,8'hda,8'hb6,8'hb6,8'h92,8'hb6,8'hb6,8'hb6,8'h92},
	{8'h92,8'h92,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'hdb,8'hdb,8'hdb,8'hdb,8'h6d,8'hff,8'hda,8'hba,8'hdb,8'hda,8'hda,8'hdb,8'hdb,8'h91,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'h92,8'h92,8'h92,8'h91,8'h92},
	{8'h92,8'h92,8'h6d,8'h92,8'hda,8'hda,8'hda,8'hdb,8'hb6,8'hb6,8'hdb,8'h25,8'hdb,8'h6d,8'hda,8'hda,8'hda,8'hdb,8'hda,8'hff,8'h6d,8'h6d,8'hb6,8'hb6,8'hb6,8'hda,8'h92,8'h6d,8'h91,8'h96,8'hb6,8'h92},
	{8'h92,8'h92,8'h92,8'hb6,8'hb6,8'hda,8'hda,8'hdb,8'hb6,8'hb6,8'hb6,8'h2d,8'hb6,8'h6d,8'h92,8'h92,8'h92,8'h92,8'h92,8'h96,8'h6d,8'h6d,8'hb6,8'hb6,8'hb6,8'hb6,8'h92,8'h6d,8'h92,8'h92,8'h91,8'h92},
	{8'hb6,8'h6d,8'hb6,8'hb6,8'hb6,8'hda,8'hda,8'hff,8'hda,8'hba,8'hb6,8'h6d,8'h6d,8'h25,8'h2d,8'h25,8'h6d,8'h25,8'h6d,8'h6d,8'h6d,8'h6d,8'h96,8'hb6,8'hb6,8'hb6,8'h92,8'h6d,8'h92,8'h92,8'hda,8'h92},
	{8'h92,8'h25,8'hb6,8'hb6,8'h92,8'hb6,8'hdb,8'hff,8'hda,8'hb6,8'hda,8'hb6,8'h92,8'h92,8'h92,8'h6d,8'hb6,8'hb6,8'hdb,8'hdb,8'hda,8'hdb,8'hda,8'hb6,8'hb6,8'hb6,8'h92,8'h6d,8'h6d,8'h92,8'hb6,8'h92},
	{8'h92,8'h25,8'h92,8'h92,8'h92,8'hda,8'hff,8'hff,8'hdf,8'hda,8'hdb,8'hdb,8'hb6,8'hda,8'hda,8'hda,8'h92,8'h92,8'hda,8'hdb,8'hff,8'hdb,8'hdb,8'hdb,8'hdb,8'hb6,8'hb6,8'h6d,8'h71,8'hb6,8'hb6,8'hb6},
	{8'hdb,8'hda,8'hda,8'hda,8'hb6,8'hff,8'hb6,8'hba,8'hb6,8'hb6,8'hda,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h6d,8'h6d,8'hb6,8'hda,8'hdb,8'hff,8'hff,8'hdf,8'hdb,8'hb6,8'h92,8'h6d,8'h92,8'hb6,8'hda,8'hb6},
	{8'hdb,8'hb6,8'hb6,8'hb6,8'hba,8'hdb,8'hdb,8'hdb,8'hdb,8'hda,8'hb6,8'hda,8'hb6,8'hb6,8'hb6,8'hb6,8'h6d,8'h71,8'hb6,8'hda,8'hdb,8'hff,8'hff,8'hff,8'hdb,8'hb6,8'hb6,8'h6d,8'h96,8'hba,8'hdb,8'hba},
	{8'hdb,8'hdb,8'hda,8'hb6,8'hb6,8'hda,8'h96,8'hb6,8'hdb,8'hda,8'hda,8'hda,8'hdb,8'hdb,8'hb6,8'hda,8'h25,8'h6d,8'h91,8'hda,8'hda,8'hdf,8'hdb,8'hdb,8'hff,8'hda,8'h92,8'h72,8'hb6,8'hdb,8'hda,8'hda},
	{8'hff,8'hda,8'hda,8'h91,8'h92,8'hff,8'hda,8'hdb,8'hdb,8'hdb,8'hdb,8'hff,8'hdb,8'hdb,8'hb6,8'hba,8'h6d,8'h6d,8'h6d,8'h6d,8'h91,8'h91,8'h92,8'hb6,8'hb6,8'h92,8'h6d,8'h92,8'hda,8'hdb,8'hba,8'hdb},
	{8'hdf,8'hb6,8'hb6,8'h92,8'h92,8'hff,8'hdf,8'hdb,8'hdb,8'hdf,8'hff,8'hdb,8'hdb,8'hda,8'hb6,8'h92,8'h2d,8'h92,8'h96,8'hb6,8'hb6,8'hba,8'h92,8'hff,8'hdb,8'hdb,8'hba,8'hda,8'hda,8'hda,8'hdb,8'hdf},
	{8'hdb,8'hb6,8'h92,8'h92,8'h92,8'hdb,8'hba,8'hba,8'hdb,8'hdf,8'hff,8'hdf,8'hda,8'hb6,8'hb6,8'h92,8'h6d,8'h92,8'h92,8'hdb,8'hda,8'hdb,8'h92,8'hff,8'hdf,8'hb6,8'hb6,8'hb6,8'hb6,8'hba,8'hb6,8'hb6},
	{8'hdb,8'hb6,8'hb6,8'h92,8'h92,8'hda,8'h92,8'hb6,8'hda,8'hdb,8'hdb,8'hda,8'hb6,8'hb6,8'hb6,8'hb6,8'h91,8'hb6,8'hb6,8'hb6,8'hda,8'hff,8'h96,8'hda,8'hba,8'hdb,8'h91,8'hdb,8'hff,8'hdb,8'hdb,8'hdb},
	{8'hb6,8'hdb,8'hb6,8'h96,8'h92,8'hb6,8'h91,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'h96,8'h92,8'h92,8'hba,8'h6d,8'hb6,8'hb6,8'hda,8'hdb,8'hdb,8'h71,8'hba,8'hb6,8'hdb,8'hda,8'hdb,8'hff,8'h96,8'hdf,8'hff},
	{8'hdb,8'hb6,8'hda,8'hb6,8'h92,8'h6d,8'h2d,8'h6d,8'h6d,8'h6d,8'h6d,8'h6d,8'h2d,8'h24,8'h25,8'h25,8'h6d,8'h92,8'hb6,8'hb6,8'h96,8'hdf,8'h6d,8'hda,8'hda,8'hdb,8'hdf,8'hdf,8'hff,8'hff,8'hdf,8'hdb},
	{8'hdb,8'hb6,8'hb6,8'hb6,8'hb6,8'h92,8'h6d,8'h92,8'h92,8'h92,8'h92,8'h92,8'h92,8'h6d,8'h6d,8'hb6,8'h6d,8'h91,8'h92,8'h92,8'h92,8'hb6,8'h6d,8'hda,8'hda,8'hda,8'hda,8'hdb,8'hdb,8'hdb,8'hdb,8'hda},
	{8'hb6,8'h92,8'h92,8'h92,8'hb6,8'h6d,8'h91,8'hb6,8'hb6,8'hb6,8'h92,8'h96,8'h92,8'h92,8'h92,8'h92,8'h92,8'h92,8'h92,8'h71,8'h92,8'h92,8'hb6,8'hb6,8'hb6,8'hb6,8'hb6,8'hda,8'hda,8'hda,8'hda,8'hb6}}
	,
	// MEDIUM WALL - REDBRICK ( 02 CODE )
  {{8'hc4,8'hc4,8'hc4,8'hc4,8'h84,8'hc4,8'hc4,8'ha4,8'ha4,8'ha4,8'ha4,8'hcc,8'h80,8'hc4,8'hc4,8'hc4,8'hc4,8'hc4,8'hcc,8'ha4,8'ha4,8'hc4,8'hc4,8'ha4,8'ha4,8'ha4,8'hc4,8'hc4,8'h84,8'hc4,8'hc4,8'ha4},
	{8'hec,8'hec,8'hec,8'hec,8'ha4,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'ha4,8'hec,8'h84,8'hf1,8'ha4,8'hf1,8'hec,8'hec,8'hec,8'hcc,8'hc4,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec},
	{8'hec,8'hec,8'hec,8'hec,8'ha4,8'hf1,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'h84,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf1,8'hc4,8'hf1,8'hed,8'hec,8'hec,8'hec,8'he4,8'he4,8'ha4,8'hec,8'hec,8'hec},
	{8'hec,8'hec,8'hec,8'hec,8'h84,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'h80,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf1,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec},
	{8'he4,8'hec,8'he4,8'he4,8'ha4,8'hec,8'hf1,8'hcc,8'hec,8'hec,8'hcc,8'hec,8'h80,8'hec,8'hec,8'hec,8'hec,8'hec,8'h84,8'hcc,8'hc4,8'hf0,8'hec,8'hec,8'hec,8'hf0,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec},
	{8'h84,8'h84,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h84,8'h80,8'h84,8'h84,8'ha4,8'ha4,8'ha4,8'h84,8'ha4,8'h84,8'h84,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4},
	{8'hec,8'h80,8'hec,8'hec,8'hec,8'hec,8'hf1,8'hec,8'h84,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'hc4,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec,8'hc4},
	{8'hec,8'hec,8'hec,8'hec,8'hec,8'h84,8'hec,8'hcc,8'h84,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'hf1,8'hec,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hcc,8'hec,8'hec,8'h80,8'hec,8'hec,8'hc4},
	{8'hec,8'hec,8'ha4,8'hec,8'hec,8'hed,8'hec,8'hcc,8'h80,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hc4,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hec,8'hcc},
	{8'hcc,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'h80,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hc4,8'hcc,8'hec,8'hf1,8'hec,8'hed,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf1,8'hc4},
	{8'h80,8'h84,8'h84,8'h84,8'h84,8'h84,8'h80,8'h80,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h80,8'h80,8'h84,8'h84,8'h84,8'h80,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h84,8'h80,8'h80,8'h84,8'h80},
	{8'hec,8'hec,8'he4,8'he4,8'ha4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hed,8'hec,8'h80,8'hec,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'hcc,8'hc4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec},
	{8'hec,8'hec,8'hec,8'he4,8'ha4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'he4,8'h84,8'hf1,8'hed,8'hec,8'hec,8'hec,8'hec,8'hcc,8'hc4,8'hf1,8'hf1,8'hed,8'hec,8'hec,8'hec,8'he4,8'ha4,8'hf1,8'hf1,8'hec},
	{8'hec,8'hec,8'hec,8'hec,8'ha4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'he4,8'h80,8'he4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf1,8'hcc,8'hf1,8'hec,8'hec,8'hec,8'hec,8'he4,8'he4,8'ha4,8'hec,8'hec,8'hec},
	{8'hec,8'hec,8'hec,8'he4,8'ha4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'h84,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hf1,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec},
	{8'hc4,8'hc4,8'hc4,8'ha4,8'ha4,8'hc4,8'hec,8'hcc,8'hc4,8'hc4,8'hc4,8'hc4,8'h84,8'ha4,8'hf5,8'hf5,8'hf1,8'hcc,8'h80,8'ha4,8'hcc,8'ha4,8'hc4,8'hc4,8'hc4,8'hc4,8'hc4,8'hc4,8'h84,8'ha4,8'ha4,8'hc4},
	{8'ha4,8'hc4,8'hc4,8'hc4,8'hc4,8'hec,8'hcc,8'hec,8'h80,8'hcc,8'hcc,8'h80,8'hec,8'hec,8'hec,8'hc4,8'ha4,8'hc4,8'hc4,8'hc4,8'hc4,8'hc4,8'hc4,8'ha4,8'ha4,8'hec,8'hec,8'hcc,8'hc4,8'hc4,8'ha4,8'ha4},
	{8'hc4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'h84,8'hec,8'ha4,8'hc4,8'hcc,8'hec,8'hec,8'hcc,8'ha4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'ha4,8'hec,8'hf5,8'hec,8'hec,8'hec,8'hec,8'hec,8'hc4},
	{8'ha4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'ha4,8'hac,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'ha4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'ha4,8'hec,8'hec,8'hec,8'hec,8'hc4,8'hf5,8'hec,8'hc4},
	{8'ha4,8'hf1,8'hed,8'hec,8'hec,8'hec,8'hec,8'hec,8'h84,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'ha4,8'hf1,8'hf1,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hc4,8'hec,8'hed,8'hec,8'hec,8'hec,8'hec,8'hcc},
	{8'hc4,8'hec,8'he4,8'he4,8'he4,8'hec,8'he4,8'he4,8'h80,8'hed,8'hec,8'hec,8'hec,8'hec,8'hf1,8'hc4,8'hc4,8'hec,8'he4,8'he4,8'he4,8'he4,8'he4,8'ha4,8'hc4,8'hec,8'hec,8'hec,8'hf1,8'hf5,8'hf6,8'ha4},
	{8'h80,8'h80,8'h80,8'h84,8'h84,8'h84,8'h80,8'h84,8'h84,8'h84,8'h84,8'h84,8'h80,8'h80,8'h84,8'h84,8'h84,8'h84,8'h80,8'h80,8'h84,8'h80,8'h84,8'h84,8'h80,8'h80,8'h84,8'h84,8'h84,8'h80,8'ha4,8'h84},
	{8'hec,8'hec,8'hec,8'hec,8'ha4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'h80,8'hf1,8'hf1,8'hf1,8'hf1,8'hed,8'hec,8'hcc,8'hc4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hed,8'he4,8'ha4,8'hec,8'hed,8'hec},
	{8'hec,8'hec,8'hec,8'hec,8'ha4,8'hf1,8'hf1,8'hec,8'hec,8'hec,8'hcc,8'hec,8'h80,8'hf1,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hc4,8'hf1,8'hf1,8'hec,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec},
	{8'hec,8'hec,8'hec,8'hec,8'ha4,8'hf1,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'h84,8'hec,8'hec,8'hec,8'hec,8'h80,8'hec,8'hf1,8'hec,8'hf1,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec},
	{8'hec,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'h80,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hf1,8'hcd,8'hc4,8'hec,8'hec,8'hec,8'hec,8'hec,8'he4,8'he4,8'ha4,8'hec,8'hec,8'he4},
	{8'ha4,8'ha4,8'ha4,8'h84,8'h80,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h84,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'ha4,8'h80,8'ha4,8'ha4,8'ha4},
	{8'hec,8'hec,8'hed,8'hec,8'hec,8'hec,8'hf6,8'hc4,8'h80,8'hf1,8'hf1,8'hf1,8'hed,8'hec,8'hec,8'hec,8'hc4,8'hf1,8'hf1,8'hf1,8'hec,8'hec,8'he4,8'ha4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hc4},
	{8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'h84,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'ha4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'ha4,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hc4},
	{8'hec,8'hec,8'hec,8'h80,8'hf5,8'hec,8'hec,8'hcc,8'h84,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hed,8'hec,8'ha4,8'hf1,8'hf1,8'hf1,8'hf1,8'hf1,8'hec,8'ha4,8'ha4,8'hec,8'hec,8'hec,8'hec,8'h80,8'hec,8'hc4},
	{8'hec,8'hcc,8'hec,8'hec,8'hec,8'hec,8'hec,8'hcc,8'h80,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hc4,8'ha4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'hed,8'hc4},
	{8'h80,8'hc4,8'hc4,8'hc4,8'hc4,8'hc4,8'hcc,8'hc4,8'h80,8'he4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hc4,8'hc4,8'hec,8'hec,8'hec,8'hec,8'hec,8'hec,8'ha4,8'hc4,8'hec,8'hcc,8'hcc,8'hcc,8'hcc,8'hc4,8'ha4}}
	,
	// WEAKEST WALL - WOOD ( 01 CODE )
  {{8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h8c,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64},
	{8'h6c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h20,8'h8c,8'h6c,8'h8c,8'h8c,8'hd5,8'h6c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h64,8'h20,8'h64,8'h8c,8'hfa,8'h6c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h20,8'h20,8'h20,8'h20,8'h64,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h20,8'hb1,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64},
	{8'h6c,8'h6c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h20,8'h6c,8'h8c,8'h8c,8'h20,8'h20,8'h20,8'h20,8'h64,8'h6c,8'h6c,8'h6c,8'hb1,8'h6c,8'h6c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h6c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h64,8'h64,8'h8c,8'h20,8'hb1,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h64,8'h64,8'h8c,8'h8c,8'h8d,8'h64,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h6c,8'h6c,8'h6c,8'h64,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h64,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h64,8'h64,8'h6c,8'h6c},
	{8'h8c,8'h64,8'h20,8'h20,8'h20,8'h20,8'h20,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h64,8'h20,8'h20,8'h20,8'h20,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h20,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h64,8'h20,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h20,8'h20,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h24,8'h20,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'hac,8'hd5,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h64,8'h20,8'h24,8'h64,8'h64,8'h64,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20,8'h20},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h64,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h64,8'h20,8'h20,8'h8c,8'h6c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h6c,8'h64,8'h20,8'h20,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h8c,8'h24,8'h20,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h20,8'h24,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h6c,8'h20,8'h20,8'h20,8'h20,8'h6c,8'h6c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h64,8'h20,8'h20,8'h24,8'h20,8'h20,8'h6c,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h6c,8'h6c,8'h64,8'h64,8'h64,8'h64,8'h64},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h64,8'h64,8'h64,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h8c,8'h8c,8'h6c,8'h20,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h64,8'h64,8'h20,8'h20,8'h20,8'h20,8'h20,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h20,8'h24,8'h24,8'h20,8'h20,8'h20,8'h64,8'h64,8'h64,8'h64,8'h6c,8'h6c,8'h6c,8'h6c,8'h64},
	{8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h6c,8'h20,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h20,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h20,8'h6c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h6c,8'h6c,8'h6c,8'h6c,8'h8c,8'h8c,8'h64,8'h20,8'h20,8'h20,8'h20,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h20,8'h20,8'hd5,8'h6c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h64,8'h64,8'h64,8'h6c,8'h6c,8'h6c,8'h8c,8'h6c,8'h6c,8'h6c,8'h64,8'h64,8'h64,8'h64,8'h8c,8'h6c,8'h8c,8'h8c,8'h8c},
	{8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h24,8'h20,8'h20,8'h20,8'h20,8'h20,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64,8'h64},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h64,8'h20,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c},
	{8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h6c,8'h20,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c,8'h8c}}
 };


//logic collision_flames_dynamic_walls_flag;		
//logic flames_DrawReq_d;

logic [0:14] [0:16]	flag_matrix = 
			{
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00}
			};


// pipeline (ff) to get the pixel color from the array 	 
//==----------------------------------------------------------------------------------------------------------------=
always_ff@(posedge clk or negedge resetN)
begin
		
	
	if(!resetN) begin
		RGBout <=	8'h00;
		MazeBitMapMask <=
			{	// RESET
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00},
			 {4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00},
			 {4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00},
			 {4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00},
			 {4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00},
			 {4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00},
			 {4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h02, 4'h00, 4'h00, 4'h00, 4'h01, 4'h00, 4'h00, 4'h00, 4'h03, 4'h00, 4'h00, 4'h00, 4'h00},
			 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00}
			};
	end
	
	else begin // clk
		

			RGBout <= TRANSPARENT_ENCODING ; // default 
			//flames_DrawReq_d <= flames_DrawReq;
		
			if (InsideRectangle == 1'b1 ) begin // take bits 5,6,7,8,9,10 from address to select  position in the maze
				
				// strongest dynamic wall
				if (MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] == 4'h03)   
					begin
							RGBout <= object_colors[0][offsetY[4:0]][offsetX[4:0]] ; 
					end
			
			// medium dynamic wall
				else if (MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] == 4'h02)
					begin
							RGBout <= object_colors[1][offsetY[4:0]][offsetX[4:0]] ; 
					end
			
				// weakest dynamic wall
				else if (MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] == 4'h01) 
					begin
								RGBout <= object_colors[2][offsetY[4:0]][offsetX[4:0]] ; 
					end
					
				 if (SingleHitPulseWall && flag_matrix[offsetY[8:5]][offsetX[8:5]] == 1'b0) begin
						  if (MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] == 4'h03) begin
									MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] <= 4'h02;
									flag_matrix[offsetY[8:5]][offsetX[8:5]] <= 1'b1;	// force block another deletion of current wall
							end
							
						  else if (MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] == 4'h02) begin   
									MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] <= 4'h01;	
									flag_matrix[offsetY[8:5]][offsetX[8:5]] <= 1'b1;	// force block another deletion of current wall
							end
							
						  else if (MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] == 4'h01) begin  
									MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] <= 4'h00;	
									flag_matrix[offsetY[8:5]][offsetX[8:5]] <= 1'b1;	// force block another deletion of current wall
							end
						//	MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] <= MazeBitMapMask[offsetY[8:5]][offsetX[8:5]] - 4'h01;
				end
			
			
			if (enable_wall_destruct) begin
			
					flag_matrix <=
						{	 
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00},
						 {4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00, 4'h00}
						};
			end
		end
		
	end
		
end


//==----------------------------------------------------------------------------------------------------------------=
// decide if to draw the pixel or not 
assign drawingRequest = (RGBout != TRANSPARENT_ENCODING ) ? 1'b1 : 1'b0 ; // get optional transparent command from the bitmap 


endmodule
