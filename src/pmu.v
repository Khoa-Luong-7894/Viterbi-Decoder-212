module pmu #(
    parameter PM_WIDTH = 4
)(
    input  wire clk,
    input  wire rst_n,
    input  wire pm_we,

    input  wire [PM_WIDTH-1:0] pm_next_00,
    input  wire [PM_WIDTH-1:0] pm_next_01,
    input  wire [PM_WIDTH-1:0] pm_next_10,
    input  wire [PM_WIDTH-1:0] pm_next_11,

    output reg  [PM_WIDTH-1:0] pm_00,
    output reg  [PM_WIDTH-1:0] pm_01,
    output reg  [PM_WIDTH-1:0] pm_10,
    output reg  [PM_WIDTH-1:0] pm_11,

    output reg  [1:0] min_state
);
    localparam [PM_WIDTH-1:0] INF = {PM_WIDTH{1'b1}};

    // Metric Register
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pm_00 <= 0;
            pm_01 <= INF;
            pm_10 <= INF;
            pm_11 <= INF;
        end
        else if (pm_we) begin
            pm_00 <= pm_next_00;
            pm_01 <= pm_next_01;
            pm_10 <= pm_next_10;
            pm_11 <= pm_next_11;
        end
    end

    // Combinational Min Search
    reg [PM_WIDTH-1:0] min_val;
    reg [1:0] min_idx;

    always @(*) begin
        min_val = pm_00;
        min_idx = 2'b00;

        if (pm_01 < min_val) begin
            min_val = pm_01;
            min_idx = 2'b01;
        end

        if (pm_10 < min_val) begin
            min_val = pm_10;
            min_idx = 2'b10;
        end

        if (pm_11 < min_val) begin
            min_val = pm_11;
            min_idx = 2'b11;
        end
    end

    // Register Min State
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            min_state <= 2'b00;
        else
            min_state <= min_idx;
    end

endmodule