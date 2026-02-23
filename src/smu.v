module smu #(
    parameter DEPTH = 8
)(
    input  wire clk,
    input  wire rst_n,

    // Forward write
    input  wire        smu_we,
    input  wire        bank_sel,   // bank write
    input  wire [2:0]  fw_idx,
    input  wire [3:0]  surv_bit,

    // Traceback read
    input  wire        read_bank,  // = ~bank_sel
    input  wire [2:0]  tb_idx,
    output reg  [3:0]  surv_out
);

    //--------------------------------------------------
    // 2 banks × DEPTH
    //--------------------------------------------------
    reg [3:0] mem0 [0:DEPTH-1];
    reg [3:0] mem1 [0:DEPTH-1];

    integer i;

    //--------------------------------------------------
    // 1️⃣ Reset memory (simulation safe)
    //--------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < DEPTH; i = i + 1) begin
                mem0[i] <= 4'b0;
                mem1[i] <= 4'b0;
            end
        end
    end

    //--------------------------------------------------
    // 2️⃣ Write logic (forward phase)
    //--------------------------------------------------
    always @(posedge clk) begin
        if (smu_we) begin
            if (bank_sel)
                mem1[fw_idx] <= surv_bit;
            else
                mem0[fw_idx] <= surv_bit;
        end
    end

    //--------------------------------------------------
    // 3️⃣ Read logic (traceback phase)
    // synchronous read (FPGA friendly)
    //--------------------------------------------------
    always @(posedge clk) begin
        if (read_bank)
            surv_out <= mem1[tb_idx];
        else
            surv_out <= mem0[tb_idx];
    end

endmodule