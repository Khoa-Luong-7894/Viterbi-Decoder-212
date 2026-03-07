module vit_212_top (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire [15:0] rx_data,

    output wire [7:0]  o_data,
    output wire        o_done
);
    // CTRL
    wire load_rx;
    wire ext_en;
    wire pm_we;
    wire smu_we;
    wire tb_en;
    wire [2:0] fw_idx;

    ctrl u_ctrl (
        .clk     (clk),
        .rst_n   (rst_n),
        .en      (en),
        .o_done  (o_done),

        .load_rx (load_rx),
        .ext_en  (ext_en),
        .pm_we   (pm_we),
        .smu_we  (smu_we),
        .tb_en   (tb_en),
        .fw_idx  (fw_idx)
    );
    // EXT
    wire [1:0] bmu_sym;

    ext u_ext (
        .clk     (clk),
        .rst_n   (rst_n),
        .load_rx (load_rx),
        .ext_en  (ext_en),
        .rx_data (rx_data),
        .bmu_sym (bmu_sym)
    );
    // BMU
    wire [1:0] acs_bm00_0, acs_bm00_1;
    wire [1:0] acs_bm01_0, acs_bm01_1;
    wire [1:0] acs_bm10_0, acs_bm10_1;
    wire [1:0] acs_bm11_0, acs_bm11_1;

    bmu u_bmu (
        .bmu_sym     (bmu_sym),

        .acs_bm00_0  (acs_bm00_0),
        .acs_bm00_1  (acs_bm00_1),
        .acs_bm01_0  (acs_bm01_0),
        .acs_bm01_1  (acs_bm01_1),
        .acs_bm10_0  (acs_bm10_0),
        .acs_bm10_1  (acs_bm10_1),
        .acs_bm11_0  (acs_bm11_0),
        .acs_bm11_1  (acs_bm11_1)
    );
    // ACSU
    wire [3:0] pm_next_00, pm_next_01;
    wire [3:0] pm_next_10, pm_next_11;
    wire smu_surv_bit_00;
    wire smu_surv_bit_01;
    wire smu_surv_bit_10;
    wire smu_surv_bit_11;
    wire [3:0] pm_00, pm_01, pm_10, pm_11;

    acsu u_acsu (
        .pm_00           (pm_00),
        .pm_01           (pm_01),
        .pm_10           (pm_10),
        .pm_11           (pm_11),

        .acs_bm00_0      (acs_bm00_0),
        .acs_bm00_1      (acs_bm00_1),
        .acs_bm01_0      (acs_bm01_0),
        .acs_bm01_1      (acs_bm01_1),
        .acs_bm10_0      (acs_bm10_0),
        .acs_bm10_1      (acs_bm10_1),
        .acs_bm11_0      (acs_bm11_0),
        .acs_bm11_1      (acs_bm11_1),

        .pm_next_00      (pm_next_00),
        .pm_next_01      (pm_next_01),
        .pm_next_10      (pm_next_10),
        .pm_next_11      (pm_next_11),

        .smu_surv_bit_00 (smu_surv_bit_00),
        .smu_surv_bit_01 (smu_surv_bit_01),
        .smu_surv_bit_10 (smu_surv_bit_10),
        .smu_surv_bit_11 (smu_surv_bit_11)
    );
    // PMU
    pmu u_pmu (
        .clk        (clk),
        .rst_n      (rst_n),
        .pm_we      (pm_we),

        .pm_next_00 (pm_next_00),
        .pm_next_01 (pm_next_01),
        .pm_next_10 (pm_next_10),
        .pm_next_11 (pm_next_11),

        .pm_00      (pm_00),
        .pm_01      (pm_01),
        .pm_10      (pm_10),
        .pm_11      (pm_11)
    );
    // SMU
    wire [2:0] tb_idx;
    wire tbu_out_00, tbu_out_01, tbu_out_10, tbu_out_11;

    smu u_smu (
        .clk             (clk),
        .rst_n           (rst_n),

        .smu_we          (smu_we),
        .fw_idx          (fw_idx),

        .smu_surv_bit_00 (smu_surv_bit_00),
        .smu_surv_bit_01 (smu_surv_bit_01),
        .smu_surv_bit_10 (smu_surv_bit_10),
        .smu_surv_bit_11 (smu_surv_bit_11),

        .tb_idx          (tb_idx),
        .tbu_out_00      (tbu_out_00),
        .tbu_out_01      (tbu_out_01),
        .tbu_out_10      (tbu_out_10),
        .tbu_out_11      (tbu_out_11)
    );
    // TBU (Traceback + Output)
    tbu u_tbu (
        .clk        (clk),
        .rst_n      (rst_n),
        .tb_en      (tb_en),

        .pm_00      (pm_00),
        .pm_01      (pm_01),
        .pm_10      (pm_10),
        .pm_11      (pm_11),

        .tbu_out_00 (tbu_out_00),
        .tbu_out_01 (tbu_out_01),
        .tbu_out_10 (tbu_out_10),
        .tbu_out_11 (tbu_out_11),

        .o_data     (o_data),
        .o_done     (o_done),
        .tb_idx     (tb_idx)
    );

endmodule
