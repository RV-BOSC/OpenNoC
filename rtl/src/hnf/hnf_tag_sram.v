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
*    Hongyu Gao <gaohongyu@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"
`ifndef FPGA_MEMORY
module hnf_tag_sram `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_cache_pipeline
        loc_index_q,
        loc_rd_en_q,
        loc_wr_ways_q,
        loc_wr_cline_q,

        //outputs to hnf_cache_pipeline
        loc_rd_clines_q
    );

    //global inputs
    input wire                                      clk;
    input wire                                      rst;

    //inputs from hnf_cache_pipeline
    input wire [`LOC_INDEX_WIDTH-1:0]               loc_index_q;
    input wire                                      loc_rd_en_q;
    input wire [`LOC_WAY_NUM-1:0]                   loc_wr_ways_q;
    input wire [`LOC_CLINE_WIDTH-1:0]               loc_wr_cline_q;

    //outputs to hnf_cache_pipeline
    output reg [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0]  loc_rd_clines_q;

    //internal wire signal
    wire [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0]        loc_rd_clines;
    wire [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0]        sram_out;

    //main function

    //module instantiation
    hnf_sram_mask #(
                      .RAM_ADDR_WIDTH (`LOC_INDEX_WIDTH  ),
                      .RAM_DATA_WIDTH (`LOC_CLINE_WIDTH  ),
                      .RAM_MASK_WIDTH (`LOC_WAY_NUM      )
                  ) u_tag_sram (
                      .CLK            (clk               ),
                      .WE             (|loc_wr_ways_q    ),
                      .WMASK          (loc_wr_ways_q     ),
                      .ADDR           (loc_index_q       ),
                      .DATA_IN        (loc_wr_cline_q    ),
                      .DATA_OUT       (sram_out          )
                  );

    assign loc_rd_clines = sram_out;

    //data -> D
    always@(posedge clk or posedge rst)begin
        if(rst == 1'b1)begin
            loc_rd_clines_q <= {`LOC_CLINE_WIDTH*`LOC_WAY_NUM{1'b0}};
        end
        else begin
            loc_rd_clines_q <= loc_rd_clines;
        end
    end

endmodule

`else
module hnf_tag_sram `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_cache_pipeline
        loc_index_q,
        loc_rd_en_q,
        loc_wr_ways_q,
        loc_wr_cline_q,

        //outputs to hnf_cache_pipeline
        loc_rd_clines_q
    );

    //global inputs
    input wire                                      clk;
    input wire                                      rst;

    //inputs from hnf_cache_pipeline
    input wire [`LOC_INDEX_WIDTH-1:0]               loc_index_q;
    input wire                                      loc_rd_en_q;
    input wire [`LOC_WAY_NUM-1:0]                   loc_wr_ways_q;
    input wire [`LOC_CLINE_WIDTH-1:0]               loc_wr_cline_q;

    //outputs to hnf_cache_pipeline
    output reg [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0]  loc_rd_clines_q;

    //internal wire signal
    wire [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0]        sram_out,sram_out1;

    //internal wire signal
    reg [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0]         sram_in;

    //internal varibales
    genvar ii;
    integer i;

    //main function

    ////module instantiation
    //hnf_sram_mask #(
    //.RAM_ADDR_WIDTH (`LOC_INDEX_WIDTH  ),
    //.RAM_DATA_WIDTH (`LOC_CLINE_WIDTH  ),
    //.RAM_MASK_WIDTH (`LOC_WAY_NUM      )
    //) u_tag_sram (
    //.CLK            (clk               ),
    //.WE             (|loc_wr_ways_q    ),
    //.WMASK          (loc_wr_ways_q     ),
    //.ADDR           (loc_index_q       ),
    //.DATA_IN        (sram_in           ),
    //.DATA_OUT       (sram_out          )
    //);
    generate
        for (ii = 0; ii < `LOC_WAY_NUM; ii = ii + 1) begin
            ram_sp
                #(
                    .RAM_WIDTH(`LOC_CLINE_WIDTH ),
                    .RAM_DEPTH(2**`LOC_INDEX_WIDTH)
                )
                u_tag_sram1 (
                    .clka(clk),    // input wire clka
                    .ena(1'b1),      // input wire ena
                    .wea(loc_wr_ways_q[ii]),      // input wire [0 : 0] wea
                    .addra(loc_index_q),  // input wire [13 : 0] addra
                    .dina(sram_in[(`LOC_CLINE_WIDTH*ii)+:`LOC_CLINE_WIDTH]),    // input wire [27 : 0] dina
                    .douta(sram_out[(`LOC_CLINE_WIDTH*ii)+:`LOC_CLINE_WIDTH])  // output wire [27 : 0] douta
                );
        end
    endgenerate

    //wrap data
    always@*begin
        sram_in = {`LOC_CLINE_WIDTH*`LOC_WAY_NUM{1'b0}};
        for(i=0;i<`LOC_WAY_NUM;i=i+1)begin
            sram_in[i*`LOC_CLINE_WIDTH +: `LOC_CLINE_WIDTH] = sram_in[i*`LOC_CLINE_WIDTH +: `LOC_CLINE_WIDTH] | (loc_wr_cline_q & {`LOC_CLINE_WIDTH{loc_wr_ways_q[i]}});
        end
    end

    //data -> D
    always@ * //(posedge clk or posedge rst)
    begin
        if(rst == 1'b1)begin
            loc_rd_clines_q <= {`LOC_CLINE_WIDTH*`LOC_WAY_NUM{1'b0}};
        end
        else begin
            loc_rd_clines_q <= sram_out;
        end
    end

endmodule
`endif
