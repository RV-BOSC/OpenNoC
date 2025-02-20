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
*    Li Zhao <lizhao@bosc.ac.cn>
*    Nana Cai <cainana@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*    Xiaotian Cao <caoxiaotian@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "axi4_defines.v"
`include "hni_defines.v"
`include "hni_param.v"

module hni_mshr `HNI_PARAM
    (
        clk,
        rst,        

        rxreq_alloc_en_s0,
        rxreq_alloc_flit_s0,
        mshr_entry_idx_alloc_s0,        

        excl_pass_s1,
        excl_fail_s1,       

        rxrsp_valid_s0,
        rxrspflit_s0,       

        mshr_entry_sleep_s1,
        txrsp_valid_sx_q,
        txrsp_qos_sx,
        txrsp_tgtid_sx,
        txrsp_txnid_sx,
        txrsp_opcode_sx,
        txrsp_resperr_sx,
        txrsp_resp_sx,
        txrsp_dbid_sx,
        txrsp_tracetag_sx,

        txrsp_won_sx,
        txrsp_fp_won_s1,

        rxreq_dbf_en_s0,
        rxreq_dbf_axid_s0,
        rxreq_dbf_addr_s0,
        rxreq_dbf_device_s0,
        rxreq_dbf_wr_s0,   //write txn
        rxreq_dbf_size_s0,
        rxreq_dbf_axlen_s0,
        rxreq_dbf_entry_idx_s0,

        mshr_rdat_en_sx,   //mshr allow dbf receive data from slave
        mshr_rdat_entry_idx_sx,

        dbf_rvalid_sx,  //dbf receive rdata
        dbf_rvalid_entry_idx_sx,
        dbf_cdmask_sx,

        mshr_txdat_en_sx,   //mshr allow dbf send data to chi xp
        mshr_txdat_dataid_sx,
        mshr_txdat_txnid_sx,
        mshr_txdat_opcode_sx,
        mshr_txdat_resp_sx,
        mshr_txdat_resperr_sx,
        mshr_txdat_dbid_sx,
        mshr_txdat_tgtid_sx,
        mshr_txdat_tracetag_sx,
        mshr_txdat_won_sx,

        dbf_rxdat_valid_s0,
        dbf_rxdat_txnid_s0,
        dbf_rxdat_opcode_s0,
        dbf_rxdat_dataid_s0,

        mshr_wdat_en_sx,    //send data to axi slave enable
        mshr_wdat_entry_idx_sx,
        dbf_wdat_last,

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
    //inputs
    input wire                                          clk;
    input wire                                          rst;

    //inputs from hni_qos
    input  wire                                         rxreq_alloc_en_s0;
    input  wire [`CHIE_REQ_FLIT_RANGE]                  rxreq_alloc_flit_s0;
    input  wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]           mshr_entry_idx_alloc_s0;

    //inouts with hni_global_monitor
    input wire                                          excl_pass_s1;
    input wire                                          excl_fail_s1;

    //inouts with hni_rxrsp
    input wire                                          rxrsp_valid_s0;
    input wire [`CHIE_RSP_FLIT_RANGE]                   rxrspflit_s0;

    //inouts with hni_txrsp
    output wire                                         mshr_entry_sleep_s1;
    output reg                                          txrsp_valid_sx_q;
    output wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]          txrsp_qos_sx;
    output wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]        txrsp_tgtid_sx;
    output wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]        txrsp_txnid_sx;
    output wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]       txrsp_opcode_sx;
    output wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]      txrsp_resperr_sx;
    output wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]         txrsp_resp_sx;
    output wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]         txrsp_dbid_sx;
    output wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]     txrsp_tracetag_sx;

    input wire                                          txrsp_won_sx;
    input wire                                          txrsp_fp_won_s1;

    //inouts with hni_data_buffer
    output wire                                         rxreq_dbf_en_s0;
    output wire [`HNI_AXI4_AXID_WIDTH-1:0]              rxreq_dbf_axid_s0;
    output wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]         rxreq_dbf_addr_s0;
    output wire                                         rxreq_dbf_device_s0;
    output wire                                         rxreq_dbf_wr_s0;   //write txn
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]         rxreq_dbf_size_s0; 
    output wire [`AXI4_AWLEN_WIDTH-1:0]                 rxreq_dbf_axlen_s0;

    output wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]           rxreq_dbf_entry_idx_s0;

    output wire                                         mshr_rdat_en_sx;   //mshr allow dbf receive data from slave
    output wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]           mshr_rdat_entry_idx_sx;

    input  wire                                         dbf_rvalid_sx;  //dbf receive rdata
    input  wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]           dbf_rvalid_entry_idx_sx;
    input  wire [3:0]                                   dbf_cdmask_sx;

    output wire                                         mshr_txdat_en_sx;   //mshr allow dbf send data to chi xp
    output wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]       mshr_txdat_dataid_sx;
    output wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]        mshr_txdat_txnid_sx;
    output wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]       mshr_txdat_opcode_sx;
    output wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]         mshr_txdat_resp_sx;
    output wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]      mshr_txdat_resperr_sx;
    output wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]         mshr_txdat_dbid_sx;
    output wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]        mshr_txdat_tgtid_sx;
    output wire [`CHIE_DAT_FLIT_TRACETAG_WIDTH-1:0]     mshr_txdat_tracetag_sx;
    input wire                                          mshr_txdat_won_sx;

    input wire                                          dbf_rxdat_valid_s0;
    input wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]         dbf_rxdat_txnid_s0;
    input wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]        dbf_rxdat_opcode_s0;
    input wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]        dbf_rxdat_dataid_s0;

    output wire                                         mshr_wdat_en_sx;    //send data to axi slave enable
    output wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]           mshr_wdat_entry_idx_sx;
    input  wire                                         dbf_wdat_last;

    //outputs to hni_qos, hni_data_buffer
    output wire                                         mshr_retired_valid_sx;
    output wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]           mshr_retired_idx_sx;

    //inout with axi slaves
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

    //internal reg
    reg                                         rxreq_alloc_en_s1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           mshr_entry_idx_alloc_s1_q;

    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             mshr_entry_valid_sx_q;

    reg [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]       rxreq_opcode_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]          rxreq_qos_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]      rxreq_memattr_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg                                         rxreq_device_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]        rxreq_srcid_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]        rxreq_txnid_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxreq_excl_s1_q;
    reg [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]         rxreq_size_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]         rxreq_addr_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_NS_WIDTH-1:0]           rxreq_ns_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]        rxreq_order_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxreq_expcompack_s1_q;
    reg [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]     rxreq_tracetag_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxreq_excl_pass_s2_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxreq_excl_fail_s2_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxreq_rd_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxreq_wrf_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxreq_wrp_s1_q;
    reg [`CHIE_DAT_FLIT_CCID_WIDTH-1:0]         rxreq_ccid_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]         rxreq_alignaddr_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`HNI_AXI4_AXID_WIDTH-1:0]              rxreq_axid_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`AXI4_AWLEN_WIDTH-1:0]                 rxreq_axlen_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`AXI4_AWSIZE_WIDTH-1:0]                rxreq_axsize_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];

    reg [`HNI_AXI4_AXID_WIDTH-1:0]              rxreq_axid_s0;    
    reg [1:0]                                   addr_region_id;
    reg [2:0]                                   addr_range_compare;
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1-12:0]      addr_order_region_aligned;

    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxrsp_compack_s1_q;

    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxdat_data1_valid_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxdat_data2_valid_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             dbf_rxdat_ok_s2_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rxdat_compack_s1_q;

    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             txrsp_fifo_valid_s1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           txrsp_fifo_entry_idx_sx_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]       txrsp_fifo_opcode_s1_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           txrsp_fifo_set_s1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           txrsp_fifo_cnt_sx_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           txrsp_entry_idx_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             txrsp_sent_q;

    reg [1:0]                                   txdat_fifo_rdy_sx_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [2*`HNI_MSHR_ENTRIES_NUM-1:0]           txdat_fifo_valid_s1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           txdat_fifo_entry_idx_sx_q[2*`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]       txdat_fifo_dataid_s1_q[2*`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`HNI_MSHR_ENTRIES_WIDTH:0]             txdat_fifo_set_s1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH:0]             txdat_fifo_cnt_sx_q;
    reg                                         txdat_en_sx_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           txdat_entry_idx_sx_q;
    reg [1:0]                                   txdat_sent_sx_q[`HNI_MSHR_ENTRIES_NUM-1:0];

    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             arvalid_fifo_s1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           arvalid_fifo_idx_sx_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           arvalid_fifo_set_sx_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           arvalid_fifo_cnt_sx_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           arvalid_entry_idx_s1_q;

    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             rdat_valid_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           rdat_entry_idx_s1_q;
    reg [3:0]                                   rdat_pdmask_q[`HNI_MSHR_ENTRIES_NUM-1:0];

    reg                                         dbf_rxdat_valid_s1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           dbf_rxdat_txnid_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             awvalid_fifo_s2_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           awvalid_fifo_idx_s2_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           awvalid_fifo_set_s2_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           awvalid_fifo_cnt_sx_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           awvalid_entry_idx_s2_q;
    reg                                         awvalid_sx1_q;

    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             bresp_ok_q;
    reg                                         wdat_wait_sx_q;

    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             mshr_entry_sleep_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             need_to_wakeup_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           need_to_wakeup_idx_q[`HNI_MSHR_ENTRIES_NUM-1:0];
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             sleep_sx_q;

    reg [`HNI_MSHR_ENTRIES_NUM-1:0]             retired_entry_sx1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]           retired_entry_idx_sx1_q;

    //wire 
    wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]         rxreq_qos_s0;
    wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]       rxreq_srcid_s0;
    wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]       rxreq_txnid_s0;
    wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]      rxreq_opcode_s0;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        rxreq_size_s0;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        rxreq_addr_s0;
    wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]          rxreq_ns_s0;
    wire                                        rxreq_allowretry_s0;
    wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]       rxreq_order_s0;
    wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]    rxreq_pcrdtype_s0;
    wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]     rxreq_memattr_s0;
    wire                                        rxreq_device_s0;
    wire [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]        rxreq_lpid_s0;
    wire                                        rxreq_excl_s0;
    wire                                        rxreq_expcompack_s0;
    wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]    rxreq_tracetag_s0;
    wire                                        rxreq_rd_s0;
    wire                                        rxreq_wrf_s0;
    wire                                        rxreq_wrp_s0;
    wire [`AXI4_AWSIZE_WIDTH-1:0]               rxreq_axsize_s0;
    wire [`AXI4_AWLEN_WIDTH-1:0]                rxreq_axlen_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]            mshr_entry_alloc_sx;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1-12:0]     sam_addrregion_idx[2:0];
    wire [5:0]                                  sam_addrregion_size[2:0];
    wire [5:0]                                  sam_order_region_size[2:0];
    wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       rxrsp_entry_idx_s0;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      rxrsp_opcode_s0;
    wire                                        rxdat_valid_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]            rxdat_entry_idx_s0;
    wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]      rxdat_opcode_s0;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]      rxdat_dataid_s0;
    wire                                        rxdat_data1_valid_s0;
    wire                                        rxdat_data2_valid_s0;
    wire                                        dbf_rxdat_ok_s1;
    wire                                        txrsp_en_s1;
    wire                                        txrsp_compdbid_en_s1;
    wire                                        txrsp_readreceipt_en_s1;
    wire                                        txrsp_en2_s1;
    wire                                        txrsp_compdbid_en2_s1;
    wire                                        txrsp_readreceipt_en2_s1;
    wire                                        txdat_en_sx;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]            txdat1_en_sx;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]            txdat2_en_sx;
    wire                                        arvalid_en_s1;
    wire                                        arvalid_en2_s1;
    wire                                        awvalid_en_s1;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]            need_to_sleep_s0;
    wire                                        wakeup_valid;
    wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]          wakeup_idx_sx;
    wire [`HNI_MSHR_ENTRIES_NUM-1: 0]           compack_ok_sx;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]            retired_entry_sx;

//main function
    genvar entry, i, j;
    integer k;

    //************************************************************************//

    //          mshr allocate s0 stage request fields decode logic

    //************************************************************************//

    //rxreq_alloc_flit_s0 decode
    assign rxreq_qos_s0        = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_QOS_RANGE]           :{`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};
    assign rxreq_srcid_s0      = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_SRCID_RANGE]         :{`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
    assign rxreq_txnid_s0      = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_TXNID_RANGE]         :{`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
    assign rxreq_opcode_s0     = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_OPCODE_RANGE]        :{`CHIE_REQ_FLIT_OPCODE_WIDTH{1'b0}};
    assign rxreq_size_s0       = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_SIZE_RANGE]          :{`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
    assign rxreq_addr_s0       = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_ADDR_RANGE]          :{`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
    assign rxreq_ns_s0         = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_NS_RANGE]            :{`CHIE_REQ_FLIT_NS_WIDTH{1'b0}};
    assign rxreq_allowretry_s0 = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE]    :{`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH{1'b0}};
    assign rxreq_order_s0      = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_ORDER_RANGE]         :{`CHIE_REQ_FLIT_ORDER_WIDTH{1'b0}};
    assign rxreq_pcrdtype_s0   = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_PCRDTYPE_RANGE]      :{`CHIE_REQ_FLIT_PCRDTYPE_WIDTH{1'b0}};
    assign rxreq_memattr_s0    = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_MEMATTR_RANGE]       :{`CHIE_REQ_FLIT_MEMATTR_WIDTH{1'b0}};
    assign rxreq_device_s0     = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_MEMATTR_DEVICE_RANGE]:{`CHIE_REQ_FLIT_MEMATTR_DEVICE_WIDTH{1'b0}};
    assign rxreq_lpid_s0       = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_LPID_RANGE]          :{`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
    assign rxreq_excl_s0       = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_EXCL_RANGE]          :{`CHIE_REQ_FLIT_EXCL_WIDTH{1'b0}};
    assign rxreq_expcompack_s0 = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_EXPCOMPACK_RANGE]    :{`CHIE_REQ_FLIT_EXPCOMPACK_WIDTH{1'b0}};
    assign rxreq_tracetag_s0   = (rxreq_alloc_en_s0 == 1'b1)? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_TRACETAG_RANGE]      :{`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
    assign rxreq_rd_s0         = (rxreq_alloc_en_s0 == 1'b1)? ((rxreq_opcode_s0 == `CHIE_READNOSNP)|(rxreq_opcode_s0 == `CHIE_READONCE)|(rxreq_opcode_s0 == `CHIE_READCLEAN)|(rxreq_opcode_s0 == `CHIE_READNOTSHAREDDIRTY)|(rxreq_opcode_s0 == `CHIE_READUNIQUE)) :1'b0;
    assign rxreq_wrf_s0        = (rxreq_alloc_en_s0 == 1'b1)? ((rxreq_opcode_s0 == `CHIE_WRITENOSNPFULL)|(rxreq_opcode_s0 == `CHIE_WRITECLEANFULL)|(rxreq_opcode_s0 == `CHIE_WRITEEVICTFULL)|(rxreq_opcode_s0 == `CHIE_WRITEBACKFULL)|(rxreq_opcode_s0 == `CHIE_WRITEUNIQUEFULL)):1'b0;
    assign rxreq_wrp_s0        = (rxreq_alloc_en_s0 == 1'b1)? ((rxreq_opcode_s0 == `CHIE_WRITENOSNPPTL)|(rxreq_opcode_s0 == `CHIE_WRITEUNIQUEPTL)):1'b0;

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign mshr_entry_alloc_sx[entry] = (rxreq_alloc_en_s0 == 1'b1) && (mshr_entry_idx_alloc_s0 == entry);
        end
    endgenerate

    //ax channel signal
    assign rxreq_axsize_s0  = ((rxreq_size_s0 == 3'b110) | (rxreq_size_s0 == 3'b101)) ? 3'b100 : rxreq_size_s0;
    assign rxreq_axlen_s0   = rxreq_device_s0 ? ((rxreq_size_s0 == 3'b110) ? (8'b11-rxreq_addr_s0[5:4]) : ((rxreq_size_s0 == 3'b101) ? ({7'b0,~rxreq_addr_s0[4]}) : 8'b0)) : ((rxreq_size_s0 == 3'b110) ? 'b11 : ((rxreq_size_s0 == 3'b101) ? 'b1 : 8'b0));

    assign rxreq_dbf_en_s0        = rxreq_alloc_en_s0;
    assign rxreq_dbf_axid_s0      = rxreq_axid_s0;
    assign rxreq_dbf_addr_s0      = rxreq_addr_s0;
    assign rxreq_dbf_device_s0    = rxreq_device_s0;
    assign rxreq_dbf_wr_s0        = rxreq_wrf_s0 | rxreq_wrp_s0;
    assign rxreq_dbf_size_s0      = rxreq_size_s0;
    assign rxreq_dbf_axlen_s0     = rxreq_axlen_s0;
    assign rxreq_dbf_entry_idx_s0 = mshr_entry_idx_alloc_s0;

    //fields reg
    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin : mshr_entry_valid_s1_q_logic
                if(rst == 1'b1)
                    mshr_entry_valid_sx_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    mshr_entry_valid_sx_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    mshr_entry_valid_sx_q[entry] <= 1'b1;
            end

            always @(posedge clk or posedge rst)begin : rxreq_rd_s1_q_logic
                if(rst == 1'b1)
                    rxreq_rd_s1_q[entry] <= 0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_rd_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_rd_s1_q[entry] <= rxreq_rd_s0;
            end

            always @(posedge clk or posedge rst)begin : rxreq_wrf_s1_q_logic
                if(rst == 1'b1)
                    rxreq_wrf_s1_q[entry] <= 0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_wrf_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_wrf_s1_q[entry] <= rxreq_wrf_s0;
            end

            always @(posedge clk or posedge rst)begin : rxreq_wrp_s1_q_logic
                if(rst == 1'b1)
                    rxreq_wrp_s1_q[entry] <= 0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_wrp_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_wrp_s1_q[entry] <= rxreq_wrp_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_qos_s1_q_logic
                if(rst == 1'b1)
                    rxreq_qos_s1_q[entry] <= {`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_qos_s1_q[entry] <= {`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_qos_s1_q[entry] <= rxreq_qos_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_srcid_s1_q_logic
                if(rst == 1'b1)
                    rxreq_srcid_s1_q[entry] <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_srcid_s1_q[entry] <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_srcid_s1_q[entry] <= rxreq_srcid_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_txnid_s1_q_logic
                if(rst == 1'b1)
                    rxreq_txnid_s1_q[entry] <= {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_txnid_s1_q[entry] <= {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_txnid_s1_q[entry] <= rxreq_txnid_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_opcode_s1_q_logic
                if(rst == 1'b1)
                    rxreq_opcode_s1_q[entry] <= {`CHIE_REQ_FLIT_OPCODE_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_opcode_s1_q[entry] <= {`CHIE_REQ_FLIT_OPCODE_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_opcode_s1_q[entry] <= rxreq_opcode_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_size_s1_q_logic
                if(rst == 1'b1)
                    rxreq_size_s1_q[entry] <= {`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_size_s1_q[entry] <= {`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_size_s1_q[entry] <= rxreq_size_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_addr_s1_q_logic
                if(rst == 1'b1)
                    rxreq_addr_s1_q[entry] <= {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_addr_s1_q[entry] <= {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_addr_s1_q[entry] <= rxreq_addr_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_alignaddr_s1_q_logic
                if(rst == 1'b1)
                    rxreq_alignaddr_s1_q[entry] <= {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_alignaddr_s1_q[entry] <= {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_alignaddr_s1_q[entry] <= ((rxreq_addr_s0 >> rxreq_size_s0) << rxreq_size_s0);
            end

            always @(posedge clk or posedge rst)begin : mshr_ns_s1_q_logic
                if(rst == 1'b1)
                    rxreq_ns_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_ns_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_ns_s1_q[entry] <= rxreq_ns_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_order_s1_q_logic
                if(rst == 1'b1)
                    rxreq_order_s1_q[entry] <= {`CHIE_REQ_FLIT_ORDER_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_order_s1_q[entry] <= {`CHIE_REQ_FLIT_ORDER_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_order_s1_q[entry] <= rxreq_order_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_memattr_s1_q_logic
                if(rst == 1'b1)
                    rxreq_memattr_s1_q[entry] <= {`CHIE_REQ_FLIT_MEMATTR_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_memattr_s1_q[entry] <= {`CHIE_REQ_FLIT_MEMATTR_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_memattr_s1_q[entry] <= rxreq_memattr_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_device_s1_q_logic
                if(rst == 1'b1)
                    rxreq_device_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_device_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_device_s1_q[entry] <= rxreq_device_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_excl_s1_q_logic
                if(rst == 1'b1)
                    rxreq_excl_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_excl_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_excl_s1_q[entry] <= rxreq_excl_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_expcompack_s1_q_logic
                if(rst == 1'b1)
                    rxreq_expcompack_s1_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_expcompack_s1_q[entry] <= 1'b0;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_expcompack_s1_q[entry] <= rxreq_expcompack_s0;
            end

            always @(posedge clk or posedge rst)begin : mshr_tracetag_s1_q_logic
                if(rst == 1'b1)
                    rxreq_tracetag_s1_q[entry] <= {`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_tracetag_s1_q[entry] <= {`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_tracetag_s1_q[entry] <= rxreq_tracetag_s0;
            end

            //ADDR[5:4]:identifies the critical chunk
            always @(posedge clk or posedge rst)begin : axlen_logic
                if(rst == 1'b1)
                    rxreq_axlen_s1_q[entry] <= {`AXI4_AWLEN_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_axlen_s1_q[entry] <= {`AXI4_AWLEN_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_axlen_s1_q[entry] <= rxreq_axlen_s0;
            end

            always @(posedge clk or posedge rst)begin : axsize_logic
                if(rst == 1'b1)
                    rxreq_axsize_s1_q[entry] <= {`AXI4_AWSIZE_WIDTH{1'b0}};
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_axsize_s1_q[entry] <= {`AXI4_AWSIZE_WIDTH{1'b0}};
                else if(mshr_entry_alloc_sx[entry] == 1'b1)begin
                    rxreq_axsize_s1_q[entry] <= rxreq_axsize_s0;
                end
            end

            always @(posedge clk or posedge rst)begin : mshr_ccid_s1_q_logic
                if(rst == 1'b1)
                    rxreq_ccid_s1_q[entry] <= 2'b00;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxreq_ccid_s1_q[entry] <= 2'b00;
                else if(mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_ccid_s1_q[entry] <= rxreq_addr_s0[5:4];
            end

            always @(posedge clk or posedge rst)begin : mshr_excl_pass_s_q_logic
                if(rst == 1'b1)begin
                    rxreq_excl_pass_s2_q[entry] <= 1'b0;
                    rxreq_excl_fail_s2_q[entry] <= 1'b0;
                end   
                else if(retired_entry_sx1_q[entry] == 1'b1) begin
                    rxreq_excl_pass_s2_q[entry] <= 1'b0;
                    rxreq_excl_fail_s2_q[entry] <= 1'b0;                    
                end
                else if(rxreq_alloc_en_s1_q && (mshr_entry_idx_alloc_s1_q == entry))begin
                    rxreq_excl_pass_s2_q[entry] <= excl_pass_s1;
                    rxreq_excl_fail_s2_q[entry] <= excl_fail_s1; 
                end
            end
        end
    endgenerate

    always @(posedge clk or posedge rst)begin : mshr_rxreq_alloc_s1_q_logic
        if(rst)begin
            rxreq_alloc_en_s1_q         <= 1'b0;
            mshr_entry_idx_alloc_s1_q   <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else begin
            rxreq_alloc_en_s1_q         <= rxreq_alloc_en_s0;
            mshr_entry_idx_alloc_s1_q   <= mshr_entry_idx_alloc_s0;
        end
    end

    //************************************************************************//

    //                            mshr sam logic

    //************************************************************************//

    wire [`HNI_AXI4_AXADDR_WIDTH-1:0] rxreq_addralign_s0[HNI_ADDR_REGION_NUM-1:0];
    generate
        for(i=0;i< HNI_ADDR_REGION_NUM;i=i+1) begin:rxreq_addralign_s0_val
            assign rxreq_addralign_s0[i] = (rxreq_addr_s0 >> HNI_ADDR_REGION_SIZE[i]);
        end
    endgenerate
    always @* begin: rxreq_axid_s0_val
        rxreq_axid_s0 = {`HNI_AXI4_AXID_WIDTH{1'b0}};
        for(k=0;k< HNI_ADDR_REGION_NUM;k=k+1) begin
            if (rxreq_addralign_s0[k] == (HNI_ADDR_REGION_LSB[k] >> HNI_ADDR_REGION_SIZE[k])) begin
                rxreq_axid_s0 = k+1;
            end
        end
    end

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin : sam_axid_logic
                if (rst ==1'b1)
                    rxreq_axid_s1_q[entry] <= {`HNI_AXI4_AXID_WIDTH{1'b0}};
                else if (retired_entry_sx[entry] == 1'b1)
                    rxreq_axid_s1_q[entry] <= {`HNI_AXI4_AXID_WIDTH{1'b0}};
                else if (mshr_entry_alloc_sx[entry] == 1'b1)
                    rxreq_axid_s1_q[entry] <= rxreq_axid_s0;
            end
        end
    endgenerate

    //************************************************************************//

    //                        mshr rxrsp channel decode logic

    //************************************************************************//
    //rsp flit decode
    assign rxrsp_entry_idx_s0 = (rxrsp_valid_s0 == 1'b1)? rxrspflit_s0[`CHIE_RSP_FLIT_TXNID_RANGE]  :{`CHIE_RSP_FLIT_TXNID_WIDTH{1'b0}};
    assign rxrsp_opcode_s0    = (rxrsp_valid_s0 == 1'b1)? rxrspflit_s0[`CHIE_RSP_FLIT_OPCODE_RANGE] :{`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}};

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin : mshr_rsp_entry_vec_s0_logic
            always @(posedge clk or posedge rst)begin : rxrsp_compack_s1_q_logic
                if(rst == 1'b1)
                    rxrsp_compack_s1_q[entry] <= 0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxrsp_compack_s1_q[entry] <= 1'b0;
                else if((rxrsp_valid_s0 == 1'b1) && (entry == rxrsp_entry_idx_s0))
                    rxrsp_compack_s1_q[entry] <= (rxrsp_opcode_s0 == `CHIE_COMPACK);
            end
        end
    endgenerate

    //************************************************************************//

    //                       mshr rxdat channel decode logic

    //************************************************************************//

    assign rxdat_valid_s0           = dbf_rxdat_valid_s0;
    assign rxdat_entry_idx_s0       = dbf_rxdat_txnid_s0;
    assign rxdat_opcode_s0          = dbf_rxdat_opcode_s0;
    assign rxdat_dataid_s0          = dbf_rxdat_dataid_s0;

    assign rxdat_data1_valid_s0     = (rxdat_valid_s0 == 1'b1) ? (rxdat_dataid_s0 == 2'b00) : 1'b0;
    assign rxdat_data2_valid_s0     = (rxdat_valid_s0 == 1'b1) ? (rxdat_dataid_s0 == 2'b10) : 1'b0;

    always @(posedge clk or posedge rst) begin: rxdat_logic
        if(rst == 1'b1) begin
            dbf_rxdat_valid_s1_q <= 1'b0;
            dbf_rxdat_txnid_s1_q <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else begin
            dbf_rxdat_valid_s1_q  <= dbf_rxdat_valid_s0;
            dbf_rxdat_txnid_s1_q  <= dbf_rxdat_txnid_s0;
        end
    end

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin : mshr_dat_entry_vec_s0_logic
            always @(posedge clk or posedge rst)begin : rxdat_data1_valid_s1_q_logic
                if(rst == 1'b1)
                    rxdat_data1_valid_s1_q[entry] <= 0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxdat_data1_valid_s1_q[entry] <= 1'b0;
                else if((rxdat_data1_valid_s0 == 1'b1) && (entry == rxdat_entry_idx_s0))
                    rxdat_data1_valid_s1_q[entry] <= 1'b1;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : rxdat_data2_valid_s1_q_logic
                if(rst == 1'b1)
                    rxdat_data2_valid_s1_q[entry] <= 0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxdat_data2_valid_s1_q[entry] <= 1'b0;
                else if((rxdat_data2_valid_s0 == 1'b1) && (entry == rxdat_entry_idx_s0))
                    rxdat_data2_valid_s1_q[entry] <= 1'b1;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : rxdat_data_ok_logic
                if(rst == 1'b1)
                    dbf_rxdat_ok_s2_q[entry] <= 0;
                else if(retired_entry_sx[entry] == 1'b1)
                    dbf_rxdat_ok_s2_q[entry] <= 1'b0;
                else if(dbf_rxdat_ok_s1 && (entry == dbf_rxdat_txnid_s1_q))
                    dbf_rxdat_ok_s2_q[entry] <= 1'b1;
                else
                    ;
            end

            always @(posedge clk or posedge rst)begin : rxdat_compack_s1_q_logic
                if(rst == 1'b1)
                    rxdat_compack_s1_q[entry] <= 0;
                else if(retired_entry_sx[entry] == 1'b1)
                    rxdat_compack_s1_q[entry] <= 1'b0;
                else if((rxdat_valid_s0 == 1'b1) && (entry == rxdat_entry_idx_s0))
                    rxdat_compack_s1_q[entry] <= (rxdat_opcode_s0 == `CHIE_NCBWRDATACOMPACK);
                else
                    ;
            end
        end
    endgenerate

    assign dbf_rxdat_ok_s1 = dbf_rxdat_valid_s1_q ? (rxreq_size_s1_q[dbf_rxdat_txnid_s1_q] == 3'b110 ? 
                            (rxdat_data1_valid_s1_q[dbf_rxdat_txnid_s1_q] & rxdat_data2_valid_s1_q[dbf_rxdat_txnid_s1_q]) : 
                            (rxdat_data1_valid_s1_q[dbf_rxdat_txnid_s1_q] | rxdat_data2_valid_s1_q[dbf_rxdat_txnid_s1_q])) : 1'b0;

    //************************************************************************//

    //                      mshr txrspflit wrap logic

    //************************************************************************//
    assign txrsp_en_s1              = txrsp_compdbid_en_s1 | txrsp_readreceipt_en_s1;
    assign txrsp_compdbid_en_s1     = (rxreq_alloc_en_s1_q && (~sleep_sx_q[mshr_entry_idx_alloc_s1_q])) ? (rxreq_wrf_s1_q[mshr_entry_idx_alloc_s1_q] | rxreq_wrp_s1_q[mshr_entry_idx_alloc_s1_q]) & (~txrsp_fp_won_s1) : 1'b0;
    assign txrsp_readreceipt_en_s1  = (rxreq_alloc_en_s1_q && (~sleep_sx_q[mshr_entry_idx_alloc_s1_q])) ? (rxreq_rd_s1_q[mshr_entry_idx_alloc_s1_q] && (rxreq_order_s1_q[mshr_entry_idx_alloc_s1_q] != 2'b00) && (~txrsp_fp_won_s1)) : 1'b0;

    assign txrsp_en2_s1             = txrsp_compdbid_en2_s1 | txrsp_readreceipt_en2_s1;
    assign txrsp_compdbid_en2_s1    = wakeup_valid ? (rxreq_wrf_s1_q[wakeup_idx_sx] | rxreq_wrp_s1_q[wakeup_idx_sx]) : 1'b0;
    assign txrsp_readreceipt_en2_s1 = wakeup_valid ? (rxreq_rd_s1_q[wakeup_idx_sx] && (rxreq_order_s1_q[wakeup_idx_sx] != 2'b00)) : 1'b0;

    always @(posedge clk or posedge rst) begin: txrsp_fifo_set_logic
        if(rst == 1'b1) begin
            txrsp_fifo_set_s1_q <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(txrsp_en_s1 && txrsp_en2_s1) begin
            txrsp_fifo_set_s1_q <= txrsp_fifo_set_s1_q + 2;
        end
        else if (txrsp_en_s1 || txrsp_en2_s1) begin
            txrsp_fifo_set_s1_q <= txrsp_fifo_set_s1_q + 1;
        end
    end

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin: txrsp_fifo_set_logic
                if(rst == 1'b1)
                    txrsp_fifo_valid_s1_q[entry]        <= 1'b0;
                else if (txrsp_won_sx && txrsp_valid_sx_q && (txrsp_fifo_cnt_sx_q == entry))
                    txrsp_fifo_valid_s1_q[entry]        <= 1'b0;
                else if (txrsp_en_s1 && txrsp_en2_s1 && (txrsp_fifo_set_s1_q == entry)) begin
                    txrsp_fifo_valid_s1_q[entry]        <= 1'b1;
                    txrsp_fifo_entry_idx_sx_q[entry]    <= wakeup_idx_sx;
                    txrsp_fifo_opcode_s1_q[entry]       <= txrsp_compdbid_en2_s1 ? `CHIE_COMPDBIDRESP : (txrsp_readreceipt_en2_s1 ? `CHIE_READRECEIPT : {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}});
                end
                else if (txrsp_en_s1 && txrsp_en2_s1 &&  (((txrsp_fifo_set_s1_q == (`HNI_MSHR_ENTRIES_NUM-1)) & (entry == 0)) | ((txrsp_fifo_set_s1_q +1) == entry))) begin
                    txrsp_fifo_valid_s1_q[entry]        <= 1'b1;
                    txrsp_fifo_entry_idx_sx_q[entry]    <= mshr_entry_idx_alloc_s1_q;
                    txrsp_fifo_opcode_s1_q[entry]       <= txrsp_compdbid_en_s1 ? `CHIE_COMPDBIDRESP : (txrsp_readreceipt_en_s1 ? `CHIE_READRECEIPT : {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}});
                end
                else if (txrsp_en_s1 && (txrsp_fifo_set_s1_q == entry)) begin
                    txrsp_fifo_valid_s1_q[entry]        <= 1'b1;
                    txrsp_fifo_entry_idx_sx_q[entry]    <= mshr_entry_idx_alloc_s1_q;
                    txrsp_fifo_opcode_s1_q[entry]       <= txrsp_compdbid_en_s1 ? `CHIE_COMPDBIDRESP : (txrsp_readreceipt_en_s1 ? `CHIE_READRECEIPT : {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}});
                end
                else if (txrsp_en2_s1 && (txrsp_fifo_set_s1_q == entry)) begin
                    txrsp_fifo_valid_s1_q[entry]        <= 1'b1;
                    txrsp_fifo_entry_idx_sx_q[entry]    <= wakeup_idx_sx;
                    txrsp_fifo_opcode_s1_q[entry]       <= txrsp_compdbid_en2_s1 ? `CHIE_COMPDBIDRESP : (txrsp_readreceipt_en2_s1 ? `CHIE_READRECEIPT : {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}});
                end
            end

            always @(posedge clk or posedge rst) begin: txrsp_sent_logic
                if(rst == 1'b1)
                    txrsp_sent_q[entry] <= 1'b0;
                else if (mshr_entry_valid_sx_q[entry] & rxreq_rd_s1_q[entry] & (rxreq_order_s1_q[entry] == 2'b00))
                    txrsp_sent_q[entry] <= 1'b1;
                else if (txrsp_won_sx && txrsp_valid_sx_q && (txrsp_entry_idx_s1_q == entry))
                    txrsp_sent_q[entry] <= 1'b1;
                else if (txrsp_fp_won_s1 && (mshr_entry_idx_alloc_s1_q == entry))
                    txrsp_sent_q[entry] <= 1'b1;
                else if (retired_entry_sx[entry])
                    txrsp_sent_q[entry] <= 1'b0;
            end
        end
    endgenerate
    
    always @(posedge clk or posedge rst) begin: txrsp_fifo_idx_logic
        if(rst == 1'b1)
            txrsp_fifo_cnt_sx_q     <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        else if(txrsp_won_sx == 1'b1)
            txrsp_fifo_cnt_sx_q     <= txrsp_fifo_cnt_sx_q + 1;
    end

    always @(posedge clk or posedge rst)begin : mshr_txrsp_logic
        if(rst == 1'b1) begin
            txrsp_valid_sx_q        <= 1'b0;
            txrsp_entry_idx_s1_q    <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(txrsp_won_sx && txrsp_valid_sx_q)begin
            txrsp_valid_sx_q        <= 1'b0;
            txrsp_entry_idx_s1_q    <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(txrsp_fifo_valid_s1_q[txrsp_fifo_cnt_sx_q])begin
            txrsp_valid_sx_q        <= 1'b1;
            txrsp_entry_idx_s1_q    <= txrsp_fifo_entry_idx_sx_q[txrsp_fifo_cnt_sx_q];
        end
    end

    assign txrsp_qos_sx      = (rxreq_qos_s1_q[txrsp_entry_idx_s1_q]);
    assign txrsp_tgtid_sx    = (rxreq_srcid_s1_q[txrsp_entry_idx_s1_q]);
    assign txrsp_txnid_sx    = (rxreq_txnid_s1_q[txrsp_entry_idx_s1_q]);
    assign txrsp_opcode_sx   = txrsp_fifo_opcode_s1_q[txrsp_fifo_cnt_sx_q];
    assign txrsp_resperr_sx  = (txrsp_opcode_sx == `CHIE_COMPDBIDRESP & rxreq_excl_s1_q[txrsp_entry_idx_s1_q] & ((rxreq_excl_pass_s2_q[txrsp_entry_idx_s1_q]) | (excl_pass_s1 & (mshr_entry_idx_alloc_s1_q == txrsp_entry_idx_s1_q))))? 2'b01:2'b00;
    assign txrsp_resp_sx     = `CHIE_COMP_RESP_I;
    assign txrsp_dbid_sx     = txrsp_entry_idx_s1_q;
    assign txrsp_tracetag_sx = rxreq_tracetag_s1_q[txrsp_entry_idx_s1_q];

    //************************************************************************//

    //                      mshr txdatflit wrap logic

    //************************************************************************//
    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign txdat1_en_sx[entry] = (rdat_valid_q[entry] & (~txdat_fifo_rdy_sx_q[entry][0])) ? 
                                        (rxreq_device_s1_q[entry] ? (rxreq_ccid_s1_q[entry]==2'b11 ? (rdat_pdmask_q[entry][3]==1'b1) : 
                                        (rxreq_ccid_s1_q[entry]==2'b10 ? ((rdat_pdmask_q[entry][3:2]==2'b11) | ((rdat_pdmask_q[entry][2]==1'b1) && (rxreq_size_s1_q[entry]<=3'b100))) : 
                                        (rxreq_ccid_s1_q[entry]==2'b01 ? (rdat_pdmask_q[entry][1]==1'b1) :
                                        ((rdat_pdmask_q[entry][1:0]==2'b11) | ((rdat_pdmask_q[entry][0]==1'b1) && (rxreq_size_s1_q[entry]<=3'b100)))))) : 
                                        (rxreq_size_s1_q[entry]<=3'b100) ? rdat_pdmask_q[entry][rxreq_ccid_s1_q[entry]]==1'b1 : 
                                        (rxreq_ccid_s1_q[entry][1]==1'b1 ? rdat_pdmask_q[entry][3:2]==2'b11 :
                                        ((rxreq_ccid_s1_q[entry][1]==1'b0) & (rdat_pdmask_q[entry][1:0]==2'b11)))) : 1'b0;
            assign txdat2_en_sx[entry] = (rdat_valid_q[entry] & (rxreq_size_s1_q[entry]==3'b110) & (txdat_fifo_rdy_sx_q[entry][0]) & (~txdat_fifo_rdy_sx_q[entry][1])) ? 
                                        (rxreq_ccid_s1_q[entry][1] ? (rxreq_device_s1_q[entry] ? 1'b1 : rdat_pdmask_q[entry][1:0]==2'b11) : 
                                        rdat_pdmask_q[entry][3:2]==2'b11) : 1'b0;
        end
    endgenerate
    assign txdat_en_sx = ((|txdat1_en_sx) || (|txdat2_en_sx));

    always @(posedge clk or posedge rst) begin: txdat_fifo_set_logic
        if(rst == 1'b1)
            txdat_fifo_set_s1_q <= {(`HNI_MSHR_ENTRIES_WIDTH+1){1'b0}};
        else if(txdat_en_sx)
            txdat_fifo_set_s1_q <= txdat_fifo_set_s1_q + 1;
    end

    generate
        for(entry=0;entry<(2*`HNI_MSHR_ENTRIES_NUM);entry=entry+1) begin
            always @(posedge clk or posedge rst) begin: txdat_fifo_set_logic
                if(rst == 1'b1)
                    txdat_fifo_valid_s1_q[entry]        <= 1'b0;
                else if (mshr_txdat_won_sx && txdat_en_sx_q && (txdat_fifo_cnt_sx_q == entry))
                    txdat_fifo_valid_s1_q[entry]        <= 1'b0;
                else if (txdat_en_sx && (txdat_fifo_set_s1_q == entry)) begin
                    txdat_fifo_valid_s1_q[entry]        <= 1'b1;
                    txdat_fifo_entry_idx_sx_q[entry]    <= rdat_entry_idx_s1_q;
                    txdat_fifo_dataid_s1_q[entry]       <= (|txdat1_en_sx) ? ((rxreq_ccid_s1_q[rdat_entry_idx_s1_q][1]) ? 2'b10 : 2'b00) 
                                                            : ((rxreq_ccid_s1_q[rdat_entry_idx_s1_q][1]) ? 2'b00 : 2'b10);
                end
            end
        end
    endgenerate

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin: txdat_fifo_rdy_logic
                if (rst)begin
                    txdat_fifo_rdy_sx_q[entry]      <= 2'b00;
                end
                else if (txdat1_en_sx[entry])
                    txdat_fifo_rdy_sx_q[entry][0]   <= 1'b1;
                else if (txdat2_en_sx[entry])
                    txdat_fifo_rdy_sx_q[entry][1]   <= 1'b1;
                else if (retired_entry_sx[entry])
                    txdat_fifo_rdy_sx_q[entry]      <= 2'b00;
            end

            always @(posedge clk or posedge rst)begin: txdat_sent_logic
                if (rst)begin
                    txdat_sent_sx_q[entry]      <= 2'b00;
                end
                else if (mshr_txdat_won_sx && (txdat_entry_idx_sx_q == entry) && (mshr_txdat_dataid_sx == 2'b00))
                    txdat_sent_sx_q[entry][0]   <= 1'b1;
                else if (mshr_txdat_won_sx && (txdat_entry_idx_sx_q == entry) && (mshr_txdat_dataid_sx == 2'b10))
                    txdat_sent_sx_q[entry][1]   <= 1'b1;
                else if (retired_entry_sx[entry])
                    txdat_sent_sx_q[entry]      <= 2'b00;
            end
        end
    endgenerate
    
    always @(posedge clk or posedge rst) begin: txdat_fifo_idx_logic
        if(rst == 1'b1)
            txdat_fifo_cnt_sx_q     <= {(`HNI_MSHR_ENTRIES_WIDTH+1){1'b0}};
        else if(mshr_txdat_won_sx == 1'b1)
            txdat_fifo_cnt_sx_q     <= txdat_fifo_cnt_sx_q + 1;
    end

    always @(posedge clk or posedge rst)begin : mshr_txdat_logic
        if(rst == 1'b1) begin
            txdat_en_sx_q           <= 1'b0;
            txdat_entry_idx_sx_q    <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(mshr_txdat_won_sx && mshr_txdat_en_sx)begin
            txdat_en_sx_q           <= 1'b0;
            txdat_entry_idx_sx_q    <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(txdat_fifo_valid_s1_q[txdat_fifo_cnt_sx_q])begin
            txdat_en_sx_q           <= 1'b1;
            txdat_entry_idx_sx_q    <= txdat_fifo_entry_idx_sx_q[txdat_fifo_cnt_sx_q];
        end
    end

    assign mshr_txdat_en_sx         = txdat_en_sx_q; 
    assign mshr_txdat_dataid_sx     = txdat_fifo_dataid_s1_q[txdat_fifo_cnt_sx_q];
    assign mshr_txdat_txnid_sx      = rxreq_txnid_s1_q[txdat_entry_idx_sx_q];
    assign mshr_txdat_opcode_sx     = `CHIE_COMPDATA;
    assign mshr_txdat_resp_sx       = `CHIE_COMP_RESP_I;
    assign mshr_txdat_resperr_sx    = ((rxreq_rd_s1_q[txdat_entry_idx_sx_q] & rxreq_excl_s1_q[txdat_entry_idx_sx_q] & (rxreq_excl_pass_s2_q[txdat_entry_idx_sx_q]))? 2'b01:2'b00);
    assign mshr_txdat_dbid_sx       = txdat_entry_idx_sx_q;
    assign mshr_txdat_tgtid_sx      = rxreq_srcid_s1_q[txdat_entry_idx_sx_q];
    assign mshr_txdat_tracetag_sx   = rxreq_tracetag_s1_q[txdat_entry_idx_sx_q];

    //************************************************************************//

    //                       mshr AR channel logic

    //************************************************************************//
    assign arvalid_en_s1 = rxreq_alloc_en_s1_q ? ((~sleep_sx_q[mshr_entry_idx_alloc_s1_q]) && rxreq_rd_s1_q[mshr_entry_idx_alloc_s1_q]) : 1'b0;
    assign arvalid_en2_s1 = wakeup_valid ? rxreq_rd_s1_q[wakeup_idx_sx] : 1'b0;

    always @(posedge clk or posedge rst) begin: arvalid_fifo_set_logic
        if(rst == 1'b1) begin
            arvalid_fifo_set_sx_q <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(arvalid_en_s1 && arvalid_en2_s1) begin
            arvalid_fifo_set_sx_q <= arvalid_fifo_set_sx_q + 2;
        end
        else if (arvalid_en_s1 || arvalid_en2_s1) begin
            arvalid_fifo_set_sx_q <= arvalid_fifo_set_sx_q + 1;
        end
    end

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin: arvalid_fifo_set_logic
                if(rst == 1'b1)
                    arvalid_fifo_s1_q[entry]        <= 1'b0;
                else if ((arvalid_sx == 1'b1) && (arready_sx == 1'b1) && (arvalid_fifo_cnt_sx_q == entry))
                    arvalid_fifo_s1_q[entry]        <= 1'b0;
                else if (arvalid_en_s1 && arvalid_en2_s1 && (arvalid_fifo_set_sx_q == entry)) begin
                    arvalid_fifo_s1_q[entry]        <= 1'b1;
                    arvalid_fifo_idx_sx_q[entry]    <= wakeup_idx_sx;
                end
                else if (arvalid_en_s1 && arvalid_en2_s1 && (((arvalid_fifo_set_sx_q == (`HNI_MSHR_ENTRIES_NUM-1)) & (entry == 0)) | ((arvalid_fifo_set_sx_q +1) == entry))) begin
                    arvalid_fifo_s1_q[entry]        <= 1'b1;
                    arvalid_fifo_idx_sx_q[entry]    <= mshr_entry_idx_alloc_s1_q;
                end
                else if (arvalid_en_s1 && (arvalid_fifo_set_sx_q == entry)) begin
                    arvalid_fifo_s1_q[entry]        <= 1'b1;
                    arvalid_fifo_idx_sx_q[entry]    <= mshr_entry_idx_alloc_s1_q;
                end
                else if (arvalid_en2_s1 && (arvalid_fifo_set_sx_q == entry)) begin
                    arvalid_fifo_s1_q[entry]        <= 1'b1;
                    arvalid_fifo_idx_sx_q[entry]    <= wakeup_idx_sx;
                end
            end
        end
    endgenerate

    always @(posedge clk or posedge rst) begin: arvalid_fifo_cnt_logic
        if(rst == 1'b1)
            arvalid_fifo_cnt_sx_q     <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        else if((arvalid_sx == 1'b1) && (arready_sx == 1'b1))
            arvalid_fifo_cnt_sx_q     <= arvalid_fifo_cnt_sx_q + 1;
    end

    always @(posedge clk or posedge rst)begin : mshr_arvalid_logic
        if(rst == 1'b1) begin
            arvalid_sx        <= 1'b0;
            arvalid_entry_idx_s1_q    <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if((arvalid_sx == 1'b1) && (arready_sx == 1'b1))begin
            arvalid_sx        <= 1'b0;
            arvalid_entry_idx_s1_q    <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(arvalid_fifo_s1_q[arvalid_fifo_cnt_sx_q])begin
            arvalid_sx        <= 1'b1;
            arvalid_entry_idx_s1_q    <= arvalid_fifo_idx_sx_q[arvalid_fifo_cnt_sx_q];
        end
    end

    assign arid_sx          = rxreq_axid_s1_q[arvalid_entry_idx_s1_q];
    assign araddr_sx        = rxreq_device_s1_q[arvalid_entry_idx_s1_q] ? rxreq_addr_s1_q[arvalid_entry_idx_s1_q][`AXI4_ARADDR_WIDTH-1:0] : rxreq_alignaddr_s1_q[arvalid_entry_idx_s1_q][`AXI4_ARADDR_WIDTH-1:0];
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

    //                       mshr R channel logic

    //************************************************************************//
    assign mshr_rdat_en_sx          = ((arvalid_sx == 1'b1) && (arready_sx == 1'b1));
    assign mshr_rdat_entry_idx_sx   = mshr_rdat_en_sx ? arvalid_entry_idx_s1_q : 0;

    always @(posedge clk or posedge rst) begin: rdat_entry_idx_s1_q_logic
        if(rst == 1'b1)
            rdat_entry_idx_s1_q <= 1'b0;
        else if(dbf_rvalid_sx)
            rdat_entry_idx_s1_q <= dbf_rvalid_entry_idx_sx;
    end

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin: rdat_valid_q_logic
                if(rst == 1'b1)
                    rdat_valid_q[entry] <= 1'b0;
                else if(retired_entry_sx[entry])
                    rdat_valid_q[entry] <= 1'b0;
                else if (dbf_rvalid_sx && (dbf_rvalid_entry_idx_sx == entry))
                    rdat_valid_q[entry] <= 1'b1;
            end

            always @(posedge clk or posedge rst) begin: rdat_pdmask_q_logic
                if(rst == 1'b1)
                    rdat_pdmask_q[entry] <= 4'b0000;
                else if (dbf_rvalid_sx && (dbf_rvalid_entry_idx_sx == entry))
                    rdat_pdmask_q[entry] <= dbf_cdmask_sx | rdat_pdmask_q[entry];
                else if (retired_entry_sx[entry]) begin
                    rdat_pdmask_q[entry] <= 4'b0000;
                end
            end
        end
    endgenerate

    //************************************************************************//

    //                       mshr AW channel logic

    //************************************************************************//
    assign awvalid_en_s1 = dbf_rxdat_ok_s1 && (~rxreq_excl_fail_s2_q[dbf_rxdat_txnid_s1_q]);

    always @(posedge clk or posedge rst) begin: awvalid_fifo_set_cnt_logic
        if(rst == 1'b1) begin
            awvalid_fifo_set_s2_q   <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if(awvalid_en_s1 == 1'b1) begin
            awvalid_fifo_set_s2_q   <= awvalid_fifo_set_s2_q + 1;
        end
    end

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin: awvalid_fifo_set_logic
                if(rst == 1'b1)
                    awvalid_fifo_s2_q[entry]        <= 1'b0;
                else if ((awvalid_sx == 1'b1) && (awready_sx == 1'b1) && (awvalid_fifo_cnt_sx_q == entry))
                    awvalid_fifo_s2_q[entry]        <= 1'b0;
                else if (awvalid_en_s1 && (awvalid_fifo_set_s2_q == entry)) begin
                    awvalid_fifo_s2_q[entry]        <= 1'b1;
                    awvalid_fifo_idx_s2_q[entry]    <= dbf_rxdat_txnid_s1_q;
                end
            end
        end
    endgenerate

    always @(posedge clk or posedge rst) begin: awvalid_fifo_clr_logic
        if(rst == 1'b1)
            awvalid_fifo_cnt_sx_q   <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        else if((awvalid_sx == 1'b1) && (awready_sx == 1'b1))
            awvalid_fifo_cnt_sx_q   <= awvalid_fifo_cnt_sx_q + 1;
    end

    always @(posedge clk or posedge rst)begin : mshr_awvalid_logic
        if(rst == 1'b1) begin
            awvalid_sx              <= 1'b0;
            awvalid_entry_idx_s2_q  <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if((awvalid_sx == 1'b1) && (awready_sx == 1'b1))begin
            awvalid_sx              <= 1'b0;
        end
        else if(~wdat_wait_sx_q && awvalid_fifo_s2_q[awvalid_fifo_cnt_sx_q])begin
            awvalid_sx              <= 1'b1;
            awvalid_entry_idx_s2_q  <= awvalid_fifo_idx_s2_q[awvalid_fifo_cnt_sx_q];
        end
    end

    always @(posedge clk or posedge rst)begin : mshr_awvalid_s1_logic
        if(rst == 1'b1)
            awvalid_sx1_q   <= 1'b0;
        else
            awvalid_sx1_q   <= awvalid_sx;
    end

    //MemAttr propagation on AWCACHE
    // AWCACHE[0] (EWA) => MemAttr[0] (EWA)
    // AWCACHE[1] (Modifiable) => ~MemAttr[1] (Device)
    // AWCACHE[2] (Other Allocate) => MemAttr[2] (Cacheable)
    // AWCACHE[3] (Allocate) => MemAttr[3] (Allocate)
    //--------------------------------------------
    assign awid_sx          = rxreq_axid_s1_q[awvalid_entry_idx_s2_q];
    assign awaddr_sx        = rxreq_device_s1_q[awvalid_entry_idx_s2_q] ? rxreq_addr_s1_q[awvalid_entry_idx_s2_q][`AXI4_AWADDR_WIDTH-1:0] : rxreq_alignaddr_s1_q[awvalid_entry_idx_s2_q][`AXI4_AWADDR_WIDTH-1:0] ;
    assign awcache_sx[0]    = rxreq_memattr_s1_q[awvalid_entry_idx_s2_q][0];
    assign awcache_sx[1]    = ~rxreq_memattr_s1_q[awvalid_entry_idx_s2_q][1];
    assign awcache_sx[2]    = rxreq_memattr_s1_q[awvalid_entry_idx_s2_q][2];
    assign awcache_sx[3]    = rxreq_memattr_s1_q[awvalid_entry_idx_s2_q][3];
    assign awqos_sx         = rxreq_qos_s1_q[awvalid_entry_idx_s2_q];
    assign awprot_sx        = {1'b0,rxreq_ns_s1_q[awvalid_entry_idx_s2_q],1'b0};       
    assign awlen_sx         = rxreq_axlen_s1_q[awvalid_entry_idx_s2_q];
    assign awsize_sx        = rxreq_axsize_s1_q[awvalid_entry_idx_s2_q];
    assign awburst_sx       = 2'b01;
    assign awlock_sx        = 1'b0;        
    assign awregion_sx      = {`AXI4_AWREGION_WIDTH{1'b0}};

    //************************************************************************//

    //                      mshr W channel logic

    //************************************************************************//
    assign mshr_wdat_en_sx          = ~awvalid_sx1_q & awvalid_sx;    //send data to axi slave enable
    assign mshr_wdat_entry_idx_sx   = awvalid_entry_idx_s2_q;

    always @(posedge clk or posedge rst)begin : mshr_wdat_wait_logic
        if(rst == 1'b1)
            wdat_wait_sx_q  <= 1'b0;
        else if(mshr_wdat_en_sx == 1'b1)
            wdat_wait_sx_q  <= 1'b1;
        else if (dbf_wdat_last)
            wdat_wait_sx_q  <= 1'b0;
    end

    //************************************************************************//

    //                      mshr B channel decode logic

    //************************************************************************//  
    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin : mshr_B_logic
                if (rst)
                    bresp_ok_q[entry] <= 1'b0;
                else if (retired_entry_sx[entry])
                    bresp_ok_q[entry] <= 1'b0;
                else if (bvalid_sx && bready_sx && (~sleep_sx_q[entry]) && (bid_sx == rxreq_axid_s1_q[entry]))
                    bresp_ok_q[entry] <= 1'b1;
                else
                    ;
            end
        end
    endgenerate

    assign bready_sx    = ~rst;
    //************************************************************************//

    //                      mshr sleep/wakeup logic

    //************************************************************************//
    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign need_to_sleep_s0[entry] = rxreq_alloc_en_s0 && (~need_to_wakeup_q[entry]) && (rxreq_axid_s0 == rxreq_axid_s1_q[entry]);
        end
    endgenerate

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst)begin : mshr_wakeup_logic
                if (rst == 1'b1) begin
                    need_to_wakeup_q[entry]     <= 1'b0;
                    need_to_wakeup_idx_q[entry] <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
                end
                else if (retired_entry_sx1_q[entry] && (retired_entry_idx_sx1_q == entry)) begin
                    need_to_wakeup_q[entry]     <= 1'b0;
                end
                else if (need_to_sleep_s0[entry]) begin
                    need_to_wakeup_q[entry]     <= 1'b1;
                    need_to_wakeup_idx_q[entry] <= mshr_entry_idx_alloc_s0;
                end
            end

            always @(posedge clk or posedge rst)begin : mshr_sleep_logic
                if (rst == 1'b1) begin
                    sleep_sx_q[entry]               <= 1'b0;
                    mshr_entry_sleep_s1_q[entry]    <= 1'b0;
                end
                else if (wakeup_valid & (wakeup_idx_sx == entry)) begin
                    mshr_entry_sleep_s1_q[entry]    <= 1'b0;
                    sleep_sx_q[entry]               <= 1'b0;
                end
                else if (rxreq_alloc_en_s0 & (|need_to_sleep_s0) & (mshr_entry_idx_alloc_s0 == entry)) begin
                    sleep_sx_q[entry]               <= 1'b1;
                    mshr_entry_sleep_s1_q[entry]    <= 1'b1;
                end
                else
                    mshr_entry_sleep_s1_q[entry]    <= 1'b0;
            end
        end
    endgenerate

    assign mshr_entry_sleep_s1  = |mshr_entry_sleep_s1_q;
    assign wakeup_valid         = (|retired_entry_sx1_q) ? need_to_wakeup_q[retired_entry_idx_sx1_q] : 1'b0;
    assign wakeup_idx_sx        = (|retired_entry_sx1_q) ? need_to_wakeup_idx_q[retired_entry_idx_sx1_q] : {`HNI_MSHR_ENTRIES_NUM{1'b0}};

    //************************************************************************//

    //                            mshr retire logic

    //************************************************************************//
    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            assign compack_ok_sx[entry]     = rxrsp_compack_s1_q[entry]|rxdat_compack_s1_q[entry];
            assign retired_entry_sx[entry]  = (mshr_entry_valid_sx_q[entry] & (~sleep_sx_q[entry]) & txrsp_sent_q[entry] & ~(rxreq_expcompack_s1_q[entry] & ~compack_ok_sx[entry])) ? 
                                            ((rxreq_wrf_s1_q[entry] | rxreq_wrp_s1_q[entry]) ? (bresp_ok_q[entry] | (dbf_rxdat_ok_s2_q[entry] & rxreq_excl_fail_s2_q[entry])) : 
                                            (rxreq_rd_s1_q[entry] & ((txdat_sent_sx_q[entry] == 2'b11) | ((rxreq_size_s1_q[entry] <= 3'b101) & (|txdat_sent_sx_q[entry]))))) : 1'b0;
        end
    endgenerate

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin
                if(rst == 1'b1) begin
                    retired_entry_sx1_q[entry]  <= 1'b0;
                end
                else if (retired_entry_sx[entry]) begin 
                    retired_entry_sx1_q[entry]  <= 1'b1;
                end 
                else if (mshr_retired_valid_sx & (mshr_retired_idx_sx == entry)) begin
                    retired_entry_sx1_q[entry]  <= 1'b0;
                end
            end
        end
    endgenerate

    always @* begin:retired_entry_idx_logic
        retired_entry_idx_sx1_q = {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        for (k=0; k < `HNI_MSHR_ENTRIES_NUM; k=k+1) begin
            if(retired_entry_sx1_q[k])
                retired_entry_idx_sx1_q = k;
        end
    end

    assign mshr_retired_valid_sx    = |retired_entry_sx1_q;
    assign mshr_retired_idx_sx      = retired_entry_idx_sx1_q;

endmodule

