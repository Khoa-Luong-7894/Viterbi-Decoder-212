`timescale 1ns/1ps

module vit_212_multi_frame_tb();

    parameter DEPTH = 8;
    parameter CLK_PERIOD = 10;

    reg clk, rst_n;
    reg i_valid, i_last;
    reg [1:0] i_data;

    wire o_valid, o_data, o_last;
    
    // Mảng chứa dữ liệu đầu vào (8 cặp bit mã hóa)
    reg [1:0] test_input [0:7];
    initial begin
        test_input[0] = 2'b11; test_input[1] = 2'b10;
        test_input[2] = 2'b00; test_input[3] = 2'b01;
        test_input[4] = 2'b01; test_input[5] = 2'b11;
        test_input[6] = 2'b11; test_input[7] = 2'b10;
    end

    // DUT
    vit_212_top #(.DEPTH(DEPTH)) dut (
        .clk(clk), .rst_n(rst_n),
        .i_valid(i_valid), .i_data(i_data), .i_last(i_last),
        .o_valid(o_valid), .o_data(o_data), .o_last(o_last)
    );

    // Clock
    initial clk = 0;
    always #(CLK_PERIOD/2) clk = ~clk;

    // LIFO Buffer để lưu bit giải mã của từng Frame
    reg [DEPTH-1:0] lifo_mem [0:2]; // Lưu 3 frames
    integer frame_recv_ptr = 0;
    integer bit_recv_ptr = 0;

    // Ghi nhận đầu ra
    always @(posedge clk) begin
        if (o_valid) begin
            lifo_mem[frame_recv_ptr][bit_recv_ptr] <= o_data;
            bit_recv_ptr <= bit_recv_ptr + 1;
        end
        if (o_last) begin
            $display("[TIME %t] Frame %d Decoded (Reverse): %b", $time, frame_recv_ptr, lifo_mem[frame_recv_ptr]);
            frame_recv_ptr <= frame_recv_ptr + 1;
            bit_recv_ptr <= 0;
        end
    end

    // Stimulus điều khiển 3 Frame
    integer f, b;
    initial begin
        rst_n = 0; i_valid = 0; i_last = 0; i_data = 0;
        #(CLK_PERIOD * 3) rst_n = 1;
        #(CLK_PERIOD);

        $display("--- Starting 3-Frame Ping-Pong Test ---");

        for (f = 0; f < 3; f = f + 1) begin
            $display("Feeding Frame %d...", f);
            for (b = 0; b < DEPTH; b = b + 1) begin
                @(posedge clk);
                i_valid = 1;
                i_data = test_input[b];
                // i_last chỉ bật ở cuối Frame thứ 3 để kết thúc simulation
                i_last = (f == 2 && b == DEPTH - 1); 
            end
        end

        // Kết thúc nạp dữ liệu
        @(posedge clk);
        i_valid = 0; i_last = 0;

        // Chờ đợi tất cả 3 frame giải mã xong
        wait(frame_recv_ptr == 3);
        #(CLK_PERIOD * 10);
        $display("--- All Frames Processed ---");
        $finish;
    end

endmodule
