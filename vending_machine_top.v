`timescale 1ns / 1ps

module vending_machine_top(
    input  wire clk,        // 100 MHz clock
    input  wire rst,        // Asynchronous reset (SW15)
    
    // Switches for item selection: sw_item[1:0]
    input  wire [1:0] sw_item,
    
    // Push-buttons (raw), each will be debounced
    input  wire btnU,  // Insert 50 cents
    input  wire btnL,  // Insert 25 cents
    input  wire btnR,  // Insert 10 cents
    input  wire btnD,  // Cancel
    input  wire btnC,  // Confirm
    
    // 7-segment display outputs
    output wire [7:0] seg,  // CA..CG,DP
    output wire [3:0] an,   // four digit anodes
    
    // LED indicators
    output wire [15:0] led_purchase, // LEDs for successful vend (now 16-bit)
    output wire led_insuff    // LED for insufficient funds
);
    // ----------------------------------------------------------
    // 1) Debounce the 5 push-buttons
    // ----------------------------------------------------------
    wire db_btnU, db_btnL, db_btnR, db_btnD, db_btnC;
    
    Debouncer debU (
        .clk(clk),
        .rst(rst),
        .btn_in(btnU),
        .btn_out(db_btnU)
    );
    Debouncer debL (
        .clk(clk),
        .rst(rst),
        .btn_in(btnL),
        .btn_out(db_btnL)
    );
    Debouncer debR (
        .clk(clk),
        .rst(rst),
        .btn_in(btnR),
        .btn_out(db_btnR)
    );
    Debouncer debD (
        .clk(clk),
        .rst(rst),
        .btn_in(btnD),
        .btn_out(db_btnD)
    );
    Debouncer debC (
        .clk(clk),
        .rst(rst),
        .btn_in(btnC),
        .btn_out(db_btnC)
    );
    
    // ----------------------------------------------------------
    // 2) Instantiate the FSM
    //    - Controls coin sums, states, price, change
    //    - Produces led_purchase, led_insuff, and a display value
    // ----------------------------------------------------------
    wire [11:0] display_val;    // value to show on 7-seg
    wire fsm_purchase, fsm_insuff;
    
    vending_fsm fsm_unit (
        .clk(clk),
        .rst(rst),
        .sw_item(sw_item),
        
        .db_btnU(db_btnU),
        .db_btnL(db_btnL),
        .db_btnR(db_btnR),
        .db_btnD(db_btnD),
        .db_btnC(db_btnC),
        
        .display_val(display_val),
        .led_purchase(fsm_purchase),
        .led_insuff(fsm_insuff)
    );
    
    // Drive top-level LED outputs from FSM signals
    // Update led_purchase to use all 16 bits
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            led_purchase <= 16'h0000;
        end
        else if (fsm_purchase) begin
            led_purchase <= 16'hFFFF; // All LEDs on when purchase is successful
        end
        else begin
            led_purchase <= 16'h0000; // All LEDs off
        end
    end

    assign led_insuff   = fsm_insuff;
    
    // ----------------------------------------------------------
    // 3) Display the `display_val` on the 7-segment
    // ----------------------------------------------------------
    SevenSegmentDriver sseg_unit (
        .clk(clk),
        .rst(rst),
        .value(display_val),
        .seg(seg),
        .an(an)
    );
    
endmodule