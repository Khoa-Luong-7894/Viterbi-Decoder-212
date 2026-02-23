module pmu (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        pm_we,

    input  wire [3:0]  pm_next_00,
    input  wire [3:0]  pm_next_01,
    input  wire [3:0]  pm_next_10,
    input  wire [3:0]  pm_next_11,

    output reg  [3:0]  pm_00,
    output reg  [3:0]  pm_01,
    output reg  [3:0]  pm_10,
    output reg  [3:0]  pm_11
);

    localparam [3:0] INF = 4'b1111;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pm_00 <= 4'b0000; 
            pm_01 <= INF;
            pm_10 <= INF;
            pm_11 <= INF;
        end else if (pm_we) begin
            pm_00 <= pm_next_00;
            pm_01 <= pm_next_01;
            pm_10 <= pm_next_10;
            pm_11 <= pm_next_11;
        end
        // else: giu nguyen
    end

endmodule
