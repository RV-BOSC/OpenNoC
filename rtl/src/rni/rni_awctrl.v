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
*/

`include "rni_param.v"
`include "rni_defines.v"
`include "axi4_defines.v"
`include "chie_defines.v"

module rni_awctrl `RNI_PARAM
    (
        clk_i
        ,rst_i
        ,awctrl_txrspflit_d0_o
        ,awctrl_txrspflitv_d0_o
        ,awctrl_txrspflit_sent_d0_i
        ,awctrl_txreqflit_s4_o
        ,awctrl_txreqflitv_s4_o
        ,awctrl_txreqflit_sent_s4_i
        ,awctrl_rxrspflitv_d1_i
        ,awctrl_rxrspflit_d1_i
        ,AWVALID0
        ,AW_CH_S0
        ,AWREADY0
        ,pcrdgnt_pkt_v_d2_i
        ,pcrdgnt_pkt_d2_i
        ,awctrl_pcrdgnt_h_present_d3_o
        ,awctrl_pcrdgnt_l_present_d3_o
        ,awctrl_pcrdgnt_h_win_d3_i
        ,awctrl_pcrdgnt_l_win_d3_i
        ,awctrl_alloc_valid_s2_o
        ,awctrl_alloc_entry_s2_o
        ,awctrl_ctmask_s2_o
        ,awctrl_pdmask_s2_o
        ,awctrl_bc_vec_s2_o
        ,awctrl_dealloc_entry_o
        ,wb_req_fifo_pfull_d1_i
        ,wb_req_done_d3_i
        ,wb_req_entry_d3_i
        ,wb_not_busy_d1_i
        ,awctrl_txdat_rdy_v_d2_o
        ,awctrl_txdat_rdy_entry_d2_o
        ,awctrl_txdat_qos_d2_o
        ,awctrl_txdat_compack_d2_o
        ,awctrl_txdat_dbid_d2_o
        ,awctrl_txdat_tgtid_d2_o
        ,awctrl_txdat_ccid_d2_o
        ,awctrl_txdat_ctmask_d2_o
        ,awctrl_txdat_not_busy_d2_i
        ,awctrl_brsp_fifo_pop_d3_i
        ,awctrl_brsp_rdy_v_d2_o
        ,awctrl_brsp_last_v_d2_o
        ,awctrl_brsp_axid_d2_o
        ,awctrl_brsp_resperr_d2_o
    );

    // Global inputs
    input wire           clk_i;
    input wire           rst_i;

    /////////////////////////////////////////////////////////////
    // CHI face
    /////////////////////////////////////////////////////////////

    output  wire [`CHIE_RSP_FLIT_WIDTH-1:0]             awctrl_txrspflit_d0_o;
    output  wire                                        awctrl_txrspflitv_d0_o;
    input   wire                                        awctrl_txrspflit_sent_d0_i;

    output  wire [`CHIE_REQ_FLIT_WIDTH-1:0]             awctrl_txreqflit_s4_o;
    output  wire                                        awctrl_txreqflitv_s4_o;
    input   wire                                        awctrl_txreqflit_sent_s4_i;

    input wire                                          awctrl_rxrspflitv_d1_i;
    input wire  [`CHIE_RSP_FLIT_RANGE]                  awctrl_rxrspflit_d1_i;

    /////////////////////////////////////////////////////////////
    // AMBA4 face
    /////////////////////////////////////////////////////////////

    input  wire                                         AWVALID0;
    input  wire [`AXI4_AW_WIDTH-1:0]                    AW_CH_S0;
    output wire                                         AWREADY0;

    ///////////////////////////////////////////////////////////////
    // Misc face
    ///////////////////////////////////////////////////////////////

    input wire                                          pcrdgnt_pkt_v_d2_i;
    input wire  [`PCRDGRANT_PKT_WIDTH-1:0]              pcrdgnt_pkt_d2_i;
    output wire                                         awctrl_pcrdgnt_h_present_d3_o;
    output wire                                         awctrl_pcrdgnt_l_present_d3_o;
    input wire                                          awctrl_pcrdgnt_h_win_d3_i;
    input wire                                          awctrl_pcrdgnt_l_win_d3_i;

    output  wire                                        awctrl_alloc_valid_s2_o;
    output  wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_alloc_entry_s2_o;
    output  wire [`RNI_DMASK_CT_WIDTH-1:0]              awctrl_ctmask_s2_o;
    output  wire [`RNI_DMASK_PD_WIDTH-1:0]              awctrl_pdmask_s2_o;
    output  wire [`RNI_BCVEC_WIDTH-1:0]                 awctrl_bc_vec_s2_o;

    // request deallocate
    output  wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_dealloc_entry_o;

    // misc
    input wire                                          wb_req_fifo_pfull_d1_i;
    input wire                                          wb_req_done_d3_i;
    input wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]           wb_req_entry_d3_i;

    // txdatflit request
    input   wire                                        wb_not_busy_d1_i;
    output  wire                                        awctrl_txdat_rdy_v_d2_o;
    output  wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_txdat_rdy_entry_d2_o;
    output  reg [`CHIE_DAT_FLIT_QOS_WIDTH-1:0]          awctrl_txdat_qos_d2_o;
    output  wire                                        awctrl_txdat_compack_d2_o;
    output  reg [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]         awctrl_txdat_dbid_d2_o;
    output  reg [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]        awctrl_txdat_tgtid_d2_o;
    output  wire [`CHIE_DAT_FLIT_CCID_WIDTH-1:0]        awctrl_txdat_ccid_d2_o;
    output  wire [`RNI_DMASK_CT_WIDTH-1:0]              awctrl_txdat_ctmask_d2_o;
    input   wire                                        awctrl_txdat_not_busy_d2_i;

    // B response request
    input   wire                                        awctrl_brsp_fifo_pop_d3_i;
    output  wire                                        awctrl_brsp_rdy_v_d2_o;
    output  wire                                        awctrl_brsp_last_v_d2_o;
    output  wire [`AXI4_BID_WIDTH-1:0]                  awctrl_brsp_axid_d2_o;
    output  wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]     awctrl_brsp_resperr_d2_o;

    wire [`AXI4_AW_WIDTH-1:0]                   awlink_awbus_s1_w;
    wire                                        stall_flag_s1_w;
    wire [`AXI4_AWLEN_WIDTH-1:0]                awlink_len_s1_w;
    wire                                        awlink_valid_s1_w;
    wire [`AXI4_AWADDR_WIDTH-1:0]               awlink_addr_s1_w;
    wire                                        awlink_done_s1_w;
    wire [`RNI_BCVEC_WIDTH-1:0]                 awlink_bc_vec_s2_w;
    wire [`RNI_DMASK_WIDTH-1:0]                 awlink_dmask_s2_w;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        awlink_size_s2_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_alloc_ptr_s1_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_rdy_s1_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_v_ns_w;
    wire                                        awctrl_entry_dealloc_v_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_dealloc_vec_w;
    wire                                        txdat_packet_0_s2_w;
    wire                                        txdat_packet_1_s2_w;
    wire                                        txdat_two_packets_s2_w;
    wire                                        aw_txreq_expcompack_w;
    wire                                        awctrl_new_entry_req_dep_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_is_req_dep_v_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_dep_v_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_req_dep_chain_young_ns_w;
    wire                                        awctrl_new_entry_compack_dep_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_is_compack_dep_v_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_compack_dep_v_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_compack_dep_chain_young_ns_w;
    wire                                        awctrl_new_entry_bresp_dep_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_is_bresp_dep_v_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_bresp_dep_v_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_bresp_dep_chain_young_ns_w;
    wire                                        awctrl_req_hi_retry_found_w;
    wire                                        awctrl_req_lo_retry_found_w;
    wire                                        awctrl_req_hi_new_found_w;
    wire                                        awctrl_req_lo_new_found_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_hi_retry_dec_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_lo_retry_dec_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_hi_new_dec_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_lo_new_dec_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_ptr_ns_w;
    wire                                        awctrl_entry_req_select_success_flag_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_req_retry_ready_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_hi_retry_rdy_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_lo_retry_rdy_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_req_new_rdy_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_hi_new_rdy_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_lo_new_rdy_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_req_select_vec_ns_w;
    wire [CHIE_NID_WIDTH_PARAM-1:0]             aw_tx_send_nid_w;
    wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       awctrl_entry_rxrsp_tgtid_w;
    wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]       awctrl_entry_rxrsp_srcid_w;
    wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       awctrl_entry_rxrsp_txnid_w;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      awctrl_entry_rxrsp_opcode_w;
    wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]        awctrl_entry_rxrsp_dbid_w;
    wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]    awctrl_entry_rxrsp_pcrdtype_w;
    wire                                        aw_rxrsp_correct_w;
    wire                                        rxrsp_dbid_recv_flag_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_dbid_recv_vec_w;
    wire                                        rxrsp_comp_recv_flag_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_comp_recv_vec_w;
    wire                                        rxrsp_retryack_recv_flag_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_retryack_recv_vec_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_retryack_recv_vec_ns_w;
    wire                                        rxrsp_pcrdgrant_recv_flag_w;
    wire                                        rxrsp_pcrdtype_hi_select_w;
    wire                                        rxrsp_pcrdtype_lo_select_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_pcrdgrant_hi_upd_ptr_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_pcrdgrant_lo_upd_ptr_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_pcrdgrant_recv_vec_ns_w;
    wire                                        rxrsp_pcrdtype_hi_match_d2_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_pcrdgrant_hi_recv_vec_d2_w;
    wire                                        rxrsp_pcrdtype_lo_match_d2_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_pcrdgrant_lo_recv_vec_d2_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_dbid_recv_vec_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         rxrsp_comp_recv_vec_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         txdat_select_rdy_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         wdata_recv_done_ns_w;
    wire                                        txdat_select_entry_two_packets_w;
    wire                                        txdat_select_new_entry_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         txdat_select_vec_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_two_packets_current_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_entry_two_packets_flag_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         txdat_send_vec_ns_w;
    wire                                        txdat_select_success_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         txdat_select_vec_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         txrsp_select_rdy_w;
    wire                                        txrsp_select_success_flag_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         txrsp_select_vec_ns_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         txrsp_compack_send_vec_ns_w;
    wire                                        awctrl_compack_chain_clean_flag_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_compack_chain_clean_vec_w;
    wire                                        txrsp_select_success_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         txrsp_select_vec_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         bresp_select_rdy_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         bresp_select_vec_ns_w;
    wire                                        bresp_select_success_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         bresp_select_vec_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         bresp_send_ptr_w;
    wire                                        bresp_credit_full_w;
    wire                                        bresp_credit_avail_w;

    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_v_q;
    reg [`AXI4_AW_WIDTH-1:0]                    awctrl_entry_info_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg                                         awctrl_entry_full_r;
    reg [`AXI4_AWLEN_WIDTH-1:0]                 awctrl_entry_len_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [`AXI4_AWADDR_WIDTH-1:0]                awctrl_entry_addr_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [`AXI4_AWSIZE_WIDTH-1:0]                awctrl_entry_size_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [`RNI_DMASK_CT_WIDTH-1:0]               awctrl_entry_ctmask_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [`RNI_DMASK_PD_WIDTH-1:0]               awctrl_entry_pdmask_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_expcompack_q;
    reg                                         awctrl_entry_segburst_last_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_qos_hi_q;
    reg                                         awlink_valid_s2_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_alloc_ptr_s2_q;
    reg [`AXI4_AWID_WIDTH-1:0]                  awctrl_awid_s2_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_req_select_rdy_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_req_dep_v_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_sameid_req_chain_vec_d2_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_is_req_dep_num_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_is_req_dep_v_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_is_req_dep_num_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_req_dep_chain_young_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_compack_dep_v_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_sameid_compack_chain_vec_d2_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_is_compack_dep_num_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_is_compack_dep_v_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_is_compack_dep_num_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_compack_dep_chain_young_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_bresp_dep_v_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_sameid_bresp_chain_vec_d2_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_is_bresp_dep_num_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_is_bresp_dep_v_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_is_bresp_dep_num_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_bresp_dep_chain_young_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_req_ptr_q;
    reg                                         awctrl_entry_req_select_success_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_req_select_vec_q;
    reg                                         awctrl_entry_req_select_retry_flag_q;
    reg [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]        aw_txreq_txnid_r;
    reg [`CHIE_REQ_FLIT_WIDTH-1:0]              aw_txreqflit_info_r;
    reg                                         aw_txreqflitv_s5_q;
    reg [`CHIE_REQ_FLIT_WIDTH-1:0]              aw_txreqflit_s5_q;
    reg                                         aw_txreqflit_sent_s5_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_rxrsp_ptr_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_pcrdgrant_hi_rdy_vec_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_pcrdgrant_lo_rdy_vec_r;
    reg                                         rxrsp_pcrdtype_hi_match_d3_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_pcrdgrant_hi_recv_vec_d3_q;
    reg                                         rxrsp_pcrdtype_lo_match_d3_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_pcrdgrant_lo_recv_vec_d3_q;
    reg [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]        rxrsp_dbidresp_srcid_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]         rxrsp_dbidresp_dbid_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]     rxrsp_retryack_pcrdtype_q [RNI_AW_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_retryack_recv_vec_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_pcrdgrant_hi_upd_ptr_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_pcrdgrant_lo_upd_ptr_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_pcrdgrant_recv_vec_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_dbid_recv_vec_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          rxrsp_comp_recv_vec_q;
    reg [`RNI_DMASK_CT_WIDTH-1:0]               txdat_ctmask_d1_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          wdata_recv_done_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          txdat_select_ptr_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          txdat_select_vec_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_two_packets_current_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          awctrl_entry_two_packets_flag_q;
    reg                                         txdat_rdy_v_d2_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          txdat_rdy_entry_d2_q;
    reg [`RNI_DMASK_CT_WIDTH-1:0]               txdat_ctmask_d2_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          txdat_rdy_entry_d3_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          txdat_select_vec_d3_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          txdat_send_vec_q;
    reg [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]        aw_txrsp_txnid_r;
    reg [`CHIE_RSP_FLIT_WIDTH-1:0]              aw_txrspflit_info_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          txrsp_select_ptr_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          txrsp_select_vec_q;
    reg                                         aw_txrspflitv_d0_q;
    reg                                         aw_txrspflit_sent_d0_q;
    reg [`CHIE_RSP_FLIT_WIDTH-1:0]              aw_txrspflit_d0_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          txrsp_compack_send_vec_q;
    reg                                         txrsp_select_success_flag_q;
    reg                                         brsp_last_v_d2_ns_r;
    reg [`AXI4_BID_WIDTH-1:0]                   brsp_axid_d2_ns_r;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          bresp_select_ptr_q;
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          bresp_select_vec_q;
    reg                                         brsp_rdy_v_d2_q;
    reg                                         brsp_last_v_d2_q;
    reg [`AXI4_BID_WIDTH-1:0]                   brsp_axid_d2_q;

    genvar entry;
    integer i;

    /////////////////////////////////////////////////////////////
    // txreq s1
    /////////////////////////////////////////////////////////////
    rni_awlink rni_awlink_u0
               (
                   .clk_i                        (clk_i                  )
                   ,.rst_i                        (rst_i                  )
                   ,.AWVALID                      (AWVALID0               )
                   ,.AWBUS                        (AW_CH_S0               )
                   ,.stall_flag_s1_i              (stall_flag_s1_w        )
                   ,.AWREADY                      (AWREADY0               )
                   ,.awlink_awvalid_s1_o          ()
                   ,.awlink_awbus_s1_o            (awlink_awbus_s1_w      )
                   ,.awlink_len_s1_o              (awlink_len_s1_w        )
                   ,.awlink_valid_s1_o            (awlink_valid_s1_w      )
                   ,.awlink_addr_s1_o             (awlink_addr_s1_w       )
                   ,.awlink_done_s1_o             (awlink_done_s1_w       )
                   ,.awlink_bc_vec_s2_o           (awlink_bc_vec_s2_w     )
                   ,.awlink_dmask_s2_o            (awlink_dmask_s2_w      )
                   ,.awlink_size_s2_o             (awlink_size_s2_w       )
                   ,.awlink_lock_s2_o             ()
               );


    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        awctrl_entry_alloc(
            .in_vec(awctrl_entry_rdy_s1_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx({RNI_AW_ENTRIES_NUM_PARAM{1'b0}})
            ,.ptr_dec(awctrl_alloc_ptr_s1_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found()
        );

    always@* begin
        awctrl_entry_full_r = 1'b1;
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)
            awctrl_entry_full_r = awctrl_entry_full_r & awctrl_entry_v_q[i];
    end
    //wdata is written at s2, so it is pfull
    assign stall_flag_s1_w = wb_req_fifo_pfull_d1_i | awctrl_entry_full_r;
    assign awctrl_entry_rdy_s1_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = ~awctrl_entry_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & {RNI_AW_ENTRIES_NUM_PARAM{awlink_valid_s1_w}};
    assign awctrl_entry_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | awctrl_alloc_ptr_s1_w[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin: txn_info
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_info_q[entry][`AXI4_AW_WIDTH-1:0] <= {`AXI4_AW_WIDTH{1'b0}};
                end
                else begin
                    if(awctrl_alloc_ptr_s1_w[entry] == 1'b1)begin
                        awctrl_entry_info_q[entry][`AXI4_AW_WIDTH-1:0] <= awlink_awbus_s1_w[`AXI4_AW_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_len_q[entry][`AXI4_AWLEN_WIDTH-1:0] <= {`AXI4_AWLEN_WIDTH{1'b0}};
                end
                else begin
                    if(awctrl_alloc_ptr_s1_w[entry] == 1'b1)begin
                        awctrl_entry_len_q[entry][`AXI4_AWLEN_WIDTH-1:0] <= awlink_len_s1_w[`AXI4_AWLEN_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_addr_q[entry][`AXI4_AWADDR_WIDTH-1:0] <= {`AXI4_AWADDR_WIDTH{1'b0}};
                end
                else begin
                    if(awctrl_alloc_ptr_s1_w[entry] == 1'b1)begin
                        awctrl_entry_addr_q[entry][`AXI4_AWADDR_WIDTH-1:0] <= awlink_addr_s1_w[`AXI4_AWADDR_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_segburst_last_q[entry] <= 1'b0;
                end
                else begin
                    if(awctrl_alloc_ptr_s1_w[entry] == 1'b1)begin
                        awctrl_entry_segburst_last_q[entry] <= awlink_done_s1_w;
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_qos_hi_q[entry] <= 1'b0;
                end
                else begin
                    if(awctrl_alloc_ptr_s1_w[entry] == 1'b1)begin
                        awctrl_entry_qos_hi_q[entry] <= (awlink_awbus_s1_w[`AXI4_AWQOS_RANGE] == 4'b1111);
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awlink_valid_s1_w | awctrl_entry_dealloc_v_w)begin
                awctrl_entry_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awlink_valid_s2_q <= 1'b0;
        end
        else begin
            awlink_valid_s2_q <= awlink_valid_s1_w;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_alloc_ptr_s1_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
        end
    end

    /////////////////////////////////////////////////////////////
    // txreq s2
    /////////////////////////////////////////////////////////////
    assign awctrl_alloc_valid_s2_o = awlink_valid_s2_q;
    assign awctrl_alloc_entry_s2_o[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_ctmask_s2_o[`RNI_DMASK_CT_WIDTH-1:0] = awlink_dmask_s2_w[`RNI_DMASK_CT_RANGE];
    assign awctrl_pdmask_s2_o[`RNI_DMASK_PD_WIDTH-1:0] = awlink_dmask_s2_w[`RNI_DMASK_PD_RANGE];
    assign awctrl_bc_vec_s2_o[`RNI_BCVEC_WIDTH-1:0] = awlink_bc_vec_s2_w[`RNI_BCVEC_WIDTH-1:0];
    assign txdat_packet_0_s2_w = awlink_valid_s2_q & |awlink_dmask_s2_w[`RNI_DMASK_PD_LSB + 1:`RNI_DMASK_PD_LSB];
    assign txdat_packet_1_s2_w = awlink_valid_s2_q & |awlink_dmask_s2_w[`RNI_DMASK_PD_LSB + 3:`RNI_DMASK_PD_LSB + 2];
    assign txdat_two_packets_s2_w = txdat_packet_0_s2_w & txdat_packet_1_s2_w;
    assign aw_txreq_expcompack_w = awctrl_new_entry_compack_dep_w;

    always@* begin
        awctrl_awid_s2_r[`AXI4_AWID_WIDTH-1:0] = {`AXI4_AWID_WIDTH{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)
            awctrl_awid_s2_r[`AXI4_AWID_WIDTH-1:0] = awctrl_awid_s2_r[`AXI4_AWID_WIDTH-1:0] | ({`AXI4_AWID_WIDTH{awctrl_alloc_ptr_s2_q[i]}} & awctrl_entry_info_q[i][`AXI4_AWID_RANGE]);
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_req_select_rdy_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            awctrl_entry_req_select_rdy_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
        end
    end

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin: txn_size_info
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_size_q[entry][`AXI4_AWSIZE_WIDTH-1:0] <= {`AXI4_AWSIZE_WIDTH{1'b0}};
                end
                else begin
                    if(awctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        awctrl_entry_size_q[entry][`AXI4_AWSIZE_WIDTH-1:0] <= awlink_size_s2_w[`AXI4_AWSIZE_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_ctmask_q[entry][`RNI_DMASK_CT_WIDTH-1:0] <={`RNI_DMASK_CT_WIDTH{1'b0}};
                end
                else begin
                    if(awctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        awctrl_entry_ctmask_q[entry][`RNI_DMASK_CT_WIDTH-1:0] <= awctrl_ctmask_s2_o[`RNI_DMASK_CT_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_pdmask_q[entry][`RNI_DMASK_PD_WIDTH-1:0] <={`RNI_DMASK_PD_WIDTH{1'b0}};
                end
                else begin
                    if(awctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        awctrl_entry_pdmask_q[entry][`RNI_DMASK_PD_WIDTH-1:0] <= awctrl_pdmask_s2_o[`RNI_DMASK_PD_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_expcompack_q[entry] <=1'b0;
                end
                else begin
                    if(awctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        awctrl_entry_expcompack_q[entry] <= aw_txreq_expcompack_w;
                    end
                end
            end
        end
    endgenerate

    //request chain
    assign awctrl_new_entry_req_dep_w = |awctrl_sameid_req_chain_vec_d2_r[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_is_req_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_is_req_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | awctrl_sameid_req_chain_vec_d2_r[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~rxrsp_dbid_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_req_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_req_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{(awctrl_new_entry_req_dep_w)}} & awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])) & ~awctrl_entry_is_req_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_req_dep_chain_young_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = ((awctrl_req_dep_chain_young_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_sameid_req_chain_vec_d2_r[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~rxrsp_dbid_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin:axid_req_same
            always@* begin
                if((awctrl_alloc_ptr_s2_q[entry] == 1'b0) && (awctrl_entry_v_q[entry] == 1'b1) && (rxrsp_dbid_recv_vec_w[entry] == 1'b0))begin
                    awctrl_sameid_req_chain_vec_d2_r[entry] = (awlink_valid_s2_q && awctrl_awid_s2_r[`AXI4_AWID_WIDTH-1:0] == awctrl_entry_info_q[entry][`AXI4_AWID_RANGE]) && awctrl_req_dep_chain_young_q[entry];
                end
                else begin
                    awctrl_sameid_req_chain_vec_d2_r[entry] = 1'b0;
                end
            end
        end
    endgenerate

    always@* begin
        awctrl_entry_is_req_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0] = {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)
            awctrl_entry_is_req_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_entry_is_req_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{rxrsp_dbid_recv_vec_w[i]}} & awctrl_entry_is_req_dep_num_q[i][RNI_AW_ENTRIES_NUM_PARAM-1:0]);
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_is_req_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awlink_valid_s2_q | rxrsp_dbid_recv_flag_w)begin
                awctrl_entry_is_req_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_is_req_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_req_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if((awlink_valid_s2_q && awctrl_new_entry_req_dep_w) | rxrsp_dbid_recv_flag_w)begin
                awctrl_entry_req_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_req_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin:req_dep_num
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_is_req_dep_num_q[entry][RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
                end
                else begin
                    if(rxrsp_dbid_recv_vec_w[entry])begin
                        awctrl_entry_is_req_dep_num_q[entry][RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
                    end
                    else if((awlink_valid_s2_q && awctrl_sameid_req_chain_vec_d2_r[entry]))begin
                        awctrl_entry_is_req_dep_num_q[entry][RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_req_dep_chain_young_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awlink_valid_s2_q | rxrsp_dbid_recv_flag_w)begin
                awctrl_req_dep_chain_young_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_req_dep_chain_young_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    //compack chain
    assign awctrl_new_entry_compack_dep_w = |awctrl_sameid_compack_chain_vec_d2_r[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_is_compack_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_is_compack_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | awctrl_sameid_compack_chain_vec_d2_r[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_compack_chain_clean_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_compack_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_compack_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{(awctrl_new_entry_compack_dep_w)}} & awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])) &
           ~awctrl_entry_is_compack_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_compack_dep_chain_young_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = ((awctrl_compack_dep_chain_young_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_sameid_compack_chain_vec_d2_r[RNI_AW_ENTRIES_NUM_PARAM-1:0]) &
           ~awctrl_compack_chain_clean_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];


    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin:axid_compack_same
            always@* begin
                if((awctrl_alloc_ptr_s2_q[entry] == 1'b0) && (awctrl_entry_v_q[entry] == 1'b1) && (awctrl_compack_chain_clean_vec_w[entry] == 1'b0))begin
                    awctrl_sameid_compack_chain_vec_d2_r[entry] = (awlink_valid_s2_q && awctrl_awid_s2_r[`AXI4_AWID_WIDTH-1:0] == awctrl_entry_info_q[entry][`AXI4_AWID_RANGE]) && awctrl_compack_dep_chain_young_q[entry];
                end
                else begin
                    awctrl_sameid_compack_chain_vec_d2_r[entry] = 1'b0;
                end
            end
        end
    endgenerate

    always@* begin
        awctrl_entry_is_compack_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0] = {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)
            awctrl_entry_is_compack_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_entry_is_compack_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{awctrl_compack_chain_clean_vec_w[i]}} & awctrl_entry_is_compack_dep_num_q[i][RNI_AW_ENTRIES_NUM_PARAM-1:0]);
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_is_compack_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awlink_valid_s2_q | awctrl_compack_chain_clean_flag_w)begin
                awctrl_entry_is_compack_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_is_compack_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_compack_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if((awlink_valid_s2_q & awctrl_new_entry_compack_dep_w) | awctrl_compack_chain_clean_flag_w)begin
                awctrl_entry_compack_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_compack_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin:compack_dep_num
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_is_compack_dep_num_q[entry][RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
                end
                else begin
                    if(awctrl_compack_chain_clean_vec_w[entry])begin
                        awctrl_entry_is_compack_dep_num_q[entry][RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
                    end
                    else if((awlink_valid_s2_q && awctrl_sameid_compack_chain_vec_d2_r[entry]))begin
                        awctrl_entry_is_compack_dep_num_q[entry][RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_compack_dep_chain_young_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awlink_valid_s2_q | awctrl_compack_chain_clean_flag_w)begin
                awctrl_compack_dep_chain_young_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_compack_dep_chain_young_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    //bresp chain
    assign awctrl_new_entry_bresp_dep_w = |awctrl_sameid_bresp_chain_vec_d2_r[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_is_bresp_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_is_bresp_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | awctrl_sameid_bresp_chain_vec_d2_r[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_bresp_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_bresp_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{(awctrl_new_entry_bresp_dep_w)}} & awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])) & ~awctrl_entry_is_bresp_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_bresp_dep_chain_young_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = ((awctrl_bresp_dep_chain_young_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_sameid_bresp_chain_vec_d2_r[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin:axid_bresp_same
            always@* begin
                if((awctrl_alloc_ptr_s2_q[entry] == 1'b0) && (awctrl_entry_v_q[entry] == 1'b1) && (awctrl_entry_dealloc_vec_w[entry] == 1'b0))begin
                    awctrl_sameid_bresp_chain_vec_d2_r[entry] = (awlink_valid_s2_q && awctrl_awid_s2_r[`AXI4_AWID_WIDTH-1:0] == awctrl_entry_info_q[entry][`AXI4_AWID_RANGE]) && awctrl_bresp_dep_chain_young_q[entry];
                end
                else begin
                    awctrl_sameid_bresp_chain_vec_d2_r[entry] = 1'b0;
                end
            end
        end
    endgenerate

    always@* begin
        awctrl_entry_is_bresp_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0] = {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)
            awctrl_entry_is_bresp_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_entry_is_bresp_dep_num_r[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{awctrl_entry_dealloc_vec_w[i]}} & awctrl_entry_is_bresp_dep_num_q[i][RNI_AW_ENTRIES_NUM_PARAM-1:0]);
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_is_bresp_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awlink_valid_s2_q | awctrl_brsp_fifo_pop_d3_i)begin
                awctrl_entry_is_bresp_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_is_bresp_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_bresp_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if((awlink_valid_s2_q & awctrl_new_entry_bresp_dep_w) | awctrl_brsp_fifo_pop_d3_i)begin
                awctrl_entry_bresp_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_bresp_dep_v_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin:bresp_dep_num
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    awctrl_entry_is_bresp_dep_num_q[entry][RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
                end
                else begin
                    if(awctrl_entry_dealloc_vec_w[entry])begin
                        awctrl_entry_is_bresp_dep_num_q[entry][RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
                    end
                    else if((awlink_valid_s2_q && awctrl_sameid_bresp_chain_vec_d2_r[entry]))begin
                        awctrl_entry_is_bresp_dep_num_q[entry][RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_bresp_dep_chain_young_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awlink_valid_s2_q | awctrl_brsp_fifo_pop_d3_i)begin
                awctrl_bresp_dep_chain_young_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_bresp_dep_chain_young_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    /////////////////////////////////////////////////////////////
    // txreq select
    /////////////////////////////////////////////////////////////
    assign awctrl_req_retry_ready_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_entry_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & awctrl_entry_req_select_rdy_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & rxrsp_pcrdgrant_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~awctrl_entry_req_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_req_hi_retry_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_req_retry_ready_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] & awctrl_entry_qos_hi_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_req_lo_retry_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_req_retry_ready_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~awctrl_entry_qos_hi_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_req_new_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_entry_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & awctrl_entry_req_select_rdy_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~awctrl_entry_req_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~rxrsp_retryack_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~awctrl_entry_req_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_req_hi_new_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_req_new_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] & awctrl_entry_qos_hi_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_req_lo_new_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_req_new_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~awctrl_entry_qos_hi_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    //deassert select_vec when receiving retryack
    assign awctrl_entry_req_select_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_req_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{awctrl_entry_req_select_success_flag_w}} & awctrl_entry_req_ptr_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])) & ~rxrsp_retryack_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        req_retry_hi(
            .in_vec(awctrl_entry_req_hi_retry_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx(awctrl_entry_req_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(awctrl_entry_req_hi_retry_dec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found(awctrl_req_hi_retry_found_w)
        );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        req_retry_lo(
            .in_vec(awctrl_entry_req_lo_retry_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx(awctrl_entry_req_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(awctrl_entry_req_lo_retry_dec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found(awctrl_req_lo_retry_found_w)
        );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        req_new_hi(
            .in_vec(awctrl_entry_req_hi_new_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx(awctrl_entry_req_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(awctrl_entry_req_hi_new_dec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found(awctrl_req_hi_new_found_w)
        );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        req_new_lo(
            .in_vec(awctrl_entry_req_lo_new_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx(awctrl_entry_req_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(awctrl_entry_req_lo_new_dec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found(awctrl_req_lo_new_found_w)
        );

    assign awctrl_entry_req_ptr_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_req_hi_retry_found_w ? awctrl_entry_req_hi_retry_dec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0]:
           awctrl_req_hi_new_found_w ? awctrl_entry_req_hi_new_dec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0]:
           awctrl_req_lo_retry_found_w ? awctrl_entry_req_lo_retry_dec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0]:
           awctrl_entry_req_lo_new_dec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_req_select_success_flag_w = (awctrl_req_hi_retry_found_w | awctrl_req_hi_new_found_w | awctrl_req_lo_retry_found_w | awctrl_req_lo_new_found_w) & (awctrl_txreqflit_sent_s4_i | ~awctrl_txreqflitv_s4_o);

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_req_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awctrl_entry_req_select_success_flag_w)begin
                awctrl_entry_req_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_req_ptr_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_req_select_success_q <= 1'b0;
        end
        else begin
            awctrl_entry_req_select_success_q <= awctrl_entry_req_select_success_flag_w;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_req_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awctrl_entry_req_select_success_flag_w | rxrsp_retryack_recv_flag_w | awctrl_entry_dealloc_v_w)begin
                awctrl_entry_req_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= awctrl_entry_req_select_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_req_select_retry_flag_q <= 1'b0;
        end
        else begin
            if(awctrl_entry_req_select_success_flag_w)begin
                awctrl_entry_req_select_retry_flag_q <= awctrl_req_hi_retry_found_w | awctrl_req_lo_retry_found_w;
            end
        end
    end

    /////////////////////////////////////////////////////////////
    // txreq send
    /////////////////////////////////////////////////////////////
    //expcompack considers that when sending a flit, if the comp it depends on has not been received, it will choose owo, otherwise it will be rqo
    assign aw_tx_send_nid_w[CHIE_NID_WIDTH_PARAM-1:0] = HNF_NID_PARAM;

    always@* begin
        aw_txreq_txnid_r[`CHIE_REQ_FLIT_TXNID_WIDTH-1:0] = {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
        aw_txreq_txnid_r[`CHIE_REQ_FLIT_TXNID_WIDTH-1] = 1'b1;
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)
            aw_txreq_txnid_r[`RNI_AW_ENTRIES_WIDTH-1:0] = aw_txreq_txnid_r[`RNI_AW_ENTRIES_WIDTH-1:0] | ({`RNI_AW_ENTRIES_WIDTH{awctrl_entry_req_ptr_q[i]}} & i);
    end

    generate
        if(CHIE_REQ_RSVDC_WIDTH_PARAM != 0)begin
            always @*begin
                aw_txreqflit_info_r[`CHIE_REQ_FLIT_RSVDC_RANGE] = {`CHIE_REQ_FLIT_RSVDC_WIDTH{1'b0}};
            end
        end
    endgenerate

    always@* begin
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_WIDTH-1:0] = {`CHIE_REQ_FLIT_WIDTH{1'b0}};
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_TGTID_RANGE] = aw_tx_send_nid_w[CHIE_NID_WIDTH_PARAM-1:0];
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_SRCID_RANGE] = RNI_NID_PARAM;
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_TXNID_RANGE] = aw_txreq_txnid_r[`CHIE_REQ_FLIT_TXNID_WIDTH-1:0];
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_OPCODE_RANGE] = `CHIE_WRITEUNIQUEPTL;
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE] = ~awctrl_entry_req_select_retry_flag_q;
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_ORDER_RANGE] = 2'b10;
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_RANGE] = 1'b1;
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_DEVICE_RANGE] = 1'b0;
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_CACHEABLE_RANGE] = 1'b1;
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_SNPATTR_RANGE] = 1'b1;
        aw_txreqflit_info_r[`CHIE_REQ_FLIT_LPID_RANGE] = {`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)begin
            aw_txreqflit_info_r[`CHIE_REQ_FLIT_QOS_RANGE] = aw_txreqflit_info_r[`CHIE_REQ_FLIT_QOS_RANGE] | ({`AXI4_AWQOS_WIDTH{awctrl_entry_req_ptr_q[i]}} & awctrl_entry_info_q[i][`AXI4_AWQOS_RANGE]);
            aw_txreqflit_info_r[`CHIE_REQ_FLIT_SIZE_RANGE] = aw_txreqflit_info_r[`CHIE_REQ_FLIT_SIZE_RANGE] | ({`AXI4_AWSIZE_WIDTH{awctrl_entry_req_ptr_q[i]}} & awctrl_entry_size_q[i][`AXI4_AWSIZE_WIDTH-1:0]);
            aw_txreqflit_info_r[`CHIE_REQ_FLIT_ADDR_RANGE] = aw_txreqflit_info_r[`CHIE_REQ_FLIT_ADDR_RANGE] | ({`AXI4_AWADDR_WIDTH{awctrl_entry_req_ptr_q[i]}} & awctrl_entry_addr_q[i][`AXI4_AWADDR_WIDTH-1:0]);
            aw_txreqflit_info_r[`CHIE_REQ_FLIT_PCRDTYPE_RANGE] = ~awctrl_entry_req_select_retry_flag_q ? {`CHIE_REQ_FLIT_PCRDTYPE_WIDTH{1'b0}} :
                               aw_txreqflit_info_r[`CHIE_REQ_FLIT_PCRDTYPE_RANGE] | ({`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{awctrl_entry_req_ptr_q[i]}} & rxrsp_retryack_pcrdtype_q[i][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]);
            aw_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_ALLOCATE_RANGE] = aw_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_ALLOCATE_RANGE] | (awctrl_entry_req_ptr_q[i] & awctrl_entry_info_q[i][`AXI4_AWCACHE_MSB]);
            aw_txreqflit_info_r[`CHIE_REQ_FLIT_EXPCOMPACK_RANGE] = aw_txreqflit_info_r[`CHIE_REQ_FLIT_EXPCOMPACK_RANGE] | (awctrl_entry_req_ptr_q[i] & awctrl_entry_expcompack_q[i]);
        end
    end

    assign awctrl_txreqflitv_s4_o = awctrl_entry_req_select_success_q | (~aw_txreqflit_sent_s5_q & aw_txreqflitv_s5_q);
    assign awctrl_txreqflit_s4_o[`CHIE_REQ_FLIT_WIDTH-1:0] = (~aw_txreqflit_sent_s5_q & aw_txreqflitv_s5_q) ? aw_txreqflit_s5_q[`CHIE_REQ_FLIT_WIDTH-1:0] : aw_txreqflit_info_r[`CHIE_REQ_FLIT_WIDTH-1:0];

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            aw_txreqflitv_s5_q <= 1'b0;
        end
        else begin
            aw_txreqflitv_s5_q <= awctrl_txreqflitv_s4_o;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            aw_txreqflit_s5_q[`CHIE_REQ_FLIT_WIDTH-1:0] <= {`CHIE_REQ_FLIT_WIDTH{1'b0}};
        end
        else begin
            aw_txreqflit_s5_q[`CHIE_REQ_FLIT_WIDTH-1:0]<= awctrl_txreqflit_s4_o[`CHIE_REQ_FLIT_WIDTH-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            aw_txreqflit_sent_s5_q <= 1'b0;
        end
        else begin
            aw_txreqflit_sent_s5_q<= awctrl_txreqflit_sent_s4_i;
        end
    end

    /////////////////////////////////////////////////////////////
    // rxrsp
    /////////////////////////////////////////////////////////////
    assign awctrl_entry_rxrsp_tgtid_w[`CHIE_RSP_FLIT_TGTID_WIDTH-1:0] = awctrl_rxrspflit_d1_i[`CHIE_RSP_FLIT_TGTID_RANGE];
    assign awctrl_entry_rxrsp_srcid_w[`CHIE_RSP_FLIT_SRCID_WIDTH-1:0] = awctrl_rxrspflit_d1_i[`CHIE_RSP_FLIT_SRCID_RANGE];
    assign awctrl_entry_rxrsp_txnid_w[`CHIE_RSP_FLIT_TXNID_WIDTH-1:0] = awctrl_rxrspflit_d1_i[`CHIE_RSP_FLIT_TXNID_RANGE];
    assign awctrl_entry_rxrsp_opcode_w[`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0] = awctrl_rxrspflit_d1_i[`CHIE_RSP_FLIT_OPCODE_RANGE];
    assign awctrl_entry_rxrsp_dbid_w[`CHIE_RSP_FLIT_DBID_WIDTH-1:0] = awctrl_rxrspflit_d1_i[`CHIE_RSP_FLIT_DBID_RANGE];
    assign awctrl_entry_rxrsp_pcrdtype_w[`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] = awctrl_rxrspflit_d1_i[`CHIE_RSP_FLIT_PCRDTYPE_RANGE];

    assign aw_rxrsp_correct_w = awctrl_rxrspflitv_d1_i & awctrl_entry_rxrsp_txnid_w[`CHIE_RSP_FLIT_TXNID_WIDTH-1] & (awctrl_entry_rxrsp_tgtid_w[`CHIE_RSP_FLIT_TGTID_WIDTH-1:0] == RNI_NID_PARAM);
    assign rxrsp_dbid_recv_flag_w = aw_rxrsp_correct_w & ((awctrl_entry_rxrsp_opcode_w[`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0] == `CHIE_COMPDBIDRESP) | (awctrl_entry_rxrsp_opcode_w[`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0] == `CHIE_DBIDRESP));
    assign rxrsp_dbid_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = {RNI_AW_ENTRIES_NUM_PARAM{rxrsp_dbid_recv_flag_w}} & awctrl_rxrsp_ptr_r[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign rxrsp_comp_recv_flag_w = aw_rxrsp_correct_w & ((awctrl_entry_rxrsp_opcode_w[`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0] == `CHIE_COMPDBIDRESP) | (awctrl_entry_rxrsp_opcode_w[`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0] == `CHIE_COMP));
    assign rxrsp_comp_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = {RNI_AW_ENTRIES_NUM_PARAM{rxrsp_comp_recv_flag_w}} & awctrl_rxrsp_ptr_r[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign rxrsp_retryack_recv_flag_w = aw_rxrsp_correct_w & (awctrl_entry_rxrsp_opcode_w[`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0] == `CHIE_RETRYACK);
    assign rxrsp_retryack_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = {RNI_AW_ENTRIES_NUM_PARAM{rxrsp_retryack_recv_flag_w}} & awctrl_rxrsp_ptr_r[RNI_AW_ENTRIES_NUM_PARAM-1:0];

    assign rxrsp_retryack_recv_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (rxrsp_retryack_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | rxrsp_retryack_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign rxrsp_dbid_recv_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (rxrsp_dbid_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | rxrsp_dbid_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign rxrsp_comp_recv_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (rxrsp_comp_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | rxrsp_comp_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0]) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];

    assign rxrsp_pcrdgrant_recv_flag_w = pcrdgnt_pkt_v_d2_i;
    assign awctrl_pcrdgnt_h_present_d3_o = rxrsp_pcrdtype_hi_match_d3_q;
    assign awctrl_pcrdgnt_l_present_d3_o = rxrsp_pcrdtype_lo_match_d3_q;
    assign rxrsp_pcrdtype_hi_select_w = awctrl_pcrdgnt_h_win_d3_i & rxrsp_pcrdtype_hi_match_d3_q;
    assign rxrsp_pcrdtype_lo_select_w = awctrl_pcrdgnt_l_win_d3_i & rxrsp_pcrdtype_lo_match_d3_q;
    assign rxrsp_pcrdgrant_hi_upd_ptr_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = {RNI_AW_ENTRIES_NUM_PARAM{rxrsp_pcrdtype_hi_select_w}} & rxrsp_pcrdgrant_hi_recv_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign rxrsp_pcrdgrant_lo_upd_ptr_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = {RNI_AW_ENTRIES_NUM_PARAM{rxrsp_pcrdtype_lo_select_w}} & rxrsp_pcrdgrant_lo_recv_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign rxrsp_pcrdgrant_recv_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (rxrsp_pcrdgrant_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] |
            (({RNI_AW_ENTRIES_NUM_PARAM{rxrsp_pcrdtype_hi_select_w}} & rxrsp_pcrdgrant_hi_recv_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0]) |
             ({RNI_AW_ENTRIES_NUM_PARAM{rxrsp_pcrdtype_lo_select_w}} & rxrsp_pcrdgrant_lo_recv_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0]))) &
           ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin:rxrsp_ptr
            always@* begin
                if(entry == awctrl_entry_rxrsp_txnid_w[`RNI_AW_ENTRIES_WIDTH-1:0])begin
                    awctrl_rxrsp_ptr_r[entry] = 1'b1;
                end
                else begin
                    awctrl_rxrsp_ptr_r[entry] = 1'b0;
                end
            end
        end
    endgenerate

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin:pcrdtype_match
            always@* begin
                if(rxrsp_pcrdgrant_recv_flag_w & rxrsp_retryack_recv_vec_q[entry] & ~(rxrsp_pcrdgrant_recv_vec_q[entry] | rxrsp_pcrdgrant_recv_vec_ns_w[entry]))begin
                    rxrsp_pcrdgrant_hi_rdy_vec_r[entry] = (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_PCRDTYPE_RANGE] == rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]) &&
                                                (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_SRCID_RANGE] == aw_tx_send_nid_w[CHIE_NID_WIDTH_PARAM-1:0]) &&
                                                (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_TGTID_RANGE] == RNI_NID_PARAM) && awctrl_entry_qos_hi_q[entry];
                end
                else begin
                    rxrsp_pcrdgrant_hi_rdy_vec_r[entry] = 1'b0;
                end
            end

            always@* begin
                if(rxrsp_pcrdgrant_recv_flag_w & rxrsp_retryack_recv_vec_q[entry] & ~(rxrsp_pcrdgrant_recv_vec_q[entry] | rxrsp_pcrdgrant_recv_vec_ns_w[entry]))begin
                    rxrsp_pcrdgrant_lo_rdy_vec_r[entry] = (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_PCRDTYPE_RANGE] == rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]) &&
                                                (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_SRCID_RANGE] == aw_tx_send_nid_w[CHIE_NID_WIDTH_PARAM-1:0]) &&
                                                (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_TGTID_RANGE] == RNI_NID_PARAM) && ~awctrl_entry_qos_hi_q[entry];
                end
                else begin
                    rxrsp_pcrdgrant_lo_rdy_vec_r[entry] = 1'b0;
                end
            end
        end
    endgenerate
    //s2 selects entry, s3 knows whether it is successful, and s4 updates rxrsp_pcrdgrant_hi_upd_ptr_q/rxrsp_pcrdgrant_recv_vec_q,
    // it is necessary to consider the situation of two consecutive beats.
    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        pcrdtype_hi_select(
            .in_vec(rxrsp_pcrdgrant_hi_rdy_vec_r[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx(rxrsp_pcrdtype_hi_select_w ? rxrsp_pcrdgrant_hi_upd_ptr_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] : rxrsp_pcrdgrant_hi_upd_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(rxrsp_pcrdgrant_hi_recv_vec_d2_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found(rxrsp_pcrdtype_hi_match_d2_w)
        );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        pcrdtype_lo_select(
            .in_vec(rxrsp_pcrdgrant_lo_rdy_vec_r[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx(rxrsp_pcrdtype_lo_select_w ? rxrsp_pcrdgrant_lo_upd_ptr_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] : rxrsp_pcrdgrant_lo_upd_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(rxrsp_pcrdgrant_lo_recv_vec_d2_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found(rxrsp_pcrdtype_lo_match_d2_w)
        );

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdtype_hi_match_d3_q <= 1'b0;
        end
        else begin
            rxrsp_pcrdtype_hi_match_d3_q <= rxrsp_pcrdtype_hi_match_d2_w;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_hi_recv_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            rxrsp_pcrdgrant_hi_recv_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_hi_recv_vec_d2_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdtype_lo_match_d3_q <= 1'b0;
        end
        else begin
            rxrsp_pcrdtype_lo_match_d3_q <= rxrsp_pcrdtype_lo_match_d2_w;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_lo_recv_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            rxrsp_pcrdgrant_lo_recv_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_lo_recv_vec_d2_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
        end
    end

    generate
        for (entry=0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry=entry+1) begin:rxrsp_info
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    rxrsp_dbidresp_srcid_q[entry][`CHIE_RSP_FLIT_SRCID_WIDTH-1:0] <= {`CHIE_RSP_FLIT_SRCID_WIDTH{1'b0}};
                end
                else begin
                    if(rxrsp_dbid_recv_vec_w[entry])begin
                        rxrsp_dbidresp_srcid_q[entry][`CHIE_RSP_FLIT_SRCID_WIDTH-1:0] <= awctrl_entry_rxrsp_srcid_w[`CHIE_RSP_FLIT_SRCID_WIDTH-1:0];
                    end
                    else if(awctrl_entry_dealloc_vec_w[entry])begin
                        rxrsp_dbidresp_srcid_q[entry][`CHIE_RSP_FLIT_SRCID_WIDTH-1:0] <= {`CHIE_RSP_FLIT_SRCID_WIDTH{1'b0}};
                    end
                end
            end
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    rxrsp_dbidresp_dbid_q[entry][`CHIE_RSP_FLIT_DBID_WIDTH-1:0] <= {`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
                end
                else begin
                    if(rxrsp_dbid_recv_vec_w[entry])begin
                        rxrsp_dbidresp_dbid_q[entry][`CHIE_RSP_FLIT_DBID_WIDTH-1:0] <= awctrl_entry_rxrsp_dbid_w[`CHIE_RSP_FLIT_DBID_WIDTH-1:0];
                    end
                    else if(awctrl_entry_dealloc_vec_w[entry])begin
                        rxrsp_dbidresp_dbid_q[entry][`CHIE_RSP_FLIT_DBID_WIDTH-1:0] <= {`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
                    end
                end
            end
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] <= {`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};
                end
                else begin
                    if(rxrsp_retryack_recv_vec_w[entry])begin
                        rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] <= awctrl_entry_rxrsp_pcrdtype_w[`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0];
                    end
                    else if(awctrl_entry_dealloc_vec_w[entry])begin
                        rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] <= {`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_retryack_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_retryack_recv_flag_w | awctrl_entry_dealloc_v_w)begin
                rxrsp_retryack_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= rxrsp_retryack_recv_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_hi_upd_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_pcrdtype_hi_select_w)begin
                rxrsp_pcrdgrant_hi_upd_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_hi_upd_ptr_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_lo_upd_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_pcrdtype_lo_select_w)begin
                rxrsp_pcrdgrant_lo_upd_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_lo_upd_ptr_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_pcrdtype_hi_select_w | rxrsp_pcrdtype_lo_select_w | awctrl_entry_dealloc_v_w)begin
                rxrsp_pcrdgrant_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_recv_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_dbid_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_dbid_recv_flag_w | awctrl_entry_dealloc_v_w)begin
                rxrsp_dbid_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= rxrsp_dbid_recv_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_comp_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_comp_recv_flag_w | awctrl_entry_dealloc_v_w)begin
                rxrsp_comp_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= rxrsp_comp_recv_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    /////////////////////////////////////////////////////////////
    // txdat
    /////////////////////////////////////////////////////////////
    //req is sent in two beats and txdat is sent in three beats
    assign txdat_select_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = rxrsp_dbid_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & wdata_recv_done_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~txdat_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign wdata_recv_done_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (wdata_recv_done_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{wb_req_done_d3_i}} & wb_req_entry_d3_i[RNI_AW_ENTRIES_NUM_PARAM-1:0])) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign txdat_select_entry_two_packets_w = wb_not_busy_d1_i & txdat_select_success_w & (|(txdat_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] & awctrl_entry_two_packets_current_q[RNI_AW_ENTRIES_NUM_PARAM-1:0]));
    assign txdat_select_new_entry_w = wb_not_busy_d1_i & txdat_select_success_w & ~txdat_select_entry_two_packets_w;
    assign txdat_select_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (txdat_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{txdat_select_new_entry_w}} & txdat_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    //When alloc the entry, if there are two dat packets, awctrl_entry_two_packets_current_q is assert, and when the entry is successfully selected, awctrl_entry_two_packets_current_q is deassert
    assign awctrl_entry_two_packets_current_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_two_packets_current_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | (awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & {RNI_AW_ENTRIES_NUM_PARAM{txdat_two_packets_s2_w}})) &
           ~(txdat_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] & {RNI_AW_ENTRIES_NUM_PARAM{txdat_select_entry_two_packets_w}});
    //When alloc the entry, if there are two dat packets,awctrl_entry_two_packets_flag_q is assert, and when the entry is dealloc, awctrl_entry_two_packets_flag_q is deassert
    assign awctrl_entry_two_packets_flag_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (awctrl_entry_two_packets_flag_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | (awctrl_alloc_ptr_s2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & {RNI_AW_ENTRIES_NUM_PARAM{txdat_two_packets_s2_w}})) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign txdat_send_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (txdat_send_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{awctrl_txdat_not_busy_d2_i}} & txdat_rdy_entry_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & txdat_select_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];//txdat_select_vec_d3_q prevents a second packet
    assign awctrl_txdat_ccid_d2_o = {`CHIE_DAT_FLIT_CCID_WIDTH{1'b0}};
    assign awctrl_txdat_compack_d2_o = 1'b0;
    assign awctrl_txdat_rdy_v_d2_o = txdat_rdy_v_d2_q;
    assign awctrl_txdat_rdy_entry_d2_o[RNI_AW_ENTRIES_NUM_PARAM-1:0] = txdat_rdy_entry_d2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_txdat_ctmask_d2_o[`RNI_DMASK_CT_WIDTH-1:0] = txdat_ctmask_d2_q[`RNI_DMASK_CT_WIDTH-1:0];
    //If an entry needs to send two packets, entry_vec and upd are the same as the last selection.
    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        txdat_select(
            .in_vec(txdat_select_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx(txdat_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(txdat_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found(txdat_select_success_w)
        );

    always@* begin
        txdat_ctmask_d1_r[`RNI_DMASK_CT_WIDTH-1:0] = {`RNI_DMASK_CT_WIDTH{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1) begin
            if(txdat_select_vec_w[i])
                txdat_ctmask_d1_r[`RNI_DMASK_CT_WIDTH-1:0] = (awctrl_entry_two_packets_flag_q[i] & ~awctrl_entry_two_packets_current_q[i]) ? {awctrl_entry_ctmask_q[i][1:0],awctrl_entry_ctmask_q[i][3:2]} : awctrl_entry_ctmask_q[i][`RNI_DMASK_CT_WIDTH-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            wdata_recv_done_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(wb_req_done_d3_i | awctrl_entry_dealloc_v_w)begin
                wdata_recv_done_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= wdata_recv_done_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txdat_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(txdat_select_new_entry_w)begin
                txdat_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= txdat_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txdat_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(txdat_select_new_entry_w | awctrl_entry_dealloc_v_w)begin
                txdat_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= txdat_select_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_two_packets_current_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awlink_valid_s2_q | txdat_select_entry_two_packets_w)begin
                awctrl_entry_two_packets_current_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <=awctrl_entry_two_packets_current_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awctrl_entry_two_packets_flag_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awlink_valid_s2_q | awctrl_entry_dealloc_v_w)begin
                awctrl_entry_two_packets_flag_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <=awctrl_entry_two_packets_flag_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txdat_rdy_v_d2_q <= 1'b0;
        end
        else begin
            if(wb_not_busy_d1_i)begin
                txdat_rdy_v_d2_q <=txdat_select_success_w;
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txdat_rdy_entry_d2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(wb_not_busy_d1_i)begin
                txdat_rdy_entry_d2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <=txdat_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always@* begin
        awctrl_txdat_qos_d2_o = {`CHIE_DAT_FLIT_QOS_WIDTH{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1) begin
            if(txdat_rdy_v_d2_q && txdat_rdy_entry_d2_q[i])
                awctrl_txdat_qos_d2_o[`CHIE_DAT_FLIT_QOS_WIDTH-1:0] = awctrl_entry_info_q[i][`AXI4_AWQOS_RANGE];
        end
    end

    always@* begin
        awctrl_txdat_dbid_d2_o = {`CHIE_DAT_FLIT_DBID_WIDTH{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1) begin
            if(txdat_rdy_v_d2_q && txdat_rdy_entry_d2_q[i])
                awctrl_txdat_dbid_d2_o[`CHIE_DAT_FLIT_DBID_WIDTH-1:0] = rxrsp_dbidresp_dbid_q[i][`CHIE_RSP_FLIT_DBID_WIDTH-1:0];
        end
    end

    always@* begin
        awctrl_txdat_tgtid_d2_o[`CHIE_DAT_FLIT_TGTID_WIDTH-1:0] = {`CHIE_DAT_FLIT_TGTID_WIDTH{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1) begin
            if(txdat_rdy_v_d2_q && txdat_rdy_entry_d2_q[i])
                awctrl_txdat_tgtid_d2_o[`CHIE_DAT_FLIT_TGTID_WIDTH-1:0] = rxrsp_dbidresp_srcid_q[i][`CHIE_RSP_FLIT_SRCID_WIDTH-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txdat_ctmask_d2_q[`RNI_DMASK_CT_WIDTH-1:0] <= {4{1'b0}};
        end
        else begin
            if(wb_not_busy_d1_i)begin
                txdat_ctmask_d2_q[`RNI_DMASK_CT_WIDTH-1:0] <=txdat_ctmask_d1_r[`RNI_DMASK_CT_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txdat_rdy_entry_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            txdat_rdy_entry_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <=txdat_rdy_entry_d2_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txdat_select_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            txdat_select_vec_d3_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= txdat_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txdat_send_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(awctrl_txdat_not_busy_d2_i | awctrl_entry_dealloc_v_w)begin
                txdat_send_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <=txdat_send_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end
    /////////////////////////////////////////////////////////////
    // txrsp
    /////////////////////////////////////////////////////////////
    assign txrsp_select_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = txdat_send_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & rxrsp_comp_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~awctrl_entry_compack_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] &
           awctrl_entry_expcompack_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~txrsp_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign txrsp_select_success_flag_w = txrsp_select_success_w & (~awctrl_txrspflitv_d0_o | awctrl_txrspflit_sent_d0_i);
    assign txrsp_select_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (txrsp_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{txrsp_select_success_flag_w}} & txrsp_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_txrspflitv_d0_o = txrsp_select_success_flag_q | (aw_txrspflitv_d0_q & ~aw_txrspflit_sent_d0_q);
    assign awctrl_txrspflit_d0_o[`CHIE_RSP_FLIT_WIDTH-1:0] = (aw_txrspflitv_d0_q & ~aw_txrspflit_sent_d0_q) ? aw_txrspflit_d0_q[`CHIE_RSP_FLIT_WIDTH-1:0] : aw_txrspflit_info_r[`CHIE_RSP_FLIT_WIDTH-1:0];
    assign txrsp_compack_send_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (txrsp_compack_send_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | (txrsp_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & {RNI_AW_ENTRIES_NUM_PARAM{(awctrl_txrspflitv_d0_o & awctrl_txrspflit_sent_d0_i)}})) &
           ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_compack_chain_clean_flag_w = (awctrl_txrspflitv_d0_o & awctrl_txrspflit_sent_d0_i) | rxrsp_comp_recv_flag_w;
    assign awctrl_compack_chain_clean_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = ({RNI_AW_ENTRIES_NUM_PARAM{awctrl_txrspflitv_d0_o & awctrl_txrspflit_sent_d0_i}} & txrsp_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0]) |
           (rxrsp_comp_recv_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~awctrl_entry_expcompack_q[RNI_AW_ENTRIES_NUM_PARAM-1:0]);

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        txrsp_select(
            .in_vec(txrsp_select_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx(txrsp_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(txrsp_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found(txrsp_select_success_w)
        );

    always@* begin
        aw_txrsp_txnid_r[`CHIE_RSP_FLIT_TXNID_WIDTH-1:0] = {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)
            aw_txrsp_txnid_r[`CHIE_RSP_FLIT_DBID_WIDTH-1:0] = aw_txrsp_txnid_r[`CHIE_RSP_FLIT_DBID_WIDTH-1:0] | ({`CHIE_RSP_FLIT_DBID_WIDTH{txrsp_select_ptr_q[i]}} & rxrsp_dbidresp_dbid_q[i][`CHIE_RSP_FLIT_DBID_WIDTH-1:0]);
    end

    always@* begin
        aw_txrspflit_info_r[`CHIE_RSP_FLIT_WIDTH-1:0] = {`CHIE_RSP_FLIT_WIDTH{1'b0}};
        aw_txrspflit_info_r[`CHIE_RSP_FLIT_TGTID_RANGE] = aw_tx_send_nid_w[CHIE_NID_WIDTH_PARAM-1:0];
        aw_txrspflit_info_r[`CHIE_RSP_FLIT_SRCID_RANGE] = RNI_NID_PARAM;
        aw_txrspflit_info_r[`CHIE_RSP_FLIT_TXNID_RANGE] = aw_txrsp_txnid_r[`CHIE_RSP_FLIT_TXNID_WIDTH-1:0];
        aw_txrspflit_info_r[`CHIE_RSP_FLIT_OPCODE_RANGE] = `CHIE_COMPACK;
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)begin
            aw_txrspflit_info_r[`CHIE_RSP_FLIT_QOS_RANGE] = aw_txrspflit_info_r[`CHIE_RSP_FLIT_QOS_RANGE] | ({`AXI4_AWQOS_WIDTH{txrsp_select_ptr_q[i]}} & awctrl_entry_info_q[i][`AXI4_AWQOS_RANGE]);
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txrsp_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(txrsp_select_success_flag_w)begin
                txrsp_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= txrsp_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txrsp_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(txrsp_select_success_flag_w | awctrl_entry_dealloc_v_w)begin
                txrsp_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= txrsp_select_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            aw_txrspflitv_d0_q <= 1'b0;
        end
        else begin
            aw_txrspflitv_d0_q <= awctrl_txrspflitv_d0_o;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            aw_txrspflit_sent_d0_q <= 1'b0;
        end
        else begin
            aw_txrspflit_sent_d0_q <= awctrl_txrspflit_sent_d0_i;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            aw_txrspflit_d0_q[`CHIE_RSP_FLIT_WIDTH-1:0] <= {`CHIE_RSP_FLIT_WIDTH{1'b0}};
        end
        else begin
            aw_txrspflit_d0_q[`CHIE_RSP_FLIT_WIDTH-1:0] <= awctrl_txrspflit_d0_o;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txrsp_compack_send_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if((awctrl_txrspflitv_d0_o & awctrl_txrspflit_sent_d0_i) | awctrl_entry_dealloc_v_w)begin
                txrsp_compack_send_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= txrsp_compack_send_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            txrsp_select_success_flag_q <= 1'b0;
        end
        else begin
            txrsp_select_success_flag_q <= txrsp_select_success_flag_w;
        end
    end

    /////////////////////////////////////////////////////////////
    // bresp
    /////////////////////////////////////////////////////////////
    assign bresp_select_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_entry_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & rxrsp_comp_recv_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & txdat_send_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] &
           (txrsp_compack_send_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ~awctrl_entry_expcompack_q[RNI_AW_ENTRIES_NUM_PARAM-1:0]) &
           ~awctrl_entry_bresp_dep_v_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] & ~bresp_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign bresp_select_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = (bresp_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] | ({RNI_AW_ENTRIES_NUM_PARAM{bresp_select_success_w & bresp_credit_avail_w}} & bresp_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])) & ~awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_brsp_rdy_v_d2_o = brsp_rdy_v_d2_q;
    assign awctrl_brsp_last_v_d2_o = brsp_last_v_d2_q;
    assign awctrl_brsp_axid_d2_o[`AXI4_BID_WIDTH-1:0] = brsp_axid_d2_q[`AXI4_BID_WIDTH-1:0];
    assign awctrl_brsp_resperr_d2_o[`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0] = {`CHIE_RSP_FLIT_RESPERR_WIDTH{1'b0}};
    assign bresp_credit_avail_w = !bresp_credit_full_w;

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AW_ENTRIES_NUM_PARAM)
        )
        bresp_select(
            .in_vec(bresp_select_rdy_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.startx(bresp_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(bresp_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0])
            ,.found(bresp_select_success_w)
        );

    sync_fifo #(
                  .FIFO_ENTRIES_WIDTH (RNI_AW_ENTRIES_NUM_PARAM)
                  ,.FIFO_ENTRIES_DEPTH (`BRSP_FIFO_ENTRIES_DEPTH)
                  ,.FIFO_BYP_ENABLE    (1'b0)
              )
              bresp_credit(
                  .clk            (clk_i                                              )
                  ,.rst            (rst_i                                              )
                  ,.push           (bresp_select_success_w & bresp_credit_avail_w      )
                  ,.pop            (awctrl_brsp_fifo_pop_d3_i                          )
                  ,.data_in        (bresp_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0]   )
                  ,.data_out       (bresp_send_ptr_w[RNI_AW_ENTRIES_NUM_PARAM-1:0]     )
                  ,.empty          (                                                   )
                  ,.full           (bresp_credit_full_w                                )
                  ,.count          (                                                   )
              );

    always@* begin
        brsp_last_v_d2_ns_r = 1'b0;
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)
            brsp_last_v_d2_ns_r = brsp_last_v_d2_ns_r | (bresp_select_vec_w[i] & awctrl_entry_segburst_last_q[i]);
    end

    always@* begin
        brsp_axid_d2_ns_r[`AXI4_BID_WIDTH-1:0] = {`AXI4_BID_WIDTH{1'b0}};
        for (i=0; i < RNI_AW_ENTRIES_NUM_PARAM; i=i+1)
            brsp_axid_d2_ns_r[`AXI4_BID_WIDTH-1:0] = brsp_axid_d2_ns_r[`AXI4_BID_WIDTH-1:0] | ({`AXI4_BID_WIDTH{bresp_select_vec_w[i]}} & awctrl_entry_info_q[i][`AXI4_AWID_RANGE]);
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            bresp_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(bresp_select_success_w & bresp_credit_avail_w)begin
                bresp_select_ptr_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= bresp_select_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            bresp_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= {RNI_AW_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if((bresp_select_success_w & bresp_credit_avail_w) | awctrl_entry_dealloc_v_w)begin
                bresp_select_vec_q[RNI_AW_ENTRIES_NUM_PARAM-1:0] <= bresp_select_vec_ns_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            brsp_rdy_v_d2_q <= 1'b0;
        end
        else begin
            brsp_rdy_v_d2_q <= bresp_select_success_w && bresp_credit_avail_w;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            brsp_last_v_d2_q <= 1'b0;
        end
        else begin
            brsp_last_v_d2_q <= brsp_last_v_d2_ns_r;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            brsp_axid_d2_q[`AXI4_BID_WIDTH-1:0] <= 1'b0;
        end
        else begin
            brsp_axid_d2_q[`AXI4_BID_WIDTH-1:0] <= brsp_axid_d2_ns_r[`AXI4_BID_WIDTH-1:0];
        end
    end

    /////////////////////////////////////////////////////////////
    // dealloc
    /////////////////////////////////////////////////////////////
    assign awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0] = {RNI_AW_ENTRIES_NUM_PARAM{awctrl_brsp_fifo_pop_d3_i}} & bresp_send_ptr_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_entry_dealloc_v_w = |awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
    assign awctrl_dealloc_entry_o[RNI_AW_ENTRIES_NUM_PARAM-1:0] = awctrl_entry_dealloc_vec_w[RNI_AW_ENTRIES_NUM_PARAM-1:0];
endmodule
