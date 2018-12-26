`ifndef HVSYNC_GENERATOR_H
`define HVSYNC_GENERATOR_H

/*
Video sync generator, used to drive a simulated CRT.
To use:
- Wire the hsync and vsync signals to top level outputs
- Add a 3-bit (or more) "rgb" output to the top level
*/

module hvsync_generator(clk, hsync, vsync, display_on, hpos_scaled, vpos_scaled);

  input clk;
  output wire hsync, vsync;
  output display_on;
  output reg [8:0] hpos_scaled;
  output wire [8:0] vpos_scaled;
  reg [9:0] hpos;
  reg [9:0] vpos;

  // declarations for TV-simulator sync parameters
  // horizontal constants
  parameter H_DISPLAY       = 640; // horizontal display width
  parameter H_BACK          =  48; // horizontal left border (back porch)
  parameter H_FRONT         =  16; // horizontal right border (front porch)
  parameter H_SYNC          =  96; // horizontal sync width
  // vertical constants
  parameter V_DISPLAY       = 480; // vertical display height
  parameter V_TOP           =  33; // vertical top border (back porch)
  parameter V_BOTTOM        =  10; // vertical bottom border (front porch)
  parameter V_SYNC          =   2; // vertical sync # lines
  // derived constants
  parameter H_SYNC_START    = H_DISPLAY + H_FRONT;
  parameter H_SYNC_END      = H_DISPLAY + H_FRONT + H_SYNC;
  parameter H_MAX           = H_DISPLAY + H_BACK + H_FRONT + H_SYNC;
  parameter V_SYNC_START    = V_DISPLAY + V_BOTTOM;
  parameter V_SYNC_END      = V_DISPLAY + V_BOTTOM + V_SYNC;
  parameter V_MAX           = V_DISPLAY + V_TOP + V_BOTTOM + V_SYNC;

  assign hsync = ~((hpos>=H_SYNC_START) && (hpos<H_SYNC_END)); // active low
  assign vsync = ~((vpos>=V_SYNC_START) && (vpos<V_SYNC_END)); // active low
  assign vpos_scaled = vpos[9:1];

  always @(posedge clk)
  begin
    // horizontal position counter
    if(hpos == H_MAX)
    begin
      hpos <= 0;
      // vertical position counter
      if (vpos == V_MAX)
        vpos <= 0;
      else
        vpos <= vpos + 1;
    end
    else
      hpos <= hpos + 1;
  end

  always @(negedge clk)
  begin
    if (hpos>=64 && hpos <577 && !hpos[0]) hpos_scaled = hpos[9:1] - 32;  
  end

  // display_on is set when beam is in "safe" visible frame
  assign display_on = (hpos>=64 && hpos <576) && (vpos<V_DISPLAY);

endmodule

`endif
