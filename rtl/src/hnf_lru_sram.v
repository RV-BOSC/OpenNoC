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
*    Bingcheng Jin <jinbingcheng@bosc.ac.cn>
*    Ziqing Li <liziqing@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"
`ifndef FPGA_MEMORY
module hnf_lru_sram `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_cache_pipeline
        lru_index_q,
        lru_rd_en_q,
        lru_wr_en_q,
        lru_wr_data_q,

        //outputs to hnf_cache_pipeline
        lru_rd_data_q
    );

    //global inputs
    input wire                              clk;
    input wire                              rst;

    //inputs from hnf_cache_pipeline
    input wire [`LOC_INDEX_WIDTH-1:0]       lru_index_q;
    input wire                              lru_rd_en_q;
    input wire                              lru_wr_en_q;
    input wire [`LRU_CLINE_WIDTH-1:0]       lru_wr_data_q;

    //outputs to hnf_cache_pipeline
    output reg [`LRU_CLINE_WIDTH-1:0]       lru_rd_data_q;

    //internal signals
    wire [`LRU_CLINE_WIDTH-1:0]             lru_rd_data;

    //main function

    //module instantiation
    hnf_sram #(
                 .RAM_ADDR_WIDTH (`LOC_INDEX_WIDTH   ),
                 .RAM_DATA_WIDTH (`LRU_CLINE_WIDTH   )
             ) u_lru_sram (
                 .CLK            (clk               ),
                 .WE             (lru_wr_en_q       ),
                 .ADDR           (lru_index_q       ),
                 .DATA_IN        (lru_wr_data_q     ),
                 .DATA_OUT       (lru_rd_data       )
             );

    always@(posedge clk or posedge rst)begin
        if(rst == 1'b1)begin
            lru_rd_data_q <= {`LRU_CLINE_WIDTH{1'b0}};
        end
        else begin
            lru_rd_data_q <= lru_rd_data;
        end
    end

endmodule

`else
module hnf_lru_sram `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_cache_pipeline
        lru_index_q,
        lru_rd_en_q,
        lru_wr_en_q,
        lru_wr_data_q,

        //outputs to hnf_cache_pipeline
        lru_rd_data_q
    );

    //global inputs
    input wire                              clk;
    input wire                              rst;

    //inputs from hnf_cache_pipeline
    input wire [`LOC_INDEX_WIDTH-1:0]       lru_index_q;
    input wire                              lru_rd_en_q;
    input wire                              lru_wr_en_q;
    input wire [`LRU_CLINE_WIDTH-1:0]       lru_wr_data_q;

    //outputs to hnf_cache_pipeline
    output reg [`LRU_CLINE_WIDTH-1:0]       lru_rd_data_q;

    //internal signals
    wire [`LRU_CLINE_WIDTH-1:0]             lru_rd_data,lru_rd_data1;

    //main function

    ram_sp
        #(
            .RAM_WIDTH(`LRU_CLINE_WIDTH ),
            .RAM_DEPTH(2**`LOC_INDEX_WIDTH)
        )
        u_lru_sram1 (
            .clka(clk),    // input wire clka
            .ena(1'b1),      // input wire ena
            .wea(lru_wr_en_q),      // input wire [0 : 0] wea
            .addra(lru_index_q),  // input wire [13 : 0] addra
            .dina(lru_wr_data_q),    // input wire [31 : 0] dina
            .douta(lru_rd_data)  // output wire [31 : 0] douta
        );

    always@ (posedge clk or posedge rst)begin
        if(rst == 1'b1)begin
            lru_rd_data_q <= {`LRU_CLINE_WIDTH{1'b0}};
        end
        else begin
            lru_rd_data_q <= lru_rd_data;
        end
    end

endmodule
`endif
