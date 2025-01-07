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
*    Jianhong Zhang <zhangjianhong@bosc.ac.cn>
*    Ziqing Li <liziqing@bosc.ac.cn>
*    Jianxing Wang <wangjianxing@bosc.ac.cn>
*    Li Zhao <lizhao@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_mshr `HNF_PARAM
    (
        // 57 inputs + clk + rst
        clk,
        rst,
        li_mshr_rxreq_valid_s0,
        li_mshr_rxreq_qos_s0,
        li_mshr_rxreq_srcid_s0,
        li_mshr_rxreq_txnid_s0,
        li_mshr_rxreq_opcode_s0,
        li_mshr_rxreq_size_s0,
        li_mshr_rxreq_addr_s0,
        li_mshr_rxreq_ns_s0,
        li_mshr_rxreq_allowretry_s0,
        li_mshr_rxreq_order_s0,
        li_mshr_rxreq_pcrdtype_s0,
        li_mshr_rxreq_memattr_s0,
        li_mshr_rxreq_lpid_s0,
        li_mshr_rxreq_excl_s0,
        li_mshr_rxreq_expcompack_s0,
        li_mshr_rxreq_tracetag_s0,
        txrsp_mshr_retryack_won_s1,
        txrsp_mshr_pcrdgnt_won_s2,
        txreq_mshr_bypass_won_s1,
        txrsp_mshr_bypass_won_s1,
        pipe_mshr_addr_sx2_q,
        pipe_mshr_addr_valid_sx2_q,
        pipe_mshr_addr_idx_sx2_q,
        l3_mshr_entry_sx7_q,
        l3_evict_sx7_q,
        l3_evict_addr_sx7_q,
        li_mshr_rxdat_valid_s0,
        li_mshr_rxdat_txnid_s0,
        li_mshr_rxdat_opcode_s0,
        li_mshr_rxdat_resp_s0,
        li_mshr_rxdat_fwdstate_s0,
        li_mshr_rxdat_dataid_s0,
        li_mshr_rxrsp_valid_s0,
        li_mshr_rxrsp_srcid_s0,
        li_mshr_rxrsp_txnid_s0,
        li_mshr_rxrsp_opcode_s0,
        li_mshr_rxrsp_resp_s0,
        li_mshr_rxrsp_fwdstate_s0,
        li_mshr_rxrsp_dbid_s0,
        li_mshr_rxrsp_pcrdtype_s0,
        txreq_mshr_won_sx1,
        txrsp_mshr_won_sx1,
        txsnp_mshr_busy_sx1,
        txdat_mshr_busy_sx,
        txdat_mshr_rd_idx_sx2,
        txdat_mshr_clr_dbf_busy_valid_sx3,
        txdat_mshr_clr_dbf_busy_idx_sx3,
        l3_opcode_sx7_q,
        l3_memrd_sx7_q,
        l3_hit_sx7_q,
        l3_sfhit_sx7_q,
        l3_pipeval_sx7_q,
        l3_mshr_wr_op_sx7_q,
        l3_snpdirect_sx7_q,
        l3_snpbrd_sx7_q,
        l3_snp_bit_sx7_q,
        l3_replay_sx7_q,
        l3_hit_d_sx7_q,

        // 89 outputs
        mshr_txrsp_bypass_valid_s1,
        mshr_txrsp_bypass_qos_s1,
        mshr_txrsp_bypass_tgtid_s1,
        mshr_txrsp_bypass_txnid_s1,
        mshr_txrsp_bypass_opcode_s1,
        mshr_txrsp_bypass_resperr_s1,
        mshr_txrsp_bypass_dbid_s1,
        mshr_txrsp_bypass_tracetag_s1,
        mshr_txreq_bypass_valid_s1,
        mshr_txreq_bypass_qos_s1,
        mshr_txreq_bypass_txnid_s1,
        mshr_txreq_bypass_returnnid_s1,
        mshr_txreq_bypass_returntxnid_s1,
        mshr_txreq_bypass_opcode_s1,
        mshr_txreq_bypass_size_s1,
        mshr_txreq_bypass_addr_s1,
        mshr_txreq_bypass_ns_s1,
        mshr_txreq_bypass_allowretry_s1,
        mshr_txreq_bypass_order_s1,
        mshr_txreq_bypass_pcrdtype_s1,
        mshr_txreq_bypass_memattr_s1,
        mshr_txreq_bypass_dodwt_s1,
        mshr_txreq_bypass_tracetag_s1,
        qos_txrsp_retryack_valid_s1,
        qos_txrsp_retryack_qos_s1,
        qos_txrsp_retryack_tgtid_s1,
        qos_txrsp_retryack_txnid_s1,
        qos_txrsp_retryack_pcrdtype_s1,
        qos_txrsp_retryack_tracetag_s1,
        qos_txrsp_pcrdgnt_valid_s2,
        qos_txrsp_pcrdgnt_qos_s2,
        qos_txrsp_pcrdgnt_tgtid_s2,
        qos_txrsp_pcrdgnt_pcrdtype_s2,
        rxreq_retry_enable_s0,
        qos_seq_pool_full_s0_q,
        mshr_txsnp_addr_sx1,
        mshr_txreq_addr_sx1,
        mshr_l3_hazard_valid_sx3_q,
        mshr_l3_addr_sx1,
        mshr_dbf_rd_idx_sx1_q,
        mshr_dbf_rd_valid_sx1_q,
        mshr_dbf_retired_idx_sx1_q,
        mshr_dbf_retired_valid_sx1_q,
        mshr_txreq_valid_sx1_q,
        mshr_txreq_qos_sx1,
        mshr_txreq_txnid_sx1_q,
        mshr_txreq_returnnid_sx1,
        mshr_txreq_returntxnid_sx1,
        mshr_txreq_opcode_sx1,
        mshr_txreq_size_sx1,
        mshr_txreq_ns_sx1,
        mshr_txreq_allowretry_sx1,
        mshr_txreq_order_sx1,
        mshr_txreq_pcrdtype_sx1,
        mshr_txreq_memattr_sx1,
        mshr_txreq_dodwt_sx1,
        mshr_txreq_tracetag_sx1,
        mshr_txrsp_valid_sx1_q,
        mshr_txrsp_qos_sx1,
        mshr_txrsp_tgtid_sx1,
        mshr_txrsp_txnid_sx1_q,
        mshr_txrsp_opcode_sx1,
        mshr_txrsp_resperr_sx1,
        mshr_txrsp_resp_sx1,
        mshr_txrsp_dbid_sx1,
        mshr_txrsp_tracetag_sx1,
        mshr_txsnp_valid_sx1_q,
        mshr_txsnp_qos_sx1,
        mshr_txsnp_txnid_sx1_q,
        mshr_txsnp_fwdnid_sx1,
        mshr_txsnp_fwdtxnid_sx1,
        mshr_txsnp_opcode_sx1,
        mshr_txsnp_ns_sx1,
        mshr_txsnp_rettosrc_sx1,
        mshr_txsnp_tracetag_sx1,
        mshr_txsnp_rn_vec_sx1,
        mshr_txdat_tgtid_sx2,
        mshr_txdat_txnid_sx2,
        mshr_txdat_opcode_sx2,
        mshr_txdat_resp_sx2,
        mshr_txdat_resperr_sx2,
        mshr_txdat_dbid_sx2,
        mshr_l3_fill_sx1_q,
        mshr_l3_rnf_sx1_q,
        mshr_l3_seq_retire_sx1_q,
        mshr_l3_opcode_sx1_q,
        mshr_l3_req_en_sx1_q,
        mshr_l3_entry_idx_sx1_q,
        mshr_l3_fill_dirty_sx1_q

    );
    //inputs
    input wire                                         clk;
    input wire                                         rst;
    input wire                                         li_mshr_rxreq_valid_s0;
    input wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]          li_mshr_rxreq_qos_s0;
    input wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]        li_mshr_rxreq_srcid_s0;
    input wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]        li_mshr_rxreq_txnid_s0;
    input wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]       li_mshr_rxreq_opcode_s0;
    input wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]         li_mshr_rxreq_size_s0;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]         li_mshr_rxreq_addr_s0;
    input wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]           li_mshr_rxreq_ns_s0;
    input wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0]   li_mshr_rxreq_allowretry_s0;
    input wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]        li_mshr_rxreq_order_s0;
    input wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]     li_mshr_rxreq_pcrdtype_s0;
    input wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]      li_mshr_rxreq_memattr_s0;
    input wire [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]         li_mshr_rxreq_lpid_s0;
    input wire [`CHIE_REQ_FLIT_EXCL_WIDTH-1:0]         li_mshr_rxreq_excl_s0;
    input wire [`CHIE_REQ_FLIT_EXPCOMPACK_WIDTH-1:0]   li_mshr_rxreq_expcompack_s0;
    input wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]     li_mshr_rxreq_tracetag_s0;
    input wire                                         txrsp_mshr_retryack_won_s1;
    input wire                                         txrsp_mshr_pcrdgnt_won_s2;
    input wire                                         txreq_mshr_bypass_won_s1;
    input wire                                         txrsp_mshr_bypass_won_s1;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]         pipe_mshr_addr_sx2_q;
    input wire                                         pipe_mshr_addr_valid_sx2_q;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]               pipe_mshr_addr_idx_sx2_q;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]               l3_mshr_entry_sx7_q;
    input wire                                         l3_evict_sx7_q;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]         l3_evict_addr_sx7_q;
    input wire                                         li_mshr_rxdat_valid_s0;
    input wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]        li_mshr_rxdat_txnid_s0;
    input wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]       li_mshr_rxdat_opcode_s0;
    input wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]         li_mshr_rxdat_resp_s0;
    input wire [`CHIE_DAT_FLIT_FWDSTATE_WIDTH-1:0]     li_mshr_rxdat_fwdstate_s0;
    input wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]       li_mshr_rxdat_dataid_s0;
    input wire                                         li_mshr_rxrsp_valid_s0;
    input wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]        li_mshr_rxrsp_srcid_s0;
    input wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]        li_mshr_rxrsp_txnid_s0;
    input wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]       li_mshr_rxrsp_opcode_s0;
    input wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]         li_mshr_rxrsp_resp_s0;
    input wire [`CHIE_RSP_FLIT_FWDSTATE_WIDTH-1:0]     li_mshr_rxrsp_fwdstate_s0;
    input wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]         li_mshr_rxrsp_dbid_s0;
    input wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]     li_mshr_rxrsp_pcrdtype_s0;
    input wire                                         txreq_mshr_won_sx1;
    input wire                                         txrsp_mshr_won_sx1;
    input wire                                         txsnp_mshr_busy_sx1;
    input wire                                         txdat_mshr_busy_sx;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]               txdat_mshr_rd_idx_sx2;
    input wire                                         txdat_mshr_clr_dbf_busy_valid_sx3;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]               txdat_mshr_clr_dbf_busy_idx_sx3;
    input wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]       l3_opcode_sx7_q;
    input wire                                         l3_memrd_sx7_q;
    input wire                                         l3_hit_sx7_q;
    input wire                                         l3_sfhit_sx7_q;
    input wire                                         l3_pipeval_sx7_q;
    input wire                                         l3_mshr_wr_op_sx7_q;
    input wire                                         l3_snpdirect_sx7_q;
    input wire                                         l3_snpbrd_sx7_q;
    input wire [HNF_MSHR_RNF_NUM_PARAM-1:0]            l3_snp_bit_sx7_q;
    input wire                                         l3_replay_sx7_q;
    input wire                                         l3_hit_d_sx7_q;

    //outputs
    output wire                                        mshr_txrsp_bypass_valid_s1;
    output wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         mshr_txrsp_bypass_qos_s1;
    output wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       mshr_txrsp_bypass_tgtid_s1;
    output wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       mshr_txrsp_bypass_txnid_s1;
    output wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      mshr_txrsp_bypass_opcode_s1;
    output wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]     mshr_txrsp_bypass_resperr_s1;
    output wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]        mshr_txrsp_bypass_dbid_s1;
    output wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    mshr_txrsp_bypass_tracetag_s1;
    output wire                                        mshr_txreq_bypass_valid_s1;
    output wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]         mshr_txreq_bypass_qos_s1;
    output wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]       mshr_txreq_bypass_txnid_s1;
    output wire [`CHIE_REQ_FLIT_RETURNNID_WIDTH-1:0]   mshr_txreq_bypass_returnnid_s1;
    output wire [`CHIE_REQ_FLIT_RETURNTXNID_WIDTH-1:0] mshr_txreq_bypass_returntxnid_s1;
    output wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      mshr_txreq_bypass_opcode_s1;
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        mshr_txreq_bypass_size_s1;
    output wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        mshr_txreq_bypass_addr_s1;
    output wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]          mshr_txreq_bypass_ns_s1;
    output wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0]  mshr_txreq_bypass_allowretry_s1;
    output wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]       mshr_txreq_bypass_order_s1;
    output wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]    mshr_txreq_bypass_pcrdtype_s1;
    output wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]     mshr_txreq_bypass_memattr_s1;
    output wire [`CHIE_REQ_FLIT_DODWT_WIDTH-1:0]       mshr_txreq_bypass_dodwt_s1;
    output wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]    mshr_txreq_bypass_tracetag_s1;
    output wire                                        qos_txrsp_retryack_valid_s1;
    output wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         qos_txrsp_retryack_qos_s1;
    output wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       qos_txrsp_retryack_tgtid_s1;
    output wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       qos_txrsp_retryack_txnid_s1;
    output wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]    qos_txrsp_retryack_pcrdtype_s1;
    output wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    qos_txrsp_retryack_tracetag_s1;
    output wire                                        qos_txrsp_pcrdgnt_valid_s2;
    output wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         qos_txrsp_pcrdgnt_qos_s2;
    output wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       qos_txrsp_pcrdgnt_tgtid_s2;
    output wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]    qos_txrsp_pcrdgnt_pcrdtype_s2;
    output wire                                        rxreq_retry_enable_s0;
    output wire                                        qos_seq_pool_full_s0_q;
    output wire [`CHIE_SNP_FLIT_ADDR_WIDTH-1:0]        mshr_txsnp_addr_sx1;
    output wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        mshr_txreq_addr_sx1;
    output wire                                        mshr_l3_hazard_valid_sx3_q;
    output wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        mshr_l3_addr_sx1;
    output wire [`MSHR_ENTRIES_WIDTH-1:0]              mshr_dbf_rd_idx_sx1_q;
    output wire                                        mshr_dbf_rd_valid_sx1_q;
    output wire [`MSHR_ENTRIES_WIDTH-1:0]              mshr_dbf_retired_idx_sx1_q;
    output wire                                        mshr_dbf_retired_valid_sx1_q;
    output wire                                        mshr_txreq_valid_sx1_q;
    output wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]         mshr_txreq_qos_sx1;
    output wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]       mshr_txreq_txnid_sx1_q;
    output wire [`CHIE_REQ_FLIT_RETURNNID_WIDTH-1:0]   mshr_txreq_returnnid_sx1;
    output wire [`CHIE_REQ_FLIT_RETURNTXNID_WIDTH-1:0] mshr_txreq_returntxnid_sx1;
    output wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      mshr_txreq_opcode_sx1;
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        mshr_txreq_size_sx1;
    output wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]          mshr_txreq_ns_sx1;
    output wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0]  mshr_txreq_allowretry_sx1;
    output wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]       mshr_txreq_order_sx1;
    output wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]    mshr_txreq_pcrdtype_sx1;
    output wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]     mshr_txreq_memattr_sx1;
    output wire [`CHIE_REQ_FLIT_DODWT_WIDTH-1:0]       mshr_txreq_dodwt_sx1;
    output wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]    mshr_txreq_tracetag_sx1;
    output wire                                        mshr_txrsp_valid_sx1_q;
    output wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         mshr_txrsp_qos_sx1;
    output wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       mshr_txrsp_tgtid_sx1;
    output wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       mshr_txrsp_txnid_sx1_q;
    output wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      mshr_txrsp_opcode_sx1;
    output wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]     mshr_txrsp_resperr_sx1;
    output wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]        mshr_txrsp_resp_sx1;
    output wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]        mshr_txrsp_dbid_sx1;
    output wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    mshr_txrsp_tracetag_sx1;
    output wire                                        mshr_txsnp_valid_sx1_q;
    output wire [`CHIE_SNP_FLIT_QOS_WIDTH-1:0]         mshr_txsnp_qos_sx1;
    output wire [`CHIE_SNP_FLIT_TXNID_WIDTH-1:0]       mshr_txsnp_txnid_sx1_q;
    output wire [`CHIE_SNP_FLIT_FWDNID_WIDTH-1:0]      mshr_txsnp_fwdnid_sx1;
    output wire [`CHIE_SNP_FLIT_FWDTXNID_WIDTH-1:0]    mshr_txsnp_fwdtxnid_sx1;
    output wire [`CHIE_SNP_FLIT_OPCODE_WIDTH-1:0]      mshr_txsnp_opcode_sx1;
    output wire [`CHIE_SNP_FLIT_NS_WIDTH-1:0]          mshr_txsnp_ns_sx1;
    output wire [`CHIE_SNP_FLIT_RETTOSRC_WIDTH-1:0]    mshr_txsnp_rettosrc_sx1;
    output wire [`CHIE_SNP_FLIT_TRACETAG_WIDTH-1:0]    mshr_txsnp_tracetag_sx1;
    output wire [HNF_MSHR_RNF_NUM_PARAM-1:0]           mshr_txsnp_rn_vec_sx1;
    output wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]       mshr_txdat_tgtid_sx2;
    output wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]       mshr_txdat_txnid_sx2;
    output wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]      mshr_txdat_opcode_sx2;
    output wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]        mshr_txdat_resp_sx2;
    output wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]     mshr_txdat_resperr_sx2;
    output wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]        mshr_txdat_dbid_sx2;
    output wire                                        mshr_l3_fill_sx1_q;
    output wire [CHIE_NID_WIDTH_PARAM-1:0]             mshr_l3_rnf_sx1_q;
    output wire                                        mshr_l3_seq_retire_sx1_q;
    output wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      mshr_l3_opcode_sx1_q;
    output wire                                        mshr_l3_req_en_sx1_q;
    output wire [`MSHR_ENTRIES_WIDTH-1:0]              mshr_l3_entry_idx_sx1_q;
    output wire                                        mshr_l3_fill_dirty_sx1_q;

    //wires
    wire [`MSHR_ENTRIES_WIDTH-1:0]                     mshr_entry_idx_alloc_s0;
    wire [`MSHR_ENTRIES_WIDTH-1:0]                     mshr_entry_idx_alloc_s1_q;
    wire [`MSHR_ENTRIES_NUM-1:0]                       mshr_entry_alloc_s1_q;
    wire                                               mshr_alloc_en_s0;
    wire                                               mshr_alloc_en_s1_q;
    wire                                               rxreq_cam_hazard_s1_q;
    wire [`MSHR_ENTRIES_NUM-1:0]                       rxreq_cam_hazard_entry_s1_q;
    wire                                               excl_pass_s1;
    wire                                               excl_fail_s1;
    wire [`MSHR_ENTRIES_NUM-1:0]                       pipe_cam_hazard_entry_sx3_q;
    wire [`MSHR_ENTRIES_NUM-1:0]                       pipe_sleep_entry_sx3_q;
    wire                                               txreq_mshr_bypass_lost_s1;
    wire                                               txrsp_mshr_bypass_lost_s1;

    hnf_mshr_bypass `HNF_PARAM_INST
                    u_hnf_mshr_bypass(
                        .clk                                             (clk                                  ),
                        .rst                                             (rst                                  ),
                        .li_mshr_rxreq_valid_s0                          (li_mshr_rxreq_valid_s0               ),
                        .li_mshr_rxreq_qos_s0                            (li_mshr_rxreq_qos_s0                 ),
                        .li_mshr_rxreq_srcid_s0                          (li_mshr_rxreq_srcid_s0               ),
                        .li_mshr_rxreq_txnid_s0                          (li_mshr_rxreq_txnid_s0               ),
                        .li_mshr_rxreq_opcode_s0                         (li_mshr_rxreq_opcode_s0              ),
                        .li_mshr_rxreq_size_s0                           (li_mshr_rxreq_size_s0                ),
                        .li_mshr_rxreq_addr_s0                           (li_mshr_rxreq_addr_s0                ),
                        .li_mshr_rxreq_ns_s0                             (li_mshr_rxreq_ns_s0                  ),
                        .li_mshr_rxreq_order_s0                          (li_mshr_rxreq_order_s0               ),
                        .li_mshr_rxreq_pcrdtype_s0                       (li_mshr_rxreq_pcrdtype_s0            ),
                        .li_mshr_rxreq_memattr_s0                        (li_mshr_rxreq_memattr_s0             ),
                        .li_mshr_rxreq_excl_s0                           (li_mshr_rxreq_excl_s0                ),
                        .li_mshr_rxreq_expcompack_s0                     (li_mshr_rxreq_expcompack_s0          ),
                        .li_mshr_rxreq_tracetag_s0                       (li_mshr_rxreq_tracetag_s0            ),
                        .mshr_entry_idx_alloc_s1_q                       (mshr_entry_idx_alloc_s1_q            ),
                        .mshr_alloc_en_s0                                (mshr_alloc_en_s0                     ),
                        .rxreq_cam_hazard_s1_q                           (rxreq_cam_hazard_s1_q                ),
                        .excl_pass_s1                                    (excl_pass_s1                         ),
                        .excl_fail_s1                                    (excl_fail_s1                         ),
                        .txreq_mshr_bypass_won_s1                        (txreq_mshr_bypass_won_s1             ),
                        .txrsp_mshr_bypass_won_s1                        (txrsp_mshr_bypass_won_s1             ),
                        .mshr_txrsp_bypass_valid_s1                      (mshr_txrsp_bypass_valid_s1           ),
                        .mshr_txrsp_bypass_qos_s1                        (mshr_txrsp_bypass_qos_s1             ),
                        .mshr_txrsp_bypass_tgtid_s1                      (mshr_txrsp_bypass_tgtid_s1           ),
                        .mshr_txrsp_bypass_txnid_s1                      (mshr_txrsp_bypass_txnid_s1           ),
                        .mshr_txrsp_bypass_opcode_s1                     (mshr_txrsp_bypass_opcode_s1          ),
                        .mshr_txrsp_bypass_resperr_s1                    (mshr_txrsp_bypass_resperr_s1         ),
                        .mshr_txrsp_bypass_dbid_s1                       (mshr_txrsp_bypass_dbid_s1            ),
                        .mshr_txrsp_bypass_tracetag_s1                   (mshr_txrsp_bypass_tracetag_s1        ),
                        .mshr_txreq_bypass_valid_s1                      (mshr_txreq_bypass_valid_s1           ),
                        .mshr_txreq_bypass_qos_s1                        (mshr_txreq_bypass_qos_s1             ),
                        .mshr_txreq_bypass_txnid_s1                      (mshr_txreq_bypass_txnid_s1           ),
                        .mshr_txreq_bypass_returnnid_s1                  (mshr_txreq_bypass_returnnid_s1       ),
                        .mshr_txreq_bypass_returntxnid_s1                (mshr_txreq_bypass_returntxnid_s1     ),
                        .mshr_txreq_bypass_opcode_s1                     (mshr_txreq_bypass_opcode_s1          ),
                        .mshr_txreq_bypass_size_s1                       (mshr_txreq_bypass_size_s1            ),
                        .mshr_txreq_bypass_addr_s1                       (mshr_txreq_bypass_addr_s1            ),
                        .mshr_txreq_bypass_ns_s1                         (mshr_txreq_bypass_ns_s1              ),
                        .mshr_txreq_bypass_allowretry_s1                 (mshr_txreq_bypass_allowretry_s1      ),
                        .mshr_txreq_bypass_order_s1                      (mshr_txreq_bypass_order_s1           ),
                        .mshr_txreq_bypass_pcrdtype_s1                   (mshr_txreq_bypass_pcrdtype_s1        ),
                        .mshr_txreq_bypass_memattr_s1                    (mshr_txreq_bypass_memattr_s1         ),
                        .mshr_txreq_bypass_dodwt_s1                      (mshr_txreq_bypass_dodwt_s1           ),
                        .mshr_txreq_bypass_tracetag_s1                   (mshr_txreq_bypass_tracetag_s1        ),
                        .txreq_mshr_bypass_lost_s1                       (txreq_mshr_bypass_lost_s1            ),
                        .txrsp_mshr_bypass_lost_s1                       (txrsp_mshr_bypass_lost_s1            )
                    );

    hnf_mshr_global_monitor `HNF_PARAM_INST
                            u_hnf_mshr_global_monitor(
                                .clk                                             (clk                               ),
                                .rst                                             (rst                               ),
                                .mshr_alloc_en_s0                                (mshr_alloc_en_s0                  ),
                                .li_mshr_rxreq_valid_s0                          (li_mshr_rxreq_valid_s0            ),
                                .li_mshr_rxreq_srcid_s0                          (li_mshr_rxreq_srcid_s0            ),
                                .li_mshr_rxreq_opcode_s0                         (li_mshr_rxreq_opcode_s0           ),
                                .li_mshr_rxreq_addr_s0                           (li_mshr_rxreq_addr_s0             ),
                                .li_mshr_rxreq_ns_s0                             (li_mshr_rxreq_ns_s0               ),
                                .li_mshr_rxreq_lpid_s0                           (li_mshr_rxreq_lpid_s0             ),
                                .li_mshr_rxreq_excl_s0                           (li_mshr_rxreq_excl_s0             ),
                                .excl_pass_s1                                    (excl_pass_s1                      ),
                                .excl_fail_s1                                    (excl_fail_s1                      )
                            );

    hnf_mshr_qos `HNF_PARAM_INST
                 u_hnf_mshr_qos(
                     .clk                                             (clk                               ),
                     .rst                                             (rst                               ),
                     .txrsp_mshr_retryack_won_s1                      (txrsp_mshr_retryack_won_s1        ),
                     .txrsp_mshr_pcrdgnt_won_s2                       (txrsp_mshr_pcrdgnt_won_s2         ),
                     .li_mshr_rxreq_valid_s0                          (li_mshr_rxreq_valid_s0            ),
                     .li_mshr_rxreq_qos_s0                            (li_mshr_rxreq_qos_s0              ),
                     .li_mshr_rxreq_srcid_s0                          (li_mshr_rxreq_srcid_s0            ),
                     .li_mshr_rxreq_txnid_s0                          (li_mshr_rxreq_txnid_s0            ),
                     .li_mshr_rxreq_opcode_s0                         (li_mshr_rxreq_opcode_s0           ),
                     .li_mshr_rxreq_allowretry_s0                     (li_mshr_rxreq_allowretry_s0       ),
                     .li_mshr_rxreq_tracetag_s0                       (li_mshr_rxreq_tracetag_s0         ),
                     .mshr_dbf_retired_valid_sx1_q                    (mshr_dbf_retired_valid_sx1_q      ),
                     .mshr_dbf_retired_idx_sx1_q                      (mshr_dbf_retired_idx_sx1_q        ),
                     .qos_txrsp_retryack_valid_s1                     (qos_txrsp_retryack_valid_s1       ),
                     .qos_txrsp_retryack_qos_s1                       (qos_txrsp_retryack_qos_s1         ),
                     .qos_txrsp_retryack_tgtid_s1                     (qos_txrsp_retryack_tgtid_s1       ),
                     .qos_txrsp_retryack_txnid_s1                     (qos_txrsp_retryack_txnid_s1       ),
                     .qos_txrsp_retryack_pcrdtype_s1                  (qos_txrsp_retryack_pcrdtype_s1    ),
                     .qos_txrsp_retryack_tracetag_s1                  (qos_txrsp_retryack_tracetag_s1    ),
                     .qos_txrsp_pcrdgnt_valid_s2                      (qos_txrsp_pcrdgnt_valid_s2        ),
                     .qos_txrsp_pcrdgnt_qos_s2                        (qos_txrsp_pcrdgnt_qos_s2          ),
                     .qos_txrsp_pcrdgnt_tgtid_s2                      (qos_txrsp_pcrdgnt_tgtid_s2        ),
                     .qos_txrsp_pcrdgnt_pcrdtype_s2                   (qos_txrsp_pcrdgnt_pcrdtype_s2     ),
                     .rxreq_retry_enable_s0                           (rxreq_retry_enable_s0             ),
                     .qos_seq_pool_full_s0_q                          (qos_seq_pool_full_s0_q            ),
                     .mshr_alloc_en_s0                                (mshr_alloc_en_s0                  ),
                     .mshr_alloc_en_s1_q                              (mshr_alloc_en_s1_q                ),
                     .mshr_entry_idx_alloc_s0                         (mshr_entry_idx_alloc_s0           ),
                     .mshr_entry_idx_alloc_s1_q                       (mshr_entry_idx_alloc_s1_q         ),
                     .mshr_entry_alloc_s1_q                           (mshr_entry_alloc_s1_q             )
                 );

    hnf_mshr_addr_buffer `HNF_PARAM_INST
                         u_hnf_mshr_addr_buffer(
                             .clk                                             (clk                               ),
                             .rst                                             (rst                               ),
                             .li_mshr_rxreq_valid_s0                          (li_mshr_rxreq_valid_s0            ),
                             .li_mshr_rxreq_addr_s0                           (li_mshr_rxreq_addr_s0             ),
                             .mshr_alloc_en_s1_q                              (mshr_alloc_en_s1_q                ),
                             .mshr_entry_idx_alloc_s1_q                       (mshr_entry_idx_alloc_s1_q         ),
                             .mshr_entry_alloc_s1_q                           (mshr_entry_alloc_s1_q             ),
                             .mshr_txsnp_rd_idx_sx1_q                         (mshr_txsnp_txnid_sx1_q            ),
                             .mshr_txreq_rd_idx_sx1_q                         (mshr_txreq_txnid_sx1_q            ),
                             .mshr_dbf_retired_idx_sx1_q                      (mshr_dbf_retired_idx_sx1_q        ),
                             .mshr_dbf_retired_valid_sx1_q                    (mshr_dbf_retired_valid_sx1_q      ),
                             .pipe_mshr_addr_sx2_q                            (pipe_mshr_addr_sx2_q              ),
                             .pipe_mshr_addr_valid_sx2_q                      (pipe_mshr_addr_valid_sx2_q        ),
                             .pipe_mshr_addr_idx_sx2_q                        (pipe_mshr_addr_idx_sx2_q          ),
                             .l3_mshr_entry_sx7_q                             (l3_mshr_entry_sx7_q               ),
                             .l3_evict_sx7_q                                  (l3_evict_sx7_q                    ),
                             .l3_evict_addr_sx7_q                             (l3_evict_addr_sx7_q               ),
                             .mshr_l3_entry_idx_sx1_q                         (mshr_l3_entry_idx_sx1_q           ),
                             .rxreq_cam_hazard_s1_q                           (rxreq_cam_hazard_s1_q             ),
                             .rxreq_cam_hazard_entry_s1_q                     (rxreq_cam_hazard_entry_s1_q       ),
                             .mshr_txsnp_addr_sx1                             (mshr_txsnp_addr_sx1               ),
                             .mshr_txreq_addr_sx1                             (mshr_txreq_addr_sx1               ),
                             .pipe_cam_hazard_entry_sx3_q                     (pipe_cam_hazard_entry_sx3_q       ),
                             .pipe_sleep_entry_sx3_q                          (pipe_sleep_entry_sx3_q            ),
                             .mshr_l3_hazard_valid_sx3_q                      (mshr_l3_hazard_valid_sx3_q        ),
                             .mshr_l3_addr_sx1                                (mshr_l3_addr_sx1                  )
                         );

    hnf_mshr_ctl `HNF_PARAM_INST
                 u_hnf_mshr_ctl(
                     .clk                                             (clk                               ),
                     .rst                                             (rst                               ),
                     .li_mshr_rxreq_valid_s0                          (li_mshr_rxreq_valid_s0            ),
                     .li_mshr_rxreq_qos_s0                            (li_mshr_rxreq_qos_s0              ),
                     .li_mshr_rxreq_srcid_s0                          (li_mshr_rxreq_srcid_s0            ),
                     .li_mshr_rxreq_txnid_s0                          (li_mshr_rxreq_txnid_s0            ),
                     .li_mshr_rxreq_opcode_s0                         (li_mshr_rxreq_opcode_s0           ),
                     .li_mshr_rxreq_size_s0                           (li_mshr_rxreq_size_s0             ),
                     .li_mshr_rxreq_addr_s0                           (li_mshr_rxreq_addr_s0             ),
                     .li_mshr_rxreq_ns_s0                             (li_mshr_rxreq_ns_s0               ),
                     .li_mshr_rxreq_allowretry_s0                     (li_mshr_rxreq_allowretry_s0       ),
                     .li_mshr_rxreq_order_s0                          (li_mshr_rxreq_order_s0            ),
                     .li_mshr_rxreq_pcrdtype_s0                       (li_mshr_rxreq_pcrdtype_s0         ),
                     .li_mshr_rxreq_memattr_s0                        (li_mshr_rxreq_memattr_s0          ),
                     .li_mshr_rxreq_lpid_s0                           (li_mshr_rxreq_lpid_s0             ),
                     .li_mshr_rxreq_excl_s0                           (li_mshr_rxreq_excl_s0             ),
                     .li_mshr_rxreq_expcompack_s0                     (li_mshr_rxreq_expcompack_s0       ),
                     .li_mshr_rxreq_tracetag_s0                       (li_mshr_rxreq_tracetag_s0         ),
                     .li_mshr_rxdat_valid_s0                          (li_mshr_rxdat_valid_s0            ),
                     .li_mshr_rxdat_txnid_s0                          (li_mshr_rxdat_txnid_s0            ),
                     .li_mshr_rxdat_opcode_s0                         (li_mshr_rxdat_opcode_s0           ),
                     .li_mshr_rxdat_resp_s0                           (li_mshr_rxdat_resp_s0             ),
                     .li_mshr_rxdat_fwdstate_s0                       (li_mshr_rxdat_fwdstate_s0         ),
                     .li_mshr_rxdat_dataid_s0                         (li_mshr_rxdat_dataid_s0           ),
                     .li_mshr_rxrsp_valid_s0                          (li_mshr_rxrsp_valid_s0            ),
                     .li_mshr_rxrsp_srcid_s0                          (li_mshr_rxrsp_srcid_s0            ),
                     .li_mshr_rxrsp_txnid_s0                          (li_mshr_rxrsp_txnid_s0            ),
                     .li_mshr_rxrsp_opcode_s0                         (li_mshr_rxrsp_opcode_s0           ),
                     .li_mshr_rxrsp_resp_s0                           (li_mshr_rxrsp_resp_s0             ),
                     .li_mshr_rxrsp_fwdstate_s0                       (li_mshr_rxrsp_fwdstate_s0         ),
                     .li_mshr_rxrsp_dbid_s0                           (li_mshr_rxrsp_dbid_s0             ),
                     .li_mshr_rxrsp_pcrdtype_s0                       (li_mshr_rxrsp_pcrdtype_s0         ),
                     .excl_pass_s1                                    (excl_pass_s1                      ),
                     .excl_fail_s1                                    (excl_fail_s1                      ),
                     .txreq_mshr_bypass_lost_s1                           (txreq_mshr_bypass_lost_s1             ),
                     .txrsp_mshr_bypass_lost_s1                           (txrsp_mshr_bypass_lost_s1             ),
                     .mshr_alloc_en_s0                                (mshr_alloc_en_s0                  ),
                     .mshr_alloc_en_s1_q                              (mshr_alloc_en_s1_q                ),
                     .mshr_entry_idx_alloc_s0                         (mshr_entry_idx_alloc_s0           ),
                     .mshr_entry_idx_alloc_s1_q                       (mshr_entry_idx_alloc_s1_q         ),
                     .rxreq_cam_hazard_s1_q                           (rxreq_cam_hazard_s1_q             ),
                     .rxreq_cam_hazard_entry_s1_q                     (rxreq_cam_hazard_entry_s1_q       ),
                     .mshr_l3_hazard_valid_sx3_q                      (mshr_l3_hazard_valid_sx3_q        ),
                     .pipe_cam_hazard_entry_sx3_q                     (pipe_cam_hazard_entry_sx3_q       ),
                     .pipe_sleep_entry_sx3_q                          (pipe_sleep_entry_sx3_q            ),
                     .txreq_mshr_won_sx1                              (txreq_mshr_won_sx1                ),
                     .txrsp_mshr_won_sx1                              (txrsp_mshr_won_sx1                ),
                     .txsnp_mshr_busy_sx1                             (txsnp_mshr_busy_sx1               ),
                     .txdat_mshr_busy_sx                              (txdat_mshr_busy_sx                ),
                     .txdat_mshr_rd_idx_sx2                           (txdat_mshr_rd_idx_sx2             ),
                     .txdat_mshr_clr_dbf_busy_valid_sx3               (txdat_mshr_clr_dbf_busy_valid_sx3 ),
                     .txdat_mshr_clr_dbf_busy_idx_sx3                 (txdat_mshr_clr_dbf_busy_idx_sx3   ),
                     .l3_opcode_sx7_q                                 (l3_opcode_sx7_q                   ),
                     .l3_mshr_entry_sx7_q                             (l3_mshr_entry_sx7_q               ),
                     .l3_memrd_sx7_q                                  (l3_memrd_sx7_q                    ),
                     .l3_hit_sx7_q                                    (l3_hit_sx7_q                      ),
                     .l3_sfhit_sx7_q                                  (l3_sfhit_sx7_q                    ),
                     .l3_pipeval_sx7_q                                (l3_pipeval_sx7_q                  ),
                     .l3_mshr_wr_op_sx7_q                             (l3_mshr_wr_op_sx7_q               ),
                     .l3_snpdirect_sx7_q                              (l3_snpdirect_sx7_q                ),
                     .l3_snpbrd_sx7_q                                 (l3_snpbrd_sx7_q                   ),
                     .l3_snp_bit_sx7_q                                (l3_snp_bit_sx7_q                  ),
                     .l3_replay_sx7_q                                 (l3_replay_sx7_q                   ),
                     .l3_hit_d_sx7_q                                  (l3_hit_d_sx7_q                    ),
                     .l3_evict_sx7_q                                  (l3_evict_sx7_q                    ),
                     .mshr_dbf_rd_idx_sx1_q                           (mshr_dbf_rd_idx_sx1_q             ),
                     .mshr_dbf_rd_valid_sx1_q                         (mshr_dbf_rd_valid_sx1_q           ),
                     .mshr_dbf_retired_idx_sx1_q                      (mshr_dbf_retired_idx_sx1_q        ),
                     .mshr_dbf_retired_valid_sx1_q                    (mshr_dbf_retired_valid_sx1_q      ),
                     .mshr_txreq_valid_sx1_q                          (mshr_txreq_valid_sx1_q            ),
                     .mshr_txreq_qos_sx1                              (mshr_txreq_qos_sx1                ),
                     .mshr_txreq_txnid_sx1_q                          (mshr_txreq_txnid_sx1_q            ),
                     .mshr_txreq_returnnid_sx1                        (mshr_txreq_returnnid_sx1          ),
                     .mshr_txreq_returntxnid_sx1                      (mshr_txreq_returntxnid_sx1        ),
                     .mshr_txreq_opcode_sx1                           (mshr_txreq_opcode_sx1             ),
                     .mshr_txreq_size_sx1                             (mshr_txreq_size_sx1               ),
                     .mshr_txreq_ns_sx1                               (mshr_txreq_ns_sx1                 ),
                     .mshr_txreq_allowretry_sx1                       (mshr_txreq_allowretry_sx1         ),
                     .mshr_txreq_order_sx1                            (mshr_txreq_order_sx1              ),
                     .mshr_txreq_pcrdtype_sx1                         (mshr_txreq_pcrdtype_sx1           ),
                     .mshr_txreq_memattr_sx1                          (mshr_txreq_memattr_sx1            ),
                     .mshr_txreq_dodwt_sx1                            (mshr_txreq_dodwt_sx1              ),
                     .mshr_txreq_tracetag_sx1                         (mshr_txreq_tracetag_sx1           ),
                     .mshr_txrsp_valid_sx1_q                          (mshr_txrsp_valid_sx1_q            ),
                     .mshr_txrsp_qos_sx1                              (mshr_txrsp_qos_sx1                ),
                     .mshr_txrsp_tgtid_sx1                            (mshr_txrsp_tgtid_sx1              ),
                     .mshr_txrsp_txnid_sx1_q                          (mshr_txrsp_txnid_sx1_q            ),
                     .mshr_txrsp_opcode_sx1                           (mshr_txrsp_opcode_sx1             ),
                     .mshr_txrsp_resperr_sx1                          (mshr_txrsp_resperr_sx1            ),
                     .mshr_txrsp_resp_sx1                             (mshr_txrsp_resp_sx1               ),
                     .mshr_txrsp_dbid_sx1                             (mshr_txrsp_dbid_sx1               ),
                     .mshr_txrsp_tracetag_sx1                         (mshr_txrsp_tracetag_sx1           ),
                     .mshr_txsnp_valid_sx1_q                          (mshr_txsnp_valid_sx1_q            ),
                     .mshr_txsnp_qos_sx1                              (mshr_txsnp_qos_sx1                ),
                     .mshr_txsnp_txnid_sx1_q                          (mshr_txsnp_txnid_sx1_q            ),
                     .mshr_txsnp_fwdnid_sx1                           (mshr_txsnp_fwdnid_sx1             ),
                     .mshr_txsnp_fwdtxnid_sx1                         (mshr_txsnp_fwdtxnid_sx1           ),
                     .mshr_txsnp_opcode_sx1                           (mshr_txsnp_opcode_sx1             ),
                     .mshr_txsnp_ns_sx1                               (mshr_txsnp_ns_sx1                 ),
                     .mshr_txsnp_rettosrc_sx1                         (mshr_txsnp_rettosrc_sx1           ),
                     .mshr_txsnp_tracetag_sx1                         (mshr_txsnp_tracetag_sx1           ),
                     .mshr_txsnp_rn_vec_sx1                           (mshr_txsnp_rn_vec_sx1             ),
                     .mshr_txdat_tgtid_sx2                            (mshr_txdat_tgtid_sx2              ),
                     .mshr_txdat_txnid_sx2                            (mshr_txdat_txnid_sx2              ),
                     .mshr_txdat_opcode_sx2                           (mshr_txdat_opcode_sx2             ),
                     .mshr_txdat_resp_sx2                             (mshr_txdat_resp_sx2               ),
                     .mshr_txdat_resperr_sx2                          (mshr_txdat_resperr_sx2            ),
                     .mshr_txdat_dbid_sx2                             (mshr_txdat_dbid_sx2               ),
                     .mshr_l3_fill_sx1_q                              (mshr_l3_fill_sx1_q                ),
                     .mshr_l3_rnf_sx1_q                               (mshr_l3_rnf_sx1_q                 ),
                     .mshr_l3_seq_retire_sx1_q                        (mshr_l3_seq_retire_sx1_q          ),
                     .mshr_l3_opcode_sx1_q                            (mshr_l3_opcode_sx1_q              ),
                     .mshr_l3_req_en_sx1_q                            (mshr_l3_req_en_sx1_q              ),
                     .mshr_l3_entry_idx_sx1_q                         (mshr_l3_entry_idx_sx1_q           ),
                     .mshr_l3_fill_dirty_sx1_q                        (mshr_l3_fill_dirty_sx1_q          )
                 );


endmodule
