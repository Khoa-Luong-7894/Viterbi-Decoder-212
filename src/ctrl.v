module ctrl #(
    parameter DEPTH = 8
)(
    input  wire clk,
    input  wire rst_n,
    input  wire i_valid,
    input  wire i_last,

    output reg  pm_we,
    output reg  smu_we,
    
    output reg  smu_re,  
    output reg  tb_en,     
    
    output reg  bank_sel,
    output reg  load_state,

    output reg  [2:0] fw_idx,
    output reg  [2:0] tb_idx,

    output reg  o_valid,
    output reg  o_last
);

    localparam S_IDLE  = 2'd0;
    localparam S_RUN   = 2'd1;
    localparam S_FLUSH = 2'd2;

    reg [1:0] state;
    reg last_seen;
    
    // Thanh ghi dịch để tạo delay 2 nhịp chờ PMU tính toán xong min_state
    reg s_done_1; 
    reg s_done_2; 

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= S_IDLE;
            fw_idx     <= 3'd0;
            tb_idx     <= 3'd0;
            bank_sel   <= 1'b0;
            last_seen  <= 1'b0;
            
            pm_we      <= 1'b0; smu_we     <= 1'b0;
            smu_rd_en  <= 1'b0; tbu_en     <= 1'b0;
            load_state <= 1'b0; o_valid    <= 1'b0; o_last <= 1'b0;
            s_done_1   <= 1'b0; s_done_2   <= 1'b0;
        end
        else begin
            // 1. FORWARD LOGIC (GHI DỮ LIỆU)
            pm_we  <= (i_valid && state != S_FLUSH);
            smu_we <= (i_valid && state != S_FLUSH);

            if (pm_we) begin
                if (fw_idx == DEPTH - 1) begin
                    fw_idx   <= 3'd0;
                    bank_sel <= ~bank_sel;
                    s_done_1 <= 1'b1; // Bắt đầu đếm nhịp chờ PMU
                end else begin
                    fw_idx   <= fw_idx + 1'b1;
                    s_done_1 <= 1'b0;
                end
            end else begin
                s_done_1 <= 1'b0;
            end

            if (i_valid && i_last) last_seen <= 1'b1;

            // 2. PIPELINE DELAY (CHỜ PMU VÀ SMU ỔN ĐỊNH)
            s_done_2 <= s_done_1; // Trễ thêm 1 nhịp (Tổng 2 nhịp từ lúc pm_we=1)

            // 3. TRACEBACK LOGIC (ĐỌC VÀ DỊCH NGƯỢC)
            // A. Nạp trạng thái: Thực hiện đúng lúc min_state đã chốt
            load_state <= s_done_2;
            // B. Đọc SMU: Bắt đầu cùng lúc với lệnh load_state
            if (s_done_2) begin
                smu_rd_en <= 1'b1;
                tb_idx    <= DEPTH - 1;
            end else if (smu_rd_en) begin
                if (tb_idx == 0) smu_rd_en <= 1'b0;
                else tb_idx <= tb_idx - 1'b1;
            end
            // C. Dịch TBU: Phải trễ 1 nhịp so với smu_rd_en vì RAM mất 1 clock để xuất data
            tbu_en <= smu_rd_en;
            // D. Báo Valid: o_data của TBU tốn thêm 1 clock nữa để chốt ra ngoài
            o_valid <= tbu_en;


            // 4. FSM QUẢN LÝ FLUSH (KẾT THÚC)
            o_last <= 1'b0;
            case (state)
                S_IDLE: if (i_valid) state <= S_RUN;
                
                S_RUN:  if (last_seen && !i_valid && !pm_we) state <= S_FLUSH;
                
                S_FLUSH: begin
                    // Đợi luồng Traceback chạy xong toàn bộ (vắt cạn pipeline)
                    if (!smu_rd_en && !tbu_en && !o_valid && !s_done_1 && !s_done_2) begin
                        o_last    <= 1'b1;
                        state     <= S_IDLE;
                        last_seen <= 1'b0;
                    end
                end
            endcase
        end
    end
endmodule