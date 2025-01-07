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
*    Nana Cai <cainana@bosc.ac.cn>
*/

`ifndef HNF_DEFINES
`define HNF_DEFINES

`include "chie_defines.v"

// `define HNF_DELAY_ONE_CYCLE
// `define FPGA_MEMORY
// `define DISPLAY_INFO
// `define DISPLAY_ERROR
// `define DISPLAY_FATAL

`define CHIE_RSP_CHANNEL                   1
`define CHIE_DAT_CHANNEL                   0

//global define
`define RN0_ID                             8
`define RN1_ID                             40
`define RN2_ID                             16
`define RN3_ID                             48
`define HNF0_ID                            0
`define SN_ID                              32
`define RN4_ID                             6
`define RN5_ID                             7
`define RN6_ID                             9
`define RN7_ID                             10
`define RN8_ID                             11
`define RN9_ID                             12
`define RN10_ID                            13
`define RN11_ID                            14
`define RN12_ID                            15
`define RN13_ID                            17
`define RN14_ID                            18
`define RN15_ID                            19

`ifdef DISPLAY_INFO
`define display_info(info)                    $display(info);
`endif

`ifdef DISPLAY_ERROR
`define display_error(flag,info)              if(!(flag)) $error(info);
`endif

`ifdef DISPLAY_FATAL
`define display_fatal(flag,info)              if(!(flag)) $fatal(info);
`endif

`define CACHE_LINE_WIDTH                   CHIE_DATA_WIDTH_PARAM*2
`define CACHE_BE_WIDTH                     CHIE_BE_WIDTH_PARAM*2
`define CACHE_BLOCK_OFFSET                 6
`define RNF_NUM                            HNF_MSHR_RNF_NUM_PARAM
`define RNI_NUM                            HNF_MSHR_RNI_NUM_PARAM
`define RN_NUM                             (HNF_MSHR_RNF_NUM_PARAM + HNF_MSHR_RNI_NUM_PARAM)
`define RNF_WIDTH                          ((HNF_MSHR_RNF_NUM_PARAM == 1)? 1 : $clog2(HNF_MSHR_RNF_NUM_PARAM))
`define RNI_WIDTH                          ((HNF_MSHR_RNI_NUM_PARAM <= 1)? 1 : $clog2(HNF_MSHR_RNI_NUM_PARAM))
`define RN_WIDTH                           ((`RN_NUM == 1)? 1 : $clog2(`RN_NUM))
`define MSHR_ENTRIES_NUM                   HNF_MSHR_ENTRIES_NUM_PARAM
`define MSHR_ENTRIES_WIDTH                 HNF_MSHR_ENTRIES_WIDTH_PARAM

//hnf_sf_sram
`define SF_WAY_NUM                         HNF_SF_WAY_NUM_PARAM
`define SF_SET_NUM                         (HNF_SF_ENTRIES_NUM_PARAM/HNF_SF_WAY_NUM_PARAM)
`define SF_INDEX_WIDTH                     $clog2(`SF_SET_NUM)
`define SF_INDEX_RANGE                     `SF_INDEX_WIDTH + `CACHE_BLOCK_OFFSET - 1 : `CACHE_BLOCK_OFFSET
`define SF_TAG_WIDTH                       (CHIE_REQ_ADDR_WIDTH_PARAM-`SF_INDEX_WIDTH-`CACHE_BLOCK_OFFSET)
`define SF_TAG_RANGE                       CHIE_REQ_ADDR_WIDTH_PARAM-1:`SF_INDEX_WIDTH+`CACHE_BLOCK_OFFSET
`define SF_STATE_WIDTH                     2
`define SF_STATE_VALID                     0
`define SF_STATE_SHARE                     1
`define SF_I                               0
`define SF_S                               3
`define SF_U                               1
`define SF_CLINE_WIDTH                     (`SF_TAG_WIDTH+`RNF_NUM*`SF_STATE_WIDTH)

//hnf_tag_sram
`define LOC_WAY_NUM                        HNF_L3_WAY_NUM_PARAM
`define LOC_SET_NUM                        (HNF_L3_CACHE_SIZE_PARAM*1024/64/HNF_L3_WAY_NUM_PARAM)
`define LOC_INDEX_WIDTH                    $clog2(`LOC_SET_NUM)
`define LOC_INDEX_RANGE                    `LOC_INDEX_WIDTH + `CACHE_BLOCK_OFFSET - 1: `CACHE_BLOCK_OFFSET
`define LOC_TAG_WIDTH                      (CHIE_REQ_ADDR_WIDTH_PARAM - `LOC_INDEX_WIDTH - `CACHE_BLOCK_OFFSET)
`define LOC_TAG_RANGE                      CHIE_REQ_ADDR_WIDTH_PARAM - 1: `LOC_INDEX_WIDTH + `CACHE_BLOCK_OFFSET
`define LOC_TAG_STATE                      2
`define LOC_TAG_STATE_VALID                0
`define LOC_TAG_STATE_CLEAN                1
`define LOC_CLINE_WIDTH                    (`LOC_TAG_WIDTH + `LOC_TAG_STATE)

//hnf_lru_sram
`define LRU_CLINE_WIDTH                    HNF_L3_WAY_NUM_PARAM*2

//hnf_link_req_channel_lcredit
`define HNF_LCRD_REQ_CNT_WIDTH             4
`define HNF_LCRD_REQ_CNT_RANGE             3:0
`define HNF_LCRD_REQ_CNT_MSB               3
`define HNF_LCRD_REQ_CNT_LSB               0
`define HNF_LCRD_REQ_MAX_VALUE             XP_LCRD_NUM_PARAM
`define LCRD_INCDEC_ONE                    1
`define LCRD_INCDEC_TWO                    2
`define LCRD_INCDEC_THREE                  3

//hnf_link_rsp_channel_lcredit
`define HNF_LCRD_RSP_CNT_WIDTH             4
`define HNF_LCRD_RSP_CNT_RANGE             3:0
`define HNF_LCRD_RSP_CNT_MSB               3
`define HNF_LCRD_RSP_CNT_LSB               0
`define HNF_LCRD_RSP_MAX_VALUE             XP_LCRD_NUM_PARAM

//hnf_link_snp_channel_lcredit
`define HNF_LCRD_SNP_CNT_WIDTH             4
`define HNF_LCRD_SNP_CNT_RANGE             3:0
`define HNF_LCRD_SNP_CNT_MSB               3
`define HNF_LCRD_SNP_CNT_LSB               0
`define HNF_LCRD_SNP_MAX_VALUE             XP_LCRD_NUM_PARAM
`define HNF_SNP_FLIT_RANGE                 `CHIE_SNP_FLIT_WIDTH+CHIE_NID_WIDTH_PARAM-1:0
`define HNF_SNP_FLIT_WIDTH                 `CHIE_SNP_FLIT_WIDTH+CHIE_NID_WIDTH_PARAM

//hnf_link_dat_channel_lcredit
`define HNF_LCRD_DAT_CNT_WIDTH             4
`define HNF_LCRD_DAT_CNT_RANGE             3:0
`define HNF_LCRD_DAT_CNT_MSB               3
`define HNF_LCRD_DAT_CNT_LSB               0
`define HNF_LCRD_DAT_MAX_VALUE             XP_LCRD_NUM_PARAM

//hnf_mshr_qos
`define QOS_CLASS_WIDTH                    3
`define QOS_CLASS_SEQ                      4
`define QOS_CLASS_HHIGH                    3
`define QOS_CLASS_HIGH                     2
`define QOS_CLASS_MED                      1
`define QOS_CLASS_LOW                      0
`define QOS_HHIGH_MAX                      15
`define QOS_HHIGH_MIN                      15
`define QOS_HIGH_MAX                       14
`define QOS_HIGH_MIN                       12
`define QOS_MED_MAX                        11
`define QOS_MED_MIN                        8
`define QOS_LOW_MAX                        7
`define QOS_LOW_MIN                        0
`define QOS_POOL_CNT_WIDTH                 ((HNF_MSHR_ENTRIES_NUM_PARAM == 32)? 4 : 5)
`define QOS_HHIGH_POOL_NUM                 ((HNF_MSHR_ENTRIES_NUM_PARAM == 32)? 2 : 4)
`define QOS_HIGH_POOL_NUM                  ((HNF_MSHR_ENTRIES_NUM_PARAM == 32)? 6 : 12)
`define QOS_MED_POOL_NUM                   ((HNF_MSHR_ENTRIES_NUM_PARAM == 32)? 8 : 16)
`define QOS_LOW_POOL_NUM                   ((HNF_MSHR_ENTRIES_NUM_PARAM == 32)? 15 : 31)
`define RET_BANK_CNT_WIDTH                 10
`define RET_BANK_ENTRIES_NUM               HNF_MSHR_RNF_NUM_PARAM
`define RET_BANK_ENTRIES_WIDTH             ((HNF_MSHR_RNF_NUM_PARAM == 1)? 1 : $clog2(HNF_MSHR_RNF_NUM_PARAM))
`define MAX_WAIT_CNT_WIDTH                 4
`define LOW2MED_MAX_CNT                    5
`define MED2HIGH_MAX_CNT                   5
`define HIGH2HHIGH_MAX_CNT                 5
`define LOW2HIGH_MAX_CNT                   10
`define MED2HHIGH_MAX_CNT                  10
`define LOW2HHIGH_MAX_CNT                  15
`define RETRY_ACKQ_DATA_DEPTH              15
`define RETRY_ACKQ_DATA_WIDTH              `CHIE_REQ_FLIT_SRCID_WIDTH+`CHIE_REQ_FLIT_TXNID_WIDTH+`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_TRACETAG_WIDTH+`CHIE_REQ_FLIT_PCRDTYPE_WIDTH
`define RETRY_ACKQ_DATA_RANGE              `CHIE_REQ_FLIT_SRCID_WIDTH+`CHIE_REQ_FLIT_TXNID_WIDTH+`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_TRACETAG_WIDTH+`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0
`define RETRY_ACKQ_SRCID_RANGE             `CHIE_REQ_FLIT_SRCID_WIDTH-1:0
`define RETRY_ACKQ_TXNID_RANGE             `CHIE_REQ_FLIT_TXNID_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH-1:`CHIE_REQ_FLIT_SRCID_WIDTH
`define RETRY_ACKQ_QOS_RANGE               `CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_TXNID_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH-1:`CHIE_REQ_FLIT_TXNID_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH
`define RETRY_ACKQ_TRACE_RANGE             `CHIE_REQ_FLIT_TRACETAG_WIDTH+`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_TXNID_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH-1:`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_TXNID_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH
`define RETRY_ACKQ_PCRDTYPE_RANGE          `CHIE_REQ_FLIT_PCRDTYPE_WIDTH+`CHIE_REQ_FLIT_TRACETAG_WIDTH+`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_TXNID_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH-1:`CHIE_REQ_FLIT_TRACETAG_WIDTH+`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_TXNID_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH
`define PCRDGRANTQ_DATA_DEPTH              `MSHR_ENTRIES_NUM-1
`define PCRDGRANTQ_DATA_WIDTH              `CHIE_REQ_FLIT_SRCID_WIDTH+`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_PCRDTYPE_WIDTH
`define PCRDGRANTQ_DATA_RANGE              `CHIE_REQ_FLIT_SRCID_WIDTH+`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0
`define PCRDGRANTQ_SRCID_RANGE             `CHIE_REQ_FLIT_SRCID_WIDTH-1:0
`define PCRDGRANTQ_QOS_RANGE               `CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH-1:`CHIE_REQ_FLIT_SRCID_WIDTH
`define PCRDGRANTQ_PCRDTYPE_RANGE          `CHIE_REQ_FLIT_PCRDTYPE_WIDTH+`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH-1:`CHIE_REQ_FLIT_QOS_WIDTH+`CHIE_REQ_FLIT_SRCID_WIDTH

//hnf_mshr_ctl
`define SF_EVICT                           'h40
`define MSHR_PCRDTYPE_NUMS                  16
`define MSHR_SNPCNT_WIDTH                   ((HNF_MSHR_RNF_NUM_PARAM <= 7)? 3 : (HNF_MSHR_RNF_NUM_PARAM <= 15)? 4 : (HNF_MSHR_RNF_NUM_PARAM <= 31)? 5 : (HNF_MSHR_RNF_NUM_PARAM <= 63)? 6 : 7)

`define TXDAT_BUFFER_NUM                    2
`define TXDAT_BUFFER_RANGE                  1

`endif
