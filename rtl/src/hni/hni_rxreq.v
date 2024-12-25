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

module hni_rxreq `HNI_PARAM
    (
        clk,
        rst,

        rxreqflitv,
        rxreqflit,
        rxreqflitpend,

        rxreq_retry_enable_s0,

        txrsp_retryack_won_s1,

        rxreq_lcrdv,

        rxreq_valid_s0,
        rxreqflit_s0
    );

    //global inputs
    input wire                         clk;
    input wire                         rst;

    //inputs from link
    input wire                         rxreqflitv;
    input wire [`CHIE_REQ_FLIT_RANGE]  rxreqflit;
    input wire                         rxreqflitpend;

    //inputs from hni_qos
    input wire                         rxreq_retry_enable_s0;

    //inputs from hni_txrsp
    input wire                         txrsp_retryack_won_s1;

    //outputs to link
    output wire                        rxreq_lcrdv;

    //outputs to hni_qos
    output wire                        rxreq_valid_s0;
    output wire [`CHIE_REQ_FLIT_RANGE] rxreqflit_s0;

    //internal reg signals
    reg                                             rxreqflitv_en_q;
    reg [`HNI_LL_REQ_CRD_CNT_RANGE]                 rxreq_crd_cnt_s1_q;
    reg [3:0]                                       rxreq_crdcntsm_out;
    reg                                             rxreqcrdv_s1_q;

    //internal wire signals
    wire [`HNI_LL_REQ_CRD_CNT_RANGE]                rxreq_crd_cnt_inc1_val_s1;
    wire [`HNI_LL_REQ_CRD_CNT_RANGE]                rxreq_crd_cnt_dec_val_s1;
    wire [`HNI_LL_REQ_CRD_CNT_RANGE]                rxreq_crd_cnt_inc_s1;
    wire [3:0]                                      rxreq_crdcntsm_in_sx;
    wire                                            hni_rxcrd_enable_sx;
    wire                                            rxreq_crd_cnt_zero_sx;
    wire                                            req_crd_rtn_s0;
    wire                                            retack_tx_s1;
    wire                                            rxreq_crd_cnt_upd_s1;
    wire                                            rxreqcrdv_ns_s0;
    wire                                            rxreq_crd_cnt_inc1_s1;
    wire                                            rxreq_crd_cnt_dec_s1;
    wire [`HNI_LL_REQ_CRD_CNT_RANGE]                rxreq_crd_cnt_nxt_s1;

    //main function

    //link_rxreq_parse awake
    always @(posedge clk or posedge rst)begin : rxreqflitv_en_q_logic_t
        if(rst == 1'b1)
            rxreqflitv_en_q <= 1'b0;
        else if (rxreqflitpend == 1'b1)
            rxreqflitv_en_q <= 1'b1;
        else
            rxreqflitv_en_q <= 1'b0;
    end

    //rxreqflit decode
    assign rxreq_valid_s0    = (rxreqflitv == 1'b1);
    assign rxreqflit_s0      = (rxreqflitv == 1'b1) ? rxreqflit : {`CHIE_REQ_FLIT_WIDTH{1'b0}};

    //rxreq L-credit
    assign req_crd_rtn_s0 = !rxreq_retry_enable_s0 && rxreqflitv == 1'b1;

    //retry transaction sent
    assign retack_tx_s1 = txrsp_retryack_won_s1;

    // ---------- input ------------- //
    // hni_rxcrd_enable_sx rxreq_crd_cnt_zero_sx req_crd_rtn_s0 retack_tx_s1
    // ---------- output -------------//
    // upd lcrdv inc1 dec1
    // 1 0 0 0 //  8 //  1 1 0 1  //  dec - 1
    // 1 0 0 1 //  9 //  0 1 0 0  //  no change
    // 1 0 1 0 // 10 //  0 1 0 0  //  no change
    // 1 0 1 1 // 11 //  1 1 1 0  //  inc + 1

    // 1 1 0 0 // 12 //  0 0 0 0  //  no change
    // 1 1 0 1 // 13 //  0 1 0 0  //  no change
    // 1 1 1 0 // 14 //  0 1 0 0  //  no change
    // 1 1 1 1 // 15 //  1 1 1 0  //  inc + 1

    assign rxreq_crd_cnt_inc1_val_s1 = rxreq_crd_cnt_s1_q + `HNI_LL_CRD_INCDEC_ONE;
    assign rxreq_crd_cnt_dec_val_s1  = rxreq_crd_cnt_s1_q - `HNI_LL_CRD_INCDEC_ONE;

    assign hni_rxcrd_enable_sx   = 1'b1;
    assign rxreq_crd_cnt_zero_sx = (rxreq_crd_cnt_s1_q == {`HNI_LL_REQ_CRD_CNT_WIDTH{1'b0}});
    assign rxreq_crdcntsm_in_sx  = {hni_rxcrd_enable_sx, rxreq_crd_cnt_zero_sx, req_crd_rtn_s0, retack_tx_s1};

    always @*begin
        casez (rxreq_crdcntsm_in_sx)
            4'b1000  :
                rxreq_crdcntsm_out = 4'hd;
            4'b1001  :
                rxreq_crdcntsm_out = 4'h4;
            4'b1010  :
                rxreq_crdcntsm_out = 4'h4;
            4'b1011  :
                rxreq_crdcntsm_out = 4'he;

            4'b1100  :
                rxreq_crdcntsm_out = 4'h0;
            4'b1101  :
                rxreq_crdcntsm_out = 4'h4;
            4'b1110  :
                rxreq_crdcntsm_out = 4'h4;
            4'b1111  :
                rxreq_crdcntsm_out = 4'he;
            default   :
                rxreq_crdcntsm_out = 4'h0;
        endcase
    end

    assign rxreq_crd_cnt_upd_s1  = rxreq_crdcntsm_out[3];
    assign rxreqcrdv_ns_s0       = rxreq_crdcntsm_out[2];
    assign rxreq_crd_cnt_inc1_s1 = rxreq_crdcntsm_out[1];
    assign rxreq_crd_cnt_dec_s1  = rxreq_crdcntsm_out[0];

    assign rxreq_crd_cnt_nxt_s1 = rxreq_crd_cnt_dec_s1? rxreq_crd_cnt_dec_val_s1:
           rxreq_crd_cnt_inc_s1;

    assign rxreq_crd_cnt_inc_s1 = rxreq_crd_cnt_inc1_val_s1;


    always @(posedge clk or posedge rst) begin: rxreq_crd_cnt_s1_q_logic_t
        if (rst == 1'b1)
            rxreq_crd_cnt_s1_q <= XP_LCRD_NUM_PARAM;
        else if (rxreq_crd_cnt_upd_s1 == 1'b1)
            rxreq_crd_cnt_s1_q <= rxreq_crd_cnt_nxt_s1;
    end

    always @(posedge clk or posedge rst) begin: rxreqcrdv_s1_q_logic_t
        if (rst == 1'b1)
            rxreqcrdv_s1_q <= 1'b0;
        else
            rxreqcrdv_s1_q <= rxreqcrdv_ns_s0;
    end

    assign rxreq_lcrdv = rxreqcrdv_s1_q;

endmodule
