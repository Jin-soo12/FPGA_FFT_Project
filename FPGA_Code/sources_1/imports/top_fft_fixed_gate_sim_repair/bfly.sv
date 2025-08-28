

`timescale 1ns/1ps

module bfly #(
    parameter WIDTH = 9  // module_00에서 9로 설정되어 있으므로 이를 사용
)(
    input  logic clk,
    input  logic rstn,

    input  logic bfly_valid, // 연산 진행 동안 HIGH

    input  logic signed [WIDTH-1:0] din_re        [0:15],
    input  logic signed [WIDTH-1:0] din_im        [0:15],
    input  logic signed [WIDTH-1:0] shift_data_re [0:15],
    input  logic signed [WIDTH-1:0] shift_data_im [0:15],

    output logic signed [WIDTH:0] bfly_sum_re   [0:15],
    output logic signed [WIDTH:0] bfly_sum_im   [0:15],
    output logic signed [WIDTH:0] bfly_diff_re  [0:15],
    output logic signed [WIDTH:0] bfly_diff_im  [0:15],

    output logic twiddle_valid // 1클럭 지연된 valid 신호
);

    logic bfly_valid_delay;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin 
            bfly_valid_delay <= 1'b0; 
            for (int i = 0; i < 16; i++) begin
                bfly_sum_re[i]  <= '0; 
                bfly_sum_im[i]  <= '0;
                bfly_diff_re[i] <= '0;
                bfly_diff_im[i] <= '0;
            end
        end else begin
            bfly_valid_delay <= bfly_valid;  
            if (bfly_valid) begin
                for (int i = 0; i < 16; i++) begin
                    bfly_sum_re[i]  <= $signed(shift_data_re[i]) + $signed(din_re[i]);
                    bfly_sum_im[i]  <= $signed(shift_data_im[i]) + $signed(din_im[i]);
                    bfly_diff_re[i] <= $signed(shift_data_re[i]) - $signed(din_re[i]);
                    bfly_diff_im[i] <= $signed(shift_data_im[i]) - $signed(din_im[i]);
                end
            end else begin
                // bfly_valid가 LOW일 때는 0으로 유지
                for (int i = 0; i < 16; i++) begin
                    bfly_sum_re[i]  <= '0;
                    bfly_sum_im[i]  <= '0;
                    bfly_diff_re[i] <= '0;
                    bfly_diff_im[i] <= '0;
                end
            end
        end
    end

    assign twiddle_valid = bfly_valid_delay;

endmodule





