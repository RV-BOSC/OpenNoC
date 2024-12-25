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

`ifndef RNI_DEFINES_V
`define RNI_DEFINES_V
//rni_link_ctl
`define LL_STATE_WIDTH                  2
`define LL_STOP                         2'b00
`define LL_ACTIVATE                     2'b10
`define LL_RUN                          2'b11
`define LL_DEACTIVATE                   2'b01
//rni_misc
`define PCRDGRANT_PKT_WIDTH             ({`CHIE_RSP_FLIT_PCRDTYPE_WIDTH+`CHIE_RSP_FLIT_SRCID_WIDTH+`CHIE_RSP_FLIT_TGTID_WIDTH})
`define PCRDGRANT_PKT_TGTID_RANGE       `CHIE_RSP_FLIT_TGTID_WIDTH-1:0
`define PCRDGRANT_PKT_SRCID_RANGE       `CHIE_RSP_FLIT_SRCID_WIDTH+`CHIE_RSP_FLIT_TGTID_WIDTH-1:`CHIE_RSP_FLIT_TGTID_WIDTH
`define PCRDGRANT_PKT_PCRDTYPE_RANGE    `CHIE_RSP_FLIT_PCRDTYPE_WIDTH+`CHIE_RSP_FLIT_SRCID_WIDTH+`CHIE_RSP_FLIT_TGTID_WIDTH-1:`CHIE_RSP_FLIT_SRCID_WIDTH+`CHIE_RSP_FLIT_TGTID_WIDTH
`define L_DISABLE_CNT_WIDTH             3
`define L_DISABLE_H_MAX_VAL             2
//rni_ctl
`define RNI_AW_ENTRIES_WIDTH            ((RNI_AW_ENTRIES_NUM_PARAM == 1)? 1 : $clog2(RNI_AW_ENTRIES_NUM_PARAM))
`define RNI_AR_ENTRIES_WIDTH            ((RNI_AR_ENTRIES_NUM_PARAM == 1)? 1 : $clog2(RNI_AR_ENTRIES_NUM_PARAM))
`define RNI_DMASK_CT_RANGE              3:0
`define RNI_DMASK_CT_LSB                0
`define RNI_DMASK_CT_MSB                3
`define RNI_DMASK_CT_WIDTH              4
`define RNI_DMASK_PD_RANGE              7:4
`define RNI_DMASK_PD_LSB                4
`define RNI_DMASK_PD_MSB                7
`define RNI_DMASK_PD_WIDTH              4
`define RNI_DMASK_LS_RANGE              11:8
`define RNI_DMASK_LS_LSB                8
`define RNI_DMASK_LS_MSB                11
`define RNI_DMASK_LS_WIDTH              4
`define RNI_DMASK_RV_RANGE              15:12
`define RNI_DMASK_RV_LSB                12
`define RNI_DMASK_RV_MSB                15
`define RNI_DMASK_RV_WIDTH              4
`define RNI_BC_WIDTH                    4
`define RNI_BCVEC_WIDTH                 16
`define RNI_DMASK_WIDTH                 16
`define AXI_4KB_WIDTH                   12
`define AW_FIFO_CNT_WIDTH               2
`define AW_FIFO_CNT_NUM                 2
//rni_wr_buffer
`define WD_FIFO_ENTRIES_WIDTH           `AXI4_W_WIDTH
`define WD_FIFO_ENTRIES_DEPTH           4
`define AW_REQ_FIFO_ENTRIES_WIDTH       (RNI_AW_ENTRIES_NUM_PARAM + 4 + 4 + 16)
`define AW_REQ_FIFO_ENTRIES_DEPTH       6
`define BRSP_FIFO_ENTRIES_WIDTH         (`AXI4_BID_WIDTH + `CHIE_RSP_FLIT_RESPERR_WIDTH + 1)
`define BRSP_FIFO_ENTRIES_DEPTH         2
`define BRSP_FIFO_LAST_RANGE            0:0
`define BRSP_FIFO_RESPERR_RANGE         `CHIE_RSP_FLIT_RESPERR_WIDTH + 1 - 1:1
`define BRSP_FIFO_AXID_RANGE            `AXI4_BID_WIDTH + `CHIE_RSP_FLIT_RESPERR_WIDTH + 1 - 1:`CHIE_RSP_FLIT_RESPERR_WIDTH + 1
`define WR_BUFFER_DATA_BANK_NUM         4
`define WR_BUFFER_DATA_BANK_WIDTH       AXI4_AXDATA_WIDTH_PARAM
//rni_rd_buffer
`define RNI_RD_BANK_NUM                 4
`define RNI_RD_BANK_ADDR_WIDTH          `RNI_AR_ENTRIES_WIDTH
`define RNI_RD_BANK_DATA_WIDTH          128
`define RNI_RP_FIFO_DEPTH               2
`define RNI_RP_FIFO_WIDTH               (`AXI4_R_WIDTH+`RNI_BC_WIDTH)
`define RNI_RD_FIFO_DEPTH               2
`define RNI_RD_FIFO_WIDTH               `AXI4_R_WIDTH
//cacheline
`define L3_CACHELINE_OFFSET             6

`endif
