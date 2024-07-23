/*
Module     : led_switch
Description: A test project that switches on LEDs based on the 
            switches turned on, a bit like a circular buffer.
*/

`default_nettype none
`timescale 1ns / 1ps
/* verilator lint_off UNUSEDPARAM */

module led_switch #(
    // How many LEDs & switches are there
    parameter WIDTH = 8,

    // Shift how many places to the left
    parameter SHIFT = 5
) (
    // input logic clk,
    // input logic rst,

    // Switches and leds
    input wire [7:0] switches,
    output wire [7:0] leds
);
    
    initial begin
        // Check input
        assert (WIDTH > 0)
        else $fatal("Make sure WIDTH (ie number of LEDs and switches) are greater than 0!");
    end

    generate
		genvar i;
		for (i = 0; i < WIDTH; i = i+1) begin: gen_block
            if (i - SHIFT >= 0) begin
			    assign leds[i] = switches[i-SHIFT];
            end else begin
                assign leds[i] = switches[i-SHIFT+WIDTH];
            end
		end
	endgenerate

endmodule