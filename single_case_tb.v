`timescale 1ns/1ps
module single_case_tb;
    reg clk;
    reg rst_n;

    always #10 clk = ~clk;   // 50 MHz

    reg         en;
    reg [15:0]  rx_data;
    wire [7:0]  o_data;
    wire        o_done;

    vit_212_top dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .en      (en),
        .rx_data (rx_data),
        .o_data  (o_data),
        .o_done  (o_done)
    );

    reg [7:0] expected;
    initial begin
        clk     = 0;
        rst_n   = 0;
        en      = 0;
        rx_data = 16'b0;

        repeat(5) @(posedge clk);
        rst_n = 1;

        @(posedge clk);
        rx_data <= 16'b1101101010011110;  // encoded input
        expected <= 8'b11111000;          // original data
        en <= 1'b1;

        wait (o_done == 1'b1);

        @(posedge clk);
        en <= 1'b0;

        if (o_data === expected) begin
            $display("======================================");
            $display("PASS SINGLE CASE");
            $display("Input  (encoded) = %b", rx_data);
            $display("Output (decoded) = %b", o_data);
            $display("Expected         = %b", expected);
            $display("======================================");
        end else begin
            $display("======================================");
            $display("FAIL SINGLE CASE");
            $display("Input  (encoded) = %b", rx_data);
            $display("Output (decoded) = %b", o_data);
            $display("Expected         = %b", expected);
            $display("======================================");
        end

        #50;
        $finish;
    end

endmodule

