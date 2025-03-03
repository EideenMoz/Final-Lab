`timescale 1ns / 1ps

module SevenSegmentDriver(
    input  wire        clk,
    input  wire        rst,
    input  wire [11:0] value,  // up to 9999 decimal
    output reg  [7:0]  seg,    // segments (active low)
    output reg  [3:0]  an      // digit anodes (active low)
);
    // Break down 'value' => thousands, hundreds, tens, ones
    reg [3:0] digit [3:0];
    integer temp;
    
    // Refresh scanning
    reg [15:0] refresh_count = 0;
    reg [1:0]  digit_index   = 0;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            refresh_count <= 0;
            digit_index   <= 0;
        end else begin
            refresh_count <= refresh_count + 1;
            digit_index   <= refresh_count[15:14];
        end
    end
    
    always @(*) begin
        temp     = value; 
        digit[3] = temp / 1000; 
        temp     = temp % 1000;
        digit[2] = temp / 100;
        temp     = temp % 100;
        digit[1] = temp / 10;
        digit[0] = temp % 10;
    end
    
    // Digit -> segment pattern (common anode => active-low)
    reg [7:0] seg_pattern;
    reg [3:0] curr_digit;
    
    always @(*) begin
        curr_digit = digit[digit_index];
        case (curr_digit)
            4'd0: seg_pattern = 8'b11000000; // 0
            4'd1: seg_pattern = 8'b11111001; // 1
            4'd2: seg_pattern = 8'b10100100; // 2
            4'd3: seg_pattern = 8'b10110000; // 3
            4'd4: seg_pattern = 8'b10011001; // 4
            4'd5: seg_pattern = 8'b10010010; // 5
            4'd6: seg_pattern = 8'b10000010; // 6
            4'd7: seg_pattern = 8'b11111000; // 7
            4'd8: seg_pattern = 8'b10000000; // 8
            4'd9: seg_pattern = 8'b10010000; // 9
            default: seg_pattern = 8'b11111111; // blank
        endcase
    end
    
    always @(*) begin
        seg = seg_pattern;
        an  = 4'b1111;
        an[digit_index] = 1'b0;  // light up that digit
    end
endmodule