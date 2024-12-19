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

module hnf_link `HNF_PARAM
    (
        // 95 inputs + clk + rst
        clk,
        rst,
        rxreqflitv,
        rxreqflit,
        rxreqflitpend,
        biq_req_valid_s0_q,
        biq_req_addr_s0_q,
        qos_seq_pool_full_s0_q,
        rxreq_retry_enable_s0,
        rxrspflitv,
        rxrspflit,
        rxrspflitpend,
        rxdatflitv,
        rxdatflit,
        rxdatflitpend,
        txreq_lcrdv,
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
        mshr_txreq_valid_sx1_q,
        mshr_txreq_qos_sx1,
        mshr_txreq_txnid_sx1_q,
        mshr_txreq_returnnid_sx1,
        mshr_txreq_returntxnid_sx1,
        mshr_txreq_opcode_sx1,
        mshr_txreq_size_sx1,
        mshr_txreq_addr_sx1,
        mshr_txreq_ns_sx1,
        mshr_txreq_allowretry_sx1,
        mshr_txreq_order_sx1,
        mshr_txreq_pcrdtype_sx1,
        mshr_txreq_memattr_sx1,
        mshr_txreq_dodwt_sx1,
        mshr_txreq_tracetag_sx1,
        txrsp_lcrdv,
        mshr_txrsp_bypass_valid_s1,
        mshr_txrsp_bypass_qos_s1,
        mshr_txrsp_bypass_tgtid_s1,
        mshr_txrsp_bypass_txnid_s1,
        mshr_txrsp_bypass_opcode_s1,
        mshr_txrsp_bypass_resperr_s1,
        mshr_txrsp_bypass_dbid_s1,
        mshr_txrsp_bypass_tracetag_s1,
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
        mshr_txrsp_valid_sx1_q,
        mshr_txrsp_qos_sx1,
        mshr_txrsp_tgtid_sx1,
        mshr_txrsp_txnid_sx1_q,
        mshr_txrsp_opcode_sx1,
        mshr_txrsp_resperr_sx1,
        mshr_txrsp_resp_sx1,
        mshr_txrsp_dbid_sx1,
        mshr_txrsp_tracetag_sx1,
        txsnp_lcrdv,
        mshr_txsnp_valid_sx1_q,
        mshr_txsnp_qos_sx1,
        mshr_txsnp_txnid_sx1_q,
        mshr_txsnp_fwdnid_sx1,
        mshr_txsnp_fwdtxnid_sx1,
        mshr_txsnp_opcode_sx1,
        mshr_txsnp_addr_sx1,
        mshr_txsnp_ns_sx1,
        mshr_txsnp_rettosrc_sx1,
        mshr_txsnp_tracetag_sx1,
        mshr_txsnp_rn_vec_sx1,
        txdat_lcrdv,
        mshr_txdat_tgtid_sx2,
        mshr_txdat_txnid_sx2,
        mshr_txdat_opcode_sx2,
        mshr_txdat_resp_sx2,
        mshr_txdat_resperr_sx2,
        mshr_txdat_dbid_sx2,
        dbf_txdat_data_sx1,
        dbf_txdat_idx_sx1,
        dbf_txdat_be_sx1,
        dbf_txdat_pe_sx1,
        dbf_txdat_valid_sx1,

        // 62 outputs
        rxreq_lcrdv,
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
        rxrsp_lcrdv,
        li_mshr_rxrsp_valid_s0,
        li_mshr_rxrsp_srcid_s0,
        li_mshr_rxrsp_txnid_s0,
        li_mshr_rxrsp_opcode_s0,
        li_mshr_rxrsp_resp_s0,
        li_mshr_rxrsp_fwdstate_s0,
        li_mshr_rxrsp_dbid_s0,
        li_mshr_rxrsp_pcrdtype_s0,
        rxdat_lcrdv,
        li_mshr_rxdat_valid_s0,
        li_mshr_rxdat_txnid_s0,
        li_mshr_rxdat_opcode_s0,
        li_mshr_rxdat_resp_s0,
        li_mshr_rxdat_fwdstate_s0,
        li_mshr_rxdat_dataid_s0,
        li_dbf_rxdat_valid_s0,
        li_dbf_rxdat_txnid_s0,
        li_dbf_rxdat_opcode_s0,
        li_dbf_rxdat_dataid_s0,
        li_dbf_rxdat_be_s0,
        li_dbf_rxdat_data_s0,
        txreqflitv,
        txreqflit,
        txreqflitpend,
        txrspflitv,
        txrspflit,
        txrspflitpend,
        txrsp_mshr_retryack_won_s1,
        txrsp_mshr_pcrdgnt_won_s2,
        txrsp_mshr_won_sx1,
        txreq_mshr_won_sx1,
        txreq_mshr_bypass_won_s1,
        txrsp_mshr_bypass_won_s1,
        txsnpflitv,
        txsnpflit,
        txsnpflitpend,
        txsnp_mshr_busy_sx1,
        txdatflitv,
        txdatflit,
        txdatflitpend,
        txdat_mshr_clr_dbf_busy_valid_sx3,
        txdat_mshr_clr_dbf_busy_idx_sx3,
        txdat_mshr_rd_idx_sx2,
        txdat_mshr_busy_sx
    );
    //inputs
    input wire                                        clk;
    input wire                                        rst;
    input wire                                        rxreqflitv;
    input wire [`CHIE_REQ_FLIT_RANGE]                 rxreqflit;
    input wire                                        rxreqflitpend;
    input wire                                        biq_req_valid_s0_q;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        biq_req_addr_s0_q;
    input wire                                        qos_seq_pool_full_s0_q;
    input wire                                        rxreq_retry_enable_s0;
    input wire                                        rxrspflitv;
    input wire [`CHIE_RSP_FLIT_RANGE]                 rxrspflit;
    input wire                                        rxrspflitpend;
    input wire                                        rxdatflitv;
    input wire [`CHIE_DAT_FLIT_RANGE]                 rxdatflit;
    input wire                                        rxdatflitpend;
    input wire                                        txreq_lcrdv;
    input wire                                        mshr_txreq_bypass_valid_s1;
    input wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]         mshr_txreq_bypass_qos_s1;
    input wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]       mshr_txreq_bypass_txnid_s1;
    input wire [`CHIE_REQ_FLIT_RETURNNID_WIDTH-1:0]   mshr_txreq_bypass_returnnid_s1;
    input wire [`CHIE_REQ_FLIT_RETURNTXNID_WIDTH-1:0] mshr_txreq_bypass_returntxnid_s1;
    input wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      mshr_txreq_bypass_opcode_s1;
    input wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        mshr_txreq_bypass_size_s1;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        mshr_txreq_bypass_addr_s1;
    input wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]          mshr_txreq_bypass_ns_s1;
    input wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0]  mshr_txreq_bypass_allowretry_s1;
    input wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]       mshr_txreq_bypass_order_s1;
    input wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]    mshr_txreq_bypass_pcrdtype_s1;
    input wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]     mshr_txreq_bypass_memattr_s1;
    input wire [`CHIE_REQ_FLIT_DODWT_WIDTH-1:0]       mshr_txreq_bypass_dodwt_s1;
    input wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]    mshr_txreq_bypass_tracetag_s1;
    input wire                                        mshr_txreq_valid_sx1_q;
    input wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]         mshr_txreq_qos_sx1;
    input wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]       mshr_txreq_txnid_sx1_q;
    input wire [`CHIE_REQ_FLIT_RETURNNID_WIDTH-1:0]   mshr_txreq_returnnid_sx1;
    input wire [`CHIE_REQ_FLIT_RETURNTXNID_WIDTH-1:0] mshr_txreq_returntxnid_sx1;
    input wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      mshr_txreq_opcode_sx1;
    input wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        mshr_txreq_size_sx1;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        mshr_txreq_addr_sx1;
    input wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]          mshr_txreq_ns_sx1;
    input wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0]  mshr_txreq_allowretry_sx1;
    input wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]       mshr_txreq_order_sx1;
    input wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]    mshr_txreq_pcrdtype_sx1;
    input wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]     mshr_txreq_memattr_sx1;
    input wire [`CHIE_REQ_FLIT_DODWT_WIDTH-1:0]       mshr_txreq_dodwt_sx1;
    input wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]    mshr_txreq_tracetag_sx1;
    input wire                                        txrsp_lcrdv;
    input wire                                        mshr_txrsp_bypass_valid_s1;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         mshr_txrsp_bypass_qos_s1;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       mshr_txrsp_bypass_tgtid_s1;
    input wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       mshr_txrsp_bypass_txnid_s1;
    input wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      mshr_txrsp_bypass_opcode_s1;
    input wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]     mshr_txrsp_bypass_resperr_s1;
    input wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]        mshr_txrsp_bypass_dbid_s1;
    input wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    mshr_txrsp_bypass_tracetag_s1;
    input wire                                        qos_txrsp_retryack_valid_s1;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         qos_txrsp_retryack_qos_s1;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       qos_txrsp_retryack_tgtid_s1;
    input wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       qos_txrsp_retryack_txnid_s1;
    input wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]    qos_txrsp_retryack_pcrdtype_s1;
    input wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    qos_txrsp_retryack_tracetag_s1;
    input wire                                        qos_txrsp_pcrdgnt_valid_s2;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         qos_txrsp_pcrdgnt_qos_s2;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       qos_txrsp_pcrdgnt_tgtid_s2;
    input wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]    qos_txrsp_pcrdgnt_pcrdtype_s2;
    input wire                                        mshr_txrsp_valid_sx1_q;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         mshr_txrsp_qos_sx1;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       mshr_txrsp_tgtid_sx1;
    input wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       mshr_txrsp_txnid_sx1_q;
    input wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      mshr_txrsp_opcode_sx1;
    input wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]     mshr_txrsp_resperr_sx1;
    input wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]        mshr_txrsp_resp_sx1;
    input wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]        mshr_txrsp_dbid_sx1;
    input wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    mshr_txrsp_tracetag_sx1;
    input wire                                        txsnp_lcrdv;
    input wire                                        mshr_txsnp_valid_sx1_q;
    input wire [`CHIE_SNP_FLIT_QOS_WIDTH-1:0]         mshr_txsnp_qos_sx1;
    input wire [`CHIE_SNP_FLIT_TXNID_WIDTH-1:0]       mshr_txsnp_txnid_sx1_q;
    input wire [`CHIE_SNP_FLIT_FWDNID_WIDTH-1:0]      mshr_txsnp_fwdnid_sx1;
    input wire [`CHIE_SNP_FLIT_FWDTXNID_WIDTH-1:0]    mshr_txsnp_fwdtxnid_sx1;
    input wire [`CHIE_SNP_FLIT_OPCODE_WIDTH-1:0]      mshr_txsnp_opcode_sx1;
    input wire [`CHIE_SNP_FLIT_ADDR_WIDTH-1:0]        mshr_txsnp_addr_sx1;
    input wire [`CHIE_SNP_FLIT_NS_WIDTH-1:0]          mshr_txsnp_ns_sx1;
    input wire [`CHIE_SNP_FLIT_RETTOSRC_WIDTH-1:0]    mshr_txsnp_rettosrc_sx1;
    input wire [`CHIE_SNP_FLIT_TRACETAG_WIDTH-1:0]    mshr_txsnp_tracetag_sx1;
    input wire [HNF_MSHR_RNF_NUM_PARAM-1:0]           mshr_txsnp_rn_vec_sx1;
    input wire                                        txdat_lcrdv;
    input wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]       mshr_txdat_tgtid_sx2;
    input wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]       mshr_txdat_txnid_sx2;
    input wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]      mshr_txdat_opcode_sx2;
    input wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]        mshr_txdat_resp_sx2;
    input wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]     mshr_txdat_resperr_sx2;
    input wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]        mshr_txdat_dbid_sx2;
    input wire [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]      dbf_txdat_data_sx1;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]              dbf_txdat_idx_sx1;
    input wire [1:0]                                  dbf_txdat_pe_sx1;
    input wire [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]        dbf_txdat_be_sx1;
    input wire                                        dbf_txdat_valid_sx1;

    //outputs
    output wire                                       rxreq_lcrdv;
    output wire                                       li_mshr_rxreq_valid_s0;
    output wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]        li_mshr_rxreq_qos_s0;
    output wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]      li_mshr_rxreq_srcid_s0;
    output wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]      li_mshr_rxreq_txnid_s0;
    output wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]     li_mshr_rxreq_opcode_s0;
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]       li_mshr_rxreq_size_s0;
    output wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]       li_mshr_rxreq_addr_s0;
    output wire                                       li_mshr_rxreq_ns_s0;
    output wire                                       li_mshr_rxreq_allowretry_s0;
    output wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]      li_mshr_rxreq_order_s0;
    output wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]   li_mshr_rxreq_pcrdtype_s0;
    output wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]    li_mshr_rxreq_memattr_s0;
    output wire [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]       li_mshr_rxreq_lpid_s0;
    output wire                                       li_mshr_rxreq_excl_s0;
    output wire                                       li_mshr_rxreq_expcompack_s0;
    output wire                                       li_mshr_rxreq_tracetag_s0;
    output wire                                       rxrsp_lcrdv;
    output wire                                       li_mshr_rxrsp_valid_s0;
    output wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]      li_mshr_rxrsp_srcid_s0;
    output wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]      li_mshr_rxrsp_txnid_s0;
    output wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]     li_mshr_rxrsp_opcode_s0;
    output wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]       li_mshr_rxrsp_resp_s0;
    output wire [`CHIE_RSP_FLIT_FWDSTATE_WIDTH-1:0]   li_mshr_rxrsp_fwdstate_s0;
    output wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]       li_mshr_rxrsp_dbid_s0;
    output wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]   li_mshr_rxrsp_pcrdtype_s0;
    output wire                                       rxdat_lcrdv;
    output wire                                       li_mshr_rxdat_valid_s0;
    output wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]      li_mshr_rxdat_txnid_s0;
    output wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]     li_mshr_rxdat_opcode_s0;
    output wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]       li_mshr_rxdat_resp_s0;
    output wire [`CHIE_DAT_FLIT_FWDSTATE_WIDTH-1:0]   li_mshr_rxdat_fwdstate_s0;
    output wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]     li_mshr_rxdat_dataid_s0;
    output wire                                       li_dbf_rxdat_valid_s0;
    output wire [`MSHR_ENTRIES_WIDTH-1:0]             li_dbf_rxdat_txnid_s0;
    output wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]     li_dbf_rxdat_opcode_s0;
    output wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]     li_dbf_rxdat_dataid_s0;
    output wire [`CHIE_DAT_FLIT_BE_WIDTH-1:0]         li_dbf_rxdat_be_s0;
    output wire [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]       li_dbf_rxdat_data_s0;
    output wire                                       txreqflitv;
    output wire [`CHIE_REQ_FLIT_RANGE]                txreqflit;
    output wire                                       txreqflitpend;
    output wire                                       txrspflitv;
    output wire [`CHIE_RSP_FLIT_RANGE]                txrspflit;
    output wire                                       txrspflitpend;
    output wire                                       txrsp_mshr_retryack_won_s1;
    output wire                                       txrsp_mshr_pcrdgnt_won_s2;
    output wire                                       txrsp_mshr_won_sx1;
    output wire                                       txreq_mshr_won_sx1;
    output wire                                       txreq_mshr_bypass_won_s1;
    output wire                                       txrsp_mshr_bypass_won_s1;
    output wire                                       txsnpflitv;
    output wire [`HNF_SNP_FLIT_RANGE]                 txsnpflit;
    output wire                                       txsnpflitpend;
    output wire                                       txsnp_mshr_busy_sx1;
    output wire                                       txdatflitv;
    output wire [`CHIE_DAT_FLIT_RANGE]                txdatflit;
    output wire                                       txdatflitpend;
    output wire                                       txdat_mshr_clr_dbf_busy_valid_sx3;
    output wire [`MSHR_ENTRIES_WIDTH-1:0]             txdat_mshr_clr_dbf_busy_idx_sx3;
    output wire [`MSHR_ENTRIES_WIDTH-1:0]             txdat_mshr_rd_idx_sx2;
    output wire                                       txdat_mshr_busy_sx;

    hnf_link_rxreq_parse `HNF_PARAM_INST
                         u_hnf_link_rxreq_parse(
                             .clk                                            (clk                            ),
                             .rst                                            (rst                            ),
                             .rxreqflitv                                     (rxreqflitv                     ),
                             .rxreqflit                                      (rxreqflit                      ),
                             .rxreqflitpend                                  (rxreqflitpend                  ),
                             .biq_req_valid_s0_q                             (biq_req_valid_s0_q             ),
                             .biq_req_addr_s0_q                              (biq_req_addr_s0_q              ),
                             .qos_seq_pool_full_s0_q                         (qos_seq_pool_full_s0_q         ),
                             .rxreq_retry_enable_s0                          (rxreq_retry_enable_s0          ),
                             .txrsp_mshr_retryack_won_s1                     (txrsp_mshr_retryack_won_s1     ),
                             .rxreq_lcrdv                                    (rxreq_lcrdv                    ),
                             .li_mshr_rxreq_valid_s0                         (li_mshr_rxreq_valid_s0         ),
                             .li_mshr_rxreq_qos_s0                           (li_mshr_rxreq_qos_s0           ),
                             .li_mshr_rxreq_srcid_s0                         (li_mshr_rxreq_srcid_s0         ),
                             .li_mshr_rxreq_txnid_s0                         (li_mshr_rxreq_txnid_s0         ),
                             .li_mshr_rxreq_opcode_s0                        (li_mshr_rxreq_opcode_s0        ),
                             .li_mshr_rxreq_size_s0                          (li_mshr_rxreq_size_s0          ),
                             .li_mshr_rxreq_addr_s0                          (li_mshr_rxreq_addr_s0          ),
                             .li_mshr_rxreq_ns_s0                            (li_mshr_rxreq_ns_s0            ),
                             .li_mshr_rxreq_allowretry_s0                    (li_mshr_rxreq_allowretry_s0    ),
                             .li_mshr_rxreq_order_s0                         (li_mshr_rxreq_order_s0         ),
                             .li_mshr_rxreq_pcrdtype_s0                      (li_mshr_rxreq_pcrdtype_s0      ),
                             .li_mshr_rxreq_memattr_s0                       (li_mshr_rxreq_memattr_s0       ),
                             .li_mshr_rxreq_lpid_s0                          (li_mshr_rxreq_lpid_s0          ),
                             .li_mshr_rxreq_excl_s0                          (li_mshr_rxreq_excl_s0          ),
                             .li_mshr_rxreq_expcompack_s0                    (li_mshr_rxreq_expcompack_s0    ),
                             .li_mshr_rxreq_tracetag_s0                      (li_mshr_rxreq_tracetag_s0      )
                         );

    hnf_link_rxrsp_parse `HNF_PARAM_INST
                         u_hnf_link_rxrsp_parse(
                             .clk                                            (clk                            ),
                             .rst                                            (rst                            ),
                             .rxrspflitv                                     (rxrspflitv                     ),
                             .rxrspflit                                      (rxrspflit                      ),
                             .rxrspflitpend                                  (rxrspflitpend                  ),
                             .rxrsp_lcrdv                                    (rxrsp_lcrdv                    ),
                             .li_mshr_rxrsp_valid_s0                         (li_mshr_rxrsp_valid_s0         ),
                             .li_mshr_rxrsp_srcid_s0                         (li_mshr_rxrsp_srcid_s0         ),
                             .li_mshr_rxrsp_txnid_s0                         (li_mshr_rxrsp_txnid_s0         ),
                             .li_mshr_rxrsp_opcode_s0                        (li_mshr_rxrsp_opcode_s0        ),
                             .li_mshr_rxrsp_resp_s0                          (li_mshr_rxrsp_resp_s0          ),
                             .li_mshr_rxrsp_fwdstate_s0                      (li_mshr_rxrsp_fwdstate_s0      ),
                             .li_mshr_rxrsp_dbid_s0                          (li_mshr_rxrsp_dbid_s0          ),
                             .li_mshr_rxrsp_pcrdtype_s0                      (li_mshr_rxrsp_pcrdtype_s0      )
                         );

    hnf_link_rxdat_parse `HNF_PARAM_INST
                         u_hnf_link_rxdat_parse(
                             .clk                                            (clk                            ),
                             .rst                                            (rst                            ),
                             .rxdatflitv                                     (rxdatflitv                     ),
                             .rxdatflit                                      (rxdatflit                      ),
                             .rxdatflitpend                                  (rxdatflitpend                  ),
                             .rxdat_lcrdv                                    (rxdat_lcrdv                    ),
                             .li_mshr_rxdat_valid_s0                         (li_mshr_rxdat_valid_s0         ),
                             .li_mshr_rxdat_txnid_s0                         (li_mshr_rxdat_txnid_s0         ),
                             .li_mshr_rxdat_opcode_s0                        (li_mshr_rxdat_opcode_s0        ),
                             .li_mshr_rxdat_resp_s0                          (li_mshr_rxdat_resp_s0          ),
                             .li_mshr_rxdat_fwdstate_s0                      (li_mshr_rxdat_fwdstate_s0      ),
                             .li_mshr_rxdat_dataid_s0                        (li_mshr_rxdat_dataid_s0        ),
                             .li_dbf_rxdat_valid_s0                          (li_dbf_rxdat_valid_s0          ),
                             .li_dbf_rxdat_txnid_s0                          (li_dbf_rxdat_txnid_s0          ),
                             .li_dbf_rxdat_opcode_s0                         (li_dbf_rxdat_opcode_s0         ),
                             .li_dbf_rxdat_dataid_s0                         (li_dbf_rxdat_dataid_s0         ),
                             .li_dbf_rxdat_be_s0                             (li_dbf_rxdat_be_s0             ),
                             .li_dbf_rxdat_data_s0                           (li_dbf_rxdat_data_s0           )
                         );

    hnf_link_txreq_wrap `HNF_PARAM_INST
                        u_hnf_link_txreq_wrap(
                            .clk                                            (clk                            ),
                            .rst                                            (rst                            ),
                            .txreq_lcrdv                                    (txreq_lcrdv                    ),
                            .mshr_txreq_bypass_valid_s1                         (mshr_txreq_bypass_valid_s1         ),
                            .mshr_txreq_bypass_qos_s1                           (mshr_txreq_bypass_qos_s1           ),
                            .mshr_txreq_bypass_txnid_s1                         (mshr_txreq_bypass_txnid_s1         ),
                            .mshr_txreq_bypass_returnnid_s1                     (mshr_txreq_bypass_returnnid_s1     ),
                            .mshr_txreq_bypass_returntxnid_s1                   (mshr_txreq_bypass_returntxnid_s1   ),
                            .mshr_txreq_bypass_opcode_s1                        (mshr_txreq_bypass_opcode_s1        ),
                            .mshr_txreq_bypass_size_s1                          (mshr_txreq_bypass_size_s1          ),
                            .mshr_txreq_bypass_addr_s1                          (mshr_txreq_bypass_addr_s1          ),
                            .mshr_txreq_bypass_ns_s1                            (mshr_txreq_bypass_ns_s1            ),
                            .mshr_txreq_bypass_allowretry_s1                    (mshr_txreq_bypass_allowretry_s1    ),
                            .mshr_txreq_bypass_order_s1                         (mshr_txreq_bypass_order_s1         ),
                            .mshr_txreq_bypass_pcrdtype_s1                      (mshr_txreq_bypass_pcrdtype_s1      ),
                            .mshr_txreq_bypass_memattr_s1                       (mshr_txreq_bypass_memattr_s1       ),
                            .mshr_txreq_bypass_dodwt_s1                         (mshr_txreq_bypass_dodwt_s1         ),
                            .mshr_txreq_bypass_tracetag_s1                      (mshr_txreq_bypass_tracetag_s1      ),
                            .mshr_txreq_valid_sx1_q                         (mshr_txreq_valid_sx1_q         ),
                            .mshr_txreq_qos_sx1                             (mshr_txreq_qos_sx1             ),
                            .mshr_txreq_txnid_sx1_q                         (mshr_txreq_txnid_sx1_q         ),
                            .mshr_txreq_returnnid_sx1                       (mshr_txreq_returnnid_sx1       ),
                            .mshr_txreq_returntxnid_sx1                     (mshr_txreq_returntxnid_sx1     ),
                            .mshr_txreq_opcode_sx1                          (mshr_txreq_opcode_sx1          ),
                            .mshr_txreq_size_sx1                            (mshr_txreq_size_sx1            ),
                            .mshr_txreq_addr_sx1                            (mshr_txreq_addr_sx1            ),
                            .mshr_txreq_ns_sx1                              (mshr_txreq_ns_sx1              ),
                            .mshr_txreq_allowretry_sx1                      (mshr_txreq_allowretry_sx1      ),
                            .mshr_txreq_order_sx1                           (mshr_txreq_order_sx1           ),
                            .mshr_txreq_pcrdtype_sx1                        (mshr_txreq_pcrdtype_sx1        ),
                            .mshr_txreq_memattr_sx1                         (mshr_txreq_memattr_sx1         ),
                            .mshr_txreq_dodwt_sx1                           (mshr_txreq_dodwt_sx1           ),
                            .mshr_txreq_tracetag_sx1                        (mshr_txreq_tracetag_sx1        ),
                            .txreqflitv                                     (txreqflitv                     ),
                            .txreqflit                                      (txreqflit                      ),
                            .txreqflitpend                                  (txreqflitpend                  ),
                            .txreq_mshr_won_sx1                             (txreq_mshr_won_sx1             ),
                            .txreq_mshr_bypass_won_s1                           (txreq_mshr_bypass_won_s1           )
                        );

    hnf_link_txrsp_wrap `HNF_PARAM_INST
                        u_hnf_link_txrsp_wrap(
                            .clk                                            (clk                            ),
                            .rst                                            (rst                            ),
                            .txrsp_lcrdv                                    (txrsp_lcrdv                    ),
                            .mshr_txrsp_bypass_valid_s1                         (mshr_txrsp_bypass_valid_s1         ),
                            .mshr_txrsp_bypass_qos_s1                           (mshr_txrsp_bypass_qos_s1           ),
                            .mshr_txrsp_bypass_tgtid_s1                         (mshr_txrsp_bypass_tgtid_s1         ),
                            .mshr_txrsp_bypass_txnid_s1                         (mshr_txrsp_bypass_txnid_s1         ),
                            .mshr_txrsp_bypass_opcode_s1                        (mshr_txrsp_bypass_opcode_s1        ),
                            .mshr_txrsp_bypass_resperr_s1                       (mshr_txrsp_bypass_resperr_s1       ),
                            .mshr_txrsp_bypass_dbid_s1                          (mshr_txrsp_bypass_dbid_s1          ),
                            .mshr_txrsp_bypass_tracetag_s1                      (mshr_txrsp_bypass_tracetag_s1      ),
                            .qos_txrsp_retryack_valid_s1                    (qos_txrsp_retryack_valid_s1    ),
                            .qos_txrsp_retryack_qos_s1                      (qos_txrsp_retryack_qos_s1      ),
                            .qos_txrsp_retryack_tgtid_s1                    (qos_txrsp_retryack_tgtid_s1    ),
                            .qos_txrsp_retryack_txnid_s1                    (qos_txrsp_retryack_txnid_s1    ),
                            .qos_txrsp_retryack_pcrdtype_s1                 (qos_txrsp_retryack_pcrdtype_s1 ),
                            .qos_txrsp_retryack_tracetag_s1                 (qos_txrsp_retryack_tracetag_s1 ),
                            .qos_txrsp_pcrdgnt_valid_s2                     (qos_txrsp_pcrdgnt_valid_s2     ),
                            .qos_txrsp_pcrdgnt_qos_s2                       (qos_txrsp_pcrdgnt_qos_s2       ),
                            .qos_txrsp_pcrdgnt_tgtid_s2                     (qos_txrsp_pcrdgnt_tgtid_s2     ),
                            .qos_txrsp_pcrdgnt_pcrdtype_s2                  (qos_txrsp_pcrdgnt_pcrdtype_s2  ),
                            .mshr_txrsp_valid_sx1_q                         (mshr_txrsp_valid_sx1_q         ),
                            .mshr_txrsp_qos_sx1                             (mshr_txrsp_qos_sx1             ),
                            .mshr_txrsp_tgtid_sx1                           (mshr_txrsp_tgtid_sx1           ),
                            .mshr_txrsp_txnid_sx1_q                         (mshr_txrsp_txnid_sx1_q         ),
                            .mshr_txrsp_opcode_sx1                          (mshr_txrsp_opcode_sx1          ),
                            .mshr_txrsp_resperr_sx1                         (mshr_txrsp_resperr_sx1         ),
                            .mshr_txrsp_resp_sx1                            (mshr_txrsp_resp_sx1            ),
                            .mshr_txrsp_dbid_sx1                            (mshr_txrsp_dbid_sx1            ),
                            .mshr_txrsp_tracetag_sx1                        (mshr_txrsp_tracetag_sx1        ),
                            .txrspflitv                                     (txrspflitv                     ),
                            .txrspflit                                      (txrspflit                      ),
                            .txrspflitpend                                  (txrspflitpend                  ),
                            .txrsp_mshr_retryack_won_s1                     (txrsp_mshr_retryack_won_s1     ),
                            .txrsp_mshr_pcrdgnt_won_s2                      (txrsp_mshr_pcrdgnt_won_s2      ),
                            .txrsp_mshr_won_sx1                             (txrsp_mshr_won_sx1             ),
                            .txrsp_mshr_bypass_won_s1                           (txrsp_mshr_bypass_won_s1           )
                        );

    hnf_link_txsnp_wrap `HNF_PARAM_INST
                        u_hnf_link_txsnp_wrap(
                            .clk                                            (clk                               ),
                            .rst                                            (rst                               ),
                            .txsnp_lcrdv                                    (txsnp_lcrdv                       ),
                            .mshr_txsnp_valid_sx1_q                         (mshr_txsnp_valid_sx1_q            ),
                            .mshr_txsnp_qos_sx1                             (mshr_txsnp_qos_sx1                ),
                            .mshr_txsnp_txnid_sx1_q                         (mshr_txsnp_txnid_sx1_q            ),
                            .mshr_txsnp_fwdnid_sx1                          (mshr_txsnp_fwdnid_sx1             ),
                            .mshr_txsnp_fwdtxnid_sx1                        (mshr_txsnp_fwdtxnid_sx1           ),
                            .mshr_txsnp_opcode_sx1                          (mshr_txsnp_opcode_sx1             ),
                            .mshr_txsnp_addr_sx1                            (mshr_txsnp_addr_sx1               ),
                            .mshr_txsnp_ns_sx1                              (mshr_txsnp_ns_sx1                 ),
                            .mshr_txsnp_rettosrc_sx1                        (mshr_txsnp_rettosrc_sx1           ),
                            .mshr_txsnp_tracetag_sx1                        (mshr_txsnp_tracetag_sx1           ),
                            .mshr_txsnp_rn_vec_sx1                          (mshr_txsnp_rn_vec_sx1             ),
                            .txsnpflitv                                     (txsnpflitv                        ),
                            .txsnpflit                                      (txsnpflit                         ),
                            .txsnpflitpend                                  (txsnpflitpend                     ),
                            .txsnp_mshr_busy_sx1                            (txsnp_mshr_busy_sx1               )
                        );

    hnf_link_txdat_wrap `HNF_PARAM_INST
                        u_hnf_link_txdat_wrap(
                            .clk                                            (clk                               ),
                            .rst                                            (rst                               ),
                            .txdat_lcrdv                                    (txdat_lcrdv                       ),
                            .mshr_txdat_tgtid_sx2                           (mshr_txdat_tgtid_sx2              ),
                            .mshr_txdat_txnid_sx2                           (mshr_txdat_txnid_sx2              ),
                            .mshr_txdat_opcode_sx2                          (mshr_txdat_opcode_sx2             ),
                            .mshr_txdat_resp_sx2                            (mshr_txdat_resp_sx2               ),
                            .mshr_txdat_resperr_sx2                         (mshr_txdat_resperr_sx2            ),
                            .mshr_txdat_dbid_sx2                            (mshr_txdat_dbid_sx2               ),
                            .dbf_txdat_data_sx1                             (dbf_txdat_data_sx1                ),
                            .dbf_txdat_idx_sx1                              (dbf_txdat_idx_sx1                 ),
                            .dbf_txdat_be_sx1                               (dbf_txdat_be_sx1                  ),
                            .dbf_txdat_pe_sx1                               (dbf_txdat_pe_sx1                  ),
                            .dbf_txdat_valid_sx1                            (dbf_txdat_valid_sx1               ),
                            .txdatflitv                                     (txdatflitv                        ),
                            .txdatflit                                      (txdatflit                         ),
                            .txdatflitpend                                  (txdatflitpend                     ),
                            .txdat_mshr_clr_dbf_busy_valid_sx3              (txdat_mshr_clr_dbf_busy_valid_sx3 ),
                            .txdat_mshr_clr_dbf_busy_idx_sx3                (txdat_mshr_clr_dbf_busy_idx_sx3   ),
                            .txdat_mshr_rd_idx_sx2                          (txdat_mshr_rd_idx_sx2             ),
                            .txdat_mshr_busy_sx                             (txdat_mshr_busy_sx                )
                        );


endmodule
