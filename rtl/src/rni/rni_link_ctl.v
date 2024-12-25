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

module rni_link_ctl `RNI_PARAM
    (
        // global inputs
        clk_i
        ,rst_i

        // link handshake
        ,TXLINKACTIVEREQ
        ,TXLINKACTIVEACK
        ,RXLINKACTIVEREQ
        ,RXLINKACTIVEACK

        // CHI Interface
        ,RXRSPFLITPEND
        ,RXRSPFLITV
        ,RXRSPFLIT
        ,RXRSPLCRDV
        ,RXDATFLITPEND
        ,RXDATFLITV
        ,RXDATFLIT
        ,RXDATLCRDV
        ,TXDATFLITPEND
        ,TXDATFLITV
        ,TXDATFLIT
        ,TXDATLCRDV
        ,TXRSPFLITPEND
        ,TXRSPFLITV
        ,TXRSPFLIT
        ,TXRSPLCRDV
        ,TXREQFLITPEND
        ,TXREQFLITV
        ,TXREQFLIT
        ,TXREQLCRDV

        // input from rni_wr_buffer
        ,wb_txdatflit_d3_i
        ,wb_txdatflitv_d3_i
        ,wb_txdatflit_sent_d3_o

        // input from rni_ar_ctl
        ,ar_txreqflit_s4_i
        ,ar_txreqflitv_s4_i
        ,ar_txreqflit_sent_s4_o

        // input from rni_aw_ctl
        ,aw_txrspflit_d0_i
        ,aw_txrspflitv_d0_i
        ,aw_txrspflit_sent_d0_o
        ,aw_txreqflit_s4_i
        ,aw_txreqflitv_s4_i
        ,aw_txreqflit_sent_s4_o

        // outputs to rni_ar_ctl/rni_aw_ctl/rni_rd_buffer/rni_misc
        ,rxrspflitv_d1_o
        ,rxrspflit_d1_q_o
        ,rxdatflitv_d1_o
        ,rxdatflit_d1_q_o
    );
    // global inputs
    input  wire                            clk_i;
    input  wire                            rst_i;

    // link handshake
    output wire                            TXLINKACTIVEREQ;
    input  wire                            TXLINKACTIVEACK;
    input  wire                            RXLINKACTIVEREQ;
    output wire                            RXLINKACTIVEACK;

    // CHI Interface
    input  wire                            RXRSPFLITPEND;
    input  wire                            RXRSPFLITV;
    input  wire [`CHIE_RSP_FLIT_RANGE]     RXRSPFLIT;
    output reg                             RXRSPLCRDV;
    input  wire                            RXDATFLITPEND;
    input  wire                            RXDATFLITV;
    input  wire [`CHIE_DAT_FLIT_RANGE]     RXDATFLIT;
    output reg                             RXDATLCRDV;
    output wire                            TXDATFLITPEND;
    output wire                            TXDATFLITV;
    output wire [`CHIE_DAT_FLIT_RANGE]     TXDATFLIT;
    input  wire                            TXDATLCRDV;
    output wire                            TXRSPFLITPEND;
    output wire                            TXRSPFLITV;
    output wire [`CHIE_RSP_FLIT_RANGE]     TXRSPFLIT;
    input  wire                            TXRSPLCRDV;
    output wire                            TXREQFLITPEND;
    output wire                            TXREQFLITV;
    output wire [`CHIE_REQ_FLIT_RANGE]     TXREQFLIT;
    input  wire                            TXREQLCRDV;

    // rni_wr_buffer Interface
    input  wire [`CHIE_DAT_FLIT_WIDTH-1:0] wb_txdatflit_d3_i;
    input  wire                            wb_txdatflitv_d3_i;
    output wire                            wb_txdatflit_sent_d3_o;

    // rni_ar_ctl Interface
    input  wire [`CHIE_REQ_FLIT_WIDTH-1:0] ar_txreqflit_s4_i;
    input  wire                            ar_txreqflitv_s4_i;
    output wire                            ar_txreqflit_sent_s4_o;

    // rni_aw_ctl Interface
    input  wire [`CHIE_RSP_FLIT_WIDTH-1:0] aw_txrspflit_d0_i;
    input  wire                            aw_txrspflitv_d0_i;
    output wire                            aw_txrspflit_sent_d0_o;
    input  wire [`CHIE_REQ_FLIT_WIDTH-1:0] aw_txreqflit_s4_i;
    input  wire                            aw_txreqflitv_s4_i;
    output wire                            aw_txreqflit_sent_s4_o;

    // outputs to rni_ar_ctl/rni_aw_ctl/rni_rd_buffer/rni_misc
    output wire                            rxrspflitv_d1_o;
    output reg  [`CHIE_RSP_FLIT_RANGE]     rxrspflit_d1_q_o;
    output wire                            rxdatflitv_d1_o;
    output reg  [`CHIE_DAT_FLIT_RANGE]     rxdatflit_d1_q_o;

    // internal wire
    wire                                   rxrsplcrdv_d1_w;
    wire                                   rxdatlcrdv_d1_w;
    wire                                   rxrsp_lcrd_full_d2_w;
    wire                                   rxdat_lcrd_full_d2_w;
    wire                                   rxrsp_lcrd_avail_d1_w;
    wire                                   rxdat_lcrd_avail_d1_w;
    wire                                   txdat_lcrd_avail_d3_w;
    wire                                   txrsp_lcrd_avail_d0_w;
    wire                                   txreq_lcrd_avail_s4_w;
    wire                                   txdatflitv_en_w;
    wire [`CHIE_DAT_FLIT_RANGE]            txdatflit_d3_w;
    wire                                   ax_txrspflitv_d0_w;
    wire                                   ax_txrspflit_upd_d0_w;
    wire                                   ax_txrspflit_sel_d0_w;
    wire                                   ax_txrspflit_sent_d0_w;
    wire                                   txrspflitv_en_w;
    wire [`CHIE_RSP_FLIT_RANGE]            txrspflit_d0_w;
    wire [1:0]                             ax_txreqflitv_s4_w;
    wire                                   ax_txreqflit_upd_s4_w;
    wire [1:0]                             ax_txreqflit_sel_s4_w;
    wire                                   ax_txreqflit_sent_s4_w;
    wire                                   txreqflitv_en_w;
    wire [`CHIE_REQ_FLIT_RANGE]            txreqflit_s4_w;
    wire [`LL_STATE_WIDTH-1:0]             txlink_state;
    wire [`LL_STATE_WIDTH-1:0]             rxlink_state;
    wire                                   txflit_avail;
    wire                                   txll_st_run;
    wire                                   rxll_st_run;
    wire                                   llst_is_run;
    wire                                   rxcrd_cnt_full;
    wire                                   lcrd_return_en;
    wire                                   rxcrd_en;
    wire                                   txdatflit_lcrd_v;
    wire                                   txrspflit_lcrd_v;
    wire                                   txreqflit_lcrd_v;

    // internal reg
    reg                                    rxrspflitpend_d1_q;
    reg                                    rxrspflitv_d1_q;
    reg                                    rxdatflitpend_d1_q;
    reg                                    rxdatflitv_d1_q;
    reg                                    txdatflitv_d4_q;
    reg  [`CHIE_DAT_FLIT_RANGE]            txdatflit_d4_q;
    reg                                    txrspflitv_d1_q;
    reg  [`CHIE_RSP_FLIT_RANGE]            txrspflit_d1_q;
    reg                                    txreqflitv_s5_q;
    reg  [`CHIE_REQ_FLIT_RANGE]            txreqflit_s5_q;
    reg  [`CHIE_DAT_FLIT_RANGE]            txdatflit_lcrd_d4;
    reg  [`CHIE_RSP_FLIT_RANGE]            txrspflit_lcrd_d4;
    reg  [`CHIE_REQ_FLIT_RANGE]            txreqflit_lcrd_d4;

    // local parameter
    localparam XP_LCRD_NUM_PARAM = 15;

    // main function
    // Initial channel pending
`ifdef LINKFLITPEND_EN

    assign TXDATFLITPEND = wb_txdatflitv_d3_i | txdatflit_lcrd_v;
    assign TXRSPFLITPEND = aw_txrspflitv_d0_i | txrspflit_lcrd_v;
    assign TXREQFLITPEND = ar_txreqflitv_s4_i | aw_txreqflitv_s4_i | txreqflit_lcrd_v;
`else
    assign TXDATFLITPEND = 1'b1;
    assign TXRSPFLITPEND = 1'b1;
    assign TXREQFLITPEND = 1'b1;
`endif

    //*************************************************
    //                Link HandShake
    //*************************************************
    assign txflit_avail   = wb_txdatflitv_d3_i | aw_txrspflitv_d0_i | ar_txreqflitv_s4_i | aw_txreqflitv_s4_i;

    assign txll_st_run    = (txlink_state == `LL_RUN);
    assign rxll_st_run    = (rxlink_state == `LL_RUN);
    assign llst_is_run    = txll_st_run & rxll_st_run;
    assign rxcrd_cnt_full = rxrsp_lcrd_full_d2_w & rxdat_lcrd_full_d2_w & ~llst_is_run;

    rni_link_handshake inst_rni_link_handshake(
                           .clk               ( clk_i           )
                           ,.rst               ( rst_i           )
                           ,.TXLINKACTIVEREQ   ( TXLINKACTIVEREQ )
                           ,.TXLINKACTIVEACK   ( TXLINKACTIVEACK )
                           ,.RXLINKACTIVEREQ   ( RXLINKACTIVEREQ )
                           ,.RXLINKACTIVEACK   ( RXLINKACTIVEACK )
                           ,.txlink_state      ( txlink_state    )
                           ,.rxlink_state      ( rxlink_state    )
                           ,.txflit_avail      ( txflit_avail    )
                           ,.rxcrd_cnt_full    ( rxcrd_cnt_full  )
                           ,.lcrd_return_en    ( lcrd_return_en  )
                           ,.rxcrd_en          ( rxcrd_en        )
                       );

    always @* begin
        if(rst_i == 1'b1)begin
            txdatflit_lcrd_d4[`CHIE_DAT_FLIT_WIDTH-1:0] = {`CHIE_DAT_FLIT_WIDTH{1'b0}};
        end
        else begin
            txdatflit_lcrd_d4[`CHIE_DAT_FLIT_OPCODE_MSB:`CHIE_DAT_FLIT_OPCODE_LSB] = `CHIE_DATLCRDRETURN;
            txdatflit_lcrd_d4[`CHIE_DAT_FLIT_SRCID_MSB:`CHIE_DAT_FLIT_SRCID_LSB]  = RNI_NID_PARAM;
        end
    end

    assign txdatflit_lcrd_v = lcrd_return_en & txdat_lcrd_avail_d3_w;

    always @* begin
        if(rst_i == 1'b1)begin
            txrspflit_lcrd_d4 = {`CHIE_RSP_FLIT_WIDTH{1'b0}};
        end
        else begin
            txrspflit_lcrd_d4[`CHIE_RSP_FLIT_OPCODE_RANGE] = `CHIE_RSPLCRDRETURN;
            txrspflit_lcrd_d4[`CHIE_RSP_FLIT_SRCID_RANGE]  = RNI_NID_PARAM;
        end
    end

    assign txrspflit_lcrd_v = lcrd_return_en & txrsp_lcrd_avail_d0_w;

    always @* begin
        if(rst_i == 1'b1)begin
            txreqflit_lcrd_d4 = {`CHIE_REQ_FLIT_WIDTH{1'b0}};
        end
        else begin
            txreqflit_lcrd_d4[`CHIE_REQ_FLIT_OPCODE_RANGE] = `CHIE_REQLCRDRETURN;
            txreqflit_lcrd_d4[`CHIE_REQ_FLIT_SRCID_RANGE]  = RNI_NID_PARAM;
        end
    end

    assign txreqflit_lcrd_v = lcrd_return_en & txreq_lcrd_avail_s4_w;

    //***************** RXRSP Channel *****************
    //         D0                         D1                    D2
    //       RXRSPFLIT              rxrspflit_d1_q_o          RXRSPLCRDV
    //       RXRSPFLITV             rxrspflitv_d1_q
    //
    //*************************************************
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            rxrspflitpend_d1_q <= 1'b0;
        else
            rxrspflitpend_d1_q <= RXRSPFLITPEND;
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            rxrspflitv_d1_q <= 1'b0;
        else
            rxrspflitv_d1_q <= RXRSPFLITV;
    end

    assign rxrspflitv_d1_o = rxrspflitv_d1_q & (rxrspflit_d1_q_o[`CHIE_RSP_FLIT_OPCODE_RANGE] != `CHIE_RSPLCRDRETURN);

    // RXRSPFLITPEND is used when LINKFLITPEND_EN assert on
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            rxrspflit_d1_q_o <= {`CHIE_RSP_FLIT_WIDTH{1'b0}};
`ifdef LINKFLITPEND_EN

        else if (rxrspflitpend_d1_q == 1'b1 && RXRSPFLITV == 1'b1)
            rxrspflit_d1_q_o <= RXRSPFLIT;
`else
        else if (RXRSPFLITV == 1'b1)
            rxrspflit_d1_q_o <= RXRSPFLIT;
`endif

        else
            rxrspflit_d1_q_o <= rxrspflit_d1_q_o;
    end

    assign rxrsplcrdv_d1_w = rxrsp_lcrd_avail_d1_w & rxcrd_en;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            RXRSPLCRDV <= 1'b0;
        else
            RXRSPLCRDV <= rxrsplcrdv_d1_w;
    end

    rni_lcrd_hdlr #(
                      .LCRD_INIT_CNT_VAL ( XP_LCRD_NUM_PARAM      )
                      ,.LCRD_MAX_CNT_VAL  ( XP_LCRD_NUM_PARAM      )
                  )rxrsp_lcrd_hdlr(
                      .clk               ( clk_i                  )
                      ,.rst               ( rst_i                  )
                      ,.lcrd_inc          ( rxrspflitv_d1_q        )
                      ,.lcrd_dec          ( rxrsplcrdv_d1_w        )
                      ,.lcrd_full         ( rxrsp_lcrd_full_d2_w   )
                      ,.lcrd_avail        ( rxrsp_lcrd_avail_d1_w  )
                  );

    //***************** RXDAT Channel *****************
    //         D0                         D1                    D2
    //       RXDATFLIT              rxdatflit_d1_q_o          RXDATLCRDV
    //       RXDATFLITV             rxdatflitv_d1_q
    //
    //*************************************************
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            rxdatflitpend_d1_q <= 1'b0;
        else
            rxdatflitpend_d1_q <= RXDATFLITPEND;
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            rxdatflitv_d1_q <= 1'b0;
        else
            rxdatflitv_d1_q <= RXDATFLITV;
    end

    assign rxdatflitv_d1_o = rxdatflitv_d1_q & (rxdatflit_d1_q_o[`CHIE_DAT_FLIT_OPCODE_RANGE] != `CHIE_DATLCRDRETURN);

    // RXDATFLITPEND is used when LINKFLITPEND_EN assert on
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            rxdatflit_d1_q_o <= {`CHIE_DAT_FLIT_WIDTH{1'b0}};
`ifdef LINKFLITPEND_EN

        else if (rxdatflitpend_d1_q == 1'b1 && RXDATFLITV == 1'b1)
            rxdatflit_d1_q_o <= RXDATFLIT;
`else
        else if (RXDATFLITV == 1'b1)
            rxdatflit_d1_q_o <= RXDATFLIT;
`endif

        else
            rxdatflit_d1_q_o <= rxdatflit_d1_q_o;
    end

    assign rxdatlcrdv_d1_w = rxdat_lcrd_avail_d1_w & rxcrd_en;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            RXDATLCRDV <= 1'b0;
        else
            RXDATLCRDV <= rxdatlcrdv_d1_w;
    end

    rni_lcrd_hdlr #(
                      .LCRD_INIT_CNT_VAL ( XP_LCRD_NUM_PARAM      )
                      ,.LCRD_MAX_CNT_VAL  ( XP_LCRD_NUM_PARAM      )
                  )rxdat_lcrd_hdlr(
                      .clk               ( clk_i                  )
                      ,.rst               ( rst_i                  )
                      ,.lcrd_inc          ( rxdatflitv_d1_q        )
                      ,.lcrd_dec          ( rxdatlcrdv_d1_w        )
                      ,.lcrd_full         ( rxdat_lcrd_full_d2_w   )
                      ,.lcrd_avail        ( rxdat_lcrd_avail_d1_w  )
                  );

    //***************** TXDAT Channel *****************
    //         D3                         D4
    //    wb_txdatflit_d3_i            TXDATFLIT
    //    wb_txdatflitv_d3_i           TXDATFLITV
    //  wb_txdatflit_sent_d3_o
    //    TXDATFLITPEND
    //*************************************************
    rni_lcrd_hdlr #(
                      .LCRD_INIT_CNT_VAL ( 0                      )
                      ,.LCRD_MAX_CNT_VAL  ( XP_LCRD_NUM_PARAM      )
                  )txdat_lcrd_hdlr(
                      .clk               ( clk_i                  )
                      ,.rst               ( rst_i                  )
                      ,.lcrd_inc          ( TXDATLCRDV             ) // TXDATLCRDV -> txdatlcrdv_q ?
                      ,.lcrd_dec          ( wb_txdatflit_sent_d3_o )
                      ,.lcrd_full         (                        )
                      ,.lcrd_avail        ( txdat_lcrd_avail_d3_w  )
                  );

    assign wb_txdatflit_sent_d3_o = (wb_txdatflitv_d3_i & txdat_lcrd_avail_d3_w & ~lcrd_return_en & txll_st_run) | txdatflit_lcrd_v;
    assign txdatflitv_en_w = wb_txdatflit_sent_d3_o | txdatflitv_d4_q;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            txdatflitv_d4_q <= 1'b0;
        else if (txdatflitv_en_w == 1'b1)
            txdatflitv_d4_q <= wb_txdatflit_sent_d3_o;
    end

    assign TXDATFLITV = txdatflitv_d4_q;

    assign txdatflit_d3_w = txdatflit_lcrd_v? txdatflit_lcrd_d4 : wb_txdatflit_d3_i;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            txdatflit_d4_q <= {`CHIE_DAT_FLIT_WIDTH{1'b0}};
        else if (wb_txdatflit_sent_d3_o == 1'b1)
            txdatflit_d4_q <= txdatflit_d3_w;
    end

    assign TXDATFLIT = txdatflit_d4_q;

    //***************** TXRSP Channel *****************
    //         D0                         D1
    //  ax_txrspflit_d0_i             TXRSPFLIT
    //  ax_txrspflitv_d0_i            TXRSPFLITV
    //  ax_txrspflit_sent_d0_o
    //    TXRSPFLITPEND
    //*************************************************
    rni_lcrd_hdlr #(
                      .LCRD_INIT_CNT_VAL ( 0                      )
                      ,.LCRD_MAX_CNT_VAL  ( XP_LCRD_NUM_PARAM      )
                  )txrsp_lcrd_hdlr(
                      .clk               ( clk_i                  )
                      ,.rst               ( rst_i                  )
                      ,.lcrd_inc          ( TXRSPLCRDV             ) // TXRSPLCRDV -> txrsplcrdv_q ?
                      ,.lcrd_dec          ( ax_txrspflit_sent_d0_w )
                      ,.lcrd_full         (                        )
                      ,.lcrd_avail        ( txrsp_lcrd_avail_d0_w  )
                  );

    assign ax_txrspflitv_d0_w    = aw_txrspflitv_d0_i;
    assign ax_txrspflit_upd_d0_w = txrsp_lcrd_avail_d0_w & (aw_txrspflitv_d0_i);

    poll_function #(
                      .POLL_ENTRIES_NUM  ( 1                      )
                      ,.POLL_MODE         ( 1'b1                   )
                  )txrsp_poll(
                      .clk               ( clk_i                  )
                      ,.rst               ( rst_i                  )
                      ,.entry_vec         ( ax_txrspflitv_d0_w     )
                      ,.upd               ( ax_txrspflit_upd_d0_w  )
                      ,.found             (                        )
                      ,.sel_entry         ( ax_txrspflit_sel_d0_w  )
                      ,.sel_index         (                        )
                  );

    assign aw_txrspflit_sent_d0_o = (ax_txrspflit_sel_d0_w & aw_txrspflitv_d0_i & txrsp_lcrd_avail_d0_w & ~lcrd_return_en & txll_st_run) | txrspflit_lcrd_v;
    assign ax_txrspflit_sent_d0_w = aw_txrspflit_sent_d0_o;

    assign txrspflitv_en_w = ax_txrspflit_sent_d0_w | txrspflitv_d1_q;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            txrspflitv_d1_q <= 1'b0;
        else if (txrspflitv_en_w == 1'b1)
            txrspflitv_d1_q <= ax_txrspflit_sent_d0_w;
    end

    assign TXRSPFLITV = txrspflitv_d1_q;

    assign txrspflit_d0_w = txrspflit_lcrd_v? txrspflit_lcrd_d4 : ({`CHIE_RSP_FLIT_WIDTH{ax_txrspflit_sel_d0_w}} & aw_txrspflit_d0_i);

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            txrspflit_d1_q <= {`CHIE_RSP_FLIT_WIDTH{1'b0}};
        else if (ax_txrspflit_sent_d0_w == 1'b1)
            txrspflit_d1_q <= txrspflit_d0_w;
    end

    assign TXRSPFLIT = txrspflit_d1_q;

    //***************** TXREQ Channel *****************
    //         S4                         S5
    //  ax_txreqflit_s4_i              TXREQFLIT
    //  ax_txreqflitv_s4_i             TXREQFLITV
    //  ax_txreqflit_sent_s4_o
    //    TXREQFLITPEND
    //*************************************************
    rni_lcrd_hdlr #(
                      .LCRD_INIT_CNT_VAL ( 0                      )
                      ,.LCRD_MAX_CNT_VAL  ( XP_LCRD_NUM_PARAM      )
                  )txreq_lcrd_hdlr(
                      .clk               ( clk_i                  )
                      ,.rst               ( rst_i                  )
                      ,.lcrd_inc          ( TXREQLCRDV             ) // TXREQLCRDV -> txreqlcrdv_q ?
                      ,.lcrd_dec          ( ax_txreqflit_sent_s4_w )
                      ,.lcrd_full         (                        )
                      ,.lcrd_avail        ( txreq_lcrd_avail_s4_w  )
                  );

    assign ax_txreqflitv_s4_w    = {aw_txreqflitv_s4_i, ar_txreqflitv_s4_i};
    assign ax_txreqflit_upd_s4_w = txreq_lcrd_avail_s4_w & (aw_txreqflitv_s4_i | ar_txreqflitv_s4_i);

    poll_function #(
                      .POLL_ENTRIES_NUM ( 2                       )
                      ,.POLL_MODE        ( 1'b1                    )
                  )txreq_poll(
                      .clk              ( clk_i                   )
                      ,.rst              ( rst_i                   )
                      ,.entry_vec        ( ax_txreqflitv_s4_w      )
                      ,.upd              ( ax_txreqflit_upd_s4_w   )
                      ,.found            (                         )
                      ,.sel_entry        ( ax_txreqflit_sel_s4_w   )
                      ,.sel_index        (                         )
                  );

    assign ar_txreqflit_sent_s4_o = ax_txreqflit_sel_s4_w[0] & ar_txreqflitv_s4_i & txreq_lcrd_avail_s4_w & ~lcrd_return_en & txll_st_run;
    assign aw_txreqflit_sent_s4_o = ax_txreqflit_sel_s4_w[1] & aw_txreqflitv_s4_i & txreq_lcrd_avail_s4_w & ~lcrd_return_en & txll_st_run;
    assign ax_txreqflit_sent_s4_w = (ar_txreqflit_sent_s4_o | aw_txreqflit_sent_s4_o | txreqflit_lcrd_v);

    assign txreqflitv_en_w = ax_txreqflit_sent_s4_w | txreqflitv_s5_q;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            txreqflitv_s5_q <= 1'b0;
        else if (txreqflitv_en_w == 1'b1)
            txreqflitv_s5_q <= ax_txreqflit_sent_s4_w;
    end

    assign TXREQFLITV = txreqflitv_s5_q;

    assign txreqflit_s4_w = txreqflit_lcrd_v? txreqflit_lcrd_d4 : (({`CHIE_REQ_FLIT_WIDTH{ax_txreqflit_sel_s4_w[0]}} & ar_txreqflit_s4_i) |
            ({`CHIE_REQ_FLIT_WIDTH{ax_txreqflit_sel_s4_w[1]}} & aw_txreqflit_s4_i));

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            txreqflit_s5_q <= {`CHIE_REQ_FLIT_WIDTH{1'b0}};
        else if (ax_txreqflit_sent_s4_w == 1'b1)
            txreqflit_s5_q <= txreqflit_s4_w;
    end

    assign TXREQFLIT = txreqflit_s5_q;

    // Assertion Checker
`ifdef ASSERT_CHECKER_ON
    `ifdef LINKFLITPEND_EN

    assert_checker #(
                       3,  // security_level
                       "Received RXRSPFLITV with RXRSPFLITPEND deasserted in the previous cycle!")
                   RXRSPFLITV_check (
                       .clk   ( clk_i ),
                       .rst   ( rst_i ),
                       .cond  ( (rxrspflitpend_d1_q == 0 && RXRSPFLITV == 1) )
                   );

    assert_checker #(
                       3,  // security_level
                       "Received RXDATFLITV with RXDATFLITPEND deasserted in the previous cycle!")
                   RXDATFLITV_check (
                       .clk   ( clk_i ),
                       .rst   ( rst_i ),
                       .cond  ( (rxdatflitpend_d1_q == 0 && RXDATFLITV == 1) )
                   );
`endif
`endif
endmodule
