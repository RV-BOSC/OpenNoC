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
*    Jianxing Wang <wangjianxing@bosc.ac.cn>
*    Ziqing Li <liziqing@bosc.ac.cn>
*    Jianhong Zhang <zhangjianhong@bosc.ac.cn>
*    Qianruo Li <liqianruo@bosc.ac.cn> 
*    Bingcheng Jin <jinbingcheng@bosc.ac.cn>
*    Hongyu Gao <gaohongyu@bosc.ac.cn>
*    Li Zhao <lizhao@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_cache_pipeline `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_mshr_ctl
        mshr_l3_req_en_sx1_q,
        mshr_l3_addr_sx1,
        mshr_l3_entry_idx_sx1_q,
        mshr_l3_fill_sx1_q,
        mshr_l3_opcode_sx1_q,
        mshr_l3_rnf_sx1_q,
        mshr_l3_fill_dirty_sx1_q,
        mshr_l3_seq_retire_sx1_q,

        //inputs from hnf_tag_sram
        loc_rd_clines_q,

        //inputs from hnf_sf_sram
        sf_rd_clines_q,

        //inputs from hnf_lru_sram
        lru_rd_data_q,

        //inputs from hnf_mshr_addr_buffer
        mshr_l3_hazard_valid_sx3_q,

        //outputs to hnf_tag_sram
        loc_index_q,
        loc_rd_en_q,
        loc_wr_ways_q,
        loc_wr_cline_q,

        //outputs to hnf_sf_sram
        sf_index_q,
        sf_rd_en_q,
        sf_wr_ways_q,
        sf_wr_cline_q,

        //outputs to hnf_data_sram
        l3_index_q,
        l3_rd_ways_q,
        l3_wr_ways_q,

        //outputs to hnf_lru_sram
        lru_index_q,
        lru_rd_en_q,
        lru_wr_en_q,
        lru_wr_data_q,

        //outputs to hnf_mshr_addr_buffer
        pipe_mshr_addr_sx5_q,
        pipe_mshr_addr_valid_sx5_q,
        pipe_mshr_addr_idx_sx5_q,
        l3_evict_addr_sx7_q,

        //outputs to hnf_mshr_addr_buffer and hnf_mshr_ctl
        l3_evict_sx7_q,
        l3_mshr_entry_sx7_q,

        //outputs to hnf_mshr_ctl
        biq_req_valid_s0_q,
        biq_req_addr_s0_q,
        l3_pipeval_sx7_q,
        l3_opcode_sx7_q,
        l3_memrd_sx7_q,
        l3_hit_sx7_q,
        l3_hit_dirty_sx7_q,
        l3_sfhit_sx7_q,
        l3_snpdirect_sx7_q,
        l3_snpbrd_sx7_q,
        l3_snp_bit_sx7_q,
        l3_replay_sx7_q,
        l3_mshr_wr_op_sx7_q,

        //outputs to hnf_data_buffer
        pipe_dbf_wr_valid_sx9_q,
        pipe_dbf_wr_idx_sx9_q,
        pipe_dbf_rd_idx_valid_sx6_q,
        pipe_dbf_rd_idx_sx6_q
    );
    //local param
    localparam CPL_HZD_ENTRY  = 4;
    localparam CPL_HZD_WIDTH  = $clog2(CPL_HZD_ENTRY);
    localparam SX1            = 0;
    localparam SX2            = (SX1 + 1);
    localparam SX3            = (SX2 + 1);
    localparam SX4            = (SX3 + 1);
    localparam SX5            = (SX4 + 1);
    localparam SX6            = (SX5 + 1);
    localparam SX7            = (SX6 + 1);
    localparam CPL_STAGE      = (SX7);
    localparam ADDR_WIDTH     = `CHIE_REQ_FLIT_ADDR_WIDTH;
    localparam OPCODE_WIDTH   = `CHIE_REQ_FLIT_OPCODE_WIDTH;
    localparam NID_WIDTH      = CHIE_NID_WIDTH_PARAM;
    localparam BIQ_NUM        = 8;
    localparam BIQ_NUM_WIDTH  = $clog2(BIQ_NUM);
    localparam BIQ_DATA_WIDTH = ADDR_WIDTH;

    //global inputs
    input wire                                   clk;
    input wire                                   rst;

    //inputs from hnf_mshr_ctl
    input wire                                   mshr_l3_req_en_sx1_q;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]   mshr_l3_addr_sx1;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]         mshr_l3_entry_idx_sx1_q;
    input wire                                   mshr_l3_fill_sx1_q;
    input wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0] mshr_l3_opcode_sx1_q;
    input wire [CHIE_NID_WIDTH_PARAM-1:0]        mshr_l3_rnf_sx1_q;
    input wire                                   mshr_l3_fill_dirty_sx1_q;
    input wire                                   mshr_l3_seq_retire_sx1_q;

    //inputs from hnf_tag_sram
    input wire [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0] loc_rd_clines_q;

    //inputs from hnf_sf_sram
    input wire [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]   sf_rd_clines_q;

    //inputs from hnf_lru_sram
    input wire [`LRU_CLINE_WIDTH-1:0]            lru_rd_data_q;

    //inputs from hnf_mshr_addr_buffer
    input wire                                   mshr_l3_hazard_valid_sx3_q;

    //outputs to hnf_tag_sram
    output reg [`LOC_INDEX_WIDTH-1:0]            loc_index_q;
    output reg                                   loc_rd_en_q;
    output reg [`LOC_WAY_NUM-1:0]                loc_wr_ways_q;
    output reg [`LOC_CLINE_WIDTH-1:0]            loc_wr_cline_q;

    //outputs to hnf_sf_sram
    output reg [`SF_INDEX_WIDTH-1:0]             sf_index_q;
    output reg                                   sf_rd_en_q;
    output reg [`SF_WAY_NUM-1:0]                 sf_wr_ways_q;
    output reg [`SF_CLINE_WIDTH-1:0]             sf_wr_cline_q;

    //outputs to hnf_data_sram
    output reg [`LOC_INDEX_WIDTH-1:0]            l3_index_q;
    output reg [`LOC_WAY_NUM-1:0]                l3_rd_ways_q;
    output reg [`LOC_WAY_NUM-1:0]                l3_wr_ways_q;

    //outputs to hnf_lru_sram
    output reg [`LOC_INDEX_WIDTH-1:0]            lru_index_q;
    output reg                                   lru_rd_en_q;
    output reg                                   lru_wr_en_q;
    output reg [`LRU_CLINE_WIDTH-1:0]            lru_wr_data_q;

    //outputs to hnf_mshr_addr_buffer
    output reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]   pipe_mshr_addr_sx5_q;
    output reg                                   pipe_mshr_addr_valid_sx5_q;
    output reg [`MSHR_ENTRIES_WIDTH-1:0]         pipe_mshr_addr_idx_sx5_q;

    //outputs to hnf_mshr_addr_buffer and hnf_mshr_ctl
    output reg                                   l3_evict_sx7_q;
    output reg [`MSHR_ENTRIES_WIDTH-1:0]         l3_mshr_entry_sx7_q;

    //outputs to hnf_link_rxreq_wrap
    output wire                                  biq_req_valid_s0_q;
    output wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]  biq_req_addr_s0_q;

    //outputs to hnf_mshr_ctl
    output reg                                   l3_pipeval_sx7_q;
    output reg [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0] l3_opcode_sx7_q;
    output reg                                   l3_memrd_sx7_q;
    output reg                                   l3_hit_sx7_q;
    output reg                                   l3_hit_dirty_sx7_q;
    output reg                                   l3_sfhit_sx7_q;
    output reg                                   l3_snpdirect_sx7_q;
    output reg                                   l3_snpbrd_sx7_q;
    output reg [HNF_MSHR_RNF_NUM_PARAM-1:0]      l3_snp_bit_sx7_q;
    output reg                                   l3_replay_sx7_q;
    output reg                                   l3_mshr_wr_op_sx7_q;
    output reg [ADDR_WIDTH-1:0]                  l3_evict_addr_sx7_q;

    //outputs to hnf_data_buffer
    output reg                                   pipe_dbf_wr_valid_sx9_q;
    output reg [`MSHR_ENTRIES_WIDTH-1:0]         pipe_dbf_wr_idx_sx9_q;
    output reg                                   pipe_dbf_rd_idx_valid_sx6_q;
    output reg [`MSHR_ENTRIES_WIDTH-1:0]         pipe_dbf_rd_idx_sx6_q;

    //internal variables
    genvar gi;
    integer ii;

    //internal signals

    /////////////////////////////////////////////////////////////
    //===========================================================
    // CPL every stage keep all MSHR info
    /////////////////////////////////////////////////////////////
    //===========================================================
    reg [OPCODE_WIDTH-1:0]                 pipe_opcode_sx_q[CPL_STAGE-1:0];
    reg [ADDR_WIDTH-1:0]                   pipe_addr_sx_q[CPL_STAGE-1:0];
    reg [NID_WIDTH-1:0]                    pipe_rnf_idx_sx_q[CPL_STAGE-1:0];
    reg [`MSHR_ENTRIES_WIDTH-1:0]          pipe_mshr_idx_sx_q[CPL_STAGE-1:0];
    reg [CPL_STAGE-1:0]                    pipe_fill_sx_q;
    reg [CPL_STAGE-1:0]                    pipe_fill_dirty_sx_q;
    reg [CPL_STAGE-1:0]                    pipe_req_valid_sx_q;
    wire [CPL_STAGE-2:0]                   pipe_req_valid_sx;

    /////////////////////////////////////////////////////////////
    //===========================================================
    // Stage SX1 signals
    /////////////////////////////////////////////////////////////
    //===========================================================
    wire [OPCODE_WIDTH-1:0]                 pipe_opcode_sx1;
    wire [ADDR_WIDTH-1:0]                   pipe_addr_sx1;
    wire [NID_WIDTH-1:0]                    pipe_rnf_idx_sx1;
    wire [`MSHR_ENTRIES_WIDTH-1:0]          pipe_mshr_idx_sx1;
    wire                                    pipe_fill_sx1;
    wire                                    pipe_fill_dirty_sx1;
    wire                                    pipe_req_bypass_sx1;
    wire                                    pipe_mshr_req_valid_sx1;

    /////////////////////////////////////////////////////////////
    //===========================================================
    // Stage SX2 signals
    /////////////////////////////////////////////////////////////
    //===========================================================
    // mshr requst signals
    wire                                    pipe_tag_rd_sx1;
    wire                                    pipe_sf_rd_sx1;
    wire                                    pipe_lru_rd_sx1;

    // cpl internal write signals
    wire                                    pipe_tag_wr_sx1;
    wire                                    pipe_sf_wr_sx1;
    wire                                    pipe_lru_wr_sx1;
    reg                                     pipe_data_wr_sx2_q;
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_wr_way_sx2_q;
    reg                                     pipe_wrap_wr_sx2_q;
    reg [ADDR_WIDTH-1:0]                    pipe_addr_wr_sx2_q;
    reg [`RNF_NUM*NID_WIDTH-1:0]            pipe_nodeid_list_sx2;
    reg [NID_WIDTH-1:0]                     pipe_physical_nodeid_sx2;
    reg [NID_WIDTH-1:0]                     pipe_current_nodeid_sx2;
    reg                                     pipe_rnfid_found_sx2;

    /////////////////////////////////////////////////////////////
    //===========================================================
    // Stage SX3 signals
    /////////////////////////////////////////////////////////////
    //===========================================================

    // cpl internal write signals
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_wr_way_sx3_q;
    reg [ADDR_WIDTH-1:0]                    pipe_addr_wr_sx3_q;
    reg                                     pipe_data_wr_sx3_q;
    reg                                     pipe_wrap_wr_sx3_q;

    // Prepare decode stage for SX4
    wire [OPCODE_WIDTH-1:0]                 pipe_opcode_sx3;
    wire                                    op_rdonce_sx3;
    wire                                    op_rdnsd_sx3;
    wire                                    op_rdclean_sx3;
    wire                                    op_rdunique_sx3;
    wire                                    op_wufull_sx3;
    wire                                    op_wuptl_sx3;
    wire                                    op_wbfull_sx3;
    wire                                    op_wevict_sx3;
    wire                                    op_dl_cu_sx3;
    wire                                    op_dl_mu_sx3;
    wire                                    op_dl_evict_sx3;
    wire                                    op_cmo_cs_sx3;
    wire                                    op_cmo_ci_sx3;
    wire                                    pipe_mem_rd_sx3;

    // Tag Match signals
    wire [ADDR_WIDTH-1:0]                   pipe_addr_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_tag_match_vec_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_tag_dirty_vec_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_tag_free_vec_sx3;
    wire                                    pipe_tag_free_sx3;
    wire                                    pipe_tag_match_sx3;
    wire                                    pipe_tag_match_dirty_sx3;
    wire                                    pipe_tag_evict_dirty_sx3;
    wire                                    pipe_tag_evict_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_tag_evict_way_sx3;
    reg [`LOC_TAG_WIDTH-1:0]                pipe_tag_evict_tag_sx3;
    // LRU match signals
    wire [`LOC_WAY_NUM-1:0]                 pipe_lru_immediate_rrpv_vec_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_lru_near_immediate_rrpv_vec_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_lru_long_rrpv_vec_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_lru_distance_rrpv_vec_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_lru_immediate_alloc_vec_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_lru_near_immediate_alloc_vec_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_lru_long_alloc_vec_sx3;
    wire [`LOC_WAY_NUM-1:0]                 pipe_lru_distance_alloc_vec_sx3;
    wire                                    pipe_lru_immediate_found_sx3;
    wire                                    pipe_lru_near_immediate_found_sx3;
    wire                                    pipe_lru_long_found_sx3;
    wire                                    pipe_lru_distance_found_sx3;
    reg  [`LOC_WAY_NUM-1:0]                 pipe_lru_next_vec_q;
    wire [`LOC_WAY_NUM-1:0]                 pipe_lru_alloc_vec_sx3;
    // SF Match signals
    wire [`SF_WAY_NUM-1:0]                  pipe_sf_match_vec_sx3;
    wire [`SF_WAY_NUM-1:0]                  pipe_sf_free_vec_sx3;
    wire [`SF_WAY_NUM-1:0]                  pipe_sf_other_valid_vec_sx3;
    wire [`SF_WAY_NUM-1:0]                  pipe_sf_other_share_vec_sx3;
    wire [`SF_WAY_NUM-1:0]                  pipe_sf_self_valid_vec_sx3;
    wire [`SF_WAY_NUM-1:0]                  pipe_sf_self_share_vec_sx3;
    wire                                    pipe_sf_other_match_sx3;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_match_state_sx3;
    reg [`SF_TAG_WIDTH-1:0]                 pipe_sf_evict_tag_sx3;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_evict_state_sx3;
    // Random SF evict posistion, left shift per cycle
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_evict_next_sx3_q;
    // generate SF mask
    reg [`RNF_NUM*2-1:0]                    pipe_sf_other_valid_mask_sx3_q;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_other_share_mask_sx3_q;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_self_valid_mask_sx3_q;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_self_share_mask_sx3_q;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_self_mask_sx3_q;

    //===========================================================
    /////////////////////////////////////////////////////////////
    // Stage SX4 signals
    /////////////////////////////////////////////////////////////
    //===========================================================

    // cpl internal write signals
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_wr_way_sx4_q;
    reg [ADDR_WIDTH-1:0]                    pipe_addr_wr_sx4_q;
    reg                                     pipe_data_wr_sx4_q;
    reg                                     pipe_wrap_wr_sx4_q;

    //LRU data delay one cycle
    reg [`LRU_CLINE_WIDTH-1:0]              lru_rd_data_d_q;

    // MSHR request tag/sf state machine
    wire [ADDR_WIDTH-1:0]                   pipe_addr_sx4;
    wire                                    pipe_fill_sx4;
    reg                                     op_rdonce_sx4_q;
    reg                                     op_rdnsd_sx4_q;
    reg                                     op_rdclean_sx4_q;
    reg                                     op_rdunique_sx4_q;
    reg                                     op_wufull_sx4_q;
    reg                                     op_wuptl_sx4_q;
    reg                                     op_wbfull_sx4_q;
    reg                                     op_wevict_sx4_q;
    reg                                     op_dl_cu_sx4_q;
    reg                                     op_dl_mu_sx4_q;
    reg                                     op_dl_evict_sx4_q;
    reg                                     op_cmo_cs_sx4_q;
    reg                                     op_cmo_ci_sx4_q;

    /////////////////////////////////////////////////////////////
    // Tag Match signals
    /////////////////////////////////////////////////////////////
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_match_vec_sx4_q;
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_free_vec_sx4_q;
    reg                                     pipe_tag_match_sx4_q;
    reg                                     pipe_tag_free_sx4_q;
    reg                                     pipe_tag_match_dirty_sx4_q;
    reg                                     pipe_tag_evict_dirty_sx4_q;
    reg                                     pipe_tag_evict_sx4_q;
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_alloc_free_way_vec_sx4;
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_alloc_free_way_vector;
    reg [`LOC_TAG_WIDTH-1:0]                pipe_tag_evict_tag_sx4_q;
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_evict_way_sx4_q;
    wire [ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET] pipe_tag_evict_addr_sx4;
    wire [`LOC_WAY_NUM-1:0]                 pipe_tag_wr_way_sx4;
    wire [`LOC_WAY_NUM-1:0]                 pipe_tag_haz_way_sx4;

    // Tag update signals
    wire                                    pipe_insert_slc_nofill_sx4;
    wire                                    pipe_insert_slc_fill_sx4;
    wire                                    pipe_insert_slc_sx4;
    wire                                    pipe_update_slc_nofill_sx4;
    wire                                    pipe_update_slc_fill_sx4;
    wire                                    pipe_update_slc_sx4;
    wire                                    pipe_invalid_slc_nofill_sx4;
    wire                                    pipe_invalid_slc_fill_sx4;
    wire                                    pipe_invalid_slc_sx4;
    wire                                    pipe_tag_state_invalid_sx4;
    wire                                    pipe_tag_state_clean_sx4;
    wire                                    pipe_tag_state_dirty_sx4;
    wire                                    pipe_read_slc_nofill_sx4;
    wire                                    pipe_read_slc_fill_sx4;
    wire                                    pipe_read_slc_sx4;
    wire [1:0]                              pipe_tag_state_sx4;
    wire                                    pipe_read_l3_nofill_sx4;
    wire                                    pipe_read_l3_fill_sx4;
    wire                                    pipe_read_l3_sx4;

    /////////////////////////////////////////////////////////////
    // SF Match signals
    /////////////////////////////////////////////////////////////
    // SX4 SF mask
    reg [`RNF_NUM*2-1:0]                    pipe_sf_self_valid_mask_sx4_q;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_self_share_mask_sx4_q;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_self_mask_sx4_q;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_other_valid_mask_sx4_q;
    // SF hit status
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_match_vec_sx4_q;
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_free_vec_sx4_q;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_match_state_sx4_q;
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_other_valid_vec_sx4_q;
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_other_share_vec_sx4_q;
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_self_valid_vec_sx4_q;
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_self_share_vec_sx4_q;
    wire [`RNF_NUM*2-1:0]                   pipe_sf_snp_share_state_sx4;
    wire [`SF_WAY_NUM-1:0]                  pipe_sf_free_way_vec_sx4;
    wire                                    pipe_sf_free_sx4;
    wire                                    pipe_sf_other_match_sx4;
    wire                                    pipe_sf_other_match_share_sx4;
    wire                                    pipe_sf_self_match_sx4;
    wire                                    pipe_sf_self_match_share_sx4;
    wire                                    pipe_sf_clear_valid_sx4;
    wire [`RNF_NUM*2-1:0]                   pipe_sf_all_invalid_sx4;
    wire                                    pipe_sf_self_unique_sx4;
    wire [`RNF_NUM*2-1:0]                   pipe_sf_requester_unique_sx4;
    wire                                    pipe_sf_self_share_sx4;
    wire [`RNF_NUM*2-1:0]                   pipe_sf_requester_share_sx4;
    wire                                    pipe_sf_self_invalid_sx4;
    wire [`RNF_NUM*2-1:0]                   pipe_sf_requester_invalid_sx4;
    wire [`RNF_NUM*2-1:0]                   pipe_sf_insert_state_sx4;
    wire [`RNF_NUM-1:0]                     pipe_sf_evict_tgt_vec_sx4;
    wire [`RNF_NUM-1:0]                     pipe_sf_snp_tgt_vec_sx4;
    wire [`RNF_NUM-1:0]                     pipe_sf_snp_unq_tgt_vec_sx4;
    wire [`RNF_NUM-1:0]                     pipe_sf_tgt_vec_sx4;

    // SF update signals
    wire [`RNF_NUM*2-1:0]                   pipe_sf_update_state_sx4;
    wire                                    pipe_sf_insert_sx4;
    reg [`SF_TAG_WIDTH-1:0]                 pipe_sf_evict_tag_sx4_q;
    reg [`RNF_NUM*2-1:0]                    pipe_sf_evict_state_sx4_q;

    // Random SF evict posistion, left shift per cycle
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_evict_next_sx4_q;

    /////////////////////////////////////////////////////////////
    // LRU match signals
    /////////////////////////////////////////////////////////////
    wire [`LOC_WAY_NUM*2-1:0]               pipe_lru_degrade1_rrpv_sx4;
    wire [`LOC_WAY_NUM*2-1:0]               pipe_lru_degrade2_rrpv_sx4;
    wire [`LOC_WAY_NUM*2-1:0]               pipe_lru_degrade3_rrpv_sx4;
    wire [`LOC_WAY_NUM*2-1:0]               pipe_lru_degrade_rrpv_sx4;
    reg [`LOC_WAY_NUM*2-1:0]                pipe_lru_replace_entry_mask_sx4;
    reg [`LOC_WAY_NUM*2-1:0]                pipe_lru_replace_entry_rrpv_sx4;
    wire [`LOC_WAY_NUM*2-1:0]               pipe_lru_replace_rrpv_sx4;
    reg [`LOC_WAY_NUM*2-1:0]                pipe_lru_free_entry_mask_sx4;
    reg [`LOC_WAY_NUM*2-1:0]                pipe_lru_free_entry_rrpv_sx4;
    wire [`LOC_WAY_NUM*2-1:0]               pipe_lru_free_rrpv_sx4;
    reg [`LOC_WAY_NUM*2-1:0]                pipe_lru_promote_mask_sx4;
    wire [`LOC_WAY_NUM*2-1:0]               pipe_lru_promote_rrpv_sx4;
    wire [`LOC_WAY_NUM*2-1:0]               pipe_lru_next_rrpv_sx4;
    reg [`LOC_WAY_NUM-1:0]                  pipe_lru_alloc_vec_sx4_q;
    reg                                     pipe_lru_near_immediate_found_sx4_q;
    reg                                     pipe_lru_long_found_sx4_q;
    reg                                     pipe_lru_distance_found_sx4_q;

    /////////////////////////////////////////////////////////////
    // Stage SX4 State Machine result
    /////////////////////////////////////////////////////////////
    wire                                    pipe_data_rd_sx4;
    wire                                    pipe_data_wr_sx4;
    wire                                    pipe_tag_wr_sx4;
    wire                                    pipe_sf_wr_sx4;
    wire                                    pipe_sf_evict_sx4;
    wire [`SF_WAY_NUM-1:0]                  pipe_sf_wr_way_sx4;
    wire [`RNF_NUM*2-1:0]                   pipe_sf_wr_state_sx4;
    wire [ADDR_WIDTH-1:0]                   pipe_sf_evict_addr_sx4;
    wire                                    pipe_lru_wr_sx4;
    wire                                    pipe_mem_rd_sx4;

    //===========================================================
    /////////////////////////////////////////////////////////////
    // Stage SX5 signals
    /////////////////////////////////////////////////////////////
    //===========================================================
    wire [`LOC_INDEX_WIDTH-1:0]             l3_index_sx4;
    wire [`LOC_WAY_NUM-1:0]                 l3_rd_ways_sx4;
    wire [`LOC_WAY_NUM-1:0]                 l3_wr_ways_sx4;
    reg                                     pipe_data_rd_sx5_q;
    reg                                     pipe_data_wr_sx5_q;
    reg                                     pipe_tag_wr_sx5_q;
    reg                                     pipe_sf_wr_sx5_q;
    reg                                     pipe_lru_wr_sx5_q;
    wire                                    pipe_tag_wr_sx5;

    // SLC evict
    reg [ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET]  pipe_tag_evict_addr_sx5_q;
    reg                                     pipe_tag_dirty_sx5_q;
    reg                                     pipe_tag_evict_sx5_q;
    // SLC hit
    reg                                     pipe_tag_hit_sx5_q;
    // SLC new state
    reg [1:0]                               pipe_tag_wr_state_sx5_q;
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_wr_way_sx5_q;
    // SF evict
    reg                                     pipe_sf_evict_sx5_q;
    reg [ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET]  pipe_sf_evict_addr_sx5_q;
    // SF hit vec for snp
    reg                                     pipe_sf_other_hit_sx5_q;
    reg                                     pipe_sf_hit_sx5_q;
    reg [`RNF_NUM-1:0]                      pipe_sf_tgt_vec_sx5_q;
    wire                                    pipe_biq_hit_cancel_brd_sx5;
    reg [`RNF_NUM-1:0]                      pipe_biq_hit_tgt_vec_sx5_q;
    wire [`RNF_NUM-1:0]                     pipe_biq_hit_tgt_vec_sx5;
    // SF new state
    reg [`SF_CLINE_WIDTH-1:0]               pipe_sf_wr_state_sx5_q;
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_wr_way_sx5_q;
    // LRU new state
    reg [`LOC_WAY_NUM*2-1:0]                pipe_lru_wr_rrpv_sx5_q;
    // if need read SF
    reg                                     pipe_mem_rd_sx5_q;
    reg                                     pipe_wrap_wr_sx5_q;
    //Stage SX6 signals

    //FIXME: hazard should record tag/SF index other than bitmap
    reg [CPL_HZD_ENTRY-1:0]                 pipe_tag_hazard_valid_sx6_q;
    reg [`LOC_INDEX_WIDTH-1:0]              pipe_tag_hazard_index_sx6_q[CPL_HZD_ENTRY-1:0];
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_hazard_way_sx6_q[CPL_HZD_ENTRY-1:0];
    wire [`LOC_INDEX_WIDTH-1:0]             pipe_tag_index_sx5;
    wire [`LOC_WAY_NUM-1:0]                 pipe_tag_way_sx5;
    wire [CPL_HZD_ENTRY-1:0]                pipe_tag_hazard_match_vec_sx5;
    reg                                     pipe_tag_hazard_valid_sx5_q;
    reg [CPL_HZD_ENTRY-1:0]                 pipe_tag_hazard_alloc_sx5;
    reg [CPL_HZD_ENTRY-1:0]                 pipe_tag_hazard_alloc_vector;
    wire [CPL_HZD_ENTRY-1:0]                pipe_tag_hazard_set_sx5;
    wire [CPL_HZD_ENTRY-1:0]                pipe_tag_hazard_clr_sx5;
    wire [CPL_HZD_ENTRY-1:0]                pipe_tag_hazard_ns_sx5;
    reg [CPL_HZD_ENTRY-1:0]                 pipe_tag_hazard_timer_sx5_q[CPL_HZD_ENTRY-1:0];
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_haz_way_sx5_q;
    reg [CPL_HZD_ENTRY-1:0]                 pipe_sf_hazard_valid_sx6_q;
    reg [`SF_INDEX_WIDTH-1:0]               pipe_sf_hazard_index_sx6_q[CPL_HZD_ENTRY-1:0];
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_hazard_way_sx6_q[CPL_HZD_ENTRY-1:0];
    wire [`SF_INDEX_WIDTH-1:0]              pipe_sf_index_sx5;
    wire [`SF_WAY_NUM-1:0]                  pipe_sf_way_sx5;
    wire [CPL_HZD_ENTRY-1:0]                pipe_sf_hazard_match_vec_sx5;
    reg                                     pipe_sf_hazard_valid_sx5_q;
    reg [CPL_HZD_ENTRY-1:0]                 pipe_sf_hazard_alloc_sx5;
    reg [CPL_HZD_ENTRY-1:0]                 pipe_sf_hazard_alloc_vector;
    wire [CPL_HZD_ENTRY-1:0]                pipe_sf_hazard_set_sx5;
    wire [CPL_HZD_ENTRY-1:0]                pipe_sf_hazard_clr_sx5;
    wire [CPL_HZD_ENTRY-1:0]                pipe_sf_hazard_ns_sx5;
    reg [CPL_HZD_ENTRY-1:0]                 pipe_sf_hazard_timer_sx5_q[CPL_HZD_ENTRY-1:0];
    wire                                    pipe_hazard_fail_sx5;
    reg                                     pipe_data_wr_sx6_q;
    reg                                     pipe_tag_wr_sx6_q;
    reg                                     pipe_sf_wr_sx6_q;
    reg                                     pipe_lru_wr_sx6_q;
    reg [1:0]                               pipe_tag_wr_state_sx6_q;
    reg [`LOC_WAY_NUM-1:0]                  pipe_tag_wr_way_sx6_q;
    // SF new state
    reg [`SF_CLINE_WIDTH-1:0]               pipe_sf_wr_state_sx6_q;
    reg [`SF_WAY_NUM-1:0]                   pipe_sf_wr_way_sx6_q;
    // LRU new state
    reg [`LOC_WAY_NUM*2-1:0]                pipe_lru_wr_rrpv_sx6_q;
    // if need read SF
    wire                                    cpl_internal_wr_sx5;

    wire                                    l3_replay_sx5;
    // Stage SX7 signals
    wire [ADDR_WIDTH-1:0]                   pipe_addr_sx6;

    reg                                     cpl_internal_wr_sx6_q;
    reg [`RNF_WIDTH-1:0]                    pipe_sf_hit_count_sx5;

    // BIQ signals
    reg [ADDR_WIDTH-1:0]                    biq_evict_addr_sx5_q;
    wire                                    biq_evict_retry_sx5;
    wire                                    biq_fifo_empty;
    wire                                    biq_fifo_full;
    wire                                    biq_hit_raw;
    wire                                    biq_hit;
    wire                                    biq_evict_valid_sx5;
    wire                                    biq_find_valid_sx5;

    wire [`SF_CLINE_WIDTH-1:0]              sf_rd_clines[`SF_WAY_NUM-1:0];


    //=============================================================================
    // SX1 Stage: Arb MSHR request and CPL wrap Write
    //=============================================================================

    assign pipe_req_bypass_sx1     = ~cpl_internal_wr_sx6_q & mshr_l3_req_en_sx1_q;
    assign pipe_mshr_req_valid_sx1 = pipe_req_bypass_sx1;
    assign pipe_req_valid_sx[SX1]  = pipe_mshr_req_valid_sx1;
    assign pipe_opcode_sx1         = pipe_req_bypass_sx1 ? mshr_l3_opcode_sx1_q     : {OPCODE_WIDTH{1'b0}};
    assign pipe_addr_sx1           = pipe_req_bypass_sx1 ? mshr_l3_addr_sx1         : {ADDR_WIDTH{1'b0}};
    assign pipe_mshr_idx_sx1       = pipe_req_bypass_sx1 ? mshr_l3_entry_idx_sx1_q  : {`MSHR_ENTRIES_WIDTH{1'b0}};
    assign pipe_rnf_idx_sx1        = pipe_req_bypass_sx1 ? mshr_l3_rnf_sx1_q        : {NID_WIDTH{1'b0}};
    assign pipe_fill_sx1           = pipe_req_bypass_sx1 ? mshr_l3_fill_sx1_q       : 1'b0;
    assign pipe_fill_dirty_sx1     = pipe_req_bypass_sx1 ? mshr_l3_fill_dirty_sx1_q : 1'b0;

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_req_valid_sx_q[SX2] <= 1'b0;
            pipe_req_valid_sx_q[SX1] <= 1'b0;
        end
        else begin
            pipe_req_valid_sx_q[SX2] <= pipe_req_valid_sx[SX1];
        end
    end

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_opcode_sx_q[SX2]     <= {OPCODE_WIDTH{1'b0}};
            pipe_addr_sx_q[SX2]       <= {ADDR_WIDTH{1'b0}};
            pipe_rnf_idx_sx_q[SX2]    <= {NID_WIDTH{1'b0}};
            pipe_mshr_idx_sx_q[SX2]   <= {`MSHR_ENTRIES_WIDTH{1'b0}};
            pipe_fill_sx_q[SX2]       <= 1'b0;
            pipe_fill_dirty_sx_q[SX2] <= 1'b0;
        end
        else if (cpl_internal_wr_sx6_q)begin
            pipe_opcode_sx_q[SX2]     <= pipe_opcode_sx_q[SX6];
            pipe_addr_sx_q[SX2]       <= pipe_addr_sx_q[SX6];
            pipe_rnf_idx_sx_q[SX2]    <= pipe_rnf_idx_sx_q[SX6];
            pipe_mshr_idx_sx_q[SX2]   <= pipe_mshr_idx_sx_q[SX6];
            pipe_fill_sx_q[SX2]       <= pipe_fill_sx_q[SX6];
            pipe_fill_dirty_sx_q[SX2] <= pipe_fill_dirty_sx_q[SX6];
        end
        else if (pipe_mshr_req_valid_sx1)begin
            pipe_opcode_sx_q[SX2]     <= pipe_opcode_sx1;
            pipe_addr_sx_q[SX2]       <= pipe_addr_sx1;
            pipe_rnf_idx_sx_q[SX2]    <= pipe_rnf_idx_sx1;
            pipe_mshr_idx_sx_q[SX2]   <= pipe_mshr_idx_sx1;
            pipe_fill_sx_q[SX2]       <= pipe_fill_sx1;
            pipe_fill_dirty_sx_q[SX2] <= pipe_fill_dirty_sx1;
        end
        else begin
            pipe_opcode_sx_q[SX2]     <= {OPCODE_WIDTH{1'b0}};
            pipe_addr_sx_q[SX2]       <= {ADDR_WIDTH{1'b0}};
            pipe_rnf_idx_sx_q[SX2]    <= {NID_WIDTH{1'b0}};
            pipe_mshr_idx_sx_q[SX2]   <= {`MSHR_ENTRIES_WIDTH{1'b0}};
            pipe_fill_sx_q[SX2]       <= 1'b0;
            pipe_fill_dirty_sx_q[SX2] <= 1'b0;
        end
    end

    assign pipe_tag_rd_sx1 = pipe_mshr_req_valid_sx1;
    assign pipe_tag_wr_sx1 = (cpl_internal_wr_sx6_q & pipe_tag_wr_sx6_q);

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            loc_index_q    <= {`LOC_INDEX_WIDTH{1'b0}};
            loc_rd_en_q    <= 1'b0;
            loc_wr_ways_q  <= {`LOC_WAY_NUM{1'b0}};
            loc_wr_cline_q <= {`LOC_CLINE_WIDTH{1'b0}};
        end
        else if (pipe_tag_rd_sx1 == 1'b1)begin
            loc_index_q    <= pipe_addr_sx1[`LOC_INDEX_RANGE];
            loc_rd_en_q    <= 1'b1;
            loc_wr_ways_q  <= {`LOC_WAY_NUM{1'b0}};
            loc_wr_cline_q <= {`LOC_CLINE_WIDTH{1'b0}};
        end
        else if (pipe_tag_wr_sx1 == 1'b1)begin
            loc_index_q    <= pipe_addr_sx6[`LOC_INDEX_RANGE];
            loc_rd_en_q    <= 1'b0;
            loc_wr_ways_q  <= pipe_tag_wr_way_sx6_q[`LOC_WAY_NUM-1:0];
            loc_wr_cline_q <= {pipe_addr_sx6[`LOC_TAG_RANGE],pipe_tag_wr_state_sx6_q[1:0]};
        end
        else begin
            loc_index_q    <= {`LOC_INDEX_WIDTH{1'b0}};
            loc_rd_en_q    <= 1'b0;
            loc_wr_ways_q  <= {`LOC_WAY_NUM{1'b0}};
            loc_wr_cline_q <= {`LOC_CLINE_WIDTH{1'b0}};
        end
    end

    // Read/Write SF
    assign pipe_sf_rd_sx1 = pipe_mshr_req_valid_sx1;
    assign pipe_sf_wr_sx1 = cpl_internal_wr_sx6_q & pipe_sf_wr_sx6_q;

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            sf_index_q    <= {`SF_INDEX_WIDTH{1'b0}};
            sf_rd_en_q    <= 1'b0;
            sf_wr_ways_q  <= {`SF_WAY_NUM{1'b0}};
            sf_wr_cline_q <= {`SF_CLINE_WIDTH{1'b0}};
        end
        else if (pipe_sf_rd_sx1 == 1'b1)begin
            sf_index_q    <= pipe_addr_sx1[`SF_INDEX_RANGE];
            sf_rd_en_q    <= 1'b1;
            sf_wr_ways_q  <= {`SF_WAY_NUM{1'b0}};
            sf_wr_cline_q <= {`SF_CLINE_WIDTH{1'b0}};
        end
        else if (pipe_sf_wr_sx1 == 1'b1)begin
            sf_index_q    <= pipe_addr_sx6[`SF_INDEX_RANGE];
            sf_rd_en_q    <= 1'b0;
            sf_wr_ways_q  <= pipe_sf_wr_way_sx6_q[`SF_WAY_NUM-1:0];
            sf_wr_cline_q <= pipe_sf_wr_state_sx6_q[`SF_CLINE_WIDTH-1:0];
        end
        else begin
            sf_index_q    <= {`SF_INDEX_WIDTH{1'b0}};
            sf_rd_en_q    <= 1'b0;
            sf_wr_ways_q  <= {`SF_WAY_NUM{1'b0}};
            sf_wr_cline_q <= {`SF_CLINE_WIDTH{1'b0}};
        end
    end

    // Read/Write LRU
    assign pipe_lru_rd_sx1 = pipe_mshr_req_valid_sx1;
    assign pipe_lru_wr_sx1 = cpl_internal_wr_sx6_q & pipe_lru_wr_sx6_q;
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            lru_index_q   <= {`LOC_INDEX_WIDTH{1'b0}};
            lru_rd_en_q   <= 1'b0;
            lru_wr_en_q   <= 1'b0;
            lru_wr_data_q <= {`LRU_CLINE_WIDTH{1'b0}};
        end
        else if (pipe_lru_rd_sx1 == 1'b1)begin
            lru_index_q   <= pipe_addr_sx1[`LOC_INDEX_RANGE];
            lru_rd_en_q   <= 1'b1;
            lru_wr_en_q   <= 1'b0;
            lru_wr_data_q <= {`LRU_CLINE_WIDTH{1'b0}};
        end
        else if (pipe_lru_wr_sx1 == 1'b1)begin
            lru_index_q   <= pipe_addr_sx6[`LOC_INDEX_RANGE];
            lru_rd_en_q   <= 1'b0;
            lru_wr_en_q   <= 1'b1;
            lru_wr_data_q <= pipe_lru_wr_rrpv_sx6_q[`LRU_CLINE_WIDTH-1:0];
        end
        else begin
            lru_index_q   <= {`LOC_INDEX_WIDTH{1'b0}};
            lru_rd_en_q   <= 1'b0;
            lru_wr_en_q   <= 1'b0;
            lru_wr_data_q <= {`LRU_CLINE_WIDTH{1'b0}};
        end
    end

    // Wrap Write info for Data SRAM
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_wrap_wr_sx2_q    <= 1'b0;
            pipe_data_wr_sx2_q    <= 1'b0;
            pipe_tag_wr_way_sx2_q <= {`LOC_WAY_NUM{1'b0}};
            pipe_addr_wr_sx2_q    <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            pipe_wrap_wr_sx2_q    <= cpl_internal_wr_sx6_q;
            pipe_data_wr_sx2_q    <= cpl_internal_wr_sx6_q & pipe_data_wr_sx6_q;
            pipe_tag_wr_way_sx2_q <= {`LOC_WAY_NUM{cpl_internal_wr_sx6_q}} & pipe_tag_wr_way_sx6_q[`LOC_WAY_NUM-1:0];
            pipe_addr_wr_sx2_q    <= pipe_addr_sx6;
        end
    end
    //=============================================================================
    // Stage SX2
    // 1) Read/Write Tag is available
    // 2) Read/Write LRU is available
    // 3) Read/Write SF is available
    //=============================================================================

    // Read/Write Tag
    assign pipe_req_valid_sx[SX2] = pipe_req_valid_sx_q[SX2];

    generate
        for (gi = SX3; gi < CPL_STAGE; gi = gi + 1)begin
            always @(posedge clk or posedge rst)begin
                if (rst == 1'b1)begin
                    pipe_req_valid_sx_q[gi]  <= 1'b0;
                    pipe_opcode_sx_q[gi]     <= {OPCODE_WIDTH{1'b0}};
                    pipe_addr_sx_q[gi]       <= {ADDR_WIDTH{1'b0}};
                    pipe_rnf_idx_sx_q[gi]    <= {NID_WIDTH{1'b0}};
                    pipe_mshr_idx_sx_q[gi]   <= {`MSHR_ENTRIES_WIDTH{1'b0}};
                    pipe_fill_sx_q[gi]       <= 1'b0;
                    pipe_fill_dirty_sx_q[gi] <= 1'b0;
                end
                else if (pipe_req_valid_sx[gi-1] == 1'b1)begin
                    pipe_req_valid_sx_q[gi]  <= pipe_req_valid_sx[gi-1];
                    pipe_opcode_sx_q[gi]     <= pipe_opcode_sx_q[gi-1][OPCODE_WIDTH-1:0];
                    pipe_addr_sx_q[gi]       <= pipe_addr_sx_q[gi-1][ADDR_WIDTH-1:0];
                    pipe_rnf_idx_sx_q[gi]    <= pipe_rnf_idx_sx_q[gi-1][NID_WIDTH-1:0];
                    pipe_mshr_idx_sx_q[gi]   <= pipe_mshr_idx_sx_q[gi-1][`MSHR_ENTRIES_WIDTH-1:0];
                    pipe_fill_sx_q[gi]       <= pipe_fill_sx_q[gi-1];
                    pipe_fill_dirty_sx_q[gi] <= pipe_fill_dirty_sx_q[gi-1];
                end
                else begin
                    pipe_opcode_sx_q[gi]     <= {OPCODE_WIDTH{1'b0}};
                    pipe_addr_sx_q[gi]       <= {ADDR_WIDTH{1'b0}};
                    pipe_rnf_idx_sx_q[gi]    <= {NID_WIDTH{1'b0}};
                    pipe_mshr_idx_sx_q[gi]   <= {`MSHR_ENTRIES_WIDTH{1'b0}};
                    pipe_fill_sx_q[gi]       <= 1'b0;
                    pipe_fill_dirty_sx_q[gi] <= 1'b0;
                    pipe_req_valid_sx_q[gi]  <= 1'b0;
                end
            end
        end
    endgenerate

    // Wrap Write info for Data SRAM
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_wrap_wr_sx3_q    <= 1'b0;
            pipe_data_wr_sx3_q    <= 1'b0;
            pipe_tag_wr_way_sx3_q <= {`LOC_WAY_NUM{1'b0}};
            pipe_addr_wr_sx3_q    <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            pipe_wrap_wr_sx3_q    <= pipe_wrap_wr_sx2_q;
            pipe_data_wr_sx3_q    <= pipe_data_wr_sx2_q;
            pipe_tag_wr_way_sx3_q <= pipe_tag_wr_way_sx2_q[`LOC_WAY_NUM-1:0];
            pipe_addr_wr_sx3_q    <= pipe_addr_wr_sx2_q;
        end
    end
    //=============================================================================
    // Stage SX3
    //  1) Read TAG/SF/LRU SRAM and match,the comparison results are delayed by one cycle
    //  2) Write TAG/SF/LRU SRAM Done, do nothing
    //  3) Prepare TAG/SF change for SX4, generate SF mask for SX4
    //=============================================================================

    //                  pipe_wrap_wr_sx3_q   pipe_data_wr_sx3_q     SX4 valid
    //  MSHR request            0                   0                   valid
    //  CPL wrap write          1                   1                   valid
    //
    //  Notes:
    //      SX4 is invalid if other cases
    assign pipe_req_valid_sx[SX3] = pipe_req_valid_sx_q[SX3] & ~(pipe_wrap_wr_sx3_q ^ pipe_data_wr_sx3_q);

    always @(*)begin : func_rnfid2physicalid
        integer i;
        pipe_nodeid_list_sx2[`RNF_NUM*NID_WIDTH-1:0]      = RNF_NID_LIST_PARAM;
        pipe_physical_nodeid_sx2[NID_WIDTH-1:0]          = {NID_WIDTH{1'b0}};
        pipe_rnfid_found_sx2                             = 0;
        for (i = 0; i < `RNF_NUM; i = i+1) begin
            pipe_current_nodeid_sx2[NID_WIDTH-1:0] = pipe_nodeid_list_sx2[NID_WIDTH*i +: NID_WIDTH];
            if (pipe_current_nodeid_sx2[NID_WIDTH-1:0] == pipe_rnf_idx_sx_q[SX2][NID_WIDTH-1:0]) begin
                pipe_physical_nodeid_sx2[NID_WIDTH-1:0] = i;
                pipe_rnfid_found_sx2                    = 1;
            end
        end
    end

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_sf_other_valid_mask_sx3_q[`RNF_NUM*2-1:0] <= 0;
            pipe_sf_other_share_mask_sx3_q[`RNF_NUM*2-1:0] <= 0;
            pipe_sf_self_valid_mask_sx3_q[`RNF_NUM*2-1:0]  <= 0;
            pipe_sf_self_share_mask_sx3_q[`RNF_NUM*2-1:0]  <= 0;
            pipe_sf_self_mask_sx3_q[`RNF_NUM*2-1:0]        <= 0;
        end
        else begin
            pipe_sf_other_valid_mask_sx3_q[`RNF_NUM*2-1:0] <= ~({`RNF_NUM{2'b10}} | (({2{pipe_rnfid_found_sx2}} & 2'b01) << (2*pipe_physical_nodeid_sx2[NID_WIDTH-1:0])));//01010101010101010101010101010100
            pipe_sf_other_share_mask_sx3_q[`RNF_NUM*2-1:0] <= ~({`RNF_NUM{2'b01}} | (({2{pipe_rnfid_found_sx2}} & 2'b10) << (2*pipe_physical_nodeid_sx2[NID_WIDTH-1:0])));//10101010101010101010101010101000
            pipe_sf_self_valid_mask_sx3_q[`RNF_NUM*2-1:0]  <= {`RNF_NUM{2'b00}} | (({2{pipe_rnfid_found_sx2}} & 2'b01) << (2*pipe_physical_nodeid_sx2[NID_WIDTH-1:0]));//00000000000000000000000000000001
            pipe_sf_self_share_mask_sx3_q[`RNF_NUM*2-1:0]  <= {`RNF_NUM{2'b00}} | (({2{pipe_rnfid_found_sx2}} & 2'b10) << (2*pipe_physical_nodeid_sx2[NID_WIDTH-1:0]));//00000000000000000000000000000010
            pipe_sf_self_mask_sx3_q[`RNF_NUM*2-1:0]        <= {`RNF_NUM{2'b00}} | (({2{pipe_rnfid_found_sx2}} & 2'b11) << (2*pipe_physical_nodeid_sx2[NID_WIDTH-1:0]));//00000000000000000000000000000011
        end
    end

    assign pipe_opcode_sx3 = pipe_opcode_sx_q[SX3][OPCODE_WIDTH-1:
            0] & {OPCODE_WIDTH{pipe_req_valid_sx[SX3]}};
    assign op_rdonce_sx3   = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_READONCE);
    assign op_rdnsd_sx3    = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_READNOTSHAREDDIRTY);
    assign op_rdclean_sx3  = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_READCLEAN);
    assign op_rdunique_sx3 = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_READUNIQUE);
    assign op_wufull_sx3   = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_WRITEUNIQUEFULL);
    assign op_wuptl_sx3    = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_WRITEUNIQUEPTL);
    assign op_wbfull_sx3   = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_WRITEBACKFULL);
    assign op_wevict_sx3   = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_WRITEEVICTFULL);
    assign op_dl_cu_sx3    = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_CLEANUNIQUE);
    assign op_dl_mu_sx3    = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_MAKEUNIQUE);
    assign op_dl_evict_sx3 = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_EVICT);
    assign op_cmo_cs_sx3   = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_CLEANSHARED);
    assign op_cmo_ci_sx3   = (pipe_opcode_sx3[OPCODE_WIDTH-1:0] == `CHIE_CLEANINVALID);

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            op_rdonce_sx4_q   <= 1'b0;
            op_rdnsd_sx4_q    <= 1'b0;
            op_rdclean_sx4_q  <= 1'b0;
            op_rdunique_sx4_q <= 1'b0;
            op_wufull_sx4_q   <= 1'b0;
            op_wuptl_sx4_q    <= 1'b0;
            op_wbfull_sx4_q   <= 1'b0;
            op_wevict_sx4_q   <= 1'b0;
            op_dl_cu_sx4_q    <= 1'b0;
            op_dl_mu_sx4_q    <= 1'b0;
            op_dl_evict_sx4_q <= 1'b0;
            op_cmo_cs_sx4_q   <= 1'b0;
            op_cmo_ci_sx4_q   <= 1'b0;
        end
        else begin
            op_rdonce_sx4_q   <= op_rdonce_sx3;
            op_rdnsd_sx4_q    <= op_rdnsd_sx3;
            op_rdclean_sx4_q  <= op_rdclean_sx3;
            op_rdunique_sx4_q <= op_rdunique_sx3;
            op_wufull_sx4_q   <= op_wufull_sx3;
            op_wuptl_sx4_q    <= op_wuptl_sx3;
            op_wbfull_sx4_q   <= op_wbfull_sx3;
            op_wevict_sx4_q   <= op_wevict_sx3;
            op_dl_cu_sx4_q    <= op_dl_cu_sx3;
            op_dl_mu_sx4_q    <= op_dl_mu_sx3;
            op_dl_evict_sx4_q <= op_dl_evict_sx3;
            op_cmo_cs_sx4_q   <= op_cmo_cs_sx3;
            op_cmo_ci_sx4_q   <= op_cmo_ci_sx3;
        end
    end

    // Wrap Write info for Data SRAM
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_wrap_wr_sx4_q    <= 1'b0;
            pipe_data_wr_sx4_q    <= 1'b0;
            pipe_tag_wr_way_sx4_q <= {`LOC_WAY_NUM{1'b0}};
            pipe_addr_wr_sx4_q    <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            pipe_wrap_wr_sx4_q    <= pipe_wrap_wr_sx3_q;
            pipe_data_wr_sx4_q    <= pipe_data_wr_sx3_q;
            pipe_tag_wr_way_sx4_q <= pipe_tag_wr_way_sx3_q[`LOC_WAY_NUM-1:0];
            pipe_addr_wr_sx4_q    <= pipe_addr_wr_sx3_q;
        end
    end

    //=============================================================================
    //  Match TAG\LRU\SF sram
    //=============================================================================
    //TAG match
    assign pipe_addr_sx3          = pipe_addr_sx_q[SX3][ADDR_WIDTH-1:
            0];

    generate
        for (gi = 0;
                gi < `LOC_WAY_NUM;
                gi = gi + 1)begin
            assign pipe_tag_match_vec_sx3[gi]
                   = (pipe_addr_sx3[`LOC_TAG_RANGE] == loc_rd_clines_q[`LOC_TAG_WIDTH+2-1+gi*`LOC_CLINE_WIDTH:2+gi*`LOC_CLINE_WIDTH]) && loc_rd_clines_q[`LOC_TAG_STATE_VALID+gi*`LOC_CLINE_WIDTH];
            assign pipe_tag_dirty_vec_sx3[gi] = ~loc_rd_clines_q[`LOC_TAG_STATE_CLEAN+gi*`LOC_CLINE_WIDTH];
            assign pipe_tag_free_vec_sx3[gi]  = ~loc_rd_clines_q[`LOC_TAG_STATE_VALID+gi*`LOC_CLINE_WIDTH];
        end
    endgenerate

    //Tag is invalid
    assign pipe_tag_free_sx3        = |pipe_tag_free_vec_sx3[`LOC_WAY_NUM-1:
            0];
    //Tag is clean or dirty
    assign pipe_tag_match_sx3       = |pipe_tag_match_vec_sx3[`LOC_WAY_NUM-1:
            0];
    //Tag is dirty
    assign pipe_tag_match_dirty_sx3 = |(pipe_tag_match_vec_sx3[`LOC_WAY_NUM-1:0] & pipe_tag_dirty_vec_sx3[`LOC_WAY_NUM-1:0]);

    // Need to evict someone for insert new cacheline
    assign pipe_tag_evict_sx3 = ~pipe_tag_match_sx3 & ~pipe_tag_free_sx3 & pipe_fill_sx_q[SX3];
    assign pipe_tag_evict_way_sx3[`LOC_WAY_NUM-1:
                                  0] = pipe_lru_alloc_vec_sx3[`LOC_WAY_NUM-1:
                                                              0];

    //Evict tag
    always @*begin
        pipe_tag_evict_tag_sx3[`LOC_TAG_WIDTH-1:0] = {`LOC_TAG_WIDTH{1'b0}};
        for (ii = 0; ii < `LOC_WAY_NUM; ii = ii + 1)
            pipe_tag_evict_tag_sx3[`LOC_TAG_WIDTH-1:0] = pipe_tag_evict_tag_sx3[`LOC_TAG_WIDTH-1:0] | ({`LOC_TAG_WIDTH{pipe_tag_evict_way_sx3[ii]}} & loc_rd_clines_q[(2+ii*`LOC_CLINE_WIDTH)+:`LOC_TAG_WIDTH]);
    end
    assign pipe_tag_evict_dirty_sx3 = |(pipe_tag_dirty_vec_sx3[`LOC_WAY_NUM-1:0] & pipe_tag_evict_way_sx3[`LOC_WAY_NUM-1:0]);

    //SF match
    generate
        for (gi = 0;
                gi < `SF_WAY_NUM;
                gi = gi + 1)begin
            assign pipe_sf_match_vec_sx3[gi]
                   = (pipe_addr_sx3[`SF_TAG_RANGE] == sf_rd_clines_q[`SF_CLINE_WIDTH-1+gi*`SF_CLINE_WIDTH:`RNF_NUM*2+gi*`SF_CLINE_WIDTH]) & (|sf_rd_clines_q[`RNF_NUM*2-1+gi*`SF_CLINE_WIDTH:gi*`SF_CLINE_WIDTH]);
            assign pipe_sf_free_vec_sx3[gi]  = &(~sf_rd_clines_q[`RNF_NUM*2-1+gi*`SF_CLINE_WIDTH:gi*`SF_CLINE_WIDTH]);

            assign pipe_sf_other_valid_vec_sx3[gi] = |(sf_rd_clines_q[`RNF_NUM*2-1+gi*`SF_CLINE_WIDTH:gi*`SF_CLINE_WIDTH] & pipe_sf_other_valid_mask_sx3_q[`RNF_NUM*2-1:0]);
            assign pipe_sf_other_share_vec_sx3[gi] = |(sf_rd_clines_q[`RNF_NUM*2-1+gi*`SF_CLINE_WIDTH:gi*`SF_CLINE_WIDTH] & pipe_sf_other_share_mask_sx3_q[`RNF_NUM*2-1:0]);

            assign pipe_sf_self_valid_vec_sx3[gi] = |(sf_rd_clines_q[`RNF_NUM*2-1+gi*`SF_CLINE_WIDTH:gi*`SF_CLINE_WIDTH] & pipe_sf_self_valid_mask_sx3_q[`RNF_NUM*2-1:0]);
            assign pipe_sf_self_share_vec_sx3[gi] = |(sf_rd_clines_q[`RNF_NUM*2-1+gi*`SF_CLINE_WIDTH:gi*`SF_CLINE_WIDTH] & pipe_sf_self_share_mask_sx3_q[`RNF_NUM*2-1:0]);

            assign sf_rd_clines[gi] = sf_rd_clines_q[gi*`SF_CLINE_WIDTH +: `SF_CLINE_WIDTH];

        end
    endgenerate

    always @*begin
        pipe_sf_match_state_sx3[`RNF_NUM*2-1:0] = {(`RNF_NUM * 2) {1'b0}};
        for (ii = 0; ii < `SF_WAY_NUM; ii = ii + 1)begin
            pipe_sf_match_state_sx3[`RNF_NUM*2-1:0] = pipe_sf_match_state_sx3[`RNF_NUM*2-1:0] | ({(`RNF_NUM*2){pipe_sf_match_vec_sx3[ii]}} & sf_rd_clines[ii][`RNF_NUM*2-1:0]);
        end
    end

    // One-Hot vector for random evict SF entry
    generate
        if(`SF_WAY_NUM == 1) begin:sf_one_way
            always @(posedge clk or posedge rst)begin
                if (rst)begin
                    pipe_sf_evict_next_sx3_q[`SF_WAY_NUM-1:0] <= 1'b1;
                end
                else begin
                    pipe_sf_evict_next_sx3_q[`SF_WAY_NUM-1:0] <= 1'b1;
                end
            end
        end
        else begin:sf_more_than_one_way
            always @(posedge clk or posedge rst)begin
                if (rst)begin
                    pipe_sf_evict_next_sx3_q[`SF_WAY_NUM-1:0] <= {{(`SF_WAY_NUM - 1) {1'b0}}, 1'b1};
                end
                else begin
                    pipe_sf_evict_next_sx3_q[`SF_WAY_NUM-1:0] <= {
                                                pipe_sf_evict_next_sx3_q[`SF_WAY_NUM-2:0], pipe_sf_evict_next_sx3_q[`SF_WAY_NUM-1]
                                            };
                end
            end
        end
    endgenerate


    always @*begin
        pipe_sf_evict_tag_sx3[`SF_TAG_WIDTH-1:0] = {`SF_TAG_WIDTH{1'b0}};
        pipe_sf_evict_state_sx3[`RNF_NUM*2-1:0] = {(`RNF_NUM*2){1'b0}};
        for (ii = 0; ii < `SF_WAY_NUM; ii = ii + 1)begin
            pipe_sf_evict_tag_sx3[`SF_TAG_WIDTH-1:0] = pipe_sf_evict_tag_sx3[`SF_TAG_WIDTH-1:0] | ({`SF_TAG_WIDTH{pipe_sf_evict_next_sx3_q[ii]}} & sf_rd_clines[ii][`SF_CLINE_WIDTH-1:`RNF_NUM*2]);
            pipe_sf_evict_state_sx3[`RNF_NUM*2-1:0] = pipe_sf_evict_state_sx3[`RNF_NUM*2-1:0] | ({(`RNF_NUM*2){pipe_sf_evict_next_sx3_q[ii]}} & sf_rd_clines[ii][`RNF_NUM*2-1:0]);
        end
    end
    //    end

    assign pipe_sf_other_match_sx3 = |(pipe_sf_other_valid_vec_sx3[`SF_WAY_NUM-1:0] & pipe_sf_match_vec_sx3[`SF_WAY_NUM-1:0]);

    assign pipe_mem_rd_sx3 = ~pipe_fill_sx_q[SX3] & (op_rdonce_sx3 | op_rdnsd_sx3 | op_rdclean_sx3 | op_rdunique_sx3 | op_wuptl_sx3) & ~pipe_tag_match_sx3 & ~pipe_sf_other_match_sx3;

    //LRU match
    generate
        for (gi = 0;
                gi < `LOC_WAY_NUM;
                gi = gi + 1)begin
            assign pipe_lru_immediate_rrpv_vec_sx3[gi]
                   = ~|lru_rd_data_q[(gi+1)*2-1:gi*2];
            assign pipe_lru_near_immediate_rrpv_vec_sx3[gi] = (lru_rd_data_q[(gi+1)*2 - 1: gi*2] == 2'b01);
            assign pipe_lru_long_rrpv_vec_sx3[gi]           = (lru_rd_data_q[(gi+1)*2-1:gi*2] == 2'b10);
            assign pipe_lru_distance_rrpv_vec_sx3[gi]       = (lru_rd_data_q[(gi+1)*2-1:gi*2] == 2'b11);
        end
    endgenerate

    generate
        if(`LOC_WAY_NUM == 1) begin:loc_one_way
            //  LRU choose way
            hnf_sel_bit_from_vec #(
                                     .ENTRIES_NUM   (`LOC_WAY_NUM)
                                 )
                                 u_lru_immediate_find (
                                     .entry_vec     (pipe_lru_immediate_rrpv_vec_sx3),
                                     .start_entry   (pipe_lru_next_vec_q[`LOC_WAY_NUM-1:0]),
                                     .entry_ptr_sel (pipe_lru_immediate_alloc_vec_sx3),
                                     .found         (pipe_lru_immediate_found_sx3)
                                 );

            hnf_sel_bit_from_vec #(
                                     .ENTRIES_NUM   (`LOC_WAY_NUM)
                                 ) u_lru_near_immediate_find (
                                     .entry_vec     (pipe_lru_near_immediate_rrpv_vec_sx3),
                                     .start_entry   (pipe_lru_next_vec_q[`LOC_WAY_NUM-1:0]),
                                     .entry_ptr_sel (pipe_lru_near_immediate_alloc_vec_sx3),
                                     .found         (pipe_lru_near_immediate_found_sx3)
                                 );

            hnf_sel_bit_from_vec #(
                                     .ENTRIES_NUM   (`LOC_WAY_NUM)
                                 ) u_lru_long_find (
                                     .entry_vec     (pipe_lru_long_rrpv_vec_sx3),
                                     .start_entry   (pipe_lru_next_vec_q[`LOC_WAY_NUM-1:0]),
                                     .entry_ptr_sel (pipe_lru_long_alloc_vec_sx3),
                                     .found         (pipe_lru_long_found_sx3)
                                 );

            hnf_sel_bit_from_vec #(
                                     .ENTRIES_NUM   (`LOC_WAY_NUM)
                                 ) u_lru_distance_find (
                                     .entry_vec     (pipe_lru_distance_rrpv_vec_sx3),
                                     .start_entry   (pipe_lru_next_vec_q[`LOC_WAY_NUM-1:0]),
                                     .entry_ptr_sel (pipe_lru_distance_alloc_vec_sx3),
                                     .found         (pipe_lru_distance_found_sx3)
                                 );
        end
        else begin:loc_more_than_one_way
            //  LRU choose way
            hnf_sel_bit_from_vec #(
                                     .ENTRIES_NUM   (`LOC_WAY_NUM)
                                 ) u_lru_immediate_find (
                                     .entry_vec     (pipe_lru_immediate_rrpv_vec_sx3),
                                     .start_entry   ({pipe_lru_next_vec_q[`LOC_WAY_NUM-2:0],pipe_lru_next_vec_q[`LOC_WAY_NUM-1]}),
                                     .entry_ptr_sel (pipe_lru_immediate_alloc_vec_sx3),
                                     .found         (pipe_lru_immediate_found_sx3)
                                 );

            hnf_sel_bit_from_vec #(
                                     .ENTRIES_NUM   (`LOC_WAY_NUM)
                                 ) u_lru_near_immediate_find (
                                     .entry_vec     (pipe_lru_near_immediate_rrpv_vec_sx3),
                                     .start_entry   ({pipe_lru_next_vec_q[`LOC_WAY_NUM-2:0],pipe_lru_next_vec_q[`LOC_WAY_NUM-1]}),
                                     .entry_ptr_sel (pipe_lru_near_immediate_alloc_vec_sx3),
                                     .found         (pipe_lru_near_immediate_found_sx3)
                                 );

            hnf_sel_bit_from_vec #(
                                     .ENTRIES_NUM   (`LOC_WAY_NUM)
                                 ) u_lru_long_find (
                                     .entry_vec     (pipe_lru_long_rrpv_vec_sx3),
                                     .start_entry   ({pipe_lru_next_vec_q[`LOC_WAY_NUM-2:0],pipe_lru_next_vec_q[`LOC_WAY_NUM-1]}),
                                     .entry_ptr_sel (pipe_lru_long_alloc_vec_sx3),
                                     .found         (pipe_lru_long_found_sx3)
                                 );

            hnf_sel_bit_from_vec #(
                                     .ENTRIES_NUM   (`LOC_WAY_NUM)
                                 ) u_lru_distance_find (
                                     .entry_vec     (pipe_lru_distance_rrpv_vec_sx3),
                                     .start_entry   ({pipe_lru_next_vec_q[`LOC_WAY_NUM-2:0],pipe_lru_next_vec_q[`LOC_WAY_NUM-1]}),
                                     .entry_ptr_sel (pipe_lru_distance_alloc_vec_sx3),
                                     .found         (pipe_lru_distance_found_sx3)
                                 );
        end
    endgenerate

    always @(posedge clk or posedge rst)begin
        if (rst)
            pipe_lru_next_vec_q <= {1'b1,{(`LOC_WAY_NUM - 1) {1'b0}}};
        else if (pipe_tag_evict_sx3)
            pipe_lru_next_vec_q[`LOC_WAY_NUM-1:0] <= pipe_lru_alloc_vec_sx3[`LOC_WAY_NUM-1:0];
        else begin
            pipe_lru_next_vec_q[`LOC_WAY_NUM-1:0] <= pipe_lru_next_vec_q[`LOC_WAY_NUM-1:0];
        end
    end

    // Replace Priority: distance > long > near immediate > immediate
    assign pipe_lru_alloc_vec_sx3[`LOC_WAY_NUM-1:
                                  0] =
           pipe_lru_distance_found_sx3 ? pipe_lru_distance_alloc_vec_sx3[`LOC_WAY_NUM-1:0]:
           (pipe_lru_long_found_sx3 ? pipe_lru_long_alloc_vec_sx3[`LOC_WAY_NUM-1:0]:
            (pipe_lru_near_immediate_found_sx3 ? pipe_lru_near_immediate_alloc_vec_sx3[`LOC_WAY_NUM-1:0]:
             pipe_lru_immediate_alloc_vec_sx3[`LOC_WAY_NUM-1:0]));

    //Compare results delay one cycle
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_tag_match_vec_sx4_q                      <='d0;
            pipe_tag_free_vec_sx4_q                       <='d0;
            pipe_tag_free_sx4_q                           <='d0;
            pipe_tag_match_sx4_q                          <='d0;
            pipe_tag_match_dirty_sx4_q                    <='d0;
            pipe_tag_evict_dirty_sx4_q                    <='d0;
            pipe_tag_evict_sx4_q                          <='d0;
            pipe_tag_evict_way_sx4_q                      <='d0;
            pipe_tag_evict_tag_sx4_q                      <='d0;
            pipe_sf_match_vec_sx4_q                       <='d0;
            pipe_sf_free_vec_sx4_q                        <='d0;
            pipe_sf_other_valid_vec_sx4_q                 <='d0;
            pipe_sf_other_share_vec_sx4_q                 <='d0;
            pipe_sf_self_valid_vec_sx4_q                  <='d0;
            pipe_sf_self_share_vec_sx4_q                  <='d0;
            pipe_sf_match_state_sx4_q                     <='d0;
            pipe_sf_self_valid_mask_sx4_q                 <='d0;
            pipe_sf_self_share_mask_sx4_q                 <='d0;
            pipe_sf_self_mask_sx4_q                       <='d0;
            pipe_sf_other_valid_mask_sx4_q                <='d0;
            pipe_sf_evict_next_sx4_q                      <='d0;
            pipe_sf_evict_tag_sx4_q                       <='d0;
            pipe_sf_evict_state_sx4_q                     <='d0;
            pipe_lru_near_immediate_found_sx4_q           <='d0;
            pipe_lru_long_found_sx4_q                     <='d0;
            pipe_lru_distance_found_sx4_q                 <='d0;
            pipe_lru_alloc_vec_sx4_q                      <='d0;
        end
        else if (pipe_req_valid_sx[SX3])begin
            pipe_tag_match_vec_sx4_q                      <=pipe_tag_match_vec_sx3                          ;
            pipe_tag_free_vec_sx4_q                       <=pipe_tag_free_vec_sx3                           ;
            pipe_tag_free_sx4_q                           <=pipe_tag_free_sx3                               ;
            pipe_tag_match_sx4_q                          <=pipe_tag_match_sx3                              ;
            pipe_tag_match_dirty_sx4_q                    <=pipe_tag_match_dirty_sx3                        ;
            pipe_tag_evict_dirty_sx4_q                    <=pipe_tag_evict_dirty_sx3                        ;
            pipe_tag_evict_sx4_q                          <=pipe_tag_evict_sx3                              ;
            pipe_tag_evict_way_sx4_q                      <=pipe_tag_evict_way_sx3                          ;
            pipe_tag_evict_tag_sx4_q                      <=pipe_tag_evict_tag_sx3                          ;
            pipe_sf_match_vec_sx4_q                       <=pipe_sf_match_vec_sx3                           ;
            pipe_sf_free_vec_sx4_q                        <=pipe_sf_free_vec_sx3                            ;
            pipe_sf_other_valid_vec_sx4_q                 <=pipe_sf_other_valid_vec_sx3                     ;
            pipe_sf_other_share_vec_sx4_q                 <=pipe_sf_other_share_vec_sx3                     ;
            pipe_sf_self_valid_vec_sx4_q                  <=pipe_sf_self_valid_vec_sx3                      ;
            pipe_sf_self_share_vec_sx4_q                  <=pipe_sf_self_share_vec_sx3                      ;
            pipe_sf_match_state_sx4_q                     <=pipe_sf_match_state_sx3                         ;
            pipe_sf_self_valid_mask_sx4_q                 <=pipe_sf_self_valid_mask_sx3_q[`RNF_NUM*2-1:0]   ;
            pipe_sf_self_share_mask_sx4_q                 <=pipe_sf_self_share_mask_sx3_q[`RNF_NUM*2-1:0]   ;
            pipe_sf_self_mask_sx4_q                       <=pipe_sf_self_mask_sx3_q[`RNF_NUM*2-1:0]         ;
            pipe_sf_other_valid_mask_sx4_q                <=pipe_sf_other_valid_mask_sx3_q[`RNF_NUM*2-1:0]  ;
            pipe_sf_evict_next_sx4_q                      <=pipe_sf_evict_next_sx3_q                        ;
            pipe_sf_evict_tag_sx4_q                       <=pipe_sf_evict_tag_sx3                           ;
            pipe_sf_evict_state_sx4_q                     <=pipe_sf_evict_state_sx3                         ;
            pipe_lru_near_immediate_found_sx4_q           <=pipe_lru_near_immediate_found_sx3               ;
            pipe_lru_long_found_sx4_q                     <=pipe_lru_long_found_sx3                         ;
            pipe_lru_distance_found_sx4_q                 <=pipe_lru_distance_found_sx3                     ;
            pipe_lru_alloc_vec_sx4_q                      <=pipe_lru_alloc_vec_sx3                          ;
        end
        else begin
            pipe_tag_match_vec_sx4_q                      <='d0;
            pipe_tag_free_vec_sx4_q                       <='d0;
            pipe_tag_free_sx4_q                           <='d0;
            pipe_tag_match_sx4_q                          <='d0;
            pipe_tag_match_dirty_sx4_q                    <='d0;
            pipe_tag_evict_dirty_sx4_q                    <='d0;
            pipe_tag_evict_sx4_q                          <='d0;
            pipe_tag_evict_way_sx4_q                      <='d0;
            pipe_tag_evict_tag_sx4_q                      <='d0;
            pipe_sf_match_vec_sx4_q                       <='d0;
            pipe_sf_free_vec_sx4_q                        <='d0;
            pipe_sf_other_valid_vec_sx4_q                 <='d0;
            pipe_sf_other_share_vec_sx4_q                 <='d0;
            pipe_sf_self_valid_vec_sx4_q                  <='d0;
            pipe_sf_self_share_vec_sx4_q                  <='d0;
            pipe_sf_match_state_sx4_q                     <='d0;
            pipe_sf_self_valid_mask_sx4_q                 <='d0;
            pipe_sf_self_share_mask_sx4_q                 <='d0;
            pipe_sf_self_mask_sx4_q                       <='d0;
            pipe_sf_other_valid_mask_sx4_q                <='d0;
            pipe_sf_evict_next_sx4_q                      <=pipe_sf_evict_next_sx3_q;
            pipe_sf_evict_tag_sx4_q                       <='d0;
            pipe_sf_evict_state_sx4_q                     <='d0;
            pipe_lru_near_immediate_found_sx4_q           <='d0;
            pipe_lru_long_found_sx4_q                     <='d0;
            pipe_lru_distance_found_sx4_q                 <='d0;
            pipe_lru_alloc_vec_sx4_q                      <='d0;
        end
    end

    //LRU data delay one cycle

    always @(posedge clk or posedge rst)begin
        if(rst == 1'b1)begin
            lru_rd_data_d_q <='d0;
        end
        else begin
            lru_rd_data_d_q <=lru_rd_data_q;
        end
    end

    //=============================================================================
    // Stage SX4
    //  1) Read TAG/SF/LRU done, check hit status
    //  2) compliate State Machine cooperating with MSHR
    //  3) CPL wrap write do nothing for preventing data sram competition
    //=============================================================================

    // Tag State
    // bit 0: 1 is Valid, 0 is Invalid
    // bit 1: 1 is Clean, 0 is Dirty

    // legal state:
    //   00: Invalid
    //   11: Clean
    //   01: Dirty
    //   10: none legal

    assign pipe_req_valid_sx[SX4] = pipe_req_valid_sx_q[SX4];
    assign pipe_addr_sx4          = pipe_addr_sx_q[SX4][ADDR_WIDTH-1:
            0];
    assign pipe_fill_sx4          = pipe_fill_sx_q[SX4];

    //====================================================================================
    //# fill and nofill
    //    Read:
    //     1) 1. read miss in slc and sf(nofill).
    //        2. read from SNF
    //        3. data from SNF maybe cached in slc(fill)
    //
    //     2) 1. read miss in slc but hit in sf(nofill)
    //        2. snoop from other RNF
    //        3. data from snoop response maybe cached in slc(fill)
    //
    //    Write:
    //        1. write first inquire slc and sf(nofill)
    //        2. write data response(CBWriteData/NCBWriteData) maybe cached in slc(fill)
    //    DataLess
    //        1. CleanUnique/MakeUnique/Evict only inquire slc and sf one
    //        time(nofill)
    //    CMO:
    //        1. CleanShare/CleanInvalid only inquire slc and sf one time(nofill)
    //
    //====================================================================================

    //====================================================================================
    //                         SLC State Machine
    //====================================================================================

    //invalid tag needs to be inserted
    assign pipe_insert_slc_nofill_sx4 = 1'b0;
    assign pipe_insert_slc_fill_sx4 = ~pipe_tag_match_sx4_q & (op_rdonce_sx4_q | op_rdnsd_sx4_q | op_rdclean_sx4_q | op_wufull_sx4_q | op_wuptl_sx4_q | op_wbfull_sx4_q | op_wevict_sx4_q);
    assign pipe_insert_slc_sx4 = (~pipe_fill_sx4 & pipe_insert_slc_nofill_sx4)|(pipe_fill_sx4 & pipe_insert_slc_fill_sx4);

    //clean or dirty tag needs to be updated
    assign pipe_update_slc_nofill_sx4 = pipe_tag_match_dirty_sx4_q & (op_cmo_cs_sx4_q);
    assign pipe_update_slc_fill_sx4 = 1'b0;//pipe_tag_match_sx4_q & (op_wufull_sx4_q | op_wbfull_sx4_q);
    assign pipe_update_slc_sx4 = (~pipe_fill_sx4 & pipe_update_slc_nofill_sx4)|(pipe_fill_sx4 & pipe_update_slc_fill_sx4);

    //clean or dirty tag needs to be invalidated
    assign pipe_invalid_slc_nofill_sx4 = pipe_tag_match_sx4_q &
           // ReadNoShareDirty/ReadClean hit in SLC but no other RNF has its cache copy, invalid SLC copy
           ((~pipe_sf_other_match_sx4 & (op_rdnsd_sx4_q | op_rdclean_sx4_q)) |
            // ReadUnique will invalid all cache copies including SLC
            op_rdunique_sx4_q |
            // WriteUniqueFull/Ptl will first invalid SLC, NCBWriteData will refill SLC
            op_wufull_sx4_q | op_wuptl_sx4_q |
            // CleanUnique/MakeUnique will invalid all cache copies including SLC
            op_dl_cu_sx4_q | op_dl_mu_sx4_q |
            // CleanInvalid will invalid all cache copies include SLC
            op_cmo_ci_sx4_q
           );
    assign pipe_invalid_slc_fill_sx4 = 1'b0;
    assign pipe_invalid_slc_sx4 = (~pipe_fill_sx4 & pipe_invalid_slc_nofill_sx4)|(pipe_fill_sx4 & pipe_invalid_slc_fill_sx4);

    //tag hits and needs to read
    assign pipe_read_slc_nofill_sx4 = pipe_tag_match_sx4_q & (
               // ReadOnce/ReadNoShareDirty/ReadClean/ReadUnique will get data if SLC hit
               op_rdonce_sx4_q | op_rdnsd_sx4_q | op_rdclean_sx4_q | op_rdunique_sx4_q |
               // WriteUniqePtl read SLC data for further merge data
               op_wuptl_sx4_q | op_dl_cu_sx4_q | op_cmo_ci_sx4_q | op_dl_mu_sx4_q |
               // Dirty Read when CleanUnique/CleanShared
               op_wufull_sx4_q | op_cmo_cs_sx4_q);

    assign pipe_read_slc_fill_sx4 = 1'b0;
    assign pipe_read_slc_sx4 = (~pipe_fill_sx4 & pipe_read_slc_nofill_sx4)|(pipe_fill_sx4 & pipe_read_slc_fill_sx4);

    always @* begin: pipe_tag_alloc_free_way_vector_comb_logic
        integer i;
        pipe_tag_alloc_free_way_vector = {`LOC_WAY_NUM{1'b0}};
        pipe_tag_alloc_free_way_vec_sx4 = {`LOC_WAY_NUM{1'b0}};

        for (i=1; i<`LOC_WAY_NUM; i=i+1)begin
            pipe_tag_alloc_free_way_vector[i] = pipe_tag_alloc_free_way_vector[i-1] | pipe_tag_free_vec_sx4_q[i-1];
        end

        for(i=0; i<`LOC_WAY_NUM; i=i+1)begin
            pipe_tag_alloc_free_way_vec_sx4[i] = ~pipe_tag_alloc_free_way_vector[i] & pipe_tag_free_vec_sx4_q[i];
        end
    end


    assign pipe_tag_wr_way_sx4[`LOC_WAY_NUM-1:
                               0] = (pipe_invalid_slc_sx4 | (~pipe_fill_sx4 & pipe_update_slc_nofill_sx4)) ? pipe_tag_match_vec_sx4_q : pipe_tag_free_sx4_q ? pipe_tag_alloc_free_way_vec_sx4[`LOC_WAY_NUM-1:0] : pipe_tag_evict_way_sx4_q[`LOC_WAY_NUM-1:0];

    assign pipe_tag_haz_way_sx4[`LOC_WAY_NUM-1:
                                0] = pipe_read_slc_sx4 ? pipe_tag_match_vec_sx4_q : (pipe_insert_slc_sx4 & pipe_tag_free_sx4_q) ? pipe_tag_alloc_free_way_vec_sx4[`LOC_WAY_NUM-1:0] : pipe_tag_evict_sx4_q ? pipe_tag_evict_way_sx4_q[`LOC_WAY_NUM-1:0] : {`LOC_WAY_NUM{1'b0}};

    assign pipe_tag_evict_addr_sx4[ADDR_WIDTH-1:
                                   `CACHE_BLOCK_OFFSET] = {
               pipe_tag_evict_tag_sx4_q[`LOC_TAG_WIDTH-1:0],
               pipe_addr_sx4[`LOC_INDEX_RANGE]
           };

    // Tag final State
    assign pipe_tag_state_invalid_sx4 = pipe_invalid_slc_sx4;
    assign pipe_tag_state_clean_sx4 = (pipe_fill_sx4 & ~pipe_fill_dirty_sx_q[SX4]) | op_cmo_cs_sx4_q;
    assign pipe_tag_state_dirty_sx4 = pipe_fill_sx4 & pipe_fill_dirty_sx_q[SX4];
    assign pipe_tag_state_sx4[1:
                              0] = pipe_tag_state_invalid_sx4 ? 2'b00 :
           (pipe_tag_state_dirty_sx4 ? 2'b01: (pipe_tag_state_clean_sx4 ? 2'b11: {~pipe_tag_match_dirty_sx4_q, pipe_tag_match_sx4_q}));


    //====================================================================================
    //                         LRU State Machine
    //====================================================================================
    //    SRRIP replace
    //    RRPV(Re-Reference Prediction Value) 2^M bit prediction re-reference interval (current M is 2):
    //        0: immediate re-reference interval
    //        1: near-immediate re-reference interval
    //        2: long re-reference interval
    //        3: distance re-reference interval
    //    Insert: RRPV 2
    //    Promote hit: RRPV 0
    //    Evict:
    //        1. find RRPV3
    //        2. if 3 found, choose it
    //        2. if none hit, all RRPV increse, replay step 1


    // Replace Priority: distance > long > near immediate > immediate
    generate
        for (gi = 0;
                gi < `LOC_WAY_NUM;
                gi = gi + 1)begin
            assign pipe_lru_degrade1_rrpv_sx4[(gi+1)*2-1:gi*2]
                   = (lru_rd_data_d_q[(gi+1)*2-1:gi*2] + 2'd1);
            assign pipe_lru_degrade2_rrpv_sx4[(gi+1)*2-1:gi*2] = (lru_rd_data_d_q[(gi+1)*2-1:gi*2] + 2'd2);
            assign pipe_lru_degrade3_rrpv_sx4[(gi+1)*2-1:gi*2] = (lru_rd_data_d_q[(gi+1)*2-1:gi*2] + 2'd3);
        end
    endgenerate

    assign pipe_lru_degrade_rrpv_sx4[`LRU_CLINE_WIDTH-1:
                                     0] =
           pipe_lru_distance_found_sx4_q ? lru_rd_data_d_q[`LRU_CLINE_WIDTH-1:0] :
           (pipe_lru_long_found_sx4_q ? pipe_lru_degrade1_rrpv_sx4[`LRU_CLINE_WIDTH-1:0]:
            (pipe_lru_near_immediate_found_sx4_q ? pipe_lru_degrade2_rrpv_sx4[`LRU_CLINE_WIDTH-1:0]:
             pipe_lru_degrade3_rrpv_sx4[`LRU_CLINE_WIDTH-1:0]
            )
           );


    // Generate LRU replace mask
    always @*begin
        for (ii = 0; ii < `LOC_WAY_NUM; ii = ii + 1)begin
            if (pipe_lru_alloc_vec_sx4_q[ii])begin
                pipe_lru_replace_entry_mask_sx4[ii*2+:2] = 2'b00;
                pipe_lru_replace_entry_rrpv_sx4[ii*2+:2] = 2'b10;
            end
            else begin
                pipe_lru_replace_entry_mask_sx4[ii*2+:2] = 2'b11;
                pipe_lru_replace_entry_rrpv_sx4[ii*2+:2] = 2'b00;
            end
        end
    end

    assign pipe_lru_replace_rrpv_sx4[`LRU_CLINE_WIDTH-1:
                                     0] = (pipe_lru_degrade_rrpv_sx4[`LRU_CLINE_WIDTH-1:0] & pipe_lru_replace_entry_mask_sx4[`LRU_CLINE_WIDTH-1:0]) | pipe_lru_replace_entry_rrpv_sx4[`LRU_CLINE_WIDTH-1:
                                             0];

    // When Tag only Read/Update and hit, promote RRPV to 0
    always @*begin
        for (ii = 0; ii < `LOC_WAY_NUM; ii = ii + 1)begin
            if (pipe_tag_match_vec_sx4_q[ii])begin
                pipe_lru_promote_mask_sx4[ii*2+:2] = 2'b00;
            end
            else begin
                pipe_lru_promote_mask_sx4[ii*2+:2] = 2'b11;
            end
        end
    end

    assign pipe_lru_promote_rrpv_sx4[`LRU_CLINE_WIDTH-1:
                                     0] = lru_rd_data_d_q[`LRU_CLINE_WIDTH-1:
                                                          0] & pipe_lru_promote_mask_sx4[`LRU_CLINE_WIDTH-1:
                                                                                         0];

    // When insert and find free entry, only set RRPV to 2
    always @*begin
        for (ii = 0; ii < `LOC_WAY_NUM; ii = ii + 1)begin
            if (pipe_tag_alloc_free_way_vec_sx4[ii])begin
                pipe_lru_free_entry_mask_sx4[ii*2+:2] <= 2'b00;
                pipe_lru_free_entry_rrpv_sx4[ii*2+:2] <= 2'b10;
            end
            else begin
                pipe_lru_free_entry_mask_sx4[ii*2+:2] <= 2'b11;
                pipe_lru_free_entry_rrpv_sx4[ii*2+:2] <= 2'b00;
            end
        end
    end

    assign pipe_lru_free_rrpv_sx4[`LRU_CLINE_WIDTH-1:
                                  0] = (lru_rd_data_d_q[`LRU_CLINE_WIDTH-1:0] & pipe_lru_free_entry_mask_sx4[`LRU_CLINE_WIDTH-1:0]) | pipe_lru_free_entry_rrpv_sx4[`LRU_CLINE_WIDTH-1:
                                          0];
    // Evict Data Sram degrade RRPV, Read Hit promote RRPV
    // if (insert slc) {
    //      if (no free tag)
    //          select entry via LRU, maybe degrade RRPV
    //          update gobal pipe_lru_next_vec_q
    //      update entry RRPV(2)
    // } else {
    //      if (read/update and tag match)
    //          update entry RRPV(0)
    //      if (invalid slc)
    //          do nothing
    // }
    assign pipe_lru_next_rrpv_sx4[`LRU_CLINE_WIDTH-1:
                                  0] = pipe_tag_evict_sx4_q ? pipe_lru_replace_rrpv_sx4[`LRU_CLINE_WIDTH-1:0] :
           ((pipe_insert_slc_sx4 & pipe_tag_free_sx4_q) ? pipe_lru_free_rrpv_sx4[`LRU_CLINE_WIDTH-1:0] : pipe_lru_promote_rrpv_sx4[`LRU_CLINE_WIDTH-1:0]);


    //====================================================================================
    //                         SF State Machine
    //  1) update SF state when hit
    //  2) evict SF when need insert but miss and no free entry
    //  3) return snp tgt vec or evict tgt vec
    //====================================================================================

    // SF State
    // bit 0: 1 is Valid
    // bit 1: 1 is Share, 0 is Unique
    // FIXME: Maybe should advance the work for preventing to be critical path
    assign pipe_sf_free_sx4              = |pipe_sf_free_vec_sx4_q[`SF_WAY_NUM-1:
            0];

    assign pipe_sf_other_match_sx4       = |(pipe_sf_other_valid_vec_sx4_q[`SF_WAY_NUM-1:0] & pipe_sf_match_vec_sx4_q[`SF_WAY_NUM-1:0]);
    assign pipe_sf_other_match_share_sx4 = |(pipe_sf_other_share_vec_sx4_q[`SF_WAY_NUM-1:0] & pipe_sf_match_vec_sx4_q[`SF_WAY_NUM-1:0]);

    assign pipe_sf_self_match_sx4        = |(pipe_sf_self_valid_vec_sx4_q[`SF_WAY_NUM-1:0] & pipe_sf_match_vec_sx4_q[`SF_WAY_NUM-1:0]);
    assign pipe_sf_self_match_share_sx4  = |(pipe_sf_self_share_vec_sx4_q[`SF_WAY_NUM-1:0] & pipe_sf_match_vec_sx4_q[`SF_WAY_NUM-1:0]);

    hnf_sel_bit_from_vec #(
                             .ENTRIES_NUM(`SF_WAY_NUM)
                         ) u_sf_free_entry_find (
                             .entry_vec     (pipe_sf_free_vec_sx4_q[`SF_WAY_NUM-1:0]),
                             .start_entry   ({{(`SF_WAY_NUM-1){1'b0}}, 1'b1}),
                             .entry_ptr_sel (pipe_sf_free_way_vec_sx4[`SF_WAY_NUM-1:0]),
                             .found         ( )
                         );

    // Update hit SF entry state
    //////////////////////////////////////////////////////////////////////////////
    //  1) WriteUnique/WriteBack/WriteEvict/CleanInvalid mark all invalid
    //  2) if request need unique, other must must be Invalid
    //  3) if request need share, other must be share
    //  4) evict only effcet self, degrade to Invalid
    //////////////////////////////////////////////////////////////////////////////

    // Clear is for all RNF
    assign pipe_sf_clear_valid_sx4                       = (op_wufull_sx4_q | op_wuptl_sx4_q | op_cmo_ci_sx4_q);
    assign pipe_sf_all_invalid_sx4[`RNF_NUM*2-1:
                                   0]       = {(`RNF_NUM*2){1'b0}};

    // unique for requester
    assign pipe_sf_self_unique_sx4                       = op_rdunique_sx4_q | op_dl_cu_sx4_q | op_dl_mu_sx4_q | ((op_rdnsd_sx4_q | op_rdclean_sx4_q) & ~pipe_sf_other_match_sx4);
    assign pipe_sf_requester_unique_sx4[`RNF_NUM*2-1:
                                        0]  = pipe_sf_self_valid_mask_sx4_q[`RNF_NUM*2-1:
                                                                            0];

    // share for requester
    assign pipe_sf_self_share_sx4                        = (op_rdnsd_sx4_q | op_rdclean_sx4_q) & pipe_sf_other_match_sx4;
    assign pipe_sf_requester_share_sx4[`RNF_NUM*2-1:
                                       0]   = (pipe_sf_self_share_mask_sx4_q[`RNF_NUM*2-1:0] | pipe_sf_self_valid_mask_sx4_q[`RNF_NUM*2-1:0]);

    // invalid for requester
    assign pipe_sf_self_invalid_sx4                      = op_dl_evict_sx4_q | op_wbfull_sx4_q | op_wevict_sx4_q;
    assign pipe_sf_requester_invalid_sx4[`RNF_NUM*2-1:
                                         0] = ~pipe_sf_self_mask_sx4_q[`RNF_NUM*2-1:
                                                                       0] & pipe_sf_match_state_sx4_q[`RNF_NUM*2-1:
                                                                                                      0];

    assign pipe_sf_update_state_sx4[`RNF_NUM*2-1:
                                    0] = pipe_sf_clear_valid_sx4  ? pipe_sf_all_invalid_sx4[`RNF_NUM*2-1:0]       :
           pipe_sf_self_unique_sx4  ? pipe_sf_requester_unique_sx4[`RNF_NUM*2-1:0]  :
           (pipe_sf_self_share_sx4 & pipe_sf_other_match_share_sx4)  ? (pipe_sf_requester_share_sx4[`RNF_NUM*2-1:0] | pipe_sf_match_state_sx4_q[`RNF_NUM*2-1:0])     :
           (pipe_sf_self_share_sx4 & ~pipe_sf_other_match_share_sx4) ? (pipe_sf_requester_share_sx4[`RNF_NUM*2-1:0] | pipe_sf_snp_share_state_sx4[`RNF_NUM*2-1:0]) :
           pipe_sf_self_invalid_sx4 ? pipe_sf_requester_invalid_sx4[`RNF_NUM*2-1:0] :
           pipe_sf_match_state_sx4_q[`RNF_NUM*2-1:0]       ;

    generate
        for (gi = 0;
                gi < `RNF_NUM;
                gi = gi + 1)begin
            assign pipe_sf_snp_tgt_vec_sx4[gi]
                   = |(pipe_sf_match_state_sx4_q[gi*2+:2] & ~pipe_sf_self_mask_sx4_q[gi*2+:2]) & ~pipe_fill_sx4 &
                   ((~pipe_tag_match_sx4_q & (op_rdnsd_sx4_q | op_rdclean_sx4_q | op_rdonce_sx4_q)) | op_rdunique_sx4_q | op_wufull_sx4_q | op_wuptl_sx4_q | op_dl_cu_sx4_q |
                    op_cmo_ci_sx4_q | op_dl_mu_sx4_q) & ~op_dl_evict_sx4_q;
        end
    endgenerate

    generate
        for (gi = 0;
                gi < `RNF_NUM;
                gi = gi + 1)begin
            assign pipe_sf_snp_unq_tgt_vec_sx4[gi]
                   = ((pipe_sf_match_state_sx4_q[gi*2+:2] == `SF_U) & pipe_sf_other_valid_mask_sx4_q[gi*2]);
            assign pipe_sf_snp_share_state_sx4[gi*2 +: 2] = {(`SF_STATE_WIDTH){pipe_sf_snp_unq_tgt_vec_sx4[gi]}};
        end
    endgenerate

    //////////////////////////////////////////////////////////////////////////////
    // Add new SF entry if need insert but miss and no free entry
    //////////////////////////////////////////////////////////////////////////////
    assign pipe_sf_insert_sx4 = ~(pipe_sf_self_match_sx4 | pipe_sf_other_match_sx4) & ~pipe_fill_sx4 & (op_rdnsd_sx4_q | op_rdclean_sx4_q | op_rdunique_sx4_q | op_dl_mu_sx4_q | op_dl_cu_sx4_q) & pipe_req_valid_sx[SX4] & ~((`RNF_NUM == 1) & (`RNI_NUM == 0));

    // SF evict
    assign pipe_sf_evict_sx4 = pipe_sf_insert_sx4 & ~pipe_sf_free_sx4;

    generate
        for (gi = 0;
                gi < `RNF_NUM;
                gi = gi + 1)begin
            assign pipe_sf_evict_tgt_vec_sx4[gi]
                   = |pipe_sf_evict_state_sx4_q[gi*2 +: 2];
        end
    endgenerate


    assign pipe_sf_evict_addr_sx4[ADDR_WIDTH-1:
                                  0] = {
               pipe_sf_evict_tag_sx4_q[`SF_TAG_WIDTH-1:0],
               pipe_addr_sx_q[SX4][`SF_INDEX_RANGE],
               {`CACHE_BLOCK_OFFSET{1'b0}}
           };

    // Insert miss SF entry
    assign pipe_sf_insert_state_sx4[`RNF_NUM*2-1:
                                    0] = pipe_sf_self_unique_sx4 ? pipe_sf_requester_unique_sx4[`RNF_NUM*2-1:0] :
           (pipe_sf_self_share_sx4 ? (pipe_sf_self_valid_mask_sx4_q[`RNF_NUM*2-1:0] | pipe_sf_self_share_mask_sx4_q[`RNF_NUM*2-1:0]):
            pipe_sf_all_invalid_sx4[`RNF_NUM*2-1:0]);


    assign pipe_sf_wr_way_sx4[`SF_WAY_NUM-1:
                              0] = (pipe_sf_other_match_sx4 | pipe_sf_self_match_sx4) ? pipe_sf_match_vec_sx4_q[`SF_WAY_NUM-1:0] :
           (pipe_sf_evict_sx4 ? pipe_sf_evict_next_sx4_q[`SF_WAY_NUM-1:0] : pipe_sf_free_way_vec_sx4[`SF_WAY_NUM-1:0]);
    assign pipe_sf_tgt_vec_sx4[`RNF_NUM-1:
                               0] = op_cmo_cs_sx4_q ? pipe_sf_snp_unq_tgt_vec_sx4[`RNF_NUM-1:0] : pipe_sf_snp_tgt_vec_sx4[`RNF_NUM-1:0];
    assign pipe_sf_wr_state_sx4[`RNF_NUM*2-1:
                                0] = (pipe_sf_other_match_sx4 | pipe_sf_self_match_sx4) ? pipe_sf_update_state_sx4[`RNF_NUM*2-1:0] : pipe_sf_insert_state_sx4[`RNF_NUM*2-1:0];

    //////////////////////////////////////////////////////////////////////////////
    // Tag hits and needs to read l3 data
    //////////////////////////////////////////////////////////////////////////////
    assign pipe_read_l3_nofill_sx4 = pipe_tag_match_sx4_q & (
               // ReadOnce/ReadNoShareDirty/ReadClean/ReadUnique will get l3 data if SLC hit
               op_rdonce_sx4_q | op_rdnsd_sx4_q | op_rdclean_sx4_q | op_rdunique_sx4_q |
               // WriteUniqePtl read l3 data for further merge data
               op_wuptl_sx4_q |
               // Dirty Read l3 data
               (pipe_tag_match_dirty_sx4_q & (op_dl_cu_sx4_q | op_cmo_cs_sx4_q | op_cmo_ci_sx4_q))
           );
    assign pipe_read_l3_fill_sx4 = pipe_tag_evict_sx4_q && pipe_tag_evict_dirty_sx4_q;
    assign pipe_read_l3_sx4 = (~pipe_fill_sx4 & pipe_read_l3_nofill_sx4)|(pipe_fill_sx4 & pipe_read_l3_fill_sx4);

    ///////////////////////////////////////////////////////////////////////////////
    // prepare snf_vec for biq hit
    //////////////////////////////////////////////////////////////////////////////
    generate
        for(gi=0;
                gi<`RNF_NUM;
                gi=gi+1)begin
            assign pipe_biq_hit_tgt_vec_sx5[gi]
                   = ~pipe_sf_self_valid_mask_sx4_q[gi*2];
        end
    endgenerate
    //=============================================================================
    //  IMPORTANT! MSHR request result
    //=============================================================================
    assign pipe_data_rd_sx4 = pipe_read_l3_sx4;
    assign pipe_data_wr_sx4 = pipe_insert_slc_sx4 | (pipe_update_slc_sx4 & ~(pipe_update_slc_nofill_sx4));
    assign pipe_tag_wr_sx4  = pipe_insert_slc_sx4 | pipe_invalid_slc_sx4 | pipe_update_slc_sx4;
    assign pipe_lru_wr_sx4  = pipe_insert_slc_sx4 | pipe_read_slc_sx4    | pipe_update_slc_sx4;
    assign pipe_sf_wr_sx4   = (((pipe_sf_other_match_sx4 | pipe_sf_self_match_sx4) && (pipe_sf_wr_state_sx4 != pipe_sf_match_state_sx4_q)) | pipe_sf_insert_sx4) & (~op_rdonce_sx4_q);

    // when no fill read miss in slc and sf
    assign pipe_mem_rd_sx4 = ~pipe_tag_match_sx4_q & ~pipe_sf_other_match_sx4 & ~pipe_fill_sx4 & (op_rdonce_sx4_q | op_rdnsd_sx4_q | op_rdclean_sx4_q | op_rdunique_sx4_q | op_wuptl_sx4_q);

    //=============================================================================
    // Stage 5
    // 1) read/write Data if slc hit
    // 2) Inquire AddrBuf from MSHR if slc miss and sf miss, next cycle get result
    // 3) update LRU if slc hit
    // 4) enqueue BIQ if insert sf but miss
    // 5) Store SX4 info(tag, sf, lru... info)
    //=============================================================================

    // CPL wrap write will done in SX5
    assign pipe_req_valid_sx[SX5] = pipe_req_valid_sx_q[SX5] & ~pipe_wrap_wr_sx5_q;

    // wrap SLC info from SX4 to SX5
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_tag_dirty_sx5_q                                        <= 1'b0;
            pipe_tag_hit_sx5_q                                          <= 1'b0;
            pipe_tag_wr_sx5_q                                           <= 1'b0;
            pipe_tag_evict_sx5_q                                        <= 1'b0;
            pipe_tag_evict_addr_sx5_q[ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET] <= {(ADDR_WIDTH-`CACHE_BLOCK_OFFSET){1'b0}};
            pipe_tag_wr_state_sx5_q[1:0]                                <= 2'b00;
            pipe_tag_wr_way_sx5_q[`LOC_WAY_NUM-1:0]                     <= {`LOC_WAY_NUM{1'b0}};
            pipe_tag_haz_way_sx5_q[`LOC_WAY_NUM-1:0]                    <= {`LOC_WAY_NUM{1'b0}};
            pipe_data_rd_sx5_q                                          <= 1'b0;
            pipe_data_wr_sx5_q                                          <= 1'b0;
        end
        else begin
            pipe_tag_hit_sx5_q                                          <= pipe_tag_match_sx4_q;
            pipe_tag_wr_sx5_q                                           <= pipe_tag_wr_sx4;
            pipe_tag_dirty_sx5_q                                        <= pipe_tag_match_dirty_sx4_q;
            pipe_tag_evict_sx5_q                                        <= pipe_tag_evict_sx4_q && pipe_tag_evict_dirty_sx4_q;
            pipe_tag_evict_addr_sx5_q[ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET] <= pipe_tag_evict_addr_sx4[ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET];
            pipe_tag_wr_state_sx5_q[1:0]                                <= pipe_tag_state_sx4[1:0];
            pipe_tag_wr_way_sx5_q[`LOC_WAY_NUM-1:0]                     <= pipe_tag_wr_way_sx4[`LOC_WAY_NUM-1:0];
            pipe_tag_haz_way_sx5_q[`LOC_WAY_NUM-1:0]                    <= pipe_tag_haz_way_sx4[`LOC_WAY_NUM-1:0];
            pipe_data_rd_sx5_q                                          <= pipe_data_rd_sx4;
            pipe_data_wr_sx5_q                                          <= pipe_data_wr_sx4;
        end
    end

    // wrap SF info from SX4 to SX5
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_sf_other_hit_sx5_q                                     <= 1'b0;
            pipe_sf_hit_sx5_q                                           <= 1'b0;
            pipe_sf_wr_sx5_q                                            <= 1'b0;
            pipe_sf_tgt_vec_sx5_q[`RNF_NUM-1:0]                          <= {`RNF_NUM{1'b0}};
            pipe_biq_hit_tgt_vec_sx5_q[`RNF_NUM-1:0]                     <= {`RNF_NUM{1'b0}};
            pipe_sf_evict_sx5_q                                         <= 1'b0;
            pipe_sf_wr_way_sx5_q[`SF_WAY_NUM-1:0]                       <= {`SF_WAY_NUM{1'b0}};
            pipe_sf_wr_state_sx5_q[`SF_CLINE_WIDTH-1:0]                 <= {`SF_CLINE_WIDTH{1'b0}};
            pipe_sf_evict_addr_sx5_q[ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET]  <= {(ADDR_WIDTH-`CACHE_BLOCK_OFFSET){1'b0}};
        end
        else begin
            pipe_sf_other_hit_sx5_q                                     <= pipe_sf_other_match_sx4;
            pipe_sf_hit_sx5_q                                           <= pipe_sf_other_match_sx4 | pipe_sf_self_match_sx4;
            pipe_sf_wr_sx5_q                                            <= pipe_sf_wr_sx4;
            pipe_sf_tgt_vec_sx5_q[`RNF_NUM-1:0]                          <= pipe_sf_tgt_vec_sx4[`RNF_NUM-1:0];
            pipe_biq_hit_tgt_vec_sx5_q[`RNF_NUM-1:0]                     <= pipe_biq_hit_tgt_vec_sx5[`RNF_NUM-1:0];
            pipe_sf_evict_sx5_q                                         <= pipe_sf_evict_sx4;
            pipe_sf_wr_way_sx5_q[`SF_WAY_NUM-1:0]                       <= pipe_sf_wr_way_sx4[`SF_WAY_NUM-1:0];
            pipe_sf_wr_state_sx5_q[`SF_CLINE_WIDTH-1:0]                 <= {pipe_addr_sx4[`SF_TAG_RANGE], pipe_sf_wr_state_sx4[`RNF_NUM*2-1:0]};
            pipe_sf_evict_addr_sx5_q[ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET]  <= pipe_sf_evict_addr_sx4[ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET];
        end
    end

    assign pipe_tag_wr_sx5 = !(biq_hit & ((pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0] == `CHIE_READNOTSHAREDDIRTY) | (pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0] == `CHIE_READCLEAN))
                               & ~pipe_sf_other_hit_sx5_q & pipe_tag_hit_sx5_q) & pipe_tag_wr_sx5_q;

    // LRU state
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_lru_wr_sx5_q                          <= 1'b0;
            pipe_lru_wr_rrpv_sx5_q[`LOC_WAY_NUM*2-1:0] <= {(`LOC_WAY_NUM * 2) {1'b0}};
        end
        else begin
            pipe_lru_wr_sx5_q                          <= pipe_lru_wr_sx4;
            pipe_lru_wr_rrpv_sx5_q[`LOC_WAY_NUM*2-1:0] <= pipe_lru_next_rrpv_sx4[`LOC_WAY_NUM*2-1:0];
        end
    end

    // wrap mem read result
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_mem_rd_sx5_q <= 1'b0;
        end
        else begin
            pipe_mem_rd_sx5_q <= pipe_mem_rd_sx4;
        end
    end

    // wrap write result
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_wrap_wr_sx5_q <= 1'b0;
        end
        else begin
            pipe_wrap_wr_sx5_q <= pipe_wrap_wr_sx4_q;
        end
    end
    // read data sram
    assign l3_index_sx4[`LOC_INDEX_WIDTH-1:
                        0] = ( pipe_wrap_wr_sx4_q & pipe_data_wr_sx4_q) ? pipe_addr_wr_sx4_q[`LOC_INDEX_RANGE]: pipe_addr_sx_q[SX4][`LOC_INDEX_RANGE];
    assign l3_rd_ways_sx4[`LOC_WAY_NUM-1:
                          0]   = (~pipe_wrap_wr_sx4_q & pipe_data_rd_sx4  ) ? ((pipe_tag_evict_sx4_q && pipe_tag_evict_dirty_sx4_q) ? pipe_tag_evict_way_sx4_q[`LOC_WAY_NUM-1:0] : pipe_tag_match_vec_sx4_q[`LOC_WAY_NUM-1:0]) : {`LOC_WAY_NUM{1'b0}};
    assign l3_wr_ways_sx4[`LOC_WAY_NUM-1:
                          0]   = ( pipe_wrap_wr_sx4_q & pipe_data_wr_sx4_q) ? pipe_tag_wr_way_sx4_q[`LOC_WAY_NUM-1:0]  : {`LOC_WAY_NUM{1'b0}};

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_tag_hazard_valid_sx5_q <= 1'b0;
            pipe_sf_hazard_valid_sx5_q  <= 1'b0;
        end
        else begin
            pipe_tag_hazard_valid_sx5_q <= pipe_lru_wr_sx4;
            pipe_sf_hazard_valid_sx5_q  <= pipe_sf_other_match_sx4 || pipe_sf_self_match_sx4 || pipe_sf_insert_sx4;
        end
    end
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            l3_index_q[`LOC_INDEX_WIDTH-1:0] <= {`LOC_INDEX_WIDTH{1'b0}};
            l3_rd_ways_q[`LOC_WAY_NUM-1:0]   <= {`LOC_WAY_NUM{1'b0}};
            l3_wr_ways_q[`LOC_WAY_NUM-1:0]   <= {`LOC_WAY_NUM{1'b0}};
        end
        else begin
            l3_index_q[`LOC_INDEX_WIDTH-1:0] <= l3_index_sx4[`LOC_INDEX_WIDTH-1:0];
            l3_rd_ways_q[`LOC_WAY_NUM-1:0]   <= l3_rd_ways_sx4[`LOC_WAY_NUM-1:0];
            l3_wr_ways_q[`LOC_WAY_NUM-1:0]   <= l3_wr_ways_sx4[`LOC_WAY_NUM-1:0];
        end
    end

    // inquiry addrbuffer for addr hazard
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_mshr_addr_sx5_q[ADDR_WIDTH-1:0] <= {ADDR_WIDTH{1'b0}};
            pipe_mshr_addr_valid_sx5_q           <= 1'b0;
            pipe_mshr_addr_idx_sx5_q             <= {`MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else begin
            pipe_mshr_addr_valid_sx5_q           <= pipe_mem_rd_sx3 || ((op_rdonce_sx3 | op_rdnsd_sx3 | op_rdclean_sx3 | op_rdunique_sx3 | op_wuptl_sx3) &&
                                                 ~pipe_tag_match_sx3 && ~pipe_fill_sx_q[SX3] && pipe_sf_other_match_sx3);

            pipe_mshr_addr_sx5_q[ADDR_WIDTH-1:0] <= pipe_addr_sx_q[SX3][ADDR_WIDTH-1:0];
            pipe_mshr_addr_idx_sx5_q             <= pipe_mshr_idx_sx_q[SX3];
        end
    end

    // BIQ(Back Invalidate Queue) Manager
    assign biq_evict_valid_sx5 = pipe_sf_evict_sx5_q & ~(mshr_l3_hazard_valid_sx3_q | pipe_hazard_fail_sx5) & ~biq_hit & pipe_req_valid_sx[SX5];
    assign biq_evict_retry_sx5 = biq_fifo_full & biq_evict_valid_sx5 & !mshr_l3_seq_retire_sx1_q;

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            biq_evict_addr_sx5_q  <= {ADDR_WIDTH{1'b0}};
        end
        else begin
            biq_evict_addr_sx5_q  <= {pipe_sf_evict_addr_sx4[ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET], {`CACHE_BLOCK_OFFSET{1'b0}}};
        end
    end

    assign biq_req_valid_s0_q  = ~biq_fifo_empty;
    assign biq_find_valid_sx5  = ~pipe_sf_hit_sx5_q && pipe_req_valid_sx[SX5];
    assign biq_hit = biq_hit_raw & ( (pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_READONCE)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_READUNIQUE)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_READNOTSHAREDDIRTY)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_READCLEAN)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_WRITEUNIQUEFULL)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_WRITEUNIQUEPTL)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_CLEANUNIQUE)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_MAKEUNIQUE)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_CLEANSHARED)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_CLEANINVALID) );

    hnf_biq #(
                .BIQ_WIDTH (BIQ_DATA_WIDTH           ),
                .BIQ_DEPTH (BIQ_NUM                  )
            ) u_biq (
                .clk       (clk                      ),
                .rst       (rst                      ),
                .push      (biq_evict_valid_sx5      ),
                .pop       (mshr_l3_seq_retire_sx1_q ),
                .addr_in   (biq_evict_addr_sx5_q     ),
                .addr_out  (biq_req_addr_s0_q        ),
                .find      (biq_find_valid_sx5       ),
                .find_addr (pipe_addr_sx_q[SX5]      ),
                .match     (biq_hit_raw              ),
                .biq_full  (biq_fifo_full            ),
                .biq_empty (biq_fifo_empty           ),
                .biq_pfull (                         )
            );

    // Internal Hazard Check
    // Hazard period is from SX2, SX3, SX4, SX5

    assign pipe_tag_index_sx5[`LOC_INDEX_WIDTH-1:
                              0] = pipe_addr_sx_q[SX5][`LOC_INDEX_RANGE];
    assign pipe_tag_way_sx5[`LOC_WAY_NUM-1:
                            0]       = pipe_tag_haz_way_sx5_q[`LOC_WAY_NUM-1:
                                                              0];
    assign pipe_sf_index_sx5[`SF_INDEX_WIDTH-1:
                             0]   = pipe_addr_sx_q[SX5][`SF_INDEX_RANGE];
    assign pipe_sf_way_sx5[`SF_WAY_NUM-1:
                           0]         = pipe_sf_wr_way_sx5_q[`SF_WAY_NUM-1:
                                                             0];
    generate
        for (gi = 0;
                gi < CPL_HZD_ENTRY;
                gi = gi + 1)begin
            assign pipe_tag_hazard_match_vec_sx5[gi]
                   = pipe_tag_hazard_valid_sx6_q[gi] &
                   ({pipe_tag_index_sx5[`LOC_INDEX_WIDTH-1:0], pipe_tag_way_sx5[`LOC_WAY_NUM-1:0]} == {pipe_tag_hazard_index_sx6_q[gi][`LOC_INDEX_WIDTH-1:0], pipe_tag_hazard_way_sx6_q[gi][`LOC_WAY_NUM-1:0]});

            assign pipe_sf_hazard_match_vec_sx5[gi] = pipe_sf_hazard_valid_sx6_q[gi] &
                   ({pipe_sf_index_sx5[`SF_INDEX_WIDTH-1:0], pipe_sf_way_sx5[`SF_WAY_NUM-1:0]} == {pipe_sf_hazard_index_sx6_q[gi][`SF_INDEX_WIDTH-1:0], pipe_sf_hazard_way_sx6_q[gi][`SF_WAY_NUM-1:0]});
        end
    endgenerate

    assign pipe_hazard_fail_sx5 = ((pipe_tag_hazard_valid_sx5_q & |pipe_tag_hazard_match_vec_sx5[CPL_HZD_ENTRY-1:0]) | (pipe_sf_hazard_valid_sx5_q & |pipe_sf_hazard_match_vec_sx5[CPL_HZD_ENTRY-1:0]));

    // Tag hazard manage
    always @* begin: pipe_tag_hazard_alloc_vector_comb_logic
        integer i;
        pipe_tag_hazard_alloc_vector = {CPL_HZD_ENTRY{1'b0}};
        pipe_tag_hazard_alloc_sx5 = {CPL_HZD_ENTRY{1'b0}};

        for (i=1; i<CPL_HZD_ENTRY; i=i+1)begin
            pipe_tag_hazard_alloc_vector[i] = pipe_tag_hazard_alloc_vector[i-1] | ~pipe_tag_hazard_valid_sx6_q[i-1];
        end

        for(i=0; i<CPL_HZD_ENTRY; i=i+1)begin
            pipe_tag_hazard_alloc_sx5[i] = ~pipe_tag_hazard_alloc_vector[i] & ~pipe_tag_hazard_valid_sx6_q[i];
        end
    end

    generate
        for (gi = 0;
                gi < CPL_HZD_ENTRY;
                gi = gi + 1)begin
            assign pipe_tag_hazard_set_sx5[gi]
                   = pipe_tag_wr_sx5 & pipe_tag_hazard_alloc_sx5[gi] & ~l3_replay_sx5;
            assign pipe_tag_hazard_clr_sx5[gi] = (pipe_tag_hazard_timer_sx5_q[gi] == CPL_HZD_ENTRY);
            assign pipe_tag_hazard_ns_sx5[gi]  = (pipe_tag_hazard_valid_sx6_q[gi] & ~pipe_tag_hazard_clr_sx5[gi]) | pipe_tag_hazard_set_sx5[gi];
            always @(posedge clk or posedge rst)begin
                if (rst == 1'b1)begin
                    pipe_tag_hazard_valid_sx6_q[gi]                       <= 1'b0;
                    pipe_tag_hazard_index_sx6_q[gi][`LOC_INDEX_WIDTH-1:0] <= {`LOC_INDEX_WIDTH{1'b0}};
                    pipe_tag_hazard_way_sx6_q[gi][`LOC_WAY_NUM-1:0]       <= {`LOC_WAY_NUM{1'b0}};
                end
                else if (pipe_tag_hazard_set_sx5[gi] | pipe_tag_hazard_clr_sx5[gi])begin
                    pipe_tag_hazard_valid_sx6_q[gi]                       <= pipe_tag_hazard_ns_sx5[gi];
                    pipe_tag_hazard_index_sx6_q[gi][`LOC_INDEX_WIDTH-1:0] <= pipe_addr_sx_q[SX5][`LOC_INDEX_RANGE];
                    pipe_tag_hazard_way_sx6_q[gi][`LOC_WAY_NUM-1:0]       <= pipe_tag_wr_way_sx5_q[`LOC_WAY_NUM-1:0];
                end
                else begin
                    pipe_tag_hazard_valid_sx6_q[gi]                       <= pipe_tag_hazard_valid_sx6_q[gi];
                    pipe_tag_hazard_index_sx6_q[gi][`LOC_INDEX_WIDTH-1:0] <= pipe_tag_hazard_index_sx6_q[gi][`LOC_INDEX_WIDTH-1:0];
                    pipe_tag_hazard_way_sx6_q[gi][`LOC_WAY_NUM-1:0]       <= pipe_tag_hazard_way_sx6_q[gi][`LOC_WAY_NUM-1:0];
                end
            end
            always @(posedge clk or posedge rst)begin
                if (rst == 1'b1)begin
                    pipe_tag_hazard_timer_sx5_q[gi] <= {CPL_HZD_ENTRY{1'b0}};
                end
                else if (pipe_tag_hazard_valid_sx6_q[gi])begin
                    pipe_tag_hazard_timer_sx5_q[gi] <= pipe_tag_hazard_timer_sx5_q[gi] + 1'b1;
                end
                else begin
                    pipe_tag_hazard_timer_sx5_q[gi] <= {CPL_HZD_ENTRY{1'b0}};
                end
            end
        end
    endgenerate

    // SF hazard manage
    always @* begin: pipe_sf_hazard_alloc_vector_comb_logic
        integer i;
        pipe_sf_hazard_alloc_vector = {CPL_HZD_ENTRY{1'b0}};
        pipe_sf_hazard_alloc_sx5 = {CPL_HZD_ENTRY{1'b0}};

        for (i=1; i<CPL_HZD_ENTRY; i=i+1)begin
            pipe_sf_hazard_alloc_vector[i] = pipe_sf_hazard_alloc_vector[i-1] | ~pipe_sf_hazard_valid_sx6_q[i-1];
        end

        for(i=0; i<CPL_HZD_ENTRY; i=i+1)begin
            pipe_sf_hazard_alloc_sx5[i] = ~pipe_sf_hazard_alloc_vector[i] & ~pipe_sf_hazard_valid_sx6_q[i];
        end
    end

    generate
        for (gi = 0;
                gi < CPL_HZD_ENTRY;
                gi = gi + 1)begin
            assign pipe_sf_hazard_set_sx5[gi]
                   = pipe_sf_wr_sx5_q & pipe_sf_hazard_alloc_sx5[gi] & ~l3_replay_sx5 & ~biq_hit;
            assign pipe_sf_hazard_clr_sx5[gi] = (pipe_sf_hazard_timer_sx5_q[gi] == CPL_HZD_ENTRY);
            assign pipe_sf_hazard_ns_sx5[gi]  = (pipe_sf_hazard_valid_sx6_q[gi] & ~pipe_sf_hazard_clr_sx5[gi]) | pipe_sf_hazard_set_sx5[gi];
            always @(posedge clk or posedge rst)begin
                if (rst == 1'b1)begin
                    pipe_sf_hazard_valid_sx6_q[gi]                      <= 1'b0;
                    pipe_sf_hazard_index_sx6_q[gi][`SF_INDEX_WIDTH-1:0] <= {`SF_INDEX_WIDTH{1'b0}};
                    pipe_sf_hazard_way_sx6_q[gi][`SF_WAY_NUM-1:0]       <= {`SF_WAY_NUM{1'b0}};
                end
                else if (pipe_sf_hazard_set_sx5[gi] | pipe_sf_hazard_clr_sx5[gi])begin
                    pipe_sf_hazard_valid_sx6_q[gi]                      <= pipe_sf_hazard_ns_sx5[gi];
                    pipe_sf_hazard_index_sx6_q[gi][`SF_INDEX_WIDTH-1:0] <= pipe_addr_sx_q[SX5][`SF_INDEX_RANGE];
                    pipe_sf_hazard_way_sx6_q[gi][`SF_WAY_NUM-1:0]       <= pipe_sf_wr_way_sx5_q[`SF_WAY_NUM-1:0];
                end
                else begin
                    pipe_sf_hazard_valid_sx6_q[gi]                      <= pipe_sf_hazard_valid_sx6_q[gi];
                    pipe_sf_hazard_index_sx6_q[gi][`SF_INDEX_WIDTH-1:0] <= pipe_sf_hazard_index_sx6_q[gi][`SF_INDEX_WIDTH-1:0];
                    pipe_sf_hazard_way_sx6_q[gi][`SF_WAY_NUM-1:0]       <= pipe_sf_hazard_way_sx6_q[gi][`SF_WAY_NUM-1:0];
                end
            end
            always @(posedge clk or posedge rst)begin
                if (rst == 1'b1)begin
                    pipe_sf_hazard_timer_sx5_q[gi] <= {CPL_HZD_ENTRY{1'b0}};
                end
                else if (pipe_sf_hazard_valid_sx6_q[gi])begin
                    pipe_sf_hazard_timer_sx5_q[gi] <= pipe_sf_hazard_timer_sx5_q[gi] + 1'b1;
                end
                else begin
                    pipe_sf_hazard_timer_sx5_q[gi] <= {CPL_HZD_ENTRY{1'b0}};
                end
            end
        end
    endgenerate

    // update SLC tag and data status to SX6(SX1)
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_tag_wr_sx6_q                           <= 1'b0;
            pipe_tag_wr_state_sx6_q[1:0]                <= 2'b00;
            pipe_tag_wr_way_sx6_q[`LOC_WAY_NUM-1:0]     <= {`LOC_WAY_NUM{1'b0}};
            pipe_data_wr_sx6_q                          <= 1'b0;
        end
        else if(pipe_req_valid_sx[SX5])begin
            pipe_tag_wr_sx6_q                           <= pipe_tag_wr_sx5;
            pipe_tag_wr_state_sx6_q[1:0]                <= pipe_tag_wr_state_sx5_q[1:0];//2'b00;
            pipe_tag_wr_way_sx6_q[`LOC_WAY_NUM-1:0]     <= pipe_tag_wr_way_sx5_q[`LOC_WAY_NUM-1:0];
            pipe_data_wr_sx6_q                          <= pipe_data_wr_sx5_q;
        end
        else begin
            pipe_tag_wr_sx6_q                           <= 1'b0;
            pipe_tag_wr_state_sx6_q[1:0]                <= 2'b00;
            pipe_tag_wr_way_sx6_q[`LOC_WAY_NUM-1:0]     <= {`LOC_WAY_NUM{1'b0}};
            pipe_data_wr_sx6_q                          <= 1'b0;
        end
    end

    // update SF status to SX6(SX1)
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_sf_wr_sx6_q                            <= 1'b0;
            pipe_sf_wr_state_sx6_q[`SF_CLINE_WIDTH-1:0] <= {`SF_CLINE_WIDTH{1'b0}};
            pipe_sf_wr_way_sx6_q[`SF_WAY_NUM-1:0]       <= {`SF_WAY_NUM{1'b0}};
        end
        else if(pipe_req_valid_sx[SX5])begin
            pipe_sf_wr_sx6_q                            <= pipe_sf_wr_sx5_q & ~biq_hit;
            pipe_sf_wr_state_sx6_q[`SF_CLINE_WIDTH-1:0] <= pipe_sf_wr_state_sx5_q[`SF_CLINE_WIDTH-1:0];
            pipe_sf_wr_way_sx6_q[`SF_WAY_NUM-1:0]       <= pipe_sf_wr_way_sx5_q[`SF_WAY_NUM-1:0];
        end
        else begin
            pipe_sf_wr_sx6_q                            <= 1'b0;
            pipe_sf_wr_state_sx6_q[`SF_CLINE_WIDTH-1:0] <= {`SF_CLINE_WIDTH{1'b0}};
            pipe_sf_wr_way_sx6_q[`SF_WAY_NUM-1:0]       <= {`SF_WAY_NUM{1'b0}};
        end
    end

    // update LRU status to SX6(SX1)
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_lru_wr_sx6_q                           <= 1'b0;
            pipe_lru_wr_rrpv_sx6_q[`LOC_WAY_NUM*2-1:0]  <= {(`LOC_WAY_NUM * 2) {1'b0}};
        end
        else if(pipe_req_valid_sx[SX5])begin
            pipe_lru_wr_sx6_q                           <= pipe_lru_wr_sx5_q;
            pipe_lru_wr_rrpv_sx6_q[`LOC_WAY_NUM*2-1:0]  <= pipe_lru_wr_rrpv_sx5_q[`LOC_WAY_NUM*2-1:0];
        end
        else begin
            pipe_lru_wr_sx6_q                           <= 1'b0;
            pipe_lru_wr_rrpv_sx6_q[`LOC_WAY_NUM*2-1:0]  <= {(`LOC_WAY_NUM * 2) {1'b0}};
        end
    end

    // need to update sf, tag, data, and lru in the second round.
    assign cpl_internal_wr_sx5 = (pipe_sf_wr_sx5_q & ~biq_hit) | pipe_tag_wr_sx5 | pipe_data_wr_sx5_q | pipe_lru_wr_sx5_q;

    // compute snp count
    always @*begin
        pipe_sf_hit_count_sx5[`RNF_WIDTH-1:0] = {`RNF_WIDTH{1'b0}};
        for (ii = 0; ii < `RNF_NUM; ii = ii + 1)begin
            pipe_sf_hit_count_sx5[`RNF_WIDTH-1:0] = pipe_sf_hit_count_sx5[`RNF_WIDTH-1:0] + pipe_sf_tgt_vec_sx5_q[ii];
        end
    end

    //outputs cpl result to mshr
    assign pipe_biq_hit_cancel_brd_sx5 = pipe_tag_hit_sx5_q & ((pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_READONCE)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_READNOTSHAREDDIRTY)||(pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0]==`CHIE_READCLEAN));
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            l3_pipeval_sx7_q    <= 1'b0;
            l3_mshr_entry_sx7_q <= {`MSHR_ENTRIES_WIDTH{1'b0}};
            l3_opcode_sx7_q     <= {OPCODE_WIDTH{1'b0}};
            l3_memrd_sx7_q      <= 1'b0;
            l3_hit_sx7_q        <= 1'b0;
            l3_hit_dirty_sx7_q  <= 1'b0;
            l3_sfhit_sx7_q      <= 1'b0;
            l3_snpdirect_sx7_q  <= 1'b0;
            l3_snpbrd_sx7_q     <= 1'b0;
            l3_snp_bit_sx7_q    <= {HNF_MSHR_RNF_NUM_PARAM{1'b0}};
            l3_replay_sx7_q     <= 1'b0;
            l3_mshr_wr_op_sx7_q <= 1'b0;
            l3_evict_sx7_q      <= 1'b0;
            l3_evict_addr_sx7_q <= {ADDR_WIDTH{1'b0}};
        end
        else if(pipe_fill_sx_q[SX5])begin
            l3_pipeval_sx7_q    <= pipe_req_valid_sx_q[SX5];
            l3_opcode_sx7_q     <= pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0];
            l3_mshr_entry_sx7_q <= pipe_mshr_idx_sx_q[SX5][`MSHR_ENTRIES_WIDTH-1:0];
            l3_memrd_sx7_q      <= 1'b0;
            l3_hit_sx7_q        <= 1'b0;
            l3_hit_dirty_sx7_q  <= 1'b0;
            l3_sfhit_sx7_q      <= 1'b0;
            l3_snpdirect_sx7_q  <= 1'b0;
            l3_snpbrd_sx7_q     <= 1'b0;
            l3_snp_bit_sx7_q    <= {`RNF_NUM{1'b0}};
            l3_replay_sx7_q     <= mshr_l3_hazard_valid_sx3_q | pipe_hazard_fail_sx5 | biq_evict_retry_sx5;
            l3_mshr_wr_op_sx7_q <= ~(pipe_hazard_fail_sx5 | mshr_l3_hazard_valid_sx3_q | biq_evict_retry_sx5) & cpl_internal_wr_sx5;
            l3_evict_sx7_q      <= pipe_tag_evict_sx5_q && !l3_replay_sx5;
            l3_evict_addr_sx7_q <= {pipe_tag_evict_addr_sx5_q[ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET], {`CACHE_BLOCK_OFFSET{1'b0}}};
        end
        else begin
            l3_pipeval_sx7_q    <= pipe_req_valid_sx_q[SX5];
            l3_opcode_sx7_q     <= pipe_opcode_sx_q[SX5][OPCODE_WIDTH-1:0];
            l3_mshr_entry_sx7_q <= pipe_mshr_idx_sx_q[SX5][`MSHR_ENTRIES_WIDTH-1:0];
            l3_memrd_sx7_q      <= pipe_mem_rd_sx5_q & ~l3_replay_sx5 & (~biq_hit);
            l3_hit_sx7_q        <= pipe_tag_hit_sx5_q;
            l3_hit_dirty_sx7_q  <= pipe_tag_dirty_sx5_q;
            l3_sfhit_sx7_q      <= pipe_sf_other_hit_sx5_q | biq_hit;
            l3_snpdirect_sx7_q  <= (pipe_sf_hit_count_sx5[`RNF_WIDTH-1:0] == 1);
            l3_snpbrd_sx7_q     <= (pipe_sf_other_hit_sx5_q & (pipe_sf_hit_count_sx5[`RNF_WIDTH-1:0] > 1) & !pipe_biq_hit_cancel_brd_sx5) | (biq_hit & (~pipe_biq_hit_cancel_brd_sx5));
            l3_snp_bit_sx7_q    <= biq_hit?pipe_biq_hit_tgt_vec_sx5_q[`RNF_NUM-1:0]: pipe_sf_tgt_vec_sx5_q[`RNF_NUM-1:0];
            l3_replay_sx7_q     <= pipe_hazard_fail_sx5 | mshr_l3_hazard_valid_sx3_q | biq_evict_retry_sx5;
            l3_mshr_wr_op_sx7_q <= ~(pipe_hazard_fail_sx5 | mshr_l3_hazard_valid_sx3_q | biq_evict_retry_sx5) & cpl_internal_wr_sx5;
            l3_evict_sx7_q      <= 1'b0;
            l3_evict_addr_sx7_q <= {pipe_tag_evict_addr_sx5_q[ADDR_WIDTH-1:`CACHE_BLOCK_OFFSET], {`CACHE_BLOCK_OFFSET{1'b0}}};
        end
    end

    // write request to databuffer
    assign l3_replay_sx5 = pipe_hazard_fail_sx5 | mshr_l3_hazard_valid_sx3_q | biq_evict_retry_sx5;

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_dbf_wr_valid_sx9_q <= 1'b0;
            pipe_dbf_wr_idx_sx9_q   <= {`MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else begin
            pipe_dbf_wr_idx_sx9_q   <= pipe_mshr_idx_sx_q[SX5];
            pipe_dbf_wr_valid_sx9_q <= pipe_data_rd_sx5_q && !l3_replay_sx5;
        end
    end
    //=============================================================================
    // internal write will be canceled if any below conditions satisfied:
    //   - biq full
    //   - addrbuffer hazard
    //   - tag or sf hazard_fifo hazard
    //=============================================================================
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            cpl_internal_wr_sx6_q <= 1'b0;
        end
        else if (pipe_req_valid_sx[SX5] == 1'b1)begin
            cpl_internal_wr_sx6_q <= cpl_internal_wr_sx5 & ~l3_replay_sx5;
        end
        else begin
            cpl_internal_wr_sx6_q <= 1'b0;
        end
    end

    assign pipe_addr_sx6[ADDR_WIDTH-1:
                         0] = pipe_addr_sx_q[SX6][ADDR_WIDTH-1:
                                                  0];

    // read databuffer valid
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_dbf_rd_idx_valid_sx6_q <= 1'b0;
        end
        else if (pipe_req_valid_sx[SX5] == 1'b1)begin
            pipe_dbf_rd_idx_valid_sx6_q <= pipe_data_wr_sx5_q & ~l3_replay_sx5;
        end
        else begin
            pipe_dbf_rd_idx_valid_sx6_q <= 1'b0;
        end
    end

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            pipe_dbf_rd_idx_sx6_q <= 1'b0;
        end
        else if (pipe_req_valid_sx[SX5] == 1'b1)begin
            pipe_dbf_rd_idx_sx6_q <= pipe_mshr_idx_sx_q[SX5][`MSHR_ENTRIES_WIDTH-1:0];
        end
    end

`ifdef DISPLAY_INFO
    reg [`RNF_NUM*2-1:
         0]        disp_pipe_sf_match_state_sx5_q;
    reg [`RNF_NUM*2-1:
         0]        disp_pipe_sf_wr_state_sx5_q;
    reg [`LRU_CLINE_WIDTH-1:
         0]  disp_lru_rd_data_sx5_q;
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)begin
            disp_pipe_sf_match_state_sx5_q       <= 'd0;
            disp_pipe_sf_wr_state_sx5_q          <= 'd0;
            disp_lru_rd_data_sx5_q               <= 'd0;
        end
        else begin
            disp_pipe_sf_match_state_sx5_q       <= pipe_sf_match_state_sx4_q;
            disp_pipe_sf_wr_state_sx5_q          <= pipe_sf_wr_state_sx4;
            disp_lru_rd_data_sx5_q               <= lru_rd_data_d_q;
        end
    end

    initial begin
        while(1)begin
            @(posedge clk);
            #1;
            if(pipe_tag_wr_sx5 | pipe_sf_wr_sx5_q | pipe_lru_wr_sx5_q | pipe_data_wr_sx5_q | pipe_data_rd_sx5_q | biq_evict_valid_sx5 | biq_hit | pipe_hazard_fail_sx5 | mshr_l3_hazard_valid_sx3_q | biq_evict_retry_sx5)begin
                $display("*****************************************************************");
                $display("Trans Basic Information :");
                $display("  opcode      : %h.", pipe_opcode_sx_q[SX5]);
                $display("  addr        : %h.", pipe_addr_sx_q[SX5]);
                $display("  rnf_idx     : %h.", pipe_rnf_idx_sx_q[SX5]);
                $display("  mshr_idx    : %h.", pipe_mshr_idx_sx_q[SX5]);
                $display("  fill        : %h.", pipe_fill_sx_q[SX5]);
                $display("  fill_dirty  : %h.", pipe_fill_dirty_sx_q[SX5]);
                if(pipe_tag_wr_sx5)begin
                    $display("**TAG state change**");
                    if(pipe_tag_hit_sx5_q)begin
                        $display("    tag hit, hit tag way: %h.", pipe_tag_wr_way_sx5_q);
                    end
                    else if(pipe_tag_evict_sx5_q)begin
                        $display("    tag evict, evict tag way: %h.", pipe_tag_wr_way_sx5_q);
                    end
                    else begin
                        $display("    tag insert, insert tag way: %h.", pipe_tag_wr_way_sx5_q);
                    end
                    $display("    tag_rd_state: %b.", {~pipe_tag_dirty_sx5_q,pipe_tag_hit_sx5_q});
                    $display("    tag_wr_state: %b.", pipe_tag_wr_state_sx5_q);
                end
                if(pipe_sf_wr_sx5_q)begin
                    $display("**SF state change**");
                    if(pipe_sf_hit_sx5_q)begin
                        $display("    sf hit, hit sf way: %h.", pipe_sf_wr_way_sx5_q);
                    end
                    else if(pipe_sf_evict_sx5_q)begin
                        $display("    sf evict, evict sf way: %h.", pipe_sf_wr_way_sx5_q);
                    end
                    else begin
                        $display("    sf insert, insert sf way: %h.", pipe_sf_wr_way_sx5_q);
                    end
                    $display("    sf_rd_state: %b.", disp_pipe_sf_match_state_sx5_q);
                    $display("    sf_wr_state: %b.", disp_pipe_sf_wr_state_sx5_q);
                end
                if(pipe_lru_wr_sx5_q)begin
                    $display("**LRU data change**");
                    $display("    lru_rd_data: %h.", disp_lru_rd_data_sx5_q);
                    $display("    lru_wr_data: %h.", pipe_lru_wr_rrpv_sx5_q);
                end
                if(pipe_data_wr_sx5_q)begin
                    $display("**DATA sram write**");
                    $display("    data sram write, write way: %h.", pipe_tag_wr_way_sx5_q);
                end
                if(pipe_data_rd_sx5_q)begin
                    $display("**DATA sram read**");
                    $display("    data sram read, read way: %h.", l3_rd_ways_q);
                end
                if(biq_evict_valid_sx5)begin
                    $display("**PUSH biq fifo**");
                    $display("    push_biq_addr: %h.", biq_evict_addr_sx5_q);
                end
                if(biq_hit)begin
                    $display("**BIQ hit**");
                end
                if(pipe_hazard_fail_sx5 | mshr_l3_hazard_valid_sx3_q | biq_evict_retry_sx5)begin
                    $display("**REPLAY**");
                    if(pipe_tag_hazard_valid_sx5_q & |pipe_tag_hazard_match_vec_sx5[CPL_HZD_ENTRY-1:0])begin
                        $display("    tag hazard.");
                    end
                    if(pipe_sf_hazard_valid_sx5_q & |pipe_sf_hazard_match_vec_sx5[CPL_HZD_ENTRY-1:0])begin
                        $display("    sf hazard.");
                    end
                    if(mshr_l3_hazard_valid_sx3_q)begin
                        $display("    addr buffer hazard.");
                    end
                    if(biq_evict_retry_sx5)begin
                        $display("    biq full but enqueue.");
                    end
                end
                $display("*****************************************************************");
            end
        end
    end
`endif

`ifdef DISPLAY_FATAL
    reg [`RNF_NUM-1:
         0] sf_state_u_count;
    reg [`RNF_NUM-1:
         0] sf_state_s_count;
    integer i;
    integer j;
    initial begin
        while(1)begin
            @(posedge clk);
            #1;
            if(mshr_l3_req_en_sx1_q)begin
                //mshr_l3_opcode_sx1_q check
                if((mshr_l3_opcode_sx1_q == `CHIE_READONCE) || (mshr_l3_opcode_sx1_q == `CHIE_READCLEAN) || (mshr_l3_opcode_sx1_q == `CHIE_READNOTSHAREDDIRTY) ||
                        (mshr_l3_opcode_sx1_q == `CHIE_READUNIQUE) || (mshr_l3_opcode_sx1_q == `CHIE_WRITEUNIQUEFULL) || (mshr_l3_opcode_sx1_q == `CHIE_WRITEUNIQUEPTL) ||
                        (mshr_l3_opcode_sx1_q == `CHIE_WRITEBACKFULL) || (mshr_l3_opcode_sx1_q == `CHIE_WRITEEVICTFULL) || (mshr_l3_opcode_sx1_q == `CHIE_CLEANUNIQUE) ||
                        (mshr_l3_opcode_sx1_q == `CHIE_MAKEUNIQUE) || (mshr_l3_opcode_sx1_q == `CHIE_EVICT) || (mshr_l3_opcode_sx1_q == `CHIE_CLEANSHARED) ||
                        (mshr_l3_opcode_sx1_q == `CHIE_CLEANINVALID))begin
                end
                else begin
                    $fatal("mshr_l3_opcode_sx1_q ERROR:  %h.",mshr_l3_opcode_sx1_q);
                end
                //mshr_l3_fill_sx1_q check
                if(((mshr_l3_opcode_sx1_q == `CHIE_WRITEBACKFULL) || (mshr_l3_opcode_sx1_q == `CHIE_WRITEEVICTFULL)) && mshr_l3_fill_sx1_q == 1'b0 && mshr_l3_req_en_sx1_q)begin
                    $fatal("mshr_l3_fill_sx1_q ERROR:  opcode = %h , fill = %h.",mshr_l3_opcode_sx1_q,mshr_l3_fill_sx1_q);
                end
                else if(((mshr_l3_opcode_sx1_q == `CHIE_READUNIQUE) || (mshr_l3_opcode_sx1_q == `CHIE_CLEANUNIQUE) ||
                         (mshr_l3_opcode_sx1_q == `CHIE_MAKEUNIQUE) || (mshr_l3_opcode_sx1_q == `CHIE_EVICT) ||
                         (mshr_l3_opcode_sx1_q == `CHIE_CLEANSHARED) || (mshr_l3_opcode_sx1_q == `CHIE_CLEANINVALID)) && mshr_l3_fill_sx1_q == 1'b1)begin
                    $fatal("mshr_l3_fill_sx1_q ERROR:  opcode = %h , fill = %h.",mshr_l3_opcode_sx1_q,mshr_l3_fill_sx1_q);
                end
                else begin
                end
            end
            if(pipe_req_valid_sx_q[SX2])begin
                //mshr_l3_rnf_sx1_q check
                if(!pipe_rnfid_found_sx2)begin
                    $fatal("mshr_l3_rnf_sx1_q ERROR:  rnf = %h ",pipe_rnf_idx_sx_q[SX2][NID_WIDTH-1:0]);
                end
            end
            if(pipe_req_valid_sx_q[SX3])begin
                //loc_state sf_state check
                for (i = 0; i < `LOC_WAY_NUM; i = i + 1)begin
                    if({loc_rd_clines_q[`LOC_TAG_STATE_CLEAN+i*`LOC_CLINE_WIDTH],loc_rd_clines_q[`LOC_TAG_STATE_VALID+i*`LOC_CLINE_WIDTH]} == 2'b10)begin
                        $fatal("loc_rd_clines_q ERROR:  loc state = 2'b10 ");
                    end
                end

                for (i = 0; i < `SF_WAY_NUM; i = i + 1)begin
                    for(j = 0; j < `RNF_NUM; j = j + 1)begin
                        if({sf_rd_clines_q[i*`SF_CLINE_WIDTH+j*2+1],sf_rd_clines_q[i*`SF_CLINE_WIDTH+j*2]} == 2'b10)begin
                            $fatal("sf_rd_clines_q ERROR:  sf state = 2'b10 ");
                        end
                    end
                end

                for (i = 0; i < `SF_WAY_NUM; i = i + 1)begin
                    sf_state_u_count = 'd0;
                    sf_state_s_count = 'd0;
                    for(j = 0; j < `RNF_NUM; j = j + 1)begin
                        if({sf_rd_clines_q[i*`SF_CLINE_WIDTH+j*2+1],sf_rd_clines_q[i*`SF_CLINE_WIDTH+j*2]} == 2'b01)begin
                            sf_state_u_count = sf_state_u_count + 1;
                        end
                        if({sf_rd_clines_q[i*`SF_CLINE_WIDTH+j*2+1],sf_rd_clines_q[i*`SF_CLINE_WIDTH+j*2]} == 2'b11)begin
                            sf_state_s_count = sf_state_s_count + 1;
                        end
                    end
                    if(sf_state_u_count > 'd1)begin
                        $fatal("sf_rd_clines_q ERROR, Unique state has more than one");
                    end
                    if(sf_state_u_count == 'd1 && sf_state_s_count != 'd0)begin
                        $fatal("sf_rd_clines_q ERROR, Unique states and Share states coexist");
                    end
                end
            end
            if(pipe_req_valid_sx_q[SX4])begin
                if(pipe_tag_match_sx4_q && (pipe_sf_self_match_sx4 || pipe_sf_other_match_sx4))begin
                    sf_state_u_count = 'd0;
                    for(i = 0; i < `RNF_NUM; i = i + 1)begin
                        if({pipe_sf_match_state_sx4_q[i*2+1],pipe_sf_match_state_sx4_q[i*2]} == 2'b01)begin
                            sf_state_u_count = sf_state_u_count + 1;
                        end
                    end
                    if(sf_state_u_count != 'd0)begin
                        $fatal("sf_rd_clines_q and loc_rd_clines_q ERROR, When l3 hit, Snoop Filter contains Unique state");
                    end
                end
            end
        end
    end
`endif

endmodule
