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
*    Hongyu Gao <gaohongyu@bosc.ac.cn>
*    Li Zhao <lizhao@bosc.ac.cn>
*    Nana Cai <cainana@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*    Guo Bing <guobing@bosc.ac.cn>
*    Jianxing Wang <wangjianxing@bosc.ac.cn> 
*/

`timescale 1ns/1ns
`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module tb_hnf `HNF_PARAM;

// hnf Parameters
parameter PERIOD  = 10;

//`define print_info
`define tb_hnf

`define WR_SF_STATUS  7'b1110000
`define WR_HN_STATUS  7'b1110001
`define WR_ADDR       7'b1110010
`define WR_HNF        7'b1110011
`define WR_SNI        7'b1110100

`define RD_SF_STATUS  7'b1110101
`define RD_HN_STATUS  7'b1110110
`define RD_ADDR       7'b1110111
`define RD_HNF        7'b1111000
`define RD_SNI        7'b1111001

`define RD_STATUS     7'b1110010
`define RD_DATA       7'b1110011

`define RXREQ_RN0     7'b0000000
`define RXREQ_RN1     7'b0000100

`define RXRSP_RN0     7'b0010000
`define RXRSP_RN1     7'b0010100
`define RXRSP_SN      7'b0011000

`define RXDAT1_RN0    7'b0100000
`define RXDAT2_RN0    7'b0100001
`define RXDAT1_RN1    7'b0100100
`define RXDAT2_RN1    7'b0100101
`define RXDAT1_SN     7'b0101000
`define RXDAT2_SN     7'b0101001

`define TXREQ_SN      7'b0111000

`define TXRSP_RN0     7'b1000000
`define TXRSP_RN1     7'b1000100
`define TXRSP_SN      7'b1001000

`define TXDAT1_RN0    7'b1010000
`define TXDAT2_RN0    7'b1010001
`define TXDAT1_RN1    7'b1010100
`define TXDAT2_RN1    7'b1010101
`define TXDAT1_SN     7'b1011000
`define TXDAT2_SN     7'b1011001

`define TXSNP_RN0     7'b1100000
`define TXSNP_RN1     7'b1100100

`define SNI_RSP_RN0   7'b1111100
`define RN0_DAT1_SNI  7'b1111101
`define RN0_DAT2_SNI  7'b1111110

`define SNI_DAT1_RN0  7'b1111010
`define SNI_DAT2_RN0  7'b1111011

`define LAST_LINE     7'b1111111

// hnf Inputs
reg                                     CLK;
reg                                     RST;
reg                                     RXREQFLITV;
reg [`CHIE_REQ_FLIT_RANGE]              RXREQFLIT;
reg                                     RXREQFLITPEND;
reg                                     RXRSPFLITV;
reg [`CHIE_RSP_FLIT_RANGE]              RXRSPFLIT;
reg                                     RXRSPFLITPEND;
reg                                     RXDATFLITV;
reg [`CHIE_DAT_FLIT_RANGE]              RXDATFLIT;
reg                                     RXDATFLITPEND;
reg                                     TXREQLCRDV;
reg                                     TXRSPLCRDV;
reg                                     TXSNPLCRDV;
reg                                     TXDATLCRDV;

// hnf Outputs
wire                                    RXREQLCRDV;
wire                                    RXRSPLCRDV;
wire                                    RXDATLCRDV;
wire                                    TXREQFLITV;
wire [`CHIE_REQ_FLIT_RANGE]             TXREQFLIT;
wire                                    TXREQFLITPEND;
wire                                    TXRSPFLITV;
wire [`CHIE_RSP_FLIT_RANGE]             TXRSPFLIT;
wire                                    TXRSPFLITPEND;
wire                                    TXSNPFLITV;
wire [`HNF_SNP_FLIT_RANGE]              TXSNPFLIT;
wire                                    TXSNPFLITPEND;
wire                                    TXDATFLITV;
wire [`CHIE_DAT_FLIT_RANGE]             TXDATFLIT;
wire                                    TXDATFLITPEND;

reg [6:0]                               typ [31:0];
reg [511:0]                             flit[31:0];
reg                                     dbg_sn_wr_en;
reg                                     dbg_sn_rd_en;
reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]     dbg_sn_addr;
reg [`CHIE_DAT_FLIT_WIDTH*2-1:0]        dbg_sn_wr_data;
reg                                     dbg_l3_valid_q;
reg [`LOC_INDEX_WIDTH-1:0]              dbg_l3_index_q;
reg [`LOC_WAY_NUM-1:0]                  dbg_l3_rd_ways_q;
reg [`CACHE_LINE_WIDTH-1:0]             dbg_l3_wr_data_q;
reg [`LOC_WAY_NUM-1:0]                  dbg_l3_wr_ways_q;
reg [`CACHE_LINE_WIDTH-1:0]             dbg_l3_rd_data_q;
reg                                     dbg_loc_valid_q;
reg [`LOC_INDEX_WIDTH-1:0]              dbg_loc_index_q;
reg                                     dbg_loc_rd_en_q;
reg [`LOC_WAY_NUM-1:0]                  dbg_loc_wr_ways_q;
reg [`LOC_CLINE_WIDTH-1:0]              dbg_loc_wr_cline_q;
reg                                     dbg_sf_valid_q;
reg [`SF_INDEX_WIDTH-1:0]               dbg_sf_index_q;
reg                                     dbg_sf_rd_en_q;
reg [`SF_WAY_NUM-1:0]                   dbg_sf_wr_ways_q;
reg [`SF_CLINE_WIDTH-1:0]               dbg_sf_wr_cline_q;
reg                                     dbg_lru_valid_q;
reg [`LOC_INDEX_WIDTH-1:0]              dbg_lru_index_q;
reg                                     dbg_lru_rd_en_q;
reg                                     dbg_lru_wr_en_q;
reg [`LRU_CLINE_WIDTH-1:0]              dbg_lru_wr_data_q;
reg [`LOC_CLINE_WIDTH*`LOC_WAY_NUM-1:0] dbg_loc_rd_clines_q;
reg [`SF_CLINE_WIDTH*`SF_WAY_NUM-1:0]   dbg_sf_rd_clines_q;
reg [`LRU_CLINE_WIDTH-1:0]              dbg_lru_rd_data_q;
reg [2:0]                               notify_reg;
reg                                     sn_rxrspflitv;
reg [`CHIE_RSP_FLIT_RANGE]              sn_rxrspflit;
reg                                     sn_rxdatflitv;
reg [`CHIE_DAT_FLIT_RANGE]              sn_rxdatflit;
reg                                     rn_rxrspflitv;
reg [`CHIE_RSP_FLIT_RANGE]              rn_rxrspflit;
reg                                     rn_rxdatflitv;
reg [`CHIE_DAT_FLIT_RANGE]              rn_rxdatflit;
reg                                     sn_txdatflitv;
reg [`CHIE_DAT_FLIT_RANGE]              sn_txdatflit;
reg                                     sn_txdatflitv_tmp;
reg [`CHIE_DAT_FLIT_RANGE]              sn_txdatflit_tmp;
reg [3:0]                               wr_rn_status;
reg [1:0]                               wr_hn_status;
reg [43:0]                              wr_addr;
reg [511:0]                             wr_hnf;
reg [511:0]                             wr_sni;
reg [3:0]                               rd_rn_status;
reg [1:0]                               rd_hn_status;
reg [43:0]                              rd_addr;
reg [511:0]                             rd_hnf;
reg [511:0]                             rd_sni;
reg [`CHIE_REQ_FLIT_RANGE]              rxreqflit;
reg [`CHIE_RSP_FLIT_RANGE]              rxrspflit;
reg [`CHIE_DAT_FLIT_RANGE]              rxdatflit;
reg [`CHIE_REQ_FLIT_RANGE]              txreqflit;
reg [`CHIE_RSP_FLIT_RANGE]              txrspflit;
reg [`HNF_SNP_FLIT_RANGE]               txsnpflit;
reg [`CHIE_DAT_FLIT_RANGE]              txdatflit;
reg [`CHIE_RSP_FLIT_RANGE]              g_rxrspflit;
reg [`CHIE_DAT_FLIT_RANGE]              g_txdatflit;
reg [`CHIE_DAT_FLIT_RANGE]              g_rxdatflit;
wire [`CHIE_DAT_FLIT_WIDTH*2-1:0]       dbg_sn_rd_data;

integer                                 fd;
integer                                 code;
integer                                 i;
integer                                 j;
integer                                 k;
integer                                 p;

string test_case_files_list[] = {
    /*001*/"./case/WriteNoSnpFull/I_I_I_Excl_Order00_NonCompAck_WriteNoSnpFull_I_I_I_fail.txt",
    /*002*/"./case/WriteNoSnpFull/I_I_I_Excl_Order10_NonCompAck_WriteNoSnpFull_I_I_I_success.txt",
    /*003*/"./case/WriteNoSnpFull/I_I_I_NonExcl_Order00_NonCompAck_WriteNoSnpFull_I_I_I.txt",
    /*004*/"./case/WriteNoSnpFull/I_I_I_NonExcl_Order10_CompAck_WriteNoSnpFull_I_I_I.txt",
    /*005*/"./case/WriteNoSnpFull/I_I_I_NonExcl_Order10_NonCompAck_WriteNoSnpFull_I_I_I.txt",
    /*006*/"./case/WriteNoSnpPtl/I_I_I_Excl_Order00_NonCompAck_WriteNoSnpPtl_I_I_I_fail.txt",
    /*007*/"./case/WriteNoSnpPtl/I_I_I_Excl_Order10_NonCompAck_WriteNoSnpPtl_I_I_I_success.txt",
    /*008*/"./case/WriteNoSnpPtl/I_I_I_NonExcl_Order00_NonCompAck_WriteNoSnpPtl_I_I_I.txt",
    /*009*/"./case/WriteNoSnpPtl/I_I_I_NonExcl_Order10_CompAck_WriteNoSnpPtl_I_I_I.txt",
    /*010*/"./case/WriteNoSnpPtl/I_I_I_NonExcl_Order10_NonCompAck_WriteNoSnpPtl_I_I_I.txt",
    /*011*/"./case/CleanUnique/SC_SC_C_Excl_Order00_CompAck_CleanUnique_U_I_I_success.txt",
    /*012*/"./case/CleanUnique/SC_I_I_Excl_Order00_CompAck_CleanUnique_SC_I_I_fail.txt",
    /*013*/"./case/CleanUnique/SC_I_I_NonExcl_Order00_CompAck_CleanUnique_U_I_I.txt",
    /*014*/"./case/CleanUnique/SC_I_D_NonExcl_Order00_CompAck_CleanUnique_U_I_I.txt",
    /*015*/"./case/CleanUnique/I_U_I_NonExcl_Order00_CompAck_CleanUnique_I_U_I.txt",
    /*016*/"./case/CleanShared/I_I_I_SF_I_U_NonExcl_Order00_NonCompAck_CleanShared_I_U_I.txt",
    /*017*/"./case/CleanShared/SC_SC_D_NonExcl_Order00_NonCompAck_CleanShared_SC_SC_C.txt",
    /*018*/"./case/CleanShared/I_UD_I_NonExcl_Order00_NonCompAck_CleanShared_I_U_I.txt",
    /*019*/"./case/CleanShared/SC_SC_C_NonExcl_Order00_NonCompAck_CleanShared_SC_SC_C.txt",
    /*020*/"./case/CleanInvalid/I_SC_D_NonExcl_Order00_NonCompAck_CleanInvalid_I_I_I.txt",
    /*021*/"./case/CleanInvalid/I_UD_I_NonExcl_Order00_NonCompAck_CleanInvalid_I_I_I.txt",
    /*022*/"./case/Evict/U_I_I_NonExcl_Order00_NonCompAck_Evict_I_I_I.txt",
    /*023*/"./case/Evict/SC_SC_D_NonExcl_Order00_NonCompAck_Evict_I_SC_D.txt",
    /*024*/"./case/Evict/SC_SC_I_NonExcl_Order00_NonCompAck_Evict_I_SC_I.txt",
    /*025*/"./case/Evict/SC_I_D_NonExcl_Order00_NonCompAck_Evict_I_I_D.txt",
    /*026*/"./case/Evict/SC_I_I_NonExcl_Order00_NonCompAck_Evict_I_I_I.txt",
    /*027*/"./case/MakeUnique/SC_SC_D_NonExcl_Order00_CompAck_MakeUnique_U_I_I.txt",
    /*028*/"./case/MakeUnique/I_U_I_NonExcl_Order00_CompAck_MakeUnique_U_I_I.txt",
    /*029*/"./case/WriteCleanFull/SC_I_I_NonExcl_Order00_NonCompAck_WriteCleanFull_SC_I_I.txt",
    /*030*/"./case/WriteCleanFull/UC_I_I_NonExcl_Order00_NonCompAck_WriteCleanFull_U_I_I.txt",
    /*031*/"./case/WriteCleanFull/UD_I_I_NonExcl_Order00_NonCompAck_WriteCleanFull_U_I_I.txt",
    /*032*/"./case/WriteCleanFull/I_I_I_NonExcl_Order00_NonCompAck_WriteCleanFull_I_I_I.txt",
    /*033*/"./case/WriteEvictFull/SC_I_I_NonExcl_Order00_NonCompAck_WriteEvictFull_SC_I_I.txt",
    /*034*/"./case/WriteEvictFull/I_I_I_NonExcl_Order00_NonCompAck_WriteEvictFull_I_I_I.txt",
    /*035*/"./case/WriteEvictFull/UC_I_I_NonExcl_Order00_NonCompAck_WriteEvictFull_I_I_C.txt",
    /*036*/"./case/WriteUniqueFull/I_SC_I_NonExcl_Order10_NonCompAck_NonAllocate_WriteUniqueFull_I_I_I.txt",
    /*037*/"./case/WriteUniqueFull/I_SC_D_NonExcl_Order10_CompAck_NonAllocate_WriteUniqueFull_I_I_I.txt",
    /*038*/"./case/WriteUniqueFull/I_I_I_NonExcl_Order00_NonCompAck_NonAllocate_WriteUniqueFull_I_I_I.txt",
    /*039*/"./case/WriteUniqueFull/I_SC_D_NonExcl_Order10_CompAck_Allocate_WriteUniqueFull_I_I_D.txt",
    /*040*/"./case/WriteUniqueFull/I_SC_I_NonExcl_Order10_NonCompAck_Allocate_WriteUniqueFull_I_I_D.txt",
    /*041*/"./case/WriteUniquePtl/I_SC_I_NonExcl_Order10_NonCompAck_NonAllocate_WriteUniquePtl_I_I_I.txt",
    /*042*/"./case/WriteUniquePtl/I_I_I_NonExcl_Order00_NonCompAck_Allocate_WriteUniquePtl_I_I_C.txt",
    /*043*/"./case/WriteUniquePtl/I_U_I_NonExcl_Order00_NonCompAck_NonAllocate_WriteUniquePtl_I_I_I.txt",
    /*044*/"./case/WriteUniquePtl/I_SC_I_NonExcl_Order10_NonCompAck_Allocate_WriteUniquePtl_I_I_D.txt",
    /*045*/"./case/WriteUniquePtl/I_SC_D_NonExcl_Order10_CompAck_NonAllocate_WriteUniquePtl_I_I_I.txt",
    /*046*/"./case/WriteUniquePtl/I_SC_D_NonExcl_Order10_CompAck_Allocate_WriteUniquePtl_I_I_D.txt",
    /*047*/"./case/WriteUniquePtl/I_I_D_NonExcl_Order00_NonCompAck_Allocate_WriteUniquePtl_I_I_D.txt",
    /*048*/"./case/WriteUniquePtl/I_I_I_NonExcl_Order00_NonCompAck_NonAllocate_WriteUniquePtl_I_I_I.txt",
    /*049*/"./case/WriteUniquePtl/I_UD_I_NonExcl_Order10_CompAck_Allocate_WriteUniquePtl_I_I_D.txt",
    /*050*/"./case/WriteBackFull/UD_I_I_NonExcl_Order00_NonCompAck_Allocate_WriteBackFull_I_I_D.txt",
    /*051*/"./case/WriteBackFull/UC_I_I_NonExcl_Order00_NonCompAck_Allocate_WriteBackFull_I_I_C.txt",
    /*052*/"./case/WriteBackFull/UD_I_I_NonExcl_Order00_NonCompAck_NonAllocate_WriteBackFull_U_I_I.txt",
    /*053*/"./case/WriteBackFull/I_SC_I_NonExcl_Order00_NonCompAck_NonAllocate_WriteBackFull_I_SC_I.txt",
    /*054*/"./case/WriteBackFull/SC_SC_I_NonExcl_Order00_NonCompAck_NonAllocate_WriteBackFull_SC_SC_I.txt",
    /*055*/"./case/WriteBackFull/SC_I_I_NonExcl_Order00_NonCompAck_Allocate_WriteBackFull_SC_I_I.txt",
    /*056*/"./case/WriteBackFull/I_U_I_NonExcl_Order00_NonCompAck_Allocate_WriteBackFull_I_U_I.txt",
    /*057*/"./case/WriteBackFull/UC_I_I_NonExcl_Order00_NonCompAck_NonAllocate_WriteBackFull_U_I_I.txt",
    /*058*/"./case/ReadNoSnp/I_I_I_Excl_Order00_CompAck_ReadNoSnp_I_I_I.txt",
    /*059*/"./case/ReadNoSnp/I_I_I_Excl_Order00_NonCompAck_ReadNoSnp_I_I_I.txt",
    /*060*/"./case/ReadNoSnp/I_I_I_Excl_Order10_CompAck_ReadNoSnp_I_I_I.txt",
    /*061*/"./case/ReadNoSnp/I_I_I_Excl_Order10_NonCompAck_ReadNoSnp_I_I_I.txt",
    /*062*/"./case/ReadNoSnp/I_I_I_NonExcl_Order00_CompAck_ReadNoSnp_I_I_I.txt",
    /*063*/"./case/ReadNoSnp/I_I_I_NonExcl_Order00_NonCompAck_ReadNoSnp_I_I_I.txt",
    /*064*/"./case/ReadNoSnp/I_I_I_NonExcl_Order10_CompAck_ReadNoSnp_I_I_I.txt",
    /*065*/"./case/ReadNoSnp/I_I_I_NonExcl_Order10_NonCompAck_ReadNoSnp_I_I_I.txt",
    /*066*/"./case/ReadOnce/I_I_I_SF_I_U_NonExcl_Order10_CompAck_ReadOnce_I_I_I.txt",
    /*067*/"./case/ReadOnce/I_I_I_NonExcl_Order00_CompAck_ReadOnce_I_I_I.txt",
    /*068*/"./case/ReadOnce/I_SC_I_NonExcl_Order00_CompAck_ReadOnce_I_SC_I.txt",
    /*069*/"./case/ReadOnce/I_UC_I_NonExcl_Order00_NonCompAck_ReadOnce_I_U_I.txt",
    /*070*/"./case/ReadOnce/I_SC_I_NonExcl_Order00_NonCompAck_ReadOnce_I_SC_I.txt",
    /*071*/"./case/ReadOnce/I_I_I_SF_I_U_NonExcl_Order10_NonCompAck_ReadOnce_I_I_I.txt",
    /*072*/"./case/ReadOnce/I_SC_I_NonExcl_Order10_NonCompAck_ReadOnce_I_SC_I.txt",
    /*073*/"./case/ReadOnce/I_UD_I_NonExcl_Order00_NonCompAck_ReadOnce_I_U_I.txt",
    /*074*/"./case/ReadOnce/I_I_I_SF_I_SC_NonExcl_Order10_NonCompAck_ReadOnce_I_I_I.txt",
    /*075*/"./case/ReadOnce/I_I_I_SF_I_U_NonExcl_Order00_CompAck_ReadOnce_I_I_I.txt",
    /*076*/"./case/ReadOnce/I_I_D_NonExcl_Order10_CompAck_ReadOnce_I_I_D.txt",
    /*077*/"./case/ReadOnce/I_UC_I_NonExcl_Order10_NonCompAck_ReadOnce_I_U_I.txt",
    /*078*/"./case/ReadOnce/I_I_I_SF_I_U_NonExcl_Order00_NonCompAck_ReadOnce_I_I_I.txt",
    /*079*/"./case/ReadOnce/I_I_I_NonExcl_Order10_NonCompAck_ReadOnce_I_I_I.txt",
    /*080*/"./case/ReadOnce/I_I_I_SF_I_SC_NonExcl_Order10_CompAck_ReadOnce_I_I_I.txt",
    /*081*/"./case/ReadOnce/I_SC_C_NonExcl_Order00_NonCompAck_ReadOnce_I_SC_C.txt",
    /*082*/"./case/ReadOnce/I_I_I_SF_I_SC_NonExcl_Order00_CompAck_ReadOnce_I_I_I.txt",
    /*083*/"./case/ReadOnce/I_SC_I_NonExcl_Order10_CompAck_ReadOnce_I_SC_I.txt",
    /*084*/"./case/ReadOnce/I_I_I_NonExcl_Order10_CompAck_ReadOnce_I_I_I.txt",
    /*085*/"./case/ReadOnce/I_UC_I_NonExcl_Order10_CompAck_ReadOnce_I_U_I.txt",
    /*086*/"./case/ReadOnce/I_UC_I_NonExcl_Order00_CompAck_ReadOnce_I_U_I.txt",
    /*087*/"./case/ReadOnce/I_UD_I_NonExcl_Order10_CompAck_ReadOnce_I_U_I.txt",
    /*088*/"./case/ReadOnce/I_UD_I_NonExcl_Order10_NonCompAck_ReadOnce_I_U_I.txt",
    /*089*/"./case/ReadOnce/I_UD_I_NonExcl_Order00_CompAck_ReadOnce_I_U_I.txt",
    /*090*/"./case/ReadOnce/I_I_I_NonExcl_Order00_NonCompAck_ReadOnce_I_I_I.txt",
    /*091*/"./case/ReadOnce/I_I_I_SF_I_SC_NonExcl_Order00_NonCompAck_ReadOnce_I_I_I.txt",
    /*092*/"./case/ReadNotSharedDirty/I_I_D_Excl_Order00_CompAck_ReadNotSharedDirty_U_I_I.txt",
    /*093*/"./case/ReadNotSharedDirty/I_SC_C_NonExcl_Order00_CompAck_ReadNotSharedDirty_SC_SC_C.txt",
    /*094*/"./case/ReadNotSharedDirty/I_SC_I_Excl_Order00_CompAck_ReadNotSharedDirty_SC_SC_C.txt",
    /*095*/"./case/ReadNotSharedDirty/I_I_I_NonExcl_Order00_CompAck_ReadNotSharedDirty_U_I_I.txt",
    /*096*/"./case/ReadNotSharedDirty/I_I_C_Excl_Order00_CompAck_ReadNotSharedDirty_U_I_I.txt",
    /*097*/"./case/ReadNotSharedDirty/I_I_I_SF_U_I_NonExcl_Order00_CompAck_ReadNotSharedDirty_U_I_I.txt",
    /*098*/"./case/ReadNotSharedDirty/I_I_I_SF_SC_I_Excl_Order00_CompAck_ReadNotSharedDirty_U_I_I.txt",
    /*099*/"./case/ReadNotSharedDirty/I_SC_I_NonExcl_Order00_CompAck_ReadNotSharedDirty_SC_SC_C.txt",
    /*100*/"./case/ReadNotSharedDirty/I_SC_C_Excl_Order00_CompAck_ReadNotSharedDirty_SC_SC_C.txt",
    /*101*/"./case/ReadNotSharedDirty/I_I_I_SF_I_U_NonExcl_Order00_CompAck_ReadNotSharedDirty_SC_SC_C.txt",
    /*102*/"./case/ReadNotSharedDirty/I_U_I_Excl_Order00_CompAck_ReadNotSharedDirty_SC_SC_C.txt",
    /*103*/"./case/ReadNotSharedDirty/I_I_C_NonExcl_Order00_CompAck_ReadNotSharedDirty_U_I_I.txt",
    /*104*/"./case/ReadNotSharedDirty/I_UD_I_NonExcl_Order00_CompAck_ReadNotSharedDirty_SC_SC_D.txt",
    /*105*/"./case/ReadNotSharedDirty/I_U_I_NonExcl_Order00_CompAck_ReadNotSharedDirty_SC_SC_C.txt",
    /*106*/"./case/ReadNotSharedDirty/I_I_I_SF_I_SC_Excl_Order00_CompAck_ReadNotSharedDirty_SC_SC_C.txt",
    /*107*/"./case/ReadNotSharedDirty/I_I_D_NonExcl_Order00_CompAck_ReadNotSharedDirty_U_I_I.txt",
    /*108*/"./case/ReadNotSharedDirty/I_UD_I_Excl_Order00_CompAck_ReadNotSharedDirty_SC_SC_D.txt",
    /*109*/"./case/ReadClean/I_I_D_NonExcl_Order00_CompAck_ReadClean_U_I_I.txt",
    /*110*/"./case/ReadClean/I_I_I_SF_SC_I_Excl_Order00_CompAck_ReadClean_U_I_I.txt",
    /*111*/"./case/ReadClean/I_U_I_NonExcl_Order00_CompAck_ReadClean_SC_SC_C.txt",
    /*112*/"./case/ReadClean/I_I_C_Excl_Order00_CompAck_ReadClean_U_I_I.txt",
    /*113*/"./case/ReadClean/I_I_C_NonExcl_Order00_CompAck_ReadClean_U_I_I.txt",
    /*114*/"./case/ReadClean/I_I_I_SF_U_I_NonExcl_Order00_CompAck_ReadClean_U_I_I.txt",
    /*115*/"./case/ReadClean/I_UD_I_Excl_Order00_CompAck_ReadClean_SC_SC_D.txt",
    /*116*/"./case/ReadClean/I_I_D_Excl_Order00_CompAck_ReadClean_U_I_I.txt",
    /*117*/"./case/ReadClean/I_SC_C_NonExcl_Order00_CompAck_ReadClean_SC_SC_C.txt",
    /*118*/"./case/ReadClean/I_U_I_Excl_Order00_CompAck_ReadClean_SC_SC_C.txt",
    /*119*/"./case/ReadClean/I_I_I_SF_I_SC_Excl_Order00_CompAck_ReadClean_SC_SC_C.txt",
    /*120*/"./case/ReadClean/I_UD_I_NonExcl_Order00_CompAck_ReadClean_SC_SC_D.txt",
    /*121*/"./case/ReadClean/I_I_I_SF_I_U_NonExcl_Order00_CompAck_ReadClean_SC_SC_C.txt",
    /*122*/"./case/ReadClean/I_SC_C_Excl_Order00_CompAck_ReadClean_SC_SC_C.txt",
    /*123*/"./case/ReadClean/I_SC_I_NonExcl_Order00_CompAck_ReadClean_SC_SC_C.txt",
    /*124*/"./case/ReadClean/I_SC_I_Excl_Order00_CompAck_ReadClean_SC_SC_C.txt",
    /*125*/"./case/ReadClean/I_I_I_NonExcl_Order00_CompAck_ReadClean_U_I_I.txt",
    /*126*/"./case/ReadUnique/I_I_I_SF_I_U_NonExcl_Order00_CompAck_ReadUnique_U_I_I.txt",
    /*127*/"./case/ReadUnique/I_I_I_SF_U_I_NonExcl_Order00_CompAck_ReadUnique_U_I_I.txt",
    /*128*/"./case/ReadUnique/I_UD_I_NonExcl_Order00_CompAck_ReadUnique_U_I_I.txt",
    /*129*/"./case/ReadUnique/I_SC_D_NonExcl_Order00_CompAck_ReadUnique_U_I_I.txt",
    /*130*/"./case/ReadUnique/I_I_I_NonExcl_Order00_CompAck_ReadUnique_U_I_I.txt",
    /*131*/"./case/ReadUnique/I_U_I_NonExcl_Order00_CompAck_ReadUnique_U_I_I.txt",
    /*132*/"./case/ReadUnique/I_I_I_SF_I_SC_NonExcl_Order00_CompAck_ReadUnique_U_I_I.txt",
    /*133*/"./case/ReadUnique/I_SC_I_NonExcl_Order00_CompAck_ReadUnique_U_I_I.txt",
    /*134*/"./case/Mixed/Test_01.txt",
    /*135*/"./case/Mixed/Test_02.txt",
    /*136*/"./case/Mixed/Test_03.txt"
  };

// read file
initial 
begin
  $display("\n/***************** Begin ******************/");
  for (k = 0; k < test_case_files_list.size(); k++) begin
    j = 0;
    p = 0;
    fd = $fopen(test_case_files_list[k], "r");
    if(!fd)
    begin
        $display("Text file NOT FOUND");
    end
    else
    begin
      i=0;
      while(i<50)
      begin

        code = $fscanf(fd, "%b %b", typ[i], flit[i]);

        if(typ[i] == `WR_SF_STATUS)
          wr_rn_status = flit[i][3:0];
        else if(typ[i] == `WR_HN_STATUS)
          wr_hn_status = flit[i][1:0];
        else if(typ[i] == `WR_ADDR)
          wr_addr = {12'b000000000000,flit[i][31:0]};
        else if(typ[i] == `WR_HNF)
          wr_hnf = {{(480){1'b0}},{flit[i][31:0]}};
        else if(typ[i] == `WR_SNI)
          wr_sni = {{(480){1'b0}},{flit[i][31:0]}};
        else if(typ[i] == `RD_SF_STATUS)
          rd_rn_status = flit[i][3:0];
        else if(typ[i] == `RD_HN_STATUS)
          rd_hn_status = flit[i][1:0];
        else if(typ[i] == `RD_ADDR) 
          rd_addr = {12'b000000000000,flit[i][31:0]};
        else if(typ[i] == `RD_HNF)
          rd_hnf = {{(480){1'b0}},{flit[i][31:0]}};
        else if(typ[i] == `RD_SNI)
          rd_sni = {{(480){1'b0}},{flit[i][31:0]}};
        else;
        if(typ[i] == `LAST_LINE)
        begin
          break;
        end
        i = i + 1;
      end
    end
    $fclose(fd);
    while(!p)
    begin
      @(posedge CLK);
    end
  end
  $display("Done!");
  $display("\n********* Report Stage *********\n");
  $display("Total test cases: %d\n",test_case_files_list.size());
  $display("All tests passed\n");
  $display("/****************** End *******************/\n");
  $finish;
end

// write and read sf status
initial
begin
  dbg_sf_valid_q    <= 1'b0;
  dbg_lru_valid_q   <= 1'b0;
  dbg_loc_valid_q   <= 1'b0;
  dbg_l3_valid_q    <= 1'b0;
  @(negedge RST);
  $display("Initializing SRAMs, Please wait...");
  while (notify_reg != 7)
    @(posedge CLK);
  $display("Done!\n");
  $display("Running Tests...");
  forever begin
    if(typ[j] == `WR_SF_STATUS)
    begin
      `ifdef print_info
        $display("\n****** Initializing Stage ******");
      `endif
      dbg_sf_valid_q    <= 1'b1;
      dbg_sf_index_q    <= 'd0;
      dbg_sf_wr_ways_q  <= {{(`SF_WAY_NUM-1){1'b0}},1'b1};
      dbg_sf_wr_cline_q <= {{(`SF_CLINE_WIDTH-4){1'b0}},wr_rn_status};
      j <= j + 1;
      `ifdef print_info
        $display("SF status complete !");
      `endif
      @(posedge CLK);
      dbg_sf_valid_q    <= 1'b0;
      dbg_sf_index_q    <= 'd0;
      dbg_sf_wr_ways_q  <= 'd0;
    end

    if(typ[j] == `RD_SF_STATUS)
    begin
      repeat(15)@(posedge CLK); //wait for HN write data to sn if any
      `ifdef print_info
        $display("\n******* Comparing Stage *******");
      `endif
      dbg_sf_valid_q <= 1'b1;
      dbg_sf_index_q <= 'd0;
      dbg_sf_rd_en_q <= 'd1;
      @(posedge CLK);
      dbg_sf_valid_q <= 1'b0;
      dbg_sf_rd_en_q <= 'd0;
      dbg_sf_index_q <= 'd0;
  `ifdef HNF_DELAY_ONE_CYCLE
      @(posedge CLK);
      @(posedge CLK);
  `else
      @(posedge CLK);
  `endif
      if(dbg_sf_rd_clines_q[3:0] == rd_rn_status)
      begin
        j <= j + 1;
        `ifdef print_info
          $display("SF status match !");
        `endif
      end
      else begin
        $display("SF status NOT match");
        $display("SF status : %b",dbg_sf_rd_clines_q[3:0]);
        $error("Test case %d fail", (k+1));
        $finish;
      end
      @(posedge CLK);
    end

    @(posedge CLK);
  end
end

// write and read llc status
initial
begin
  @(negedge RST);
  forever
  begin

    if(typ[j] == `WR_HN_STATUS)
    begin
      dbg_loc_valid_q    <= 1'b1;
      dbg_loc_index_q    <= 'd0;
      dbg_loc_wr_ways_q  <= {{(`LOC_WAY_NUM-1){1'b0}},1'b1};
      dbg_loc_wr_cline_q <= {{(`LOC_CLINE_WIDTH-2){1'b0}},wr_hn_status};
      j <= j + 2; //skip wr_addr type
      `ifdef print_info
        $display("L3 status complete !");
      `endif
      @(posedge CLK);
      dbg_loc_valid_q    <= 1'b0;
      dbg_loc_index_q    <= 'd0;
      dbg_loc_wr_ways_q  <= 'd0;
    end

    if(typ[j] == `RD_HN_STATUS)
    begin
      dbg_loc_valid_q <= 1'b1;
      dbg_loc_index_q <= 'd0;
      dbg_loc_rd_en_q <= 'd1;
      @(posedge CLK);
      dbg_loc_valid_q <= 1'b0;
      dbg_loc_rd_en_q <= 'd0;
      dbg_loc_index_q <= 'd0;
  `ifdef HNF_DELAY_ONE_CYCLE
      @(posedge CLK);
      @(posedge CLK);
  `else
      @(posedge CLK);
  `endif
      if(dbg_loc_rd_clines_q[1:0] == rd_hn_status)
      begin
        j <= j + 2; //skip wr_addr type
      `ifdef print_info
        $display("L3 status match !");
      `endif
      end
      else begin
        $display("L3 status NOT match");
        $display("L3 status : %b",dbg_loc_rd_clines_q[1:0]);
        $error("Test case %d fail", (k+1));
        $finish;
      end
      @(posedge CLK);
    end

    @(posedge CLK);
  end
end

//write and read llc data
initial
begin
  @(negedge RST);
  forever
  begin
    
    if(typ[j] == `WR_HNF)
    begin
      dbg_l3_valid_q   <= 1'b1;
      dbg_l3_index_q   <= 'd0;
      dbg_l3_wr_ways_q <= {{(`LOC_WAY_NUM-1){1'b0}},1'b1};
      dbg_l3_wr_data_q <= wr_hnf;
      j <= j + 1;
      `ifdef print_info
        $display("L3 data   complete !");
      `endif
      @(posedge CLK);
      dbg_l3_valid_q   <= 1'b0;
      dbg_l3_wr_ways_q <= 'd0;
      dbg_l3_index_q   <= 'd0;
    end

    if(typ[j] == `RD_HNF)
    begin
      dbg_l3_valid_q   <= 1'b1;
      dbg_l3_index_q   <= 'd0;
      dbg_l3_rd_ways_q <= 'd1;
      @(posedge CLK);
      dbg_l3_valid_q   <= 1'b0;
      dbg_l3_index_q   <= 'd0;
      dbg_l3_rd_ways_q <= 'd0;
  `ifdef HNF_DELAY_ONE_CYCLE
      @(posedge CLK);
      @(posedge CLK);
  `else
      @(posedge CLK);
  `endif
      if(dbg_l3_rd_data_q == rd_hnf)
      begin
        j <= j + 1;
      `ifdef print_info
        $display("L3 data   match !");
      `endif
      end
      else begin
        $display("L3 data NOT match");
        $display("L3 data : %b",dbg_l3_rd_data_q);
        $error("Test case %d fail", (k+1));
        $finish;
      end
      @(posedge CLK);
    end

    @(posedge CLK);
  end
end

//write and read sn data
initial
begin
  @(negedge RST);
  forever
  begin

    if(typ[j] == `WR_SNI)
    begin
      dbg_sn_wr_en   <= 1'b1;
      dbg_sn_addr    <= wr_addr;
      dbg_sn_wr_data <= wr_sni;
      j <= j + 1;
      `ifdef print_info
        $display("SN data   complete !");
      `endif
      @(posedge CLK);
      dbg_sn_wr_en   <= 1'b0;
    end

    if(typ[j] == `RD_SNI)
    begin
      dbg_sn_rd_en   <= 1'b1;
      dbg_sn_addr    <= rd_addr;
      @(posedge CLK);
      dbg_sn_rd_en   <= 1'b0;
  `ifdef HNF_DELAY_ONE_CYCLE
      @(posedge CLK);
      @(posedge CLK);
  `else
      @(posedge CLK);
  `endif
      if(dbg_sn_rd_data == rd_sni)
      begin
        j <= j + 1;
        `ifdef print_info
          $display("SN data   match !");
        `endif
      end
      else begin
        $display("SN data NOT match");
        $display("SN data : %b",dbg_sn_rd_data);
        $error("Test case %d fail", (k+1));
        $finish;
      end
      @(posedge CLK);
    end

    @(posedge CLK);
  end
end

//lcrdv
initial
begin
    @(negedge RST);
    TXREQLCRDV <= 1'b1;
    TXRSPLCRDV <= 1'b1;
    TXSNPLCRDV <= 1'b1;
    TXDATLCRDV <= 1'b1;
    repeat(6) @(posedge CLK);
    TXREQLCRDV <= 1'b0;
    TXRSPLCRDV <= 1'b0;
    TXSNPLCRDV <= 1'b0;
    TXDATLCRDV <= 1'b0;
  forever begin
    if(TXREQFLITV == 1'b1)
    begin
      TXREQLCRDV <= 1'b1;
    end

    if(TXRSPFLITV == 1'b1)
    begin
      TXRSPLCRDV <= 1'b1;
    end

    if(TXSNPFLITV == 1'b1)
    begin
      TXSNPLCRDV <= 1'b1;
    end

    if(TXDATFLITV == 1'b1)
    begin
      TXDATLCRDV <= 1'b1;
    end
    @(posedge CLK);
    TXREQLCRDV <= 1'b0;
    TXRSPLCRDV <= 1'b0;
    TXSNPLCRDV <= 1'b0;
    TXDATLCRDV <= 1'b0;
  end
end

//clock
initial
begin
  CLK = 1'b0;
  forever #(PERIOD/2)  CLK=~CLK;
end

//reset
initial
begin
  RST = 1'b1;
  repeat(32) @(posedge CLK);
  RST = 1'b0;
end

//instantiation
hnf  u_hnf (
    //inputs
    .CLK                 (CLK                ),
    .RST                 (RST                ),
    .RXREQFLITV          (RXREQFLITV         ),
    .RXREQFLIT           (RXREQFLIT          ),
    .RXREQFLITPEND       (RXREQFLITPEND      ),
    .RXRSPFLITV          (RXRSPFLITV         ),
    .RXRSPFLIT           (RXRSPFLIT          ),
    .RXRSPFLITPEND       (RXRSPFLITPEND      ),
    .RXDATFLITV          (RXDATFLITV         ),
    .RXDATFLIT           (RXDATFLIT          ),
    .RXDATFLITPEND       (RXDATFLITPEND      ),
    .TXREQLCRDV          (TXREQLCRDV         ),
    .TXRSPLCRDV          (TXRSPLCRDV         ),
    .TXSNPLCRDV          (TXSNPLCRDV         ),
    .TXDATLCRDV          (TXDATLCRDV         ),
                
    //outputs            
    .RXREQLCRDV          (RXREQLCRDV         ),
    .RXRSPLCRDV          (RXRSPLCRDV         ),
    .RXDATLCRDV          (RXDATLCRDV         ),
    .TXREQFLITV          (TXREQFLITV         ),
    .TXREQFLIT           (TXREQFLIT          ),
    .TXREQFLITPEND       (TXREQFLITPEND      ),
    .TXRSPFLITV          (TXRSPFLITV         ),
    .TXRSPFLIT           (TXRSPFLIT          ),
    .TXRSPFLITPEND       (TXRSPFLITPEND      ),
    .TXSNPFLITV          (TXSNPFLITV         ),
    .TXSNPFLIT           (TXSNPFLIT          ),
    .TXSNPFLITPEND       (TXSNPFLITPEND      ),
    .TXDATFLITV          (TXDATFLITV         ),
    .TXDATFLIT           (TXDATFLIT          ),
    .TXDATFLITPEND       (TXDATFLITPEND      ),

    //debug signals
    .dbg_l3_valid_q      (dbg_l3_valid_q     ),
    .dbg_l3_index_q      (dbg_l3_index_q     ),
    .dbg_l3_rd_ways_q    (dbg_l3_rd_ways_q   ),
    .dbg_l3_wr_data_q    (dbg_l3_wr_data_q   ),
    .dbg_l3_wr_ways_q    (dbg_l3_wr_ways_q   ),
    .dbg_loc_valid_q     (dbg_loc_valid_q    ),
    .dbg_loc_index_q     (dbg_loc_index_q    ),
    .dbg_loc_rd_en_q     (dbg_loc_rd_en_q    ),
    .dbg_loc_wr_ways_q   (dbg_loc_wr_ways_q  ),
    .dbg_loc_wr_cline_q  (dbg_loc_wr_cline_q ),
    .dbg_sf_valid_q      (dbg_sf_valid_q     ),
    .dbg_sf_index_q      (dbg_sf_index_q     ),
    .dbg_sf_rd_en_q      (dbg_sf_rd_en_q     ),
    .dbg_sf_wr_ways_q    (dbg_sf_wr_ways_q   ),
    .dbg_sf_wr_cline_q   (dbg_sf_wr_cline_q  ),
    .dbg_l3_rd_data_q    (dbg_l3_rd_data_q   ),
    .dbg_loc_rd_clines_q (dbg_loc_rd_clines_q),
    .dbg_sf_rd_clines_q  (dbg_sf_rd_clines_q ),
    .dbg_lru_valid_q     (dbg_lru_valid_q    ),
    .dbg_lru_index_q     (dbg_lru_index_q    ),
    .dbg_lru_rd_en_q     (dbg_lru_rd_en_q    ),
    .dbg_lru_wr_en_q     (dbg_lru_wr_en_q    ),
    .dbg_lru_wr_data_q   (dbg_lru_wr_data_q  ),
    .dbg_lru_rd_data_q   (dbg_lru_rd_data_q  ),
    .notify_reg          (notify_reg         )
);

tb_snf u_tb_snf(
    .CLK                 (CLK                ),
    .RST                 (RST                ),
    .RXREQFLITV          (TXREQFLITV         ),
    .RXREQFLIT           (TXREQFLIT          ),
    .RXDATFLITV          (sn_txdatflitv      ),
    .RXDATFLIT           (sn_txdatflit       ),
    .TXRSPFLITV          (sn_rxrspflitv      ),
    .TXRSPFLIT           (sn_rxrspflit       ),
    .TXDATFLITV          (sn_rxdatflitv      ),
    .TXDATFLIT           (sn_rxdatflit       ),
    .dbg_sn_wr_en        (dbg_sn_wr_en       ),
    .dbg_sn_wr_data      (dbg_sn_wr_data     ),
    .dbg_sn_addr         (dbg_sn_addr        ),
    .dbg_sn_rd_en        (dbg_sn_rd_en       ),
    .dbg_sn_rd_data      (dbg_sn_rd_data     )
);

//HNF RXREQ CHANNEL
initial
begin
  RXREQFLITPEND <= 1'b1;
  RXRSPFLITPEND <= 1'b1;
  RXDATFLITPEND <= 1'b1;
  RXREQFLITV    <= 1'b0;
  RXREQFLIT     <= 'd0;
  @(negedge RST);
  forever
  begin
    if((typ[j] == `RXREQ_RN0))
    begin
      rxreqflit = flit[j][`CHIE_REQ_FLIT_RANGE];
      rxreqflit[`CHIE_REQ_FLIT_SRCID_RANGE] = `RN0_ID;
      rxreqflit[`CHIE_REQ_FLIT_TGTID_RANGE] = `HNF0_ID;
      RXREQFLIT  <= rxreqflit;
      RXREQFLITV <= 1'b1;
      j <= j+1;
      `ifdef print_info
        $display("\n****** Transaction Stage ******");
        $display("RN0 request sent");
      `endif
    end

    if((typ[j] == `RXREQ_RN1))
    begin
      rxreqflit = flit[j][`CHIE_REQ_FLIT_RANGE];
      rxreqflit[`CHIE_REQ_FLIT_SRCID_RANGE] = `RN1_ID;
      rxreqflit[`CHIE_REQ_FLIT_TGTID_RANGE] = `HNF0_ID;
      RXREQFLIT  <= rxreqflit;
      RXREQFLITV <= 1'b1;
      j <= j+1;
      `ifdef print_info
        $display("\n****** Transaction Stage ******");
        $display("RN1 request sent");
      `endif                               
    end
    @(posedge CLK);
    RXREQFLITV <= 1'b0;
  end
end

//HNF RXRSP CHANNEL
assign RXRSPFLITV = (sn_rxrspflitv & (sn_rxrspflit[`CHIE_RSP_FLIT_TGTID_RANGE] == `HNF0_ID))? sn_rxrspflitv:rn_rxrspflitv;
assign RXRSPFLIT  = (sn_rxrspflitv & (sn_rxrspflit[`CHIE_RSP_FLIT_TGTID_RANGE] == `HNF0_ID))? sn_rxrspflit:rn_rxrspflit;

initial
begin
  rn_rxrspflitv <= 1'b0;
  rn_rxrspflit  <= 'd0;
  @(negedge RST);
  forever
  begin
    if((typ[j] == `RXRSP_RN0))
    begin
      rxrspflit = flit[j][`CHIE_RSP_FLIT_RANGE];
      rxrspflit[`CHIE_RSP_FLIT_SRCID_RANGE] = `RN0_ID;
      rxrspflit[`CHIE_RSP_FLIT_TGTID_RANGE] = `HNF0_ID;
      rn_rxrspflit  <= rxrspflit;
      rn_rxrspflitv <= 1'b1;
      j <= j + 1;
      `ifdef print_info
        $display("RN0 response sent");
      `endif 
    end
    if((typ[j] == `RXRSP_RN1))
    begin
      rxrspflit = flit[j][`CHIE_RSP_FLIT_RANGE];
      rxrspflit[`CHIE_RSP_FLIT_SRCID_RANGE] = `RN1_ID;
      rxrspflit[`CHIE_RSP_FLIT_TGTID_RANGE] = `HNF0_ID;
      rn_rxrspflit  <= flit[j][`CHIE_RSP_FLIT_RANGE];
      rn_rxrspflitv <= 1'b1;
      j <= j + 1;
      `ifdef print_info
        $display("RN1 response sent");
      `endif 
    end
    @(posedge CLK);
    
    //resolve sn and rn sending rsp conflit, let rn rsp send 2 cycles
    if(sn_rxrspflitv & (sn_rxrspflit[`CHIE_RSP_FLIT_TGTID_RANGE] == `HNF0_ID))
    begin
    end
    else begin
      rn_rxrspflitv <= 1'b0;
    end
  end
end

//HNF RXDAT CHANNEL
assign RXDATFLIT = (sn_rxdatflitv & (sn_rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] == `HNF0_ID))? sn_rxdatflit:rn_rxdatflit;
assign RXDATFLITV = (sn_rxdatflitv & (sn_rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] == `HNF0_ID))? sn_rxdatflitv:rn_rxdatflitv;

initial
begin
  rn_rxdatflitv <= 1'b0;
  rn_rxdatflit  <= 'd0;
  @(negedge RST);
  forever
  begin
    if(typ[j] == `RXDAT1_RN0)
    begin
      rxdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
      rxdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `RN0_ID;
      rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `HNF0_ID;
      rn_rxdatflitv <= 1'b1;
      rn_rxdatflit  <= rxdatflit;
      j<=j+1;
      `ifdef print_info
        $display("RN0 sent data0");
      `endif 
    end
      
    if(typ[j] == `RXDAT1_RN1)
    begin
      rxdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
      rxdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `RN1_ID;
      rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `HNF0_ID;
      rn_rxdatflitv <= 1'b1;
      rn_rxdatflit  <= rxdatflit;
      j<=j+1;
      `ifdef print_info
        $display("RN1 sent data0");
      `endif 
    end
      
    @(posedge CLK);

    if(typ[j] == `RXDAT2_RN0)
    begin
      rxdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
      rxdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `RN0_ID;
      rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `HNF0_ID;
      rn_rxdatflitv <= 1'b1;
      rn_rxdatflit  <= rxdatflit;
      j<=j+1;
      `ifdef print_info
        $display("RN0 sent data1");
      `endif 
    end

    if(typ[j] == `RXDAT2_RN1)
    begin
      rxdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
      rxdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `RN1_ID;
      rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `HNF0_ID;
      rn_rxdatflitv <= 1'b1;
      rn_rxdatflit  <= rxdatflit;
      j<=j+1;
      `ifdef print_info
        $display("RN1 sent data1");
      `endif 
    end

    @(posedge CLK);
    rn_rxdatflitv <= 1'b0;
  end
end

//HNF TXDAT CHANNEL
initial
begin
  @(negedge RST);
  forever
  begin
    if((typ[j] == `TXDAT1_RN0))
    begin
      while(!TXDATFLITV)
        @(posedge CLK);
      if(TXDATFLIT[`CHIE_DAT_FLIT_TGTID_RANGE] == `RN0_ID)
      begin
        txdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
        txdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `RN0_ID;
        txdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `HNF0_ID;
        txdatflit[`CHIE_DAT_FLIT_HOMENID_RANGE] = `HNF0_ID;
        if(TXDATFLIT == txdatflit)
        begin
          j <= j + 1;
          `ifdef print_info
            $display("RN0 received data0 from HNF");
          `endif 
        end
        else
        begin
          $display("RN0 received data0 from HNF NOT match");
          $display("RN0 received act data0 from HNF = %b",TXDATFLIT);
          $display("RN0 received exp data0 from HNF = %b",txdatflit);
          $error("Test case %d fail", (k+1));
          $finish;
        end
        
        @(posedge CLK);
        while(!TXDATFLITV)
          @(posedge CLK);
        txdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
        txdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `RN0_ID;
        txdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `HNF0_ID;
        txdatflit[`CHIE_DAT_FLIT_HOMENID_RANGE] = `HNF0_ID;
        if(TXDATFLIT == txdatflit)
        begin
          j <= j + 1;
          `ifdef print_info
            $display("RN0 received data1 from HNF");
          `endif 
        end
        else
        begin
          $display("RN0 received data1 from HNF NOT match");
          $display("RN0 received act data1 from HNF = %b",TXDATFLIT);
          $display("RN0 received exp data1 from HNF = %b",txdatflit);
          $error("Test case %d fail", (k+1));
          $finish;
        end
      end
    end

    if((typ[j] == `TXDAT1_RN1))
    begin
      while(!TXDATFLITV)
        @(posedge CLK);
      if(TXDATFLIT[`CHIE_DAT_FLIT_TGTID_RANGE] == `RN1_ID)
      begin
        txdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
        txdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `RN1_ID;
        txdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `HNF0_ID;
        txdatflit[`CHIE_DAT_FLIT_HOMENID_RANGE] = `HNF0_ID;
        if(TXDATFLIT == txdatflit)
        begin
          j <= j + 1;
          `ifdef print_info
            $display("RN1 received data0 from HNF");
          `endif 
        end
        else
        begin
          $display("RN1 received data0 from HNF NOT match");
          $display("RN1 received act data0 from HNF = %b",TXDATFLIT);
          $display("RN1 received exp data0 from HNF = %b",txdatflit);
          $error("Test case %d fail", (k+1));
          $finish;
        end
        
        @(posedge CLK);
        while(!TXDATFLITV)
          @(posedge CLK);
        txdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
        txdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `RN1_ID;
        txdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `HNF0_ID;
        txdatflit[`CHIE_DAT_FLIT_HOMENID_RANGE] = `HNF0_ID;
        if(TXDATFLIT == txdatflit)
        begin
          j <= j + 1;
          `ifdef print_info
            $display("RN1 received data1 from HNF");
          `endif 
        end
        else
        begin
          $display("RN1 received data1 from HNF NOT match");
          $display("RN1 received act data1 from HNF = %b",TXDATFLIT);
          $display("RN1 received exp data1 from HNF = %b",txdatflit);
          $error("Test case %d fail", (k+1));
          $finish;
        end
      end
    end
    @(posedge CLK);
  end
end

//HNF TXRSP CHANNEL
initial
begin
  @(negedge RST);
  forever
  begin
    if((typ[j] == `TXRSP_RN0))
    begin
      while(!TXRSPFLITV)
        @(posedge CLK);
      txrspflit = flit[j][`CHIE_RSP_FLIT_RANGE];
      txrspflit[`CHIE_RSP_FLIT_TGTID_RANGE] = `RN0_ID;
      txrspflit[`CHIE_RSP_FLIT_SRCID_RANGE] = `HNF0_ID;
      if(TXRSPFLIT == txrspflit)
      begin
        j <= j + 1;
        `ifdef print_info
          $display("RN0 received response from HNF");
        `endif 
      end
      else
      begin
        $display("RN0 received response from HNF NOT match");
        $display("RN0 received act response from HNF = %b",TXRSPFLIT);
        $display("RN0 received exp response from HNF = %b",txrspflit);
        $error("Test case %d fail", (k+1));
        $finish;
      end
    end

    if((typ[j] == `TXRSP_RN1))
    begin
      while(!TXRSPFLITV)
        @(posedge CLK);
      txrspflit = flit[j][`CHIE_RSP_FLIT_RANGE];
      txrspflit[`CHIE_RSP_FLIT_TGTID_RANGE] = `RN1_ID;
      txrspflit[`CHIE_RSP_FLIT_SRCID_RANGE] = `HNF0_ID;
      if(TXRSPFLIT == txrspflit)
      begin
        j <= j + 1;
        `ifdef print_info
          $display("RN1 received response from HNF");
        `endif 
      end
      else
      begin
        $display("RN1 received response from HNF NOT match");
        $display("RN1 received act response from HNF = %b",TXRSPFLIT);
        $display("RN1 received exp response from HNF = %b",txrspflit);
        $error("Test case %d fail", (k+1));
        $finish;
      end
    end
    @(posedge CLK);
  end
end

//HNF TXSNP CHANNEL
initial
begin
  @(negedge RST);
  forever
  begin
    if((typ[j] == `TXSNP_RN0))
    begin
      while(!TXSNPFLITV)
        @(posedge CLK);
      txsnpflit = flit[j][`HNF_SNP_FLIT_RANGE];
      txsnpflit[`HNF_SNP_FLIT_WIDTH-1:`CHIE_SNP_FLIT_WIDTH] = `RN0_ID;
      txsnpflit[`CHIE_SNP_FLIT_SRCID_RANGE] = `HNF0_ID;
      if(txsnpflit[`CHIE_SNP_FLIT_FWDNID_RANGE] == 3)
        txsnpflit[`CHIE_SNP_FLIT_FWDNID_RANGE] = `RN1_ID;
      if(TXSNPFLIT == txsnpflit)
      begin
        j <= j + 1;
        `ifdef print_info
          $display("RN0 received snoop from HNF");
        `endif 
      end
      else
      begin
        $display("RN0 received snoop from HNF NOT match");
        $display("RN0 received act snoop from HNF = %b",TXSNPFLIT);
        $display("RN0 received exp snoop from HNF = %b",txsnpflit);
        $error("Test case %d fail", (k+1));
        $finish;
      end
    end

    if((typ[j] == `TXSNP_RN1))
    begin
      while(!TXSNPFLITV)
        @(posedge CLK);
      txsnpflit = flit[j][`HNF_SNP_FLIT_RANGE];
      txsnpflit[`HNF_SNP_FLIT_WIDTH-1:`CHIE_SNP_FLIT_WIDTH] = `RN1_ID;
      txsnpflit[`CHIE_SNP_FLIT_SRCID_RANGE] = `HNF0_ID;
      if(txsnpflit[`CHIE_SNP_FLIT_FWDNID_RANGE] == 1)
        txsnpflit[`CHIE_SNP_FLIT_FWDNID_RANGE] = `RN0_ID;
      if(TXSNPFLIT == txsnpflit)
      begin
        j <= j + 1;
        `ifdef print_info
          $display("RN1 received snoop from HNF");
        `endif 
      end
      else
      begin
        $display("RN1 received snoop from HNF NOT match");
        $display("RN1 received act snoop from HNF = %b",TXSNPFLIT);
        $display("RN1 received exp snoop from HNF = %b",txsnpflit);
        $error("Test case %d fail", (k+1));
        $finish;
      end
    end
    @(posedge CLK);
  end
end

//DWT SNI->RN0 Response
initial
begin
  @(negedge RST);
  forever
  begin
    if((typ[j] == `SNI_RSP_RN0))
    begin
      while(!sn_rxrspflitv)
        @(posedge CLK);
      g_rxrspflit = flit[j][`CHIE_RSP_FLIT_RANGE];
      g_rxrspflit[`CHIE_RSP_FLIT_TGTID_RANGE] = `RN0_ID;
      g_rxrspflit[`CHIE_RSP_FLIT_SRCID_RANGE] = `SN_ID;
      if(sn_rxrspflit == g_rxrspflit)
      begin
        j <= j + 1;
        `ifdef print_info
          $display("RN0 received response from SN");
        `endif 
      end
      else
      begin
        $display("RN0 received response from SN NOT match");
        $display("RN0 received act response from SN = %b",sn_rxrspflit);
        $display("RN0 received exp response from SN = %b",g_rxrspflit);
        $error("Test case %d fail", (k+1));
        $finish;
      end
    end
    @(posedge CLK);
  end
end

//DWT RN0->SNI DAT
assign sn_txdatflitv = sn_txdatflitv_tmp? sn_txdatflitv_tmp:TXDATFLITV;
assign sn_txdatflit  = sn_txdatflitv_tmp? sn_txdatflit_tmp :TXDATFLIT;

initial
begin
  sn_txdatflitv_tmp <= 1'b0;
  @(negedge RST);
  forever
  begin
    if(typ[j] == `RN0_DAT1_SNI)
    begin
      g_txdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
      g_txdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `RN0_ID;
      g_txdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `SN_ID;
      sn_txdatflitv_tmp <= 1'b1;
      sn_txdatflit_tmp <= g_txdatflit;
      j<=j+1;
      `ifdef print_info
        $display("RN0 sent data0 to SN");
      `endif 

      @(posedge CLK);
      g_txdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
      g_txdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `RN0_ID;
      g_txdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `SN_ID;
      sn_txdatflitv_tmp <= 1'b1;
      sn_txdatflit_tmp <= g_txdatflit;
      j<=j+1;
      `ifdef print_info
        $display("RN0 sent data1 to SN");
      `endif 
    end
    @(posedge CLK);
    sn_txdatflitv_tmp <= 1'b0;
  end
end

//DMT SNI->RN0 DAT
initial
begin
  @(negedge RST);
  forever
  begin
    if(typ[j] == `SNI_DAT1_RN0)
    begin
      while(!sn_rxdatflitv)
        @(posedge CLK);
      if(sn_rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] == `RN0_ID)
      begin
        g_rxdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
        g_rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `RN0_ID;
        g_rxdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `SN_ID;
        g_rxdatflit[`CHIE_DAT_FLIT_HOMENID_RANGE] = `HNF0_ID;
        if(g_rxdatflit == sn_rxdatflit)
        begin
          j <= j + 1;
          `ifdef print_info
            $display("RN0 received data0 from SN");
          `endif 
        end
        else begin
          $display("RN0 received data0 from SN NOT match");
          $display("RN0 received act data0 from SN  = %b",sn_rxdatflit);
          $display("RN0 received exp data0 from SN  = %b",g_rxdatflit);
          $error("Test case %d fail", (k+1));
          $finish;
        end
      end
  
      @(posedge CLK);
  
      while(!sn_rxdatflitv)
        @(posedge CLK);
      
      if(sn_rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] == `RN0_ID)
      begin
        g_rxdatflit = flit[j][`CHIE_DAT_FLIT_RANGE];
        g_rxdatflit[`CHIE_DAT_FLIT_TGTID_RANGE] = `RN0_ID;
        g_rxdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] = `SN_ID;
        g_rxdatflit[`CHIE_DAT_FLIT_HOMENID_RANGE] = `HNF0_ID;
        if(g_rxdatflit == sn_rxdatflit)
        begin
          j <= j + 1;
          `ifdef print_info
            $display("RN0 received data1 from SN");
          `endif 
        end
        else begin
          $display("RN0 received data1 from SN NOT match");
          $display("RN0 received act data1 from SN  = %b",sn_rxdatflit);
          $display("RN0 received exp data1 from SN  = %b",g_rxdatflit);
          $error("Test case %d fail", (k+1));
          $finish;
        end
      end
    end
    @(posedge CLK);
  end
end

//stop the sim
initial
begin
  @(negedge RST);
  forever
  begin
    while(j != i)
    begin
      @(posedge CLK);
    end
    repeat(50)@(posedge CLK);//6
    p = 1;
    `ifdef print_info
      $display("\n********* Result Stage *********");
    `endif
    //$display("Test case %d pass",(k+1));
    @(posedge CLK);
  end
end

//initial
//begin
//    $vcdpluson;
//end

//initial
//begin
//    $fsdbDumpfile("tb_hnf.fsdb");
//    $fsdbDumpvars;
//end

endmodule
