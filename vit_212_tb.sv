`timescale 1ns/1ps
module vit_212_tb;
    localparam T     = 8;
    localparam ENC_W = 16;

    logic clk;
    logic rst_n;
    logic en;
    logic [ENC_W-1:0] rx_data;
    logic [T-1:0]     o_data;
    logic             o_done;

    // Instance DUT
    vit_212_top dut (
        .clk     (clk),
        .rst_n   (rst_n),
        .en      (en),
        .rx_data (rx_data),
        .o_data  (o_data),
        .o_done  (o_done)
    );

    // Clock Generation: 100MHz [cite: 133]
    always #5 clk = ~clk;

    int fin, fout;
    logic [ENC_W-1:0] in_vec;
    logic [T-1:0]     exp_vec;

    int test_id;
    int pass_cnt;
    int fail_cnt;

    // Task Reset DUT: Đảm bảo reset sạch sẽ [cite: 135, 136]
    task automatic reset_dut;
    begin
        rst_n <= 0;
        en    <= 0;
        rx_data <= '0;
        repeat (2) @(posedge clk);
        rst_n <= 1;
        repeat (1) @(posedge clk); // Đợi 1 chu kỳ để hệ thống ổn định
    end
    endtask

    // Task chạy 1 trường hợp kiểm thử [cite: 138-144]
    task automatic run_one_case(
        input logic [ENC_W-1:0] encoded,
        input logic [T-1:0]     expected
    );
    begin
        reset_dut();
        
        // Gán dữ liệu đồng bộ với Clock để tránh race condition
        @(posedge clk);
        rx_data <= encoded;
        en      <= 1'b1;

        // Chờ tín hiệu hoàn thành từ DUT
        wait(o_done === 1'b1);
        
        // QUAN TRỌNG: Đợi thêm 1 nhịp clock để o_data được cập nhật bit cuối [cite: 139]
        @(posedge clk);

        if (o_data !== expected) begin
            $display("=================================");
            $display("FAIL CASE %0d", test_id);
            $display("Input (encoded) = %b", encoded);
            $display("Output (decoded)= %b", o_data);
            $display("Expected        = %b", expected);
            $display("=================================");
            fail_cnt++;
        end else begin
            $display("PASS CASE %0d : %b -> %b", test_id, encoded, o_data);
            pass_cnt++;
        end

        // Kết thúc case
        en <= 1'b0;
        repeat (3) @(posedge clk);
    end
    endtask

    initial begin
        // Khởi tạo các tín hiệu
        clk      = 1'b0;
        rst_n    = 1'b0;
        en       = 1'b0;
        rx_data  = '0;
        pass_cnt = 0;
        fail_cnt = 0;
        test_id  = 0;

        // Mở file dữ liệu [cite: 147, 148]
        fin  = $fopen("input.txt",  "r");
        fout = $fopen("output.txt", "r");

        if (fin == 0 || fout == 0) begin
            $fatal("ERROR: Cannot open input.txt or output.txt");
        end

        // Vòng lặp kiểm thử sử dụng fscanf để tăng độ tin cậy [cite: 151]
        while (!$feof(fin) && !$feof(fout)) begin
            // Đọc trực tiếp định dạng bit từ file
            if ($fscanf(fin, "%b\n", in_vec) != 1) break;
            if ($fscanf(fout, "%b\n", exp_vec) != 1) break;

            test_id++;
            run_one_case(in_vec, exp_vec);
        end

        // In báo cáo tổng kết [cite: 152]
        $display("=================================");
        $display("TEST SUMMARY");
        $display("TOTAL : %0d", test_id);
        $display("PASS  : %0d", pass_cnt);
        $display("FAIL  : %0d", fail_cnt);
        $display("=================================");

        $fclose(fin);
        $fclose(fout);
        $finish;
    end

endmodule