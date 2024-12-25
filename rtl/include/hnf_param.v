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
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*/

`ifndef HNF_PARAM_H
`define HNF_PARAM_H
`define HNF_PARAM #( \
     parameter CHIE_REQ_ADDR_WIDTH_PARAM    = 44,    \
     parameter CHIE_SNP_ADDR_WIDTH_PARAM    = 41,    \
     parameter CHIE_NID_WIDTH_PARAM         = 7,     \
     parameter CHIE_DATA_WIDTH_PARAM        = 256,   \
     parameter CHIE_BE_WIDTH_PARAM          = 32,    \
     parameter CHIE_DATACHECK_WIDTH_PARAM   = 32,    \
     parameter CHIE_POISON_WIDTH_PARAM      = 4,     \
     parameter CHIE_REQ_RSVDC_WIDTH_PARAM   = 0,     \
     parameter CHIE_DAT_RSVDC_WIDTH_PARAM   = 0,     \
     parameter HNF_MSHR_RNF_NUM_PARAM       = 4,     \
     parameter RNF_NID_LIST_PARAM           = {7'd48,7'd16,7'd40,7'd8}, \
     parameter HNF_NID_PARAM                = 0,     \
     parameter SNF_NID_PARAM                = 32,    \
     parameter XP_LCRD_NUM_PARAM            = 15,    \
     parameter HNF_SF_ENTRIES_NUM_PARAM     = 131072,\
     parameter HNF_SF_WAY_NUM_PARAM         = 16,    \
     parameter HNF_MSHR_EXCL_RN_NUM_PARAM   = 32,    \
     parameter HNF_MSHR_EXCL_RN_WIDTH_PARAM = 5,     \
     parameter HNF_MSHR_ENTRIES_NUM_PARAM   = 32,    \
     parameter HNF_MSHR_ENTRIES_WIDTH_PARAM = 5,     \
     parameter HNF_L3_CACHE_SIZE_PARAM      = 4096,  \
     parameter HNF_L3_WAY_NUM_PARAM         = 16     )

`define HNF_PARAM_INST #( \
    .CHIE_REQ_ADDR_WIDTH_PARAM          (CHIE_REQ_ADDR_WIDTH_PARAM         ), \
    .CHIE_SNP_ADDR_WIDTH_PARAM          (CHIE_SNP_ADDR_WIDTH_PARAM         ), \
    .CHIE_NID_WIDTH_PARAM               (CHIE_NID_WIDTH_PARAM              ), \
    .CHIE_DATA_WIDTH_PARAM              (CHIE_DATA_WIDTH_PARAM             ), \
    .CHIE_BE_WIDTH_PARAM                (CHIE_BE_WIDTH_PARAM               ), \
    .CHIE_DATACHECK_WIDTH_PARAM         (CHIE_DATACHECK_WIDTH_PARAM        ), \
    .CHIE_POISON_WIDTH_PARAM            (CHIE_POISON_WIDTH_PARAM           ), \
    .CHIE_REQ_RSVDC_WIDTH_PARAM         (CHIE_REQ_RSVDC_WIDTH_PARAM        ), \
    .CHIE_DAT_RSVDC_WIDTH_PARAM         (CHIE_DAT_RSVDC_WIDTH_PARAM        ), \
    .HNF_MSHR_RNF_NUM_PARAM             (HNF_MSHR_RNF_NUM_PARAM            ), \
    .RNF_NID_LIST_PARAM                 (RNF_NID_LIST_PARAM                ), \
    .HNF_NID_PARAM                      (HNF_NID_PARAM                     ), \
    .SNF_NID_PARAM                      (SNF_NID_PARAM                     ), \
    .XP_LCRD_NUM_PARAM                  (XP_LCRD_NUM_PARAM                 ), \
    .HNF_SF_ENTRIES_NUM_PARAM           (HNF_SF_ENTRIES_NUM_PARAM          ), \
    .HNF_SF_WAY_NUM_PARAM               (HNF_SF_WAY_NUM_PARAM              ), \
    .HNF_MSHR_EXCL_RN_NUM_PARAM         (HNF_MSHR_EXCL_RN_NUM_PARAM        ), \
    .HNF_MSHR_EXCL_RN_WIDTH_PARAM       (HNF_MSHR_EXCL_RN_WIDTH_PARAM      ), \
    .HNF_MSHR_ENTRIES_NUM_PARAM         (HNF_MSHR_ENTRIES_NUM_PARAM        ), \
    .HNF_MSHR_ENTRIES_WIDTH_PARAM       (HNF_MSHR_ENTRIES_WIDTH_PARAM      ), \
    .HNF_L3_CACHE_SIZE_PARAM            (HNF_L3_CACHE_SIZE_PARAM           ), \
    .HNF_L3_WAY_NUM_PARAM               (HNF_L3_WAY_NUM_PARAM              ))

`endif /* HNF_PARAM_H */

`define HNF_PARAM0_INST #( \
    .CHIE_REQ_ADDR_WIDTH_PARAM          (CHIE_REQ_ADDR_WIDTH_PARAM         ), \
    .CHIE_SNP_ADDR_WIDTH_PARAM          (CHIE_SNP_ADDR_WIDTH_PARAM         ), \
    .CHIE_NID_WIDTH_PARAM               (CHIE_NID_WIDTH_PARAM              ), \
    .CHIE_DATA_WIDTH_PARAM              (CHIE_DATA_WIDTH_PARAM             ), \
    .CHIE_BE_WIDTH_PARAM                (CHIE_BE_WIDTH_PARAM               ), \
    .CHIE_DATACHECK_WIDTH_PARAM         (CHIE_DATACHECK_WIDTH_PARAM        ), \
    .CHIE_POISON_WIDTH_PARAM            (CHIE_POISON_WIDTH_PARAM           ), \
    .CHIE_REQ_RSVDC_WIDTH_PARAM         (CHIE_REQ_RSVDC_WIDTH_PARAM        ), \
    .CHIE_DAT_RSVDC_WIDTH_PARAM         (CHIE_DAT_RSVDC_WIDTH_PARAM        ), \
    .HNF_MSHR_RNF_NUM_PARAM             (HNF_MSHR_RNF_NUM_PARAM            ), \
    .RNF_NID_LIST_PARAM                 (RNF_NID_LIST_PARAM                ), \
    .HNF_SF_ENTRIES_NUM_PARAM           (HNF_SF_ENTRIES_NUM_PARAM          ), \
    .HNF_SF_WAY_NUM_PARAM               (HNF_SF_WAY_NUM_PARAM              ), \
    .HNF_MSHR_EXCL_RN_NUM_PARAM         (HNF_MSHR_EXCL_RN_NUM_PARAM        ), \
    .HNF_MSHR_EXCL_RN_WIDTH_PARAM       (HNF_MSHR_EXCL_RN_WIDTH_PARAM      ), \
    .HNF_MSHR_ENTRIES_NUM_PARAM         (HNF_MSHR_ENTRIES_NUM_PARAM        ), \
    .HNF_MSHR_ENTRIES_WIDTH_PARAM       (HNF_MSHR_ENTRIES_WIDTH_PARAM      ), \
    .HNF_L3_CACHE_SIZE_PARAM            (HNF_L3_CACHE_SIZE_PARAM           ), \
    .HNF_L3_WAY_NUM_PARAM               (HNF_L3_WAY_NUM_PARAM              ))


