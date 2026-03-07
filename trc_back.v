module trc_back (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       trc_en,
    input  wire [1:0] min_state,

    input  wire       tbu_out_00,
    input  wire       tbu_out_01,
    input  wire       tbu_out_10,
    input  wire       tbu_out_11,

    output reg  [7:0] o_data,     // packed decoded data
    output reg        o_done,    // DONE pulse
    output reg  [2:0] tb_idx
);
    localparam TB_IDLE   = 2'd0;
    localparam TB_ACTIVE = 2'd1;
    localparam TB_DONE   = 2'd2;

    reg [1:0] tb_state;
    reg [1:0] cur_state;
    reg [1:0] prev_state;
    reg       surv_bit;
    reg [7:0] dec_data;
    reg [3:0] bit_cnt;

    always @(*) begin
        case (cur_state)
            2'b00: surv_bit = tbu_out_00;
            2'b01: surv_bit = tbu_out_01;
            2'b10: surv_bit = tbu_out_10;
            default: surv_bit = tbu_out_11;
        endcase

        prev_state = {cur_state[0], surv_bit};
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            tb_state  <= TB_IDLE;
            cur_state <= 2'b00;
            tb_idx    <= 3'd0;
            dec_data  <= 8'b0;
            bit_cnt   <= 4'd0;
            o_data    <= 8'b0;
            o_done   <= 1'b0;
        end else begin
            o_done <= 1'b0;
            case (tb_state)
                TB_IDLE: begin
                    tb_idx   <= 3'd0;
                    bit_cnt  <= 4'd0;
                    dec_data <= 8'b0;
                    if (trc_en) begin
                        cur_state <= min_state;
                        tb_idx    <= 3'd7;   
                        tb_state  <= TB_ACTIVE;
                    end
                end
                TB_ACTIVE: begin
                    // shift decoded bit (giữ nguyên thứ tự)
                    dec_data <= {cur_state[1], dec_data[7:1]};
                    bit_cnt  <= bit_cnt + 1'b1;
                    cur_state <= prev_state;
                    if (tb_idx == 0) begin
                        tb_state <= TB_DONE;
                    end else begin
                        tb_idx <= tb_idx - 1'b1;
                    end
                end-
                TB_DONE: begin
                    o_data  <= dec_data;
                    o_done <= 1'b1;
                    tb_state <= TB_IDLE;
                end
                default: begin
                    tb_state <= TB_IDLE;
                end
            endcase
        end
    end

endmodule
