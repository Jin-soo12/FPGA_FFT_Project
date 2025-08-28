`timescale 1ns / 1ps

module counter_v3 #(
    parameter int PULSE_CYCLES = 32
)(
    input  logic clk,
    input  logic rstn,
    input  logic en,                // 트리거 신호 (한번만 동작)
    output logic out_pulse          // 첫 번째 en에만 반응, PULSE_CYCLES 동안 유지
);

    localparam int CNT_WIDTH = $clog2(PULSE_CYCLES);
    logic [CNT_WIDTH-1:0] cnt;
    logic counting;
    logic pulse_done;               // 펄스 생성 완료 플래그

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            cnt        <= 0;
            counting   <= 0;
            pulse_done <= 0;        // 리셋시 다시 동작 가능하게
        end else begin
            if (!counting && en && !pulse_done) begin    // pulse_done이 0일 때만 시작
                counting <= 1;
                cnt      <= 1;      // 바로 다음엔 cnt=1부터 시작
            end else if (counting) begin
                if (cnt == PULSE_CYCLES - 1) begin
                    counting   <= 0;
                    cnt        <= 0;
                    pulse_done <= 1;    // 펄스 생성 완료 표시
                end else begin
                    cnt <= cnt + 1;
                end
            end
        end
    end

    assign out_pulse = (en && !counting && !pulse_done) ? 1'b1 : counting;

endmodule