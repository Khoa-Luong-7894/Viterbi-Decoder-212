module tbu (
    input  wire clk,
    input  wire rst_n,

    input  wire        tb_en,
    input  wire        load_state,
    input  wire [1:0]  start_state,
    input  wire [3:0]  surv_bits,

    output reg         o_data
);

    reg [1:0] cur_state;
    reg       surv_sel;

    // Chọn survivor bit theo current state
    always @(*) begin
        case (cur_state)
            2'b00: surv_sel = surv_bits[0];
            2'b01: surv_sel = surv_bits[1];
            2'b10: surv_sel = surv_bits[2];
            2'b11: surv_sel = surv_bits[3];
            default: surv_sel = 1'b0;
        endcase
    end

    // State update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            cur_state <= 2'b00;
        else if (load_state)
            cur_state <= start_state;
        else if (tb_en)
            cur_state <= {cur_state[0], surv_sel};
    end

    // Output decoded bit
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            o_data <= 1'b0;
        else if (tb_en)
            o_data <= surv_sel;
    end

endmodule