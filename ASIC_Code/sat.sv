`timescale 1ns/1ps

module sat #(
    parameter int IN_W  = 16,  // din 비트폭 (예: 16)
    parameter int OUT_W = 11   // dout 비트폭 (<5.6> => 5+6=11)
)(
    input  logic signed [IN_W-1:0]   din,
    output logic signed [OUT_W-1:0]  dout
);

    // ------------------------------------------------------------
    // 1) signed saturation 한계치 정의 (IN_W 폭 전체에서)
    // ------------------------------------------------------------
    // MAX_VAL: + (2^(OUT_W-1)-1)
    // MIN_VAL: - 2^(OUT_W-1)
    localparam signed [IN_W-1:0] MAX_VAL = { {(IN_W-OUT_W){1'b0}},  // 상위 비트는 0
                                              1'b0,                  // sign 비트
                                              {(OUT_W-1){1'b1}} };   // 절댓값 비트 모두 1
    localparam signed [IN_W-1:0] MIN_VAL = { {(IN_W-OUT_W){1'b1}},  // 상위 비트는 1 (sign‑extend)
                                              1'b1,                  // sign 비트
                                              {(OUT_W-1){1'b0}} };   // 절댓값 비트 모두 0

    // ------------------------------------------------------------
    // 2) MAX_OUT/MIN_OUT: saturation 후 잘라낼 비트
    // ------------------------------------------------------------
    localparam signed [OUT_W-1:0] MAX_OUT = MAX_VAL[OUT_W-1:0];
    localparam signed [OUT_W-1:0] MIN_OUT = MIN_VAL[OUT_W-1:0];

    // ------------------------------------------------------------
    // 3) 포화 로직
    // ------------------------------------------------------------
    always_comb begin
        if      (din >  MAX_VAL) dout = MAX_OUT;
        else if (din <  MIN_VAL) dout = MIN_OUT;
        else                      dout = din[OUT_W-1:0];
    end

endmodule


