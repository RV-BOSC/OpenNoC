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
module hnf_sf_sram `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_cache_pipeline
        sf_index_q,
        sf_rd_en_q,
        sf_wr_ways_q,
        sf_wr_cline_q,

        //outputs to hnf_cache_pipeline
        sf_rd_clines_q
    );

    //global inputs
    input wire                                    clk;
    input wire                                    rst;

    //inputs from hnf_cache_pipeline
    input wire [`SF_INDEX_WIDTH-1:0]              sf_index_q;
    input wire                                    sf_rd_en_q;
    input wire [`SF_WAY_NUM-1:0]                  sf_wr_ways_q;
    input wire [`SF_CLINE_WIDTH-1:0]              sf_wr_cline_q;

    //outputs to hnf_cache_pipeline
    output reg [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]  sf_rd_clines_q;

    //internal wire signals
    wire [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]        sf_rd_clines;
    wire [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]        sram_out;

    //main function

    //module instantiation
    hnf_sram_mask #(
                      .RAM_ADDR_WIDTH (`SF_INDEX_WIDTH   ),
                      .RAM_DATA_WIDTH (`SF_CLINE_WIDTH   ),
                      .RAM_MASK_WIDTH (`SF_WAY_NUM       )
                  ) u_sf_sram (
                      .CLK            (clk               ),
                      .WE             (|sf_wr_ways_q     ),
                      .WMASK          (sf_wr_ways_q      ),
                      .ADDR           (sf_index_q        ),
                      .DATA_IN        (sf_wr_cline_q     ),
                      .DATA_OUT       (sram_out          )
                  );

    assign sf_rd_clines = sram_out;

    //data -> D
    always@(posedge clk or posedge rst)begin
        if(rst == 1'b1)begin
            sf_rd_clines_q <= {`SF_CLINE_WIDTH*`SF_WAY_NUM{1'b0}};
        end
        else begin
            sf_rd_clines_q <= sf_rd_clines;
        end
    end

endmodule

`else
module hnf_sf_sram `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_cache_pipeline
        sf_index_q,
        sf_rd_en_q,
        sf_wr_ways_q,
        sf_wr_cline_q,

        //outputs to hnf_cache_pipeline
        sf_rd_clines_q
    );

    //global inputs
    input wire                                    clk;
    input wire                                    rst;

    //inputs from hnf_cache_pipeline
    input wire [`SF_INDEX_WIDTH-1:0]              sf_index_q;
    input wire                                    sf_rd_en_q;
    input wire [`SF_WAY_NUM-1:0]                  sf_wr_ways_q;
    input wire [`SF_CLINE_WIDTH-1:0]              sf_wr_cline_q;

    //outputs to hnf_cache_pipeline
    output reg [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]  sf_rd_clines_q;

    //internal wire signals
    wire [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]        sram_out,sram_out1;

    //internal reg signals
    reg [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]        sram_in;

    //internal variables
    genvar ii;
    integer i;

    //main function
    // `ifdef RTL_SRAM_EN
    // //module instantiation
    // hnf_sram_mask #(
    // .RAM_ADDR_WIDTH (`SF_INDEX_WIDTH   ),
    // .RAM_DATA_WIDTH (`SF_CLINE_WIDTH   ),
    // .RAM_MASK_WIDTH (`SF_WAY_NUM       )
    // ) u_sf_sram (
    // .CLK            (clk               ),
    // .WE             (|sf_wr_ways_q     ),
    // .WMASK          (sf_wr_ways_q      ),
    // .ADDR           (sf_index_q        ),
    // .DATA_IN        (sram_in           ),
    // .DATA_OUT       (sram_out          )
    // );
    // `else
    // genvar ii;
    generate
        for (ii = 0; ii < `SF_WAY_NUM; ii = ii + 1) begin
            ram_sp
                #(
                    .RAM_WIDTH(`SF_CLINE_WIDTH ),
                    .RAM_DEPTH(2**`SF_INDEX_WIDTH)
                )
                u_sf_sram1 (
                    .clka(clk),    // input wire clka
                    .ena(1'b1),      // input wire ena
                    .wea(sf_wr_ways_q[ii]),      // input wire [0 : 0] wea
                    .addra(sf_index_q),  // input wire [13 : 0] addra
                    .dina(sram_in[(`SF_CLINE_WIDTH*ii)+:`SF_CLINE_WIDTH]),    // input wire [27 : 0] dina
                    .douta(sram_out[(`SF_CLINE_WIDTH*ii)+:`SF_CLINE_WIDTH])  // output wire [27 : 0] douta
                );
        end
    endgenerate
    //`endif

    //wrap data
    always@*begin
        sram_in = {`SF_CLINE_WIDTH*`SF_WAY_NUM{1'b0}};
        for(i=0;i<`SF_WAY_NUM;i=i+1)begin
            sram_in[i*`SF_CLINE_WIDTH +: `SF_CLINE_WIDTH] = sram_in[i*`SF_CLINE_WIDTH +: `SF_CLINE_WIDTH] | (sf_wr_cline_q & {`SF_CLINE_WIDTH{sf_wr_ways_q[i]}});
        end
    end

    //data -> D
    always@ * //(posedge clk or posedge rst)
    begin
        if(rst == 1'b1)begin
            sf_rd_clines_q <= {`SF_CLINE_WIDTH*`SF_WAY_NUM{1'b0}};
        end
        else begin
            sf_rd_clines_q <= sram_out;
        end
    end

endmodule
`endif
