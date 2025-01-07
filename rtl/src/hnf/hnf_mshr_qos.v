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
*    Li Zhao <lizhao@bosc.ac.cn>
*    Nana Cai <cainana@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_mshr_qos `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //input from hnf_link_txrsp_wrap
        txrsp_mshr_retryack_won_s1,
        txrsp_mshr_pcrdgnt_won_s2,

        //input from hnf_link_rxreq_parse
        li_mshr_rxreq_valid_s0,
        li_mshr_rxreq_qos_s0,
        li_mshr_rxreq_srcid_s0,
        li_mshr_rxreq_txnid_s0,
        li_mshr_rxreq_opcode_s0,
        li_mshr_rxreq_allowretry_s0,
        li_mshr_rxreq_tracetag_s0,

        //input from hnf_mshr_ctl
        mshr_dbf_retired_valid_sx1_q,
        mshr_dbf_retired_idx_sx1_q,

        //outputs to hnf_link_txrsp_wrap
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

        //outputs to hnf_link_rxreq_parse
        rxreq_retry_enable_s0,
        qos_seq_pool_full_s0_q,

        //outputs to hnf_mshr_global_monitor,ctl and bypass
        mshr_alloc_en_s0,
        mshr_alloc_en_s1_q,
        mshr_entry_idx_alloc_s0,
        mshr_entry_idx_alloc_s1_q,
        mshr_entry_alloc_s1_q
    );

    //inputs
    input wire                                       clk;
    input wire                                       rst;

    //inputs from hnf_link_txrsp_wrap
    input wire                                       txrsp_mshr_retryack_won_s1;
    input wire                                       txrsp_mshr_pcrdgnt_won_s2;

    //inputs from hnf_link_rxreq_parse
    input wire                                       li_mshr_rxreq_valid_s0;
    input wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]        li_mshr_rxreq_qos_s0;
    input wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]      li_mshr_rxreq_srcid_s0;
    input wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]      li_mshr_rxreq_txnid_s0;
    input wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]     li_mshr_rxreq_opcode_s0;
    input wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0] li_mshr_rxreq_allowretry_s0;
    input wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]   li_mshr_rxreq_tracetag_s0;

    //inputs from hnf_mshr_ctl
    input wire                                       mshr_dbf_retired_valid_sx1_q;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]             mshr_dbf_retired_idx_sx1_q;

    //outputs to hnf_link_txrsp_wrap
    output wire                                      qos_txrsp_retryack_valid_s1;
    output wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]       qos_txrsp_retryack_qos_s1;
    output wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]     qos_txrsp_retryack_tgtid_s1;
    output wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]     qos_txrsp_retryack_txnid_s1;
    output wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]  qos_txrsp_retryack_pcrdtype_s1;
    output wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]  qos_txrsp_retryack_tracetag_s1;
    output wire                                      qos_txrsp_pcrdgnt_valid_s2;
    output wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]       qos_txrsp_pcrdgnt_qos_s2;
    output wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]     qos_txrsp_pcrdgnt_tgtid_s2;
    output wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]  qos_txrsp_pcrdgnt_pcrdtype_s2;

    //outputs to hnf_link_rxreq_parse
    output wire                                      rxreq_retry_enable_s0;
    output reg                                       qos_seq_pool_full_s0_q;

    //outputs to hnf_mshr_global_monitor,ctl and bypass
    output wire                                      mshr_alloc_en_s0;
    output reg                                       mshr_alloc_en_s1_q;
    output wire [`MSHR_ENTRIES_WIDTH-1:0]            mshr_entry_idx_alloc_s0;
    output reg  [`MSHR_ENTRIES_WIDTH-1:0]            mshr_entry_idx_alloc_s1_q;
    output reg  [`MSHR_ENTRIES_NUM-1:0]              mshr_entry_alloc_s1_q;

    //internal wire signals
    wire                                             qpc_hhigh_s0;
    wire                                             qpc_high_s0;
    wire                                             qpc_med_s0;
    wire                                             qpc_low_s0;
    wire                                             li_req_qos_can_alloc_s0;
    wire                                             li_req_dyn_s0;
    wire                                             li_req_static_s0;
    wire                                             li_seq_alloc_s0;
    wire                                             qos_hh_can_alloc_s0;
    wire                                             qos_h_can_alloc_s0;
    wire                                             qos_m_can_alloc_s0;
    wire                                             qos_l_can_alloc_s0;
    wire                                             li_req_dyn_alloc_s0;
    wire                                             li_req_static_alloc_s0;
    wire                                             li_req_dyn_alloc_fail_s0;
    wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]         li_mshr_rxreq_pcrdtype_s0;
    wire                                             mshr_dyn_or_seq_alloc_s0;
    wire [`MSHR_ENTRIES_NUM-1:0]                     mshr_dyn_entry_idx_avail_s0;
    wire [`MSHR_ENTRIES_NUM-1:0]                     mshr_static_entry_idx_avail_s0;
    wire [`MSHR_ENTRIES_NUM-1:0]                     mshr_alloc_set_v_s0;
    wire [`MSHR_ENTRIES_NUM-1:0]                     mshr_entry_valid_flop_en_s0;
    wire [`MSHR_ENTRIES_NUM-1:0]                     mshr_alloc_entry_s0;
    wire [`MSHR_ENTRIES_NUM-1:0]                     mshr_static_set_s0;
    wire [`MSHR_ENTRIES_NUM-1:0]                     mshr_entry_alloc_s1;
    wire [`MSHR_ENTRIES_NUM-1:0]                     mshr_static_en_s0;
    wire                                             qos_hhigh_pool_avail_s0;
    wire                                             qos_high_pool_avail_s0;
    wire                                             qos_med_pool_avail_s0;
    wire                                             qos_low_pool_avail_s0;
    wire                                             qos_seq_pool_avail_s0;
    wire                                             qos_pool_hhigh_full_s0;
    wire                                             qos_pool_high_full_s0;
    wire                                             qos_pool_med_full_s0;
    wire                                             qos_pool_low_full_s0;
    wire                                             hhigh_cnt_update_s0;
    wire                                             high_cnt_update_s0;
    wire                                             med_cnt_update_s0;
    wire                                             low_cnt_update_s0;
    wire [`QOS_POOL_CNT_WIDTH-1:0]                   qos_pool_hhigh_cnt_ns;
    wire [`QOS_POOL_CNT_WIDTH-1:0]                   qos_pool_high_cnt_ns;
    wire [`QOS_POOL_CNT_WIDTH-1:0]                   qos_pool_med_cnt_ns;
    wire [`QOS_POOL_CNT_WIDTH-1:0]                   qos_pool_low_cnt_ns;
    wire                                             qos_pool_hhigh_cnt_inc_s0;
    wire                                             qos_pool_hhigh_cnt_dec_s0;
    wire                                             qos_pool_high_cnt_inc_s0;
    wire                                             qos_pool_high_cnt_dec_s0;
    wire                                             qos_pool_med_cnt_inc_s0;
    wire                                             qos_pool_med_cnt_dec_s0;
    wire                                             qos_pool_low_cnt_inc_s0;
    wire                                             qos_pool_low_cnt_dec_s0;
    wire                                             qos_low_pool_alloc_s0;
    wire                                             qos_med_pool_alloc_s0;
    wire                                             qos_high_pool_alloc_s0;
    wire                                             qos_hhigh_pool_alloc_s0;
    wire                                             mshr_seq_retire_sx1;
    wire                                             seq_inc_cnt_s0;
    wire                                             seq_dec_cnt_s0;
    wire [`QOS_CLASS_WIDTH-1:0]                      qos_pool_retire_class_sx1;
    wire                                             hh_retire_can_convert_static_sx1;
    wire                                             h_retire_can_convert_static_sx1;
    wire                                             m_retire_can_convert_static_sx1;
    wire                                             l_retire_can_convert_static_sx1;
    wire [`QOS_CLASS_WIDTH-1:0]                      qos_class_pool_s0;
    wire [`MSHR_ENTRIES_NUM-1:0]                     qos_class_pool_flop_en_s1;
    wire                                             mark_mshr_static_sx1;
    wire [`RETRY_ACKQ_DATA_RANGE]                    retry_ackq_datain_s0;
    wire                                             hnf_pcrdtype_enable_sx;
    wire [`PCRDGRANTQ_DATA_RANGE]                    pcrdgrant_fifo_datain_s2;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_bank_srcid_match_vec_s0;
    wire                                             ret_bank_alloc_en_s0;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_bank_entry_v_s0;
    wire                                             ret_is_hh_s1;
    wire                                             ret_is_h_s1;
    wire                                             ret_is_m_s1;
    wire                                             ret_is_l_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_inc_ptr_s0;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_hh_inc_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_h_inc_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_m_inc_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_l_inc_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_hh_dec_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_h_dec_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_m_dec_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_l_dec_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_hh_en_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_h_en_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_m_en_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_l_en_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_hh_zero;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_h_zero;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_m_zero;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_l_zero;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 hh_req_entry_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 h_req_entry_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 m_req_entry_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 l_req_entry_s1;
    wire                                             hhigh_present_s1;
    wire                                             high_present_s1;
    wire                                             med_present_s1;
    wire                                             low_present_s1;
    wire                                             hhigh_disable;
    wire                                             high_disable;
    wire                                             med_disable;
    wire                                             hh_present_win;
    wire                                             h_present_win;
    wire                                             m_present_win;
    wire                                             l_present_win;
    wire                                             hh_present_win_s1;
    wire                                             h_present_win_s1;
    wire                                             m_present_win_s1;
    wire                                             l_present_win_s1;
    wire                                             h_wait_lost;
    wire                                             m_wait_lost;
    wire                                             l_wait_lost;
    wire                                             h_wait_cnt_inc;
    wire                                             m_wait_cnt_inc;
    wire                                             l_wait_cnt_inc;
    wire                                             h_wait_cnt_rst;
    wire                                             m_wait_cnt_rst;
    wire                                             l_wait_cnt_rst;
    wire                                             h_to_hh_disable;
    wire                                             m_to_hh_disable;
    wire                                             l_to_hh_disable;
    wire                                             m_to_h_disable;
    wire                                             l_to_h_disbale;
    wire                                             l_to_m_disable;
    wire                                             h_wait_cnt_upd_en;
    wire                                             m_wait_cnt_upd_en;
    wire                                             l_wait_upd_en;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_hh_dec_ptr_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_h_dec_ptr_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_m_dec_ptr_s1;
    wire [`RET_BANK_ENTRIES_NUM-1:0]                 ret_cnt_l_dec_ptr_s1;
    wire                                             pcrdgnt_req_enable_s1;
    wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]            pcrdgnt_srcid_s2;
    wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]              pcrdgnt_qos_s2;
    wire [`RETRY_ACKQ_DATA_RANGE]                    retry_ack_fifo_dataout_s1;
    wire                                             retry_ack_fifo_empty;
    wire                                             retry_ack_fifo_full;
    wire                                             retry_ack_fifo_push;
    wire                                             retry_ack_fifo_pop;
    wire [`PCRDGRANTQ_DATA_RANGE]                    pcrdgrant_fifo_dataout_s2;
    wire                                             pcrdgrant_fifo_empty;
    wire                                             pcrdgrant_fifo_full;
    wire                                             pcrdgrant_fifo_push;
    wire                                             pcrdgrant_fifo_pop;

    //internal reg signals
    reg                                              qpc_hhigh_s1_q;
    reg                                              qpc_high_s1_q;
    reg                                              qpc_med_s1_q;
    reg                                              qpc_low_s1_q;
    reg [`MSHR_ENTRIES_NUM-1:0]                      mshr_static_entry_valid_s1_q;
    reg [`MSHR_ENTRIES_WIDTH-1:0]                    mshr_dyn_idx_alloc_s0;
    reg [`MSHR_ENTRIES_WIDTH-1:0]                    mshr_static_idx_alloc_s0;
    reg [`MSHR_ENTRIES_NUM-1:0]                      mshr_entry_valid_s1_q;
    reg [`MSHR_ENTRIES_NUM-1:0]                      mshr_retire_entry_s0;
    reg [`MSHR_ENTRIES_NUM-1:0]                      mshr_dyn_entry_idx_ptr_s0;
    reg [`MSHR_ENTRIES_NUM-1:0]                      mshr_dyn_entry_idx_vector;
    reg [`MSHR_ENTRIES_NUM-1:0]                      mshr_static_entry_idx_ptr_s0;
    reg [`MSHR_ENTRIES_NUM-1:0]                      mshr_static_entry_idx_vector;
    reg                                              rxreq_retry_enable_s1_q;
    reg                                              qos_hhigh_pool_full_s1_q;
    reg                                              qos_high_pool_full_s1_q;
    reg                                              qos_med_pool_full_s1_q;
    reg                                              qos_low_pool_full_s1_q;
    reg [`QOS_POOL_CNT_WIDTH-1:0]                    qos_pool_hhigh_cnt_q;
    reg [`QOS_POOL_CNT_WIDTH-1:0]                    qos_pool_high_cnt_q;
    reg [`QOS_POOL_CNT_WIDTH-1:0]                    qos_pool_med_cnt_q;
    reg [`QOS_POOL_CNT_WIDTH-1:0]                    qos_pool_low_cnt_q;
    reg [`QOS_CLASS_WIDTH-1:0]                       qos_class_pool_s2_q[0:`MSHR_ENTRIES_NUM-1];
    reg [`QOS_CLASS_WIDTH-1:0]                       qos_class_pool_s1_q;
    reg                                              mshr_dyn_or_seq_alloc_s1_q;
    reg [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]          pcrdgnt_pcrdtype_s2;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             ret_bank_srcid_s1_q[0:HNF_MSHR_RNF_NUM_PARAM-1];
    reg [`RET_BANK_ENTRIES_NUM-1:0]                  ret_bank_entry_v_s1_q;
    reg [`RET_BANK_ENTRIES_WIDTH-1:0]                ret_bank_entry_idx_s1_q;
    reg [`RET_BANK_ENTRIES_NUM-1:0]                  ret_bank_entry_ptr_s0;
    reg [`RET_BANK_ENTRIES_NUM-1:0]                  ret_cnt_inc_ptr_s1_q;
    reg [`RET_BANK_CNT_WIDTH-1:0]                    ret_cnt_hh_entry_s2_q[0:HNF_MSHR_RNF_NUM_PARAM-1];
    reg [`RET_BANK_CNT_WIDTH-1:0]                    ret_cnt_h_entry_s2_q[0:HNF_MSHR_RNF_NUM_PARAM-1];
    reg [`RET_BANK_CNT_WIDTH-1:0]                    ret_cnt_m_entry_s2_q[0:HNF_MSHR_RNF_NUM_PARAM-1];
    reg [`RET_BANK_CNT_WIDTH-1:0]                    ret_cnt_l_entry_s2_q[0:HNF_MSHR_RNF_NUM_PARAM-1];
    reg [`RET_BANK_CNT_WIDTH-1:0]                    ret_cnt_hh_entry_ns_s1[0:HNF_MSHR_RNF_NUM_PARAM-1];
    reg [`RET_BANK_CNT_WIDTH-1:0]                    ret_cnt_h_entry_ns_s1[0:HNF_MSHR_RNF_NUM_PARAM-1];
    reg [`RET_BANK_CNT_WIDTH-1:0]                    ret_cnt_m_entry_ns_s1[0:HNF_MSHR_RNF_NUM_PARAM-1];
    reg [`RET_BANK_CNT_WIDTH-1:0]                    ret_cnt_l_entry_ns_s1[0:HNF_MSHR_RNF_NUM_PARAM-1];
    reg                                              hh_present_win_s2_q;
    reg                                              h_present_win_s2_q;
    reg                                              m_present_win_s2_q;
    reg                                              l_present_win_s2_q;
    reg [`MAX_WAIT_CNT_WIDTH-1:0]                    h_wait_cnt_q;
    reg [`MAX_WAIT_CNT_WIDTH-1:0]                    m_wait_cnt_q;
    reg [`MAX_WAIT_CNT_WIDTH-1:0]                    l_wait_cnt_q;
    reg [`MAX_WAIT_CNT_WIDTH-1:0]                    h_wait_cnt_ns;
    reg [`MAX_WAIT_CNT_WIDTH-1:0]                    m_wait_cnt_ns;
    reg [`MAX_WAIT_CNT_WIDTH-1:0]                    l_wait_cnt_ns;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             hh_pcrdgrant_srcid_s1;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             h_pcrdgrant_srcid_s1;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             m_pcrdgrant_srcid_s1;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             l_pcrdgrant_srcid_s1;
    reg [`RET_BANK_ENTRIES_NUM-1:0]                  ret_cnt_hh_dec_ptr_s2_q;
    reg [`RET_BANK_ENTRIES_NUM-1:0]                  ret_cnt_h_dec_ptr_s2_q;
    reg [`RET_BANK_ENTRIES_NUM-1:0]                  ret_cnt_m_dec_ptr_s2_q;
    reg [`RET_BANK_ENTRIES_NUM-1:0]                  ret_cnt_l_dec_ptr_s2_q;
    reg                                              pcrdgnt_req_enable_s2_q;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             hh_pcrdgrant_srcid_s2_q;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             h_pcrdgrant_srcid_s2_q;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             m_pcrdgrant_srcid_s2_q;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             l_pcrdgrant_srcid_s2_q;

    //qos_hhigh_decode
    assign qpc_hhigh_s0 = (li_mshr_rxreq_qos_s0 >= `QOS_HHIGH_MIN)?1'b1:1'b0;

    //qos_high_decode
    assign qpc_high_s0 = ((li_mshr_rxreq_qos_s0 >= `QOS_HIGH_MIN) && (li_mshr_rxreq_qos_s0 <= `QOS_HIGH_MAX))?1'b1:1'b0;

    //qos_med_decode
    assign qpc_med_s0 = ((li_mshr_rxreq_qos_s0 >= `QOS_MED_MIN) && (li_mshr_rxreq_qos_s0 <= `QOS_MED_MAX))?1'b1:1'b0;

    //qos_low_decode
    assign qpc_low_s0 = (li_mshr_rxreq_qos_s0 <= `QOS_LOW_MAX)?1'b1:1'b0;

    //hhigh can allocate if any pool is available
    assign qos_hh_can_alloc_s0 = qos_hhigh_pool_avail_s0 | qos_high_pool_avail_s0 | qos_med_pool_avail_s0 | qos_low_pool_avail_s0;

    //high can allocate if high,med and low pool is available
    assign qos_h_can_alloc_s0 = qos_high_pool_avail_s0 | qos_med_pool_avail_s0 | qos_low_pool_avail_s0;

    //med can allocate if med and low pool is available
    assign qos_m_can_alloc_s0 = qos_med_pool_avail_s0 | qos_low_pool_avail_s0;

    //low can allocate if low pool is available
    assign qos_l_can_alloc_s0 = qos_low_pool_avail_s0;

    assign li_req_qos_can_alloc_s0 = (qpc_hhigh_s0 & qos_hh_can_alloc_s0) | (qpc_high_s0  & qos_h_can_alloc_s0 ) |
           (qpc_med_s0   & qos_m_can_alloc_s0 ) | (qpc_low_s0   & qos_l_can_alloc_s0 ) ;

    //qos allocate logic
    assign li_req_dyn_s0            = li_mshr_rxreq_valid_s0 & li_mshr_rxreq_allowretry_s0;
    assign li_req_static_s0         = li_mshr_rxreq_valid_s0 & ~li_mshr_rxreq_allowretry_s0;

    assign li_req_dyn_alloc_s0      = li_req_dyn_s0 & li_req_qos_can_alloc_s0 & (li_mshr_rxreq_opcode_s0 != `SF_EVICT);
    assign li_req_dyn_alloc_fail_s0 = li_req_dyn_s0 & ~li_req_qos_can_alloc_s0;

    assign li_req_static_alloc_s0   = li_req_static_s0 & !(li_mshr_rxreq_opcode_s0 == `SF_EVICT);

    assign li_seq_alloc_s0          = li_mshr_rxreq_valid_s0 && (li_mshr_rxreq_opcode_s0 == `SF_EVICT) && qos_seq_pool_avail_s0;

    //qos allocate enable
    assign mshr_alloc_en_s0         = li_req_dyn_alloc_s0 | li_req_static_alloc_s0 | li_seq_alloc_s0;

    always @(posedge clk or posedge rst) begin: update_mshr_alloc_en_timing_logic
        if (rst == 1'b1)
            mshr_alloc_en_s1_q <= 1'b0;
        else
            mshr_alloc_en_s1_q <= mshr_alloc_en_s0;
    end

    //encode the dynamic allocation pointer
    assign mshr_dyn_entry_idx_avail_s0 = ~mshr_static_entry_valid_s1_q & ~mshr_entry_valid_s1_q;

    //find 1 from available dynamic allocations
    always @* begin: mshr_dyn_entry_idx_ptr_comb_logic
        integer i;
        mshr_dyn_entry_idx_vector = {`MSHR_ENTRIES_NUM{1'b0}};
        mshr_dyn_entry_idx_ptr_s0 = {`MSHR_ENTRIES_NUM{1'b0}};

        for (i=1; i<`MSHR_ENTRIES_NUM; i=i+1)begin
            mshr_dyn_entry_idx_vector[i] = mshr_dyn_entry_idx_vector[i-1] | mshr_dyn_entry_idx_avail_s0[i-1];
        end

        for(i=0; i<`MSHR_ENTRIES_NUM; i=i+1)begin
            mshr_dyn_entry_idx_ptr_s0[i] = ~mshr_dyn_entry_idx_vector[i] & mshr_dyn_entry_idx_avail_s0[i];
        end
    end

    //encode the dynamic allocation index
    always @* begin: enc_dyn_ptr_alloc_idx_comb_logic
        integer i;
        mshr_dyn_idx_alloc_s0 = {`MSHR_ENTRIES_WIDTH{1'b0}};

        for(i=0; i<`MSHR_ENTRIES_NUM; i = i+1)begin
            if (mshr_dyn_entry_idx_ptr_s0[i])
                mshr_dyn_idx_alloc_s0 = i;
            else
                mshr_dyn_idx_alloc_s0 = mshr_dyn_idx_alloc_s0;
        end
    end

    //encode the static allocation pointer
    assign mshr_static_entry_idx_avail_s0 = mshr_static_entry_valid_s1_q & ~mshr_entry_valid_s1_q;

    //find 1 from available static allocations
    always @* begin: mshr_static_entry_idx_ptr_comb_logic
        integer i;
        mshr_static_entry_idx_vector = {`MSHR_ENTRIES_NUM{1'b0}};
        mshr_static_entry_idx_ptr_s0 = {`MSHR_ENTRIES_NUM{1'b0}};

        for (i=1; i<`MSHR_ENTRIES_NUM; i=i+1)begin
            mshr_static_entry_idx_vector[i] = mshr_static_entry_idx_vector[i-1] | mshr_static_entry_idx_avail_s0[i-1];
        end

        for(i=0; i<`MSHR_ENTRIES_NUM; i=i+1)begin
            mshr_static_entry_idx_ptr_s0[i] = ~mshr_static_entry_idx_vector[i] & mshr_static_entry_idx_avail_s0[i];
        end
    end

    //encode the static allocation index
    always @* begin: enc_static_ptr_alloc_idx_comb_logic
        integer i;
        mshr_static_idx_alloc_s0 = {`MSHR_ENTRIES_WIDTH{1'b0}};
        for(i=0; i<`MSHR_ENTRIES_NUM; i = i+1)begin
            if (mshr_static_entry_idx_ptr_s0[i])
                mshr_static_idx_alloc_s0 = i;
            else
                mshr_static_idx_alloc_s0 = mshr_static_idx_alloc_s0;
        end
    end

    //qos allocate index logic
    assign mshr_entry_idx_alloc_s0 = li_req_static_s0? mshr_static_idx_alloc_s0 : mshr_dyn_idx_alloc_s0;

    always @(posedge clk or posedge rst) begin: mshr_entry_idx_alloc_timing_logic
        if (rst == 1'b1)
            mshr_entry_idx_alloc_s1_q <= 1'b0;
        else
            mshr_entry_idx_alloc_s1_q <= mshr_entry_idx_alloc_s0;
    end

    //qos alloccate location
    assign mshr_alloc_entry_s0 = li_req_static_s0? mshr_static_entry_idx_ptr_s0 : mshr_dyn_entry_idx_ptr_s0;

    always @(posedge clk or posedge rst) begin: mshr_entry_location_timing_logic
        if (rst == 1'b1)
            mshr_entry_alloc_s1_q <= {`MSHR_ENTRIES_NUM{1'b0}};
        else if (mshr_alloc_en_s0 == 1'b1)
            mshr_entry_alloc_s1_q <= mshr_alloc_entry_s0;
    end

    //qos enqueue entry location valid.
    //  qos entry valid is set on alloc and cleared on retire.
    assign mshr_alloc_set_v_s0 = {`MSHR_ENTRIES_NUM{mshr_alloc_en_s0}} & mshr_alloc_entry_s0;

    always @* begin: retired_entry_idx_location_comb_logic
        mshr_retire_entry_s0 = {`MSHR_ENTRIES_NUM{1'b0}};
        if(mshr_dbf_retired_valid_sx1_q == 1'b1)
            mshr_retire_entry_s0[mshr_dbf_retired_idx_sx1_q] = 1'b1;
        else
            mshr_retire_entry_s0 = {`MSHR_ENTRIES_NUM{1'b0}};
    end

    assign mshr_entry_valid_flop_en_s0 = mshr_alloc_set_v_s0 | mshr_retire_entry_s0;

    genvar entry;
    generate
        for(entry=0;entry<`MSHR_ENTRIES_NUM;entry=entry+1)begin
            always @(posedge clk or posedge rst) begin: update_mshr_entry_valid_timing_logic
                if (rst == 1'b1)
                    mshr_entry_valid_s1_q[entry] <= 1'b0;
                else if (mshr_entry_valid_flop_en_s0[entry] == 1'b1)
                    mshr_entry_valid_s1_q[entry] <= mshr_alloc_set_v_s0[entry];
                else
                    ;
            end
        end
    endgenerate

    //mshr static entry valid logic
    assign hh_retire_can_convert_static_sx1 = (qos_pool_retire_class_sx1 == `QOS_CLASS_HHIGH) &
           (hhigh_present_s1);

    assign h_retire_can_convert_static_sx1  = (qos_pool_retire_class_sx1 == `QOS_CLASS_HIGH) &
           (hhigh_present_s1 | high_present_s1);

    assign m_retire_can_convert_static_sx1  = (qos_pool_retire_class_sx1 == `QOS_CLASS_MED) &
           (hhigh_present_s1 | high_present_s1 | med_present_s1);

    assign l_retire_can_convert_static_sx1  = (qos_pool_retire_class_sx1 == `QOS_CLASS_LOW) &
           (hhigh_present_s1 | high_present_s1 | med_present_s1 | low_present_s1);

    assign mshr_seq_retire_sx1  = (qos_pool_retire_class_sx1 == `QOS_CLASS_SEQ);

    assign mark_mshr_static_sx1 = mshr_dbf_retired_valid_sx1_q & ~mshr_seq_retire_sx1 &
           (hh_retire_can_convert_static_sx1 | h_retire_can_convert_static_sx1 |
            m_retire_can_convert_static_sx1  | l_retire_can_convert_static_sx1);

    assign mshr_entry_alloc_s1  = {`MSHR_ENTRIES_NUM{mshr_alloc_en_s1_q}} & mshr_entry_alloc_s1_q;

    assign mshr_static_set_s0   = ({`MSHR_ENTRIES_NUM{mark_mshr_static_sx1}} & mshr_retire_entry_s0);

    //static entry is set on mshr retired.
    //  static entry is cleared on mshr allocate (previously retried).
    assign mshr_static_en_s0 = mshr_static_set_s0 | mshr_entry_alloc_s1;
    //(mshr_retire_entry_s0 & mshr_static_entry_valid_s1_q);

    generate
        for(entry=0;entry<`MSHR_ENTRIES_NUM;entry=entry+1)begin
            always @(posedge clk or posedge rst) begin: update_mshr_static_entry_valid_timing_logic
                if (rst == 1'b1)
                    mshr_static_entry_valid_s1_q[entry] <= 1'b0;
                else if (mshr_static_en_s0[entry] == 1'b1)
                    mshr_static_entry_valid_s1_q[entry] <= mshr_static_set_s0[entry];
            end
        end
    endgenerate

    //rxreq retry enable logic
    assign rxreq_retry_enable_s0 = li_req_dyn_alloc_fail_s0 & ~li_seq_alloc_s0;

    always @(posedge clk or posedge rst) begin:update_retry_enable_timing_logic
        if (rst == 1'b1)
            rxreq_retry_enable_s1_q <= 1'b0;
        else
            rxreq_retry_enable_s1_q <= rxreq_retry_enable_s0;
    end

    //mshr qos class pool decode logic
    assign qos_class_pool_s0 = ({`QOS_CLASS_WIDTH{qos_low_pool_alloc_s0   & ~li_seq_alloc_s0}} & `QOS_CLASS_LOW  ) |
           ({`QOS_CLASS_WIDTH{qos_med_pool_alloc_s0   & ~li_seq_alloc_s0}} & `QOS_CLASS_MED  ) |
           ({`QOS_CLASS_WIDTH{qos_high_pool_alloc_s0  & ~li_seq_alloc_s0}} & `QOS_CLASS_HIGH ) |
           ({`QOS_CLASS_WIDTH{qos_hhigh_pool_alloc_s0 & ~li_seq_alloc_s0}} & `QOS_CLASS_HHIGH) |
           ({`QOS_CLASS_WIDTH{li_seq_alloc_s0                           }} & `QOS_CLASS_SEQ);

    //dynamic and seq allocate valid
    assign mshr_dyn_or_seq_alloc_s0 = li_req_dyn_alloc_s0 | li_seq_alloc_s0;

    always @(posedge clk or posedge rst) begin:update_mshr_qos_pool_timing_logic
        if (rst == 1'b1)
            qos_class_pool_s1_q <= {`QOS_CLASS_WIDTH{1'b0}};
        else if (mshr_dyn_or_seq_alloc_s0 == 1'b1)
            qos_class_pool_s1_q <= qos_class_pool_s0;
        else
            qos_class_pool_s1_q <= qos_class_pool_s1_q;
    end

    always @(posedge clk or posedge rst) begin: update_mshr_dyn_or_seq_alloc_timing_logic
        if (rst == 1'b1)
            mshr_dyn_or_seq_alloc_s1_q <= 1'b0;
        else
            mshr_dyn_or_seq_alloc_s1_q <= mshr_dyn_or_seq_alloc_s0;
    end

    assign qos_class_pool_flop_en_s1 = {`MSHR_ENTRIES_NUM{mshr_dyn_or_seq_alloc_s1_q}} & mshr_entry_alloc_s1_q;

    generate
        for(entry=0;entry<`MSHR_ENTRIES_NUM;entry=entry+1)begin
            always @(posedge clk) begin: update_mshr_pool_timing_logic
                if (qos_class_pool_flop_en_s1[entry] == 1'b1)
                    qos_class_pool_s2_q[entry] <= qos_class_pool_s1_q;
                else
                    ;
            end
        end
    endgenerate

    //hhigh pool count logic
    assign qos_hhigh_pool_alloc_s0 = qos_hhigh_pool_avail_s0 & qpc_hhigh_s0;

    assign qos_pool_hhigh_cnt_inc_s0 = li_req_dyn_alloc_s0 & qos_hhigh_pool_alloc_s0;
    assign qos_pool_hhigh_cnt_dec_s0 = mshr_dbf_retired_valid_sx1_q & ~hhigh_present_s1 &
           (qos_pool_retire_class_sx1 == `QOS_CLASS_HHIGH);

    assign hhigh_cnt_update_s0 = (qos_pool_hhigh_cnt_inc_s0 | qos_pool_hhigh_cnt_dec_s0) &
           ~(qos_pool_hhigh_cnt_inc_s0 & qos_pool_hhigh_cnt_dec_s0);

    assign qos_pool_hhigh_cnt_ns = qos_pool_hhigh_cnt_inc_s0? (qos_pool_hhigh_cnt_q + 1'b1):
           (qos_pool_hhigh_cnt_q - 1'b1);

    assign qos_pool_hhigh_full_s0 = (qos_pool_hhigh_cnt_ns == `QOS_HHIGH_POOL_NUM);

    always @(posedge clk or posedge rst) begin:update_hhigh_pool_count_timing_logic
        if (rst == 1'b1)
            qos_pool_hhigh_cnt_q <= {`QOS_POOL_CNT_WIDTH{1'b0}};
        else if (hhigh_cnt_update_s0 == 1'b1)
            qos_pool_hhigh_cnt_q <= qos_pool_hhigh_cnt_ns;
        else
            qos_pool_hhigh_cnt_q <= qos_pool_hhigh_cnt_q;
    end

    always @(posedge clk or posedge rst) begin:update_hhigh_pool_full_timing_logic
        if (rst == 1'b1)
            qos_hhigh_pool_full_s1_q <= 1'b0;
        else if (hhigh_cnt_update_s0 == 1'b1)
            qos_hhigh_pool_full_s1_q <= qos_pool_hhigh_full_s0;
        else
            qos_hhigh_pool_full_s1_q <= qos_hhigh_pool_full_s1_q;
    end

    assign qos_hhigh_pool_avail_s0 = ~qos_hhigh_pool_full_s1_q;

    //high pool count logic
    assign qos_high_pool_alloc_s0 = qos_high_pool_avail_s0 &
           (qpc_hhigh_s0 | qpc_high_s0) &
           ~(qos_hhigh_pool_alloc_s0);

    assign qos_pool_high_cnt_inc_s0 = li_req_dyn_alloc_s0 & qos_high_pool_alloc_s0;
    assign qos_pool_high_cnt_dec_s0 = mshr_dbf_retired_valid_sx1_q &
           ~(hhigh_present_s1 | high_present_s1) &
           (qos_pool_retire_class_sx1 == `QOS_CLASS_HIGH);

    assign high_cnt_update_s0 = (qos_pool_high_cnt_inc_s0 | qos_pool_high_cnt_dec_s0) &
           ~(qos_pool_high_cnt_inc_s0 & qos_pool_high_cnt_dec_s0);

    assign qos_pool_high_cnt_ns = qos_pool_high_cnt_inc_s0? (qos_pool_high_cnt_q + 1'b1):
           (qos_pool_high_cnt_q - 1'b1);

    assign qos_pool_high_full_s0 = (qos_pool_high_cnt_ns == `QOS_HIGH_POOL_NUM);

    always @(posedge clk or posedge rst) begin: update_high_pool_count_timing_logic
        if (rst == 1'b1)
            qos_pool_high_cnt_q <= {`QOS_POOL_CNT_WIDTH{1'b0}};
        else if (high_cnt_update_s0 == 1'b1)
            qos_pool_high_cnt_q <= qos_pool_high_cnt_ns;
        else
            qos_pool_high_cnt_q <= qos_pool_high_cnt_q;
    end

    always @(posedge clk or posedge rst) begin: update_high_pool_full_timing_logic
        if (rst == 1'b1)
            qos_high_pool_full_s1_q <= 1'b0;
        else if (high_cnt_update_s0 == 1'b1)
            qos_high_pool_full_s1_q <= qos_pool_high_full_s0;
        else
            qos_high_pool_full_s1_q <= qos_high_pool_full_s1_q;
    end

    assign qos_high_pool_avail_s0 = ~qos_high_pool_full_s1_q;

    //med pool count logic
    assign qos_med_pool_alloc_s0 = qos_med_pool_avail_s0 &
           (qpc_hhigh_s0 | qpc_high_s0 | qpc_med_s0) &
           ~(qos_hhigh_pool_alloc_s0 | qos_high_pool_alloc_s0);

    assign qos_pool_med_cnt_inc_s0 = li_req_dyn_alloc_s0 & qos_med_pool_alloc_s0;
    assign qos_pool_med_cnt_dec_s0 = mshr_dbf_retired_valid_sx1_q &
           ~(hhigh_present_s1 | high_present_s1 | med_present_s1) &
           (qos_pool_retire_class_sx1 == `QOS_CLASS_MED);

    assign med_cnt_update_s0 = (qos_pool_med_cnt_inc_s0 | qos_pool_med_cnt_dec_s0) &
           ~(qos_pool_med_cnt_inc_s0 & qos_pool_med_cnt_dec_s0);

    assign qos_pool_med_cnt_ns = qos_pool_med_cnt_inc_s0? (qos_pool_med_cnt_q + 1'b1):
           (qos_pool_med_cnt_q - 1'b1);

    assign qos_pool_med_full_s0 = (qos_pool_med_cnt_ns == `QOS_MED_POOL_NUM);

    always @(posedge clk or posedge rst) begin: update_med_pool_count_timing_logic
        if (rst == 1'b1)
            qos_pool_med_cnt_q <= {`QOS_POOL_CNT_WIDTH{1'b0}};
        else if (med_cnt_update_s0 == 1'b1)
            qos_pool_med_cnt_q <= qos_pool_med_cnt_ns;
        else
            qos_pool_med_cnt_q <= qos_pool_med_cnt_q;
    end

    always @(posedge clk or posedge rst) begin: update_med_pool_full_timing_logic
        if (rst == 1'b1)
            qos_med_pool_full_s1_q <= 1'b0;
        else if (med_cnt_update_s0 == 1'b1)
            qos_med_pool_full_s1_q <= qos_pool_med_full_s0;
        else
            qos_med_pool_full_s1_q <= qos_med_pool_full_s1_q;
    end

    assign qos_med_pool_avail_s0 = ~qos_med_pool_full_s1_q;

    //low pool count logic
    assign qos_low_pool_alloc_s0 = qos_low_pool_avail_s0 &
           (qpc_hhigh_s0 | qpc_high_s0 | qpc_med_s0 | qpc_low_s0) &
           ~(qos_hhigh_pool_alloc_s0 | qos_high_pool_alloc_s0 | qos_med_pool_alloc_s0);

    assign qos_pool_low_cnt_inc_s0 = li_req_dyn_alloc_s0 & qos_low_pool_alloc_s0;
    assign qos_pool_low_cnt_dec_s0 = mshr_dbf_retired_valid_sx1_q &
           ~(hhigh_present_s1 | high_present_s1 | med_present_s1 | low_present_s1) &
           (qos_pool_retire_class_sx1 == `QOS_CLASS_LOW);

    assign low_cnt_update_s0 = (qos_pool_low_cnt_inc_s0 | qos_pool_low_cnt_dec_s0) &
           ~(qos_pool_low_cnt_inc_s0 & qos_pool_low_cnt_dec_s0);

    assign qos_pool_low_cnt_ns = qos_pool_low_cnt_inc_s0? (qos_pool_low_cnt_q + 1'b1):
           (qos_pool_low_cnt_q - 1'b1);

    assign qos_pool_low_full_s0 = (qos_pool_low_cnt_ns == `QOS_LOW_POOL_NUM);

    always @(posedge clk or posedge rst) begin: update_low_pool_count_timing_logic
        if (rst == 1'b1)
            qos_pool_low_cnt_q <= {`QOS_POOL_CNT_WIDTH{1'b0}};
        else if (low_cnt_update_s0 == 1'b1)
            qos_pool_low_cnt_q <= qos_pool_low_cnt_ns;
        else
            qos_pool_low_cnt_q <= qos_pool_low_cnt_q;
    end

    always @(posedge clk or posedge rst) begin: update_low_pool_full_timing_logic
        if (rst == 1'b1)
            qos_low_pool_full_s1_q <= 1'b0;
        else if (low_cnt_update_s0 == 1'b1)
            qos_low_pool_full_s1_q <= qos_pool_low_full_s0;
        else
            qos_low_pool_full_s1_q <= qos_low_pool_full_s1_q;
    end

    assign qos_low_pool_avail_s0 = ~qos_low_pool_full_s1_q;

    //seq pool count logic
    assign seq_inc_cnt_s0 = li_seq_alloc_s0;

    assign seq_dec_cnt_s0 = mshr_dbf_retired_valid_sx1_q  &&
           (qos_pool_retire_class_sx1 == `QOS_CLASS_SEQ);

    always @(posedge clk or posedge rst) begin: update_seq_pool_count_timing_logic
        if (rst == 1'b1)
            qos_seq_pool_full_s0_q <= 1'b0;
        else if (seq_inc_cnt_s0 == 1'b1)
            qos_seq_pool_full_s0_q <= 1'b1;
        else if (seq_dec_cnt_s0 ==  1'b1)
            qos_seq_pool_full_s0_q <= 1'b0;
        else
            qos_seq_pool_full_s0_q <= qos_seq_pool_full_s0_q;
    end

    assign qos_seq_pool_avail_s0 = ~qos_seq_pool_full_s0_q;

    assign qos_pool_retire_class_sx1 = qos_class_pool_s2_q[mshr_dbf_retired_idx_sx1_q];

    //retry pcrdtype field encode logic
    //  qos is QOS_CLASS_LOW   ,pcrdtype = 0
    //  qos is QOS_CLASS_MED   ,pcrdtype = 1
    //  qos is QOS_CLASS_HIGH  ,pcrdtype = 2
    //  qos is QOS_CLASS_HHIGH ,pcrdtype = 3

    assign hnf_pcrdtype_enable_sx = 1'b1;
    assign li_mshr_rxreq_pcrdtype_s0[0] = (qpc_hhigh_s0 | qpc_med_s0 ) & hnf_pcrdtype_enable_sx;
    assign li_mshr_rxreq_pcrdtype_s0[1] = (qpc_hhigh_s0 | qpc_high_s0) & hnf_pcrdtype_enable_sx;

    //retry_ack_fifo flit assamble
    assign retry_ackq_datain_s0[`RETRY_ACKQ_SRCID_RANGE]    = li_mshr_rxreq_srcid_s0;
    assign retry_ackq_datain_s0[`RETRY_ACKQ_TXNID_RANGE]    = li_mshr_rxreq_txnid_s0;
    assign retry_ackq_datain_s0[`RETRY_ACKQ_QOS_RANGE]      = li_mshr_rxreq_qos_s0;
    assign retry_ackq_datain_s0[`RETRY_ACKQ_TRACE_RANGE]    = li_mshr_rxreq_tracetag_s0;
    assign retry_ackq_datain_s0[`RETRY_ACKQ_PCRDTYPE_RANGE] = { 2'b0, li_mshr_rxreq_pcrdtype_s0[1:0]};

    assign retry_ack_fifo_push = rxreq_retry_enable_s0 & (~retry_ack_fifo_full | (retry_ack_fifo_full & txrsp_mshr_retryack_won_s1));
    assign retry_ack_fifo_pop  = txrsp_mshr_retryack_won_s1 & ~retry_ack_fifo_empty;

    hnf_fifo #(
                 .FIFO_ENTRIES_WIDTH (`RETRY_ACKQ_DATA_WIDTH    ),
                 .FIFO_ENTRIES_DEPTH (`RETRY_ACKQ_DATA_DEPTH    )
             )retry_ack_fifo(
                 .clk       (clk                       ),
                 .rst       (rst                       ),
                 .wr_en     (retry_ack_fifo_push       ),
                 .wr_data   (retry_ackq_datain_s0      ),
                 .rd_en     (retry_ack_fifo_pop        ),
                 .rd_data   (retry_ack_fifo_dataout_s1 ),
                 .empty     (retry_ack_fifo_empty      ),
                 .full      (retry_ack_fifo_full       ),
                 .fifo_cnt  (                          )
             );

    //retry_ack_fifo flit disassamble
    assign qos_txrsp_retryack_valid_s1    = ~retry_ack_fifo_empty;
    assign qos_txrsp_retryack_qos_s1      = retry_ack_fifo_dataout_s1[`RETRY_ACKQ_QOS_RANGE];
    assign qos_txrsp_retryack_tgtid_s1    = retry_ack_fifo_dataout_s1[`RETRY_ACKQ_SRCID_RANGE];
    assign qos_txrsp_retryack_txnid_s1    = retry_ack_fifo_dataout_s1[`RETRY_ACKQ_TXNID_RANGE];
    assign qos_txrsp_retryack_pcrdtype_s1 = retry_ack_fifo_dataout_s1[`RETRY_ACKQ_PCRDTYPE_RANGE];
    assign qos_txrsp_retryack_tracetag_s1 = retry_ack_fifo_dataout_s1[`RETRY_ACKQ_TRACE_RANGE];

    //retry bank logic
    //retry bank srcid match logic
    genvar ret_entry;
    generate
        for(ret_entry=0; ret_entry<`RET_BANK_ENTRIES_NUM;ret_entry=ret_entry+1)begin
            assign ret_bank_srcid_match_vec_s0[ret_entry] = (li_mshr_rxreq_srcid_s0 == ret_bank_srcid_s1_q[ret_entry]) & ret_bank_entry_v_s1_q[ret_entry];
        end
    endgenerate

    //qualify retry bank allocation
    assign ret_bank_alloc_en_s0  = li_mshr_rxreq_valid_s0 & ~(|ret_bank_srcid_match_vec_s0) & ~li_seq_alloc_s0;

    //update next retry bank entry index
    always @(posedge clk or posedge rst) begin: update_next_ret_bank_idx_timing_logic
        if (rst == 1'b1)
            ret_bank_entry_idx_s1_q <= {`RET_BANK_ENTRIES_WIDTH{1'b0}};
        else if (ret_bank_alloc_en_s0 == 1'b1)
            ret_bank_entry_idx_s1_q <= ret_bank_entry_idx_s1_q + 1'b1;
        else
            ret_bank_entry_idx_s1_q <= ret_bank_entry_idx_s1_q;
    end

    always @* begin:pass_ret_bank_alloc_idx_to_ptr
        integer i;
        ret_bank_entry_ptr_s0 = {`RET_BANK_ENTRIES_NUM{1'b0}};
        for (i=0; i<`RET_BANK_ENTRIES_NUM; i=i+1)
            ret_bank_entry_ptr_s0[i] = (ret_bank_entry_idx_s1_q == i);
    end

    //update retry bank entry valid
    assign ret_bank_entry_v_s0 = {`RET_BANK_ENTRIES_NUM{ret_bank_alloc_en_s0}} & ret_bank_entry_ptr_s0;

    generate
        for(ret_entry=0; ret_entry<`RET_BANK_ENTRIES_NUM;ret_entry=ret_entry+1)begin
            always @(posedge clk or posedge rst) begin: update_ret_bank_entry_valid_timing_logic
                if (rst == 1'b1)
                    ret_bank_entry_v_s1_q[ret_entry] <= 1'b0;
                else if (ret_bank_entry_v_s0[ret_entry] == 1'b1)
                    ret_bank_entry_v_s1_q[ret_entry] <= ret_bank_entry_v_s0[ret_entry];
            end
        end
    endgenerate

    //update retry bank srcid entry
    generate
        for(ret_entry=0;ret_entry< `RET_BANK_ENTRIES_NUM;ret_entry=ret_entry+1) begin: update_retry_bank_srcid_pool_timing_logic
            always @(posedge clk)begin
                if (ret_bank_entry_v_s0[ret_entry] == 1'b1)
                    ret_bank_srcid_s1_q[ret_entry] <= li_mshr_rxreq_srcid_s0;
                else
                    ;
            end
        end
    endgenerate

    //update retry bank count pointer
    assign ret_cnt_inc_ptr_s0 = ret_bank_alloc_en_s0? ret_bank_entry_ptr_s0 : ret_bank_srcid_match_vec_s0;

    always @(posedge clk or posedge rst) begin: update_retry_bank_cnt_ptr_timing_logic
        if (rst == 1'b1)
            ret_cnt_inc_ptr_s1_q <= {`RET_BANK_ENTRIES_NUM{1'b0}};
        else if (li_mshr_rxreq_valid_s0 == 1'b1)
            ret_cnt_inc_ptr_s1_q <= ret_cnt_inc_ptr_s0;
        else
            ret_cnt_inc_ptr_s1_q <= ret_cnt_inc_ptr_s1_q;
    end

    //update hhigh class
    always @(posedge clk or posedge rst) begin: update_hhigh_class_timing_logic
        if (rst == 1'b1)
            qpc_hhigh_s1_q <= 1'b0;
        else if (li_mshr_rxreq_valid_s0 == 1'b1)
            qpc_hhigh_s1_q <= qpc_hhigh_s0;
        else
            qpc_hhigh_s1_q <= qpc_hhigh_s1_q;
    end

    //update high class
    always @(posedge clk or posedge rst) begin: update_high_class_timing_logic
        if (rst == 1'b1)
            qpc_high_s1_q <= 1'b0;
        else if (li_mshr_rxreq_valid_s0 == 1'b1)
            qpc_high_s1_q <= qpc_high_s0;
        else
            qpc_high_s1_q <= qpc_high_s1_q;
    end

    //update med class
    always @(posedge clk or posedge rst) begin: update_med_class_timing_logic
        if (rst == 1'b1)
            qpc_med_s1_q <= 1'b0;
        else if (li_mshr_rxreq_valid_s0 == 1'b1)
            qpc_med_s1_q <= qpc_med_s0;
        else
            qpc_med_s1_q <= qpc_med_s1_q;
    end

    //update low class
    always @(posedge clk or posedge rst) begin: update_low_class_timing_logic
        if (rst == 1'b1)
            qpc_low_s1_q <= 1'b0;
        else if (li_mshr_rxreq_valid_s0 == 1'b1)
            qpc_low_s1_q <= qpc_low_s0;
        else
            qpc_low_s1_q <= qpc_low_s1_q;
    end

    //retry bank qos class cnt logic
    assign ret_is_hh_s1 = rxreq_retry_enable_s1_q & qpc_hhigh_s1_q;

    assign ret_is_h_s1 = rxreq_retry_enable_s1_q & qpc_high_s1_q;

    assign ret_is_m_s1 = rxreq_retry_enable_s1_q & qpc_med_s1_q;

    assign ret_is_l_s1 = rxreq_retry_enable_s1_q & qpc_low_s1_q;

    generate
        for(ret_entry=0;ret_entry<`RET_BANK_ENTRIES_NUM;ret_entry=ret_entry+1)begin
            //retry bank hhigh count
            assign ret_cnt_hh_inc_s1[ret_entry] = ret_is_hh_s1 & ret_cnt_inc_ptr_s1_q[ret_entry];
            assign ret_cnt_hh_dec_s1[ret_entry] = (hh_present_win_s2_q & ~ret_cnt_hh_zero[ret_entry] & ret_cnt_hh_dec_ptr_s2_q[ret_entry]);
            assign ret_cnt_hh_en_s1[ret_entry] = ret_cnt_hh_inc_s1[ret_entry] | ret_cnt_hh_dec_s1[ret_entry];

            always @* begin: determine_hh_entry_cnt_update_comb_logic
                casez({ret_cnt_hh_inc_s1[ret_entry], ret_cnt_hh_dec_s1[ret_entry]})
                    2'b10:
                        ret_cnt_hh_entry_ns_s1[ret_entry] = ret_cnt_hh_entry_s2_q[ret_entry]+1'b1;
                    2'b01:
                        ret_cnt_hh_entry_ns_s1[ret_entry] = ret_cnt_hh_entry_s2_q[ret_entry]-1'b1;
                    2'b11:
                        ret_cnt_hh_entry_ns_s1[ret_entry] = ret_cnt_hh_entry_s2_q[ret_entry];
                    default:
                        ret_cnt_hh_entry_ns_s1[ret_entry] = ret_cnt_hh_entry_s2_q[ret_entry];
                endcase
            end

            always @(posedge clk or posedge rst) begin: update_hh_entry_cnt_timing_logic
                if (rst == 1'b1)
                    ret_cnt_hh_entry_s2_q[ret_entry]<= {`RET_BANK_CNT_WIDTH{1'b0}};
                else if (ret_cnt_hh_en_s1[ret_entry] == 1'b1)
                    ret_cnt_hh_entry_s2_q[ret_entry] <= ret_cnt_hh_entry_ns_s1[ret_entry];
            end

            assign ret_cnt_hh_zero[ret_entry] = ret_cnt_hh_entry_s2_q[ret_entry] == {`RET_BANK_CNT_WIDTH{1'b0}};

            //retry bank high count
            assign ret_cnt_h_inc_s1[ret_entry] = ret_is_h_s1 & ret_cnt_inc_ptr_s1_q[ret_entry];
            assign ret_cnt_h_dec_s1[ret_entry] = (h_present_win_s2_q & ~ret_cnt_h_zero[ret_entry] & ret_cnt_h_dec_ptr_s2_q[ret_entry]);
            assign ret_cnt_h_en_s1[ret_entry] = ret_cnt_h_inc_s1[ret_entry] | ret_cnt_h_dec_s1[ret_entry];

            always @* begin: determine_h_entry_cnt_update_comb_logic
                casez({ret_cnt_h_inc_s1[ret_entry], ret_cnt_h_dec_s1[ret_entry]})
                    2'b10:
                        ret_cnt_h_entry_ns_s1[ret_entry] = ret_cnt_h_entry_s2_q[ret_entry]+1'b1;
                    2'b01:
                        ret_cnt_h_entry_ns_s1[ret_entry] = ret_cnt_h_entry_s2_q[ret_entry]-1'b1;
                    2'b11:
                        ret_cnt_h_entry_ns_s1[ret_entry] = ret_cnt_h_entry_s2_q[ret_entry];
                    default:
                        ret_cnt_h_entry_ns_s1[ret_entry] = ret_cnt_h_entry_s2_q[ret_entry];
                endcase
            end

            always @(posedge clk or posedge rst) begin: update_h_entry_cnt_timing_logic
                if (rst == 1'b1)
                    ret_cnt_h_entry_s2_q[ret_entry]<= {`RET_BANK_CNT_WIDTH{1'b0}};
                else if (ret_cnt_h_en_s1[ret_entry] == 1'b1)
                    ret_cnt_h_entry_s2_q[ret_entry] <= ret_cnt_h_entry_ns_s1[ret_entry];
            end

            assign ret_cnt_h_zero[ret_entry]  = ret_cnt_h_entry_s2_q[ret_entry] == {`RET_BANK_CNT_WIDTH{1'b0}};

            //retry bank med count
            assign ret_cnt_m_inc_s1[ret_entry]  = ret_is_m_s1  & ret_cnt_inc_ptr_s1_q[ret_entry];
            assign ret_cnt_m_dec_s1[ret_entry]  = (m_present_win_s2_q & ~ret_cnt_m_zero[ret_entry] & ret_cnt_m_dec_ptr_s2_q[ret_entry]);
            assign ret_cnt_m_en_s1[ret_entry] = ret_cnt_m_inc_s1[ret_entry] | ret_cnt_m_dec_s1[ret_entry];

            always @* begin: determine_m_entry_cnt_update_comb_logic
                casez({ret_cnt_m_inc_s1[ret_entry], ret_cnt_m_dec_s1[ret_entry]})
                    2'b10:
                        ret_cnt_m_entry_ns_s1[ret_entry] = ret_cnt_m_entry_s2_q[ret_entry]+1'b1;
                    2'b01:
                        ret_cnt_m_entry_ns_s1[ret_entry] = ret_cnt_m_entry_s2_q[ret_entry]-1'b1;
                    2'b11:
                        ret_cnt_m_entry_ns_s1[ret_entry] = ret_cnt_m_entry_s2_q[ret_entry];
                    default:
                        ret_cnt_m_entry_ns_s1[ret_entry] = ret_cnt_m_entry_s2_q[ret_entry];
                endcase
            end

            always @(posedge clk or posedge rst) begin: update_m_entry_cnt_timing_logic
                if (rst == 1'b1)
                    ret_cnt_m_entry_s2_q[ret_entry]<= {`RET_BANK_CNT_WIDTH{1'b0}};
                else if (ret_cnt_m_en_s1[ret_entry] == 1'b1)
                    ret_cnt_m_entry_s2_q[ret_entry] <= ret_cnt_m_entry_ns_s1[ret_entry];
            end

            assign ret_cnt_m_zero[ret_entry]  = ret_cnt_m_entry_s2_q[ret_entry] == {`RET_BANK_CNT_WIDTH{1'b0}};

            //retry bank low count
            assign ret_cnt_l_inc_s1[ret_entry] = ret_is_l_s1 & ret_cnt_inc_ptr_s1_q[ret_entry];
            assign ret_cnt_l_dec_s1[ret_entry] = (l_present_win_s2_q & ~ret_cnt_l_zero[ret_entry] & ret_cnt_l_dec_ptr_s2_q[ret_entry]);
            assign ret_cnt_l_en_s1[ret_entry] = ret_cnt_l_inc_s1[ret_entry] | ret_cnt_l_dec_s1[ret_entry];

            always @* begin: determine_l_entry_cnt_update_comb_logic
                casez({ret_cnt_l_inc_s1[ret_entry], ret_cnt_l_dec_s1[ret_entry]})
                    2'b10:
                        ret_cnt_l_entry_ns_s1[ret_entry] = ret_cnt_l_entry_s2_q[ret_entry]+1'b1;
                    2'b01:
                        ret_cnt_l_entry_ns_s1[ret_entry] = ret_cnt_l_entry_s2_q[ret_entry]-1'b1;
                    2'b11:
                        ret_cnt_l_entry_ns_s1[ret_entry] = ret_cnt_l_entry_s2_q[ret_entry];
                    default:
                        ret_cnt_l_entry_ns_s1[ret_entry] = ret_cnt_l_entry_s2_q[ret_entry];
                endcase
            end

            always @(posedge clk or posedge rst) begin: update_l_entry_cnt_timing_logic
                if (rst == 1'b1)
                    ret_cnt_l_entry_s2_q[ret_entry]<= {`RET_BANK_CNT_WIDTH{1'b0}};
                else if (ret_cnt_l_en_s1[ret_entry] == 1'b1)
                    ret_cnt_l_entry_s2_q[ret_entry] <= ret_cnt_l_entry_ns_s1[ret_entry];
            end

            assign ret_cnt_l_zero[ret_entry]  = ret_cnt_l_entry_s2_q[ret_entry] == {`RET_BANK_CNT_WIDTH{1'b0}};
        end
    endgenerate

    assign hh_req_entry_s1 = (ret_bank_entry_v_s1_q & ~ret_cnt_hh_zero) | ret_cnt_hh_inc_s1;

    assign h_req_entry_s1 = (ret_bank_entry_v_s1_q & ~ret_cnt_h_zero) | ret_cnt_h_inc_s1;

    assign m_req_entry_s1 = (ret_bank_entry_v_s1_q & ~ret_cnt_m_zero) | ret_cnt_m_inc_s1;

    assign l_req_entry_s1 = (ret_bank_entry_v_s1_q & ~ret_cnt_l_zero) | ret_cnt_l_inc_s1;

    assign hhigh_present_s1 = (|hh_req_entry_s1) | ret_is_hh_s1;

    assign high_present_s1 = (|h_req_entry_s1) | ret_is_h_s1;

    assign med_present_s1 = (|m_req_entry_s1) | ret_is_m_s1;

    assign low_present_s1 = (|l_req_entry_s1) | ret_is_l_s1;

    //pcrdgrant and starvation logic
    //disable logic
    assign h_to_hh_disable = (h_wait_cnt_q  == `HIGH2HHIGH_MAX_CNT) & high_present_s1 & mshr_dbf_retired_valid_sx1_q & (qos_pool_retire_class_sx1 <= `QOS_CLASS_HIGH);
    assign m_to_hh_disable = (m_wait_cnt_q  == `MED2HHIGH_MAX_CNT ) & med_present_s1  & mshr_dbf_retired_valid_sx1_q & (qos_pool_retire_class_sx1 <= `QOS_CLASS_MED);
    assign l_to_hh_disable = (l_wait_cnt_q  == `LOW2HHIGH_MAX_CNT ) & low_present_s1  & mshr_dbf_retired_valid_sx1_q & (qos_pool_retire_class_sx1 == `QOS_CLASS_LOW);
    assign m_to_h_disable  = (m_wait_cnt_q  >= `MED2HIGH_MAX_CNT  ) & med_present_s1  & mshr_dbf_retired_valid_sx1_q & (qos_pool_retire_class_sx1 <= `QOS_CLASS_MED);
    assign l_to_h_disbale  = (l_wait_cnt_q  >= `LOW2HIGH_MAX_CNT  ) & low_present_s1  & mshr_dbf_retired_valid_sx1_q & (qos_pool_retire_class_sx1 == `QOS_CLASS_LOW);
    assign l_to_m_disable  = (l_wait_cnt_q  >= `LOW2MED_MAX_CNT   ) & low_present_s1  & mshr_dbf_retired_valid_sx1_q & (qos_pool_retire_class_sx1 == `QOS_CLASS_LOW);

    //hhigh present win logic
    assign hhigh_disable = h_to_hh_disable | m_to_hh_disable | l_to_hh_disable ;

    assign hh_present_win = hhigh_present_s1 & mshr_dbf_retired_valid_sx1_q & ~hhigh_disable & (qos_pool_retire_class_sx1 <= `QOS_CLASS_HHIGH);
    assign hh_present_win_s1 = hh_present_win;

    always @(posedge clk or posedge rst) begin: update_hh_present_win_timing_logic
        if (rst == 1'b1)
            hh_present_win_s2_q <= 1'b0;
        else
            hh_present_win_s2_q <= hh_present_win_s1;
    end

    //high present win logic
    assign high_disable = (m_to_h_disable & ~h_to_hh_disable) | m_to_hh_disable | (l_to_h_disbale & ~h_to_hh_disable) | l_to_hh_disable;

    assign h_present_win = high_present_s1 & mshr_dbf_retired_valid_sx1_q & ~high_disable & (qos_pool_retire_class_sx1 <= `QOS_CLASS_HIGH);
    assign h_present_win_s1 = ~hh_present_win & h_present_win;

    always @(posedge clk or posedge rst) begin: update_h_present_win_timing_logic
        if (rst == 1'b1)
            h_present_win_s2_q <= 1'b0;
        else
            h_present_win_s2_q <= h_present_win_s1;
    end

    //med present win logic
    assign med_disable = (l_to_m_disable & ~(m_to_h_disable | h_to_hh_disable)) | (l_to_h_disbale & ~m_to_hh_disable) | l_to_hh_disable;

    assign m_present_win = med_present_s1 & mshr_dbf_retired_valid_sx1_q & ~med_disable & (qos_pool_retire_class_sx1 <= `QOS_CLASS_MED);
    assign m_present_win_s1 = ~hh_present_win & ~h_present_win & m_present_win;

    always @(posedge clk or posedge rst) begin: update_m_present_win_timing_logic
        if (rst == 1'b1)
            m_present_win_s2_q <= 1'b0;
        else
            m_present_win_s2_q <= m_present_win_s1;
    end

    //low present win logic
    assign l_present_win = low_present_s1 & mshr_dbf_retired_valid_sx1_q & (qos_pool_retire_class_sx1 == `QOS_CLASS_LOW);
    assign l_present_win_s1 = ~hh_present_win & ~h_present_win & ~m_present_win & l_present_win;

    always @(posedge clk or posedge rst) begin: update_l_present_win_timing_logic
        if (rst == 1'b1)
            l_present_win_s2_q <= 1'b0;
        else
            l_present_win_s2_q <= l_present_win_s1;
    end

    //htohh count logic
    assign h_wait_lost = high_present_s1 & mshr_dbf_retired_valid_sx1_q & (qos_pool_retire_class_sx1 <= `QOS_CLASS_HIGH) & ~h_present_win_s1;
    assign h_wait_cnt_inc = h_wait_lost & ~(h_wait_cnt_q == `HIGH2HHIGH_MAX_CNT);
    assign h_wait_cnt_rst = h_present_win_s1;

    always @* begin: determine_high_wait_cnt_update_comb_logic
        casez({h_wait_cnt_rst, h_wait_cnt_inc})
            2'b00:
                h_wait_cnt_ns = h_wait_cnt_q;
            2'b01:
                h_wait_cnt_ns = h_wait_cnt_q + 1'b1;
            2'b1?:
                h_wait_cnt_ns = {`MAX_WAIT_CNT_WIDTH{1'b0}};
            default:
                h_wait_cnt_ns = {`MAX_WAIT_CNT_WIDTH{1'b0}};
        endcase
    end

    assign h_wait_cnt_upd_en = h_wait_cnt_inc | h_wait_cnt_rst;

    always @(posedge clk or posedge rst) begin: update_high_to_hhigh_timing_logic
        if (rst == 1'b1)
            h_wait_cnt_q <= {`MAX_WAIT_CNT_WIDTH{1'b0}};
        else if (h_wait_cnt_upd_en == 1'b1)
            h_wait_cnt_q <= h_wait_cnt_ns;
        else
            h_wait_cnt_q <= h_wait_cnt_q;
    end

    //m_wait count logic
    assign m_wait_lost = med_present_s1 & mshr_dbf_retired_valid_sx1_q & (qos_pool_retire_class_sx1 <= `QOS_CLASS_MED) & ~m_present_win_s1;
    assign m_wait_cnt_inc = m_wait_lost & ~(m_wait_cnt_q == `MED2HHIGH_MAX_CNT);
    assign m_wait_cnt_rst = m_present_win_s1;

    always @* begin: determine_med_cnt_update_comb_logic
        casez({m_wait_cnt_rst, m_wait_cnt_inc})
            2'b00:
                m_wait_cnt_ns = m_wait_cnt_q;
            2'b01:
                m_wait_cnt_ns = m_wait_cnt_q + 1'b1;
            2'b1?:
                m_wait_cnt_ns = {`MAX_WAIT_CNT_WIDTH{1'b0}};
            default:
                m_wait_cnt_ns = {`MAX_WAIT_CNT_WIDTH{1'b0}};
        endcase
    end

    assign m_wait_cnt_upd_en = m_wait_cnt_inc | m_wait_cnt_rst;

    always @(posedge clk or posedge rst) begin: update_med_to_hhigh_timing_logic
        if (rst == 1'b1)
            m_wait_cnt_q <= {`MAX_WAIT_CNT_WIDTH{1'b0}};
        else if (m_wait_cnt_upd_en == 1'b1)
            m_wait_cnt_q <= m_wait_cnt_ns;
        else
            m_wait_cnt_q <= m_wait_cnt_q;
    end

    //ltohh count logic
    assign l_wait_lost = l_present_win & ~l_present_win_s1;
    assign l_wait_cnt_inc = l_wait_lost & ~(l_wait_cnt_q == `LOW2HHIGH_MAX_CNT);
    assign l_wait_cnt_rst = l_present_win_s1;

    always @* begin: determine_low_wait_cnt_update_comb_logic
        casez({l_wait_cnt_rst, l_wait_cnt_inc})
            2'b00:
                l_wait_cnt_ns = l_wait_cnt_q;
            2'b01:
                l_wait_cnt_ns = l_wait_cnt_q + 1'b1;
            2'b1?:
                l_wait_cnt_ns = {`MAX_WAIT_CNT_WIDTH{1'b0}};
            default:
                l_wait_cnt_ns = {`MAX_WAIT_CNT_WIDTH{1'b0}};
        endcase
    end

    assign l_wait_upd_en = l_wait_cnt_inc | l_wait_cnt_rst;

    always @(posedge clk or posedge rst) begin: update_low_to_hhigh_timing_logic
        if (rst == 1'b1)
            l_wait_cnt_q <= {`MAX_WAIT_CNT_WIDTH{1'b0}};
        else if (l_wait_upd_en == 1'b1)
            l_wait_cnt_q <= l_wait_cnt_ns;
        else
            l_wait_cnt_q <= l_wait_cnt_q;
    end

    //pcrdgrant enable logic
    assign pcrdgnt_req_enable_s1 = hh_present_win_s1 | h_present_win_s1 | m_present_win_s1 | l_present_win_s1;

    always @(posedge clk or posedge rst) begin: update_pcrdgrant_enable_timing_logic
        if (rst == 1'b1)
            pcrdgnt_req_enable_s2_q <= 1'b0;
        else
            pcrdgnt_req_enable_s2_q <= pcrdgnt_req_enable_s1;
    end

    //hh pcrdgrant srcid logic
    hnf_sel_bit_from_nxt `HNF_PARAM_INST
                         hh_hnf_sel_bit_from_nxt(
                             .clk               (clk                  ),
                             .rst               (rst                  ),
                             .req_entry_vec     (hh_req_entry_s1      ),
                             .upd_start_entry   (hh_present_win_s1    ),
                             .req_entry_ptr_sel (ret_cnt_hh_dec_ptr_s1)
                         );

    always @(posedge clk or posedge rst) begin: update_hhigh_cnt_dec_ptr_timing_logic
        if (rst == 1'b1)
            ret_cnt_hh_dec_ptr_s2_q <= {`RET_BANK_ENTRIES_NUM{1'b0}};
        else
            ret_cnt_hh_dec_ptr_s2_q <= ret_cnt_hh_dec_ptr_s1;
    end

    always @* begin: hhigh_pcrdgrant_srcid_comb_logic
        integer i;
        hh_pcrdgrant_srcid_s1 = {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        for (i=0; i<`RET_BANK_ENTRIES_NUM; i=i+1)
            hh_pcrdgrant_srcid_s1 = hh_pcrdgrant_srcid_s1 | ({`CHIE_REQ_FLIT_SRCID_WIDTH{ret_cnt_hh_dec_ptr_s1[i]}} & ret_bank_srcid_s1_q[i]);
    end

    always @(posedge clk or posedge rst) begin: update_hhigh_pcrdgrant_srcid_timing_logic
        if (rst == 1'b1)
            hh_pcrdgrant_srcid_s2_q <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        else if (mshr_dbf_retired_valid_sx1_q == 1'b1)
            hh_pcrdgrant_srcid_s2_q <= hh_pcrdgrant_srcid_s1;
        else
            hh_pcrdgrant_srcid_s2_q <= hh_pcrdgrant_srcid_s2_q;
    end

    //h pcrdgrant srcid logic
    hnf_sel_bit_from_nxt `HNF_PARAM_INST
                         h_hnf_sel_bit_from_nxt(
                             .clk               (clk                 ),
                             .rst               (rst                 ),
                             .req_entry_vec     (h_req_entry_s1      ),
                             .upd_start_entry   (h_present_win_s1    ),
                             .req_entry_ptr_sel (ret_cnt_h_dec_ptr_s1)
                         );

    always @(posedge clk or posedge rst) begin: update_high_cnt_dec_ptr_timing_logic
        if (rst == 1'b1)
            ret_cnt_h_dec_ptr_s2_q <= {`RET_BANK_ENTRIES_NUM{1'b0}};
        else
            ret_cnt_h_dec_ptr_s2_q <= ret_cnt_h_dec_ptr_s1;
    end

    always @* begin: high_pcrdgrant_srcid_comb_logic
        integer i;
        h_pcrdgrant_srcid_s1 = {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        for (i=0; i<`RET_BANK_ENTRIES_NUM; i=i+1)
            h_pcrdgrant_srcid_s1 = h_pcrdgrant_srcid_s1 | ({`CHIE_REQ_FLIT_SRCID_WIDTH{ret_cnt_h_dec_ptr_s1[i]}} & ret_bank_srcid_s1_q[i]);
    end

    always @(posedge clk or posedge rst) begin: update_high_pcrdgrant_srcid_timing_logic
        if (rst == 1'b1)
            h_pcrdgrant_srcid_s2_q <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        else if (mshr_dbf_retired_valid_sx1_q == 1'b1)
            h_pcrdgrant_srcid_s2_q <= h_pcrdgrant_srcid_s1;
        else
            h_pcrdgrant_srcid_s2_q <= h_pcrdgrant_srcid_s2_q;
    end

    //m pcrdgrant srcid logic
    hnf_sel_bit_from_nxt `HNF_PARAM_INST
                         m_hnf_sel_bit_from_nxt(
                             .clk               (clk                 ),
                             .rst               (rst                 ),
                             .req_entry_vec     (m_req_entry_s1      ),
                             .upd_start_entry   (m_present_win_s1    ),
                             .req_entry_ptr_sel (ret_cnt_m_dec_ptr_s1)
                         );

    always @(posedge clk or posedge rst) begin: update_med_cnt_dec_ptr_timing_logic
        if (rst == 1'b1)
            ret_cnt_m_dec_ptr_s2_q <= {`RET_BANK_ENTRIES_NUM{1'b0}};
        else
            ret_cnt_m_dec_ptr_s2_q <= ret_cnt_m_dec_ptr_s1;
    end

    always @* begin: med_pcrdgrant_srcid_comb_logic
        integer i;
        m_pcrdgrant_srcid_s1 = {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        for (i=0; i<`RET_BANK_ENTRIES_NUM; i=i+1)
            m_pcrdgrant_srcid_s1 = m_pcrdgrant_srcid_s1 | ({`CHIE_REQ_FLIT_SRCID_WIDTH{ret_cnt_m_dec_ptr_s1[i]}} & ret_bank_srcid_s1_q[i]);
    end

    always @(posedge clk or posedge rst) begin: update_med_pcrdgrant_srcid_timing_logic
        if (rst == 1'b1)
            m_pcrdgrant_srcid_s2_q <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        else if (mshr_dbf_retired_valid_sx1_q == 1'b1)
            m_pcrdgrant_srcid_s2_q <= m_pcrdgrant_srcid_s1;
        else
            m_pcrdgrant_srcid_s2_q <= m_pcrdgrant_srcid_s2_q;
    end

    //l pcrdgrant srcid logic
    hnf_sel_bit_from_nxt `HNF_PARAM_INST
                         l_hnf_sel_bit_from_nxt(
                             .clk               (clk                 ),
                             .rst               (rst                 ),
                             .req_entry_vec     (l_req_entry_s1      ),
                             .upd_start_entry   (l_present_win_s1    ),
                             .req_entry_ptr_sel (ret_cnt_l_dec_ptr_s1)
                         );

    always @(posedge clk or posedge rst) begin: update_low_cnt_dec_ptr_timing_logic
        if (rst == 1'b1)
            ret_cnt_l_dec_ptr_s2_q <= {`RET_BANK_ENTRIES_NUM{1'b0}};
        else
            ret_cnt_l_dec_ptr_s2_q <= ret_cnt_l_dec_ptr_s1;
    end

    always @* begin: low_pcrdgrant_srcid_comb_logic
        integer i;
        l_pcrdgrant_srcid_s1 = {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        for (i=0; i<`RET_BANK_ENTRIES_NUM; i=i+1)
            l_pcrdgrant_srcid_s1 = l_pcrdgrant_srcid_s1 | ({`CHIE_REQ_FLIT_SRCID_WIDTH{ret_cnt_l_dec_ptr_s1[i]}} & ret_bank_srcid_s1_q[i]);
    end

    always @(posedge clk or posedge rst) begin: update_low_pcrdgrant_srcid_timing_logic
        if (rst == 1'b1)
            l_pcrdgrant_srcid_s2_q <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        else if (mshr_dbf_retired_valid_sx1_q == 1'b1)
            l_pcrdgrant_srcid_s2_q <= l_pcrdgrant_srcid_s1;
        else
            l_pcrdgrant_srcid_s2_q <= l_pcrdgrant_srcid_s2_q;
    end

    //arbitrate pcrdgrant srcid
    assign pcrdgnt_srcid_s2 = ({`CHIE_REQ_FLIT_SRCID_WIDTH{hh_present_win_s2_q}} & hh_pcrdgrant_srcid_s2_q) |
           ({`CHIE_REQ_FLIT_SRCID_WIDTH{h_present_win_s2_q}}  & h_pcrdgrant_srcid_s2_q)  |
           ({`CHIE_REQ_FLIT_SRCID_WIDTH{m_present_win_s2_q}}  & m_pcrdgrant_srcid_s2_q)  |
           ({`CHIE_REQ_FLIT_SRCID_WIDTH{l_present_win_s2_q}}  & l_pcrdgrant_srcid_s2_q)  ;

    //arbitrate pcrdgrant qos
    assign pcrdgnt_qos_s2 = ({`CHIE_REQ_FLIT_QOS_WIDTH{hh_present_win_s2_q}} & `CHIE_REQ_FLIT_QOS_WIDTH'hf) |
           ({`CHIE_REQ_FLIT_QOS_WIDTH{h_present_win_s2_q}}  & `CHIE_REQ_FLIT_QOS_WIDTH'hd) |
           ({`CHIE_REQ_FLIT_QOS_WIDTH{m_present_win_s2_q}}  & `CHIE_REQ_FLIT_QOS_WIDTH'h9) |
           ({`CHIE_REQ_FLIT_QOS_WIDTH{l_present_win_s2_q}}  & `CHIE_REQ_FLIT_QOS_WIDTH'h0) ;

    //generate pcrdgrant pcrdtype
    always @*begin
        pcrdgnt_pcrdtype_s2    = {`CHIE_REQ_FLIT_PCRDTYPE_WIDTH{1'b0}};
        pcrdgnt_pcrdtype_s2[0] = hh_present_win_s2_q | m_present_win_s2_q;
        pcrdgnt_pcrdtype_s2[1] = hh_present_win_s2_q | h_present_win_s2_q;
    end

    //encode pcrdgrant part fields to fifo
    assign pcrdgrant_fifo_datain_s2[`PCRDGRANTQ_SRCID_RANGE]    = pcrdgnt_srcid_s2;
    assign pcrdgrant_fifo_datain_s2[`PCRDGRANTQ_QOS_RANGE]      = pcrdgnt_qos_s2;
    assign pcrdgrant_fifo_datain_s2[`PCRDGRANTQ_PCRDTYPE_RANGE] = pcrdgnt_pcrdtype_s2;

    assign pcrdgrant_fifo_push = pcrdgnt_req_enable_s2_q & (~pcrdgrant_fifo_full | (pcrdgrant_fifo_full & txrsp_mshr_pcrdgnt_won_s2));
    assign pcrdgrant_fifo_pop  = txrsp_mshr_pcrdgnt_won_s2 & ~pcrdgrant_fifo_empty;

    hnf_fifo #(
                 .FIFO_ENTRIES_WIDTH (`PCRDGRANTQ_DATA_WIDTH ),
                 .FIFO_ENTRIES_DEPTH (`PCRDGRANTQ_DATA_DEPTH )
             )pcrdgrant_fifo(
                 .clk       (clk                       ),
                 .rst       (rst                       ),
                 .wr_en     (pcrdgrant_fifo_push       ),
                 .wr_data   (pcrdgrant_fifo_datain_s2  ),
                 .rd_en     (pcrdgrant_fifo_pop        ),
                 .rd_data   (pcrdgrant_fifo_dataout_s2 ),
                 .empty     (pcrdgrant_fifo_empty      ),
                 .full      (pcrdgrant_fifo_full       ),
                 .fifo_cnt  (                          )
             );

    //decode pcrdgrant part fields from fifo
    assign qos_txrsp_pcrdgnt_valid_s2    = ~pcrdgrant_fifo_empty;
    assign qos_txrsp_pcrdgnt_qos_s2      = pcrdgrant_fifo_dataout_s2[`PCRDGRANTQ_QOS_RANGE];
    assign qos_txrsp_pcrdgnt_tgtid_s2    = pcrdgrant_fifo_dataout_s2[`PCRDGRANTQ_SRCID_RANGE];
    assign qos_txrsp_pcrdgnt_pcrdtype_s2 = pcrdgrant_fifo_dataout_s2[`PCRDGRANTQ_PCRDTYPE_RANGE];
    //-----------------------------------------------------------------------------
    // DISPLAY FATAL
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_FATAL

    //    always @(posedge clk)begin
    //        `display_fatal(!(retry_ack_fifo_full&&rxreq_retry_enable_s0),"Retry ack fifo overflow\n");
    //    end

    always @(posedge clk)begin
        integer i;
        if(ret_bank_alloc_en_s0 && (&ret_bank_entry_v_s1_q))begin
            $display($sformatf("Fatal: the number of retry_bank srcid overflow when rxreq received a flit with srcid: %h",li_mshr_rxreq_srcid_s0));
            for(i=0;i<HNF_MSHR_RNF_NUM_PARAM;i=i+1)begin
                $display($sformatf("The srcid of retry_bank entry %d : %0h",i,ret_bank_srcid_s1_q[i]));
            end
            `display_fatal(0,"\n")
                      end
                  end

                  always @(posedge clk)begin
                      integer i;
                      for(i=0;i<HNF_MSHR_RNF_NUM_PARAM;i=i+1)begin
                          if(ret_is_hh_s1 && ret_cnt_inc_ptr_s1_q[i] && (&ret_cnt_hh_entry_s2_q[i]))begin
                              `display_fatal(0,$sformatf("The number of srcid: %0h retry(HH) overflow\n",ret_bank_srcid_s1_q[i]));
                          end
                          if(ret_is_h_s1 && ret_cnt_inc_ptr_s1_q[i] && (&ret_cnt_h_entry_s2_q[i]))begin
                              `display_fatal(0,$sformatf("The number of srcid: %0h retry(H) overflow\n",ret_bank_srcid_s1_q[i]));
                          end
                          if(ret_is_m_s1 && ret_cnt_inc_ptr_s1_q[i] && (&ret_cnt_m_entry_s2_q[i]))begin
                              `display_fatal(0,$sformatf("The number of srcid: %0h retry(M) overflow\n",ret_bank_srcid_s1_q[i]));
                          end
                          if(ret_is_l_s1 && ret_cnt_inc_ptr_s1_q[i] && (&ret_cnt_l_entry_s2_q[i]))begin
                              `display_fatal(0,$sformatf("The number of srcid: %0h retry(L) overflow\n",ret_bank_srcid_s1_q[i]));
                          end
                      end
                  end

                  always @(posedge clk)begin
                      `display_fatal(!(li_mshr_rxreq_valid_s0 && (li_mshr_rxreq_opcode_s0 == `SF_EVICT) && qos_seq_pool_full_s0_q),"Fatal info: Seq repeat enqueue!\n");
                      `display_fatal(!(mshr_dbf_retired_valid_sx1_q&&(!mshr_entry_valid_s1_q[mshr_dbf_retired_idx_sx1_q])),"Fatal info: A invalid mshr entry is retiring\n");
                      `display_fatal(!(mshr_alloc_en_s0&&(mshr_entry_valid_s1_q[mshr_entry_idx_alloc_s0])),"Fatal info: A valid mshr entry is repeat enqueuing\n");
                  end

`endif

              endmodule
