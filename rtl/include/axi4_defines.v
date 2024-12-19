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

`ifndef AXI_DEFINES_UNDEFINE
`ifndef AXI_DEFINES
`define AXI_DEFINES

`define AXI_AXADDR_WIDTH                    AXI_AXADDR_WIDTH_PARAM
`define AXI_AXDATA_WIDTH                    AXI_AXDATA_WIDTH_PARAM
`define AXI_AXID_WIDTH                      11
`define AXI_AXLEN_WIDTH                     8
`define AXI_AXLOCK_WIDTH                    1
`define AXI_AXSIZE_WIDTH                    3
`define AXI_AXBURST_WIDTH                   2
`define AXI_AXCACHE_WIDTH                   4
`define AXI_AXPROT_WIDTH                    3
`define AXI_AXQOS_WIDTH                     4
`define AXI_AXREGION_WIDTH                  4
`define AXI_AXUSER_WIDTH                    8
`define AXI_AXBID_WIDTH                     11
`define AXI_AXBRESP_WIDTH                   2
`define AXI_AXBUSER_WIDTH                   4

`define AXI_BID_WIDTH                       11
`define AXI_BRESP_WIDTH                     2
`define AXI_BUSER_WIDTH                     4

`endif // AXI_DEFINES

`else // AXI_DEFINES_UNDEFINE set

`undef AXI_DEFINES
`undef AXI_AXADDR_WIDTH
`undef AXI_AXDATA_WIDTH


`endif // AXI_DEFINES_UNDEFINE
