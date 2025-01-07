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
*    Wenhao Li <liwenhao@bosc.ac.cn>
*    Li Zhao <lizhao@bosc.ac.cn>
*    Bingcheng Jin <jinbingcheng@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_link_txrsp_wrap `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_link
        txrsp_lcrdv,

        //inputs from hnf_mshr_bypass
        mshr_txrsp_bypass_valid_s1,
        mshr_txrsp_bypass_qos_s1,
        mshr_txrsp_bypass_tgtid_s1,
        mshr_txrsp_bypass_txnid_s1,
        mshr_txrsp_bypass_opcode_s1,
        mshr_txrsp_bypass_resperr_s1,
        mshr_txrsp_bypass_dbid_s1,
        mshr_txrsp_bypass_tracetag_s1,

        //inputs from hnf_mshr_qos
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

        //inputs from hnf_mshr_ctl
        mshr_txrsp_valid_sx1_q,
        mshr_txrsp_qos_sx1,
        mshr_txrsp_tgtid_sx1,
        mshr_txrsp_txnid_sx1_q,
        mshr_txrsp_opcode_sx1,
        mshr_txrsp_resperr_sx1,
        mshr_txrsp_resp_sx1,
        mshr_txrsp_dbid_sx1,
        mshr_txrsp_tracetag_sx1,

        //outputs to hnf_link
        txrspflitv,
        txrspflit,
        txrspflitpend,

        //outputs to hnf_mshr_qos
        txrsp_mshr_retryack_won_s1,
        txrsp_mshr_pcrdgnt_won_s2,

        //outputs to hnf_mshr_ctl
        txrsp_mshr_won_sx1,
        txrsp_mshr_bypass_won_s1

    );

    //global inputs
    input wire                                     clk;
    input wire                                     rst;

    //inputs from hnf_link
    input wire                                     txrsp_lcrdv;

    //inputs from hnf_mshr_bypass
    input wire                                     mshr_txrsp_bypass_valid_s1;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]      mshr_txrsp_bypass_qos_s1;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]    mshr_txrsp_bypass_tgtid_s1;
    input wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]    mshr_txrsp_bypass_txnid_s1;
    input wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]   mshr_txrsp_bypass_opcode_s1;
    input wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]  mshr_txrsp_bypass_resperr_s1;
    input wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]     mshr_txrsp_bypass_dbid_s1;
    input wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0] mshr_txrsp_bypass_tracetag_s1;

    //inputs from hnf_mshr_qos
    input wire                                     qos_txrsp_retryack_valid_s1;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]      qos_txrsp_retryack_qos_s1;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]    qos_txrsp_retryack_tgtid_s1;
    input wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]    qos_txrsp_retryack_txnid_s1;
    input wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] qos_txrsp_retryack_pcrdtype_s1;
    input wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0] qos_txrsp_retryack_tracetag_s1;
    input wire                                     qos_txrsp_pcrdgnt_valid_s2;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]      qos_txrsp_pcrdgnt_qos_s2;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]    qos_txrsp_pcrdgnt_tgtid_s2;
    input wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] qos_txrsp_pcrdgnt_pcrdtype_s2;

    //inputs from hnf_mshr_ctl
    input wire                                     mshr_txrsp_valid_sx1_q;
    input wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]      mshr_txrsp_qos_sx1;
    input wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]    mshr_txrsp_tgtid_sx1;
    input wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]    mshr_txrsp_txnid_sx1_q;
    input wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]   mshr_txrsp_opcode_sx1;
    input wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]  mshr_txrsp_resperr_sx1;
    input wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]     mshr_txrsp_resp_sx1;
    input wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]     mshr_txrsp_dbid_sx1;
    input wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0] mshr_txrsp_tracetag_sx1;

    //outputs to hnf_link
    output reg                                     txrspflitv;
    output reg  [`CHIE_RSP_FLIT_RANGE]             txrspflit;
    output wire                                    txrspflitpend;

    //outputs to hnf_mshr_qos
    output wire                                    txrsp_mshr_retryack_won_s1;
    output wire                                    txrsp_mshr_pcrdgnt_won_s2;

    //outputs to hnf_mshr_ctl
    output wire                                    txrsp_mshr_won_sx1;
    output wire                                    txrsp_mshr_bypass_won_s1;

    //internal reg signals
    reg [`HNF_LCRD_RSP_CNT_WIDTH-1:0]            txrsp_crd_cnt_q;
    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_bypass_s1;
    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_retyack_s1;
    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_pcrdgnt_s2;
    reg [`CHIE_RSP_FLIT_RANGE]                     txrspflit_mshr_sx1;
    reg [`HNF_LCRD_RSP_CNT_WIDTH-1:0]            rsp_crd_cnt_ns_s0;

    //internal wire signals
    wire                                           txrsp_crd_avail_s1;
    wire                                           txrsp_busy_sx;
    wire                                           txrspcrdv_s0;
    wire                                           txrsp_req_s0;
    wire                                           txrspflitv_s0;
    wire [`CHIE_RSP_FLIT_RANGE]                    txrspflit_s0;
    wire [`HNF_LCRD_RSP_CNT_WIDTH-1:0]           rsp_crd_cnt_s1;
    wire [`HNF_LCRD_RSP_CNT_WIDTH-1:0]           rsp_crd_cnt_inc_s0;
    wire [`HNF_LCRD_RSP_CNT_WIDTH-1:0]           rsp_crd_cnt_dec_s0;
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

    //outputs to mshr

    assign txrsp_mshr_bypass_won_s1       = mshr_txrsp_bypass_valid_s1 &
           ~txrsp_busy_sx;

    assign txrsp_mshr_retryack_won_s1 = (qos_txrsp_retryack_valid_s1) &
           (~mshr_txrsp_bypass_valid_s1) &
           ~txrsp_busy_sx;

    assign txrsp_mshr_pcrdgnt_won_s2  = (qos_txrsp_pcrdgnt_valid_s2) &
           (~qos_txrsp_retryack_valid_s1) &
           (~mshr_txrsp_bypass_valid_s1) &
           ~txrsp_busy_sx;

    assign txrsp_mshr_won_sx1         = (mshr_txrsp_valid_sx1_q) &
           (~qos_txrsp_pcrdgnt_valid_s2) &
           (~qos_txrsp_retryack_valid_s1) &
           (~mshr_txrsp_bypass_valid_s1) &
           ~txrsp_busy_sx;

    assign txrspcrdv_s0               = txrsp_lcrdv;
    assign txrsp_crd_cnt_inc_sx       = txrspcrdv_s0;
    assign txrsp_req_s0               = (mshr_txrsp_bypass_valid_s1      |
                                         qos_txrsp_retryack_valid_s1 |
                                         qos_txrsp_pcrdgnt_valid_s2  |
                                         mshr_txrsp_valid_sx1_q);

    //arbitration

    always @*begin
        //bypass wrap
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_QOS_RANGE]           = mshr_txrsp_bypass_qos_s1;
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_TGTID_RANGE]         = mshr_txrsp_bypass_tgtid_s1;
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_SRCID_RANGE]         = HNF_NID_PARAM;
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_TXNID_RANGE]         = mshr_txrsp_bypass_txnid_s1;
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_OPCODE_RANGE]        = mshr_txrsp_bypass_opcode_s1;
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_RESPERR_RANGE]       = mshr_txrsp_bypass_resperr_s1;
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_RESP_RANGE]          = {`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_FWDSTATE_RANGE]      = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_CBUSY_RANGE]         = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_DBID_RANGE]          = mshr_txrsp_bypass_dbid_s1;
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_PCRDTYPE_RANGE]      = {`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_TAGOP_RANGE]         = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_bypass_s1[`CHIE_RSP_FLIT_TRACETAG_RANGE]      = mshr_txrsp_bypass_tracetag_s1;
    end
    always @*begin
        //RetryAck wrap
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_QOS_RANGE]      = qos_txrsp_retryack_qos_s1;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TGTID_RANGE]    = qos_txrsp_retryack_tgtid_s1;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_SRCID_RANGE]    = HNF_NID_PARAM;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TXNID_RANGE]    = qos_txrsp_retryack_txnid_s1;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_OPCODE_RANGE]   = `CHIE_RETRYACK;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_RESPERR_RANGE]  = {`CHIE_RSP_FLIT_RESPERR_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_RESP_RANGE]     = {`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_FWDSTATE_RANGE] = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_CBUSY_RANGE]    = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_DBID_RANGE]     = {`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_PCRDTYPE_RANGE] = qos_txrsp_retryack_pcrdtype_s1;
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TAGOP_RANGE]    = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_retyack_s1[`CHIE_RSP_FLIT_TRACETAG_RANGE] = qos_txrsp_retryack_tracetag_s1;
    end

    always @*begin
        //PCrdGrant wrap
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_QOS_RANGE]      = qos_txrsp_pcrdgnt_qos_s2;
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TGTID_RANGE]    = qos_txrsp_pcrdgnt_tgtid_s2;
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_SRCID_RANGE]    = HNF_NID_PARAM;
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TXNID_RANGE]    = {`CHIE_RSP_FLIT_TXNID_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_OPCODE_RANGE]   = `CHIE_PCRDGRANT;
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_RESPERR_RANGE]  = {`CHIE_RSP_FLIT_RESPERR_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_RESP_RANGE]     = {`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_FWDSTATE_RANGE] = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_CBUSY_RANGE]    = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_DBID_RANGE]     = {`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_PCRDTYPE_RANGE] = qos_txrsp_pcrdgnt_pcrdtype_s2;
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TAGOP_RANGE]    = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_pcrdgnt_s2[`CHIE_RSP_FLIT_TRACETAG_RANGE] = {`CHIE_RSP_FLIT_TRACETAG_WIDTH{1'b0}};
    end

    always @*begin
        //MSHR txrspflit wrap
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_QOS_RANGE]        = mshr_txrsp_qos_sx1;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_TGTID_RANGE]      = mshr_txrsp_tgtid_sx1;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_SRCID_RANGE]      = HNF_NID_PARAM;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_TXNID_RANGE]      = mshr_txrsp_txnid_sx1_q;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_OPCODE_RANGE]     = mshr_txrsp_opcode_sx1;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_RESPERR_RANGE]    = mshr_txrsp_resperr_sx1;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_RESP_RANGE]       = mshr_txrsp_resp_sx1;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_FWDSTATE_RANGE]   = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_CBUSY_RANGE]      = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_DBID_RANGE]       = mshr_txrsp_dbid_sx1;
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_PCRDTYPE_RANGE]   = {`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_TAGOP_RANGE]      = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_mshr_sx1[`CHIE_RSP_FLIT_TRACETAG_RANGE]   = mshr_txrsp_tracetag_sx1;
    end

    assign txrspflit_s0 = ({`CHIE_RSP_FLIT_WIDTH{txrsp_mshr_bypass_won_s1      }} & txrspflit_bypass_s1     ) |
           ({`CHIE_RSP_FLIT_WIDTH{txrsp_mshr_retryack_won_s1}} & txrspflit_retyack_s1) |
           ({`CHIE_RSP_FLIT_WIDTH{txrsp_mshr_pcrdgnt_won_s2 }} & txrspflit_pcrdgnt_s2) |
           ({`CHIE_RSP_FLIT_WIDTH{txrsp_mshr_won_sx1        }} & txrspflit_mshr_sx1  ) ;

    assign rsp_crd_cnt_s1          = txrsp_crd_cnt_q;
    assign txrspflitv_s0           = txrsp_req_s0 & ~txrsp_busy_sx;
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
                rsp_crd_cnt_ns_s0 = {`HNF_LCRD_RSP_CNT_WIDTH{1'b0}};
        endcase
    end

    always @(posedge clk or posedge rst) begin: txrsp_crd_cnt_q_logic_t
        if (rst == 1'b1)
            txrsp_crd_cnt_q <= {`HNF_LCRD_RSP_CNT_WIDTH{1'b0}};
        else if (update_rsp_crd_cnt_s0 == 1'b1)
            txrsp_crd_cnt_q <= rsp_crd_cnt_ns_s0;
    end

    //-----------------------------------------------------------------------------
    // DISPLAY INFO
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_INFO
    always @(posedge clk)begin
        if(txrspflitv)begin
            `display_info($sformatf("HNF TXRSP send a flit\n tgtid: %h\n opcode: %h\n txnid: %h\n resperr: %h\n dbid: %h\n Time: %0d\n",txrspflit[`CHIE_RSP_FLIT_TGTID_RANGE],txrspflit[`CHIE_RSP_FLIT_OPCODE_RANGE],txrspflit[`CHIE_RSP_FLIT_TXNID_RANGE],txrspflit[`CHIE_RSP_FLIT_RESPERR_RANGE],txrspflit[`CHIE_RSP_FLIT_DBID_RANGE],$time()));
        end
    end
`endif
endmodule
