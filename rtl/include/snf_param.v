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

`ifndef SNF_PARAM_V
`define SNF_PARAM_V

`define SNF_PARAM #( \
        parameter CHIE_REQ_ADDR_WIDTH_PARAM    = 44,    \
        parameter CHIE_NID_WIDTH_PARAM         = 7,     \
        parameter CHIE_DATA_WIDTH_PARAM        = 256,   \
        parameter CHIE_BE_WIDTH_PARAM          = 32,    \
        parameter CHIE_DATACHECK_WIDTH_PARAM   = 32,    \
        parameter CHIE_POISON_WIDTH_PARAM      = 4,     \
        parameter CHIE_REQ_RSVDC_WIDTH_PARAM   = 0,     \
        parameter CHIE_DAT_RSVDC_WIDTH_PARAM   = 0,     \
        parameter SNF_MSHR_HNF_NUM_PARAM       = 4,     \
        parameter XP_LCRD_NUM_PARAM            = 15,    \
        parameter SNF_MSHR_ENTRIES_NUM_PARAM   = 32,    \
        parameter SNF_NID_PARAM                = 3,     \
        parameter AXI4_AXDATA_WIDTH_PARAM      = 128,   \
        parameter AXI4_PA_WIDTH_PARAM          = 32,    \
        parameter SNF_MSHR_ENTRIES_WIDTH_PARAM = 5      )

`define SNF_PARAM_INST #( \
    .AXI4_AXDATA_WIDTH_PARAM            (AXI4_AXDATA_WIDTH_PARAM           ), \
    .AXI4_PA_WIDTH_PARAM                (AXI4_PA_WIDTH_PARAM               ), \
    .CHIE_REQ_ADDR_WIDTH_PARAM          (CHIE_REQ_ADDR_WIDTH_PARAM         ), \
    .CHIE_NID_WIDTH_PARAM               (CHIE_NID_WIDTH_PARAM              ), \
    .CHIE_DATA_WIDTH_PARAM              (CHIE_DATA_WIDTH_PARAM             ), \
    .CHIE_BE_WIDTH_PARAM                (CHIE_BE_WIDTH_PARAM               ), \
    .CHIE_DATACHECK_WIDTH_PARAM         (CHIE_DATACHECK_WIDTH_PARAM        ), \
    .CHIE_POISON_WIDTH_PARAM            (CHIE_POISON_WIDTH_PARAM           ), \
    .CHIE_REQ_RSVDC_WIDTH_PARAM         (CHIE_REQ_RSVDC_WIDTH_PARAM        ), \
    .CHIE_DAT_RSVDC_WIDTH_PARAM         (CHIE_DAT_RSVDC_WIDTH_PARAM        ), \
    .SNF_MSHR_HNF_NUM_PARAM             (SNF_MSHR_HNF_NUM_PARAM            ), \
    .XP_LCRD_NUM_PARAM                  (XP_LCRD_NUM_PARAM                 ), \
    .SNF_NID_PARAM                      (SNF_NID_PARAM                     ), \
    .SNF_MSHR_ENTRIES_NUM_PARAM         (SNF_MSHR_ENTRIES_NUM_PARAM        ), \
    .SNF_MSHR_ENTRIES_WIDTH_PARAM       (SNF_MSHR_ENTRIES_WIDTH_PARAM      ))

`endif
