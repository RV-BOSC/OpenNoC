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

module hni_txdat `HNI_PARAM
    (
        clk,
        rst,

        txdat_lcrdv,

        dbf_txdat_valid_sx,
        txdat_flit,

        txdatflitv,
        txdatflit,
        txdatflitpend,

        txdat_dbf_rdy_s1,
        txdat_dbf_won_sx
    );

    //global inputs
    input wire                                    clk;
    input wire                                    rst;

    //inputs from hni_link
    input wire                                    txdat_lcrdv;

    //inputs from hni_data_buffer
    input wire                                    dbf_txdat_valid_sx;
    input wire [`CHIE_DAT_FLIT_RANGE]             txdat_flit;

    //outputs to hni_link
    output reg                                    txdatflitv;
    output reg  [`CHIE_DAT_FLIT_RANGE]            txdatflit;
    output wire                                   txdatflitpend;

    //outputs to hni_dbf
    output  wire                                  txdat_dbf_rdy_s1;
    output  wire                                  txdat_dbf_won_sx;
    //internal reg signals
    reg [`HNI_LL_DAT_CRD_CNT_WIDTH-1:0]           txdat_crd_cnt_q;
    reg [`HNI_LL_DAT_CRD_CNT_WIDTH-1:0]           dat_crd_cnt_ns_s0;
    reg                                           txdat_dbf_won_q;

    //internal wire signals
    wire                                          dat_crd_cnt_not_zero_sx;
    wire                                          txdat_crd_avail_s1;
    wire                                          txdatcrdv_s0;
    wire                                          txdat_crd_cnt_inc_sx;
    wire                                          txdat_crd_cnt_dec_sx;
    wire                                          update_dat_crd_cnt_s0;
    wire [`HNI_LL_DAT_CRD_CNT_WIDTH-1:0]          dat_crd_cnt_s1;
    wire [`HNI_LL_DAT_CRD_CNT_WIDTH-1:0]          dat_crd_cnt_inc_s0;
    wire [`HNI_LL_DAT_CRD_CNT_WIDTH-1:0]          dat_crd_cnt_dec_s0;

    //main function
    assign dat_crd_cnt_not_zero_sx = (txdat_crd_cnt_q != {`HNI_LL_DAT_CRD_CNT_WIDTH{1'b0}});
    assign txdat_crd_avail_s1      = (txdat_lcrdv | dat_crd_cnt_not_zero_sx);

    assign txdatcrdv_s0            = txdat_lcrdv;
    assign txdat_crd_cnt_inc_sx    = txdatcrdv_s0;

    assign dat_crd_cnt_s1          = txdat_crd_cnt_q;
    assign txdat_crd_cnt_dec_sx    = (dbf_txdat_valid_sx & txdat_crd_avail_s1 & ~txdat_dbf_won_q); //lcrd - 1

    assign txdatflitpend = 1'b1;
    assign txdat_dbf_rdy_s1 = txdat_crd_avail_s1;

    //txdatflit sending logic
    always @(posedge clk or posedge rst) begin: txdatflit_logic_t
        if(rst == 1'b1)begin
            txdatflit  <= {`CHIE_DAT_FLIT_WIDTH{1'b0}};
            txdatflitv <= 1'b0;
            txdat_dbf_won_q <= 1'b0;
        end
        else if((txdat_crd_avail_s1 == 1'b1) && (dbf_txdat_valid_sx == 1'b1) && (!txdat_dbf_won_q))begin
            txdatflit  <= txdat_flit;
            txdatflitv <= 1'b1;
            txdat_dbf_won_q <= 1'b1;
        end
        else begin
            txdatflit  <= {`CHIE_DAT_FLIT_WIDTH{1'b0}};
            txdatflitv <= 1'b0;
            txdat_dbf_won_q <= 1'b0;
        end
    end

    assign txdat_dbf_won_sx        = txdat_dbf_won_q;

    //L-credit logic
    assign update_dat_crd_cnt_s0   = txdat_crd_cnt_inc_sx | txdat_crd_cnt_dec_sx;
    assign dat_crd_cnt_inc_s0      = (dat_crd_cnt_s1 + 1'b1);
    assign dat_crd_cnt_dec_s0      = (dat_crd_cnt_s1 - 1'b1);

    always @* begin: dat_crd_cnt_ns_s0_logic_c
        casez({txdat_crd_cnt_inc_sx, txdat_crd_cnt_dec_sx})
            2'b00:
                dat_crd_cnt_ns_s0 = txdat_crd_cnt_q;     // hold
            2'b01:
                dat_crd_cnt_ns_s0 = dat_crd_cnt_dec_s0;  // dec
            2'b10:
                dat_crd_cnt_ns_s0 = dat_crd_cnt_inc_s0;  // inc
            2'b11:
                dat_crd_cnt_ns_s0 = txdat_crd_cnt_q;     // hold
            default:
                dat_crd_cnt_ns_s0 = {`HNI_LL_DAT_CRD_CNT_WIDTH{1'b0}};
        endcase
    end

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)
            txdat_crd_cnt_q <= {`HNI_LL_DAT_CRD_CNT_WIDTH{1'b0}};
        else if (update_dat_crd_cnt_s0 == 1'b1)
            txdat_crd_cnt_q <= dat_crd_cnt_ns_s0;
    end

endmodule
