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
*    Jianhong Zhang <zhangjianhong@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf `HNF_PARAM
    (
        //inputs
        CLK,
        RST,
        RXREQFLITV,
        RXREQFLIT,
        RXREQFLITPEND,
        RXRSPFLITV,
        RXRSPFLIT,
        RXRSPFLITPEND,
        RXDATFLITV,
        RXDATFLIT,
        RXDATFLITPEND,
        TXREQLCRDV,
        TXRSPLCRDV,
        TXSNPLCRDV,
        TXDATLCRDV,

        //outputs
        RXREQLCRDV,
        RXRSPLCRDV,
        RXDATLCRDV,
        TXREQFLITV,
        TXREQFLIT,
        TXREQFLITPEND,
        TXRSPFLITV,
        TXRSPFLIT,
        TXRSPFLITPEND,
        TXSNPFLITV,
        TXSNPFLIT,
        TXSNPFLITPEND,
        TXDATFLITV,
        TXDATFLIT,
        TXDATFLITPEND,

        notify_reg

`ifdef tb_hnf

        //debug signals
        ,
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
        dbg_sf_rd_clines_q
`endif

    );
    //inputs
    input wire                                  CLK;
    input wire                                  RST;
    input wire                                  RXREQFLITV;
    input wire [`CHIE_REQ_FLIT_RANGE]           RXREQFLIT;
    input wire                                  RXREQFLITPEND;
    input wire                                  RXRSPFLITV;
    input wire [`CHIE_RSP_FLIT_RANGE]           RXRSPFLIT;
    input wire                                  RXRSPFLITPEND;
    input wire                                  RXDATFLITV;
    input wire [`CHIE_DAT_FLIT_RANGE]           RXDATFLIT;
    input wire                                  RXDATFLITPEND;
    input wire                                  TXREQLCRDV;
    input wire                                  TXRSPLCRDV;
    input wire                                  TXSNPLCRDV;
    input wire                                  TXDATLCRDV;

    //outputs
    output wire                                 RXREQLCRDV;
    output wire                                 RXRSPLCRDV;
    output wire                                 RXDATLCRDV;
    output wire                                 TXREQFLITV;
    output wire [`CHIE_REQ_FLIT_RANGE]          TXREQFLIT;
    output wire                                 TXREQFLITPEND;
    output wire                                 TXRSPFLITV;
    output wire [`CHIE_RSP_FLIT_RANGE]          TXRSPFLIT;
    output wire                                 TXRSPFLITPEND;
    output wire                                 TXSNPFLITV;
    output wire [`HNF_SNP_FLIT_RANGE]           TXSNPFLIT;
    output wire                                 TXSNPFLITPEND;
    output wire                                 TXDATFLITV;
    output wire [`CHIE_DAT_FLIT_RANGE]          TXDATFLIT;
    output wire                                 TXDATFLITPEND;
    output wire [2:0]                           notify_reg;

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

    //outputs
    output wire [`CACHE_LINE_WIDTH-1:0]             dbg_l3_rd_data_q;
    output wire [`LRU_CLINE_WIDTH-1:0]              dbg_lru_rd_data_q;
    output wire [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0] dbg_loc_rd_clines_q;
    output wire [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]   dbg_sf_rd_clines_q;
`endif

    //wires
    wire                                        biq_req_valid_s0_q;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        biq_req_addr_s0_q;
    wire                                        qos_seq_pool_full_s0_q;
    wire                                        rxreq_retry_enable_s0;
    wire                                        mshr_txreq_bypass_valid_s1;
    wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]         mshr_txreq_bypass_qos_s1;
    wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]       mshr_txreq_bypass_txnid_s1;
    wire [`CHIE_REQ_FLIT_RETURNNID_WIDTH-1:0]   mshr_txreq_bypass_returnnid_s1;
    wire [`CHIE_REQ_FLIT_RETURNTXNID_WIDTH-1:0] mshr_txreq_bypass_returntxnid_s1;
    wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      mshr_txreq_bypass_opcode_s1;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        mshr_txreq_bypass_size_s1;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        mshr_txreq_bypass_addr_s1;
    wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]          mshr_txreq_bypass_ns_s1;
    wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0]  mshr_txreq_bypass_allowretry_s1;
    wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]       mshr_txreq_bypass_order_s1;
    wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]    mshr_txreq_bypass_pcrdtype_s1;
    wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]     mshr_txreq_bypass_memattr_s1;
    wire [`CHIE_REQ_FLIT_DODWT_WIDTH-1:0]       mshr_txreq_bypass_dodwt_s1;
    wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]    mshr_txreq_bypass_tracetag_s1;
    wire                                        mshr_txreq_valid_sx1_q;
    wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]         mshr_txreq_qos_sx1;
    wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]       mshr_txreq_txnid_sx1_q;
    wire [`CHIE_REQ_FLIT_RETURNNID_WIDTH-1:0]   mshr_txreq_returnnid_sx1;
    wire [`CHIE_REQ_FLIT_RETURNTXNID_WIDTH-1:0] mshr_txreq_returntxnid_sx1;
    wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      mshr_txreq_opcode_sx1;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        mshr_txreq_size_sx1;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        mshr_txreq_addr_sx1;
    wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]          mshr_txreq_ns_sx1;
    wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0]  mshr_txreq_allowretry_sx1;
    wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]       mshr_txreq_order_sx1;
    wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]    mshr_txreq_pcrdtype_sx1;
    wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]     mshr_txreq_memattr_sx1;
    wire [`CHIE_REQ_FLIT_DODWT_WIDTH-1:0]       mshr_txreq_dodwt_sx1;
    wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]    mshr_txreq_tracetag_sx1;
    wire                                        mshr_txrsp_bypass_valid_s1;
    wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         mshr_txrsp_bypass_qos_s1;
    wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       mshr_txrsp_bypass_tgtid_s1;
    wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       mshr_txrsp_bypass_txnid_s1;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      mshr_txrsp_bypass_opcode_s1;
    wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]     mshr_txrsp_bypass_resperr_s1;
    wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]        mshr_txrsp_bypass_dbid_s1;
    wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    mshr_txrsp_bypass_tracetag_s1;
    wire                                        qos_txrsp_retryack_valid_s1;
    wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         qos_txrsp_retryack_qos_s1;
    wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       qos_txrsp_retryack_tgtid_s1;
    wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       qos_txrsp_retryack_txnid_s1;
    wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]    qos_txrsp_retryack_pcrdtype_s1;
    wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    qos_txrsp_retryack_tracetag_s1;
    wire                                        qos_txrsp_pcrdgnt_valid_s2;
    wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         qos_txrsp_pcrdgnt_qos_s2;
    wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       qos_txrsp_pcrdgnt_tgtid_s2;
    wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]    qos_txrsp_pcrdgnt_pcrdtype_s2;
    wire                                        mshr_txrsp_valid_sx1_q;
    wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         mshr_txrsp_qos_sx1;
    wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       mshr_txrsp_tgtid_sx1;
    wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       mshr_txrsp_txnid_sx1_q;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      mshr_txrsp_opcode_sx1;
    wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]     mshr_txrsp_resperr_sx1;
    wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]        mshr_txrsp_resp_sx1;
    wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]        mshr_txrsp_dbid_sx1;
    wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    mshr_txrsp_tracetag_sx1;
    wire                                        mshr_txsnp_valid_sx1_q;
    wire [`CHIE_SNP_FLIT_QOS_WIDTH-1:0]         mshr_txsnp_qos_sx1;
    wire [`CHIE_SNP_FLIT_TXNID_WIDTH-1:0]       mshr_txsnp_txnid_sx1_q;
    wire [`CHIE_SNP_FLIT_FWDNID_WIDTH-1:0]      mshr_txsnp_fwdnid_sx1;
    wire [`CHIE_SNP_FLIT_FWDTXNID_WIDTH-1:0]    mshr_txsnp_fwdtxnid_sx1;
    wire [`CHIE_SNP_FLIT_OPCODE_WIDTH-1:0]      mshr_txsnp_opcode_sx1;
    wire [`CHIE_SNP_FLIT_ADDR_WIDTH-1:0]        mshr_txsnp_addr_sx1;
    wire [`CHIE_SNP_FLIT_NS_WIDTH-1:0]          mshr_txsnp_ns_sx1;
    wire [`CHIE_SNP_FLIT_RETTOSRC_WIDTH-1:0]    mshr_txsnp_rettosrc_sx1;
    wire [`CHIE_SNP_FLIT_TRACETAG_WIDTH-1:0]    mshr_txsnp_tracetag_sx1;
    wire [HNF_MSHR_RNF_NUM_PARAM-1:0]           mshr_txsnp_rn_vec_sx1;
    wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]       mshr_txdat_tgtid_sx2;
    wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]       mshr_txdat_txnid_sx2;
    wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]      mshr_txdat_opcode_sx2;
    wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]        mshr_txdat_resp_sx2;
    wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]     mshr_txdat_resperr_sx2;
    wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]        mshr_txdat_dbid_sx2;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]      dbf_txdat_data_sx1;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              dbf_txdat_idx_sx1;
    wire [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]        dbf_txdat_be_sx1;
    wire [1:0]                                  dbf_txdat_pe_sx1;
    wire                                        dbf_txdat_valid_sx1;
    wire                                        li_mshr_rxreq_valid_s0;
    wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]         li_mshr_rxreq_qos_s0;
    wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]       li_mshr_rxreq_srcid_s0;
    wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]       li_mshr_rxreq_txnid_s0;
    wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      li_mshr_rxreq_opcode_s0;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        li_mshr_rxreq_size_s0;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        li_mshr_rxreq_addr_s0;
    wire                                        li_mshr_rxreq_ns_s0;
    wire                                        li_mshr_rxreq_allowretry_s0;
    wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]       li_mshr_rxreq_order_s0;
    wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]    li_mshr_rxreq_pcrdtype_s0;
    wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]     li_mshr_rxreq_memattr_s0;
    wire [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]        li_mshr_rxreq_lpid_s0;
    wire                                        li_mshr_rxreq_excl_s0;
    wire                                        li_mshr_rxreq_expcompack_s0;
    wire                                        li_mshr_rxreq_tracetag_s0;
    wire                                        li_mshr_rxrsp_valid_s0;
    wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]       li_mshr_rxrsp_srcid_s0;
    wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       li_mshr_rxrsp_txnid_s0;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      li_mshr_rxrsp_opcode_s0;
    wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]        li_mshr_rxrsp_resp_s0;
    wire [`CHIE_RSP_FLIT_FWDSTATE_WIDTH-1:0]    li_mshr_rxrsp_fwdstate_s0;
    wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]        li_mshr_rxrsp_dbid_s0;
    wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]    li_mshr_rxrsp_pcrdtype_s0;
    wire                                        li_mshr_rxdat_valid_s0;
    wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]       li_mshr_rxdat_txnid_s0;
    wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]      li_mshr_rxdat_opcode_s0;
    wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]        li_mshr_rxdat_resp_s0;
    wire [`CHIE_DAT_FLIT_FWDSTATE_WIDTH-1:0]    li_mshr_rxdat_fwdstate_s0;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]      li_mshr_rxdat_dataid_s0;
    wire                                        li_dbf_rxdat_valid_s0;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              li_dbf_rxdat_txnid_s0;
    wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]      li_dbf_rxdat_opcode_s0;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]      li_dbf_rxdat_dataid_s0;
    wire [`CHIE_DAT_FLIT_BE_WIDTH-1:0]          li_dbf_rxdat_be_s0;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]        li_dbf_rxdat_data_s0;
    wire                                        txrsp_mshr_retryack_won_s1;
    wire                                        txrsp_mshr_pcrdgnt_won_s2;
    wire                                        txrsp_mshr_won_sx1;
    wire                                        txreq_mshr_won_sx1;
    wire                                        txreq_mshr_bypass_won_s1;
    wire                                        txrsp_mshr_bypass_won_s1;
    wire                                        txsnp_mshr_busy_sx1;
    wire                                        txdat_mshr_clr_dbf_busy_valid_sx3;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              txdat_mshr_clr_dbf_busy_idx_sx3;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              txdat_mshr_rd_idx_sx2;
    wire                                        txdat_mshr_busy_sx;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        pipe_mshr_addr_sx2_q;
    wire                                        pipe_mshr_addr_valid_sx2_q;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              pipe_mshr_addr_idx_sx2_q;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              l3_mshr_entry_sx7_q;
    wire                                        l3_evict_sx7_q;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        l3_evict_addr_sx7_q;
    wire                                        l3_pipeval_sx7_q;
    wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      l3_opcode_sx7_q;
    wire                                        l3_memrd_sx7_q;
    wire                                        l3_hit_sx7_q;
    wire                                        l3_hit_d_sx7_q;
    wire                                        l3_sfhit_sx7_q;
    wire                                        l3_snpdirect_sx7_q;
    wire                                        l3_snpbrd_sx7_q;
    wire [HNF_MSHR_RNF_NUM_PARAM-1:0]           l3_snp_bit_sx7_q;
    wire                                        l3_replay_sx7_q;
    wire                                        l3_mshr_wr_op_sx7_q;
    wire                                        mshr_l3_hazard_valid_sx3_q;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        mshr_l3_addr_sx1;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              mshr_dbf_rd_idx_sx1_q;
    wire                                        mshr_dbf_rd_valid_sx1_q;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              mshr_dbf_retired_idx_sx1_q;
    wire                                        mshr_dbf_retired_valid_sx1_q;
    wire                                        mshr_l3_req_en_sx1_q;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              mshr_l3_entry_idx_sx1_q;
    wire                                        mshr_l3_fill_sx1_q;
    wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      mshr_l3_opcode_sx1_q;
    wire [CHIE_NID_WIDTH_PARAM-1:0]             mshr_l3_rnf_sx1_q;
    wire                                        mshr_l3_fill_dirty_sx1_q;
    wire                                        mshr_l3_seq_retire_sx1_q;
    wire [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0]    loc_rd_clines_q;
    wire [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]      sf_rd_clines_q;
    wire [`LRU_CLINE_WIDTH-1:0]                 lru_rd_data_q;
    wire [`LOC_INDEX_WIDTH-1:0]                 loc_index_q;
    wire                                        loc_rd_en_q;
    wire [`LOC_WAY_NUM-1:0]                     loc_wr_ways_q;
    wire [`LOC_CLINE_WIDTH-1:0]                 loc_wr_cline_q;
    wire [`SF_INDEX_WIDTH-1:0]                  sf_index_q;
    wire                                        sf_rd_en_q;
    wire [`SF_WAY_NUM-1:0]                      sf_wr_ways_q;
    wire [`SF_CLINE_WIDTH-1:0]                  sf_wr_cline_q;
    wire [`LOC_INDEX_WIDTH-1:0]                 l3_index_q;
    wire [`LOC_WAY_NUM-1:0]                     l3_rd_ways_q;
    wire [`LOC_WAY_NUM-1:0]                     l3_wr_ways_q;
    wire [`LOC_INDEX_WIDTH-1:0]                 lru_index_q;
    wire                                        lru_rd_en_q;
    wire                                        lru_wr_en_q;
    wire [`LRU_CLINE_WIDTH-1:0]                 lru_wr_data_q;
    wire [`CACHE_LINE_WIDTH-1:0]                l3_rd_data_q;
    wire [`CACHE_LINE_WIDTH-1:0]                l3_wr_data_q;
    wire [`LOC_INDEX_WIDTH-1:0]                 cpl_l3_index_q;
    wire [`LOC_WAY_NUM-1:0]                     cpl_l3_rd_ways_q;
    wire [`CACHE_LINE_WIDTH-1:0]                dbf_l3_wr_data_q;
    wire [`LOC_WAY_NUM-1:0]                     cpl_l3_wr_ways_q;
    wire [`LOC_INDEX_WIDTH-1:0]                 cpl_loc_index_q;
    wire                                        cpl_loc_rd_en_q;
    wire [`LOC_WAY_NUM-1:0]                     cpl_loc_wr_ways_q;
    wire [`LOC_CLINE_WIDTH-1:0]                 cpl_loc_wr_cline_q;
    wire [`SF_INDEX_WIDTH-1:0]                  cpl_sf_index_q;
    wire                                        cpl_sf_rd_en_q;
    wire [`SF_WAY_NUM-1:0]                      cpl_sf_wr_ways_q;
    wire [`SF_CLINE_WIDTH-1:0]                  cpl_sf_wr_cline_q;
    wire [`LOC_INDEX_WIDTH-1:0]                 cpl_lru_index_q;
    wire                                        cpl_lru_rd_en_q;
    wire                                        cpl_lru_wr_en_q;
    wire [`LRU_CLINE_WIDTH-1:0]                 cpl_lru_wr_data_q;
    wire                                        pipe_dbf_wr_valid_sx9_q;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              pipe_dbf_wr_idx_sx9_q;
    wire                                        pipe_dbf_rd_idx_sx2_valid_q;
    wire [`MSHR_ENTRIES_WIDTH-1:0]              pipe_dbf_rd_idx_sx2_q;

    hnf_link `HNF_PARAM_INST
             u_hnf_link(
                 //inputs
                 .clk                                          (CLK                               ),
                 .rst                                          (RST                               ),
                 .rxreqflitv                                   (RXREQFLITV                        ),
                 .rxreqflit                                    (RXREQFLIT                         ),
                 .rxreqflitpend                                (RXREQFLITPEND                     ),
                 .biq_req_valid_s0_q                           (biq_req_valid_s0_q                ),
                 .biq_req_addr_s0_q                            (biq_req_addr_s0_q                 ),
                 .qos_seq_pool_full_s0_q                       (qos_seq_pool_full_s0_q            ),
                 .rxreq_retry_enable_s0                        (rxreq_retry_enable_s0             ),
                 .rxrspflitv                                   (RXRSPFLITV                        ),
                 .rxrspflit                                    (RXRSPFLIT                         ),
                 .rxrspflitpend                                (RXRSPFLITPEND                     ),
                 .rxdatflitv                                   (RXDATFLITV                        ),
                 .rxdatflit                                    (RXDATFLIT                         ),
                 .rxdatflitpend                                (RXDATFLITPEND                     ),
                 .txreq_lcrdv                                  (TXREQLCRDV                        ),
                 .mshr_txreq_bypass_valid_s1                       (mshr_txreq_bypass_valid_s1            ),
                 .mshr_txreq_bypass_qos_s1                         (mshr_txreq_bypass_qos_s1              ),
                 .mshr_txreq_bypass_txnid_s1                       (mshr_txreq_bypass_txnid_s1            ),
                 .mshr_txreq_bypass_returnnid_s1                   (mshr_txreq_bypass_returnnid_s1        ),
                 .mshr_txreq_bypass_returntxnid_s1                 (mshr_txreq_bypass_returntxnid_s1      ),
                 .mshr_txreq_bypass_opcode_s1                      (mshr_txreq_bypass_opcode_s1           ),
                 .mshr_txreq_bypass_size_s1                        (mshr_txreq_bypass_size_s1             ),
                 .mshr_txreq_bypass_addr_s1                        (mshr_txreq_bypass_addr_s1             ),
                 .mshr_txreq_bypass_ns_s1                          (mshr_txreq_bypass_ns_s1               ),
                 .mshr_txreq_bypass_allowretry_s1                  (mshr_txreq_bypass_allowretry_s1       ),
                 .mshr_txreq_bypass_order_s1                       (mshr_txreq_bypass_order_s1            ),
                 .mshr_txreq_bypass_pcrdtype_s1                    (mshr_txreq_bypass_pcrdtype_s1         ),
                 .mshr_txreq_bypass_memattr_s1                     (mshr_txreq_bypass_memattr_s1          ),
                 .mshr_txreq_bypass_dodwt_s1                       (mshr_txreq_bypass_dodwt_s1            ),
                 .mshr_txreq_bypass_tracetag_s1                    (mshr_txreq_bypass_tracetag_s1         ),
                 .mshr_txreq_valid_sx1_q                       (mshr_txreq_valid_sx1_q            ),
                 .mshr_txreq_qos_sx1                           (mshr_txreq_qos_sx1                ),
                 .mshr_txreq_txnid_sx1_q                       (mshr_txreq_txnid_sx1_q            ),
                 .mshr_txreq_returnnid_sx1                     (mshr_txreq_returnnid_sx1          ),
                 .mshr_txreq_returntxnid_sx1                   (mshr_txreq_returntxnid_sx1        ),
                 .mshr_txreq_opcode_sx1                        (mshr_txreq_opcode_sx1             ),
                 .mshr_txreq_size_sx1                          (mshr_txreq_size_sx1               ),
                 .mshr_txreq_addr_sx1                          (mshr_txreq_addr_sx1               ),
                 .mshr_txreq_ns_sx1                            (mshr_txreq_ns_sx1                 ),
                 .mshr_txreq_allowretry_sx1                    (mshr_txreq_allowretry_sx1         ),
                 .mshr_txreq_order_sx1                         (mshr_txreq_order_sx1              ),
                 .mshr_txreq_pcrdtype_sx1                      (mshr_txreq_pcrdtype_sx1           ),
                 .mshr_txreq_memattr_sx1                       (mshr_txreq_memattr_sx1            ),
                 .mshr_txreq_dodwt_sx1                         (mshr_txreq_dodwt_sx1              ),
                 .mshr_txreq_tracetag_sx1                      (mshr_txreq_tracetag_sx1           ),
                 .txrsp_lcrdv                                  (TXRSPLCRDV                        ),
                 .mshr_txrsp_bypass_valid_s1                       (mshr_txrsp_bypass_valid_s1            ),
                 .mshr_txrsp_bypass_qos_s1                         (mshr_txrsp_bypass_qos_s1              ),
                 .mshr_txrsp_bypass_tgtid_s1                       (mshr_txrsp_bypass_tgtid_s1            ),
                 .mshr_txrsp_bypass_txnid_s1                       (mshr_txrsp_bypass_txnid_s1            ),
                 .mshr_txrsp_bypass_opcode_s1                      (mshr_txrsp_bypass_opcode_s1           ),
                 .mshr_txrsp_bypass_resperr_s1                     (mshr_txrsp_bypass_resperr_s1          ),
                 .mshr_txrsp_bypass_dbid_s1                        (mshr_txrsp_bypass_dbid_s1             ),
                 .mshr_txrsp_bypass_tracetag_s1                    (mshr_txrsp_bypass_tracetag_s1         ),
                 .qos_txrsp_retryack_valid_s1                  (qos_txrsp_retryack_valid_s1       ),
                 .qos_txrsp_retryack_qos_s1                    (qos_txrsp_retryack_qos_s1         ),
                 .qos_txrsp_retryack_tgtid_s1                  (qos_txrsp_retryack_tgtid_s1       ),
                 .qos_txrsp_retryack_txnid_s1                  (qos_txrsp_retryack_txnid_s1       ),
                 .qos_txrsp_retryack_pcrdtype_s1               (qos_txrsp_retryack_pcrdtype_s1    ),
                 .qos_txrsp_retryack_tracetag_s1               (qos_txrsp_retryack_tracetag_s1    ),
                 .qos_txrsp_pcrdgnt_valid_s2                   (qos_txrsp_pcrdgnt_valid_s2        ),
                 .qos_txrsp_pcrdgnt_qos_s2                     (qos_txrsp_pcrdgnt_qos_s2          ),
                 .qos_txrsp_pcrdgnt_tgtid_s2                   (qos_txrsp_pcrdgnt_tgtid_s2        ),
                 .qos_txrsp_pcrdgnt_pcrdtype_s2                (qos_txrsp_pcrdgnt_pcrdtype_s2     ),
                 .mshr_txrsp_valid_sx1_q                       (mshr_txrsp_valid_sx1_q            ),
                 .mshr_txrsp_qos_sx1                           (mshr_txrsp_qos_sx1                ),
                 .mshr_txrsp_tgtid_sx1                         (mshr_txrsp_tgtid_sx1              ),
                 .mshr_txrsp_txnid_sx1_q                       (mshr_txrsp_txnid_sx1_q            ),
                 .mshr_txrsp_opcode_sx1                        (mshr_txrsp_opcode_sx1             ),
                 .mshr_txrsp_resperr_sx1                       (mshr_txrsp_resperr_sx1            ),
                 .mshr_txrsp_resp_sx1                          (mshr_txrsp_resp_sx1               ),
                 .mshr_txrsp_dbid_sx1                          (mshr_txrsp_dbid_sx1               ),
                 .mshr_txrsp_tracetag_sx1                      (mshr_txrsp_tracetag_sx1           ),
                 .txsnp_lcrdv                                  (TXSNPLCRDV                        ),
                 .mshr_txsnp_valid_sx1_q                       (mshr_txsnp_valid_sx1_q            ),
                 .mshr_txsnp_qos_sx1                           (mshr_txsnp_qos_sx1                ),
                 .mshr_txsnp_txnid_sx1_q                       (mshr_txsnp_txnid_sx1_q            ),
                 .mshr_txsnp_fwdnid_sx1                        (mshr_txsnp_fwdnid_sx1             ),
                 .mshr_txsnp_fwdtxnid_sx1                      (mshr_txsnp_fwdtxnid_sx1           ),
                 .mshr_txsnp_opcode_sx1                        (mshr_txsnp_opcode_sx1             ),
                 .mshr_txsnp_addr_sx1                          (mshr_txsnp_addr_sx1               ),
                 .mshr_txsnp_ns_sx1                            (mshr_txsnp_ns_sx1                 ),
                 .mshr_txsnp_rettosrc_sx1                      (mshr_txsnp_rettosrc_sx1           ),
                 .mshr_txsnp_tracetag_sx1                      (mshr_txsnp_tracetag_sx1           ),
                 .mshr_txsnp_rn_vec_sx1                        (mshr_txsnp_rn_vec_sx1             ),
                 .txdat_lcrdv                                  (TXDATLCRDV                        ),
                 .mshr_txdat_tgtid_sx2                         (mshr_txdat_tgtid_sx2              ),
                 .mshr_txdat_txnid_sx2                         (mshr_txdat_txnid_sx2              ),
                 .mshr_txdat_opcode_sx2                        (mshr_txdat_opcode_sx2             ),
                 .mshr_txdat_resp_sx2                          (mshr_txdat_resp_sx2               ),
                 .mshr_txdat_resperr_sx2                       (mshr_txdat_resperr_sx2            ),
                 .mshr_txdat_dbid_sx2                          (mshr_txdat_dbid_sx2               ),
                 .dbf_txdat_data_sx1                           (dbf_txdat_data_sx1                ),
                 .dbf_txdat_idx_sx1                            (dbf_txdat_idx_sx1                 ),
                 .dbf_txdat_be_sx1                             (dbf_txdat_be_sx1                  ),
                 .dbf_txdat_pe_sx1                             (dbf_txdat_pe_sx1                  ),
                 .dbf_txdat_valid_sx1                          (dbf_txdat_valid_sx1               ),

                 //outputs
                 .rxreq_lcrdv                                  (RXREQLCRDV                        ),
                 .li_mshr_rxreq_valid_s0                       (li_mshr_rxreq_valid_s0            ),
                 .li_mshr_rxreq_qos_s0                         (li_mshr_rxreq_qos_s0              ),
                 .li_mshr_rxreq_srcid_s0                       (li_mshr_rxreq_srcid_s0            ),
                 .li_mshr_rxreq_txnid_s0                       (li_mshr_rxreq_txnid_s0            ),
                 .li_mshr_rxreq_opcode_s0                      (li_mshr_rxreq_opcode_s0           ),
                 .li_mshr_rxreq_size_s0                        (li_mshr_rxreq_size_s0             ),
                 .li_mshr_rxreq_addr_s0                        (li_mshr_rxreq_addr_s0             ),
                 .li_mshr_rxreq_ns_s0                          (li_mshr_rxreq_ns_s0               ),
                 .li_mshr_rxreq_allowretry_s0                  (li_mshr_rxreq_allowretry_s0       ),
                 .li_mshr_rxreq_order_s0                       (li_mshr_rxreq_order_s0            ),
                 .li_mshr_rxreq_pcrdtype_s0                    (li_mshr_rxreq_pcrdtype_s0         ),
                 .li_mshr_rxreq_memattr_s0                     (li_mshr_rxreq_memattr_s0          ),
                 .li_mshr_rxreq_lpid_s0                        (li_mshr_rxreq_lpid_s0             ),
                 .li_mshr_rxreq_excl_s0                        (li_mshr_rxreq_excl_s0             ),
                 .li_mshr_rxreq_expcompack_s0                  (li_mshr_rxreq_expcompack_s0       ),
                 .li_mshr_rxreq_tracetag_s0                    (li_mshr_rxreq_tracetag_s0         ),
                 .rxrsp_lcrdv                                  (RXRSPLCRDV                        ),
                 .li_mshr_rxrsp_valid_s0                       (li_mshr_rxrsp_valid_s0            ),
                 .li_mshr_rxrsp_srcid_s0                       (li_mshr_rxrsp_srcid_s0            ),
                 .li_mshr_rxrsp_txnid_s0                       (li_mshr_rxrsp_txnid_s0            ),
                 .li_mshr_rxrsp_opcode_s0                      (li_mshr_rxrsp_opcode_s0           ),
                 .li_mshr_rxrsp_resp_s0                        (li_mshr_rxrsp_resp_s0             ),
                 .li_mshr_rxrsp_fwdstate_s0                    (li_mshr_rxrsp_fwdstate_s0         ),
                 .li_mshr_rxrsp_dbid_s0                        (li_mshr_rxrsp_dbid_s0             ),
                 .li_mshr_rxrsp_pcrdtype_s0                    (li_mshr_rxrsp_pcrdtype_s0         ),
                 .rxdat_lcrdv                                  (RXDATLCRDV                        ),
                 .li_mshr_rxdat_valid_s0                       (li_mshr_rxdat_valid_s0            ),
                 .li_mshr_rxdat_txnid_s0                       (li_mshr_rxdat_txnid_s0            ),
                 .li_mshr_rxdat_opcode_s0                      (li_mshr_rxdat_opcode_s0           ),
                 .li_mshr_rxdat_resp_s0                        (li_mshr_rxdat_resp_s0             ),
                 .li_mshr_rxdat_fwdstate_s0                    (li_mshr_rxdat_fwdstate_s0         ),
                 .li_mshr_rxdat_dataid_s0                      (li_mshr_rxdat_dataid_s0           ),
                 .li_dbf_rxdat_valid_s0                        (li_dbf_rxdat_valid_s0             ),
                 .li_dbf_rxdat_txnid_s0                        (li_dbf_rxdat_txnid_s0             ),
                 .li_dbf_rxdat_opcode_s0                       (li_dbf_rxdat_opcode_s0            ),
                 .li_dbf_rxdat_dataid_s0                       (li_dbf_rxdat_dataid_s0            ),
                 .li_dbf_rxdat_be_s0                           (li_dbf_rxdat_be_s0                ),
                 .li_dbf_rxdat_data_s0                         (li_dbf_rxdat_data_s0              ),
                 .txreqflitv                                   (TXREQFLITV                        ),
                 .txreqflit                                    (TXREQFLIT                         ),
                 .txreqflitpend                                (TXREQFLITPEND                     ),
                 .txrspflitv                                   (TXRSPFLITV                        ),
                 .txrspflit                                    (TXRSPFLIT                         ),
                 .txrspflitpend                                (TXRSPFLITPEND                     ),
                 .txrsp_mshr_retryack_won_s1                   (txrsp_mshr_retryack_won_s1        ),
                 .txrsp_mshr_pcrdgnt_won_s2                    (txrsp_mshr_pcrdgnt_won_s2         ),
                 .txrsp_mshr_won_sx1                           (txrsp_mshr_won_sx1                ),
                 .txreq_mshr_won_sx1                           (txreq_mshr_won_sx1                ),
                 .txreq_mshr_bypass_won_s1                         (txreq_mshr_bypass_won_s1              ),
                 .txrsp_mshr_bypass_won_s1                         (txrsp_mshr_bypass_won_s1              ),
                 .txsnpflitv                                   (TXSNPFLITV                        ),
                 .txsnpflit                                    (TXSNPFLIT                         ),
                 .txsnpflitpend                                (TXSNPFLITPEND                     ),
                 .txsnp_mshr_busy_sx1                          (txsnp_mshr_busy_sx1               ),
                 .txdatflitv                                   (TXDATFLITV                        ),
                 .txdatflit                                    (TXDATFLIT                         ),
                 .txdatflitpend                                (TXDATFLITPEND                     ),
                 .txdat_mshr_clr_dbf_busy_valid_sx3            (txdat_mshr_clr_dbf_busy_valid_sx3 ),
                 .txdat_mshr_clr_dbf_busy_idx_sx3              (txdat_mshr_clr_dbf_busy_idx_sx3   ),
                 .txdat_mshr_rd_idx_sx2                        (txdat_mshr_rd_idx_sx2             ),
                 .txdat_mshr_busy_sx                           (txdat_mshr_busy_sx                )
             );

    hnf_mshr `HNF_PARAM_INST
             u_hnf_mshr(
                 //inputs
                 .clk                                          (CLK                               ),
                 .rst                                          (RST                               ),
                 .li_mshr_rxreq_valid_s0                       (li_mshr_rxreq_valid_s0            ),
                 .li_mshr_rxreq_qos_s0                         (li_mshr_rxreq_qos_s0              ),
                 .li_mshr_rxreq_srcid_s0                       (li_mshr_rxreq_srcid_s0            ),
                 .li_mshr_rxreq_txnid_s0                       (li_mshr_rxreq_txnid_s0            ),
                 .li_mshr_rxreq_opcode_s0                      (li_mshr_rxreq_opcode_s0           ),
                 .li_mshr_rxreq_size_s0                        (li_mshr_rxreq_size_s0             ),
                 .li_mshr_rxreq_addr_s0                        (li_mshr_rxreq_addr_s0             ),
                 .li_mshr_rxreq_ns_s0                          (li_mshr_rxreq_ns_s0               ),
                 .li_mshr_rxreq_allowretry_s0                  (li_mshr_rxreq_allowretry_s0       ),
                 .li_mshr_rxreq_order_s0                       (li_mshr_rxreq_order_s0            ),
                 .li_mshr_rxreq_pcrdtype_s0                    (li_mshr_rxreq_pcrdtype_s0         ),
                 .li_mshr_rxreq_memattr_s0                     (li_mshr_rxreq_memattr_s0          ),
                 .li_mshr_rxreq_lpid_s0                        (li_mshr_rxreq_lpid_s0             ),
                 .li_mshr_rxreq_excl_s0                        (li_mshr_rxreq_excl_s0             ),
                 .li_mshr_rxreq_expcompack_s0                  (li_mshr_rxreq_expcompack_s0       ),
                 .li_mshr_rxreq_tracetag_s0                    (li_mshr_rxreq_tracetag_s0         ),
                 .txrsp_mshr_retryack_won_s1                   (txrsp_mshr_retryack_won_s1        ),
                 .txrsp_mshr_pcrdgnt_won_s2                    (txrsp_mshr_pcrdgnt_won_s2         ),
                 .txreq_mshr_bypass_won_s1                         (txreq_mshr_bypass_won_s1              ),
                 .txrsp_mshr_bypass_won_s1                         (txrsp_mshr_bypass_won_s1              ),
                 .pipe_mshr_addr_sx2_q                         (pipe_mshr_addr_sx2_q              ),
                 .pipe_mshr_addr_valid_sx2_q                   (pipe_mshr_addr_valid_sx2_q        ),
                 .pipe_mshr_addr_idx_sx2_q                     (pipe_mshr_addr_idx_sx2_q          ),
                 .l3_mshr_entry_sx7_q                          (l3_mshr_entry_sx7_q               ),
                 .l3_evict_sx7_q                               (l3_evict_sx7_q                    ),
                 .l3_evict_addr_sx7_q                          (l3_evict_addr_sx7_q               ),
                 .li_mshr_rxdat_valid_s0                       (li_mshr_rxdat_valid_s0            ),
                 .li_mshr_rxdat_txnid_s0                       (li_mshr_rxdat_txnid_s0            ),
                 .li_mshr_rxdat_opcode_s0                      (li_mshr_rxdat_opcode_s0           ),
                 .li_mshr_rxdat_resp_s0                        (li_mshr_rxdat_resp_s0             ),
                 .li_mshr_rxdat_fwdstate_s0                    (li_mshr_rxdat_fwdstate_s0         ),
                 .li_mshr_rxdat_dataid_s0                      (li_mshr_rxdat_dataid_s0           ),
                 .li_mshr_rxrsp_valid_s0                       (li_mshr_rxrsp_valid_s0            ),
                 .li_mshr_rxrsp_srcid_s0                       (li_mshr_rxrsp_srcid_s0            ),
                 .li_mshr_rxrsp_txnid_s0                       (li_mshr_rxrsp_txnid_s0            ),
                 .li_mshr_rxrsp_opcode_s0                      (li_mshr_rxrsp_opcode_s0           ),
                 .li_mshr_rxrsp_resp_s0                        (li_mshr_rxrsp_resp_s0             ),
                 .li_mshr_rxrsp_fwdstate_s0                    (li_mshr_rxrsp_fwdstate_s0         ),
                 .li_mshr_rxrsp_dbid_s0                        (li_mshr_rxrsp_dbid_s0             ),
                 .li_mshr_rxrsp_pcrdtype_s0                    (li_mshr_rxrsp_pcrdtype_s0         ),
                 .txreq_mshr_won_sx1                           (txreq_mshr_won_sx1                ),
                 .txrsp_mshr_won_sx1                           (txrsp_mshr_won_sx1                ),
                 .txsnp_mshr_busy_sx1                          (txsnp_mshr_busy_sx1               ),
                 .txdat_mshr_busy_sx                           (txdat_mshr_busy_sx                ),
                 .txdat_mshr_rd_idx_sx2                        (txdat_mshr_rd_idx_sx2             ),
                 .txdat_mshr_clr_dbf_busy_valid_sx3            (txdat_mshr_clr_dbf_busy_valid_sx3 ),
                 .txdat_mshr_clr_dbf_busy_idx_sx3              (txdat_mshr_clr_dbf_busy_idx_sx3   ),
                 .l3_opcode_sx7_q                              (l3_opcode_sx7_q                   ),
                 .l3_memrd_sx7_q                               (l3_memrd_sx7_q                    ),
                 .l3_hit_sx7_q                                 (l3_hit_sx7_q                      ),
                 .l3_sfhit_sx7_q                               (l3_sfhit_sx7_q                    ),
                 .l3_pipeval_sx7_q                             (l3_pipeval_sx7_q                  ),
                 .l3_mshr_wr_op_sx7_q                          (l3_mshr_wr_op_sx7_q | ~(&notify_reg)),
                 .l3_snpdirect_sx7_q                           (l3_snpdirect_sx7_q                ),
                 .l3_snpbrd_sx7_q                              (l3_snpbrd_sx7_q                   ),
                 .l3_snp_bit_sx7_q                             (l3_snp_bit_sx7_q                  ),
                 .l3_replay_sx7_q                              (l3_replay_sx7_q                   ),
                 .l3_hit_d_sx7_q                               (l3_hit_d_sx7_q                    ),

                 //outputs
                 .mshr_txrsp_bypass_valid_s1                       (mshr_txrsp_bypass_valid_s1            ),
                 .mshr_txrsp_bypass_qos_s1                         (mshr_txrsp_bypass_qos_s1              ),
                 .mshr_txrsp_bypass_tgtid_s1                       (mshr_txrsp_bypass_tgtid_s1            ),
                 .mshr_txrsp_bypass_txnid_s1                       (mshr_txrsp_bypass_txnid_s1            ),
                 .mshr_txrsp_bypass_opcode_s1                      (mshr_txrsp_bypass_opcode_s1           ),
                 .mshr_txrsp_bypass_resperr_s1                     (mshr_txrsp_bypass_resperr_s1          ),
                 .mshr_txrsp_bypass_dbid_s1                        (mshr_txrsp_bypass_dbid_s1             ),
                 .mshr_txrsp_bypass_tracetag_s1                    (mshr_txrsp_bypass_tracetag_s1         ),
                 .mshr_txreq_bypass_valid_s1                       (mshr_txreq_bypass_valid_s1            ),
                 .mshr_txreq_bypass_qos_s1                         (mshr_txreq_bypass_qos_s1              ),
                 .mshr_txreq_bypass_txnid_s1                       (mshr_txreq_bypass_txnid_s1            ),
                 .mshr_txreq_bypass_returnnid_s1                   (mshr_txreq_bypass_returnnid_s1        ),
                 .mshr_txreq_bypass_returntxnid_s1                 (mshr_txreq_bypass_returntxnid_s1      ),
                 .mshr_txreq_bypass_opcode_s1                      (mshr_txreq_bypass_opcode_s1           ),
                 .mshr_txreq_bypass_size_s1                        (mshr_txreq_bypass_size_s1             ),
                 .mshr_txreq_bypass_addr_s1                        (mshr_txreq_bypass_addr_s1             ),
                 .mshr_txreq_bypass_ns_s1                          (mshr_txreq_bypass_ns_s1               ),
                 .mshr_txreq_bypass_allowretry_s1                  (mshr_txreq_bypass_allowretry_s1       ),
                 .mshr_txreq_bypass_order_s1                       (mshr_txreq_bypass_order_s1            ),
                 .mshr_txreq_bypass_pcrdtype_s1                    (mshr_txreq_bypass_pcrdtype_s1         ),
                 .mshr_txreq_bypass_memattr_s1                     (mshr_txreq_bypass_memattr_s1          ),
                 .mshr_txreq_bypass_dodwt_s1                       (mshr_txreq_bypass_dodwt_s1            ),
                 .mshr_txreq_bypass_tracetag_s1                    (mshr_txreq_bypass_tracetag_s1         ),
                 .qos_txrsp_retryack_valid_s1                  (qos_txrsp_retryack_valid_s1       ),
                 .qos_txrsp_retryack_qos_s1                    (qos_txrsp_retryack_qos_s1         ),
                 .qos_txrsp_retryack_tgtid_s1                  (qos_txrsp_retryack_tgtid_s1       ),
                 .qos_txrsp_retryack_txnid_s1                  (qos_txrsp_retryack_txnid_s1       ),
                 .qos_txrsp_retryack_pcrdtype_s1               (qos_txrsp_retryack_pcrdtype_s1    ),
                 .qos_txrsp_retryack_tracetag_s1               (qos_txrsp_retryack_tracetag_s1    ),
                 .qos_txrsp_pcrdgnt_valid_s2                   (qos_txrsp_pcrdgnt_valid_s2        ),
                 .qos_txrsp_pcrdgnt_qos_s2                     (qos_txrsp_pcrdgnt_qos_s2          ),
                 .qos_txrsp_pcrdgnt_tgtid_s2                   (qos_txrsp_pcrdgnt_tgtid_s2        ),
                 .qos_txrsp_pcrdgnt_pcrdtype_s2                (qos_txrsp_pcrdgnt_pcrdtype_s2     ),
                 .rxreq_retry_enable_s0                        (rxreq_retry_enable_s0             ),
                 .qos_seq_pool_full_s0_q                       (qos_seq_pool_full_s0_q            ),
                 .mshr_txsnp_addr_sx1                          (mshr_txsnp_addr_sx1               ),
                 .mshr_txreq_addr_sx1                          (mshr_txreq_addr_sx1               ),
                 .mshr_l3_hazard_valid_sx3_q                   (mshr_l3_hazard_valid_sx3_q        ),
                 .mshr_l3_addr_sx1                             (mshr_l3_addr_sx1                  ),
                 .mshr_dbf_rd_idx_sx1_q                        (mshr_dbf_rd_idx_sx1_q             ),
                 .mshr_dbf_rd_valid_sx1_q                      (mshr_dbf_rd_valid_sx1_q           ),
                 .mshr_dbf_retired_idx_sx1_q                   (mshr_dbf_retired_idx_sx1_q        ),
                 .mshr_dbf_retired_valid_sx1_q                 (mshr_dbf_retired_valid_sx1_q      ),
                 .mshr_txreq_valid_sx1_q                       (mshr_txreq_valid_sx1_q            ),
                 .mshr_txreq_qos_sx1                           (mshr_txreq_qos_sx1                ),
                 .mshr_txreq_txnid_sx1_q                       (mshr_txreq_txnid_sx1_q            ),
                 .mshr_txreq_returnnid_sx1                     (mshr_txreq_returnnid_sx1          ),
                 .mshr_txreq_returntxnid_sx1                   (mshr_txreq_returntxnid_sx1        ),
                 .mshr_txreq_opcode_sx1                        (mshr_txreq_opcode_sx1             ),
                 .mshr_txreq_size_sx1                          (mshr_txreq_size_sx1               ),
                 .mshr_txreq_ns_sx1                            (mshr_txreq_ns_sx1                 ),
                 .mshr_txreq_allowretry_sx1                    (mshr_txreq_allowretry_sx1         ),
                 .mshr_txreq_order_sx1                         (mshr_txreq_order_sx1              ),
                 .mshr_txreq_pcrdtype_sx1                      (mshr_txreq_pcrdtype_sx1           ),
                 .mshr_txreq_memattr_sx1                       (mshr_txreq_memattr_sx1            ),
                 .mshr_txreq_dodwt_sx1                         (mshr_txreq_dodwt_sx1              ),
                 .mshr_txreq_tracetag_sx1                      (mshr_txreq_tracetag_sx1           ),
                 .mshr_txrsp_valid_sx1_q                       (mshr_txrsp_valid_sx1_q            ),
                 .mshr_txrsp_qos_sx1                           (mshr_txrsp_qos_sx1                ),
                 .mshr_txrsp_tgtid_sx1                         (mshr_txrsp_tgtid_sx1              ),
                 .mshr_txrsp_txnid_sx1_q                       (mshr_txrsp_txnid_sx1_q            ),
                 .mshr_txrsp_opcode_sx1                        (mshr_txrsp_opcode_sx1             ),
                 .mshr_txrsp_resperr_sx1                       (mshr_txrsp_resperr_sx1            ),
                 .mshr_txrsp_resp_sx1                          (mshr_txrsp_resp_sx1               ),
                 .mshr_txrsp_dbid_sx1                          (mshr_txrsp_dbid_sx1               ),
                 .mshr_txrsp_tracetag_sx1                      (mshr_txrsp_tracetag_sx1           ),
                 .mshr_txsnp_valid_sx1_q                       (mshr_txsnp_valid_sx1_q            ),
                 .mshr_txsnp_qos_sx1                           (mshr_txsnp_qos_sx1                ),
                 .mshr_txsnp_txnid_sx1_q                       (mshr_txsnp_txnid_sx1_q            ),
                 .mshr_txsnp_fwdnid_sx1                        (mshr_txsnp_fwdnid_sx1             ),
                 .mshr_txsnp_fwdtxnid_sx1                      (mshr_txsnp_fwdtxnid_sx1           ),
                 .mshr_txsnp_opcode_sx1                        (mshr_txsnp_opcode_sx1             ),
                 .mshr_txsnp_ns_sx1                            (mshr_txsnp_ns_sx1                 ),
                 .mshr_txsnp_rettosrc_sx1                      (mshr_txsnp_rettosrc_sx1           ),
                 .mshr_txsnp_tracetag_sx1                      (mshr_txsnp_tracetag_sx1           ),
                 .mshr_txsnp_rn_vec_sx1                        (mshr_txsnp_rn_vec_sx1             ),
                 .mshr_txdat_tgtid_sx2                         (mshr_txdat_tgtid_sx2              ),
                 .mshr_txdat_txnid_sx2                         (mshr_txdat_txnid_sx2              ),
                 .mshr_txdat_opcode_sx2                        (mshr_txdat_opcode_sx2             ),
                 .mshr_txdat_resp_sx2                          (mshr_txdat_resp_sx2               ),
                 .mshr_txdat_resperr_sx2                       (mshr_txdat_resperr_sx2            ),
                 .mshr_txdat_dbid_sx2                          (mshr_txdat_dbid_sx2               ),
                 .mshr_l3_fill_sx1_q                           (mshr_l3_fill_sx1_q                ),
                 .mshr_l3_rnf_sx1_q                            (mshr_l3_rnf_sx1_q                 ),
                 .mshr_l3_seq_retire_sx1_q                     (mshr_l3_seq_retire_sx1_q          ),
                 .mshr_l3_opcode_sx1_q                         (mshr_l3_opcode_sx1_q              ),
                 .mshr_l3_req_en_sx1_q                         (mshr_l3_req_en_sx1_q              ),
                 .mshr_l3_entry_idx_sx1_q                      (mshr_l3_entry_idx_sx1_q           ),
                 .mshr_l3_fill_dirty_sx1_q                     (mshr_l3_fill_dirty_sx1_q          )
             );

    hnf_cache_pipeline `HNF_PARAM_INST
                       u_hnf_cache_pipeline(
                           //inputs
                           .clk                                          (CLK                               ),
                           .rst                                          (RST                               ),
                           .mshr_l3_req_en_sx1_q                         (mshr_l3_req_en_sx1_q & (&notify_reg)),
                           .mshr_l3_addr_sx1                             (mshr_l3_addr_sx1                  ),
                           .mshr_l3_entry_idx_sx1_q                      (mshr_l3_entry_idx_sx1_q           ),
                           .mshr_l3_fill_sx1_q                           (mshr_l3_fill_sx1_q                ),
                           .mshr_l3_opcode_sx1_q                         (mshr_l3_opcode_sx1_q              ),
                           .mshr_l3_rnf_sx1_q                            (mshr_l3_rnf_sx1_q                 ),
                           .mshr_l3_fill_dirty_sx1_q                     (mshr_l3_fill_dirty_sx1_q          ),
                           .mshr_l3_seq_retire_sx1_q                     (mshr_l3_seq_retire_sx1_q          ),
                           .loc_rd_clines_q                              (loc_rd_clines_q                   ),
                           .sf_rd_clines_q                               (sf_rd_clines_q                    ),
                           .lru_rd_data_q                                (lru_rd_data_q                     ),
                           .mshr_l3_hazard_valid_sx3_q                   (mshr_l3_hazard_valid_sx3_q        ),

                           //outputs
                           .loc_index_q                                  (cpl_loc_index_q                   ),
                           .loc_rd_en_q                                  (cpl_loc_rd_en_q                   ),
                           .loc_wr_ways_q                                (cpl_loc_wr_ways_q                 ),
                           .loc_wr_cline_q                               (cpl_loc_wr_cline_q                ),
                           .sf_index_q                                   (cpl_sf_index_q                    ),
                           .sf_rd_en_q                                   (cpl_sf_rd_en_q                    ),
                           .sf_wr_ways_q                                 (cpl_sf_wr_ways_q                  ),
                           .sf_wr_cline_q                                (cpl_sf_wr_cline_q                 ),
                           .l3_index_q                                   (cpl_l3_index_q                    ),
                           .l3_rd_ways_q                                 (cpl_l3_rd_ways_q                  ),
                           .l3_wr_ways_q                                 (cpl_l3_wr_ways_q                  ),
                           .lru_index_q                                  (cpl_lru_index_q                   ),
                           .lru_rd_en_q                                  (cpl_lru_rd_en_q                   ),
                           .lru_wr_en_q                                  (cpl_lru_wr_en_q                   ),
                           .lru_wr_data_q                                (cpl_lru_wr_data_q                 ),
                           .pipe_mshr_addr_sx5_q                         (pipe_mshr_addr_sx2_q              ),
                           .pipe_mshr_addr_valid_sx5_q                   (pipe_mshr_addr_valid_sx2_q        ),
                           .pipe_mshr_addr_idx_sx5_q                     (pipe_mshr_addr_idx_sx2_q          ),
                           .l3_evict_addr_sx7_q                          (l3_evict_addr_sx7_q               ),
                           .l3_evict_sx7_q                               (l3_evict_sx7_q                    ),
                           .l3_mshr_entry_sx7_q                          (l3_mshr_entry_sx7_q               ),
                           .biq_req_valid_s0_q                           (biq_req_valid_s0_q                ),
                           .biq_req_addr_s0_q                            (biq_req_addr_s0_q                 ),
                           .l3_pipeval_sx7_q                             (l3_pipeval_sx7_q                  ),
                           .l3_opcode_sx7_q                              (l3_opcode_sx7_q                   ),
                           .l3_memrd_sx7_q                               (l3_memrd_sx7_q                    ),
                           .l3_hit_sx7_q                                 (l3_hit_sx7_q                      ),
                           .l3_hit_dirty_sx7_q                           (l3_hit_d_sx7_q                    ),
                           .l3_sfhit_sx7_q                               (l3_sfhit_sx7_q                    ),
                           .l3_snpdirect_sx7_q                           (l3_snpdirect_sx7_q                ),
                           .l3_snpbrd_sx7_q                              (l3_snpbrd_sx7_q                   ),
                           .l3_snp_bit_sx7_q                             (l3_snp_bit_sx7_q                  ),
                           .l3_replay_sx7_q                              (l3_replay_sx7_q                   ),
                           .l3_mshr_wr_op_sx7_q                          (l3_mshr_wr_op_sx7_q               ),
                           .pipe_dbf_wr_valid_sx9_q                      (pipe_dbf_wr_valid_sx9_q           ),
                           .pipe_dbf_wr_idx_sx9_q                        (pipe_dbf_wr_idx_sx9_q             ),
                           .pipe_dbf_rd_idx_valid_sx6_q                  (pipe_dbf_rd_idx_sx2_valid_q       ),
                           .pipe_dbf_rd_idx_sx6_q                        (pipe_dbf_rd_idx_sx2_q             )
                       );

    hnf_data_buffer `HNF_PARAM_INST
                    u_hnf_data_buffer(
                        //inputs
                        .clk                                          (CLK                               ),
                        .rst                                          (RST                               ),
                        .li_dbf_rxdat_valid_s0                        (li_dbf_rxdat_valid_s0             ),
                        .li_dbf_rxdat_txnid_s0                        (li_dbf_rxdat_txnid_s0             ),
                        .li_dbf_rxdat_opcode_s0                       (li_dbf_rxdat_opcode_s0            ),
                        .li_dbf_rxdat_dataid_s0                       (li_dbf_rxdat_dataid_s0            ),
                        .li_dbf_rxdat_be_s0                           (li_dbf_rxdat_be_s0                ),
                        .li_dbf_rxdat_data_s0                         (li_dbf_rxdat_data_s0              ),
                        .mshr_dbf_rd_idx_sx1_q                        (mshr_dbf_rd_idx_sx1_q             ),
                        .mshr_dbf_rd_valid_sx1_q                      (mshr_dbf_rd_valid_sx1_q           ),
                        .mshr_dbf_retired_idx_sx1_q                   (mshr_dbf_retired_idx_sx1_q        ),
                        .mshr_dbf_retired_valid_sx1_q                 (mshr_dbf_retired_valid_sx1_q      ),
                        .pipe_dbf_wr_valid_sx9_q                      (pipe_dbf_wr_valid_sx9_q           ),
                        .pipe_dbf_wr_idx_sx9_q                        (pipe_dbf_wr_idx_sx9_q             ),
                        .pipe_dbf_wr_data_sx9_q                       (l3_rd_data_q                      ),
                        .pipe_dbf_rd_idx_sx2_q                        (pipe_dbf_rd_idx_sx2_q             ),
                        .pipe_dbf_rd_idx_sx2_valid_q                  (pipe_dbf_rd_idx_sx2_valid_q       ),

                        //outputs
                        .dbf_pipe_rd_data_sx7_q                       (dbf_l3_wr_data_q                  ),
                        .dbf_txdat_valid_sx1                          (dbf_txdat_valid_sx1               ),
                        .dbf_txdat_idx_sx1                            (dbf_txdat_idx_sx1                 ),
                        .dbf_txdat_be_sx1                             (dbf_txdat_be_sx1                  ),
                        .dbf_txdat_pe_sx1                             (dbf_txdat_pe_sx1                  ),
                        .dbf_txdat_data_sx1                           (dbf_txdat_data_sx1                )
                    );

    hnf_sf_sram `HNF_PARAM_INST
                u_hnf_sf_sram(
                    //inputs
                    .clk                                          (CLK                               ),
                    .rst                                          (RST                               ),
                    .sf_index_q                                   (sf_index_q                        ),
                    .sf_rd_en_q                                   (sf_rd_en_q                        ),
                    .sf_wr_ways_q                                 (sf_wr_ways_q                      ),
                    .sf_wr_cline_q                                (sf_wr_cline_q                     ),
                    //outputs
                    .sf_rd_clines_q                               (sf_rd_clines_q                    )
                );

    hnf_tag_sram `HNF_PARAM_INST
                 u_hnf_tag_sram(
                     //inputs
                     .clk                                          (CLK                               ),
                     .rst                                          (RST                               ),
                     .loc_index_q                                  (loc_index_q                       ),
                     .loc_rd_en_q                                  (loc_rd_en_q                       ),
                     .loc_wr_ways_q                                (loc_wr_ways_q                     ),
                     .loc_wr_cline_q                               (loc_wr_cline_q                    ),
                     //outputs
                     .loc_rd_clines_q                              (loc_rd_clines_q                   )
                 );

    hnf_lru_sram `HNF_PARAM_INST
                 u_hnf_lru_sram(
                     //inputs
                     .clk                                          (CLK                               ),
                     .rst                                          (RST                               ),
                     .lru_index_q                                  (lru_index_q                       ),
                     .lru_rd_en_q                                  (lru_rd_en_q                       ),
                     .lru_wr_en_q                                  (lru_wr_en_q                       ),
                     .lru_wr_data_q                                (lru_wr_data_q                     ),
                     //outputs
                     .lru_rd_data_q                                (lru_rd_data_q                     )
                 );

    hnf_data_sram `HNF_PARAM_INST
                  u_hnf_data_sram(
                      //inputs
                      .clk                                          (CLK                               ),
                      .rst                                          (RST                               ),
                      .l3_index_q                                   (l3_index_q                        ),
                      .l3_rd_ways_q                                 (l3_rd_ways_q                      ),
                      .l3_wr_data_q                                 (l3_wr_data_q                      ),
                      .l3_wr_ways_q                                 (l3_wr_ways_q                      ),
                      //outputs
                      .l3_rd_data_q                                 (l3_rd_data_q                      )
                  );

    hnf_mem_ctl `HNF_PARAM_INST
                u_hnf_mem_ctl(
                    //inputs
                    .clk                                          (CLK                               ),
                    .rst                                          (RST                               ),
                    //ouputs
                    .sf_index_q                                   (sf_index_q                        ),
                    .sf_rd_en_q                                   (sf_rd_en_q                        ),
                    .sf_wr_ways_q                                 (sf_wr_ways_q                      ),
                    .sf_wr_cline_q                                (sf_wr_cline_q                     ),
                    .loc_index_q                                  (loc_index_q                       ),
                    .loc_rd_en_q                                  (loc_rd_en_q                       ),
                    .loc_wr_ways_q                                (loc_wr_ways_q                     ),
                    .loc_wr_cline_q                               (loc_wr_cline_q                    ),
                    .lru_index_q                                  (lru_index_q                       ),
                    .lru_rd_en_q                                  (lru_rd_en_q                       ),
                    .lru_wr_en_q                                  (lru_wr_en_q                       ),
                    .lru_wr_data_q                                (lru_wr_data_q                     ),
                    .l3_index_q                                   (l3_index_q                        ),
                    .l3_rd_ways_q                                 (l3_rd_ways_q                      ),
                    .l3_wr_data_q                                 (l3_wr_data_q                      ),
                    .l3_wr_ways_q                                 (l3_wr_ways_q                      ),
                    .notify_reg                                   (notify_reg                        ),
`ifdef tb_hnf
                    .dbg_l3_valid_q                               (dbg_l3_valid_q                    ),
                    .dbg_l3_index_q                               (dbg_l3_index_q                    ),
                    .dbg_l3_rd_ways_q                             (dbg_l3_rd_ways_q                  ),
                    .dbg_l3_wr_data_q                             (dbg_l3_wr_data_q                  ),
                    .dbg_l3_wr_ways_q                             (dbg_l3_wr_ways_q                  ),
                    .dbg_loc_valid_q                              (dbg_loc_valid_q                   ),
                    .dbg_loc_index_q                              (dbg_loc_index_q                   ),
                    .dbg_loc_rd_en_q                              (dbg_loc_rd_en_q                   ),
                    .dbg_loc_wr_ways_q                            (dbg_loc_wr_ways_q                 ),
                    .dbg_loc_wr_cline_q                           (dbg_loc_wr_cline_q                ),
                    .dbg_sf_valid_q                               (dbg_sf_valid_q                    ),
                    .dbg_sf_index_q                               (dbg_sf_index_q                    ),
                    .dbg_sf_rd_en_q                               (dbg_sf_rd_en_q                    ),
                    .dbg_sf_wr_ways_q                             (dbg_sf_wr_ways_q                  ),
                    .dbg_sf_wr_cline_q                            (dbg_sf_wr_cline_q                 ),
                    .dbg_lru_valid_q                              (dbg_lru_valid_q                   ),
                    .dbg_lru_index_q                              (dbg_lru_index_q                   ),
                    .dbg_lru_rd_en_q                              (dbg_lru_rd_en_q                   ),
                    .dbg_lru_wr_en_q                              (dbg_lru_wr_en_q                   ),
                    .dbg_lru_wr_data_q                            (dbg_lru_wr_data_q                 ),
                    .dbg_l3_rd_data_q                             (dbg_l3_rd_data_q                  ),
                    .dbg_lru_rd_data_q                            (dbg_lru_rd_data_q                 ),
                    .dbg_loc_rd_clines_q                          (dbg_loc_rd_clines_q               ),
                    .dbg_sf_rd_clines_q                           (dbg_sf_rd_clines_q                ),
                    .loc_rd_clines_q                              (loc_rd_clines_q                   ),
                    .sf_rd_clines_q                               (sf_rd_clines_q                    ),
                    .l3_rd_data_q                                 (l3_rd_data_q                      ),
                    .lru_rd_data_q                                (lru_rd_data_q                     ),
`endif
                    .cpl_l3_index_q                               (cpl_l3_index_q                    ),
                    .cpl_l3_rd_ways_q                             (cpl_l3_rd_ways_q                  ),
                    .dbf_l3_wr_data_q                             (dbf_l3_wr_data_q                  ),
                    .cpl_l3_wr_ways_q                             (cpl_l3_wr_ways_q                  ),
                    .cpl_loc_index_q                              (cpl_loc_index_q                   ),
                    .cpl_loc_rd_en_q                              (cpl_loc_rd_en_q                   ),
                    .cpl_loc_wr_ways_q                            (cpl_loc_wr_ways_q                 ),
                    .cpl_loc_wr_cline_q                           (cpl_loc_wr_cline_q                ),
                    .cpl_sf_index_q                               (cpl_sf_index_q                    ),
                    .cpl_sf_rd_en_q                               (cpl_sf_rd_en_q                    ),
                    .cpl_sf_wr_ways_q                             (cpl_sf_wr_ways_q                  ),
                    .cpl_sf_wr_cline_q                            (cpl_sf_wr_cline_q                 ),
                    .cpl_lru_index_q                              (cpl_lru_index_q                   ),
                    .cpl_lru_rd_en_q                              (cpl_lru_rd_en_q                   ),
                    .cpl_lru_wr_en_q                              (cpl_lru_wr_en_q                   ),
                    .cpl_lru_wr_data_q                            (cpl_lru_wr_data_q                 )
                );

endmodule
