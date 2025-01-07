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
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*    Xiaotian Cao <caoxiaotian@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_link_txreq_wrap `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_link
        txreq_lcrdv,

        //inputs from hnf_mshr_bypass
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

        //inputs from hnf_mshr_ctl
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

        //outputs to hnf_link
        txreqflitv,
        txreqflit,
        txreqflitpend,

        //outputs to hnf_mshr_ctl
        txreq_mshr_won_sx1,

        //outputs to hnf_mshr_bypass
        txreq_mshr_bypass_won_s1
    );

    //global inputs
    input wire                                        clk;
    input wire                                        rst;

    //inputs from hnf_link
    input wire                                        txreq_lcrdv;

    //inputs from hnf_mshr_bypass
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

    //inputs from hnf_mshr_ctl
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

    //outputs to hnf_link
    output reg                                        txreqflitv;
    output reg [`CHIE_REQ_FLIT_RANGE]                 txreqflit;
    output wire                                       txreqflitpend;

    //outputs to hnf_mshr_ctl
    output wire                                       txreq_mshr_won_sx1;

    //outputs to hnf_mshr_bypass
    output wire                                       txreq_mshr_bypass_won_s1;

    //internal reg signals
    reg [`HNF_LCRD_REQ_CNT_WIDTH-1:0]               txreq_crd_cnt_q;
    reg [`CHIE_REQ_FLIT_RANGE]                        txreqflit_bypass_s1;
    reg [`CHIE_REQ_FLIT_RANGE]                        txreqflit_sx1;
    reg [`HNF_LCRD_REQ_CNT_WIDTH-1:0]               req_crd_cnt_ns_s0;

    //internal wire signals
    wire                                              req_crd_cnt_not_zero_sx;
    wire                                              txreq_crd_avail_s1;
    wire                                              txreq_busy_sx;
    wire                                              txreqcrdv_s0;
    wire                                              txreq_crd_cnt_inc_sx;
    wire                                              txreq_req_s0;
    wire [`CHIE_REQ_FLIT_RANGE]                       txreqflit_s0;
    wire                                              txreqflitv_s0;
    wire                                              txreq_crd_cnt_dec_sx;
    wire                                              update_req_crd_cnt_s0;
    wire [`HNF_LCRD_REQ_CNT_WIDTH-1:0]              req_crd_cnt_s1;
    wire [`HNF_LCRD_REQ_CNT_WIDTH-1:0]              req_crd_cnt_inc_s0;
    wire [`HNF_LCRD_REQ_CNT_WIDTH-1:0]              req_crd_cnt_dec_s0;


    //main function
    assign req_crd_cnt_not_zero_sx = (txreq_crd_cnt_q != 'd0);
    assign txreq_crd_avail_s1      = (txreq_lcrdv | req_crd_cnt_not_zero_sx);
    assign txreq_busy_sx           = ~txreq_crd_avail_s1;

    assign txreq_mshr_bypass_won_s1    = (mshr_txreq_bypass_valid_s1 == 1'b1) && (~txreq_busy_sx);
    assign txreq_mshr_won_sx1      = (mshr_txreq_valid_sx1_q == 1'b1) && (mshr_txreq_bypass_valid_s1 == 1'b0) & ~txreq_busy_sx;
    assign txreqcrdv_s0            = txreq_lcrdv;
    assign txreq_crd_cnt_inc_sx    = txreqcrdv_s0;
    assign txreq_req_s0            = (mshr_txreq_bypass_valid_s1 | mshr_txreq_valid_sx1_q);

    generate
        if(CHIE_REQ_RSVDC_WIDTH_PARAM != 0)begin
            always @*begin
                txreqflit_bypass_s1[`CHIE_REQ_FLIT_RSVDC_RANGE] = {`CHIE_REQ_FLIT_RSVDC_WIDTH{1'b0}};
                txreqflit_sx1[`CHIE_REQ_FLIT_RSVDC_RANGE]       = {`CHIE_REQ_FLIT_RSVDC_WIDTH{1'b0}};
            end
        end
    endgenerate

    always @*begin
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_QOS_RANGE]          =  mshr_txreq_bypass_qos_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_TGTID_RANGE]        = SNF_NID_PARAM;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_SRCID_RANGE]        = HNF_NID_PARAM;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_TXNID_RANGE]        =  mshr_txreq_bypass_txnid_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_RETURNNID_RANGE]    = mshr_txreq_bypass_returnnid_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_ENDIAN_RANGE]       = {`CHIE_REQ_FLIT_ENDIAN_WIDTH{1'b0}};
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_RETURNTXNID_RANGE]  =  mshr_txreq_bypass_returntxnid_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_OPCODE_RANGE]       =  mshr_txreq_bypass_opcode_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_SIZE_RANGE]         =  mshr_txreq_bypass_size_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_ADDR_RANGE]         =  mshr_txreq_bypass_addr_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_NS_RANGE]           =  mshr_txreq_bypass_ns_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_LIKELYSHARED_RANGE] = {`CHIE_REQ_FLIT_LIKELYSHARED_WIDTH{1'b0}};
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE]   =  mshr_txreq_bypass_allowretry_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_ORDER_RANGE]        =  mshr_txreq_bypass_order_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_PCRDTYPE_RANGE]     =  mshr_txreq_bypass_pcrdtype_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_MEMATTR_RANGE]      =  mshr_txreq_bypass_memattr_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_DODWT_RANGE]        =  mshr_txreq_bypass_dodwt_s1;
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_LPID_RANGE]         = {`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_EXCL_RANGE]         = {`CHIE_REQ_FLIT_EXCL_WIDTH{1'b0}};
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_EXPCOMPACK_RANGE]   = {`CHIE_REQ_FLIT_EXPCOMPACK_WIDTH{1'b0}};
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_TAGOP_RANGE]        = {`CHIE_REQ_FLIT_TAGOP_WIDTH{1'b0}};
        txreqflit_bypass_s1[`CHIE_REQ_FLIT_TRACETAG_RANGE]     =  mshr_txreq_bypass_tracetag_s1;
    end

    always @*begin
        txreqflit_sx1[`CHIE_REQ_FLIT_QOS_RANGE]            = mshr_txreq_qos_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_TGTID_RANGE]          = SNF_NID_PARAM;
        txreqflit_sx1[`CHIE_REQ_FLIT_SRCID_RANGE]          = HNF_NID_PARAM;
        txreqflit_sx1[`CHIE_REQ_FLIT_TXNID_RANGE]          = mshr_txreq_txnid_sx1_q;
        txreqflit_sx1[`CHIE_REQ_FLIT_RETURNNID_RANGE]      = mshr_txreq_returnnid_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_ENDIAN_RANGE]         = {`CHIE_REQ_FLIT_ENDIAN_WIDTH{1'b0}};
        txreqflit_sx1[`CHIE_REQ_FLIT_RETURNTXNID_RANGE]    = mshr_txreq_returntxnid_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_OPCODE_RANGE]         = mshr_txreq_opcode_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_SIZE_RANGE]           = mshr_txreq_size_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_ADDR_RANGE]           = mshr_txreq_addr_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_NS_RANGE]             = mshr_txreq_ns_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_LIKELYSHARED_RANGE]   = {`CHIE_REQ_FLIT_LIKELYSHARED_WIDTH{1'b0}};
        txreqflit_sx1[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE]     = mshr_txreq_allowretry_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_ORDER_RANGE]          = mshr_txreq_order_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_PCRDTYPE_RANGE]       = mshr_txreq_pcrdtype_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_MEMATTR_RANGE]        = mshr_txreq_memattr_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_DODWT_RANGE]          = mshr_txreq_dodwt_sx1;
        txreqflit_sx1[`CHIE_REQ_FLIT_LPID_RANGE]           = {`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
        txreqflit_sx1[`CHIE_REQ_FLIT_EXCL_RANGE]           = {`CHIE_REQ_FLIT_EXCL_WIDTH{1'b0}};
        txreqflit_sx1[`CHIE_REQ_FLIT_EXPCOMPACK_RANGE]     = {`CHIE_REQ_FLIT_EXPCOMPACK_WIDTH{1'b0}};
        txreqflit_sx1[`CHIE_REQ_FLIT_TAGOP_RANGE]          = {`CHIE_REQ_FLIT_TAGOP_WIDTH{1'b0}};
        txreqflit_sx1[`CHIE_REQ_FLIT_TRACETAG_RANGE]       = mshr_txreq_tracetag_sx1;
    end

    assign txreqflit_s0 = ({`CHIE_REQ_FLIT_WIDTH{txreq_mshr_bypass_won_s1}} & txreqflit_bypass_s1) |
           ({`CHIE_REQ_FLIT_WIDTH{txreq_mshr_won_sx1  }} & txreqflit_sx1  ) ;

    assign req_crd_cnt_s1          = txreq_crd_cnt_q;
    assign txreqflitv_s0           = (txreq_req_s0 & ~txreq_busy_sx);
    assign txreq_crd_cnt_dec_sx    = (txreqflitv_s0 & txreq_crd_avail_s1); //lcrd - 1

    assign txreqflitpend = 1'b1;

    //txreqflit sending logic
    always @(posedge clk or posedge rst) begin: txreqflit_logic_t
        if(rst == 1'b1)begin
            txreqflit <= {`CHIE_REQ_FLIT_WIDTH{1'b0}};
            txreqflitv <= 1'b0;
        end
        else if((txreqflitv_s0 == 1'b1) & (txreq_crd_avail_s1 == 1'b1))begin
            txreqflit <= txreqflit_s0;
            txreqflitv <= 1'b1;
        end
        else begin
            txreqflitv <= 1'b0;
        end
    end

    //L-credit logic
    assign update_req_crd_cnt_s0   = txreq_crd_cnt_inc_sx | txreq_crd_cnt_dec_sx;
    assign req_crd_cnt_inc_s0      = (req_crd_cnt_s1 + 1'b1);
    assign req_crd_cnt_dec_s0      = (req_crd_cnt_s1 - 1'b1);

    always @* begin: req_crd_cnt_ns_s0_logic_c
        casez({txreq_crd_cnt_inc_sx, txreq_crd_cnt_dec_sx})
            2'b00:
                req_crd_cnt_ns_s0   = txreq_crd_cnt_q;     // hold
            2'b01:
                req_crd_cnt_ns_s0   = req_crd_cnt_dec_s0;  // dec
            2'b10:
                req_crd_cnt_ns_s0   = req_crd_cnt_inc_s0;  // inc
            2'b11:
                req_crd_cnt_ns_s0   = txreq_crd_cnt_q;     // hold
            default:
                req_crd_cnt_ns_s0 = {`HNF_LCRD_REQ_CNT_WIDTH{1'b0}};
        endcase
    end

    always @(posedge clk or posedge rst) begin: txreq_crd_cnt_q_logic_t
        if (rst == 1'b1)
            txreq_crd_cnt_q <= {`HNF_LCRD_REQ_CNT_WIDTH{1'b0}};
        else if (update_req_crd_cnt_s0 == 1'b1)
            txreq_crd_cnt_q <= req_crd_cnt_ns_s0;
    end
    //-----------------------------------------------------------------------------
    // DISPLAY INFO
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_INFO
    always @(posedge clk)begin
        if(txreqflitv)begin
            `display_info($sformatf("HNF TXREQ send a flit\n tgtid: %h\n opcode: %h\n txnid: %h\n returnnid: %h\n returntxnid: %h\n addr: %h\n allowretry: %h\n Time: %0d\n",txreqflit[`CHIE_REQ_FLIT_TGTID_RANGE],txreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE],txreqflit[`CHIE_REQ_FLIT_TXNID_RANGE],txreqflit[`CHIE_REQ_FLIT_RETURNNID_RANGE],txreqflit[`CHIE_REQ_FLIT_RETURNTXNID_RANGE],txreqflit[`CHIE_REQ_FLIT_ADDR_RANGE],txreqflit[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE],$time()));
        end
    end
`endif
endmodule
