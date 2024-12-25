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
`include "rni_defines.v"
`include "axi4_defines.v"
`include "chie_defines.v"

module rni `RNI_PARAM
    (
        // global inputs
        CLK
        ,RST

        // link handshake
        ,TXLINKACTIVEREQ
        ,TXLINKACTIVEACK
        ,RXLINKACTIVEREQ
        ,RXLINKACTIVEACK

        // CHI interface
        ,RXRSPFLITPEND
        ,RXRSPFLITV
        ,RXRSPFLIT
        ,RXRSPLCRDV
        ,RXDATFLITPEND
        ,RXDATFLITV
        ,RXDATFLIT
        ,RXDATLCRDV
        ,TXRSPFLITPEND
        ,TXRSPFLITV
        ,TXRSPFLIT
        ,TXRSPLCRDV
        ,TXDATFLITPEND
        ,TXDATFLITV
        ,TXDATFLIT
        ,TXDATLCRDV
        ,TXREQFLITPEND
        ,TXREQFLITV
        ,TXREQFLIT
        ,TXREQLCRDV

        // AXI interface
        ,AWID0
        ,AWADDR0
        ,AWLEN0
        ,AWSIZE0
        ,AWBURST0
        ,AWLOCK0
        ,AWCACHE0
        ,AWPROT0
        ,AWQOS0
        ,AWREGION0
        ,AWVALID0
        ,AWREADY0
        ,WDATA0
        ,WSTRB0
        ,WLAST0
        ,WVALID0
        ,WREADY0
        ,BID0
        ,BRESP0
        ,BVALID0
        ,BREADY0
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
        ,ARVALID0
        ,ARREADY0
        ,RID0
        ,RDATA0
        ,RRESP0
        ,RLAST0
        ,RVALID0
        ,RREADY0
    );

    // global ports
    input  wire                                 CLK;
    input  wire                                 RST;

    // link handshake
    output wire                                 TXLINKACTIVEREQ;
    input  wire                                 TXLINKACTIVEACK;
    input  wire                                 RXLINKACTIVEREQ;
    output wire                                 RXLINKACTIVEACK;

    // CHI interface
    input  wire                                 RXRSPFLITPEND;
    input  wire                                 RXRSPFLITV;
    input  wire [`CHIE_RSP_FLIT_RANGE]          RXRSPFLIT;
    output wire                                 RXRSPLCRDV;
    input  wire                                 RXDATFLITPEND;
    input  wire                                 RXDATFLITV;
    input  wire [`CHIE_DAT_FLIT_RANGE]          RXDATFLIT;
    output wire                                 RXDATLCRDV;
    output wire                                 TXRSPFLITPEND;
    output wire                                 TXRSPFLITV;
    output wire [`CHIE_RSP_FLIT_RANGE]          TXRSPFLIT;
    input  wire                                 TXRSPLCRDV;
    output wire                                 TXDATFLITPEND;
    output wire                                 TXDATFLITV;
    output wire [`CHIE_DAT_FLIT_RANGE]          TXDATFLIT;
    input  wire                                 TXDATLCRDV;
    output wire                                 TXREQFLITPEND;
    output wire                                 TXREQFLITV;
    output wire [`CHIE_REQ_FLIT_RANGE]          TXREQFLIT;
    input  wire                                 TXREQLCRDV;

    // AXI interface0
    input  wire [`AXI4_AWID_WIDTH-1:0]          AWID0;
    input  wire [`AXI4_AWADDR_WIDTH-1:0]        AWADDR0;
    input  wire [`AXI4_AWLEN_WIDTH-1:0]         AWLEN0;
    input  wire [`AXI4_AWSIZE_WIDTH-1:0]        AWSIZE0;
    input  wire [`AXI4_AWBURST_WIDTH-1:0]       AWBURST0;
    input  wire [`AXI4_AWLOCK_WIDTH-1:0]        AWLOCK0;
    input  wire [`AXI4_AWCACHE_WIDTH-1:0]       AWCACHE0;
    input  wire [`AXI4_AWPROT_WIDTH-1:0]        AWPROT0;
    input  wire [`AXI4_AWQOS_WIDTH-1:0]         AWQOS0;
    input  wire [`AXI4_AWREGION_WIDTH-1:0]      AWREGION0;
    input  wire                                 AWVALID0;
    output wire                                 AWREADY0;
    input  wire [`AXI4_WDATA_WIDTH-1:0]         WDATA0;
    input  wire [`AXI4_WSTRB_WIDTH-1:0]         WSTRB0;
    input  wire [`AXI4_WLAST_WIDTH-1:0]         WLAST0;
    input  wire                                 WVALID0;
    output wire                                 WREADY0;
    output wire [`AXI4_BID_WIDTH-1:0]           BID0;
    output wire [`AXI4_BRESP_WIDTH-1:0]         BRESP0;
    output wire                                 BVALID0;
    input  wire                                 BREADY0;
    input  wire [`AXI4_ARID_WIDTH-1:0]          ARID0;
    input  wire [`AXI4_ARADDR_WIDTH-1:0]        ARADDR0;
    input  wire [`AXI4_ARLEN_WIDTH-1:0]         ARLEN0;
    input  wire [`AXI4_ARSIZE_WIDTH-1:0]        ARSIZE0;
    input  wire [`AXI4_ARBURST_WIDTH-1:0]       ARBURST0;
    input  wire [`AXI4_ARLOCK_WIDTH-1:0]        ARLOCK0;
    input  wire [`AXI4_ARCACHE_WIDTH-1:0]       ARCACHE0;
    input  wire [`AXI4_ARPROT_WIDTH-1:0]        ARPROT0;
    input  wire [`AXI4_ARQOS_WIDTH-1:0]         ARQOS0;
    input  wire [`AXI4_ARREGION_WIDTH-1:0]      ARREGION0;
    input  wire                                 ARVALID0;
    output wire                                 ARREADY0;
    output wire [`AXI4_RID_WIDTH-1:0]           RID0;
    output wire [`AXI4_RDATA_WIDTH-1:0]         RDATA0;
    output wire [`AXI4_RRESP_WIDTH-1:0]         RRESP0;
    output wire [`AXI4_RLAST_WIDTH-1:0]         RLAST0;
    output wire                                 RVALID0;
    input  wire                                 RREADY0;

    // wire
    wire [`AXI4_AW_WIDTH-1:0]                   AW_CH_S0;
    wire [`AXI4_W_WIDTH-1:0]                    W_CH_S0;
    wire [`AXI4_B_WIDTH-1:0]                    B_CH_S0;
    wire [`AXI4_AR_WIDTH-1:0]                   AR_CH_S0;
    wire [`AXI4_R_WIDTH-1:0]                    R_CH_S0;
    wire                                        rxrspflitv_d1;
    wire [`CHIE_RSP_FLIT_WIDTH-1:0]             rxrspflit_d1_q;
    wire                                        rxdatflitv_d1;
    wire                                        rxdatflitv_d1_w;
    wire [`CHIE_DAT_FLIT_RANGE]                 rxdatflit_d1;
    wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]       rxdatflit_txnid_d1;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]      rxdatflit_dataid_d1;
    wire                                        arctrl_rxdat_rb_v_d2;
    wire [`RNI_AR_ENTRIES_WIDTH-1:0]            arctrl_rxdat_rb_idx_d2;
    wire                                        rp_fifo_acpt_d4;
    wire                                        arctrl_rb_valid_d4;
    wire [`RNI_DMASK_CT_WIDTH-1:0]              arctrl_rb_ctmask_d4;
    wire                                        arctrl_rb_rlast_d4;
    wire [`AXI4_ARID_WIDTH-1:0]                 arctrl_rb_rid_d4;
    wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]     arctrl_rdata_resperr_d4;
    wire [`RNI_AR_ENTRIES_WIDTH-1:0]            arctrl_rb_idx_d4;
    wire [`RNI_BC_WIDTH-1:0]                    arctrl_rb_bc_d4;
    wire [`CHIE_DAT_FLIT_WIDTH-1:0]             aw_txdatflit_s3;
    wire                                        aw_txdatflitv_s3;
    wire                                        aw_txdatflit_sent_s3;
    wire                                        pcrdgnt_pkt_v_d2;
    wire [`PCRDGRANT_PKT_WIDTH-1:0]             pcrdgnt_pkt_d2;
    wire [`CHIE_REQ_FLIT_WIDTH-1:0]             arctrl_txreqflit_s4;
    wire                                        arctrl_txreqflitv_s4;
    wire                                        arctrl_txreqflit_sent_s4;
    wire [`CHIE_RSP_FLIT_WIDTH-1:0]             aw_txrspflit_s0;
    wire                                        aw_txrspflitv_s0;
    wire                                        aw_txrspflit_sent_s0;
    wire [`CHIE_REQ_FLIT_WIDTH-1:0]             aw_txreqflit_s0;
    wire                                        aw_txreqflitv_s0;
    wire                                        aw_txreqflit_sent_s0;
    wire                                        arctrl_pcrdgnt_l_present_d3;
    wire                                        arctrl_pcrdgnt_h_present_d3;
    wire                                        aw_pcrdgnt_l_present_d3;
    wire                                        aw_pcrdgnt_h_present_d3;
    wire                                        ar_pcrdgnt_l_win_d3;
    wire                                        ar_pcrdgnt_h_win_d3;
    wire                                        aw_pcrdgnt_l_win_d3;
    wire                                        aw_pcrdgnt_h_win_d3;
    wire [`CHIE_RSP_FLIT_WIDTH-1:0]             awctrl_txrspflit_d0;
    wire                                        awctrl_txrspflitv_d0;
    wire                                        awctrl_txrspflit_sent_d0;
    wire [`CHIE_REQ_FLIT_WIDTH-1:0]             awctrl_txreqflit_s4;
    wire                                        awctrl_txreqflitv_s4;
    wire                                        awctrl_txreqflit_sent_s4;
    wire                                        awctrl_alloc_valid_s2;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_alloc_entry_s2;
    wire [`RNI_DMASK_CT_WIDTH-1:0]              awctrl_ctmask_s2;
    wire [`RNI_DMASK_PD_WIDTH-1:0]              awctrl_pdmask_s2;
    wire [`RNI_BCVEC_WIDTH-1:0]                 awctrl_bc_vec_s2;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_dealloc_entry;
    wire                                        wb_req_fifo_pfull_d1;
    wire                                        wb_req_done_d3;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         wb_req_entry_d3;
    wire                                        wb_not_busy_d1;
    wire                                        awctrl_txdat_rdy_v_d2;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]         awctrl_txdat_rdy_entry_d2;
    wire [`CHIE_DAT_FLIT_QOS_WIDTH-1:0]         awctrl_txdat_qos_d2;
    wire                                        awctrl_txdat_compack_d2;
    wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]        awctrl_txdat_dbid_d2;
    wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]       awctrl_txdat_tgtid_d2;
    wire [`CHIE_DAT_FLIT_CCID_WIDTH-1:0]        awctrl_txdat_ccid_d2;
    wire [`RNI_DMASK_CT_WIDTH-1:0]              awctrl_txdat_ctmask_d2;
    wire                                        awctrl_txdat_not_busy_d2;
    wire                                        awctrl_brsp_fifo_pop_d3;
    wire                                        awctrl_brsp_rdy_v_d2;
    wire                                        awctrl_brsp_last_v_d2;
    wire [`AXI4_BID_WIDTH-1:0]                  awctrl_brsp_axid_d2;
    wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]     awctrl_brsp_resperr_d2;
    wire [`CHIE_DAT_FLIT_WIDTH-1:0]             wb_txdatflit_d3;
    wire                                        wb_txdatflitv_d3;
    wire                                        wb_txdatflit_sent_d3;

    rni_axi_bus `RNI_PARAM_INST
                rni_axi_bus_inst(
                    // AW Channel0
                    .AWID0                                 ( AWID0                         )
                    ,.AWADDR0                               ( AWADDR0                       )
                    ,.AWLEN0                                ( AWLEN0                        )
                    ,.AWSIZE0                               ( AWSIZE0                       )
                    ,.AWBURST0                              ( AWBURST0                      )
                    ,.AWLOCK0                               ( AWLOCK0                       )
                    ,.AWCACHE0                              ( AWCACHE0                      )
                    ,.AWPROT0                               ( AWPROT0                       )
                    ,.AWQOS0                                ( AWQOS0                        )
                    ,.AWREGION0                             ( AWREGION0                     )
                    ,.AW_CH_S0                              ( AW_CH_S0                      )

                    // W Channel0
                    ,.WDATA0                                ( WDATA0                        )
                    ,.WSTRB0                                ( WSTRB0                        )
                    ,.WLAST0                                ( WLAST0                        )
                    ,.W_CH_S0                               ( W_CH_S0                       )

                    // B Channel0
                    ,.BID0                                  ( BID0                          )
                    ,.BRESP0                                ( BRESP0                        )
                    ,.B_CH_S0                               ( B_CH_S0                       )

                    // AR Channel0
                    ,.ARID0                                 ( ARID0                         )
                    ,.ARADDR0                               ( ARADDR0                       )
                    ,.ARLEN0                                ( ARLEN0                        )
                    ,.ARSIZE0                               ( ARSIZE0                       )
                    ,.ARBURST0                              ( ARBURST0                      )
                    ,.ARLOCK0                               ( ARLOCK0                       )
                    ,.ARCACHE0                              ( ARCACHE0                      )
                    ,.ARPROT0                               ( ARPROT0                       )
                    ,.ARQOS0                                ( ARQOS0                        )
                    ,.ARREGION0                             ( ARREGION0                     )
                    ,.AR_CH_S0                              ( AR_CH_S0                      )

                    // R Channel0
                    ,.RID0                                  ( RID0                          )
                    ,.RDATA0                                ( RDATA0                        )
                    ,.RRESP0                                ( RRESP0                        )
                    ,.RLAST0                                ( RLAST0                        )
                    ,.R_CH_S0                               ( R_CH_S0                       )
                );

    rni_rd_buffer `RNI_PARAM_INST
                  rni_rd_buffer_inst(
                      // global inputs
                      .clk_i                                 ( CLK                           )
                      ,.rst_i                                 ( RST                           )
                      ,.rxdatflitv_d1_i                       ( rxdatflitv_d1                 )
                      ,.rxdatflit_d1_i                        ( rxdatflit_d1                  )
                      ,.rxdatflitv_d1_o                       ( rxdatflitv_d1_w               )
                      ,.rxdatflit_txnid_d1_o                  ( rxdatflit_txnid_d1            )
                      ,.rxdatflit_dataid_d1_o                 ( rxdatflit_dataid_d1           )
                      ,.rp_fifo_acpt_d4_o                     ( rp_fifo_acpt_d4               )
                      ,.arctrl_rb_valid_d4_i                  ( arctrl_rb_valid_d4            )
                      ,.arctrl_rb_idx_d4_i                    ( arctrl_rb_idx_d4              )
                      ,.arctrl_rb_ctmask_d4_i                 ( arctrl_rb_ctmask_d4           )
                      ,.arctrl_rb_rlast_d4_i                  ( arctrl_rb_rlast_d4            )
                      ,.arctrl_rb_rid_d4_i                    ( arctrl_rb_rid_d4              )
                      ,.arctrl_rb_bc_d4_i                     ( arctrl_rb_bc_d4               )
                      ,.R_CH_S0                               ( R_CH_S0                       )
                      ,.RVALID0                               ( RVALID0                       )
                      ,.RREADY0                               ( RREADY0                       )
                  );

    rni_arctrl `RNI_PARAM_INST
               rni_arctrl_inst(
                   // global inputs
                   .clk_i                                 ( CLK                           )
                   ,.rst_i                                 ( RST                           )
                   ,.AR_CH_S0                              ( AR_CH_S0                      )
                   ,.ARVALID0                              ( ARVALID0                      )
                   ,.ARREADY0                              ( ARREADY0                      )
                   ,.arctrl_txreqflitv_s4_o                ( arctrl_txreqflitv_s4          )
                   ,.arctrl_txreqflit_s4_o                 ( arctrl_txreqflit_s4           )
                   ,.arctrl_txreqflit_sent_s4_i            ( arctrl_txreqflit_sent_s4      )
                   ,.rxrspflitv_d1_i                       ( rxrspflitv_d1                 )
                   ,.rxrspflit_d1_i                        ( rxrspflit_d1_q                )
                   ,.rxdatflitv_d1_i                       ( rxdatflitv_d1_w               )
                   ,.rxdatflit_txnid_d1_i                  ( rxdatflit_txnid_d1            )
                   ,.rxdatflit_dataid_d1_i                 ( rxdatflit_dataid_d1           )
                   ,.rp_fifo_acpt_d4_i                     ( rp_fifo_acpt_d4               )
                   ,.arctrl_rb_valid_d4_o                  ( arctrl_rb_valid_d4            )
                   ,.arctrl_rb_ctmask_d4_o                 ( arctrl_rb_ctmask_d4           )
                   ,.arctrl_rb_rlast_d4_o                  ( arctrl_rb_rlast_d4            )
                   ,.arctrl_rb_rid_d4_o                    ( arctrl_rb_rid_d4              )
                   ,.arctrl_rb_idx_d4_o                    ( arctrl_rb_idx_d4              )
                   ,.arctrl_rb_bc_d4_o                     ( arctrl_rb_bc_d4               )
                   ,.pcrdgnt_pkt_v_d2_i                    ( pcrdgnt_pkt_v_d2              )
                   ,.pcrdgnt_pkt_d2_i                      ( pcrdgnt_pkt_d2                )
                   ,.arctrl_pcrdgnt_h_present_d3_o         ( arctrl_pcrdgnt_h_present_d3   )
                   ,.arctrl_pcrdgnt_l_present_d3_o         ( arctrl_pcrdgnt_l_present_d3   )
                   ,.ar_pcrdgnt_h_win_d3_i                 ( ar_pcrdgnt_h_win_d3           )
                   ,.ar_pcrdgnt_l_win_d3_i                 ( ar_pcrdgnt_l_win_d3           )
               );

    rni_misc `RNI_PARAM_INST
             rni_misc_inst(
                 // global inputs
                 .clk_i                                 ( CLK                           )
                 ,.rst_i                                 ( RST                           )

                 // rni_link_ctl Interface
                 ,.rxrspflitv_d1_i                       ( rxrspflitv_d1                 )
                 ,.rxrspflit_d1_q_i                      ( rxrspflit_d1_q                )

                 // rni_awctrl Interface
                 ,.pcrdgnt_pkt_v_d2_o                    ( pcrdgnt_pkt_v_d2              )
                 ,.pcrdgnt_pkt_d2_o                      ( pcrdgnt_pkt_d2                )
                 ,.ar_pcrdgnt_l_present_d3_i             ( arctrl_pcrdgnt_l_present_d3   )
                 ,.ar_pcrdgnt_h_present_d3_i             ( arctrl_pcrdgnt_h_present_d3   )
                 ,.aw_pcrdgnt_l_present_d3_i             ( aw_pcrdgnt_l_present_d3       )
                 ,.aw_pcrdgnt_h_present_d3_i             ( aw_pcrdgnt_h_present_d3       )
                 ,.ar_pcrdgnt_l_win_d3_o                 ( ar_pcrdgnt_l_win_d3           )
                 ,.ar_pcrdgnt_h_win_d3_o                 ( ar_pcrdgnt_h_win_d3           )
                 ,.aw_pcrdgnt_l_win_d3_o                 ( aw_pcrdgnt_l_win_d3           )
                 ,.aw_pcrdgnt_h_win_d3_o                 ( aw_pcrdgnt_h_win_d3           )
             );

    rni_awctrl `RNI_PARAM_INST
               rni_awctrl_inst(
                   // global inputs
                   .clk_i                                 ( CLK                           )
                   ,.rst_i                                 ( RST                           )
                   ,.awctrl_txrspflit_d0_o                 ( awctrl_txrspflit_d0           )
                   ,.awctrl_txrspflitv_d0_o                ( awctrl_txrspflitv_d0          )
                   ,.awctrl_txrspflit_sent_d0_i            ( awctrl_txrspflit_sent_d0      )
                   ,.awctrl_txreqflit_s4_o                 ( awctrl_txreqflit_s4           )
                   ,.awctrl_txreqflitv_s4_o                ( awctrl_txreqflitv_s4          )
                   ,.awctrl_txreqflit_sent_s4_i            ( awctrl_txreqflit_sent_s4      )
                   ,.awctrl_rxrspflitv_d1_i                ( rxrspflitv_d1                 )
                   ,.awctrl_rxrspflit_d1_i                 ( rxrspflit_d1_q                )
                   ,.AWVALID0                              ( AWVALID0                      )
                   ,.AW_CH_S0                              ( AW_CH_S0                      )
                   ,.AWREADY0                              ( AWREADY0                      )
                   ,.pcrdgnt_pkt_v_d2_i                    ( pcrdgnt_pkt_v_d2              )
                   ,.pcrdgnt_pkt_d2_i                      ( pcrdgnt_pkt_d2                )
                   ,.awctrl_pcrdgnt_h_present_d3_o         ( aw_pcrdgnt_h_present_d3       )
                   ,.awctrl_pcrdgnt_l_present_d3_o         ( aw_pcrdgnt_l_present_d3       )
                   ,.awctrl_pcrdgnt_h_win_d3_i             ( aw_pcrdgnt_h_win_d3           )
                   ,.awctrl_pcrdgnt_l_win_d3_i             ( aw_pcrdgnt_l_win_d3           )
                   ,.awctrl_alloc_valid_s2_o               ( awctrl_alloc_valid_s2         )
                   ,.awctrl_alloc_entry_s2_o               ( awctrl_alloc_entry_s2         )
                   ,.awctrl_ctmask_s2_o                    ( awctrl_ctmask_s2              )
                   ,.awctrl_pdmask_s2_o                    ( awctrl_pdmask_s2              )
                   ,.awctrl_bc_vec_s2_o                    ( awctrl_bc_vec_s2              )
                   ,.awctrl_dealloc_entry_o                ( awctrl_dealloc_entry          )
                   ,.wb_req_fifo_pfull_d1_i                ( wb_req_fifo_pfull_d1          )
                   ,.wb_req_done_d3_i                      ( wb_req_done_d3                )
                   ,.wb_req_entry_d3_i                     ( wb_req_entry_d3               )
                   ,.wb_not_busy_d1_i                      ( wb_not_busy_d1                )
                   ,.awctrl_txdat_rdy_v_d2_o               ( awctrl_txdat_rdy_v_d2         )
                   ,.awctrl_txdat_rdy_entry_d2_o           ( awctrl_txdat_rdy_entry_d2     )
                   ,.awctrl_txdat_qos_d2_o                 ( awctrl_txdat_qos_d2           )
                   ,.awctrl_txdat_compack_d2_o             ( awctrl_txdat_compack_d2       )
                   ,.awctrl_txdat_dbid_d2_o                ( awctrl_txdat_dbid_d2          )
                   ,.awctrl_txdat_tgtid_d2_o               ( awctrl_txdat_tgtid_d2         )
                   ,.awctrl_txdat_ccid_d2_o                ( awctrl_txdat_ccid_d2          )
                   ,.awctrl_txdat_ctmask_d2_o              ( awctrl_txdat_ctmask_d2        )
                   ,.awctrl_txdat_not_busy_d2_i            ( awctrl_txdat_not_busy_d2      )
                   ,.awctrl_brsp_fifo_pop_d3_i             ( awctrl_brsp_fifo_pop_d3       )
                   ,.awctrl_brsp_rdy_v_d2_o                ( awctrl_brsp_rdy_v_d2          )
                   ,.awctrl_brsp_last_v_d2_o               ( awctrl_brsp_last_v_d2         )
                   ,.awctrl_brsp_axid_d2_o                 ( awctrl_brsp_axid_d2           )
                   ,.awctrl_brsp_resperr_d2_o              ( awctrl_brsp_resperr_d2        )
               );

    rni_wr_buffer `RNI_PARAM_INST
                  rni_wr_buffer_inst(
                      // global inputs
                      .clk_i                                 ( CLK                           )
                      ,.rst_i                                 ( RST                           )
                      ,.aw_alloc_valid_s2_i                   ( awctrl_alloc_valid_s2         )
                      ,.aw_alloc_entry_s2_i                   ( awctrl_alloc_entry_s2         )
                      ,.aw_ctmask_s2_i                        ( awctrl_ctmask_s2              )
                      ,.aw_pdmask_s2_i                        ( awctrl_pdmask_s2              )
                      ,.aw_bc_vec_s2_i                        ( awctrl_bc_vec_s2              )
                      ,.awctrl_dealloc_entry_i                ( awctrl_dealloc_entry          )
                      ,.wb_req_fifo_pfull_d1_o                ( wb_req_fifo_pfull_d1          )
                      ,.wb_req_done_d3_o                      ( wb_req_done_d3                )
                      ,.wb_req_entry_d3_o                     ( wb_req_entry_d3               )
                      ,.wb_not_busy_d1_o                      ( wb_not_busy_d1                )
                      ,.txdat_rdy_v_d2_q_i                    ( awctrl_txdat_rdy_v_d2         )
                      ,.txdat_rdy_entry_d2_q_i                ( awctrl_txdat_rdy_entry_d2     )
                      ,.txdat_qos_d2_i                        ( awctrl_txdat_qos_d2           )
                      ,.txdat_compack_d2_i                    ( awctrl_txdat_compack_d2       )
                      ,.txdat_dbid_d2_i                       ( awctrl_txdat_dbid_d2          )
                      ,.txdat_tgtid_d2_i                      ( awctrl_txdat_tgtid_d2         )
                      ,.txdat_ccid_d2_i                       ( awctrl_txdat_ccid_d2          )
                      ,.txdat_ctmask_d2_q_i                   ( awctrl_txdat_ctmask_d2        )
                      ,.wb_txdat_not_busy_d2_o                ( awctrl_txdat_not_busy_d2      )
                      ,.wb_brsp_fifo_pop_d3_o                 ( awctrl_brsp_fifo_pop_d3       )
                      ,.brsp_rdy_v_d2_i                       ( awctrl_brsp_rdy_v_d2          )
                      ,.brsp_last_v_d2_q_i                    ( awctrl_brsp_last_v_d2         )
                      ,.brsp_axid_d2_i                        ( awctrl_brsp_axid_d2           )
                      ,.brsp_resperr_d2_i                     ( awctrl_brsp_resperr_d2        )
                      ,.W_CH_S0                               ( W_CH_S0                       )
                      ,.WVALID0                               ( WVALID0                       )
                      ,.WREADY0                               ( WREADY0                       )
                      ,.B_CH_S0                               ( B_CH_S0                       )
                      ,.BVALID0                               ( BVALID0                       )
                      ,.BREADY0                               ( BREADY0                       )
                      ,.wb_txdatflit_d3_o                     ( wb_txdatflit_d3               )
                      ,.wb_txdatflitv_d3_o                    ( wb_txdatflitv_d3              )
                      ,.wb_txdatflit_sent_d3_i                ( wb_txdatflit_sent_d3          )
                  );

    rni_link_ctl `RNI_PARAM_INST
                 rni_link_ctl_inst(
                     // global inputs
                     .clk_i                                 ( CLK                           )
                     ,.rst_i                                 ( RST                           )

                     // link handshake
                     ,.TXLINKACTIVEREQ                       ( TXLINKACTIVEREQ               )
                     ,.TXLINKACTIVEACK                       ( TXLINKACTIVEACK               )
                     ,.RXLINKACTIVEREQ                       ( RXLINKACTIVEREQ               )
                     ,.RXLINKACTIVEACK                       ( RXLINKACTIVEACK               )

                     // CHI Interface
                     ,.RXRSPFLITPEND                         ( RXRSPFLITPEND                 )
                     ,.RXRSPFLITV                            ( RXRSPFLITV                    )
                     ,.RXRSPFLIT                             ( RXRSPFLIT                     )
                     ,.RXRSPLCRDV                            ( RXRSPLCRDV                    )
                     ,.RXDATFLITPEND                         ( RXDATFLITPEND                 )
                     ,.RXDATFLITV                            ( RXDATFLITV                    )
                     ,.RXDATFLIT                             ( RXDATFLIT                     )
                     ,.RXDATLCRDV                            ( RXDATLCRDV                    )
                     ,.TXDATFLITPEND                         ( TXDATFLITPEND                 )
                     ,.TXDATFLITV                            ( TXDATFLITV                    )
                     ,.TXDATFLIT                             ( TXDATFLIT                     )
                     ,.TXDATLCRDV                            ( TXDATLCRDV                    )
                     ,.TXRSPFLITPEND                         ( TXRSPFLITPEND                 )
                     ,.TXRSPFLITV                            ( TXRSPFLITV                    )
                     ,.TXRSPFLIT                             ( TXRSPFLIT                     )
                     ,.TXRSPLCRDV                            ( TXRSPLCRDV                    )
                     ,.TXREQFLITPEND                         ( TXREQFLITPEND                 )
                     ,.TXREQFLITV                            ( TXREQFLITV                    )
                     ,.TXREQFLIT                             ( TXREQFLIT                     )
                     ,.TXREQLCRDV                            ( TXREQLCRDV                    )

                     // input from rni_wr_buffer
                     ,.wb_txdatflit_d3_i                     ( wb_txdatflit_d3               )
                     ,.wb_txdatflitv_d3_i                    ( wb_txdatflitv_d3              )
                     ,.wb_txdatflit_sent_d3_o                ( wb_txdatflit_sent_d3          )

                     // input from rni_arctrl
                     ,.ar_txreqflit_s4_i                     ( arctrl_txreqflit_s4           )
                     ,.ar_txreqflitv_s4_i                    ( arctrl_txreqflitv_s4          )
                     ,.ar_txreqflit_sent_s4_o                ( arctrl_txreqflit_sent_s4      )

                     // input from rni_awctrl
                     ,.aw_txrspflit_d0_i                     ( awctrl_txrspflit_d0           )
                     ,.aw_txrspflitv_d0_i                    ( awctrl_txrspflitv_d0          )
                     ,.aw_txrspflit_sent_d0_o                ( awctrl_txrspflit_sent_d0      )
                     ,.aw_txreqflit_s4_i                     ( awctrl_txreqflit_s4           )
                     ,.aw_txreqflitv_s4_i                    ( awctrl_txreqflitv_s4          )
                     ,.aw_txreqflit_sent_s4_o                ( awctrl_txreqflit_sent_s4      )

                     // outputs to rni_arctrl/rni_awctrl/rni_rd_buffer/rni_misc
                     ,.rxrspflitv_d1_o                       ( rxrspflitv_d1                 )
                     ,.rxrspflit_d1_q_o                      ( rxrspflit_d1_q                )
                     ,.rxdatflitv_d1_o                       ( rxdatflitv_d1                 )
                     ,.rxdatflit_d1_q_o                      ( rxdatflit_d1                  )
                 );
endmodule
