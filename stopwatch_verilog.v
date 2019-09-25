`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:          		Department of Computer Science and Engineering, University of Maratuwa, Sri Lanka 
// Engineer:    			Damith Wijewardana - damith.w.12@cse.mrt.ac.lk
//
// Create Date:				17:51:21 10/03/2016
// Design Name: 			Verilog_7Segment_StopWatch
// Module Name:				Verilog Stopwatch
// Project Name:			Verilog Stopwatch
// Target Devices:			Nexsys2
// Tool versions:			
// Description:				Stopwatch with millisecond accuracy  
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

/*

module BCD_to_7Seg(bcd,seg);

	input [3:0]bcd;
	output [6:0]seg;
	//reg [6:0]seg;
    
    always@(bcd)
		begin
			case(bcd)
				1 : seg = 7'b1111001;
				2 : seg = 7'b0100100;
				3 : seg = 7'b0110000;
				4 : seg = 7'b0011001;
				5 : seg = 7'b0010010;
				6 : seg = 7'b0000010;
				7 : seg = 7'b1111000;
				8 : seg = 7'b0000000;
				9 : seg = 7'b0010000;
				0 : seg = 7'b1000000;
				default : seg = 7'b1111111;
			endcase
		end
  	 
endmodule

*/

// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
// >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

module stopwatch(
	input clock,
	input reset,
	input start, stop,
	output a, b, c, d, e, f, g, dp,
	output [3:0] an
	);
 
	// Registers to store individual counts for 4 segments 
	reg [3:0] reg_d0, reg_d1, reg_d2, reg_d3;
	
	// Register to keep track of the clock cycles 
	// Nexsys2 clock operates in 50MHz frequency
	// To get 1 millisecond need to delay the clock by 50000000x0.001 = 50000 cycles 
	// So 2^X = 50000 ---> X = 15.61
	// So we need 16bit register to keep the count 
	reg [15:0] ticker;
	
	// Internal variable to keep track of the millisecond pulses. 
	wire click;
	
	// Register to keep track of the push button presses.
	reg pb_press;

	initial
		pb_press <= 0;
	
	// Handles the push button presses and their status. 
	always @ (posedge clock)
		begin
			if(start)
				pb_press <= 1;
			else if(stop)
				pb_press <=  0;
		end
	
	// Take care of the ticker variable and its changes. 
	always @ (posedge clock or posedge reset)
		begin
			// pb_press <= start;
			if(reset)
				ticker <= 0;
			else if(ticker == 49999)
				ticker <= 0;
			else if(pb_press == 1)
				ticker <= ticker + 1;
		end
	 
	// Make 'click' variable '1' in every 50000 clock cycles. 
	assign click = ((ticker == 49999)?1'b1:1'b0);

	// Take care of the individual count registers and their values. 
	always @ (posedge clock or posedge reset)
		begin
			if (reset)
				begin
					reg_d0 <= 0;
					reg_d1 <= 0;
					reg_d2 <= 0;
					reg_d3 <= 0;
				end
			else if (click)
				begin
					if(reg_d0 == 9)
						begin  
							reg_d0 <= 0;
							if (reg_d1 == 9)
								begin  
									reg_d1 <= 0;
									if (reg_d2 == 9)
										begin
											reg_d2 <= 0;
											if(reg_d3 == 9)
												reg_d3 <= 0;
											else
												reg_d3 <= reg_d3 + 1;
										end
									else
										reg_d2 <= reg_d2 + 1;
								end
							else
								reg_d1 <= reg_d1 + 1;
						end
					else
						reg_d0 <= reg_d0 + 1;
				end
		end

	// For 7_Segement display
	localparam N = 12;
	 
	// Register to hold count for 7_Segement display rotations/changes
	reg [N-1:0]count;
	 
	// Keep counting every clock cycle unless user pushes 'reset' button
	always @ (posedge clock or posedge reset)
		begin
			if (reset)
				count <= 0;
			else
				count <= count + 1;
		end
	 
	// Register to holds values of a 7_Segement
	reg [6:0]sseg;
	
	// This temporary hold the status of the 4 7_Segement displays
	reg [3:0]an_temp;
	
	// To hold the value for dot in a 7_Segement
	reg reg_dp;
	
	// Rotate the 7_segment display which is in its 'on' state.
	// Set the value of the 7_segement using registers which keep individual counts.
	always @ (*)
		begin
			case(count[N-1:N-2])
		
				2'b00 :
					begin
					sseg = reg_d0;
					an_temp = 4'b1110;
					reg_dp = 1'b1;
					end
		
				2'b01:
					begin
					sseg = reg_d1;
					an_temp = 4'b1101;
					reg_dp = 1'b1;
					end
					
				2'b10:
					begin
					sseg = reg_d2;
					an_temp = 4'b1011;
					reg_dp = 1'b1;
					end
					 
				2'b11:
					begin
					sseg = reg_d3;
					an_temp = 4'b0111;
					reg_dp = 1'b0;
					end
			endcase
		end
		
	// Assign enable signal to 7_segements enable pins.
	assign an = an_temp;
	 
	// Register to hold value of 'on' 7_segement 
	reg [6:0] sseg_temp;
	
	// Finding out what needs to be shown in 7_segement
	always @ (*)
		begin
			case(sseg)
				0 : sseg_temp = 7'b1000000;
				1 : sseg_temp = 7'b1111001;
				2 : sseg_temp = 7'b0100100;
				3 : sseg_temp = 7'b0110000;
				4 : sseg_temp = 7'b0011001;
				5 : sseg_temp = 7'b0010010;
				6 : sseg_temp = 7'b0000010;
				7 : sseg_temp = 7'b1111000;
				8 : sseg_temp = 7'b0000000;
				9 : sseg_temp = 7'b0010000;
				default : sseg_temp = 7'b0111111;
			endcase
		end

	// Assigning 7_segement pin values
	assign {g, f, e, d, c, b, a} = sseg_temp;
	// Assigning value of the dot in 7_segement displays
	assign dp = reg_dp;
 	//this code is forked by harsha1522
	
endmodule
