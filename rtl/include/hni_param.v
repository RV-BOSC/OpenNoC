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

`ifndef HNI_PARAM_H
`define HNI_PARAM_H
`define HNI_PARAM #( \
     parameter CHIE_REQ_ADDR_WIDTH_PARAM    = 44,    \
     parameter CHIE_NID_WIDTH_PARAM         = 7,     \
     parameter CHIE_DATA_WIDTH_PARAM        = 256,   \
     parameter CHIE_BE_WIDTH_PARAM          = 32,    \
     parameter CHIE_DATACHECK_WIDTH_PARAM   = 32,    \
     parameter CHIE_POISON_WIDTH_PARAM      = 4,     \
     parameter CHIE_REQ_RSVDC_WIDTH_PARAM   = 0,     \
     parameter CHIE_DAT_RSVDC_WIDTH_PARAM   = 0,     \
     parameter HNI_MSHR_RNF_NUM_PARAM       = 4,     \
     parameter AXI4_PA_WIDTH_PARAM          = 32,    \
     parameter AXI4_AXDATA_WIDTH_PARAM      = 128,   \
     parameter XP_LCRD_NUM_PARAM            = 15,    \
     parameter HNI_MSHR_EXCL_RN_NUM_PARAM   = 32,    \
     parameter HNI_MSHR_EXCL_RN_WIDTH_PARAM = 5,     \
     parameter HNI_MSHR_ENTRIES_NUM_PARAM   = 32,    \
     parameter HNI_MSHR_ENTRIES_WIDTH_PARAM = 5,     \
     parameter HNI_NODEID_PARAM             = 0,     \
     parameter HNI_ADDR_REGION_NUM          = 16,    \
     parameter [CHIE_REQ_ADDR_WIDTH_PARAM-1:0]HNI_ADDR_REGION_LSB[HNI_ADDR_REGION_NUM-1:0] = {44'hf000, 44'he000, 44'hd000, 44'hc000, 44'hb000, 44'ha000, 44'h9000, 44'h8000, 44'h7000, 44'h6000, 44'h5000, 44'h4000, 44'h3000, 44'h2000, 44'h1000, 44'h0000}, \
     parameter [CHIE_REQ_ADDR_WIDTH_PARAM-1:0]HNI_ADDR_REGION_SIZE[HNI_ADDR_REGION_NUM-1:0] = {12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12, 12})

`define HNI_PARAM_INST #( \
    .CHIE_REQ_ADDR_WIDTH_PARAM          (CHIE_REQ_ADDR_WIDTH_PARAM         ), \
    .CHIE_NID_WIDTH_PARAM               (CHIE_NID_WIDTH_PARAM              ), \
    .CHIE_DATA_WIDTH_PARAM              (CHIE_DATA_WIDTH_PARAM             ), \
    .CHIE_BE_WIDTH_PARAM                (CHIE_BE_WIDTH_PARAM               ), \
    .CHIE_DATACHECK_WIDTH_PARAM         (CHIE_DATACHECK_WIDTH_PARAM        ), \
    .CHIE_POISON_WIDTH_PARAM            (CHIE_POISON_WIDTH_PARAM           ), \
    .CHIE_REQ_RSVDC_WIDTH_PARAM         (CHIE_REQ_RSVDC_WIDTH_PARAM        ), \
    .CHIE_DAT_RSVDC_WIDTH_PARAM         (CHIE_DAT_RSVDC_WIDTH_PARAM        ), \
    .HNI_MSHR_RNF_NUM_PARAM             (HNI_MSHR_RNF_NUM_PARAM            ), \
    .AXI4_PA_WIDTH_PARAM                (AXI4_PA_WIDTH_PARAM               ), \
    .AXI4_AXDATA_WIDTH_PARAM            (AXI4_AXDATA_WIDTH_PARAM           ), \
    .XP_LCRD_NUM_PARAM                  (XP_LCRD_NUM_PARAM                 ), \
    .HNI_MSHR_EXCL_RN_NUM_PARAM         (HNI_MSHR_EXCL_RN_NUM_PARAM        ), \
    .HNI_MSHR_EXCL_RN_WIDTH_PARAM       (HNI_MSHR_EXCL_RN_WIDTH_PARAM      ), \
    .HNI_MSHR_ENTRIES_NUM_PARAM         (HNI_MSHR_ENTRIES_NUM_PARAM        ), \
    .HNI_MSHR_ENTRIES_WIDTH_PARAM       (HNI_MSHR_ENTRIES_WIDTH_PARAM      ), \
    .HNI_NODEID_PARAM                   (HNI_NODEID_PARAM                  ), \
    .HNI_ADDR_REGION_NUM                (HNI_ADDR_REGION_NUM               ), \
    .HNI_ADDR_REGION_LSB                (HNI_ADDR_REGION_LSB               ), \
    .HNI_ADDR_REGION_SIZE               (HNI_ADDR_REGION_SIZE              )  )

`endif /* HNI_PARAM_H */
