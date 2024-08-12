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
*    Ziqing Li <liziqing@bosc.ac.cn>
*    Li Zhao <lizhao@bosc.ac.cn>
*    Nana Cai <cainana@bosc.ac.cn>
*/

module hnf_fifo #(
        parameter FIFO_ENTRIES_WIDTH = 32,
        parameter FIFO_ENTRIES_DEPTH = 16
    )
    (
        //global inputs
        clk,
        rst,

        //main inputs
        wr_en,
        wr_data,
        rd_en,

        //main outputs
        rd_data,
        empty,
        full,
        //debug
        fifo_cnt
    );
    //define localparam
    localparam FIFO_PTR_WIDTH = $clog2(FIFO_ENTRIES_DEPTH);
    localparam BYP_ENABLE = 0;

    //global inputs
    input  wire                          clk;
    input  wire                          rst;

    //main inputs
    input  wire                          wr_en;
    input  wire [FIFO_ENTRIES_WIDTH-1:0] wr_data;
    input  wire                          rd_en;

    //main outputs
    output wire [FIFO_ENTRIES_WIDTH-1:0] rd_data;
    output wire                          empty;
    output wire                          full;

    //debug
    output reg [FIFO_PTR_WIDTH:0]               fifo_cnt;

    //internal reg signals
    reg [FIFO_ENTRIES_WIDTH-1:0]         fifo_mem [0:FIFO_ENTRIES_DEPTH-1];
    reg [FIFO_PTR_WIDTH-1:0]             rd_ptr;
    reg [FIFO_PTR_WIDTH-1:0]             wr_ptr;
    // reg [FIFO_PTR_WIDTH:0]               fifo_cnt;
    reg                                  empty_q;
    reg                                  full_q;
    reg [FIFO_ENTRIES_WIDTH-1:0]         rd_mem_data;

    //internal wire signals
    wire                                 fifo_byp;
    wire                                 rd_ptr_en;
    wire                                 wr_ptr_en;
    wire [FIFO_PTR_WIDTH-1:0]            rd_ptr_ns;
    wire [FIFO_PTR_WIDTH-1:0]            wr_ptr_ns;
    wire [FIFO_ENTRIES_DEPTH-1:0]        wr_mem_en;
    wire [FIFO_PTR_WIDTH:0]              fifo_cnt_ns;
    wire                                 upd_fifo_cnt;
    wire                                 empty_ns;
    wire                                 full_ns;

    //bypass logic
    assign fifo_byp = wr_en & rd_en & empty & BYP_ENABLE;

    //read pointer logic
    assign rd_ptr_en = rd_en & ~fifo_byp;
    assign rd_ptr_ns = (rd_ptr == (FIFO_ENTRIES_DEPTH-1))? {FIFO_PTR_WIDTH{1'b0}} :
           (rd_ptr[FIFO_PTR_WIDTH-1:0] + 1'b1);
    always @(posedge clk or posedge rst)begin
        if(rst == 1'b1)
            rd_ptr <= {FIFO_PTR_WIDTH{1'b0}};
        else if(rd_ptr_en == 1'b1)
            rd_ptr <= rd_ptr_ns;
    end

    //write pointer logic
    assign wr_ptr_en = wr_en & ~fifo_byp;
    assign wr_ptr_ns = (wr_ptr == (FIFO_ENTRIES_DEPTH-1))? {FIFO_PTR_WIDTH{1'b0}} :
           (wr_ptr[FIFO_PTR_WIDTH-1:0] + 1'b1);
    always @(posedge clk or posedge rst)begin
        if(rst == 1'b1)
            wr_ptr <= {FIFO_PTR_WIDTH{1'b0}};
        else if(wr_ptr_en == 1'b1)
            wr_ptr <= wr_ptr_ns;
    end

    //write fifo memory logic
    genvar i;
    generate
        for(i=0;i<FIFO_ENTRIES_DEPTH;i=i+1)begin
            assign wr_mem_en[i] = (wr_ptr == i) & wr_en;

            always @(posedge clk)begin
                if(wr_mem_en[i])
                    fifo_mem[i] <= wr_data;
                else begin
                end
            end
        end
    endgenerate

    //read fifo memory logic
    integer j;
    always@*begin
        for(j=0;j<FIFO_ENTRIES_DEPTH;j=j+1)begin
            if(rd_ptr == j)
                rd_mem_data = fifo_mem[j];
            else begin
            end
        end
    end

    //fifo count logic
    assign fifo_cnt_ns = wr_ptr_en? (fifo_cnt + 1'b1) :
           (fifo_cnt - 1'b1);

    assign upd_fifo_cnt = (wr_en ^ rd_en) & ~fifo_byp;

    always @(posedge clk or posedge rst)begin
        if(rst == 1'b1)
            fifo_cnt <= {(FIFO_PTR_WIDTH+1){1'b0}};
        else if(upd_fifo_cnt == 1'b1)
            fifo_cnt <= fifo_cnt_ns;
    end

    //fifo empty logic
    assign empty_ns = (fifo_cnt == {{FIFO_PTR_WIDTH{1'b0}},1'b1}) && ~wr_en;

    always @(posedge clk or posedge rst)begin
        if(rst == 1'b1)
            empty_q <= 1'b1;
        else if(upd_fifo_cnt == 1'b1)
            empty_q <= empty_ns;
    end

    assign empty = empty_q;

    //fifo full logic
    assign full_ns = (fifo_cnt == (FIFO_ENTRIES_DEPTH-1)) & ~rd_en;

    always @(posedge clk or posedge rst)begin
        if(rst == 1'b1)
            full_q <= 1'b0;
        else if(upd_fifo_cnt == 1'b1)
            full_q <= full_ns;
    end

    assign full = full_q;

    // Drive and select read data.
    assign rd_data = empty_q? wr_data :
           rd_mem_data;

endmodule
