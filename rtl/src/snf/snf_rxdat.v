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

module snf_rxdat `SNF_PARAM
    (
        clk,
        rst,
        run_state,
        rxdatflitv,
        rxdatflit,
        rxdatflitpend,

        rxdat_lcrdv,

        rxdat_valid_s0,
        rxdatflit_s0
    );

    //global inputs
    input wire                                      clk;
    input wire                                      rst;
    input wire                                      run_state;

    //inputs from snf_link
    input wire                                      rxdatflitv;
    input wire [`CHIE_DAT_FLIT_RANGE]               rxdatflit;
    input wire                                      rxdatflitpend;

    //outputs to snf_link
    output wire                                     rxdat_lcrdv;

    //outputs to snf_data_buffer
    output wire                                     rxdat_valid_s0;
    output wire [`CHIE_DAT_FLIT_RANGE]              rxdatflit_s0;

    //internal reg signals
    reg                                             rxdatflitv_en_q;
    reg  [`SNF_LL_DAT_CRD_CNT_WIDTH-1:0]            rxdat_crd_cnt_s1_q;
    reg  [3:0]                                      rxdat_crd_sm_out;
    reg                                             rxdatcrdv_s1_q;

    //internal wire signals
    wire                                            snf_rxcrd_enable_s0;
    wire                                            rxdat_crd_cnt_zero;
    wire [2:0]                                      rxdat_crd_sm_in;
    wire                                            rxdat_crd_cnt_upd_s0;
    wire                                            rxdat_crd_cnt_inc1_s0;
    wire                                            rxdat_crd_cnt_dec1_s0;
    wire [`SNF_LL_DAT_CRD_CNT_WIDTH-1:0]            rxdat_crd_cnt_dec1_val_s0;
    wire [`SNF_LL_DAT_CRD_CNT_WIDTH-1:0]            rxdat_crd_cnt_inc1_val_s0;
    wire [`SNF_LL_DAT_CRD_CNT_RANGE]                rxdat_crd_cnt_nxt_s0;
    wire                                            rxdatcrdv_ns_s0;

    //main function
    always @(posedge clk or posedge rst) begin:rxdatflitv_en_q_logic_t
        if(rst == 1'b1)
            rxdatflitv_en_q <= 1'b0;
        else if(rxdatflitpend == 1'b1)
            rxdatflitv_en_q <= 1'b1;
        else
            rxdatflitv_en_q <= 1'b0;
    end

    // to dbf
    assign rxdat_valid_s0  = (rxdatflitv == 1'b1);
    assign rxdatflit_s0    = (rxdatflitv == 1'b1)? rxdatflit : {`CHIE_DAT_FLIT_WIDTH{1'b0}};

    //rx lcrd enable
    assign snf_rxcrd_enable_s0 = run_state;

    //if lcrd is zero
    assign rxdat_crd_cnt_zero = (rxdat_crd_cnt_s1_q == {`SNF_LL_DAT_CRD_CNT_WIDTH{1'b0}});

    //rxdatlcrdv logic
    // ---------------------------- input ---------------------------- // // ---------- output ------------//
    // snf_rxcrd_enable_s0 rxdat_crd_cnt_zero dat_flitv // // lcrdupdate crdv inc1 dec1//
    //        1                      0            0                1       1    0    1      4'b1101   dec -1
    //        1                      0            1                0       1    0    0      4'b0100   no_change
    //        1                      1            0                0       0    0    0      4'b0000   no_change
    //        1                      1            1                0       1    0    0      4'b0100   no_change
    assign rxdat_crd_sm_in = {snf_rxcrd_enable_s0,rxdat_crd_cnt_zero,rxdat_valid_s0};

    //sm outputs
    always @(*) begin:rxdatlcrdv_logic_t
        casez (rxdat_crd_sm_in)
            3'b100:
                rxdat_crd_sm_out[3:0] = 4'hd;
            3'b101:
                rxdat_crd_sm_out[3:0] = 4'h4;
            3'b110:
                rxdat_crd_sm_out[3:0] = 4'h0;
            3'b111:
                rxdat_crd_sm_out[3:0] = 4'h4;
            default:
                rxdat_crd_sm_out[3:0] = 4'h0;
        endcase
    end

    assign rxdat_crd_cnt_upd_s0  = rxdat_crd_sm_out[3];
    assign rxdatcrdv_ns_s0       = rxdat_crd_sm_out[2];
    assign rxdat_crd_cnt_inc1_s0 = rxdat_crd_sm_out[1];
    assign rxdat_crd_cnt_dec1_s0 = rxdat_crd_sm_out[0];

    assign rxdat_crd_cnt_dec1_val_s0 = rxdat_crd_cnt_s1_q - `SNF_LL_CRD_INCDEC_ONE;
    assign rxdat_crd_cnt_inc1_val_s0 = rxdat_crd_cnt_s1_q + `SNF_LL_CRD_INCDEC_ONE;

    //update next credit value
    assign rxdat_crd_cnt_nxt_s0 = rxdat_crd_cnt_dec1_s0 ? rxdat_crd_cnt_dec1_val_s0:
           rxdat_crd_cnt_inc1_val_s0;

    always @(posedge clk or posedge rst) begin: rxdat_crd_cnt_s1_q_logic_t
        if (rst == 1'b1)
            rxdat_crd_cnt_s1_q <= XP_LCRD_NUM_PARAM;
        else if (rxdat_crd_cnt_upd_s0 == 1'b1)
            rxdat_crd_cnt_s1_q <= rxdat_crd_cnt_nxt_s0;
    end

    always @(posedge clk or posedge rst) begin: rxdatcrdv_s1_q_logic_t
        if (rst == 1'b1)
            rxdatcrdv_s1_q <= 1'b0;
        else
            rxdatcrdv_s1_q <= rxdatcrdv_ns_s0;
    end

    assign rxdat_lcrdv = rxdatcrdv_s1_q;

endmodule
