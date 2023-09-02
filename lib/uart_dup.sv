module UART_DUP #(
    ADDR_WIDTH = 8,
    BPS = 115200,
    CLK_FREQ = 50000000
) (
    input logic CLK,
    input logic RX,
    output logic TX = 1,
    input logic RDREQ,
    input logic WRREQ,
    input logic [7:0] DIN,
    output logic [7:0] DOUT,
    output logic [ADDR_WIDTH-1:0] USEDW_RCV,
    output logic [ADDR_WIDTH-1:0] USEDW_SEND
);
    parameter INTERVAL = BPS / CLK_FREQ;

    logic WRREQ_RCV = 0, RDREQ_SEND = 0;
    logic [7:0] DATA_RCV, Q_SEND;

    logic [2:0] BIT_CNT_SEND = 0, BIT_CNT_RCV = 0;

    logic [31:0] CLK_CNT_SEND = 0, CLK_CNT_RCV = 0;
    logic [3:0] STATE_SEND = 0, STATE_RCV = 0;

    FIFO #(
        8,
        ADDR_WIDTH
    ) FIFO_RCV (
        CLK,
        RDREQ,
        WRREQ_RCV,
        DATA_RCV,
        DOUT,
        USEDW_RCV
    );
    FIFO #(
        8,
        ADDR_WIDTH
    ) FIFO_SEND (
        CLK,
        RDREQ_SEND,
        WRREQ,
        DIN,
        Q_SEND,
        USEDW_SEND
    );

    always @(posedge CLK) begin
        if (STATE_SEND == 0) begin
            if (USEDW_SEND) begin
                STATE_SEND++;
                RDREQ_SEND = 1;
                TX = 0;
            end else begin
                RDREQ_SEND = 0;
                TX = 1;
            end
        end
        else if (STATE_SEND == 1) begin
            RDREQ_SEND_1 = 0;
            if (CLK_CNT_SEND < INTERVAL) begin
                CLK_CNT_SEND++;
            end else begin
                CLK_CNT_SEND = 0;
                TX = Q_SEND[BIT_CNT_SEND];
                if ((BIT_CNT_SEND == 7)) begin
                    STATE_SEND++;
                    BIT_CNT_SEND = 0;
                end else begin
                    BIT_CNT_SEND++;
                end
            end
        end
        else if (STATE_SEND == 2) begin
            if (CLK_CNT_SEND == INTERVAL) begin
                STATE_SEND++;
                CLK_CNT_SEND = 0;
                TX = 1;
            end else begin
              CLK_CNT_SEND++;
            end
        end
        else if (STATE_SEND == 3) begin
            if (CLK_CNT_SEND == INTERVAL) begin
                STATE_SEND = 0;
                CLK_CNT_SEND = 0;
            end else begin
              CLK_CNT_SEND++;
            end
        end

        if (STATE_RCV == 0) begin
            if (!RX) begin
                STATE_RCV++;
                CLK_CNT_RCV = 0;
            end
        end
        else if (STATE_RCV == 1) begin
            if (CLK_CNT_RCV == INTERVAL/2) begin
                STATE_RCV++;
                CLK_CNT_RCV = 0;
            end else begin
              CLK_CNT_RCV++;
            end
        end
        else if (STATE_RCV == 2) begin
            if (CLK_CNT_RCV < INTERVAL) begin
                CLK_CNT_RCV++;
            end else begin
                DATA_RCV[BIT_CNT_RCV] = RX;
                CLK_CNT_RCV = 0;
                if (BIT_CNT_RCV == 7) begin
                    STATE_RCV++;
                    CLK_CNT_RCV = 0;
                    BIT_CNT_RCV = 0;
                    WRREQ_RCV = 1;
                end else begin
                    BIT_CNT_RCV++;
                end
            end
        end
        else if (STATE_RCV == 3) begin
            WRREQ_RCV = 0;
            if (CLK_CNT_RCV > INTERVAL) begin
                STATE_RCV = 0;
                CLK_CNT_RCV = 0;
            end else begin
              CLK_CNT_RCV++;
            end
        end
    end

endmodule
