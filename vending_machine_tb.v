`timescale 1ns / 1ps

module vending_machine_tb;
    // --------------------------------------------------------------------
    // Signals to drive the DUT (Device Under Test)
    // --------------------------------------------------------------------
    reg clk;
    reg rst;
    
    reg [1:0] sw_item;  // select which item (00=50,01=75,10=100,11=135)
    
    reg btnU;  // Insert 50 cents
    reg btnL;  // Insert 25 cents
    reg btnR;  // Insert 10 cents
    reg btnD;  // Cancel
    reg btnC;  // Confirm
    
    // Outputs from DUT
    wire [7:0] seg;
    wire [3:0] an;
    wire led_purchase;
    wire led_insuff;
    
    // --------------------------------------------------------------------
    // Instantiate the TOP-LEVEL module (vending_machine_top)
    // --------------------------------------------------------------------
    vending_machine_top DUT (
        .clk(clk),
        .rst(rst),
        .sw_item(sw_item),
        .btnU(btnU),
        .btnL(btnL),
        .btnR(btnR),
        .btnD(btnD),
        .btnC(btnC),
        .seg(seg),
        .an(an),
        .led_purchase(led_purchase),
        .led_insuff(led_insuff)
    );
    
    // --------------------------------------------------------------------
    // Clock Generation: 100MHz => 10 ns period
    // We'll use #5 for half-period
    // --------------------------------------------------------------------
    initial clk = 0;
    always #5 clk = ~clk;
    
    // --------------------------------------------------------------------
    // Task: Press a button for 'duration' nanoseconds
    // This simulates a clean press since we have debouncers
    // --------------------------------------------------------------------
    task press_button(input reg button_signal, input integer duration);
    begin
        button_signal = 1'b1;
        #(duration);
        button_signal = 1'b0;
        #20; // Wait a little to let the debouncer produce a pulse
    end
    endtask
    
    // --------------------------------------------------------------------
    // Main Test Procedure
    // --------------------------------------------------------------------
    initial begin
        // 1) Initialize signals
        rst = 1'b0;
        sw_item = 2'b00;
        
        {btnU, btnL, btnR, btnD, btnC} = 5'b00000;
        
        // Wait a bit
        #100;
        
        $display("\n--- Starting Vending Machine Test ---");
        
        // 2) Apply reset
        $display("Applying Reset...");
        rst = 1'b1; #15;
        rst = 1'b0; #20;
        $display("Reset de-asserted, state should be SELECT, item=sw_item(00=50c).");
        
        // Quick wait
        #50;
        
        // 3) Scenario #1: Buy item0 (50 cents)
        //    Insert 25c -> insufficient finalize -> insert 25c -> finalize -> success
        $display("\nScenario 1: sw_item=00(50c). Insert 25 + finalize => insufficient => add 25 => finalize => success");
        sw_item = 2'b00; #20;  // item price=50
        // Insert 25c
        press_button(btnL, 20); // Left=25c
        #100;
        
        $display(" Inserted 25c, now finalize with insufficient => led_insuff expected=ON");
        press_button(btnC, 20); // confirm => not enough => led_insuff=1
        #200;
        
        $display(" Insert another 25c => total 50 => finalize => success => led_purchase=1, display change=0");
        press_button(btnL, 20); // another 25c => total=50
        #100;
        press_button(btnC, 20); // finalize => success => vend
        #200;
        
        $display(" Press confirm again to return to SELECT state");
        press_button(btnC, 20);
        #200;
        
        // 4) Scenario #2: Cancel mid-transaction
        $display("\nScenario 2: set item1=75c, insert 50c, then cancel => go back to SELECT");
        sw_item = 2'b01; // 75c
        #50;
        $display(" Insert 50c (Up btn)");
        press_button(btnU, 20);
        #100;
        $display(" Cancel transaction => coin_sum=0, back to SELECT, no vend");
        press_button(btnD, 20);
        #200;
        
        // 5) Scenario #3: Overpay item2=100 => insert 50 + 50 => finalize => vend => check change=0
        $display("\nScenario 3: item2=100c => insert 50 + 50 => confirm => success => no change");
        sw_item = 2'b10; // $1.00
        #50;
        press_button(btnU, 20); // 50
        #50;
        press_button(btnU, 20); // +50 => total 100
        #100;
        press_button(btnC, 20); // finalize => success => 0 change
        #200;
        $display(" Press confirm again to reset to SELECT");
        press_button(btnC, 20);
        #200;
        
        // 6) Scenario #4: Overpay item3=135 => insert 50 + 50 + 50 => total=150 => finalize => change=15
        $display("\nScenario 4: item3=135 => insert 3 x 50 => total=150 => finalize => success => change=15");
        sw_item = 2'b11; // 1.35
        #50;
        press_button(btnU, 20); // +50 => sum=50
        #50;
        press_button(btnU, 20); // +50 => sum=100
        #50;
        press_button(btnU, 20); // +50 => sum=150
        #100;
        $display(" Now finalize => vend => change=15");
        press_button(btnC, 20);
        #200;
        
        $display(" Press confirm again => back to SELECT");
        press_button(btnC, 20);
        #200;
        
        $display("\n--- Test Completed. Observe waveforms / logs for final verification. ---");
        
        // End simulation
        #100;
        $stop;
    end
endmodule