`timescale 1ns / 1ps

module cos_gen_rom #(
    parameter WIDTH = 9,         // <3.6> fixed-point
    parameter DEPTH = 512
)(
    input  logic clk,
    input  logic rstn,
    output logic signed [WIDTH-1:0] dout_re [0:15],
    output logic signed [WIDTH-1:0] dout_im [0:15],
    output logic dout_en
);

    // ROM memory
    logic signed [WIDTH-1:0] rom_re [0:DEPTH-1];
    logic signed [WIDTH-1:0] rom_im [0:DEPTH-1];

    // Control (posedge)
    logic [5:0] cnt;
    logic [8:0] rom_index;
    logic output_en;
    logic pause_mode;

    always_ff @(posedge clk or negedge rstn) begin
        if (!rstn) begin
            output_en  <= 1'b1;
            pause_mode <= 1'b0;
            cnt        <= 6'd0;
            rom_index  <= 9'd0;
        end else begin
            if (output_en) begin
                if (cnt == 6'd31) begin
                    output_en  <= 1'b0;
                    pause_mode <= 1'b1;
                    cnt        <= 6'd0;
                    rom_index  <= 9'd0;
                end else begin
                    cnt       <= cnt + 1;
                    rom_index <= rom_index + 9'd16;
                end
            end else if (pause_mode) begin
                if (cnt == 6'd7) begin
                    output_en  <= 1'b1;
                    pause_mode <= 1'b0;
                    cnt        <= 6'd0;
                    rom_index  <= 9'd0;
                end else begin
                    cnt <= cnt + 1;
                end
            end
        end
    end

    // === 아래가 핵심: negedge clk에서 출력 타이밍 맞추기 ===

    logic [8:0] rom_index_reg;
    logic output_en_reg;
    logic dout_en_reg_delayed;

    // negedge에서 rom_index, output_en latch
    always_ff @(negedge clk or negedge rstn) begin
        if (!rstn) begin
            rom_index_reg   <= 9'd0;
            output_en_reg   <= 1'b0;
        end else begin
            rom_index_reg   <= rom_index;
            output_en_reg   <= output_en;
        end
    end

    // dout_en만 1클럭 더 delay
    always_ff @(negedge clk or negedge rstn) begin
        if (!rstn)
            dout_en_reg_delayed <= 1'b0;
        else
            dout_en_reg_delayed <= output_en_reg;
    end

    assign dout_en = dout_en_reg_delayed;

    always_ff @(negedge clk or negedge rstn) begin
        if (!rstn) begin
            for (int i = 0; i < 16; i++) begin
                dout_re[i] <= '0;
                dout_im[i] <= '0;
            end
        end else if (output_en_reg) begin
            dout_re[0]  <= rom_re[rom_index_reg + 0];
            dout_re[1]  <= rom_re[rom_index_reg + 1];
            dout_re[2]  <= rom_re[rom_index_reg + 2];
            dout_re[3]  <= rom_re[rom_index_reg + 3];
            dout_re[4]  <= rom_re[rom_index_reg + 4];
            dout_re[5]  <= rom_re[rom_index_reg + 5];
            dout_re[6]  <= rom_re[rom_index_reg + 6];
            dout_re[7]  <= rom_re[rom_index_reg + 7];
            dout_re[8]  <= rom_re[rom_index_reg + 8];
            dout_re[9]  <= rom_re[rom_index_reg + 9];
            dout_re[10] <= rom_re[rom_index_reg + 10];
            dout_re[11] <= rom_re[rom_index_reg + 11];
            dout_re[12] <= rom_re[rom_index_reg + 12];
            dout_re[13] <= rom_re[rom_index_reg + 13];
            dout_re[14] <= rom_re[rom_index_reg + 14];
            dout_re[15] <= rom_re[rom_index_reg + 15];

            dout_im[0]  <= rom_im[rom_index_reg + 0];
            dout_im[1]  <= rom_im[rom_index_reg + 1];
            dout_im[2]  <= rom_im[rom_index_reg + 2];
            dout_im[3]  <= rom_im[rom_index_reg + 3];
            dout_im[4]  <= rom_im[rom_index_reg + 4];
            dout_im[5]  <= rom_im[rom_index_reg + 5];
            dout_im[6]  <= rom_im[rom_index_reg + 6];
            dout_im[7]  <= rom_im[rom_index_reg + 7];
            dout_im[8]  <= rom_im[rom_index_reg + 8];
            dout_im[9]  <= rom_im[rom_index_reg + 9];
            dout_im[10] <= rom_im[rom_index_reg + 10];
            dout_im[11] <= rom_im[rom_index_reg + 11];
            dout_im[12] <= rom_im[rom_index_reg + 12];
            dout_im[13] <= rom_im[rom_index_reg + 13];
            dout_im[14] <= rom_im[rom_index_reg + 14];
            dout_im[15] <= rom_im[rom_index_reg + 15];
        end else begin
            for (int i = 0; i < 16; i++) begin
                dout_re[i] <= '0;
                dout_im[i] <= '0;
            end
        end
    end

    // ROM 초기화
    initial begin
        $display("🔃 Reading ROM...");
        $readmemb("cos_rom_re.mem", rom_re);
        $readmemb("cos_rom_im.mem", rom_im);
        $display("✅ ROM read done.");
    end

endmodule
