module ext (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        ext_en,
    input  wire        load_rx,
    input  wire [15:0] rx_data,

    output reg  [1:0]  bmu_sym
);

    reg [15:0] ext_reg;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ext_reg <= 16'b0;
            bmu_sym <= 2'b00;
        end else if (load_rx) begin
            ext_reg <= rx_data;
        end else if (ext_en) begin
            bmu_sym <= ext_reg[15:14];
            ext_reg <= {ext_reg[13:0], 2'b00};
        end else begin
            bmu_sym <= 2'b00;
        end
    end

endmodule

