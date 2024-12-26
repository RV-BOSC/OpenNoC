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
*    Nana Cai <cainana@bosc.ac.cn>
*    Li Zhao <lizhao@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*    Xiaotian Cao <caoxiaotian@bosc.ac.cn>
*    Guo Bing <guobing@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "axi4_defines.v"
`include "snf_defines.v"
`include "snf_param.v"

module snf_mshr `SNF_PARAM
    (
        clk,
        rst,
        rxreq_alloc_en_s0,
        rxreq_alloc_flit_s0,
        mshr_entry_idx_alloc_s0,
        txrsp_valid_sx,
        txrsp_qos_sx,
        txrsp_tgtid_sx,
        txrsp_txnid_sx,
        txrsp_opcode_sx,
        txrsp_resperr_sx,
        txrsp_resp_sx,
        txrsp_dbid_sx,
        txrsp_srcid_sx,
        txrsp_tracetag_sx,
        txrsp_won_sx,
        rxreq_dbf_en_s1,
        rxreq_dbf_addr_s1,
        rxreq_dbf_wr_s1,
        rxreq_dbf_size_s1,
        rxreq_dbf_axlen_s1,
        rxreq_dbf_entry_idx_s1,
        dbf_mshr_rdata_en_sx,
        dbf_mshr_rdata_idx_sx,
        dbf_mshr_rdata_cdmask_sx,
        dbf_mshr_rxdat_ok_sx,
        dbf_mshr_rxdat_ok_idx_sx,
        dbf_mshr_rxdat_cancel_sx,
        dbf_mshr_rxdat_cancel_idx_sx,
        mshr_txdat_en_sx,
        mshr_txdat_entry_idx_sx,
        mshr_txdat_dataid_sx,
        mshr_txdat_txnid_sx,
        mshr_txdat_opcode_sx,
        mshr_txdat_resp_sx,
        mshr_txdat_resperr_sx,
        mshr_txdat_dbid_sx,
        mshr_txdat_tgtid_sx,
        mshr_txdat_srcid_sx,
        mshr_txdat_homenid_sx,
        mshr_txdat_tracetag_sx,
        mshr_txdat_won_sx,
        mshr_wdat_en_sx,
        mshr_wdat_entry_idx_sx,
        mshr_retired_valid_sx,
        mshr_retired_idx_sx,
        arid_sx,
        araddr_sx,
        arlen_sx,
        arsize_sx,
        arburst_sx,
        arlock_sx,
        arcache_sx,
        arprot_sx,
        arqos_sx,
        arregion_sx,
        arvalid_sx,
        arready_sx,
        awid_sx,
        awaddr_sx,
        awlen_sx,
        awsize_sx,
        awburst_sx,
        awlock_sx,
        awcache_sx,
        awprot_sx,
        awqos_sx,
        awregion_sx,
        awvalid_sx,
        awready_sx,
        bid_sx,
        bresp_sx,
        bvalid_sx,
        bready_sx
    );

    input wire                                          clk;
    input wire                                          rst;
    input wire                                          rxreq_alloc_en_s0;
    input wire [`CHIE_REQ_FLIT_RANGE]                   rxreq_alloc_flit_s0;
    input wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]            mshr_entry_idx_alloc_s0;

    output wire                                         txrsp_valid_sx;
    output wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]          txrsp_qos_sx;
    output wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]        txrsp_tgtid_sx;
    output wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]        txrsp_txnid_sx;
    output wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]       txrsp_opcode_sx;
    output wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]      txrsp_resperr_sx;
    output wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]         txrsp_resp_sx;
    output wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]         txrsp_dbid_sx;
    output wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]        txrsp_srcid_sx;
    output wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]     txrsp_tracetag_sx;

    input wire                                          txrsp_won_sx;
    output wire                                         rxreq_dbf_en_s1;
    output wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]         rxreq_dbf_addr_s1;
    output wire                                         rxreq_dbf_wr_s1;
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]         rxreq_dbf_size_s1;
    output wire [`AXI4_AWSIZE_WIDTH-1:0]                 rxreq_dbf_axlen_s1;
    output wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]           rxreq_dbf_entry_idx_s1;
    input  wire                                         dbf_mshr_rdata_en_sx;
    input  wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]           dbf_mshr_rdata_idx_sx;
    input  wire [`SNF_MASK_CD_WIDTH-1:0]                dbf_mshr_rdata_cdmask_sx;
    input  wire                                         dbf_mshr_rxdat_ok_sx;
    input  wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]           dbf_mshr_rxdat_ok_idx_sx;
    input  wire                                         dbf_mshr_rxdat_cancel_sx;
    input  wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]           dbf_mshr_rxdat_cancel_idx_sx;
    output wire                                         mshr_txdat_en_sx;
    output wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]           mshr_txdat_entry_idx_sx;
    output wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]       mshr_txdat_dataid_sx;
    output wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]        mshr_txdat_txnid_sx;
    output wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]       mshr_txdat_opcode_sx;
    output wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]         mshr_txdat_resp_sx;
    output wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]      mshr_txdat_resperr_sx;
    output wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]         mshr_txdat_dbid_sx;
    output wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]        mshr_txdat_tgtid_sx;
    output wire [`CHIE_DAT_FLIT_SRCID_WIDTH-1:0]        mshr_txdat_srcid_sx;
    output wire [`CHIE_DAT_FLIT_HOMENID_WIDTH-1:0]      mshr_txdat_homenid_sx;
    output wire [`CHIE_DAT_FLIT_TRACETAG_WIDTH-1:0]     mshr_txdat_tracetag_sx;
    input wire                                          mshr_txdat_won_sx;
    output wire                                         mshr_wdat_en_sx;
    output wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]           mshr_wdat_entry_idx_sx;
    output wire                                         mshr_retired_valid_sx;
    output wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]           mshr_retired_idx_sx;
    output wire [`AXI4_ARID_WIDTH-1:0]                  arid_sx;
    output wire [`AXI4_ARADDR_WIDTH-1:0]                araddr_sx;
    output wire [`AXI4_ARLEN_WIDTH-1:0]                 arlen_sx;
    output wire [`AXI4_ARSIZE_WIDTH-1:0]                arsize_sx;
    output wire [`AXI4_ARBURST_WIDTH-1:0]               arburst_sx;
    output wire [`AXI4_ARLOCK_WIDTH-1:0]                arlock_sx;
    output wire [`AXI4_ARCACHE_WIDTH-1:0]               arcache_sx;
    output wire [`AXI4_ARPROT_WIDTH-1:0]                arprot_sx;
    output wire [`AXI4_ARQOS_WIDTH-1:0]                 arqos_sx;
    output wire [`AXI4_ARREGION_WIDTH-1:0]              arregion_sx;
    output reg                                          arvalid_sx;
    input  wire                                         arready_sx;
    output wire [`AXI4_AWID_WIDTH-1:0]                  awid_sx;
    output wire [`AXI4_AWADDR_WIDTH-1:0]                awaddr_sx;
    output wire [`AXI4_AWLEN_WIDTH-1:0]                 awlen_sx;
    output wire [`AXI4_AWSIZE_WIDTH-1:0]                awsize_sx;
    output wire [`AXI4_AWBURST_WIDTH-1:0]               awburst_sx;
    output wire [`AXI4_AWLOCK_WIDTH-1:0]                awlock_sx;
    output wire [`AXI4_AWCACHE_WIDTH-1:0]               awcache_sx;
    output wire [`AXI4_AWPROT_WIDTH-1:0]                awprot_sx;
    output wire [`AXI4_AWQOS_WIDTH-1:0]                 awqos_sx;
    output wire [`AXI4_AWREGION_WIDTH-1:0]              awregion_sx;
    output reg                                          awvalid_sx;
    input  wire                                         awready_sx;
    input  wire [`AXI4_BID_WIDTH-1:0]                   bid_sx;
    input  wire [`AXI4_BRESP_WIDTH-1:0]                 bresp_sx;
    input  wire                                         bvalid_sx;
    output wire                                         bready_sx;

    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   mshr_entry_idx_alloc_s1_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     mshr_entry_valid_sx_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     sleep_s2_q;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   hazard_idx_s2_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     hazard_sx_q;
    reg                                                 rxreq_alloc_en_s1_q;
    reg [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]               rxreq_opcode_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]                  rxreq_qos_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]              rxreq_memattr_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]                rxreq_srcid_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_TGTID_WIDTH-1:0]                rxreq_tgtid_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]                rxreq_txnid_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]                 rxreq_size_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]                 rxreq_addr_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_NS_WIDTH-1:0]                   rxreq_ns_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]                rxreq_order_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_RETURNTXNID_WIDTH-1:0]          rxreq_returntxnid_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]             rxreq_tracetag_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_RETURNNID_WIDTH-1:0]            rxreq_returnnid_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_DAT_FLIT_CCID_WIDTH-1:0]                 rxreq_ccid_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`AXI4_AXID_WIDTH-1:0]                          rxreq_axid_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`AXI4_ARLEN_WIDTH-1:0]                         rxreq_axlen_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`AXI4_ARSIZE_WIDTH-1:0]                        rxreq_axsize_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`AXI4_AXADDR_WIDTH-1:0]                        rxreq_axaddr_s1_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     rxreq_wr_s1_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     rxreq_rd_s1_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     rxreq_dodmt_s1_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     rxreq_dodwt_s1_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     rxreq_ewa_s1_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     txrsp_comp_s1_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     txrsp_comp_sent_sx_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     txrsp_rdreceipt_valid_sx_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     txrsp_rdy_sx_q;
    reg [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]               txrsp_opcode_rdy_sx_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   txrsp_entry_idx_sx;
    reg [1:0]                                           txdat_rdy_sx_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   txdat_entry_idx_sx;
    reg                                                 txdat_en_sx_q;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   txdat_entry_idx_sx_q;
    reg [1:0]                                           txdat_sent_sx_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     arvalid_fifo_s1_q;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   arvalid_fifo_idx_sx_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   arvalid_fifo_set_vec;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   arvalid_fifo_vec;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   arvalid_entry_idx_s1_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     rdat_valid_s1_q;
    reg [3:0]                                           rdat_pdmask_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     awvalid_fifo_valid_s2_q;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   awvalid_fifo_idx_s2_q[`SNF_MSHR_ENTRIES_NUM-1:0];
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   awvalid_fifo_cnt_sx_q;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   awvalid_fifo_vec_sx;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   awvalid_entry_idx_s2_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     bresp_ok_q;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     retired_entry_sx1_q;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]                   retired_entry_idx_sx1_q;
    reg                                                 mshr_wdat_en_rst;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                     rxdat_cancel_s1_q;

    wire [`SNF_MSHR_ENTRIES_NUM-1:0]                    mshr_entry_alloc_sx;
    wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]                 rxreq_qos_s0;
    wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]               rxreq_srcid_s0;
    wire [`CHIE_REQ_FLIT_TGTID_WIDTH-1:0]               rxreq_tgtid_s0;
    wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]               rxreq_txnid_s0;
    wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]              rxreq_opcode_s0;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]                rxreq_size_s0;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]                rxreq_addr_s0;
    wire [`CHIE_REQ_FLIT_RETURNNID_WIDTH-1:0]           rxreq_returnnid_s0;
    wire [`CHIE_REQ_FLIT_RETURNTXNID_WIDTH-1:0]         rxreq_returntxnid_s0;
    wire                                                rxreq_dodmt_s0;
    wire                                                rxreq_dodwt_s0;
    wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]                  rxreq_ns_s0;
    wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]               rxreq_order_s0;
    wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]            rxreq_pcrdtype_s0;
    wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]             rxreq_memattr_s0;
    wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]            rxreq_tracetag_s0;
    wire                                                rxreq_ewa_s0;
    wire                                                rxreq_rd_s0;
    wire                                                rxreq_wr_s0;
    wire                                                txrsp_en_s1;
    wire                                                txrsp_en_sx;
    wire                                                txrsp_readreceipt_en_s1;
    wire                                                txrsp_compdbidresp_en_s1;
    wire                                                txrsp_dbidresp_en_s1;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]              txrsp_opcode_en_s1;
    wire                                                txrsp_compdbidresp_en_sx;
    wire                                                txrsp_dbidresp_en_sx;
    wire                                                txrsp_ewa_dwt_rdy_sx;
    wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]                  txrsp_ewa_dwt_rdy_entry_sx;
    wire                                                txrsp_noewa_rdy_sx;
    wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]                  txrsp_noewa_rdy_entry_sx;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]              txrsp_opcode_en_sx;
    wire                                                txrsp_update_sx;
    wire [`SNF_MSHR_ENTRIES_NUM-1:0]                    txrsp_valid_idx_sx;
    wire                                                txrsp_comp_wrdatcancel_sx;
    wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]                  txrsp_comp_wrcancel_sx;
    wire [`SNF_MSHR_ENTRIES_NUM-1:0]                    txdat1_rdy_sx;
    wire [`SNF_MSHR_ENTRIES_NUM-1:0]                    txdat2_rdy_sx;
    wire                                                arvalid_en_s1;
    wire                                                arvalid_en2_s1;
    wire [`SNF_MSHR_ENTRIES_NUM-1:0]                    bresp_ok_sx;
    wire                                                wakeup_valid;
    wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]                  wakeup_idx_sx;
    wire [`SNF_MSHR_ENTRIES_NUM-1:0]                    retired_entry_sx;
    wire [`SNF_MSHR_ENTRIES_NUM-1:0]                    txdat_valid_sx;
    wire                                                mshr_txdat_update;
    wire [`SNF_MSHR_ENTRIES_NUM-1:0]                    mshr_txdat_idx_vec;
    wire [`SNF_MSHR_ENTRIES_NUM-1:0]                    hazard_sx;

    genvar entry;

    //************************************************************************//
    //                     request fields decode logic                        //
    //************************************************************************//

    assign rxreq_qos_s0         = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_QOS_RANGE]          :{`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};
    assign rxreq_srcid_s0       = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_SRCID_RANGE]        :{`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
    assign rxreq_txnid_s0       = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_TXNID_RANGE]        :{`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
    assign rxreq_opcode_s0      = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_OPCODE_RANGE]       :{`CHIE_REQ_FLIT_OPCODE_WIDTH{1'b0}};
    assign rxreq_size_s0        = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_SIZE_RANGE]         :{`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
    assign rxreq_addr_s0        = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_ADDR_RANGE]         :{`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
    assign rxreq_ns_s0          = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_NS_RANGE]           :{`CHIE_REQ_FLIT_NS_WIDTH{1'b0}};
    assign rxreq_order_s0       = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_ORDER_RANGE]        :{`CHIE_REQ_FLIT_ORDER_WIDTH{1'b0}};
    assign rxreq_pcrdtype_s0    = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_PCRDTYPE_RANGE]     :{`CHIE_REQ_FLIT_PCRDTYPE_WIDTH{1'b0}};
    assign rxreq_memattr_s0     = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_MEMATTR_RANGE]      :{`CHIE_REQ_FLIT_MEMATTR_WIDTH{1'b0}};
    assign rxreq_tgtid_s0       = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_TGTID_RANGE]        :{`CHIE_REQ_FLIT_TGTID_WIDTH{1'b0}};
    assign rxreq_tracetag_s0    = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_TRACETAG_RANGE]     :{`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
    assign rxreq_returnnid_s0   = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_RETURNNID_RANGE]    :{`CHIE_REQ_FLIT_RETURNNID_WIDTH{1'b0}};
    assign rxreq_returntxnid_s0 = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_RETURNTXNID_RANGE]  :{`CHIE_REQ_FLIT_RETURNTXNID_WIDTH{1'b0}};
    assign rxreq_dodmt_s0       = (rxreq_alloc_en_s0 == 1'b1)? (rxreq_rd_s0 == 1'b1) && (rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_SRCID_RANGE] != rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_RETURNNID_RANGE]) :1'b0;
    assign rxreq_dodwt_s0       = (rxreq_alloc_en_s0 == 1'b1)? (rxreq_wr_s0 == 1'b1) && (rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_DODWT_RANGE])      :1'b0;
    assign rxreq_rd_s0          = (rxreq_alloc_en_s0 == 1'b1)? (rxreq_opcode_s0 == `CHIE_READNOSNP)                   :1'b0;
    assign rxreq_wr_s0          = (rxreq_alloc_en_s0 == 1'b1)? ((rxreq_opcode_s0 == `CHIE_WRITENOSNPFULL)|(rxreq_opcode_s0 == `CHIE_WRITENOSNPPTL)):1'b0;
    assign rxreq_ewa_s0         = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_RANGE]  :{`CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_WIDTH{1'b0}};

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign mshr_entry_alloc_sx[entry] = (rxreq_alloc_en_s0 == 1'b1) && (mshr_entry_idx_alloc_s0 == entry);
        end
    endgenerate

    //************************************************************************//
    //                             FIELD REG                                  //
    //************************************************************************//

    always @(posedge clk)begin : mshr_rxreq_alloc_s1_q_timing_logic
            if(rst)begin
                rxreq_alloc_en_s1_q         <= 1'b0;
                mshr_entry_idx_alloc_s1_q   <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
            end
            else begin
                rxreq_alloc_en_s1_q         <= rxreq_alloc_en_s0;
                mshr_entry_idx_alloc_s1_q   <= mshr_entry_idx_alloc_s0;
            end
        end

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk)begin : mshr_entry_valid_s1_q_timing_logic
                if(rst == 1'b1)
                    mshr_entry_valid_sx_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    mshr_entry_valid_sx_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    mshr_entry_valid_sx_q[entry] <= 1'b1;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : rxreq_wr_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_wr_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_wr_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1 && rxreq_wr_s0)
                    rxreq_wr_s1_q[entry] <= 1'b1;
            end

            always @(posedge clk or posedge rst)begin : rxreq_rd_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_rd_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_rd_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1 && rxreq_rd_s0)
                    rxreq_rd_s1_q[entry] <= 1'b1;
            end

            always @(posedge clk or posedge rst)begin : rxreq_dodmt_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_dodmt_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_dodmt_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_dodmt_s1_q[entry] <= rxreq_dodmt_s0;
            end

            always @(posedge clk or posedge rst)begin : rxreq_dodwt_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_dodwt_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_dodwt_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_dodwt_s1_q[entry] <= rxreq_dodwt_s0;
            end

            always @(posedge clk or posedge rst)begin : rxreq_ewa_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_ewa_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_ewa_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_ewa_s1_q[entry] <= rxreq_ewa_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_qos_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_qos_s1_q[entry] <= {`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_qos_s1_q[entry] <= {`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_qos_s1_q[entry] <= rxreq_qos_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_srcid_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_srcid_s1_q[entry] <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_srcid_s1_q[entry] <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_srcid_s1_q[entry] <= rxreq_srcid_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_tgtid_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_tgtid_s1_q[entry] <= {`CHIE_REQ_FLIT_TGTID_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_tgtid_s1_q[entry] <= {`CHIE_REQ_FLIT_TGTID_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_tgtid_s1_q[entry] <= rxreq_tgtid_s0;
                else
                    ;
            end


            always @(posedge clk or posedge rst)begin : mshr_txnid_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_txnid_s1_q[entry] <= {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_txnid_s1_q[entry] <= {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_txnid_s1_q[entry] <= rxreq_txnid_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_opcode_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_opcode_s1_q[entry] <= {`CHIE_REQ_FLIT_OPCODE_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_opcode_s1_q[entry] <= {`CHIE_REQ_FLIT_OPCODE_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_opcode_s1_q[entry] <= rxreq_opcode_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_size_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_size_s1_q[entry] <= {`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_size_s1_q[entry] <= {`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_size_s1_q[entry] <= rxreq_size_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_addr_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_addr_s1_q[entry] <= {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_addr_s1_q[entry] <= {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_addr_s1_q[entry] <= rxreq_addr_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_ns_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_ns_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_ns_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_ns_s1_q[entry] <= rxreq_ns_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_order_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_order_s1_q[entry] <= {`CHIE_REQ_FLIT_ORDER_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_order_s1_q[entry] <= {`CHIE_REQ_FLIT_ORDER_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_order_s1_q[entry] <= rxreq_order_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_memattr_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_memattr_s1_q[entry] <= {`CHIE_REQ_FLIT_MEMATTR_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_memattr_s1_q[entry] <= {`CHIE_REQ_FLIT_MEMATTR_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_memattr_s1_q[entry] <= rxreq_memattr_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_tracetag_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_tracetag_s1_q[entry] <= {`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_tracetag_s1_q[entry] <= {`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_tracetag_s1_q[entry] <= rxreq_tracetag_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_returnnid_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_returnnid_s1_q[entry] <= {`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_returnnid_s1_q[entry] <= {`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_returnnid_s1_q[entry] <= rxreq_returnnid_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_returntxnid_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_returntxnid_s1_q[entry] <= {`CHIE_REQ_FLIT_RETURNTXNID_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_returntxnid_s1_q[entry] <= {`CHIE_REQ_FLIT_RETURNTXNID_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_returntxnid_s1_q[entry] <= rxreq_returntxnid_s0;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : mshr_ccid_s1_q_timing_logic
                if(rst == 1'b1)
                    rxreq_ccid_s1_q[entry] <= 2'b00;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_ccid_s1_q[entry] <= 2'b00;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_ccid_s1_q[entry] <= rxreq_addr_s0[5:4];
                else
                    ;
            end
        end
    endgenerate

    //************************************************************************//
    //                            AXI SIGNAL                                  //
    //************************************************************************//

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                        rxreq_axaddr_s1_q[entry] <= {`AXI4_AXADDR_WIDTH{1'b0}};
                end
                else if (mshr_retired_valid_sx && (entry == mshr_retired_idx_sx))begin
                        rxreq_axaddr_s1_q[entry] <= {`AXI4_AXADDR_WIDTH{1'b0}};
                end
                else if (rxreq_alloc_en_s0 && (entry == mshr_entry_idx_alloc_s0))begin
                    case(rxreq_size_s0)
                            `CHIE_SIZE1B  :
                                    rxreq_axaddr_s1_q[entry] <= rxreq_addr_s0;
                            `CHIE_SIZE2B  :
                                    rxreq_axaddr_s1_q[entry] <= {rxreq_addr_s0[`AXI4_AXADDR_WIDTH-1:6],rxreq_addr_s0[5:1],1'b0};
                            `CHIE_SIZE4B  :
                                    rxreq_axaddr_s1_q[entry] <= {rxreq_addr_s0[`AXI4_AXADDR_WIDTH-1:6],rxreq_addr_s0[5:2],2'b0};
                            `CHIE_SIZE8B  :
                                    rxreq_axaddr_s1_q[entry] <= {rxreq_addr_s0[`AXI4_AXADDR_WIDTH-1:6],rxreq_addr_s0[5:3],3'b0};
                            `CHIE_SIZE16B :
                                    rxreq_axaddr_s1_q[entry] <= {rxreq_addr_s0[`AXI4_AXADDR_WIDTH-1:6],rxreq_addr_s0[5:4],4'b0};
                            `CHIE_SIZE32B :
                                    rxreq_axaddr_s1_q[entry] <= {rxreq_addr_s0[`AXI4_AXADDR_WIDTH-1:6],rxreq_addr_s0[5:5],5'b0};
                            `CHIE_SIZE64B :
                                    rxreq_axaddr_s1_q[entry] <= {rxreq_addr_s0[`AXI4_AXADDR_WIDTH-1:6],6'b0};
                            default:
                                    rxreq_axaddr_s1_q[entry] <= {`AXI4_AXADDR_WIDTH{1'b0}};
                    endcase
                end
                else begin
                        rxreq_axaddr_s1_q[entry] <= rxreq_axaddr_s1_q[entry];
                end
            end

            always @(posedge clk or posedge rst)begin : mshr_axid_timing_logic
                if(rst == 1'b1)
                    rxreq_axid_s1_q[entry] <= 0;
                else if (retired_entry_sx[entry] == 1'b1)
                    rxreq_axid_s1_q[entry] <= {`AXI4_AXID_WIDTH{1'b0}};
                else if (rxreq_alloc_en_s0 && (entry == mshr_entry_idx_alloc_s0))
                    rxreq_axid_s1_q[entry] <= mshr_entry_idx_alloc_s0;
            end
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin
                if (rst) begin
                    rxreq_axlen_s1_q[entry]  <= {`AXI4_AWSIZE_WIDTH{1'b0}};
                    rxreq_axsize_s1_q[entry] <= {`AXI4_AWSIZE_WIDTH{1'b0}};
                end
                else if (mshr_retired_valid_sx && (entry == mshr_retired_idx_sx))begin
                    rxreq_axlen_s1_q[entry]  <= {`AXI4_AWSIZE_WIDTH{1'b0}};
                    rxreq_axsize_s1_q[entry] <= {`AXI4_AWSIZE_WIDTH{1'b0}};
                end
                else if (rxreq_alloc_en_s0 && (entry == mshr_entry_idx_alloc_s0))begin
                    case(rxreq_size_s0)
                        `SNF_CHIE_SIZE1B,`SNF_CHIE_SIZE2B,`SNF_CHIE_SIZE4B,`SNF_CHIE_SIZE8B,`SNF_CHIE_SIZE16B:begin
                                rxreq_axlen_s1_q[entry] <= 3'b000;
                                rxreq_axsize_s1_q[entry] <= rxreq_size_s0;
                        end
                        `SNF_CHIE_SIZE32B : begin
                                rxreq_axlen_s1_q[entry] <= (`AXI4_AXDATA_WIDTH == 128) ? 3'b001 : 3'b000;
                                rxreq_axsize_s1_q[entry] <= (`AXI4_AXDATA_WIDTH == 128) ? 3'b100 : 3'b101;
                        end
                        `SNF_CHIE_SIZE64B : begin
                                rxreq_axlen_s1_q[entry] <= (`AXI4_AXDATA_WIDTH == 128) ? 3'b011 : 3'b001; //4len,2len
                                rxreq_axsize_s1_q[entry] <= (`AXI4_AXDATA_WIDTH == 128) ? 3'b100 : 3'b101; //16B,32B
                        end
                        default: begin
                                rxreq_axlen_s1_q[entry] <= {`AXI4_AWSIZE_WIDTH{1'b0}};
                                rxreq_axsize_s1_q[entry] <= {`AXI4_AWSIZE_WIDTH{1'b0}};
                        end
                    endcase
                end
            end
        end
    endgenerate

    // to databuffer
    assign rxreq_dbf_en_s1         = rxreq_alloc_en_s1_q;
    assign rxreq_dbf_addr_s1       = rxreq_addr_s1_q[mshr_entry_idx_alloc_s1_q];
    assign rxreq_dbf_wr_s1         = rxreq_wr_s1_q[mshr_entry_idx_alloc_s1_q];
    assign rxreq_dbf_size_s1       = rxreq_size_s1_q[mshr_entry_idx_alloc_s1_q];
    assign rxreq_dbf_axlen_s1      = rxreq_axlen_s1_q[mshr_entry_idx_alloc_s1_q];
    assign rxreq_dbf_entry_idx_s1  = mshr_entry_idx_alloc_s1_q;

    //************************************************************************//
    //                      mshr txrspflit wrap logic                         //
    //************************************************************************//
    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin : txrsp_comp_timing_logic
                if (rst == 1'b1)
                    txrsp_comp_s1_q[entry] <= 1'b0;
                else if ((mshr_entry_valid_sx_q[entry]) && txrsp_dbidresp_en_s1 && (entry == mshr_entry_idx_alloc_s1_q))
                    txrsp_comp_s1_q[entry] <= 1'b1;
                else if ((mshr_entry_valid_sx_q[entry]) && txrsp_dbidresp_en_sx && (entry == wakeup_idx_sx))
                    txrsp_comp_s1_q[entry] <= 1'b1;
                else if (mshr_retired_valid_sx && (entry == mshr_retired_idx_sx))
                    txrsp_comp_s1_q[entry] <= 1'b0;
                else
                    ;
            end
        end
    endgenerate
    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin : mshr_txrsp_comp_timing_logic
                if(rst == 1'b1)
                    txrsp_comp_sent_sx_q[entry] <= 1'b0;
                else if(txrsp_won_sx && txrsp_valid_sx && (txrsp_opcode_sx == `CHIE_COMP) & (entry == txrsp_entry_idx_sx))
                    txrsp_comp_sent_sx_q[entry] <= 1'b1;
                else if(mshr_retired_valid_sx & entry == mshr_retired_idx_sx)
                    txrsp_comp_sent_sx_q[entry] <= 1'b0;
            end
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin : txrsp_comp_timing_logic
                if (rst == 1'b1)
                    txrsp_rdreceipt_valid_sx_q[entry] <= 1'b0;
                else if (txrsp_readreceipt_en_s1 && (entry == mshr_entry_idx_alloc_s1_q))
                    txrsp_rdreceipt_valid_sx_q[entry] <= 1'b1;
                else if (txrsp_won_sx && txrsp_valid_sx && (txrsp_opcode_sx == `CHIE_READRECEIPT) && (entry == txrsp_entry_idx_sx))
                    txrsp_rdreceipt_valid_sx_q[entry] <= 1'b0;
                else
                    ;
            end
        end
    endgenerate

    //*****************************************************************************************//
    //  1. ewa = 1  && dwt  : return DBIDRESP to RNF;rxdat finish ,return comp to HN
    //  2. ewa = 1  && ！dwt： compdbidresp to HN
    //  3. !ewa && dwt      : return DBIDRESP to RNF;bresp receive ,return comp to HN
    //  4. !ewa && ！dwt    :  bresp receive ,return comp to HN
    //*****************************************************************************************//
    assign txrsp_en_s1                 = txrsp_dbidresp_en_s1 | txrsp_readreceipt_en_s1 | txrsp_compdbidresp_en_s1;
    assign txrsp_readreceipt_en_s1     = rxreq_alloc_en_s1_q && rxreq_rd_s1_q[mshr_entry_idx_alloc_s1_q] && (rxreq_order_s1_q[mshr_entry_idx_alloc_s1_q] != 2'b00) && rxreq_dodmt_s1_q[mshr_entry_idx_alloc_s1_q];
    assign txrsp_compdbidresp_en_s1    = (rxreq_alloc_en_s1_q && (~sleep_s2_q[mshr_entry_idx_alloc_s1_q])) ? (rxreq_wr_s1_q[mshr_entry_idx_alloc_s1_q] && ((~rxreq_dodwt_s1_q[mshr_entry_idx_alloc_s1_q]) && rxreq_ewa_s1_q[mshr_entry_idx_alloc_s1_q])) : 1'b0;
    assign txrsp_dbidresp_en_s1        = (rxreq_alloc_en_s1_q && (~sleep_s2_q[mshr_entry_idx_alloc_s1_q])) ? (rxreq_wr_s1_q[mshr_entry_idx_alloc_s1_q] && (rxreq_dodwt_s1_q[mshr_entry_idx_alloc_s1_q] | (~rxreq_ewa_s1_q[mshr_entry_idx_alloc_s1_q]))) : 1'b0;
    assign txrsp_opcode_en_s1          = txrsp_en_s1 ? (txrsp_dbidresp_en_s1 ? `CHIE_DBIDRESP : (txrsp_readreceipt_en_s1 ? `CHIE_READRECEIPT : (txrsp_compdbidresp_en_s1 ? `CHIE_COMPDBIDRESP : {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}}))) : {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}};

    assign txrsp_en_sx                 = txrsp_dbidresp_en_sx | txrsp_compdbidresp_en_sx;
    assign txrsp_dbidresp_en_sx        = wakeup_valid ? (rxreq_wr_s1_q[wakeup_idx_sx]&& (rxreq_dodwt_s1_q[wakeup_idx_sx] | (~rxreq_ewa_s1_q[wakeup_idx_sx]))) : 1'b0;
    assign txrsp_compdbidresp_en_sx    = wakeup_valid ? (rxreq_wr_s1_q[wakeup_idx_sx] && ((~rxreq_dodwt_s1_q[wakeup_idx_sx]) && rxreq_ewa_s1_q[wakeup_idx_sx])) : 1'b0; //ewa&~dwt
    assign txrsp_opcode_en_sx          = txrsp_en_sx ? (txrsp_dbidresp_en_sx ? `CHIE_DBIDRESP : (txrsp_compdbidresp_en_sx ? `CHIE_COMPDBIDRESP : {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}})) : {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}};

    assign txrsp_ewa_dwt_rdy_sx         = dbf_mshr_rxdat_ok_sx && txrsp_comp_s1_q[dbf_mshr_rxdat_ok_idx_sx] && rxreq_ewa_s1_q[dbf_mshr_rxdat_ok_idx_sx] && rxreq_dodwt_s1_q[dbf_mshr_rxdat_ok_idx_sx];
    assign txrsp_ewa_dwt_rdy_entry_sx   = dbf_mshr_rxdat_ok_idx_sx ;
    assign txrsp_noewa_rdy_sx           = (bvalid_sx & bready_sx) ? (~rxreq_ewa_s1_q[bid_sx]  & txrsp_comp_s1_q[bid_sx]) : 1'b0;
    assign txrsp_noewa_rdy_entry_sx     = (bvalid_sx & bready_sx) ? bid_sx : 1'b0;
    assign txrsp_comp_wrdatcancel_sx    =  dbf_mshr_rxdat_cancel_sx && txrsp_comp_s1_q[dbf_mshr_rxdat_cancel_idx_sx];
    assign txrsp_comp_wrcancel_sx       =  dbf_mshr_rxdat_cancel_idx_sx;

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin
                if (rst)begin
                    txrsp_rdy_sx_q[entry] <= 1'b0;
                    txrsp_opcode_rdy_sx_q[entry] <= {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}};
                end
                else if (txrsp_valid_sx && txrsp_won_sx && (entry == txrsp_entry_idx_sx))begin
                    txrsp_rdy_sx_q[entry] <= 1'b0;
                    txrsp_opcode_rdy_sx_q[entry] <= {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}};
                end
                else if (txrsp_en_s1 && (entry == mshr_entry_idx_alloc_s1_q))begin
                    txrsp_rdy_sx_q[entry] <= 1'b1;
                    txrsp_opcode_rdy_sx_q[entry] <= txrsp_opcode_en_s1;
                end
                else if (txrsp_en_sx && (entry == wakeup_idx_sx))begin
                    txrsp_rdy_sx_q[entry] <= 1'b1;
                    txrsp_opcode_rdy_sx_q[entry] <= txrsp_opcode_en_sx;
                end
                else if (txrsp_ewa_dwt_rdy_sx && (entry == txrsp_ewa_dwt_rdy_entry_sx))begin
                    txrsp_rdy_sx_q[entry] <= 1'b1;
                    txrsp_opcode_rdy_sx_q[entry] <= `CHIE_COMP;
                end
                else if (txrsp_noewa_rdy_sx && (entry == txrsp_noewa_rdy_entry_sx)) begin
                    txrsp_rdy_sx_q[entry] <= 1'b1;
                    txrsp_opcode_rdy_sx_q[entry] <= `CHIE_COMP;
                end
                else if (txrsp_comp_wrdatcancel_sx && (entry == txrsp_comp_wrcancel_sx)) begin
                    txrsp_rdy_sx_q[entry] <= 1'b1;
                    txrsp_opcode_rdy_sx_q[entry] <= `CHIE_COMP;
                end
            end
        end
    endgenerate

    snf_find_entry #(.ENTRIES_NUM(`SNF_MSHR_ENTRIES_NUM)) txrsp_entry_sel(
                        .clk               (clk                 ),
                        .rst               (rst                 ),
                        .req_entry_vec     (txrsp_rdy_sx_q      ),
                        .upd_start_entry   (txrsp_update_sx     ),
                        .req_entry_ptr_sel (txrsp_valid_idx_sx  )
                    );

    always @(*)begin : txrsp_entry_sel_logic
    integer i;
        txrsp_entry_idx_sx = {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        for (i = 0; i < `SNF_MSHR_ENTRIES_NUM; i = i + 1) begin
            if (txrsp_valid_idx_sx[i])begin
                    txrsp_entry_idx_sx = i;
            end
        end
    end

    assign txrsp_update_sx              = (|txrsp_rdy_sx_q) & (~txrsp_valid_sx);
    assign txrsp_valid_sx               = (|txrsp_valid_idx_sx) & txrsp_rdy_sx_q[txrsp_entry_idx_sx];
    assign txrsp_qos_sx                 = (rxreq_qos_s1_q[txrsp_entry_idx_sx]);
    assign txrsp_tgtid_sx               = ((rxreq_dodwt_s1_q[txrsp_entry_idx_sx] && (txrsp_opcode_sx == `CHIE_DBIDRESP)) == 1'b1) ? rxreq_returnnid_s1_q[txrsp_entry_idx_sx] : rxreq_srcid_s1_q[txrsp_entry_idx_sx];
    assign txrsp_txnid_sx               = ((rxreq_dodwt_s1_q[txrsp_entry_idx_sx] && (txrsp_opcode_sx == `CHIE_DBIDRESP)) == 1'b1) ? rxreq_returntxnid_s1_q[txrsp_entry_idx_sx] : rxreq_txnid_s1_q[txrsp_entry_idx_sx];
    assign txrsp_opcode_sx              = txrsp_opcode_rdy_sx_q[txrsp_entry_idx_sx];
    assign txrsp_resperr_sx             = 2'b00;
    assign txrsp_resp_sx                = `CHIE_COMP_RESP_I;
    assign txrsp_dbid_sx                = txrsp_entry_idx_sx;
    assign txrsp_tracetag_sx            = rxreq_tracetag_s1_q[txrsp_entry_idx_sx];
    assign txrsp_srcid_sx               = rxreq_tgtid_s1_q[txrsp_entry_idx_sx];

    //************************************************************************//
    //                       mshr AR channel logic                            //
    //************************************************************************//
    assign arvalid_en_s1 = rxreq_alloc_en_s1_q ? ((~sleep_s2_q[mshr_entry_idx_alloc_s1_q]) && rxreq_rd_s1_q[mshr_entry_idx_alloc_s1_q]) : 1'b0;
    assign arvalid_en2_s1 = wakeup_valid ? rxreq_rd_s1_q[wakeup_idx_sx] : 1'b0;

    always @(posedge clk or posedge rst) begin: arvalid_fifo_set_comb_logic
        if(rst == 1'b1)
            arvalid_fifo_set_vec <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        else if(arvalid_en_s1 && arvalid_en2_s1)
            arvalid_fifo_set_vec <= ((arvalid_fifo_set_vec + 2) == `SNF_MSHR_ENTRIES_NUM) ? 1'b0 : ((arvalid_fifo_set_vec + 1) == `SNF_MSHR_ENTRIES_NUM) ? 1'b1 : (arvalid_fifo_set_vec + 2);
        else if ((arvalid_en_s1 && (~arvalid_en2_s1)) | ((~arvalid_en_s1) && arvalid_en2_s1))
            arvalid_fifo_set_vec <= ((arvalid_fifo_set_vec + 1) == `SNF_MSHR_ENTRIES_NUM) ? 1'b0 : (arvalid_fifo_set_vec + 1);
    end

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin: arvalid_fifo_set_comb_logic
                if(rst == 1'b1)
                    arvalid_fifo_s1_q[entry]        <= 1'b0;
                else if ((arvalid_sx == 1'b1) && (arready_sx == 1'b1) && (arvalid_fifo_vec == entry))
                    arvalid_fifo_s1_q[entry]        <= 1'b0;
                else if (arvalid_en_s1 && arvalid_en2_s1 && (arvalid_fifo_set_vec == entry)) begin
                    arvalid_fifo_s1_q[entry]        <= 1'b1;
                    arvalid_fifo_idx_sx_q[entry]    <= wakeup_idx_sx;
                end
                else if (arvalid_en_s1 && arvalid_en2_s1 && (((arvalid_fifo_set_vec == (`SNF_MSHR_ENTRIES_NUM-1)) & (entry == 0)) | ((arvalid_fifo_set_vec +1) == entry))) begin
                    arvalid_fifo_s1_q[entry]        <= 1'b1;
                    arvalid_fifo_idx_sx_q[entry]    <= mshr_entry_idx_alloc_s1_q;
                end
                else if (arvalid_en_s1 && (arvalid_fifo_set_vec == entry)) begin
                    arvalid_fifo_s1_q[entry]        <= 1'b1;
                    arvalid_fifo_idx_sx_q[entry]    <= mshr_entry_idx_alloc_s1_q;
                end
                else if (arvalid_en2_s1 && (arvalid_fifo_set_vec == entry)) begin
                    arvalid_fifo_s1_q[entry]        <= 1'b1;
                    arvalid_fifo_idx_sx_q[entry]    <= wakeup_idx_sx;
                end
            end
        end
    endgenerate

    always @(posedge clk or posedge rst) begin: arvalid_fifo_cnt_comb_logic
        if(rst == 1'b1)
            arvalid_fifo_vec     <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        else if((arvalid_sx == 1'b1) && (arready_sx == 1'b1))
            arvalid_fifo_vec     <= ((arvalid_fifo_vec + 1) == `SNF_MSHR_ENTRIES_NUM) ? 1'b0 : (arvalid_fifo_vec + 1);
    end

    always @(posedge clk or posedge rst)begin : mshr_arvalid_timing_logic
        if(rst == 1'b1) begin
            arvalid_sx                <= 1'b0;
            arvalid_entry_idx_s1_q    <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if((arvalid_sx == 1'b1) && (arready_sx == 1'b1))begin
            arvalid_sx                <= 1'b0;
            arvalid_entry_idx_s1_q    <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(arvalid_fifo_s1_q[arvalid_fifo_vec])begin
            arvalid_sx                <= 1'b1;
            arvalid_entry_idx_s1_q    <= arvalid_fifo_idx_sx_q[arvalid_fifo_vec];
        end
    end

    assign arid_sx          = rxreq_axid_s1_q[arvalid_entry_idx_s1_q];
    assign araddr_sx        = rxreq_axaddr_s1_q[arvalid_entry_idx_s1_q];
    assign arcache_sx[0]    = rxreq_memattr_s1_q[arvalid_entry_idx_s1_q][0];
    assign arcache_sx[1]    = ~rxreq_memattr_s1_q[arvalid_entry_idx_s1_q][1];
    assign arcache_sx[2]    = rxreq_memattr_s1_q[arvalid_entry_idx_s1_q][2];
    assign arcache_sx[3]    = rxreq_memattr_s1_q[arvalid_entry_idx_s1_q][3];
    assign arburst_sx       = 2'b01;
    assign arlock_sx        = 1'b0;
    assign arprot_sx        = {1'b0,rxreq_ns_s1_q[arvalid_entry_idx_s1_q],1'b0};
    assign arqos_sx         = rxreq_qos_s1_q[arvalid_entry_idx_s1_q];
    assign arregion_sx      = {`AXI4_ARREGION_WIDTH{1'b0}};
    assign arlen_sx         = rxreq_axlen_s1_q[arvalid_entry_idx_s1_q];
    assign arsize_sx        = rxreq_axsize_s1_q[arvalid_entry_idx_s1_q];

    //************************************************************************//
    //                                TXDAT                                   //
    //************************************************************************//

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin: rdat_valid_s1_q_logic
                if(rst == 1'b1)
                    rdat_valid_s1_q[entry] <= 1'b0;
                else if (dbf_mshr_rdata_en_sx && (dbf_mshr_rdata_idx_sx == entry))
                    rdat_valid_s1_q[entry] <= 1'b1;
                else if (mshr_retired_valid_sx && (mshr_retired_idx_sx == entry))
                    rdat_valid_s1_q[entry] <= 1'b0;
            end
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin: arvalid_fifo_set_comb_logic
                if(rst == 1'b1)
                    rdat_pdmask_q[entry] <= 4'b0000;
                else if ((dbf_mshr_rdata_en_sx && (entry == dbf_mshr_rdata_idx_sx)) && (mshr_txdat_en_sx && (entry == mshr_txdat_entry_idx_sx)) && (mshr_txdat_dataid_sx == 2'b00))
                    rdat_pdmask_q[entry] <= (dbf_mshr_rdata_cdmask_sx | rdat_pdmask_q[entry]) & 4'b1100;
                else if ((dbf_mshr_rdata_en_sx && (entry == dbf_mshr_rdata_idx_sx)) && (mshr_txdat_en_sx && (entry == mshr_txdat_entry_idx_sx)) && (mshr_txdat_dataid_sx == 2'b10))
                    rdat_pdmask_q[entry] <= (dbf_mshr_rdata_cdmask_sx | rdat_pdmask_q[entry]) & 4'b0011;
                else if ((dbf_mshr_rdata_en_sx && (entry == dbf_mshr_rdata_idx_sx))&& (~(mshr_txdat_en_sx && (entry == mshr_txdat_entry_idx_sx))))
                    rdat_pdmask_q[entry] <= dbf_mshr_rdata_cdmask_sx | rdat_pdmask_q[entry];
                else if(~(dbf_mshr_rdata_en_sx && (entry == dbf_mshr_rdata_idx_sx)) && (mshr_txdat_en_sx && (entry == mshr_txdat_entry_idx_sx)) && (mshr_txdat_dataid_sx == 2'b00))
                    rdat_pdmask_q[entry] <= rdat_pdmask_q[entry] & 4'b1100;
                else if(~(dbf_mshr_rdata_en_sx && (entry == dbf_mshr_rdata_idx_sx)) && (mshr_txdat_en_sx && (entry == mshr_txdat_entry_idx_sx)) && (mshr_txdat_dataid_sx == 2'b10))
                    rdat_pdmask_q[entry] <= rdat_pdmask_q[entry] & 4'b0011;
                else if (mshr_retired_valid_sx && entry == mshr_retired_idx_sx)
                    rdat_pdmask_q[entry] <= 4'b0000;
            end
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign txdat1_rdy_sx[entry] = (rdat_valid_s1_q[entry] && (~txdat_rdy_sx_q[entry][0])) ?
                                (((rxreq_ccid_s1_q[entry][1] == 1'b0) && (rdat_pdmask_q[entry][1:0] == 2'b11))
                                | ((rxreq_ccid_s1_q[entry][1] == 1'b1) && (rdat_pdmask_q[entry][3:2] == 2'b11))
                                | (rxreq_size_s1_q[entry] < `CHIE_SIZE32B) && (|(rdat_pdmask_q[entry])))
                                : 1'b0; // packet 1

            assign txdat2_rdy_sx[entry] = (rdat_valid_s1_q[entry] && (txdat_rdy_sx_q[entry][0]) && (~txdat_rdy_sx_q[entry][1]))? //packet 2
                                 (((rxreq_ccid_s1_q[entry][1] == 1'b0) && (rdat_pdmask_q[entry][3:2] == 2'b11)) | ((rxreq_ccid_s1_q[entry][1] == 1'b1) && (rdat_pdmask_q[entry][1:0] == 2'b11))) : 1'b0;
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin
                if(rst == 1'b1)
                    txdat_rdy_sx_q[entry]   <= 2'b00;
                else if (mshr_retired_valid_sx && (entry == mshr_retired_idx_sx))
                    txdat_rdy_sx_q[entry]   <= 2'b00;
                else if (txdat1_rdy_sx[entry] && (~txdat2_rdy_sx[entry]))
                    txdat_rdy_sx_q[entry]   <= txdat_rdy_sx_q[entry] | 2'b01;
                else if ((~txdat1_rdy_sx[entry]) && txdat2_rdy_sx[entry])
                    txdat_rdy_sx_q[entry]   <= txdat_rdy_sx_q[entry] | 2'b10;
                else if (txdat1_rdy_sx[entry] && txdat2_rdy_sx[entry])
                    txdat_rdy_sx_q[entry]   <= txdat_rdy_sx_q[entry] | 2'b11;
            end
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin: txdat_sent_logic
                if (rst)
                    txdat_sent_sx_q[entry]      <= 2'b00;
                else if (mshr_txdat_won_sx && (mshr_txdat_entry_idx_sx == entry) && (((mshr_txdat_dataid_sx == 2'b00) && (rxreq_ccid_s1_q[entry][1] == 1'b0)) | ((mshr_txdat_dataid_sx == 2'b10) && (rxreq_ccid_s1_q[entry][1] == 1'b1))))
                    txdat_sent_sx_q[entry]      <= txdat_sent_sx_q[entry] | 2'b01;
                else if (mshr_txdat_won_sx && (mshr_txdat_entry_idx_sx == entry) && (((mshr_txdat_dataid_sx == 2'b10) && (rxreq_ccid_s1_q[entry][1] == 1'b0)) | ((mshr_txdat_dataid_sx == 2'b00) && (rxreq_ccid_s1_q[entry][1] == 1'b1))) && (txdat_sent_sx_q[entry][0] == 1'b1))
                    txdat_sent_sx_q[entry]      <= txdat_sent_sx_q[entry] | 2'b10;
                else if (mshr_retired_valid_sx && entry == mshr_retired_idx_sx)
                    txdat_sent_sx_q[entry]      <= 2'b00;
            end
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign txdat_valid_sx[entry]  = (txdat_sent_sx_q[entry] != txdat_rdy_sx_q[entry]);
        end
    endgenerate

    snf_find_entry #(.ENTRIES_NUM(`SNF_MSHR_ENTRIES_NUM)) txdat_entry_sel(
                        .clk               (clk                 ),
                        .rst               (rst                 ),
                        .req_entry_vec     (txdat_valid_sx      ),
                        .upd_start_entry   (mshr_txdat_update   ),
                        .req_entry_ptr_sel (mshr_txdat_idx_vec  )
                    );

    always @(*)begin : txdat_entry_sel_logic
    integer i;
    txdat_entry_idx_sx = {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        for (i = 0; i < `SNF_MSHR_ENTRIES_NUM; i = i + 1) begin
            if (mshr_txdat_idx_vec[i]) begin
                txdat_entry_idx_sx = i;
            end
            else begin
                txdat_entry_idx_sx = txdat_entry_idx_sx;
            end
        end
    end

    always @(posedge clk or posedge rst)begin : mshr_txdat_timing_logic
        if(rst == 1'b1) begin
            txdat_en_sx_q           <= 1'b0;
            txdat_entry_idx_sx_q    <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(mshr_txdat_won_sx && mshr_txdat_en_sx)begin
            txdat_en_sx_q           <= 1'b0;
        end
        else if(txdat_valid_sx[txdat_entry_idx_sx])begin
            txdat_en_sx_q           <= 1'b1;
            txdat_entry_idx_sx_q    <= txdat_entry_idx_sx;
        end
    end

    assign mshr_txdat_update        = (~mshr_txdat_en_sx) & (|txdat_valid_sx) & (~txdat_valid_sx[txdat_entry_idx_sx]);
    assign mshr_txdat_entry_idx_sx  = txdat_entry_idx_sx_q;
    assign mshr_txdat_en_sx         = txdat_en_sx_q;
    assign mshr_txdat_dataid_sx     = ((((rxreq_ccid_s1_q[txdat_entry_idx_sx_q][1] == 1'b0) && (txdat_rdy_sx_q[txdat_entry_idx_sx_q][0] == 1'b1) && (txdat_sent_sx_q[txdat_entry_idx_sx_q][0] == 1'b0))
                                        | ((rxreq_ccid_s1_q[txdat_entry_idx_sx_q][1] == 1'b1) && (txdat_rdy_sx_q[txdat_entry_idx_sx_q][1] == 1'b1) && (txdat_sent_sx_q[txdat_entry_idx_sx_q][1] == 2'b01))) ? 2'b00 //ccid[1]=0,packet1;ccid[1]=1,packet2
                                    : (((rxreq_ccid_s1_q[txdat_entry_idx_sx_q][1] == 1'b0) && (txdat_rdy_sx_q[txdat_entry_idx_sx_q][1] == 1'b1) && (txdat_sent_sx_q[txdat_entry_idx_sx_q] == 2'b01))
                                        | ((rxreq_ccid_s1_q[txdat_entry_idx_sx_q][1] == 1'b1) && (txdat_rdy_sx_q[txdat_entry_idx_sx_q][0] == 1'b1) && (txdat_sent_sx_q[txdat_entry_idx_sx_q][0] == 1'b0)) ? 2'b10 // ccid[1]=0,packet2;ccid[1]=1,packet1
                                            : 2'b00));
    assign mshr_txdat_txnid_sx      = (rxreq_dodmt_s1_q[txdat_entry_idx_sx_q] == 1'b1) ? rxreq_returntxnid_s1_q[txdat_entry_idx_sx_q] : rxreq_txnid_s1_q[txdat_entry_idx_sx_q];
    assign mshr_txdat_opcode_sx     = `CHIE_COMPDATA;
    assign mshr_txdat_resp_sx       = `CHIE_COMP_RESP_UC;
    assign mshr_txdat_resperr_sx    = 2'b00;
    assign mshr_txdat_dbid_sx       = rxreq_txnid_s1_q[txdat_entry_idx_sx_q];
    assign mshr_txdat_tgtid_sx      = (rxreq_dodmt_s1_q[txdat_entry_idx_sx_q] == 1'b1) ? rxreq_returnnid_s1_q[txdat_entry_idx_sx_q] : rxreq_srcid_s1_q[txdat_entry_idx_sx_q];
    assign mshr_txdat_srcid_sx      = rxreq_tgtid_s1_q[txdat_entry_idx_sx_q];
    assign mshr_txdat_homenid_sx    = rxreq_srcid_s1_q[txdat_entry_idx_sx_q];
    assign mshr_txdat_tracetag_sx   = rxreq_tracetag_s1_q[txdat_entry_idx_sx_q];

    //************************************************************************//
    //                       mshr AW channel logic                            //
    //************************************************************************//
    always @(posedge clk or posedge rst) begin: awvalid_fifo_in_comb_logic
        if(rst == 1'b1)
            awvalid_fifo_cnt_sx_q   <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        else if(dbf_mshr_rxdat_ok_sx && !dbf_mshr_rxdat_cancel_sx)
            awvalid_fifo_cnt_sx_q   <= ((awvalid_fifo_cnt_sx_q + 1) == `SNF_MSHR_ENTRIES_NUM) ? 1'b0 : (awvalid_fifo_cnt_sx_q + 1);
    end

    always @(posedge clk or posedge rst) begin: awvalid_fifo_out_comb_logic
        if(rst == 1'b1)
            awvalid_fifo_vec_sx        <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        else if((awvalid_sx == 1'b1) && (awready_sx == 1'b1))
            awvalid_fifo_vec_sx        <= ((awvalid_fifo_vec_sx + 1) == `SNF_MSHR_ENTRIES_NUM) ? 1'b0 : (awvalid_fifo_vec_sx + 1);
    end

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin: awvalid_fifo_set_comb_logic
                if(rst == 1'b1)begin
                    awvalid_fifo_valid_s2_q[entry]      <= 1'b0;
                    awvalid_fifo_idx_s2_q[entry]        <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
                end
                else if (dbf_mshr_rxdat_ok_sx && !dbf_mshr_rxdat_cancel_sx && (awvalid_fifo_cnt_sx_q == entry)) begin
                    awvalid_fifo_valid_s2_q[entry]      <= 1'b1;
                    awvalid_fifo_idx_s2_q[entry]        <= dbf_mshr_rxdat_ok_idx_sx;
                end
                else if ((awvalid_sx == 1'b1) && (awready_sx == 1'b1) && (awvalid_fifo_vec_sx == entry))begin
                    awvalid_fifo_valid_s2_q[entry]      <= 1'b0;
                    awvalid_fifo_idx_s2_q[entry]        <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
                end
                else begin
                    ;
                end
            end
        end
    endgenerate

    always @(posedge clk or posedge rst)begin : mshr_aw_timing_logic
        if(rst == 1'b1) begin
            awvalid_sx              <= 1'b0;
            awvalid_entry_idx_s2_q  <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if((awvalid_sx == 1'b1) && (awready_sx == 1'b1))begin
            awvalid_sx              <= 1'b0;
            awvalid_entry_idx_s2_q  <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(awvalid_fifo_valid_s2_q[awvalid_fifo_vec_sx])begin
            awvalid_sx              <= 1'b1;
            awvalid_entry_idx_s2_q  <= awvalid_fifo_idx_s2_q[awvalid_fifo_vec_sx];
        end
    end

    assign awid_sx                = rxreq_axid_s1_q[awvalid_entry_idx_s2_q];
    assign awaddr_sx              = rxreq_axaddr_s1_q[awvalid_entry_idx_s2_q];
    assign awcache_sx[0]          = rxreq_memattr_s1_q[awvalid_entry_idx_s2_q][0];
    assign awcache_sx[1]          = ~rxreq_memattr_s1_q[awvalid_entry_idx_s2_q][1];
    assign awcache_sx[2]          = rxreq_memattr_s1_q[awvalid_entry_idx_s2_q][2];
    assign awcache_sx[3]          = rxreq_memattr_s1_q[awvalid_entry_idx_s2_q][3];
    assign awqos_sx               = rxreq_qos_s1_q[awvalid_entry_idx_s2_q];
    assign awprot_sx              = {1'b0,rxreq_ns_s1_q[awvalid_entry_idx_s2_q],1'b0};
    assign awlen_sx               = rxreq_axlen_s1_q[awvalid_entry_idx_s2_q];
    assign awsize_sx              = rxreq_axsize_s1_q[awvalid_entry_idx_s2_q];
    assign awburst_sx             = 2'b01;
    assign awlock_sx              = 1'b0;
    assign awregion_sx            = {`AXI4_AWREGION_WIDTH{1'b0}};

    always @(posedge clk or posedge rst)begin
        if (rst)
            mshr_wdat_en_rst   <= 1'b0;
        else
            mshr_wdat_en_rst   <= awvalid_sx;
    end

    assign mshr_wdat_en_sx        = awvalid_sx & (~mshr_wdat_en_rst);
    assign mshr_wdat_entry_idx_sx = awvalid_entry_idx_s2_q;

    //************************************************************************//
    //                      mshr B channel logic                              //
    //************************************************************************//

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign bresp_ok_sx[entry] = bvalid_sx && bready_sx & (bid_sx == entry);
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin  //bresp received
            always @(posedge clk or posedge rst)begin : mshr_bresp_complete_flag_timing_logic
                if (rst)
                    bresp_ok_q[entry] <= 1'b0;
                else if (retired_entry_sx[entry])
                    bresp_ok_q[entry] <= 1'b0;
                else if (bresp_ok_sx[entry])
                    bresp_ok_q[entry] <= 1'b1;
                else
                    ;
            end
        end
    endgenerate

    assign bready_sx    = ~rst;

    //************************************************************************//
    //                      mshr check hazard ownership logic                 //
    //************************************************************************//
    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign hazard_sx[entry] = rxreq_alloc_en_s0 & (~hazard_sx_q[entry]) & mshr_entry_valid_sx_q[entry] & (rxreq_addr_s1_q[entry][`CHIE_REQ_FLIT_ADDR_WIDTH-1:6] == rxreq_addr_s0[`CHIE_REQ_FLIT_ADDR_WIDTH-1:6]);
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin : mshr_wakeup_logic
                if (rst == 1'b1) begin
                    hazard_sx_q[entry]     <= 1'b0;
                    hazard_idx_s2_q[entry] <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
                end
                else if (mshr_retired_valid_sx && (mshr_retired_idx_sx == entry)) begin
                    hazard_sx_q[entry]     <= 1'b0;
                    hazard_idx_s2_q[entry] <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
                end
                else if (hazard_sx[entry]) begin
                    hazard_sx_q[entry]     <= 1'b1;
                    hazard_idx_s2_q[entry] <= mshr_entry_idx_alloc_s0;
                end
            end

            always @(posedge clk or posedge rst)begin : mshr_sleep_logic
                if (rst == 1'b1)
                    sleep_s2_q[entry]               <= 1'b0;
                else if (wakeup_valid & (wakeup_idx_sx == entry))
                    sleep_s2_q[entry]               <= 1'b0;
                else if (rxreq_alloc_en_s0 & (|hazard_sx) & (mshr_entry_idx_alloc_s0 == entry))
                    sleep_s2_q[entry]               <= 1'b1;
            end
        end
    endgenerate

    assign wakeup_valid         = mshr_retired_valid_sx ? hazard_sx_q[mshr_retired_idx_sx] : 1'b0;
    assign wakeup_idx_sx        = mshr_retired_valid_sx ? hazard_idx_s2_q[mshr_retired_idx_sx] : {`SNF_MSHR_ENTRIES_NUM{1'b0}};

    //************************************************************************//
    //                  rxdat logic : rxdat_cancel save                       //
    //************************************************************************//

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin : rxdat_cancel_s1_q_timing_logic
                if(rst == 1'b1)
                    rxdat_cancel_s1_q[entry]          <= 1'b0;
                else if(dbf_mshr_rxdat_cancel_sx && (entry == dbf_mshr_rxdat_cancel_idx_sx))
                    rxdat_cancel_s1_q[entry]          <= 1'b1;
                else if(mshr_retired_valid_sx && (entry == mshr_retired_idx_sx))
                    rxdat_cancel_s1_q[entry]          <= 1'b0;
                else
                    ;
            end
        end
    endgenerate

    //************************************************************************//
    //                         mshr retire logic                              //
    //************************************************************************//
    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign retired_entry_sx[entry]  = (mshr_entry_valid_sx_q[entry] && (~sleep_s2_q[entry]))
                                                && (((rxreq_wr_s1_q[entry]) && (((~rxdat_cancel_s1_q[entry]) && bresp_ok_q[entry] && (~txrsp_comp_s1_q[entry])) | ((~rxdat_cancel_s1_q[entry]) && bresp_ok_q[entry] && txrsp_comp_s1_q[entry] && txrsp_comp_sent_sx_q[entry]) | ((rxdat_cancel_s1_q[entry]) && txrsp_comp_s1_q[entry] && txrsp_comp_sent_sx_q[entry]) | ((rxdat_cancel_s1_q[entry]) && (~txrsp_comp_s1_q[entry]))))
                                                    |((rxreq_rd_s1_q[entry]) && (~txrsp_rdreceipt_valid_sx_q[entry]) && (((rxreq_size_s1_q[entry] == 3'b110) && (txdat_sent_sx_q[entry] == 2'b11)) | ((rxreq_size_s1_q[entry] != 3'b110) && ((txdat_sent_sx_q[entry] == 2'b01) | (txdat_sent_sx_q[entry] == 2'b10))))));
        end
    endgenerate

    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin
                if(rst == 1'b1)
                    retired_entry_sx1_q[entry]  <=1'b0;
                else if (retired_entry_sx[entry])
                    retired_entry_sx1_q[entry]  <= 1'b1;
                else if (mshr_retired_valid_sx && (mshr_retired_idx_sx == entry))
                    retired_entry_sx1_q[entry]  <= 1'b0;
            end
        end
    endgenerate

    always @* begin
        integer k;
        retired_entry_idx_sx1_q = {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        for (k=0; k < `SNF_MSHR_ENTRIES_NUM; k=k+1) begin
            if(retired_entry_sx1_q[k])
                retired_entry_idx_sx1_q = k;
        end
    end

    assign mshr_retired_valid_sx    = |retired_entry_sx1_q;
    assign mshr_retired_idx_sx      = retired_entry_idx_sx1_q;

endmodule

