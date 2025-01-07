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
*    Xiaotian Cao <caoxiaotian@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_mshr_bypass `HNF_PARAM (clk,
                                       rst,
                                       li_mshr_rxreq_valid_s0,
                                       li_mshr_rxreq_qos_s0,
                                       li_mshr_rxreq_srcid_s0,
                                       li_mshr_rxreq_txnid_s0,
                                       li_mshr_rxreq_opcode_s0,
                                       li_mshr_rxreq_size_s0,
                                       li_mshr_rxreq_addr_s0,
                                       li_mshr_rxreq_ns_s0,
                                       li_mshr_rxreq_order_s0,
                                       li_mshr_rxreq_pcrdtype_s0,
                                       li_mshr_rxreq_memattr_s0,
                                       li_mshr_rxreq_excl_s0,
                                       li_mshr_rxreq_expcompack_s0,
                                       li_mshr_rxreq_tracetag_s0,
                                       mshr_entry_idx_alloc_s1_q,
                                       mshr_alloc_en_s0,
                                       rxreq_cam_hazard_s1_q,
                                       excl_pass_s1,
                                       excl_fail_s1,
                                       txreq_mshr_bypass_won_s1,
                                       txrsp_mshr_bypass_won_s1,
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
                                       txreq_mshr_bypass_lost_s1,
                                       txrsp_mshr_bypass_lost_s1);


    //global inputs
    input wire                                               clk;
    input wire                                               rst;

    //inputs from hnf_mshr_rxreq_parse
    input wire                                               li_mshr_rxreq_valid_s0;
    input wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]                li_mshr_rxreq_qos_s0;
    input wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]              li_mshr_rxreq_srcid_s0;
    input wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]              li_mshr_rxreq_txnid_s0;
    input wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]             li_mshr_rxreq_opcode_s0;
    input wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]               li_mshr_rxreq_size_s0;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]               li_mshr_rxreq_addr_s0;
    input wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]                 li_mshr_rxreq_ns_s0;
    input wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]              li_mshr_rxreq_order_s0;
    input wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]           li_mshr_rxreq_pcrdtype_s0;
    input wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]            li_mshr_rxreq_memattr_s0;
    input wire [`CHIE_REQ_FLIT_EXCL_WIDTH-1:0]               li_mshr_rxreq_excl_s0;
    input wire [`CHIE_REQ_FLIT_EXPCOMPACK_WIDTH-1:0]         li_mshr_rxreq_expcompack_s0;
    input wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]           li_mshr_rxreq_tracetag_s0;

    //inputs from hnf_mshr_qos
    input wire [`MSHR_ENTRIES_WIDTH-1:0]                     mshr_entry_idx_alloc_s1_q;
    input wire                                               mshr_alloc_en_s0;
    input wire                                               rxreq_cam_hazard_s1_q;

    //inputs from hnf_mshr_global_monitor
    input wire                                               excl_pass_s1;
    input wire                                               excl_fail_s1;

    //inputs from hnf_link_txreq_wrap
    input wire                                               txreq_mshr_bypass_won_s1;

    //inputs from hnf_link_txrsp_wrap
    input wire                                               txrsp_mshr_bypass_won_s1;

    //outputs to hnf_link_txrsp_wrap
    output wire                                              mshr_txrsp_bypass_valid_s1;
    output wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]               mshr_txrsp_bypass_qos_s1;
    output wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]             mshr_txrsp_bypass_tgtid_s1;
    output wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]             mshr_txrsp_bypass_txnid_s1;
    output wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]            mshr_txrsp_bypass_opcode_s1;
    output wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]           mshr_txrsp_bypass_resperr_s1;
    output wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]              mshr_txrsp_bypass_dbid_s1;
    output wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]          mshr_txrsp_bypass_tracetag_s1;

    //outputs to hnf_link_txreq_wrap
    output wire                                              mshr_txreq_bypass_valid_s1;
    output wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]               mshr_txreq_bypass_qos_s1;
    output wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]             mshr_txreq_bypass_txnid_s1;
    output wire [`CHIE_REQ_FLIT_RETURNNID_WIDTH-1:0]         mshr_txreq_bypass_returnnid_s1;
    output wire [`CHIE_REQ_FLIT_RETURNTXNID_WIDTH-1:0]       mshr_txreq_bypass_returntxnid_s1;
    output wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]            mshr_txreq_bypass_opcode_s1;
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]              mshr_txreq_bypass_size_s1;
    output wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]              mshr_txreq_bypass_addr_s1;
    output wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]                mshr_txreq_bypass_ns_s1;
    output wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0]        mshr_txreq_bypass_allowretry_s1;
    output wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]             mshr_txreq_bypass_order_s1;
    output wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]          mshr_txreq_bypass_pcrdtype_s1;
    output wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]           mshr_txreq_bypass_memattr_s1;
    output wire [`CHIE_REQ_FLIT_DODWT_WIDTH-1:0]             mshr_txreq_bypass_dodwt_s1;
    output wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]          mshr_txreq_bypass_tracetag_s1;

    //outputs to hnf_mshr_ctl
    output wire                                              txreq_mshr_bypass_lost_s1;
    output wire                                              txrsp_mshr_bypass_lost_s1;

    wire                                              req_rd_s0;
    wire                                              req_cb_s0;
    wire                                              req_wuf_s0;
    wire                                              req_wup_s0;
    wire                                              req_rdnosnp_s0;
    wire                                              req_wrnosnpful_s0;
    wire                                              req_wrnosnpptl_s0;
    wire                                              req_wrnosnp_s0;
    wire                                              req_ord_s0;
    wire                                              req_memattr_cacheable;
    wire                                              req_memattr_allocate;

    reg [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]                li_mshr_rxreq_qos_s1_q;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]              li_mshr_rxreq_srcid_s1_q;
    reg [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]              li_mshr_rxreq_txnid_s1_q;
    reg [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]             li_mshr_rxreq_opcode_s1_q;
    reg [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]               li_mshr_rxreq_size_s1_q;
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]               li_mshr_rxreq_addr_s1_q;
    reg [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]              li_mshr_rxreq_order_s1_q;
    reg [`CHIE_REQ_FLIT_EXPCOMPACK_WIDTH-1:0]         li_mshr_rxreq_expcompack_s1_q;
    reg [`CHIE_REQ_FLIT_NS_WIDTH-1:0]                 li_mshr_rxreq_ns_s1_q;
    reg [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0]           li_mshr_rxreq_pcrdtype_s1_q;
    reg [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]            li_mshr_rxreq_memattr_s1_q;
    reg [`CHIE_REQ_FLIT_EXCL_WIDTH-1:0]               li_mshr_rxreq_excl_s1_q;
    reg [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]           li_mshr_rxreq_tracetag_s1_q;

    wire                                              rd_receipt_s0;
    wire                                              wr_compdbid_s0;
    wire                                              wr_dbid_s0;
    wire                                              tx_rdnosnp_s0;
    wire                                              tx_wrnosnpful_wuf_s0;

    reg                                               rd_receipt_s1_q;
    reg                                               wr_compdbid_s1_q;
    reg                                               wr_dbid_s1_q;
    reg                                               tx_rdnosnp_s1_q;
    reg                                               tx_wrnosnpful_wuf_s1_q;
    wire                                              tx_wrnosnpful_s1;
    wire                                              tx_wrnosnpptl_s1;

    wire                                             do_dwt_wrnosnpfull_s0;
    wire                                             do_dwt_wrnosnpptl_s0 ;
    wire                                             do_dmt_s0;
    reg                                              do_dwt_wrnosnpfull_s1_q;
    reg                                              do_dwt_wrnosnpptl_s1_q ;
    reg                                              do_dmt_s1_q;
    reg                                              mshr_alloc_en_s1_q;

    assign req_rd_s0             = (li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_READONCE||li_mshr_rxreq_opcode_s0 == `CHIE_READNOSNP);
    assign req_cb_s0             = (li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_WRITEBACKFULL||li_mshr_rxreq_opcode_s0 == `CHIE_WRITEEVICTFULL||li_mshr_rxreq_opcode_s0 == `CHIE_WRITECLEANFULL);
    assign req_wuf_s0            = (li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_WRITEUNIQUEFULL);
    assign req_wup_s0            = (li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_WRITEUNIQUEPTL);
    assign req_rdnosnp_s0        = (li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_READNOSNP);
    assign req_wrnosnpful_s0     = (li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_WRITENOSNPFULL);
    assign req_wrnosnpptl_s0     = (li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_WRITENOSNPPTL);
    assign req_wrnosnp_s0        = (li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_WRITENOSNPFULL||li_mshr_rxreq_opcode_s0 == `CHIE_WRITENOSNPPTL);
    assign req_ord_s0            = (li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_order_s0 == 2'b10);
    assign req_memattr_cacheable = li_mshr_rxreq_memattr_s0[2];
    assign req_memattr_allocate  = li_mshr_rxreq_memattr_s0[3];


    always@(posedge clk or posedge rst)begin :pass_qos
        if(rst)
            li_mshr_rxreq_qos_s1_q <= 'd0;
        else
            li_mshr_rxreq_qos_s1_q <= li_mshr_rxreq_qos_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_srcid
        if(rst)
            li_mshr_rxreq_srcid_s1_q <= 'd0;
        else
            li_mshr_rxreq_srcid_s1_q <= li_mshr_rxreq_srcid_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_txnid
        if(rst)
            li_mshr_rxreq_txnid_s1_q <= 'd0;
        else
            li_mshr_rxreq_txnid_s1_q <= li_mshr_rxreq_txnid_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_expcompack
        if(rst)
            li_mshr_rxreq_expcompack_s1_q <= 'd0;
        else
            li_mshr_rxreq_expcompack_s1_q <= li_mshr_rxreq_expcompack_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_opcode
        if(rst)
            li_mshr_rxreq_opcode_s1_q <= 'd0;
        else
            li_mshr_rxreq_opcode_s1_q <= li_mshr_rxreq_opcode_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_excl
        if(rst)
            li_mshr_rxreq_excl_s1_q <= 'd0;
        else
            li_mshr_rxreq_excl_s1_q <= li_mshr_rxreq_excl_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_order
        if(rst)
            li_mshr_rxreq_order_s1_q <= 'd0;
        else
            li_mshr_rxreq_order_s1_q <= li_mshr_rxreq_order_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_size
        if(rst)
            li_mshr_rxreq_size_s1_q <= 'd0;
        else
            li_mshr_rxreq_size_s1_q <= li_mshr_rxreq_size_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_addr
        if(rst)
            li_mshr_rxreq_addr_s1_q <= 'd0;
        else
            li_mshr_rxreq_addr_s1_q <= li_mshr_rxreq_addr_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_ns
        if(rst)
            li_mshr_rxreq_ns_s1_q <= 'd0;
        else
            li_mshr_rxreq_ns_s1_q <= li_mshr_rxreq_ns_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_pcrdtype
        if(rst)
            li_mshr_rxreq_pcrdtype_s1_q <= 'd0;
        else
            li_mshr_rxreq_pcrdtype_s1_q <= li_mshr_rxreq_pcrdtype_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_memattr
        if(rst)
            li_mshr_rxreq_memattr_s1_q <= 'd0;
        else
            li_mshr_rxreq_memattr_s1_q <= li_mshr_rxreq_memattr_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_tracetag
        if (rst)
            li_mshr_rxreq_tracetag_s1_q <= 'd0;
        else
            li_mshr_rxreq_tracetag_s1_q <= li_mshr_rxreq_tracetag_s0;
    end


    //valid judgment
    assign rd_receipt_s0        = req_rd_s0&&req_ord_s0&&mshr_alloc_en_s0;
    assign wr_compdbid_s0       = (req_cb_s0||(req_wrnosnp_s0&&(li_mshr_rxreq_excl_s0 == 1||(li_mshr_rxreq_order_s0 == 2'b10&&li_mshr_rxreq_expcompack_s0 == 1))))&&mshr_alloc_en_s0;
    assign wr_dbid_s0           = (req_wup_s0||(req_wuf_s0&&(req_memattr_allocate||(li_mshr_rxreq_order_s0 == 2'b10&&li_mshr_rxreq_expcompack_s0))))&&mshr_alloc_en_s0;
    assign tx_rdnosnp_s0        = req_rdnosnp_s0&&mshr_alloc_en_s0;
    assign tx_wrnosnpful_wuf_s0 = req_wuf_s0&&!req_memattr_allocate&&mshr_alloc_en_s0;

    assign tx_wrnosnpful_s1 = tx_wrnosnpful_wuf_s1_q||((li_mshr_rxreq_opcode_s1_q == `CHIE_WRITENOSNPFULL)&&(excl_pass_s1 == 1||li_mshr_rxreq_excl_s1_q == 0)&&mshr_alloc_en_s1_q);
    assign tx_wrnosnpptl_s1 = ((li_mshr_rxreq_opcode_s1_q == `CHIE_WRITENOSNPPTL)&&(excl_pass_s1 == 1||li_mshr_rxreq_excl_s1_q == 0)&&mshr_alloc_en_s1_q);

    always@(posedge clk or posedge rst)begin :pass_alloc_en
        if (rst)
            mshr_alloc_en_s1_q <= 'd0;
        else
            mshr_alloc_en_s1_q <= mshr_alloc_en_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_rd_receipt
        if (rst)
            rd_receipt_s1_q <= 'd0;
        else
            rd_receipt_s1_q <= rd_receipt_s0;
    end

    always@(posedge clk or posedge rst) begin:pass_wr_compdbid
        if (rst)
            wr_compdbid_s1_q <= 'd0;
        else
            wr_compdbid_s1_q <= wr_compdbid_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_wr_dbid
        if (rst)
            wr_dbid_s1_q <= 'd0;
        else
            wr_dbid_s1_q <= wr_dbid_s0;
    end

    always@(posedge clk or posedge rst) begin:pass_tx_rdnosnp
        if (rst)
            tx_rdnosnp_s1_q <= 'd0;
        else
            tx_rdnosnp_s1_q <= tx_rdnosnp_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_tx_wrnosnpful_wuf
        if (rst)
            tx_wrnosnpful_wuf_s1_q <= 'd0;
        else
            tx_wrnosnpful_wuf_s1_q <= tx_wrnosnpful_wuf_s0;
    end

    //dwt judgment
    assign do_dwt_wrnosnpfull_s0 =(!(li_mshr_rxreq_order_s0 == 2'b10 && li_mshr_rxreq_expcompack_s0==1) && (!li_mshr_rxreq_excl_s0) && (li_mshr_rxreq_opcode_s0 == `CHIE_WRITENOSNPFULL)) ||
           (!(li_mshr_rxreq_order_s0 == 2'b10 && li_mshr_rxreq_expcompack_s0==1) && (li_mshr_rxreq_opcode_s0 == `CHIE_WRITEUNIQUEFULL) && (!req_memattr_allocate));

    assign do_dwt_wrnosnpptl_s0 = (!(li_mshr_rxreq_order_s0 == 2'b10 && li_mshr_rxreq_expcompack_s0==1) && (!li_mshr_rxreq_excl_s0) && (li_mshr_rxreq_opcode_s0 == `CHIE_WRITENOSNPPTL));

    always@(posedge clk or posedge rst)begin :pass_dwt_wrnosnpfull
        if (rst)
            do_dwt_wrnosnpfull_s1_q <= 'd0;
        else
            do_dwt_wrnosnpfull_s1_q <= do_dwt_wrnosnpfull_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_dwt_wrnosnpptl
        if (rst)
            do_dwt_wrnosnpptl_s1_q <= 'd0;
        else
            do_dwt_wrnosnpptl_s1_q <= do_dwt_wrnosnpptl_s0;
    end

    //dmt judgment
    assign do_dmt_s0 = (!(((li_mshr_rxreq_order_s0 == 2'b10)&&(li_mshr_rxreq_expcompack_s0 == 0))||(li_mshr_rxreq_excl_s0 == 1)))&&((li_mshr_rxreq_opcode_s0 == `CHIE_READNOSNP));
    always@(posedge clk or posedge rst) begin: pass_do_dmt
        if (rst)
            do_dmt_s1_q <= 'd0;
        else
            do_dmt_s1_q <= do_dmt_s0;
    end

    //txrsp_bypass
    assign mshr_txrsp_bypass_valid_s1    = (rd_receipt_s1_q||wr_compdbid_s1_q||wr_dbid_s1_q)&&!rxreq_cam_hazard_s1_q;
    assign mshr_txrsp_bypass_qos_s1      = li_mshr_rxreq_qos_s1_q;
    assign mshr_txrsp_bypass_tgtid_s1    = li_mshr_rxreq_srcid_s1_q;
    assign mshr_txrsp_bypass_txnid_s1    = li_mshr_rxreq_txnid_s1_q;
    assign mshr_txrsp_bypass_opcode_s1   = rd_receipt_s1_q?`CHIE_READRECEIPT:(wr_compdbid_s1_q?`CHIE_COMPDBIDRESP:(wr_dbid_s1_q?`CHIE_DBIDRESP:0));
    assign mshr_txrsp_bypass_resperr_s1  = (wr_compdbid_s1_q&&li_mshr_rxreq_excl_s1_q&&excl_pass_s1)?1:0;
    assign mshr_txrsp_bypass_dbid_s1     = mshr_entry_idx_alloc_s1_q;
    assign mshr_txrsp_bypass_tracetag_s1 = li_mshr_rxreq_tracetag_s1_q;

    //txreq_bypass
    assign mshr_txreq_bypass_valid_s1       = (tx_rdnosnp_s1_q||tx_wrnosnpful_s1||tx_wrnosnpptl_s1)&&!rxreq_cam_hazard_s1_q&&!excl_fail_s1;
    assign mshr_txreq_bypass_qos_s1         = li_mshr_rxreq_qos_s1_q;
    assign mshr_txreq_bypass_txnid_s1       = mshr_entry_idx_alloc_s1_q;
    assign mshr_txreq_bypass_returnnid_s1   = (mshr_txreq_bypass_dodwt_s1||do_dmt_s1_q)?li_mshr_rxreq_srcid_s1_q:HNF_NID_PARAM;
    assign mshr_txreq_bypass_returntxnid_s1 = (mshr_txreq_bypass_dodwt_s1||do_dmt_s1_q)?li_mshr_rxreq_txnid_s1_q:mshr_entry_idx_alloc_s1_q;
    assign mshr_txreq_bypass_opcode_s1      = tx_rdnosnp_s1_q?`CHIE_READNOSNP:(tx_wrnosnpful_s1?`CHIE_WRITENOSNPFULL:(tx_wrnosnpptl_s1?`CHIE_WRITENOSNPPTL:0));
    assign mshr_txreq_bypass_size_s1        = li_mshr_rxreq_size_s1_q;
    assign mshr_txreq_bypass_addr_s1        = li_mshr_rxreq_addr_s1_q;
    assign mshr_txreq_bypass_ns_s1          = li_mshr_rxreq_ns_s1_q;
    assign mshr_txreq_bypass_allowretry_s1  = 1'b1;
    assign mshr_txreq_bypass_order_s1       = tx_rdnosnp_s1_q&&(li_mshr_rxreq_order_s1_q != 2'b10)&&(li_mshr_rxreq_expcompack_s1_q == 0)&&(li_mshr_rxreq_excl_s1_q == 0);
    assign mshr_txreq_bypass_pcrdtype_s1    = li_mshr_rxreq_pcrdtype_s1_q;
    assign mshr_txreq_bypass_memattr_s1     = li_mshr_rxreq_memattr_s1_q;
    assign mshr_txreq_bypass_dodwt_s1       = tx_rdnosnp_s1_q?0:(tx_wrnosnpful_s1?do_dwt_wrnosnpfull_s1_q:(tx_wrnosnpptl_s1?do_dwt_wrnosnpptl_s1_q:0));
    assign mshr_txreq_bypass_tracetag_s1    = li_mshr_rxreq_tracetag_s1_q;

    //bypass_lost
    assign txreq_mshr_bypass_lost_s1 = (mshr_txreq_bypass_valid_s1&&!txreq_mshr_bypass_won_s1)||(rxreq_cam_hazard_s1_q&&(tx_rdnosnp_s1_q||tx_wrnosnpful_s1||tx_wrnosnpptl_s1));
    assign txrsp_mshr_bypass_lost_s1 = (mshr_txrsp_bypass_valid_s1&&!txrsp_mshr_bypass_won_s1)||(rxreq_cam_hazard_s1_q&&(rd_receipt_s1_q||wr_compdbid_s1_q||wr_dbid_s1_q));

endmodule
