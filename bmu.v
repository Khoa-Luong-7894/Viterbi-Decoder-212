module bmu (
    input  wire [1:0] bmu_sym,

    output wire [1:0] acs_bm00_0,
    output wire [1:0] acs_bm00_1,
    output wire [1:0] acs_bm01_0,
    output wire [1:0] acs_bm01_1,
    output wire [1:0] acs_bm10_0,
    output wire [1:0] acs_bm10_1,
    output wire [1:0] acs_bm11_0,
    output wire [1:0] acs_bm11_1
);

    function automatic [1:0] hamming2;
        input [1:0] rx;
        input [1:0] exp;
        begin
            hamming2 = (rx[1] ^ exp[1]) + (rx[0] ^ exp[0]);
        end
    endfunction

    assign acs_bm00_0 = hamming2(bmu_sym, 2'b00);
    assign acs_bm00_1 = hamming2(bmu_sym, 2'b11);
    assign acs_bm01_0 = hamming2(bmu_sym, 2'b11);
    assign acs_bm01_1 = hamming2(bmu_sym, 2'b00);
    assign acs_bm10_0 = hamming2(bmu_sym, 2'b10);
    assign acs_bm10_1 = hamming2(bmu_sym, 2'b01);
    assign acs_bm11_0 = hamming2(bmu_sym, 2'b01);
    assign acs_bm11_1 = hamming2(bmu_sym, 2'b10);

endmodule

