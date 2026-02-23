`timescale 1ns/1ps

module vit_212_tb();

    parameter PM_WIDTH  = 4;
    parameter DEPTH     = 8;
    parameter FRAME_NUM = 3;
    parameter CLK_PERIOD = 10;

    reg clk;
    reg rst_n;
    reg i_valid;
    reg [1:0] i_data;
    reg i_last;

    wire o_valid;
    wire o_data;
    wire o_last;

    //-------------------------------------------------
    // DUT
    //-------------------------------------------------
    vit_212_top #(
        .PM_WIDTH(PM_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .i_valid(i_valid),
        .i_data(i_data),
        .i_last(i_last),
        .o_valid(o_valid),
        .o_data(o_data),
        .o_last(o_last)
    );

    //-------------------------------------------------
    // Clock
    //-------------------------------------------------
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    //-------------------------------------------------
    // Frame symbols
    //-------------------------------------------------
    reg [1:0] frame_symbols [0:DEPTH-1];

    initial begin
        frame_symbols[0] = 2'b11;
        frame_symbols[1] = 2'b01;
        frame_symbols[2] = 2'b10;
        frame_symbols[3] = 2'b01;
        frame_symbols[4] = 2'b00;
        frame_symbols[5] = 2'b01;
        frame_symbols[6] = 2'b01;
        frame_symbols[7] = 2'b11;
    end

    //-------------------------------------------------
    // Output capture
    //-------------------------------------------------
    reg [DEPTH-1:0] lifo_buffer;
    integer bit_ptr  = 0;
    integer frame_id = 0;
    integer i, f;

    always @(posedge clk) begin
        if (o_valid) begin
            lifo_buffer[bit_ptr] <= o_data;
            bit_ptr <= bit_ptr + 1;
        end

        if (o_last) begin
            $display("\n[TIME %0t] ===== Frame %0d Finished =====",
                     $time, frame_id);

            $write("Decoded: ");
            for (i = DEPTH-1; i >= 0; i = i - 1)
                $write("%b", lifo_buffer[i]);
            $write("\n");

            bit_ptr  <= 0;
            frame_id <= frame_id + 1;
        end
    end

    //-------------------------------------------------
    // Stimulus
    //-------------------------------------------------
    initial begin
        // Initial values
        rst_n   = 0;   // active-low reset
        i_valid = 0;
        i_last  = 0;
        i_data  = 0;
        lifo_buffer = 0;

        // Hold reset active
        repeat(4) @(posedge clk);

        // Release reset synchronously
        rst_n <= 1;

        repeat(2) @(posedge clk);
        $display("=== Start 3-Frame Continuous Test ===");

        //-------------------------------------------------
        // Send 3 frames continuously
        //-------------------------------------------------
        for (f = 0; f < FRAME_NUM; f = f + 1) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                @(posedge clk);
                i_valid <= 1;
                i_data  <= frame_symbols[i];

                // Assert i_last at end of EVERY frame
                if (i == DEPTH-1)
                    i_last <= 1;
                else
                    i_last <= 0;
            end
        end

        //-------------------------------------------------
        // Stop input
        //-------------------------------------------------
        @(posedge clk);
        i_valid <= 0;
        i_last  <= 0;

        //-------------------------------------------------
        // Wait until final flush
        //-------------------------------------------------
        wait(o_last);
        repeat(5) @(posedge clk);

        $display("\n=== Simulation Finished ===");
        $finish;
    end

endmodule