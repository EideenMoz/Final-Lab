`timescale 1ns / 1ps

module Debouncer(
    input  wire clk,
    input  wire rst,
    input  wire btn_in,
    output reg  btn_out
);
    // Simple synchronizer
    reg sync_0, sync_1;
    // Debounce counter (~20ms at 100MHz => 2,000,000 cycles)
    parameter THRESH = 2000000;
    
    reg [21:0] count;
    reg stable_state;
    
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            sync_0       <= 1'b0;
            sync_1       <= 1'b0;
            count        <= 0;
            stable_state <= 0;
            btn_out      <= 0;
        end else begin
            // 2-stage sync
            sync_0 <= btn_in;
            sync_1 <= sync_0;
            
            if (sync_1 != stable_state) begin
                // input changed, increment counter
                if (count < THRESH)
                    count <= count + 1;
                else begin
                    // stable for long enough
                    stable_state <= sync_1;
                    count <= 0;
                    
                    // If new stable is HIGH, generate a 1-cycle pulse
                    btn_out <= (sync_1 == 1'b1) ? 1'b1 : 1'b0;
                end
            end else begin
                // no change
                count <= 0;
                btn_out <= 0;
            end
        end
    end
endmodule