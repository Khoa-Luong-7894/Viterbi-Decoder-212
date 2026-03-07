module smu (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        smu_we,
    input  wire [2:0]  fw_idx,

    input  wire        smu_surv_bit_00,
    input  wire        smu_surv_bit_01,
    input  wire        smu_surv_bit_10,
    input  wire        smu_surv_bit_11,

    input  wire [2:0]  tb_idx,

    output wire        tbu_out_00,
    output wire        tbu_out_01,
    output wire        tbu_out_10,
    output wire        tbu_out_11
);
    reg [7:0] smu_path_00;
    reg [7:0] smu_path_01;
    reg [7:0] smu_path_10;
    reg [7:0] smu_path_11;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            smu_path_00 <= 8'b0;
            smu_path_01 <= 8'b0;
            smu_path_10 <= 8'b0;
            smu_path_11 <= 8'b0;
        end else if (smu_we) begin
            smu_path_00[fw_idx] <= smu_surv_bit_00;
            smu_path_01[fw_idx] <= smu_surv_bit_01;
            smu_path_10[fw_idx] <= smu_surv_bit_10;
            smu_path_11[fw_idx] <= smu_surv_bit_11;
        end
    end

    assign tbu_out_00 = smu_path_00[tb_idx];
    assign tbu_out_01 = smu_path_01[tb_idx];
    assign tbu_out_10 = smu_path_10[tb_idx];
    assign tbu_out_11 = smu_path_11[tb_idx];

endmodule
