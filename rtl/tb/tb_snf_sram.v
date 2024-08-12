/*
* Copyright (c) 2024 Beijing Institute of Open Source Chip
* OpenNoC is licensed under Mulan PSL v2.
* You can use this software according to the terms and conditions of the Mulan PSL v2.
* You may obtain a copy of Mulan PSL v2 at:
*          http://license.coscl.org.cn/MulanPSL2
* THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, WITHOUT WARRANTIES OF ANY KIND,
* EITHER EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO NON-INFRINGEMENT,
* MERCHANTABILITY OR FIT FOR A PARTICULAR PURPOSE.
* See the Mulan PSL v2 for more details.
*
* Author:
*    Nana Cai <cainana@bosc.ac.cn>
*    Li Zhao <lizhao@bosc.ac.cn>
*/

module tb_snf_sram
    (
        clk,
        rst,
        addr,
        wr_data,
        rd_data,
        wr_en,
        rd_en,
        full,
        empty
    );
    input wire         clk;
    input wire         rst;
    input wire [43:0]  addr;
    input wire         rd_en;
    input wire         wr_en;
    input wire [511:0] wr_data;
    output wire        full;
    output wire        empty;
    output reg [511:0] rd_data;

    integer i;
    reg [511:0] mem [3:0];
    reg [1:0] num_cnt;
    reg [511:0] rd_data_tmp;

    initial begin
        for(i=0; i<4;i=i+1) begin
            mem[i] = 'd0;
        end
    end

    always@(posedge clk or posedge rst)begin
        if(rst == 1'b1)
            num_cnt <= 2'b00;
        else if(wr_en == 1'b1)
            num_cnt <= num_cnt + 2'b01;
        else
            ;
    end

    assign full = (num_cnt == 2'b11) & wr_en;

    assign empty = (num_cnt == 2'b00);

    always@*begin
        if(rd_en == 1'b1)
            rd_data_tmp = mem[addr[3:0]];
        else
            ;
    end

    always@(posedge clk)begin
        rd_data <= rd_data_tmp;
    end

    always@(posedge clk)begin
        if(wr_en == 1'b1)
            mem[addr[3:0]] <= wr_data;
        else
            ;
    end

endmodule
