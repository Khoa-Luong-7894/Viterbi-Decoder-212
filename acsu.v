module acsu (
    input  wire [3:0] pm_00,
    input  wire [3:0] pm_01,
    input  wire [3:0] pm_10,
    input  wire [3:0] pm_11,

    input  wire [1:0] acs_bm00_0,
    input  wire [1:0] acs_bm00_1,
    input  wire [1:0] acs_bm01_0,
    input  wire [1:0] acs_bm01_1,
    input  wire [1:0] acs_bm10_0,
    input  wire [1:0] acs_bm10_1,
    input  wire [1:0] acs_bm11_0,
    input  wire [1:0] acs_bm11_1,

    output wire [3:0] pm_next_00,
    output wire [3:0] pm_next_01,
    output wire [3:0] pm_next_10,
    output wire [3:0] pm_next_11,

    output wire smu_surv_bit_00,
    output wire smu_surv_bit_01,
    output wire smu_surv_bit_10,
    output wire smu_surv_bit_11
);

    // ACS for next state 00
    // prev 00 (u=0) vs prev 01 (u=0)
    acs acs_00 (
        .pmA      (pm_00),
        .pmB      (pm_01),
        .bmA      (acs_bm00_0),
        .bmB      (acs_bm01_0),
        .pm_next  (pm_next_00),
        .surv_bit (smu_surv_bit_00)
    );

    // ACS for next state 01
    // prev 10 (u=0) vs prev 11 (u=0)
    acs acs_01 (
        .pmA      (pm_10),
        .pmB      (pm_11),
        .bmA      (acs_bm10_0),
        .bmB      (acs_bm11_0),
        .pm_next  (pm_next_01),
        .surv_bit (smu_surv_bit_01)
    );

    // ACS for next state 10
    // prev 00 (u=1) vs prev 01 (u=1)
    acs acs_10 (
        .pmA      (pm_00),
        .pmB      (pm_01),
        .bmA      (acs_bm00_1),
        .bmB      (acs_bm01_1),
        .pm_next  (pm_next_10),
        .surv_bit (smu_surv_bit_10)
    );

    // ACS for next state 11
    // prev 10 (u=1) vs prev 11 (u=1)
    acs acs_11 (
        .pmA      (pm_10),
        .pmB      (pm_11),
        .bmA      (acs_bm10_1),
        .bmB      (acs_bm11_1),
        .pm_next  (pm_next_11),
        .surv_bit (smu_surv_bit_11)
    );

endmodule

