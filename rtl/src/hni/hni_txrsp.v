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

module hni_txrsp `HNI_PARAM
    (
        clk,
        rst,

        txrsp_lcrdv,

        rxreq_alloc_en_s0,
        rxreq_alloc_flit_s0,
        mshr_entry_idx_alloc_s0,

        qos_txrsp_retryack_valid_s1,
        qos_txrsp_retryack_fifo_s1,

        qos_txrsp_pcrdgnt_valid_s2,
        qos_txrsp_pcrdgnt_fifo_s2,

        mshr_entry_sleep_s1,   //endpoint hazard
        txrsp_valid_sx_q,
        txrsp_qos_sx,
        txrsp_tgtid_sx,
        txrsp_txnid_sx,
        txrsp_opcode_sx,
        txrsp_resperr_sx,
        txrsp_resp_sx,
        txrsp_dbid_sx,
        txrsp_tracetag_sx,

        excl_pass_s1,

        txrspflitv,
        txrspflit,
        txrspflitpend,

        txrsp_retryack_won_s1,
        txrsp_pcrdgnt_won_s2,

        txrsp_won_sx,
        txrsp_fp_won_s1
    );

    //global inputs
    input wire                                     clk;
    input wire                                     rst;

    //inputs from hni_link
    input wire                                     txrsp_lcrdv;

    //inputs from hni_qos
    input wire                                     rxreq_alloc_en_s0;
    input wire [`CHIE_REQ_FLIT_RANGE]              rxreq_alloc_flit_s0;
    input wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]       mshr_entry_idx_alloc_s0;

    input wire                                     qos_txrsp_retryack_valid_s1;
    input wire [`HNI_RETRY_ACKQ_DATA_RANGE]        qos_txrsp_retryack_fifo_s1;

    input wire                                     qos_txrsp_pcrdgnt_valid_s2;
    input wire [`HNI_PCRDGRANTQ_DATA_RANGE]        qos_txrsp_pcrdgnt_fifo_s2;

    //inputs from hni_mshr
    input wire                                     mshr_entry_sleep_s1;   //endpoint hazard
    input wire                                     txrsp_valid_sx_q;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]      txrsp_qos_sx;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]    txrsp_tgtid_sx;
    input wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]    txrsp_txnid_sx;
    input wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]   txrsp_opcode_sx;
    input wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]  txrsp_resperr_sx;
    input wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]     txrsp_resp_sx;
    input wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]     txrsp_dbid_sx;
    input wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0] txrsp_tracetag_sx;

    //inputs from hni_global_monitor
    input wire                                     excl_pass_s1;

    //outputs to hni_link
    output reg                                     txrspflitv;
    output reg  [`CHIE_RSP_FLIT_RANGE]             txrspflit;
    output wire                                    txrspflitpend;

    //outputs to hni_qos
    output wire                                    txrsp_retryack_won_s1;
    output wire                                    txrsp_pcrdgnt_won_s2;

    //outputs to hni_mshr
    output wire                                    txrsp_won_sx;
    output wire                                    txrsp_fp_won_s1;

    //internal reg signals
    reg [`HNI_LL_RSP_CRD_CNT_WIDTH-1:0]            txrsp_crd_cnt_q;

    reg [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]             rxreq_qos_s1_q;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]           rxreq_srcid_s1_q;
    reg [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]           rxreq_txnid_s1_q;
    reg [`CHIE_REQ_FLIT_EXCL_WIDTH-1:0]            rxreq_excl_s1_q;    
    reg [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]        rxreq_tracetag_s1_q;
    reg                                            rd_receipt_s1_q;
    reg                                            wr_compdbid_s1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]              mshr_entry_idx_alloc_s1_q;

    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_fp_s1;
    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_retyack_s1;
    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_pcrdgnt_s2;
    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_mshr_sx1;
    reg [`HNI_LL_RSP_CRD_CNT_WIDTH-1:0]            rsp_crd_cnt_ns_s0;

    //internal wire signals
    wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]            rxreq_qos_s0;
    wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]          rxreq_srcid_s0;
    wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]          rxreq_txnid_s0;
    wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]         rxreq_opcode_s0;
    wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]          rxreq_order_s0;
    wire [`CHIE_REQ_FLIT_EXCL_WIDTH-1:0]           rxreq_excl_s0;
    wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]       rxreq_tracetag_s0;
    wire                                           req_wrnosnp_s0;
    wire                                           rd_receipt_s0;
    wire                                           wr_compdbid_s0;

    wire                                           txrsp_fp_valid_s1;
    wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]            txrsp_fp_qos_s1;
    wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]          txrsp_fp_tgtid_s1;
    wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]          txrsp_fp_txnid_s1;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]         txrsp_fp_opcode_s1;
    wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]        txrsp_fp_resperr_s1;
    wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]           txrsp_fp_dbid_s1;
    wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]       txrsp_fp_tracetag_s1;

    wire                                           txrsp_crd_avail_s1;
    wire                                           txrsp_busy_sx;
    wire                                           txrspcrdv_s0;
    wire                                           txrsp_req_s0;
    wire                                           txrspflitv_s0;
    wire [`CHIE_RSP_FLIT_RANGE]                    txrspflit_s0;
    wire [`HNI_LL_RSP_CRD_CNT_WIDTH-1:0]           rsp_crd_cnt_s1;
    wire [`HNI_LL_RSP_CRD_CNT_WIDTH-1:0]           rsp_crd_cnt_inc_s0;
    wire [`HNI_LL_RSP_CRD_CNT_WIDTH-1:0]           rsp_crd_cnt_dec_s0;
    wire                                           update_rsp_crd_cnt_s0;
    wire                                           txrsp_crd_cnt_inc_sx;
    wire                                           txrsp_crd_cnt_dec_sx;
    wire                                           rsp_crd_cnt_not_zero_sx;

    //main function

    //arb and lcrd_avail

    assign rsp_crd_cnt_not_zero_sx     = (txrsp_crd_cnt_q != 0);

    // just received it or not zero

    assign txrsp_crd_avail_s1          = (txrsp_lcrdv | rsp_crd_cnt_not_zero_sx);
    assign txrsp_busy_sx               = ~txrsp_crd_avail_s1;

    //req decode
    assign rxreq_qos_s0        = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_QOS_RANGE]        : {`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};     
    assign rxreq_srcid_s0      = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_SRCID_RANGE]      : {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};   
    assign rxreq_txnid_s0      = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_TXNID_RANGE]      : {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};   
    assign rxreq_opcode_s0     = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_OPCODE_RANGE]     : {`CHIE_REQ_FLIT_OPCODE_WIDTH{1'b0}};    
    assign rxreq_order_s0      = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_ORDER_RANGE]      : {`CHIE_REQ_FLIT_ORDER_WIDTH{1'b0}};   
    assign rxreq_excl_s0       = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_EXCL_RANGE]       : {`CHIE_REQ_FLIT_EXCL_WIDTH{1'b0}};    
    assign rxreq_tracetag_s0   = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_TRACETAG_RANGE]   : {`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}}; 

    assign req_wrnosnp_s0        = (rxreq_opcode_s0 == `CHIE_WRITENOSNPFULL) || (rxreq_opcode_s0 == `CHIE_WRITENOSNPPTL);

    //fp readreceipt
    assign rd_receipt_s0        = (rxreq_opcode_s0 == `CHIE_READNOSNP)&&(rxreq_order_s0 != 2'b0)&&rxreq_alloc_en_s0;

    //fp compdbidresp
    assign wr_compdbid_s0       = req_wrnosnp_s0 && rxreq_alloc_en_s0; //&&(rxreq_excl_s0 == 1||(rxreq_order_s0 != 2'b0))

    //fp s1 stage
    always@(posedge clk or posedge rst)begin :pass_qos
        if(rst)
            rxreq_qos_s1_q <= {`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};
        else
            rxreq_qos_s1_q <= rxreq_qos_s0;
    end
    always@(posedge clk or posedge rst)begin :pass_srcid
        if(rst)
            rxreq_srcid_s1_q <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        else
            rxreq_srcid_s1_q <= rxreq_srcid_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_txnid
        if(rst)
            rxreq_txnid_s1_q <= {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
        else
            rxreq_txnid_s1_q <= rxreq_txnid_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_excl
        if(rst)
            rxreq_excl_s1_q <= {`CHIE_REQ_FLIT_EXCL_WIDTH{1'b0}};
        else
            rxreq_excl_s1_q <= rxreq_excl_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_tracetag
        if (rst)
            rxreq_tracetag_s1_q <= {`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
        else
            rxreq_tracetag_s1_q <= rxreq_tracetag_s0;
    end

    always@(posedge clk or posedge rst)begin :pass_rd_receipt
        if (rst)
            rd_receipt_s1_q <= 1'b0;
        else
            rd_receipt_s1_q <= rd_receipt_s0;
    end

    always@(posedge clk or posedge rst) begin:pass_wr_compdbid
        if (rst)
            wr_compdbid_s1_q <= 1'b0;
        else
            wr_compdbid_s1_q <= wr_compdbid_s0;
    end

    always@(posedge clk or posedge rst) begin:pass_alloc_entry_idx
        if (rst)
            mshr_entry_idx_alloc_s1_q <= {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        else
            mshr_entry_idx_alloc_s1_q <= mshr_entry_idx_alloc_s0;
    end

    //fp output
    assign txrsp_fp_valid_s1    = (rd_receipt_s1_q||wr_compdbid_s1_q) && (~mshr_entry_sleep_s1);
    assign txrsp_fp_qos_s1      = rxreq_qos_s1_q;
    assign txrsp_fp_tgtid_s1    = rxreq_srcid_s1_q;
    assign txrsp_fp_txnid_s1    = rxreq_txnid_s1_q;
    assign txrsp_fp_opcode_s1   = rd_receipt_s1_q?`CHIE_READRECEIPT:(wr_compdbid_s1_q?`CHIE_COMPDBIDRESP:5'b0);
    assign txrsp_fp_resperr_s1  = (wr_compdbid_s1_q&&rxreq_excl_s1_q&&excl_pass_s1)?2'b01:2'b00;
    assign txrsp_fp_dbid_s1     = mshr_entry_idx_alloc_s1_q;
    assign txrsp_fp_tracetag_s1 = rxreq_tracetag_s1_q;

    //output to mshr
    assign txrsp_fp_won_s1       = txrsp_fp_valid_s1 &
           ~txrsp_busy_sx;

    //output to qos
    assign txrsp_retryack_won_s1 = (qos_txrsp_retryack_valid_s1) &
           (~txrsp_fp_valid_s1) &
           ~txrsp_busy_sx;

    assign txrsp_pcrdgnt_won_s2  = (qos_txrsp_pcrdgnt_valid_s2) &
           (~qos_txrsp_retryack_valid_s1) &
           (~txrsp_fp_valid_s1) &
           ~txrsp_busy_sx;

    //output to mshr
    assign txrsp_won_sx         = (txrsp_valid_sx_q) &
           (~qos_txrsp_pcrdgnt_valid_s2) &
           (~qos_txrsp_retryack_valid_s1) &
           (~txrsp_fp_valid_s1) &
           ~txrsp_busy_sx;

    assign txrspcrdv_s0               = txrsp_lcrdv;
    assign txrsp_crd_cnt_inc_sx       = txrspcrdv_s0;
    assign txrsp_req_s0               = (txrsp_fp_valid_s1           |
                                         qos_txrsp_retryack_valid_s1 |
                                         qos_txrsp_pcrdgnt_valid_s2  |
                                         txrsp_valid_sx_q);

    //arbitration

    always @*begin
        //FastPath wrap
        txrspflit_fp_s1[`CHIE_RSP_FLIT_QOS_RANGE]           = txrsp_fp_qos_s1;
        txrspflit_fp_s1[`CHIE_RSP_FLIT_TGTID_RANGE]         = txrsp_fp_tgtid_s1;
        txrspflit_fp_s1[`CHIE_RSP_FLIT_SRCID_RANGE]         = `HNI0_ID;
        txrspflit_fp_s1[`CHIE_RSP_FLIT_TXNID_RANGE]         = txrsp_fp_txnid_s1;
        txrspflit_fp_s1[`CHIE_RSP_FLIT_OPCODE_RANGE]        = txrsp_fp_opcode_s1;
        txrspflit_fp_s1[`CHIE_RSP_FLIT_RESPERR_RANGE]       = txrsp_fp_resperr_s1;
        txrspflit_fp_s1[`CHIE_RSP_FLIT_RESP_RANGE]          = {`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
        txrspflit_fp_s1[`CHIE_RSP_FLIT_FWDSTATE_RANGE]      = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_fp_s1[`CHIE_RSP_FLIT_CBUSY_RANGE]         = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_fp_s1[`CHIE_RSP_FLIT_DBID_RANGE]          = txrsp_fp_dbid_s1;
        txrspflit_fp_s1[`CHIE_RSP_FLIT_PCRDTYPE_RANGE]      = {`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};
        txrspflit_fp_s1[`CHIE_RSP_FLIT_TAGOP_RANGE]         = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_fp_s1[`CHIE_RSP_FLIT_TRACETAG_RANGE]      = txrsp_fp_tracetag_s1;
    end
    always @*begin
        //RetryAck wrap
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_QOS_RANGE]      = qos_txrsp_retryack_fifo_s1[`HNI_RETRY_ACKQ_QOS_RANGE];
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TGTID_RANGE]    = qos_txrsp_retryack_fifo_s1[`HNI_RETRY_ACKQ_SRCID_RANGE];
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_SRCID_RANGE]    = `HNI0_ID;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TXNID_RANGE]    = qos_txrsp_retryack_fifo_s1[`HNI_RETRY_ACKQ_TXNID_RANGE];
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_OPCODE_RANGE]   = `CHIE_RETRYACK;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_RESPERR_RANGE]  = {`CHIE_RSP_FLIT_RESPERR_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_RESP_RANGE]     = {`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_FWDSTATE_RANGE] = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_CBUSY_RANGE]    = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_DBID_RANGE]     = {`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_PCRDTYPE_RANGE] = qos_txrsp_retryack_fifo_s1[`HNI_RETRY_ACKQ_PCRDTYPE_RANGE];
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TAGOP_RANGE]    = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TRACETAG_RANGE] = qos_txrsp_retryack_fifo_s1[`HNI_RETRY_ACKQ_TRACE_RANGE];
    end

    always @*begin
        //PCrdGrant wrap
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_QOS_RANGE]      = qos_txrsp_pcrdgnt_fifo_s2[`HNI_PCRDGRANTQ_QOS_RANGE];
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TGTID_RANGE]    = qos_txrsp_pcrdgnt_fifo_s2[`HNI_PCRDGRANTQ_SRCID_RANGE];
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_SRCID_RANGE]    = `HNI0_ID;
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TXNID_RANGE]    = {`CHIE_RSP_FLIT_TXNID_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_OPCODE_RANGE]   = `CHIE_PCRDGRANT;
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_RESPERR_RANGE]  = {`CHIE_RSP_FLIT_RESPERR_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_RESP_RANGE]     = {`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_FWDSTATE_RANGE] = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_CBUSY_RANGE]    = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_DBID_RANGE]     = {`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_PCRDTYPE_RANGE] = qos_txrsp_pcrdgnt_fifo_s2[`HNI_PCRDGRANTQ_PCRDTYPE_RANGE];
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TAGOP_RANGE]    = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TRACETAG_RANGE] = {`CHIE_RSP_FLIT_TRACETAG_WIDTH{1'b0}};
    end

    always @*begin
        //MSHR txrspflit wrap
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_QOS_RANGE]        = txrsp_qos_sx;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_TGTID_RANGE]      = txrsp_tgtid_sx;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_SRCID_RANGE]      = `HNI0_ID;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_TXNID_RANGE]      = txrsp_txnid_sx;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_OPCODE_RANGE]     = txrsp_opcode_sx;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_RESPERR_RANGE]    = txrsp_resperr_sx;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_RESP_RANGE]       = txrsp_resp_sx;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_FWDSTATE_RANGE]   = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_CBUSY_RANGE]      = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_DBID_RANGE]       = txrsp_dbid_sx;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_PCRDTYPE_RANGE]   = {`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_TAGOP_RANGE]      = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_TRACETAG_RANGE]   = txrsp_tracetag_sx;
    end

    assign txrspflit_s0 = ({`CHIE_RSP_FLIT_WIDTH{txrsp_fp_won_s1      }} & txrspflit_fp_s1     ) |
           ({`CHIE_RSP_FLIT_WIDTH{txrsp_retryack_won_s1}} & txrspflit_retyack_s1) |
           ({`CHIE_RSP_FLIT_WIDTH{txrsp_pcrdgnt_won_s2 }} & txrspflit_pcrdgnt_s2) |
           ({`CHIE_RSP_FLIT_WIDTH{txrsp_won_sx        }} & txrspflit_mshr_sx1  ) ;

    assign rsp_crd_cnt_s1          = txrsp_crd_cnt_q;
    assign txrspflitv_s0           = txrsp_req_s0 & (~txrsp_busy_sx);
    assign txrsp_crd_cnt_dec_sx    = txrspflitv_s0 & txrsp_crd_avail_s1; //lcrd - 1

    assign txrspflitpend = 1'b1;

    //txrspflit sending logic
    always @(posedge clk or posedge rst) begin: txrspflit_logic_t
        if(rst == 1'b1)begin
            txrspflit <= {`CHIE_RSP_FLIT_WIDTH{1'b0}};
            txrspflitv <= 1'b0;
        end
        else if((txrspflitv_s0 == 1'b1) & (txrsp_crd_avail_s1 == 1'b1))begin
            txrspflit <= txrspflit_s0;
            txrspflitv <= 1'b1;
        end
        else begin
            txrspflitv <= 1'b0;
        end
    end

    //L-credit logic
    assign update_rsp_crd_cnt_s0   = txrsp_crd_cnt_inc_sx | txrsp_crd_cnt_dec_sx;
    assign rsp_crd_cnt_inc_s0      = (rsp_crd_cnt_s1 + 1'b1);
    assign rsp_crd_cnt_dec_s0      = (rsp_crd_cnt_s1 - 1'b1);

    always @* begin: rsp_crd_cnt_ns_s0_logic_c
        casez({txrsp_crd_cnt_inc_sx, txrsp_crd_cnt_dec_sx})
            2'b00:
                rsp_crd_cnt_ns_s0   = txrsp_crd_cnt_q;     // hold
            2'b01:
                rsp_crd_cnt_ns_s0   = rsp_crd_cnt_dec_s0;  // dec
            2'b10:
                rsp_crd_cnt_ns_s0   = rsp_crd_cnt_inc_s0;  // inc
            2'b11:
                rsp_crd_cnt_ns_s0   = txrsp_crd_cnt_q;     // hold
            default:
                rsp_crd_cnt_ns_s0 = {`HNI_LL_RSP_CRD_CNT_WIDTH{1'b0}};
        endcase
    end

    always @(posedge clk or posedge rst) begin: txrsp_crd_cnt_q_logic_t
        if (rst == 1'b1)
            txrsp_crd_cnt_q <= {`HNI_LL_RSP_CRD_CNT_WIDTH{1'b0}};
        else if (update_rsp_crd_cnt_s0 == 1'b1)
            txrsp_crd_cnt_q <= rsp_crd_cnt_ns_s0;
    end

endmodule
