module acs (
    input  wire [3:0] pmA,
    input  wire [3:0] pmB,
    input  wire [1:0] bmA,
    input  wire [1:0] bmB,

    output wire [3:0] pm_next,
    output wire       surv_bit
);

    localparam [3:0] INF = 4'b1111;

    wire [3:0] bmA_ext;
    wire [3:0] bmB_ext;
    wire [4:0] sumA;
    wire [4:0] sumB;
    wire [3:0] costA;
    wire [3:0] costB;
    wire       selB;

    assign bmA_ext = {2'b0, bmA};
    assign bmB_ext = {2'b0, bmB};
    assign sumA = pmA + bmA_ext;
    assign sumB = pmB + bmB_ext;
    assign costA = (pmA == INF) ? INF : (sumA[4] ? INF : sumA[3:0]);
    assign costB = (pmB == INF) ? INF : (sumB[4] ? INF : sumB[3:0]);
    assign selB     = (costB < costA);
    assign surv_bit = selB;
    assign pm_next  = selB ? costB : costA;

endmodule
