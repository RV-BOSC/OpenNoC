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
*    Qichao Xie <xieqichao@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_link_rxrsp_parse `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_link
        rxrspflitv,
        rxrspflit,
        rxrspflitpend,

        //outputs to hnf_link
        rxrsp_lcrdv,

        //outputs to hnf_mshr
        li_mshr_rxrsp_valid_s0,
        li_mshr_rxrsp_srcid_s0,
        li_mshr_rxrsp_txnid_s0,
        li_mshr_rxrsp_opcode_s0,
        li_mshr_rxrsp_resp_s0,
        li_mshr_rxrsp_fwdstate_s0,
        li_mshr_rxrsp_dbid_s0,
        li_mshr_rxrsp_pcrdtype_s0
    );

    //global inputs
    input wire                                      clk;
    input wire                                      rst;

    //inputs from hnf_link
    input wire                                      rxrspflitv;
    input wire [`CHIE_RSP_FLIT_RANGE]               rxrspflit;
    input wire                                      rxrspflitpend;

    //outputs to hnf_link
    output wire                                     rxrsp_lcrdv;

    //outputs to hnf_mshr
    output wire                                     li_mshr_rxrsp_valid_s0;
    output wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]    li_mshr_rxrsp_srcid_s0;
    output wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]    li_mshr_rxrsp_txnid_s0;
    output wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]   li_mshr_rxrsp_opcode_s0;
    output wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]     li_mshr_rxrsp_resp_s0;
    output wire [`CHIE_RSP_FLIT_FWDSTATE_WIDTH-1:0] li_mshr_rxrsp_fwdstate_s0;
    output wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]     li_mshr_rxrsp_dbid_s0;
    output wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] li_mshr_rxrsp_pcrdtype_s0;

    //internal reg signals
    reg                                             rxrspflitv_en_q;
    reg  [`HNF_LCRD_RSP_CNT_WIDTH-1:0]            rxrsp_crd_cnt_s1_q;
    reg  [3:0]                                      rxrsp_crd_sm_out;
    reg                                             rxrspcrdv_s1_q;

    //internal wire signals
    wire                                            hnf_rxcrd_enable_s0;
    wire                                            rxrsp_crd_cnt_zero;
    wire [2:0]                                      rxrsp_crd_sm_in;
    wire                                            rxrsp_crd_cnt_upd_s0;
    wire                                            rxrsp_crd_cnt_inc1_s0;
    wire                                            rxrsp_crd_cnt_dec1_s0;
    wire [`HNF_LCRD_RSP_CNT_WIDTH-1:0]            rxrsp_crd_cnt_dec1_val_s0;
    wire [`HNF_LCRD_RSP_CNT_WIDTH-1:0]            rxrsp_crd_cnt_inc1_val_s0;
    wire [`HNF_LCRD_RSP_CNT_RANGE]                rxrsp_crd_cnt_nxt_s0;
    wire                                            rxrspcrdv_ns_s0;

    //main function
    //receive rxrspflitpend
    always @(posedge clk or posedge rst)begin : rxrspflitv_en_q_logic_t
        if(rst == 1'b1)
            rxrspflitv_en_q <= 1'b0;
        else if (rxrspflitpend == 1'b1)
            rxrspflitv_en_q <= 1'b1;
        else
            rxrspflitv_en_q <= 1'b0;
    end

    //rxrsp decode
    assign li_mshr_rxrsp_valid_s0      = (rxrspflitv == 1'b1);
    assign li_mshr_rxrsp_srcid_s0      = (rxrspflitv == 1'b1)? rxrspflit[`CHIE_RSP_FLIT_SRCID_RANGE]     :{`CHIE_RSP_FLIT_SRCID_WIDTH{1'b0}};
    assign li_mshr_rxrsp_txnid_s0      = (rxrspflitv == 1'b1)? rxrspflit[`CHIE_RSP_FLIT_TXNID_RANGE]     :{`CHIE_RSP_FLIT_TXNID_WIDTH{1'b0}};
    assign li_mshr_rxrsp_opcode_s0     = (rxrspflitv == 1'b1)? rxrspflit[`CHIE_RSP_FLIT_OPCODE_RANGE]    :{`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}};
    assign li_mshr_rxrsp_resp_s0       = (rxrspflitv == 1'b1)? rxrspflit[`CHIE_RSP_FLIT_RESP_RANGE]      :{`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
    assign li_mshr_rxrsp_fwdstate_s0   = (rxrspflitv == 1'b1)? rxrspflit[`CHIE_RSP_FLIT_FWDSTATE_RANGE]  :{`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
    assign li_mshr_rxrsp_dbid_s0       = (rxrspflitv == 1'b1)? rxrspflit[`CHIE_RSP_FLIT_DBID_RANGE]      :{`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
    assign li_mshr_rxrsp_pcrdtype_s0   = (rxrspflitv == 1'b1)? rxrspflit[`CHIE_RSP_FLIT_PCRDTYPE_RANGE]  :{`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};

    //rx lcrd enable
    assign hnf_rxcrd_enable_s0 = 1'b1;


    //if lcrd is zero
    assign rxrsp_crd_cnt_zero = (rxrsp_crd_cnt_s1_q == {`HNF_LCRD_RSP_CNT_WIDTH{1'b0}});

    //rxrsp_crd state maching input
    //enable sending crd
    assign rxrsp_crd_sm_in[2] = hnf_rxcrd_enable_s0;

    //crd count == 0
    assign rxrsp_crd_sm_in[1] = rxrsp_crd_cnt_zero;

    //receive responses except RespLCrdReturn
    assign rxrsp_crd_sm_in[0] = li_mshr_rxrsp_valid_s0;

    //rxrsplcrdv logic
    // ---------------------------- input ---------------------------- // // ---------- output ------------//
    // hnf_rxcrd_enable_s0 rxrsp_crd_cnt_zero rsp_flitv // // lcrdupdate crdv inc1 dec1//
    //        1                      0            0                1       1    0    1      4'b1101   dec -1
    //        1                      0            1                0       1    0    0      4'b0100   no_change
    //        1                      1            0                0       0    0    0      4'b0000   no_change
    //        1                      1            1                0       1    0    0      4'b0100   no_change

    //sm outputs
    always @(*) begin:rxrsplcrdv_logic_t
        casez (rxrsp_crd_sm_in)
            3'b100:
                rxrsp_crd_sm_out[3:0] = 4'hd;
            3'b101:
                rxrsp_crd_sm_out[3:0] = 4'h4;
            3'b110:
                rxrsp_crd_sm_out[3:0] = 4'h0;
            3'b111:
                rxrsp_crd_sm_out[3:0] = 4'h4;
            default:
                rxrsp_crd_sm_out[3:0] = 4'h0;
        endcase
    end

    assign rxrsp_crd_cnt_upd_s0  = rxrsp_crd_sm_out[3];
    assign rxrspcrdv_ns_s0       = rxrsp_crd_sm_out[2];
    assign rxrsp_crd_cnt_inc1_s0 = rxrsp_crd_sm_out[1];
    assign rxrsp_crd_cnt_dec1_s0 = rxrsp_crd_sm_out[0];

    assign rxrsp_crd_cnt_dec1_val_s0 = rxrsp_crd_cnt_s1_q - `LCRD_INCDEC_ONE;
    assign rxrsp_crd_cnt_inc1_val_s0 = rxrsp_crd_cnt_s1_q + `LCRD_INCDEC_ONE;

    //update next credit value
    assign rxrsp_crd_cnt_nxt_s0 = rxrsp_crd_cnt_dec1_s0 ? rxrsp_crd_cnt_dec1_val_s0:
           rxrsp_crd_cnt_inc1_val_s0;

    always @(posedge clk or posedge rst) begin: rxrsp_crd_cnt_s1_q_logic_t
        if (rst == 1'b1)
            rxrsp_crd_cnt_s1_q <= XP_LCRD_NUM_PARAM;
        else if (rxrsp_crd_cnt_upd_s0 == 1'b1)
            rxrsp_crd_cnt_s1_q <= rxrsp_crd_cnt_nxt_s0;
    end

    always @(posedge clk or posedge rst) begin: rxrspcrdv_s1_q_logic_t
        if (rst == 1'b1)
            rxrspcrdv_s1_q <= 1'b0;
        else
            rxrspcrdv_s1_q <= rxrspcrdv_ns_s0;
    end

    assign rxrsp_lcrdv = rxrspcrdv_s1_q;
    //-----------------------------------------------------------------------------
    // DISPLAY INFO
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_INFO
    always @(posedge clk)begin
        if(rxrspflitv)begin
            `display_info($sformatf("HNF RXRSP received a flit\n opcode: %h\n srcid: %h\n txnid: %h\n resp: %h\n fwdstate: %h\n dbid: %h\n pcrdtype: %h\n Time: %0d\n",li_mshr_rxrsp_opcode_s0,li_mshr_rxrsp_srcid_s0,li_mshr_rxrsp_txnid_s0,li_mshr_rxrsp_resp_s0,li_mshr_rxrsp_fwdstate_s0,li_mshr_rxrsp_dbid_s0,li_mshr_rxrsp_pcrdtype_s0,$time()));
        end
    end
`endif

    //-----------------------------------------------------------------------------
    // DISPLAY FATAL
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_FATAL
    always @(*)begin
        `display_fatal( (!li_mshr_rxrsp_valid_s0) || (li_mshr_rxrsp_opcode_s0 == `CHIE_RSPLCRDRETURN)||(li_mshr_rxrsp_opcode_s0 == `CHIE_SNPRESP)||(li_mshr_rxrsp_opcode_s0 == `CHIE_COMPACK)||(li_mshr_rxrsp_opcode_s0 == `CHIE_RETRYACK)||(li_mshr_rxrsp_opcode_s0 == `CHIE_COMP)||(li_mshr_rxrsp_opcode_s0 == `CHIE_COMPDBIDRESP)||(li_mshr_rxrsp_opcode_s0 == `CHIE_DBIDRESP)||(li_mshr_rxrsp_opcode_s0 == `CHIE_PCRDGRANT)||(li_mshr_rxrsp_opcode_s0 ==  `CHIE_READRECEIPT)||(li_mshr_rxrsp_opcode_s0 == `CHIE_SNPRESPFWDED),$sformatf("Fatal info: RXRSP received a unsupported flit with opcode: %h",li_mshr_rxrsp_opcode_s0));
    end
`endif
endmodule
