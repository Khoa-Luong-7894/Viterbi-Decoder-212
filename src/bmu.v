module bmu (
    input  wire [1:0] i_data,

    output wire [1:0] bm00_0,
    output wire [1:0] bm00_1,
    output wire [1:0] bm01_0,
    output wire [1:0] bm01_1,
    output wire [1:0] bm10_0,
    output wire [1:0] bm10_1,
    output wire [1:0] bm11_0,
    output wire [1:0] bm11_1
);

    function [1:0] hamming2;
        input [1:0] a;
        input [1:0] b;
        begin
            hamming2 = (a[1]^b[1]) + (a[0]^b[0]);
        end
    endfunction

    // Mapping trellis cho (7,5)

    assign bm00_0 = hamming2(i_data, 2'b00);
    assign bm00_1 = hamming2(i_data, 2'b11);

    assign bm01_0 = hamming2(i_data, 2'b11);
    assign bm01_1 = hamming2(i_data, 2'b00);

    assign bm10_0 = hamming2(i_data, 2'b10);
    assign bm10_1 = hamming2(i_data, 2'b01);

    assign bm11_0 = hamming2(i_data, 2'b01);
    assign bm11_1 = hamming2(i_data, 2'b10);

endmodule