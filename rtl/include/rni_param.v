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
*    Ziqing Li <liziqing@bosc.ac.cn>
*    Wenhao Li <liwenhao@bosc.ac.cn>
*/

`ifndef RNI_PARAM_V
`define RNI_PARAM_V

`define RNI_PARAM #( \
    parameter AXI4_PA_WIDTH_PARAM        = 44,  \
    parameter AXI4_AXDATA_WIDTH_PARAM    = 128, \
    parameter CHIE_NID_WIDTH_PARAM       = 11,  \
    parameter CHIE_REQ_RSVDC_WIDTH_PARAM = 0,   \
    parameter CHIE_DAT_RSVDC_WIDTH_PARAM = 0,   \
    parameter CHIE_REQ_ADDR_WIDTH_PARAM  = 44,  \
    parameter CHIE_SNP_ADDR_WIDTH_PARAM  = 41,  \
    parameter CHIE_PA_WIDTH_PARAM        = 44,  \
    parameter CHIE_DATA_WIDTH_PARAM      = 256, \
    parameter CHIE_BE_WIDTH_PARAM        = 32,  \
    parameter CHIE_POISON_WIDTH_PARAM    = 0,   \
    parameter CHIE_DATACHECK_WIDTH_PARAM = 0,   \
    parameter RNI_AR_ENTRIES_NUM_PARAM   = 32,  \
    parameter RNI_AW_ENTRIES_NUM_PARAM   = 32,  \
    parameter HNF_NID_PARAM              = 0,   \
    parameter RNI_NID_PARAM              = 6    )

`define RNI_PARAM_INST #( \
    .AXI4_PA_WIDTH_PARAM            (AXI4_PA_WIDTH_PARAM         ), \
    .AXI4_AXDATA_WIDTH_PARAM        (AXI4_AXDATA_WIDTH_PARAM     ), \
    .CHIE_NID_WIDTH_PARAM           (CHIE_NID_WIDTH_PARAM        ), \
    .CHIE_REQ_RSVDC_WIDTH_PARAM     (CHIE_REQ_RSVDC_WIDTH_PARAM  ), \
    .CHIE_DAT_RSVDC_WIDTH_PARAM     (CHIE_DAT_RSVDC_WIDTH_PARAM  ), \
    .CHIE_REQ_ADDR_WIDTH_PARAM      (CHIE_REQ_ADDR_WIDTH_PARAM   ), \
    .CHIE_SNP_ADDR_WIDTH_PARAM      (CHIE_SNP_ADDR_WIDTH_PARAM   ), \
    .CHIE_PA_WIDTH_PARAM            (CHIE_PA_WIDTH_PARAM         ), \
    .CHIE_DATA_WIDTH_PARAM          (CHIE_DATA_WIDTH_PARAM       ), \
    .CHIE_BE_WIDTH_PARAM            (CHIE_BE_WIDTH_PARAM         ), \
    .CHIE_POISON_WIDTH_PARAM        (CHIE_POISON_WIDTH_PARAM     ), \
    .CHIE_DATACHECK_WIDTH_PARAM     (CHIE_DATACHECK_WIDTH_PARAM  ), \
    .RNI_AR_ENTRIES_NUM_PARAM       (RNI_AR_ENTRIES_NUM_PARAM    ), \
    .RNI_AW_ENTRIES_NUM_PARAM       (RNI_AW_ENTRIES_NUM_PARAM    ), \
    .HNF_NID_PARAM                  (HNF_NID_PARAM               ), \
    .RNI_NID_PARAM                  (RNI_NID_PARAM               ))

`endif
