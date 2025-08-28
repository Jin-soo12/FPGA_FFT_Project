`timescale 1ns / 1ps

module FPGA_top (
    input logic clk_p,
    input logic clk_n,
    input logic rstn
);
    logic w_din_valid;
    /*logic w_cos_rstn;*/
    logic w_dout_en;
    logic signed [8:0] w_cos_data_re[0:15];
    logic signed [8:0] w_cos_data_im[0:15];
    logic signed [12:0] w_fft_dout_re[0:511];     //<9.4>
    logic signed [12:0] w_fft_dout_im[0:511];     //<9.4>

    logic signed [12:0] w_div_fft_dout_re[0:15];     //<9.4>
    logic signed [12:0] w_div_fft_dout_im[0:15];     //<9.4>

    logic clk;

    logic [5:0] dout_cnt;
    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            dout_cnt <= 0;
        end else if (w_dout_en && dout_cnt < 31) begin
            dout_cnt <= dout_cnt + 1;
        end else begin
            dout_cnt <= 0;
        end
    end

    always_comb begin
        for (int i = 0; i < 16; i++) begin
            w_div_fft_dout_re[i] = w_fft_dout_re[i+16*dout_cnt];
            w_div_fft_dout_im[i] = w_fft_dout_im[i+16*dout_cnt];
        end
    end

    clk_wiz_0 U_CLK_WIZ_0 (
        // Clock out ports
        // Status and control signals
        .resetn(rstn),
        // Clock in ports
        .clk_in1_p(clk_p),
        .clk_in1_n(clk_n),
        .clk_out1(clk)
    );


    cos_gen_rom #(
        .WIDTH(9),   // <3.6> fixed-point
        .DEPTH(512)
    ) U_COS_GEN_ROM(
        .clk(clk),
        .rstn(rstn),
        .dout_re(w_cos_data_re),
        .dout_im(w_cos_data_im),
        .dout_en(w_din_valid)
    );

    top_fft_fixed #(
        .WIDTH(9)
    ) U_FPGA_FFT (
        .clk (clk),
        .rstn(rstn),

        .din_i(w_cos_data_re),
        .din_q(w_cos_data_im),
        .din_valid(w_din_valid),

        .dout_re(w_fft_dout_re),
        .dout_im(w_fft_dout_im),
        .dout_en(w_dout_en)
    );

    vio_fft U_FPGA_VIO (
        .clk(clk),
        .probe_in0(w_dout_en),
        .probe_in1(w_div_fft_dout_re[0]),
        .probe_in2(w_div_fft_dout_re[1]),
        .probe_in3(w_div_fft_dout_re[2]),
        .probe_in4(w_div_fft_dout_re[3]),
        .probe_in5(w_div_fft_dout_re[4]),
        .probe_in6(w_div_fft_dout_re[5]),
        .probe_in7(w_div_fft_dout_re[6]),
        .probe_in8(w_div_fft_dout_re[7]),
        .probe_in9(w_div_fft_dout_re[8]),
        .probe_in10(w_div_fft_dout_re[9]),
        .probe_in11(w_div_fft_dout_re[10]),
        .probe_in12(w_div_fft_dout_re[11]),
        .probe_in13(w_div_fft_dout_re[12]),
        .probe_in14(w_div_fft_dout_re[13]),
        .probe_in15(w_div_fft_dout_re[14]),
        .probe_in16(w_div_fft_dout_re[15]),
        .probe_in17(w_div_fft_dout_im[0]),
        .probe_in18(w_div_fft_dout_im[1]),
        .probe_in19(w_div_fft_dout_im[2]),
        .probe_in20(w_div_fft_dout_im[3]),
        .probe_in21(w_div_fft_dout_im[4]),
        .probe_in22(w_div_fft_dout_im[5]),
        .probe_in23(w_div_fft_dout_im[6]),
        .probe_in24(w_div_fft_dout_im[7]),
        .probe_in25(w_div_fft_dout_im[8]),
        .probe_in26(w_div_fft_dout_im[9]),
        .probe_in27(w_div_fft_dout_im[10]),
        .probe_in28(w_div_fft_dout_im[11]),
        .probe_in29(w_div_fft_dout_im[12]),
        .probe_in30(w_div_fft_dout_im[13]),
        .probe_in31(w_div_fft_dout_im[14]),
        .probe_in32(w_div_fft_dout_im[15]),
        .probe_out0()
    );

endmodule
