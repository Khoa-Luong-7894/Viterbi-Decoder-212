module acs #(
    parameter PM_WIDTH = 4
)(
    input  wire [PM_WIDTH-1:0] pmA,
    input  wire [PM_WIDTH-1:0] pmB,
    input  wire [1:0] bmA,
    input  wire [1:0] bmB,

    output wire [PM_WIDTH-1:0] pm_next,
    output wire                surv_bit
);

    localparam [PM_WIDTH-1:0] INF = {PM_WIDTH{1'b1}};

    wire [PM_WIDTH-1:0] bmA_ext = {{(PM_WIDTH-2){1'b0}}, bmA};
    wire [PM_WIDTH-1:0] bmB_ext = {{(PM_WIDTH-2){1'b0}}, bmB};

    wire [PM_WIDTH:0] sumA = pmA + bmA_ext;
    wire [PM_WIDTH:0] sumB = pmB + bmB_ext;

    wire overflowA = sumA[PM_WIDTH];
    wire overflowB = sumB[PM_WIDTH];

    wire [PM_WIDTH-1:0] costA = (pmA == INF) ? INF : (overflowA)  ? INF : sumA[PM_WIDTH-1:0];
    wire [PM_WIDTH-1:0] costB = (pmB == INF) ? INF : (overflowB)  ? INF : sumB[PM_WIDTH-1:0];
    wire chooseB = (costB < costA);

    assign surv_bit = chooseB;
    assign pm_next  = chooseB ? costB : costA;

endmodule