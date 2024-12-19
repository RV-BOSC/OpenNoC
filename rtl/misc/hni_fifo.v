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
*    Li Zhao <lizhao@bosc.ac.cn>
*    Nana Cai <cainana@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*    Xiaotian Cao <caoxiaotian@bosc.ac.cn>
*/

module hni_fifo #(
        parameter FIFO_WIDTH = -1,
        parameter FIFO_DEPTH = -1
    ) (
        clk,
        rst,
        wr_en,
        rd_en,
        wr_data,

        rd_data,
        full,
        empty
    );

    localparam FIFO_PTR_WIDTH = $clog2(FIFO_DEPTH);

    input wire clk;
    input wire rst;
    input wire wr_en;
    input wire rd_en;
    input wire [FIFO_WIDTH-1:0] wr_data;

    output wire [FIFO_WIDTH-1:0] rd_data;
    output wire full;
    output wire empty;

    reg [FIFO_WIDTH-1:0]        memory [FIFO_DEPTH-1:0];
    reg [FIFO_PTR_WIDTH-1:0]    rd_ptr_q;
    reg [FIFO_PTR_WIDTH-1:0]    wr_ptr_q;
    reg [FIFO_WIDTH-1:0]        rd_mem_data_q;
    reg [FIFO_PTR_WIDTH:0]      cnt_q;
    reg                         full_q;
    reg                         empty_q;

    wire [FIFO_PTR_WIDTH-1:0]   rd_ptr_ns;
    wire [FIFO_PTR_WIDTH-1:0]   wr_ptr_ns;
    wire [FIFO_PTR_WIDTH:0]     cnt_ns;
    wire                        full_ns;
    wire                        empty_ns;
    wire [FIFO_DEPTH-1:0]       wr_mem_en;
    wire                        update_fifo_cnt;

    integer j;
    genvar i;

//read pointer
    assign rd_ptr_ns = (rd_ptr_q == (FIFO_DEPTH-1'b1)) ? {FIFO_PTR_WIDTH{1'b0}} : (rd_ptr_q + 1'b1);
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1)
            rd_ptr_q <= {FIFO_PTR_WIDTH{1'b0}};
        else if(rd_en == 1'b1)
            rd_ptr_q <= rd_ptr_ns;
        else
            rd_ptr_q <= rd_ptr_q;
    end

//write pointer
    assign wr_ptr_ns = (wr_ptr_q == (FIFO_DEPTH-1'b1)) ? {FIFO_PTR_WIDTH{1'b0}} : (wr_ptr_q + 1'b1);
    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1)
            wr_ptr_q <= {FIFO_PTR_WIDTH{1'b0}};
        else if(wr_en == 1'b1)
            wr_ptr_q <= wr_ptr_ns;
        else
            wr_ptr_q <= wr_ptr_q;
    end

// write data
    generate
        for (i = 0; i < FIFO_DEPTH; i=i+1) begin
            assign wr_mem_en[i] = (wr_ptr_q == i) & wr_en;
            always @(posedge clk) begin
                if (wr_mem_en[i])
                    memory[i] <= wr_data;
            end
        end
    endgenerate

//read data
    always @* begin
        rd_mem_data_q = {FIFO_WIDTH{1'b0}};
        for (j = 0; j < FIFO_DEPTH; j=j+1) begin
            if (rd_ptr_q == j)
                rd_mem_data_q = memory[j];
        end
    end

    assign rd_data[FIFO_WIDTH-1:0] = rd_mem_data_q[FIFO_WIDTH-1:0];

//full or empty
    assign update_fifo_cnt = wr_en ^ rd_en;
    assign cnt_ns = wr_en ? (cnt_q + 1'b1) : (cnt_q - 1'b1);

    always @(posedge clk or posedge rst) begin
        if (rst)
            cnt_q <= {(FIFO_PTR_WIDTH+1){1'b0}};
        else if (update_fifo_cnt)
            cnt_q <= cnt_ns;
        else
            cnt_q <= cnt_q;
    end

    assign empty_ns = (cnt_q == {{FIFO_PTR_WIDTH{1'b0}},1'b1}) && ~wr_en;

    always @(posedge clk or posedge rst) begin
        if (rst)
            empty_q <= 1'b1;
        else if (update_fifo_cnt)
            empty_q <= empty_ns;
        else
            empty_q <= empty_q;
    end
    assign empty = empty_q;

    assign full_ns = (cnt_q == (FIFO_DEPTH-1'b1)) & ~rd_en;

    always @(posedge clk or posedge rst) begin
        if (rst)
            full_q <= 1'b0;
        else if (update_fifo_cnt)
            full_q <= full_ns;
        else
            full_q <= full_q;
    end

    assign full = full_q;


endmodule
