module tbu (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        tb_en,

    input  wire [3:0]  pm_00,
    input  wire [3:0]  pm_01,
    input  wire [3:0]  pm_10,
    input  wire [3:0]  pm_11,

    input  wire        tbu_out_00,
    input  wire        tbu_out_01,
    input  wire        tbu_out_10,
    input  wire        tbu_out_11,

    output wire [7:0]  o_data,
    output wire        o_done,
    output wire [2:0]  tb_idx
);
    wire [1:0] min_state;
    min_state u_min_state (
        .pm_00(pm_00),
        .pm_01(pm_01),
        .pm_10(pm_10),
        .pm_11(pm_11),
        .min_state(min_state)
    );

    trc_back u_trc_back (
        .clk        (clk),
        .rst_n      (rst_n),
        .trc_en     (tb_en),
        .min_state  (min_state),

        .tbu_out_00 (tbu_out_00),
        .tbu_out_01 (tbu_out_01),
        .tbu_out_10 (tbu_out_10),
        .tbu_out_11 (tbu_out_11),

        .o_data     (o_data),
        .o_done     (o_done),
        .tb_idx     (tb_idx)
    );

endmodule
