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

module snf_txrsp `SNF_PARAM
    (
        clk,
        rst,

        txrsp_lcrdv,

        qos_txrsp_retryack_valid_s1,
        qos_txrsp_retryack_fifo_s1,

        qos_txrsp_pcrdgnt_valid_s2,
        qos_txrsp_pcrdgnt_fifo_s2,

        txrsp_valid_sx,
        txrsp_qos_sx,
        txrsp_tgtid_sx,
        txrsp_txnid_sx,
        txrsp_opcode_sx,
        txrsp_resperr_sx,
        txrsp_resp_sx,
        txrsp_dbid_sx,
        txrsp_tracetag_sx,
        txrsp_srcid_sx,

        txrspflitv,
        txrspflit,
        txrspflitpend,

        txrsp_retryack_won_s1,
        txrsp_pcrdgnt_won_s2,

        txrsp_won_sx
    );

    //global inputs
    input wire                                     clk;
    input wire                                     rst;

    //inputs from snf_link
    input wire                                     txrsp_lcrdv;

    input wire                                     qos_txrsp_retryack_valid_s1;
    input wire [`SNF_RETRY_ACKQ_DATA_RANGE]            qos_txrsp_retryack_fifo_s1;

    input wire                                     qos_txrsp_pcrdgnt_valid_s2;
    input wire [`SNF_PCRDGRANTQ_DATA_RANGE]            qos_txrsp_pcrdgnt_fifo_s2;

    //inputs from snf_mshr
    input wire                                     txrsp_valid_sx;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]      txrsp_qos_sx;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]    txrsp_tgtid_sx;
    input wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]    txrsp_txnid_sx;
    input wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]   txrsp_opcode_sx;
    input wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]  txrsp_resperr_sx;
    input wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]     txrsp_resp_sx;
    input wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]     txrsp_dbid_sx;
    input wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0] txrsp_tracetag_sx;
    input wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]    txrsp_srcid_sx;

    //outputs to snf_link
    output reg                                     txrspflitv;
    output reg  [`CHIE_RSP_FLIT_RANGE]             txrspflit;
    output wire                                    txrspflitpend;

    //outputs to snf_qos
    output wire                                    txrsp_retryack_won_s1;
    output wire                                    txrsp_pcrdgnt_won_s2;

    //outputs to snf_mshr
    output wire                                    txrsp_won_sx;

    //internal reg signals
    reg [`SNF_LL_RSP_CRD_CNT_WIDTH-1:0]            txrsp_crd_cnt_q;

    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_retyack_s1;
    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_pcrdgnt_s2;
    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_mshr_sx1;
    reg [`SNF_LL_RSP_CRD_CNT_WIDTH-1:0]            rsp_crd_cnt_ns_s0;
    wire                                           txrsp_crd_avail_s1;
    wire                                           txrsp_busy_sx;
    wire                                           txrspcrdv_s0;
    wire                                           txrsp_req_s0;
    wire                                           txrspflitv_s0;
    wire [`CHIE_RSP_FLIT_RANGE]                    txrspflit_s0;
    wire [`SNF_LL_RSP_CRD_CNT_WIDTH-1:0]           rsp_crd_cnt_s1;
    wire [`SNF_LL_RSP_CRD_CNT_WIDTH-1:0]           rsp_crd_cnt_inc_s0;
    wire [`SNF_LL_RSP_CRD_CNT_WIDTH-1:0]           rsp_crd_cnt_dec_s0;
    wire                                           update_rsp_crd_cnt_s0;
    wire                                           txrsp_crd_cnt_inc_sx;
    wire                                           txrsp_crd_cnt_dec_sx;
    wire                                           rsp_crd_cnt_not_zero_sx;

    //arb and lcrd_avail
    assign rsp_crd_cnt_not_zero_sx     = (txrsp_crd_cnt_q != 0);

    // just received it or not zero
    assign txrsp_crd_avail_s1          = (txrsp_lcrdv | rsp_crd_cnt_not_zero_sx);
    assign txrsp_busy_sx               = ~txrsp_crd_avail_s1;

    //output to qos
    assign txrsp_retryack_won_s1 = (qos_txrsp_retryack_valid_s1) &
           ~txrsp_busy_sx;

    assign txrsp_pcrdgnt_won_s2  = (qos_txrsp_pcrdgnt_valid_s2) &
           (~qos_txrsp_retryack_valid_s1) &
           ~txrsp_busy_sx;

    //output to mshr
    assign txrsp_won_sx         = (txrsp_valid_sx) &
           (~qos_txrsp_pcrdgnt_valid_s2) &
           (~qos_txrsp_retryack_valid_s1) &
           ~txrsp_busy_sx;

    assign txrspcrdv_s0               = txrsp_lcrdv;
    assign txrsp_crd_cnt_inc_sx       = txrspcrdv_s0;
    assign txrsp_req_s0               = (qos_txrsp_retryack_valid_s1 |
                                         qos_txrsp_pcrdgnt_valid_s2  |
                                         txrsp_valid_sx);
    always @*begin
        //RetryAck wrap
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_QOS_RANGE]      = qos_txrsp_retryack_fifo_s1[`SNF_RETRY_ACKQ_QOS_RANGE];
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TGTID_RANGE]    = qos_txrsp_retryack_fifo_s1[`SNF_RETRY_ACKQ_SRCID_RANGE];
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_SRCID_RANGE]    = SNF_NID_PARAM;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TXNID_RANGE]    = qos_txrsp_retryack_fifo_s1[`SNF_RETRY_ACKQ_TXNID_RANGE];
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_OPCODE_RANGE]   = `CHIE_RETRYACK;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_RESPERR_RANGE]  = {`CHIE_RSP_FLIT_RESPERR_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_RESP_RANGE]     = {`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_FWDSTATE_RANGE] = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_CBUSY_RANGE]    = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_DBID_RANGE]     = {`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_PCRDTYPE_RANGE] = qos_txrsp_retryack_fifo_s1[`SNF_RETRY_ACKQ_PCRDTYPE_RANGE];
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TAGOP_RANGE]    = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TRACETAG_RANGE] = qos_txrsp_retryack_fifo_s1[`SNF_RETRY_ACKQ_TRACE_RANGE];
    end

    always @*begin
        //PCrdGrant wrap
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_QOS_RANGE]      = qos_txrsp_pcrdgnt_fifo_s2[`SNF_PCRDGRANTQ_QOS_RANGE];
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TGTID_RANGE]    = qos_txrsp_pcrdgnt_fifo_s2[`SNF_PCRDGRANTQ_SRCID_RANGE];
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_SRCID_RANGE]    = SNF_NID_PARAM;
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TXNID_RANGE]    = {`CHIE_RSP_FLIT_TXNID_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_OPCODE_RANGE]   = `CHIE_PCRDGRANT;
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_RESPERR_RANGE]  = {`CHIE_RSP_FLIT_RESPERR_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_RESP_RANGE]     = {`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_FWDSTATE_RANGE] = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_CBUSY_RANGE]    = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_DBID_RANGE]     = {`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_PCRDTYPE_RANGE] = qos_txrsp_pcrdgnt_fifo_s2[`SNF_PCRDGRANTQ_PCRDTYPE_RANGE];
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TAGOP_RANGE]    = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TRACETAG_RANGE] = {`CHIE_RSP_FLIT_TRACETAG_WIDTH{1'b0}};
    end

    always @*begin
        //MSHR txrspflit wrap
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_QOS_RANGE]        = txrsp_qos_sx;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_TGTID_RANGE]      = txrsp_tgtid_sx;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_SRCID_RANGE]      = txrsp_srcid_sx;
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

    assign txrspflit_s0 = ({`CHIE_RSP_FLIT_WIDTH{txrsp_retryack_won_s1}} & txrspflit_retyack_s1) |
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
                rsp_crd_cnt_ns_s0 = {`SNF_LL_RSP_CRD_CNT_WIDTH{1'b0}};
        endcase
    end

    always @(posedge clk or posedge rst) begin: txrsp_crd_cnt_q_logic_t
        if (rst == 1'b1)
            txrsp_crd_cnt_q <= {`SNF_LL_RSP_CRD_CNT_WIDTH{1'b0}};
        else if (update_rsp_crd_cnt_s0 == 1'b1)
            txrsp_crd_cnt_q <= rsp_crd_cnt_ns_s0;
    end


endmodule

