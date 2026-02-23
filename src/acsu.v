module acsu #(
    parameter PM_WIDTH = 4
)(
    input  wire [PM_WIDTH-1:0] pm_00,
    input  wire [PM_WIDTH-1:0] pm_01,
    input  wire [PM_WIDTH-1:0] pm_10,
    input  wire [PM_WIDTH-1:0] pm_11,

    input  wire [1:0] bm00_0,
    input  wire [1:0] bm00_1,
    input  wire [1:0] bm01_0,
    input  wire [1:0] bm01_1,
    input  wire [1:0] bm10_0,
    input  wire [1:0] bm10_1,
    input  wire [1:0] bm11_0,
    input  wire [1:0] bm11_1,

    output wire [PM_WIDTH-1:0] pm_next_00,
    output wire [PM_WIDTH-1:0] pm_next_01,
    output wire [PM_WIDTH-1:0] pm_next_10,
    output wire [PM_WIDTH-1:0] pm_next_11,

    output wire surv_00,
    output wire surv_01,
    output wire surv_10,
    output wire surv_11
);

    acs #(.PM_WIDTH(PM_WIDTH)) u00 (
        .pmA(pm_00),
        .pmB(pm_01),
        .bmA(bm00_0),
        .bmB(bm01_0),
        .pm_next(pm_next_00),
        .surv_bit(surv_00)
    );

    acs #(.PM_WIDTH(PM_WIDTH)) u01 (
        .pmA(pm_10),
        .pmB(pm_11),
        .bmA(bm10_0),
        .bmB(bm11_0),
        .pm_next(pm_next_01),
        .surv_bit(surv_01)
    );

    acs #(.PM_WIDTH(PM_WIDTH)) u10 (
        .pmA(pm_00),
        .pmB(pm_01),
        .bmA(bm00_1),
        .bmB(bm01_1),
        .pm_next(pm_next_10),
        .surv_bit(surv_10)
    );

    acs #(.PM_WIDTH(PM_WIDTH)) u11 (
        .pmA(pm_10),
        .pmB(pm_11),
        .bmA(bm10_1),
        .bmB(bm11_1),
        .pm_next(pm_next_11),
        .surv_bit(surv_11)
    );

endmodule