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

`include "rni_param.v"
`include "axi4_defines.v"

module rni_axi_bus `RNI_PARAM
    (
        // AW Channel0
        AWID0
        ,AWADDR0
        ,AWLEN0
        ,AWSIZE0
        ,AWBURST0
        ,AWLOCK0
        ,AWCACHE0
        ,AWPROT0
        ,AWQOS0
        ,AWREGION0
        ,AW_CH_S0

        // W Channel0
        ,WDATA0
        ,WSTRB0
        ,WLAST0
        ,W_CH_S0

        // B Channel0
        ,BID0
        ,BRESP0
        ,B_CH_S0

        // AR Channel0
        ,ARID0
        ,ARADDR0
        ,ARLEN0
        ,ARSIZE0
        ,ARBURST0
        ,ARLOCK0
        ,ARCACHE0
        ,ARPROT0
        ,ARQOS0
        ,ARREGION0
        ,AR_CH_S0

        // R Channel0
        ,RID0
        ,RDATA0
        ,RRESP0
        ,RLAST0
        ,R_CH_S0
    );
    // AW Channel0
    input  wire [`AXI4_AWID_WIDTH-1:0]     AWID0;
    input  wire [`AXI4_AWADDR_WIDTH-1:0]   AWADDR0;
    input  wire [`AXI4_AWLEN_WIDTH-1:0]    AWLEN0;
    input  wire [`AXI4_AWSIZE_WIDTH-1:0]   AWSIZE0;
    input  wire [`AXI4_AWBURST_WIDTH-1:0]  AWBURST0;
    input  wire [`AXI4_AWLOCK_WIDTH-1:0]   AWLOCK0;
    input  wire [`AXI4_AWCACHE_WIDTH-1:0]  AWCACHE0;
    input  wire [`AXI4_AWPROT_WIDTH-1:0]   AWPROT0;
    input  wire [`AXI4_AWQOS_WIDTH-1:0]    AWQOS0;
    input  wire [`AXI4_AWREGION_WIDTH-1:0] AWREGION0;
    output wire [`AXI4_AW_WIDTH-1:0]       AW_CH_S0;

    // W Channel0
    input  wire [`AXI4_WDATA_WIDTH-1:0]    WDATA0;
    input  wire [`AXI4_WSTRB_WIDTH-1:0]    WSTRB0;
    input  wire [`AXI4_WLAST_WIDTH-1:0]    WLAST0;
    output wire [`AXI4_W_WIDTH-1:0]        W_CH_S0;

    // B Channel0
    output wire [`AXI4_BID_WIDTH-1:0]      BID0;
    output wire [`AXI4_BRESP_WIDTH-1:0]    BRESP0;
    input  wire [`AXI4_B_WIDTH-1:0]        B_CH_S0;

    // AR Channel0
    input  wire [`AXI4_ARID_WIDTH-1:0]     ARID0;
    input  wire [`AXI4_ARADDR_WIDTH-1:0]   ARADDR0;
    input  wire [`AXI4_ARLEN_WIDTH-1:0]    ARLEN0;
    input  wire [`AXI4_ARSIZE_WIDTH-1:0]   ARSIZE0;
    input  wire [`AXI4_ARBURST_WIDTH-1:0]  ARBURST0;
    input  wire [`AXI4_ARLOCK_WIDTH-1:0]   ARLOCK0;
    input  wire [`AXI4_ARCACHE_WIDTH-1:0]  ARCACHE0;
    input  wire [`AXI4_ARPROT_WIDTH-1:0]   ARPROT0;
    input  wire [`AXI4_ARQOS_WIDTH-1:0]    ARQOS0;
    input  wire [`AXI4_ARREGION_WIDTH-1:0] ARREGION0;
    output wire [`AXI4_AR_WIDTH-1:0]       AR_CH_S0;

    // R Channel0
    output wire [`AXI4_RID_WIDTH-1:0]      RID0;
    output wire [`AXI4_RDATA_WIDTH-1:0]    RDATA0;
    output wire [`AXI4_RRESP_WIDTH-1:0]    RRESP0;
    output wire [`AXI4_RLAST_WIDTH-1:0]    RLAST0;
    input  wire [`AXI4_R_WIDTH-1:0]        R_CH_S0;

    // main function
    assign AW_CH_S0[`AXI4_AWID_RANGE]        = AWID0;
    assign AW_CH_S0[`AXI4_AWADDR_RANGE]      = AWADDR0;
    assign AW_CH_S0[`AXI4_AWLEN_RANGE]       = AWLEN0;
    assign AW_CH_S0[`AXI4_AWSIZE_RANGE]      = AWSIZE0;
    assign AW_CH_S0[`AXI4_AWBURST_RANGE]     = AWBURST0;
    assign AW_CH_S0[`AXI4_AWLOCK_RANGE]      = AWLOCK0;
    assign AW_CH_S0[`AXI4_AWCACHE_RANGE]     = AWCACHE0;
    assign AW_CH_S0[`AXI4_AWPROT_RANGE]      = AWPROT0;
    assign AW_CH_S0[`AXI4_AWQOS_RANGE]       = AWQOS0;
    assign AW_CH_S0[`AXI4_AWREGION_RANGE]    = AWREGION0;

    assign W_CH_S0[`AXI4_WDATA_RANGE]        = WDATA0;
    assign W_CH_S0[`AXI4_WSTRB_RANGE]        = WSTRB0;
    assign W_CH_S0[`AXI4_WLAST_RANGE]        = WLAST0;

    assign AR_CH_S0[`AXI4_ARID_RANGE]        = ARID0;
    assign AR_CH_S0[`AXI4_ARADDR_RANGE]      = ARADDR0;
    assign AR_CH_S0[`AXI4_ARLEN_RANGE]       = ARLEN0;
    assign AR_CH_S0[`AXI4_ARSIZE_RANGE]      = ARSIZE0;
    assign AR_CH_S0[`AXI4_ARBURST_RANGE]     = ARBURST0;
    assign AR_CH_S0[`AXI4_ARLOCK_RANGE]      = ARLOCK0;
    assign AR_CH_S0[`AXI4_ARCACHE_RANGE]     = ARCACHE0;
    assign AR_CH_S0[`AXI4_ARPROT_RANGE]      = ARPROT0;
    assign AR_CH_S0[`AXI4_ARQOS_RANGE]       = ARQOS0;
    assign AR_CH_S0[`AXI4_ARREGION_RANGE]    = ARREGION0;

    assign BID0   = B_CH_S0[`AXI4_BID_RANGE];
    assign BRESP0 = B_CH_S0[`AXI4_BRESP_RANGE];

    assign RID0   = R_CH_S0[`AXI4_RID_RANGE];
    assign RDATA0 = R_CH_S0[`AXI4_RDATA_RANGE];
    assign RRESP0 = R_CH_S0[`AXI4_RRESP_RANGE];
    assign RLAST0 = R_CH_S0[`AXI4_RLAST_RANGE];

endmodule
