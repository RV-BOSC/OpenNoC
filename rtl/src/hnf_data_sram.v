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
*    Hongyu Gao <gaohongyu@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"
`ifndef FPGA_MEMORY
module hnf_data_sram `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_cache_pipeline
        l3_index_q,
        l3_rd_ways_q,
        l3_wr_data_q,
        l3_wr_ways_q,

        //outputs to hnf_data_buffer
        l3_rd_data_q
    );

    //global inputs
    input wire                                clk;
    input wire                                rst;

    //inputs from hnf_cache_pipeline
    input wire [`LOC_INDEX_WIDTH-1:0]         l3_index_q;
    input wire [`LOC_WAY_NUM-1:0]             l3_rd_ways_q;
    input wire [`LOC_WAY_NUM-1:0]             l3_wr_ways_q;
    input wire [`CACHE_LINE_WIDTH-1:0]        l3_wr_data_q;

    //outputs to hnf_cache_pipeline
    output reg [`CACHE_LINE_WIDTH-1:0]        l3_rd_data_q;

    //internal reg signals
    reg [`CACHE_LINE_WIDTH-1:0]               l3_rd_data;
    reg [`LOC_WAY_NUM-1:0]                    l3_rd_ways_q_nxt;

    //internal wire signals
    wire [`CACHE_LINE_WIDTH*`LOC_WAY_NUM-1:0] sram_out;

    //internal variables
    integer i;

    //module instantiation
    hnf_sram_mask #(
                      .RAM_ADDR_WIDTH (`LOC_INDEX_WIDTH  ),
                      .RAM_DATA_WIDTH (`CACHE_LINE_WIDTH ),
                      .RAM_MASK_WIDTH (`LOC_WAY_NUM      )
                  ) u_sram (
                      .CLK            (clk               ),
                      .WE             (|l3_wr_ways_q     ),
                      .WMASK          (l3_wr_ways_q      ),
                      .ADDR           (l3_index_q        ),
                      .DATA_IN        (l3_wr_data_q      ),
                      .DATA_OUT       (sram_out          )
                  );

    //main function

`ifdef HNF_DELAY_ONE_CYCLE

    always@(posedge clk or posedge rst)begin
        if(rst == 1'b1)begin
            l3_rd_ways_q_nxt <= {`LOC_WAY_NUM{1'b0}};
        end
        else begin
            l3_rd_ways_q_nxt <= l3_rd_ways_q;
        end
    end

    // select way data
    always@*begin
        l3_rd_data = {`CACHE_LINE_WIDTH{1'b0}};
        for(i=0;i<`LOC_WAY_NUM;i=i+1)begin
            l3_rd_data = l3_rd_data | (sram_out[i*`CACHE_LINE_WIDTH +: `CACHE_LINE_WIDTH] & {`CACHE_LINE_WIDTH{l3_rd_ways_q_nxt[i]}});
        end
    end

`else

    // select way data
    always@*begin
        l3_rd_data = {`CACHE_LINE_WIDTH{1'b0}};
        for(i=0;i<`LOC_WAY_NUM;i=i+1)begin
            l3_rd_data = l3_rd_data | (sram_out[i*`CACHE_LINE_WIDTH +: `CACHE_LINE_WIDTH] & {`CACHE_LINE_WIDTH{l3_rd_ways_q[i]}});
        end
    end
`endif

    //data -> D
    always@(posedge clk or posedge rst)begin
        if(rst == 1'b1)begin
            l3_rd_data_q <= {`CACHE_LINE_WIDTH{1'b0}};
        end
        else begin
            l3_rd_data_q <= l3_rd_data;
        end
    end

endmodule

`else
module hnf_data_sram `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_cache_pipeline
        l3_index_q,
        l3_rd_ways_q,
        l3_wr_data_q,
        l3_wr_ways_q,

        //outputs to hnf_data_buffer
        l3_rd_data_q
    );

    //global inputs
    input wire                                clk;
    input wire                                rst;

    //inputs from hnf_cache_pipeline
    input wire [`LOC_INDEX_WIDTH-1:0]         l3_index_q;
    input wire [`LOC_WAY_NUM-1:0]             l3_rd_ways_q;
    input wire [`LOC_WAY_NUM-1:0]             l3_wr_ways_q;
    input wire [`CACHE_LINE_WIDTH-1:0]        l3_wr_data_q;

    //outputs to hnf_cache_pipeline
    output reg [`CACHE_LINE_WIDTH-1:0]        l3_rd_data_q;

    //internal reg signals
    reg [`CACHE_LINE_WIDTH-1:0]               l3_rd_data;
    reg [`LOC_WAY_NUM-1:0]                    l3_rd_ways_q_nxt;
    reg [`CACHE_LINE_WIDTH*`LOC_WAY_NUM-1:0]  sram_in;

    //internal wire signals
    wire [`CACHE_LINE_WIDTH*`LOC_WAY_NUM-1:0] sram_out,sram_out1;

    //internal variables
    integer i;
    genvar ii;

    //module instantiation
    generate
        for (ii = 0; ii < `LOC_WAY_NUM; ii = ii + 1) begin
            ram_sp
                #(
                    .RAM_WIDTH(`CACHE_LINE_WIDTH ),
                    .RAM_DEPTH(2**`LOC_INDEX_WIDTH)
                )
                data_mem_u0 (
                    .clka(clk),    // input wire clka
                    .ena(1'b1),      // input wire ena
                    .wea(l3_wr_ways_q[ii]),      // input wire [0 : 0] wea
                    .addra(l3_index_q),  // input wire [13 : 0] addra
                    .dina(sram_in[(`CACHE_LINE_WIDTH*ii)+:`CACHE_LINE_WIDTH]),    // input wire [511 : 0] dina
                    .douta(sram_out[(`CACHE_LINE_WIDTH*ii)+:`CACHE_LINE_WIDTH])  // output wire [511 : 0] douta
                );
        end
    endgenerate

    hnf_sram_mask #(
                      .RAM_ADDR_WIDTH (`LOC_INDEX_WIDTH  ),
                      .RAM_DATA_WIDTH (`CACHE_LINE_WIDTH ),
                      .RAM_MASK_WIDTH (`LOC_WAY_NUM      )
                  ) u_sram (
                      .CLK            (clk               ),
                      .WE             (|l3_wr_ways_q     ),
                      .WMASK          (l3_wr_ways_q      ),
                      .ADDR           (l3_index_q        ),
                      .DATA_IN        (sram_in           ),
                      .DATA_OUT       (sram_out1          )
                  );

    //main function
    //wrap data to 1024 bytes
    always@*begin
        sram_in = {`CACHE_LINE_WIDTH*`LOC_WAY_NUM{1'b0}};
        for(i=0;i<`LOC_WAY_NUM;i=i+1)begin
            sram_in[i*`CACHE_LINE_WIDTH +: `CACHE_LINE_WIDTH] = sram_in[i*`CACHE_LINE_WIDTH +: `CACHE_LINE_WIDTH] | (l3_wr_data_q & {`CACHE_LINE_WIDTH{l3_wr_ways_q[i]}});
        end
    end
    always@(posedge clk or posedge rst)begin
        if(rst == 1'b1)begin
            l3_rd_ways_q_nxt <= {`LOC_WAY_NUM{1'b0}};
        end
        else begin
            l3_rd_ways_q_nxt <= l3_rd_ways_q;
        end
    end
`ifdef HNF_DELAY_ONE_CYCLE



    // select way data
    always@*begin
        l3_rd_data = {`CACHE_LINE_WIDTH{1'b0}};
        for(i=0;i<`LOC_WAY_NUM;i=i+1)begin
            l3_rd_data = l3_rd_data | (sram_out[i*`CACHE_LINE_WIDTH +: `CACHE_LINE_WIDTH] & {`CACHE_LINE_WIDTH{l3_rd_ways_q_nxt[i]}});
        end
    end

`else

// select way data
always@*begin
    l3_rd_data = {`CACHE_LINE_WIDTH{1'b0}};
    for(i=0;i<`LOC_WAY_NUM;i=i+1)begin
        l3_rd_data = l3_rd_data | (sram_out[i*`CACHE_LINE_WIDTH +: `CACHE_LINE_WIDTH] & {`CACHE_LINE_WIDTH{l3_rd_ways_q_nxt[i]}});
    end
end
`endif

    //data -> D
    always@ * //(posedge clk or posedge rst)
    begin
        if(rst == 1'b1)begin
            l3_rd_data_q <= {`CACHE_LINE_WIDTH{1'b0}};
        end
        else begin
            l3_rd_data_q <= l3_rd_data;
        end
    end

endmodule
`endif
