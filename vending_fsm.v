`timescale 1ns / 1ps

module vending_fsm(
    input  wire        clk,
    input  wire        rst,
    input  wire [1:0]  sw_item,   // item selection
    // Debounced button inputs
    input  wire        db_btnU,   // coin 50
    input  wire        db_btnL,   // coin 25
    input  wire        db_btnR,   // coin 10
    input  wire        db_btnD,   // cancel
    input  wire        db_btnC,   // confirm
    
    // Outputs
    output reg  [11:0] display_val,   // value for 7-seg display
    output reg         led_purchase,
    output reg         led_insuff
);
    // States
    localparam [1:0] ST_SELECT = 2'b00,
                     ST_COIN   = 2'b01,
                     ST_VEND   = 2'b10;
    
    reg [1:0] state, nxt_state;
    
    // Price + coin logic
    reg [11:0] price;     // current item price
    reg [11:0] coin_sum;  // running total inserted
    reg [11:0] change;
    
    reg insufficient_flag;
    
    // Price lookup function (unchanged)
    function [11:0] get_price(input [1:0] sel);
        case(sel)
            2'b00: get_price = 12'd50;   // e.g. 50 cents
            2'b01: get_price = 12'd75;   // 75 cents
            2'b10: get_price = 12'd100;  // 1.00
            2'b11: get_price = 12'd135;  // 1.35
        endcase
    endfunction
    
    // 1) State register
    always @(posedge clk or posedge rst) begin
        if (rst)
            state <= ST_SELECT;
        else
            state <= nxt_state;
    end
    
    // 2) Next-state logic (combinational)
    always @(*) begin
        nxt_state = state;
        case(state)
            ST_SELECT: begin
                // Wait for first coin or confirm
                if (db_btnU)       nxt_state = ST_COIN;
                else if (db_btnL)  nxt_state = ST_COIN;
                else if (db_btnR)  nxt_state = ST_COIN;
                else if (db_btnC)  nxt_state = ST_COIN;
            end
            
            ST_COIN: begin
                // Insert coins, finalize or cancel
                if (db_btnD)
                    nxt_state = ST_SELECT;
                else if (db_btnC) begin
                    if (coin_sum >= price)
                        nxt_state = ST_VEND;
                    else
                        nxt_state = ST_COIN;
                end
            end
            
            ST_VEND: begin
                // Show change. Wait for next confirm/cancel
                if (db_btnC || db_btnD)
                    nxt_state = ST_SELECT;
            end
            
            default: nxt_state = ST_SELECT;
        endcase
    end
    
    // 3) Outputs & coin_sum updates (sequential)
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            coin_sum          <= 12'd0;
            price             <= 12'd0;
            change            <= 12'd0;
            insufficient_flag <= 1'b0;
            
            led_purchase      <= 1'b0;
            led_insuff        <= 1'b0;
            
            display_val       <= 12'd0;
        end else begin
            case(state)
                ST_SELECT: begin
                    // Continuously track the chosen item's price
                    price <= get_price(sw_item);
                    coin_sum <= 0;
                    insufficient_flag <= 1'b0;
                    led_purchase <= 1'b0;
                    led_insuff   <= 1'b0;
                    
                    // If a coin is pressed or confirm in select
                    if (db_btnU) 
                        coin_sum <= 12'd50;
                    else if (db_btnL)
                        coin_sum <= 12'd25;
                    else if (db_btnR)
                        coin_sum <= 12'd10;
                    else if (db_btnC) begin
                        if (coin_sum >= price)
                            change <= coin_sum - price;
                        else
                            insufficient_flag <= 1'b1;
                    end
                    
                    display_val <= price; // show item price
                end
                
                ST_COIN: begin
                    // Insert coins
                    if (db_btnU)
                        coin_sum <= coin_sum + 12'd50;
                    else if (db_btnL)
                        coin_sum <= coin_sum + 12'd25;
                    else if (db_btnR)
                        coin_sum <= coin_sum + 12'd10;
                    
                    // If enough coins are inserted, clear insuff
                    if (coin_sum >= price)
                        insufficient_flag <= 1'b0;
                    
                    // finalize
                    if (db_btnC) begin
                        if (coin_sum >= price) begin
                            change       <= coin_sum - price;
                            led_purchase <= 1'b1; // vend possible
                        end else begin
                            led_insuff   <= 1'b1;
                            insufficient_flag <= 1'b1;
                        end
                    end
                    
                    // cancel
                    if (db_btnD) begin
                        coin_sum          <= 0;
                        led_purchase      <= 0;
                        led_insuff        <= 0;
                        insufficient_flag <= 0;
                    end
                    
                    display_val <= coin_sum; // show current sum
                end
                
                ST_VEND: begin
                    // Vend success, show change
                    coin_sum          <= 0;
                    led_insuff        <= 0;
                    insufficient_flag <= 0;
                    
                    display_val <= change;
                    // led_purchase remains high if previously set
                end
            endcase
        end
    end
endmodule