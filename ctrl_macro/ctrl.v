module ctrl (
    input  wire        clk,
    input  wire        rst_n,
    input  wire        en,
    input  wire        o_done,   

    output reg         load_rx,  
    output reg         ext_en,   
    output reg         pm_we,    
    output reg         smu_we,   
    output reg         tb_en,    
    output reg [2:0]   fw_idx    
);
    localparam IDLE      = 3'd0; // Chờ enable
    localparam LOAD      = 3'd1; // Nạp dữ liệu ban đầu
    localparam FW_PRE    = 3'd2; // Chu kỳ pre-fetch symbol đầu tiên
    localparam FW_OLAP   = 3'd3; // Overlap: vừa fetch vừa ghi
    localparam FW_FINAL  = 3'd4; // Ghi symbol cuối cùng
    localparam TB_START  = 3'd5; // Bắt đầu traceback
    localparam TB        = 3'd6; // Đang traceback

    reg [2:0] state, state_n;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state <= IDLE;
        else
            state <= state_n;
    end

    // Bộ đếm chỉ số fw_idx
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fw_idx <= 3'd0;
        end else begin
            case (state)
                IDLE,
                LOAD,
                FW_PRE:   fw_idx <= 3'd0;
                FW_OLAP:  fw_idx <= fw_idx + 1'b1;
                FW_FINAL: fw_idx <= 3'd7;
                default:  fw_idx <= fw_idx;
            endcase
        end
    end

    always @(*) begin
        load_rx = 1'b0;
        ext_en  = 1'b0;
        pm_we   = 1'b0;
        smu_we  = 1'b0;
        tb_en   = 1'b0;
        state_n = state;
        case (state)
            IDLE: begin
                if (en)
                    state_n = LOAD;
            end
            LOAD: begin
                load_rx = 1'b1;
                state_n = FW_PRE;
            end
            // Pre-fetch symbol đầu tiên
            FW_PRE: begin
                ext_en  = 1'b1;
                state_n = FW_OLAP;
            end
            // Overlap: fetch symbol n+1 và ghi kết quả symbol n
            FW_OLAP: begin
                ext_en  = 1'b1;
                pm_we   = 1'b1;
                smu_we  = 1'b1;
                if (fw_idx == 3'd6)
                    state_n = FW_FINAL;
            end
            // Ghi symbol cuối cùng
            FW_FINAL: begin
                pm_we   = 1'b1;
                smu_we  = 1'b1;
                state_n = TB_START;
            end
            // Bắt đầu traceback
            TB_START: begin
                tb_en   = 1'b1;
                state_n = TB;
            end
            TB: begin
                if (o_done)
                    state_n = IDLE;
            end
            default: state_n = IDLE;
        endcase
    end

endmodule
