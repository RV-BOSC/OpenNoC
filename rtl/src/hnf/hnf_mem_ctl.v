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
*    Wenhao Li <liwenhao@bosc.ac.cn>
*    Li Zhao <lizhao@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_mem_ctl `HNF_PARAM
    (

        // global inputs
        clk,
        rst,
`ifdef tb_hnf
        // debug ports
        dbg_l3_valid_q,
        dbg_l3_index_q,
        dbg_l3_rd_ways_q,
        dbg_l3_wr_data_q,
        dbg_l3_wr_ways_q,
        dbg_loc_valid_q,
        dbg_loc_index_q,
        dbg_loc_rd_en_q,
        dbg_loc_wr_ways_q,
        dbg_loc_wr_cline_q,
        dbg_sf_valid_q,
        dbg_sf_index_q,
        dbg_sf_rd_en_q,
        dbg_sf_wr_ways_q,
        dbg_sf_wr_cline_q,
        dbg_lru_valid_q,
        dbg_lru_index_q,
        dbg_lru_rd_en_q,
        dbg_lru_wr_en_q,
        dbg_lru_wr_data_q,
        dbg_l3_rd_data_q,
        dbg_lru_rd_data_q,
        dbg_loc_rd_clines_q,
        dbg_sf_rd_clines_q,
        loc_rd_clines_q,
        sf_rd_clines_q,
        l3_rd_data_q,
        lru_rd_data_q,
`endif
        // cpl ports
        cpl_l3_index_q,
        cpl_l3_rd_ways_q,
        dbf_l3_wr_data_q,
        cpl_l3_wr_ways_q,
        cpl_loc_index_q,
        cpl_loc_rd_en_q,
        cpl_loc_wr_ways_q,
        cpl_loc_wr_cline_q,
        cpl_sf_index_q,
        cpl_sf_rd_en_q,
        cpl_sf_wr_ways_q,
        cpl_sf_wr_cline_q,
        cpl_lru_index_q,
        cpl_lru_rd_en_q,
        cpl_lru_wr_en_q,
        cpl_lru_wr_data_q,

        // sf sram ports
        sf_index_q,
        sf_rd_en_q,
        sf_wr_ways_q,
        sf_wr_cline_q,

        // tag sram ports
        loc_index_q,
        loc_rd_en_q,
        loc_wr_ways_q,
        loc_wr_cline_q,

        // lru sram ports
        lru_index_q,
        lru_rd_en_q,
        lru_wr_en_q,
        lru_wr_data_q,

        // L3 sram ports
        l3_index_q,
        l3_rd_ways_q,
        l3_wr_data_q,
        l3_wr_ways_q,

        // notify output reg port
        notify_reg
    );

    // global inputs
    input wire                                      clk;
    input wire                                      rst;

`ifdef tb_hnf
    //debug ports
    //inputs
    input wire                                      dbg_l3_valid_q;
    input wire [`LOC_INDEX_WIDTH-1:0]               dbg_l3_index_q;
    input wire [`LOC_WAY_NUM-1:0]                   dbg_l3_rd_ways_q;
    input wire [`CACHE_LINE_WIDTH-1:0]              dbg_l3_wr_data_q;
    input wire [`LOC_WAY_NUM-1:0]                   dbg_l3_wr_ways_q;
    input wire                                      dbg_loc_valid_q;
    input wire [`LOC_INDEX_WIDTH-1:0]               dbg_loc_index_q;
    input wire                                      dbg_loc_rd_en_q;
    input wire [`LOC_WAY_NUM-1:0]                   dbg_loc_wr_ways_q;
    input wire [`LOC_CLINE_WIDTH-1:0]               dbg_loc_wr_cline_q;
    input wire                                      dbg_sf_valid_q;
    input wire [`SF_INDEX_WIDTH-1:0]                dbg_sf_index_q;
    input wire                                      dbg_sf_rd_en_q;
    input wire [`SF_WAY_NUM-1:0]                    dbg_sf_wr_ways_q;
    input wire [`SF_CLINE_WIDTH-1:0]                dbg_sf_wr_cline_q;
    input wire                                      dbg_lru_valid_q;
    input wire [`LOC_INDEX_WIDTH-1:0]               dbg_lru_index_q;
    input wire                                      dbg_lru_rd_en_q;
    input wire                                      dbg_lru_wr_en_q;
    input wire [`LRU_CLINE_WIDTH-1:0]               dbg_lru_wr_data_q;
    input wire [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0]  loc_rd_clines_q;
    input wire [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]    sf_rd_clines_q;
    input wire [`CACHE_LINE_WIDTH-1:0]              l3_rd_data_q;
    input wire [`LRU_CLINE_WIDTH-1:0]               lru_rd_data_q;

    //outputs
    output wire [`CACHE_LINE_WIDTH-1:0]             dbg_l3_rd_data_q;
    output wire [`LRU_CLINE_WIDTH-1:0]              dbg_lru_rd_data_q;
    output reg  [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0] dbg_loc_rd_clines_q;
    output reg  [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]   dbg_sf_rd_clines_q;
`endif

    // cpl ports
    input wire [`LOC_INDEX_WIDTH-1:0]               cpl_l3_index_q;
    input wire [`LOC_WAY_NUM-1:0]                   cpl_l3_rd_ways_q;
    input wire [`CACHE_LINE_WIDTH-1:0]              dbf_l3_wr_data_q;
    input wire [`LOC_WAY_NUM-1:0]                   cpl_l3_wr_ways_q;
    input wire [`LOC_INDEX_WIDTH-1:0]               cpl_loc_index_q;
    input wire                                      cpl_loc_rd_en_q;
    input wire [`LOC_WAY_NUM-1:0]                   cpl_loc_wr_ways_q;
    input wire [`LOC_CLINE_WIDTH-1:0]               cpl_loc_wr_cline_q;
    input wire [`SF_INDEX_WIDTH-1:0]                cpl_sf_index_q;
    input wire                                      cpl_sf_rd_en_q;
    input wire [`SF_WAY_NUM-1:0]                    cpl_sf_wr_ways_q;
    input wire [`SF_CLINE_WIDTH-1:0]                cpl_sf_wr_cline_q;
    input wire [`LOC_INDEX_WIDTH-1:0]               cpl_lru_index_q;
    input wire                                      cpl_lru_rd_en_q;
    input wire                                      cpl_lru_wr_en_q;
    input wire [`LRU_CLINE_WIDTH-1:0]               cpl_lru_wr_data_q;

    // sf sram ports
    output wire [`SF_INDEX_WIDTH-1:0]               sf_index_q;
    output wire                                     sf_rd_en_q;
    output wire [`SF_WAY_NUM-1:0]                   sf_wr_ways_q;
    output wire [`SF_CLINE_WIDTH-1:0]               sf_wr_cline_q;

    // tag sram ports
    output wire [`LOC_INDEX_WIDTH-1:0]              loc_index_q;
    output wire                                     loc_rd_en_q;
    output wire [`LOC_WAY_NUM-1:0]                  loc_wr_ways_q;
    output wire [`LOC_CLINE_WIDTH-1:0]              loc_wr_cline_q;

    // lru sram ports
    output wire [`LOC_INDEX_WIDTH-1:0]              lru_index_q;
    output wire                                     lru_rd_en_q;
    output wire                                     lru_wr_en_q;
    output wire [`LRU_CLINE_WIDTH-1:0]              lru_wr_data_q;

    // L3 sram ports
    output wire [`LOC_INDEX_WIDTH-1:0]              l3_index_q;
    output wire [`LOC_WAY_NUM-1:0]                  l3_rd_ways_q;
    output wire [`LOC_WAY_NUM-1:0]                  l3_wr_ways_q;
    output wire [`CACHE_LINE_WIDTH-1:0]             l3_wr_data_q;

    // notify output reg port
    output reg  [2:0]                               notify_reg;

    // internal regs
    reg [31:0]                                      sf_cnt_reg;
    reg [ 1:0]                                      sf_done_reg;
    reg [31:0]                                      loc_cnt_reg;
    reg [ 1:0]                                      loc_done_reg;
    reg [31:0]                                      lru_cnt_reg;
    reg [ 1:0]                                      lru_done_reg;

    // internal wires
    wire                                            init_loc_valid_q;
    wire [`LOC_INDEX_WIDTH-1:0]                     init_loc_index_q;
    wire                                            init_loc_rd_en_q;
    wire [`LOC_WAY_NUM-1:0]                         init_loc_wr_ways_q;
    wire [`LOC_CLINE_WIDTH-1:0]                     init_loc_wr_cline_q;
    wire                                            init_sf_valid_q;
    wire [`SF_INDEX_WIDTH-1:0]                      init_sf_index_q;
    wire                                            init_sf_rd_en_q;
    wire [`SF_WAY_NUM-1:0]                          init_sf_wr_ways_q;
    wire [`SF_CLINE_WIDTH-1:0]                      init_sf_wr_cline_q;
    wire                                            init_lru_valid_q;
    wire [`LOC_INDEX_WIDTH-1:0]                     init_lru_index_q;
    wire                                            init_lru_rd_en_q;
    wire                                            init_lru_wr_en_q;
    wire [`LRU_CLINE_WIDTH-1:0]                     init_lru_wr_data_q;
    wire [2:0]                                      notify_ns;

    // global notify register
    assign notify_ns[0] = &sf_done_reg;
    assign notify_ns[1] = &loc_done_reg;
    assign notify_ns[2] = &lru_done_reg;

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            notify_reg <= {3{1'b0}};
        end
        else begin
            notify_reg <= notify_ns;
        end
    end

    // sf notify register
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            sf_cnt_reg <= {32{1'b1}};
        end
        else if (sf_cnt_reg == {`SF_INDEX_WIDTH{1'b1}}) begin
        end
        else begin
            sf_cnt_reg <= sf_cnt_reg + 1;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            sf_done_reg <= 2'b00;
        end
        else if (sf_cnt_reg == {`SF_INDEX_WIDTH{1'b1}}) begin
            sf_done_reg <= 2'b11;
        end
        else begin
            sf_done_reg <= 2'b01;
        end
    end

    assign init_sf_valid_q    = (sf_done_reg == 2'b01)? 1'b1 : 1'b0;
    assign init_sf_rd_en_q    = 1'b0;
    assign init_sf_index_q    = sf_cnt_reg[`SF_INDEX_WIDTH-1:0];
    assign init_sf_wr_ways_q  = (sf_done_reg == 2'b01)? {`SF_WAY_NUM{1'b1}} : {`SF_WAY_NUM{1'b0}};
    assign init_sf_wr_cline_q = {`SF_CLINE_WIDTH{1'b0}};

    // loc notify register
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            loc_cnt_reg <= {32{1'b1}};
        end
        else if (loc_cnt_reg == {`LOC_INDEX_WIDTH{1'b1}}) begin
        end
        else begin
            loc_cnt_reg <= loc_cnt_reg + 1;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            loc_done_reg <= 2'b00;
        end
        else if (loc_cnt_reg == {`LOC_INDEX_WIDTH{1'b1}}) begin
            loc_done_reg <= 2'b11;
        end
        else begin
            loc_done_reg <= 2'b01;
        end
    end

    assign init_loc_valid_q    = (loc_done_reg == 2'b01)? 1'b1 : 1'b0;
    assign init_loc_rd_en_q    = 1'b0;
    assign init_loc_index_q    = loc_cnt_reg[`LOC_INDEX_WIDTH-1:0];
    assign init_loc_wr_ways_q  = (loc_done_reg == 2'b01)? {`LOC_WAY_NUM{1'b1}} : {`LOC_WAY_NUM{1'b0}};
    assign init_loc_wr_cline_q = {`LOC_CLINE_WIDTH{1'b0}};

    // lru notify register
    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            lru_cnt_reg <= {32{1'b1}};
        end
        else if (lru_cnt_reg == {`LOC_INDEX_WIDTH{1'b1}}) begin
        end
        else begin
            lru_cnt_reg <= lru_cnt_reg + 1;
        end
    end

    always @ (posedge clk or posedge rst) begin
        if (rst) begin
            lru_done_reg <= 2'b00;
        end
        else if (lru_cnt_reg == {`LOC_INDEX_WIDTH{1'b1}}) begin
            lru_done_reg <= 2'b11;
        end
        else begin
            lru_done_reg <= 2'b01;
        end
    end

    assign init_lru_valid_q   = (lru_done_reg == 2'b01)? 1'b1 : 1'b0;
    assign init_lru_rd_en_q   = 1'b0;
    assign init_lru_index_q   = lru_cnt_reg[`LOC_INDEX_WIDTH-1:0];
    assign init_lru_wr_en_q   = (lru_done_reg == 2'b01)? 1'b1 : 1'b0;
    assign init_lru_wr_data_q = {`LRU_CLINE_WIDTH{1'b0}};

`ifdef tb_hnf
    //debug use only!
    assign sf_index_q        = init_sf_valid_q? init_sf_index_q    : dbg_sf_valid_q? dbg_sf_index_q    : cpl_sf_index_q;
    assign sf_rd_en_q        = init_sf_valid_q? init_sf_rd_en_q    : dbg_sf_valid_q? dbg_sf_rd_en_q    : cpl_sf_rd_en_q;
    assign sf_wr_ways_q      = init_sf_valid_q? init_sf_wr_ways_q  : dbg_sf_valid_q? dbg_sf_wr_ways_q  : cpl_sf_wr_ways_q;
    assign sf_wr_cline_q     = init_sf_valid_q? init_sf_wr_cline_q : dbg_sf_valid_q? dbg_sf_wr_cline_q : cpl_sf_wr_cline_q;

    assign loc_index_q       = init_loc_valid_q? init_loc_index_q    : dbg_loc_valid_q? dbg_loc_index_q    : cpl_loc_index_q;
    assign loc_rd_en_q       = init_loc_valid_q? init_loc_rd_en_q    : dbg_loc_valid_q? dbg_loc_rd_en_q    : cpl_loc_rd_en_q;
    assign loc_wr_ways_q     = init_loc_valid_q? init_loc_wr_ways_q  : dbg_loc_valid_q? dbg_loc_wr_ways_q  : cpl_loc_wr_ways_q;
    assign loc_wr_cline_q    = init_loc_valid_q? init_loc_wr_cline_q : dbg_loc_valid_q? dbg_loc_wr_cline_q : cpl_loc_wr_cline_q;

    assign lru_index_q       = init_lru_valid_q? init_lru_index_q   : dbg_lru_valid_q? dbg_lru_index_q   : cpl_lru_index_q;
    assign lru_rd_en_q       = init_lru_valid_q? init_lru_rd_en_q   : dbg_lru_valid_q? dbg_lru_rd_en_q   : cpl_lru_rd_en_q;
    assign lru_wr_en_q       = init_lru_valid_q? init_lru_wr_en_q   : dbg_lru_valid_q? dbg_lru_wr_en_q   : cpl_lru_wr_en_q;
    assign lru_wr_data_q     = init_lru_valid_q? init_lru_wr_data_q : dbg_lru_valid_q? dbg_lru_wr_data_q : cpl_lru_wr_data_q;
    assign dbg_lru_rd_data_q = lru_rd_data_q;

    assign l3_index_q        = dbg_l3_valid_q? dbg_l3_index_q   : cpl_l3_index_q  ;
    assign l3_rd_ways_q      = dbg_l3_valid_q? dbg_l3_rd_ways_q : cpl_l3_rd_ways_q;
    assign l3_wr_data_q      = dbg_l3_valid_q? dbg_l3_wr_data_q : dbf_l3_wr_data_q;
    assign l3_wr_ways_q      = dbg_l3_valid_q? dbg_l3_wr_ways_q : cpl_l3_wr_ways_q;
    assign dbg_l3_rd_data_q  = l3_rd_data_q;

    always@*begin
        dbg_sf_rd_clines_q  = sf_rd_clines_q;
    end

    always@*begin
        dbg_loc_rd_clines_q = loc_rd_clines_q;
    end
`else
    assign sf_index_q     = init_sf_valid_q? init_sf_index_q    : cpl_sf_index_q;
    assign sf_rd_en_q     = init_sf_valid_q? init_sf_rd_en_q    : cpl_sf_rd_en_q;
    assign sf_wr_ways_q   = init_sf_valid_q? init_sf_wr_ways_q  : cpl_sf_wr_ways_q;
    assign sf_wr_cline_q  = init_sf_valid_q? init_sf_wr_cline_q : cpl_sf_wr_cline_q;

    assign loc_index_q    = init_loc_valid_q? init_loc_index_q    : cpl_loc_index_q;
    assign loc_rd_en_q    = init_loc_valid_q? init_loc_rd_en_q    : cpl_loc_rd_en_q;
    assign loc_wr_ways_q  = init_loc_valid_q? init_loc_wr_ways_q  : cpl_loc_wr_ways_q;
    assign loc_wr_cline_q = init_loc_valid_q? init_loc_wr_cline_q : cpl_loc_wr_cline_q;

    assign lru_index_q    = init_lru_valid_q? init_lru_index_q   : cpl_lru_index_q;
    assign lru_rd_en_q    = init_lru_valid_q? init_lru_rd_en_q   : cpl_lru_rd_en_q;
    assign lru_wr_en_q    = init_lru_valid_q? init_lru_wr_en_q   : cpl_lru_wr_en_q;
    assign lru_wr_data_q  = init_lru_valid_q? init_lru_wr_data_q : cpl_lru_wr_data_q;

    assign l3_index_q     = cpl_l3_index_q;
    assign l3_rd_ways_q   = cpl_l3_rd_ways_q;
    assign l3_wr_data_q   = dbf_l3_wr_data_q;
    assign l3_wr_ways_q   = cpl_l3_wr_ways_q;
`endif

endmodule
