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

module rni_wr_buffer `RNI_PARAM
    (
        // global input
        clk_i
        ,rst_i

        // Aw_Ctl Interface
        // AW new request allocate
        ,aw_alloc_valid_s2_i
        ,aw_alloc_entry_s2_i
        ,aw_ctmask_s2_i
        ,aw_pdmask_s2_i
        ,aw_bc_vec_s2_i

        // AW request deallocate
        ,awctrl_dealloc_entry_i

        // AW misc
        ,wb_req_fifo_pfull_d1_o
        ,wb_req_done_d3_o
        ,wb_req_entry_d3_o

        // AW txdatflit fields
        ,wb_not_busy_d1_o
        ,txdat_rdy_v_d2_q_i
        ,txdat_rdy_entry_d2_q_i
        ,txdat_qos_d2_i
        ,txdat_compack_d2_i
        ,txdat_dbid_d2_i
        ,txdat_tgtid_d2_i
        ,txdat_ccid_d2_i
        ,txdat_ctmask_d2_q_i
        ,wb_txdat_not_busy_d2_o

        // B response fields
        ,wb_brsp_fifo_pop_d3_o
        ,brsp_rdy_v_d2_i
        ,brsp_last_v_d2_q_i
        ,brsp_axid_d2_i
        ,brsp_resperr_d2_i

        // W Channel Interface
        ,W_CH_S0
        ,WVALID0
        ,WREADY0

        // B Channel Interface
        ,B_CH_S0
        ,BVALID0
        ,BREADY0

        // Link Ctl Interface
        ,wb_txdatflit_d3_o
        ,wb_txdatflitv_d3_o
        ,wb_txdatflit_sent_d3_i
    );
    // local parameter

    // global input
    input  wire                                                     clk_i;
    input  wire                                                     rst_i;

    // Aw_Ctl Interface
    // request allocate
    input  wire                                                     aw_alloc_valid_s2_i;
    input  wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]                      aw_alloc_entry_s2_i;
    input  wire [`RNI_DMASK_CT_WIDTH-1:0]                           aw_ctmask_s2_i;
    input  wire [`RNI_DMASK_PD_WIDTH-1:0]                           aw_pdmask_s2_i;
    input  wire [`RNI_BCVEC_WIDTH-1:0]                              aw_bc_vec_s2_i;

    // request deallocate
    input  wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]                      awctrl_dealloc_entry_i;

    // misc
    output wire                                                     wb_req_fifo_pfull_d1_o;
    output wire                                                     wb_req_done_d3_o;
    output wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]                      wb_req_entry_d3_o;

    // txdatflit request
    output wire                                                     wb_not_busy_d1_o;
    input  wire                                                     txdat_rdy_v_d2_q_i;
    input  wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]                      txdat_rdy_entry_d2_q_i;
    input  wire [`CHIE_DAT_FLIT_QOS_WIDTH-1:0]                      txdat_qos_d2_i;
    input  wire                                                     txdat_compack_d2_i;
    input  wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]                     txdat_dbid_d2_i;
    input  wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]                    txdat_tgtid_d2_i;
    input  wire [`CHIE_DAT_FLIT_CCID_WIDTH-1:0]                     txdat_ccid_d2_i;
    input  wire [`RNI_DMASK_CT_WIDTH-1:0]                           txdat_ctmask_d2_q_i;
    output wire                                                     wb_txdat_not_busy_d2_o;

    // B response request
    output wire                                                     wb_brsp_fifo_pop_d3_o;
    input  wire                                                     brsp_rdy_v_d2_i;
    input  wire                                                     brsp_last_v_d2_q_i;
    input  wire [`AXI4_BID_WIDTH-1:0]                               brsp_axid_d2_i;
    input  wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]                  brsp_resperr_d2_i;

    // W Channel Interface
    input  wire [`AXI4_W_WIDTH-1:0]                                 W_CH_S0;
    input  wire                                                     WVALID0;
    output wire                                                     WREADY0;

    // B Channel Interface
    output wire [`AXI4_B_WIDTH-1:0]                                 B_CH_S0;
    output wire                                                     BVALID0;
    input  wire                                                     BREADY0;

    // Link Ctl Interface
    output reg  [`CHIE_DAT_FLIT_WIDTH-1:0]                          wb_txdatflit_d3_o;
    output wire                                                     wb_txdatflitv_d3_o;
    input  wire                                                     wb_txdatflit_sent_d3_i;

    // wire
    wire                                                            wd_fifo_push_d0_w;
    wire                                                            wd_fifo_pop_d0_w;
    wire [`WD_FIFO_ENTRIES_WIDTH-1:0]                               wd_fifo_in_d0_w;
    wire [`WD_FIFO_ENTRIES_WIDTH-1:0]                               wd_fifo_out_d1_w;
    wire                                                            wd_fifo_full_d1_w;
    wire                                                            wd_fifo_empty_d1_w;
    wire [`AXI4_W_WIDTH-1:0]                                        w_ch_d1_w;
    wire                                                            w_valid_d1_w;
    wire [`AXI4_WDATA_WIDTH-1:0]                                    w_data_d1_w;
    wire [`AXI4_WSTRB_WIDTH-1:0]                                    w_strb_d1_w;
    wire [`AXI4_WLAST_WIDTH-1:0]                                    w_last_d1_w;
    wire                                                            aw_req_avail_w;
    wire                                                            rq_wd_rdy_w;
    wire                                                            aw_req_fifo_push_s2_w;
    wire                                                            aw_req_fifo_pop_w;
    wire [`AW_REQ_FIFO_ENTRIES_WIDTH-1:0]                           aw_req_fifo_in_s2_w;
    wire [`AW_REQ_FIFO_ENTRIES_WIDTH-1:0]                           aw_req_fifo_out_s3_w;
    wire                                                            aw_req_fifo_empty_w;
    wire [4-1:0]                                                    aw_req_fifo_count_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]                             aw_new_alloc_entry_s3_w;
    wire [`RNI_DMASK_CT_WIDTH-1:0]                                  aw_ctmask_s3_w;
    wire [`RNI_DMASK_PD_WIDTH-1:0]                                  aw_pdmask_s3_w;
    wire [`RNI_BCVEC_WIDTH-1:0]                                     aw_bc_vec_s3_w;
    wire [`RNI_DMASK_CT_WIDTH-1:0]                                  aw_fdmask_s3_w;
    wire                                                            wb_bank_done_w;
    wire                                                            brsp_fifo_push_d2_w;
    wire [`BRSP_FIFO_ENTRIES_WIDTH-1:0]                             brsp_fifo_in_d2_w;
    wire [`BRSP_FIFO_ENTRIES_WIDTH-1:0]                             brsp_fifo_out_d3_w;
    wire                                                            brsp_fifo_empty_w;
    wire [RNI_AW_ENTRIES_NUM_PARAM-1:0]                             wr_entry_d1_w;
    wire [`WR_BUFFER_DATA_BANK_NUM-1:0]                             wr_bank_d1_w;
    wire [`WR_BUFFER_DATA_BANK_NUM*`AXI4_WSTRB_WIDTH-1:0]           wr_wstrb_d1_w[0:RNI_AW_ENTRIES_NUM_PARAM-1];
    wire [`WR_BUFFER_DATA_BANK_NUM*`AXI4_WSTRB_WIDTH-1:0]           w_strb_nxt_d1_w[0:RNI_AW_ENTRIES_NUM_PARAM-1];
    wire [`WR_BUFFER_DATA_BANK_NUM-1:0]                             w_strb_entry_bank_upd_d1_w[0:RNI_AW_ENTRIES_NUM_PARAM-1];
    wire                                                            txdat_info_flop_en_d2_w;
    wire [`RNI_DMASK_CT_WIDTH/2-1:0]                                txdat_ctmask_d3_w;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]                            txdat_data_d3_w;
    wire [`CHIE_DAT_FLIT_BE_WIDTH-1:0]                              txdat_be_d3_w;
    wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]                           txdatflit_txnid_d3_w;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]                          txdatflit_dataid_d3_w;
    wire [`CHIE_DAT_FLIT_BE_WIDTH-1:0]                              txdatflit_be_d3_w;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]                            txdatflit_data_d3_w;
    wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]                          txdatflit_opcode_d3_w;
    wire                                                            txdat_busy_d2_w;
    wire                                                            wb_busy_d1_w;

    // reg
    reg  [`WR_BUFFER_DATA_BANK_NUM*`AXI4_WSTRB_WIDTH-1:0]           w_strb_d2_q[0:RNI_AW_ENTRIES_NUM_PARAM-1];
    reg  [`WR_BUFFER_DATA_BANK_NUM*`WR_BUFFER_DATA_BANK_WIDTH-1:0]  w_data_d2_q[0:RNI_AW_ENTRIES_NUM_PARAM-1];
    reg  [`WR_BUFFER_DATA_BANK_NUM*`WR_BUFFER_DATA_BANK_WIDTH-1:0]  txdat_data_d2_r;
    reg  [`WR_BUFFER_DATA_BANK_NUM*`AXI4_WSTRB_WIDTH-1:0]           txdat_be_d2_r;
    reg  [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]                           txdat_rdy_idx_d2_r;
    reg  [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]                           txdat_rdy_idx_d3_q;
    reg  [`WR_BUFFER_DATA_BANK_NUM*`WR_BUFFER_DATA_BANK_WIDTH-1:0]  txdat_data_d3_q;
    reg  [`WR_BUFFER_DATA_BANK_NUM*`AXI4_WSTRB_WIDTH-1:0]           txdat_be_d3_q;
    reg  [`CHIE_DAT_FLIT_QOS_WIDTH-1:0]                             txdat_qos_d3_q;
    reg                                                             txdat_compack_d3_q;
    reg  [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]                            txdat_dbid_d3_q;
    reg  [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]                           txdat_tgtid_d3_q;
    reg  [`CHIE_DAT_FLIT_CCID_WIDTH-1:0]                            txdat_ccid_d3_q;
    reg  [`RNI_DMASK_CT_WIDTH-1:0]                                  txdat_ctmask_d3_q;
    reg                                                             txdat_rdy_v_d3_q;

    // var
    genvar  entry;
    genvar  bank;
    genvar  byt;
    integer i;

    // main function

    ////////////////////////////////////////////////////////
    // WDATA FIFO
    ////////////////////////////////////////////////////////

    assign wd_fifo_push_d0_w = WVALID0 & WREADY0;
    assign wd_fifo_in_d0_w   = W_CH_S0;

    sync_fifo #(
                  .FIFO_ENTRIES_WIDTH ( `WD_FIFO_ENTRIES_WIDTH ),
                  .FIFO_ENTRIES_DEPTH ( `WD_FIFO_ENTRIES_DEPTH ),
                  .FIFO_BYP_ENABLE    ( 1'b0                   )
              )wd_fifo(
                  .clk      ( clk_i                 ),
                  .rst      ( rst_i                 ),
                  .push     ( wd_fifo_push_d0_w     ),
                  .pop      ( wd_fifo_pop_d0_w      ),
                  .data_in  ( wd_fifo_in_d0_w       ),
                  .data_out ( wd_fifo_out_d1_w      ),
                  .empty    ( wd_fifo_empty_d1_w    ),
                  .full     ( wd_fifo_full_d1_w     ),
                  .count    (                       )
              );

    assign wd_fifo_pop_d0_w = rq_wd_rdy_w & ~wd_fifo_empty_d1_w;
    assign WREADY0 = ~wd_fifo_full_d1_w | wd_fifo_pop_d0_w;
    assign w_ch_d1_w = wd_fifo_out_d1_w;

    assign w_data_d1_w = w_ch_d1_w[`AXI4_WDATA_RANGE];
    assign w_strb_d1_w = w_ch_d1_w[`AXI4_WSTRB_RANGE];
    assign w_last_d1_w = w_ch_d1_w[`AXI4_WLAST_RANGE];

    ////////////////////////////////////////////////////////
    // AW Req info FIFO
    ////////////////////////////////////////////////////////

    assign aw_req_fifo_push_s2_w = aw_alloc_valid_s2_i;
    assign aw_req_fifo_in_s2_w = {aw_bc_vec_s2_i, aw_pdmask_s2_i, aw_ctmask_s2_i, aw_alloc_entry_s2_i};

    sync_fifo #(
                  .FIFO_ENTRIES_WIDTH ( `AW_REQ_FIFO_ENTRIES_WIDTH ),
                  .FIFO_ENTRIES_DEPTH ( `AW_REQ_FIFO_ENTRIES_DEPTH ),
                  .FIFO_BYP_ENABLE    ( 1'b0                       )
              )aw_req_fifo(
                  .clk      ( clk_i                     ),
                  .rst      ( rst_i                     ),
                  .push     ( aw_req_fifo_push_s2_w     ),
                  .pop      ( aw_req_fifo_pop_w         ),
                  .data_in  ( aw_req_fifo_in_s2_w       ),
                  .data_out ( aw_req_fifo_out_s3_w      ),
                  .empty    ( aw_req_fifo_empty_w       ),
                  .full     (                           ),
                  .count    ( aw_req_fifo_count_w       )
              );

    assign wb_req_fifo_pfull_d1_o = (aw_req_fifo_count_w >= (`AW_REQ_FIFO_ENTRIES_DEPTH-1));

    assign {aw_bc_vec_s3_w, aw_pdmask_s3_w, aw_ctmask_s3_w, aw_new_alloc_entry_s3_w} = aw_req_fifo_out_s3_w;
    assign aw_req_fifo_pop_w = wb_req_done_d3_o;
    assign wb_req_entry_d3_o = aw_new_alloc_entry_s3_w;

    ////////////////////////////////////////////////////////
    // beat count control
    // count and compute the received data beat.
    // fdmask: indicates the current data bank that is filling data beat.
    // bk_done: when received data beat filled one data bank (16 bytes).
    // rq_done: when received 64 bytes of data.
    ////////////////////////////////////////////////////////

    assign aw_req_avail_w = ~aw_req_fifo_empty_w;

    assign w_valid_d1_w = ~wd_fifo_empty_d1_w;

    assign rq_wd_rdy_w = aw_req_avail_w & w_valid_d1_w;

    rni_bcount_ctl
        rni_bcount_ctl_p0 (
            .clk            ( clk_i               ),
            .rst            ( rst_i               ),
            .rq_valid       ( rq_wd_rdy_w         ),
            .wd_valid       ( w_valid_d1_w        ),
            .bcount_vec     ( aw_bc_vec_s3_w      ),
            .ctmask         ( aw_ctmask_s3_w      ),
            .pdmask         ( aw_pdmask_s3_w      ),
            .fdmask         ( aw_fdmask_s3_w      ),
            .bk_done        ( wb_bank_done_w      ),
            .rq_done        ( wb_req_done_d3_o    )
        );

    ////////////////////////////////////////////////////////
    // WDB update
    ////////////////////////////////////////////////////////

    generate
        // write entry
        for(entry = 0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry = entry + 1)begin
            assign wr_entry_d1_w[entry] = aw_new_alloc_entry_s3_w[entry] & aw_req_avail_w & w_valid_d1_w;
        end

        //write bank
        for(bank = 0; bank < `WR_BUFFER_DATA_BANK_NUM; bank = bank + 1)begin
            assign wr_bank_d1_w[bank] = aw_fdmask_s3_w[bank] & aw_req_avail_w & w_valid_d1_w;
        end

        for(entry = 0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry = entry + 1)begin
            for(bank = 0; bank < `WR_BUFFER_DATA_BANK_NUM; bank = bank + 1)begin
                for(byt = 0; byt < `AXI4_WSTRB_WIDTH; byt = byt + 1)begin
                    assign wr_wstrb_d1_w[entry][bank*`AXI4_WSTRB_WIDTH + byt] = wr_entry_d1_w[entry] & wr_bank_d1_w[bank] & w_strb_d1_w[byt];

                    assign w_strb_nxt_d1_w[entry][bank*`AXI4_WSTRB_WIDTH + byt] = (wr_wstrb_d1_w[entry][bank*`AXI4_WSTRB_WIDTH + byt] | w_strb_d2_q[entry][bank*`AXI4_WSTRB_WIDTH + byt]) & ~awctrl_dealloc_entry_i[entry];
                end

                // write wstrb per entry per bank
                // set when each write bank valid in each valid write entry
                // clr when write entry deallocate
                assign w_strb_entry_bank_upd_d1_w[entry][bank] = (wr_entry_d1_w[entry] & wr_bank_d1_w[bank]) | awctrl_dealloc_entry_i[entry];
            end
        end
    endgenerate

    generate
        for(entry = 0; entry < RNI_AW_ENTRIES_NUM_PARAM; entry = entry + 1)begin
            for(bank = 0; bank < `WR_BUFFER_DATA_BANK_NUM; bank = bank + 1)begin
                for(byt = 0; byt < `AXI4_WSTRB_WIDTH; byt = byt + 1)begin

                    // update wstrb bank
                    always @(posedge clk_i or posedge rst_i) begin
                        if(rst_i == 1'b1)
                            w_strb_d2_q[entry][bank*`AXI4_WSTRB_WIDTH + byt] <= 1'b0;
                        else if(w_strb_entry_bank_upd_d1_w[entry][bank] == 1'b1)begin
                            w_strb_d2_q[entry][bank*`AXI4_WSTRB_WIDTH + byt] <= w_strb_nxt_d1_w[entry][bank*`AXI4_WSTRB_WIDTH + byt];
                        end
                    end

                    // update wdata bank
                    always @(posedge clk_i) begin
                        if(wr_wstrb_d1_w[entry][bank*`AXI4_WSTRB_WIDTH + byt] == 1'b1)begin
                            w_data_d2_q[entry][((bank*`WR_BUFFER_DATA_BANK_WIDTH)+(8*byt))+:8] <= w_data_d1_w[(8*byt)+:8];
                        end
                    end
                end
            end
        end
    endgenerate

    ////////////////////////////////////////////////////////
    // TXDAT entry select
    ////////////////////////////////////////////////////////

    // get 64 bytes DATA from write data bank
    always @* begin
        txdat_data_d2_r = {(`WR_BUFFER_DATA_BANK_NUM*`WR_BUFFER_DATA_BANK_WIDTH){1'b0}};
        for (i = 0; i < RNI_AW_ENTRIES_NUM_PARAM; i = i + 1)
            txdat_data_d2_r = txdat_data_d2_r | ({(`WR_BUFFER_DATA_BANK_NUM*`WR_BUFFER_DATA_BANK_WIDTH){txdat_rdy_entry_d2_q_i[i]}} & w_data_d2_q[i]);
    end

    // get 64 bits BE from write wstrb bank
    always @* begin
        txdat_be_d2_r = {(`WR_BUFFER_DATA_BANK_NUM*`AXI4_WSTRB_WIDTH){1'b0}};
        for (i = 0; i < RNI_AW_ENTRIES_NUM_PARAM; i = i + 1)
            txdat_be_d2_r = txdat_be_d2_r | ({(`WR_BUFFER_DATA_BANK_NUM*`AXI4_WSTRB_WIDTH){txdat_rdy_entry_d2_q_i[i]}} & w_strb_d2_q[i]);
    end

    // get index(TxnID) from ready entry vec
    always @* begin
        txdat_rdy_idx_d2_r = {`CHIE_DAT_FLIT_TXNID_WIDTH{1'b0}};
        for (i = 0; i < RNI_AW_ENTRIES_NUM_PARAM; i = i + 1)
            if (txdat_rdy_entry_d2_q_i[i])
                txdat_rdy_idx_d2_r = i;
            else
                txdat_rdy_idx_d2_r = txdat_rdy_idx_d2_r;
    end

    ////////////////////////////////////////////////////////
    // txdat dispath ready
    ////////////////////////////////////////////////////////

    // link_ctl txdat busy indication
    assign txdat_busy_d2_w    = txdat_rdy_v_d3_q & ~wb_txdatflit_sent_d3_i;
    assign wb_txdat_not_busy_d2_o = ~txdat_busy_d2_w;

    // wr_buffer busy indication
    assign wb_busy_d1_w = txdat_rdy_v_d2_q_i & txdat_busy_d2_w;
    assign wb_not_busy_d1_o = ~wb_busy_d1_w;

    // txdat ready indication from AW Ctl
    // it could be data ready or data cancel ready
    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i == 1'b1)
            txdat_rdy_v_d3_q <= 1'b0;
        else if(wb_txdat_not_busy_d2_o == 1'b1)
            txdat_rdy_v_d3_q <= txdat_rdy_v_d2_q_i;
    end

    // txdat info flop
    assign txdat_info_flop_en_d2_w = wb_txdat_not_busy_d2_o & txdat_rdy_v_d2_q_i;

    always @(posedge clk_i or posedge rst_i) begin
        if(rst_i == 1'b1)begin
            txdat_data_d3_q     <= 0;
            txdat_be_d3_q       <= 0;
            txdat_rdy_idx_d3_q  <= 0;
            txdat_qos_d3_q      <= 0;
            txdat_compack_d3_q  <= 0;
            txdat_dbid_d3_q     <= 0;
            txdat_tgtid_d3_q    <= 0;
            txdat_ccid_d3_q     <= 0;
            txdat_ctmask_d3_q   <= 0;
        end
        else if(txdat_info_flop_en_d2_w == 1'b1)begin
            txdat_data_d3_q     <= txdat_data_d2_r;
            txdat_be_d3_q       <= txdat_be_d2_r;
            txdat_rdy_idx_d3_q  <= txdat_rdy_idx_d2_r;
            txdat_qos_d3_q      <= txdat_qos_d2_i;
            txdat_compack_d3_q  <= txdat_compack_d2_i;
            txdat_dbid_d3_q     <= txdat_dbid_d2_i;
            txdat_tgtid_d3_q    <= txdat_tgtid_d2_i;
            txdat_ccid_d3_q     <= txdat_ccid_d2_i;
            txdat_ctmask_d3_q   <= txdat_ctmask_d2_q_i;
        end
    end

    // select high 256 bits or low 256 bits
    assign txdat_ctmask_d3_w = {(|txdat_ctmask_d3_q[3:2]), (|txdat_ctmask_d3_q[1:0])};

    assign txdat_data_d3_w = {`CHIE_DAT_FLIT_DATA_WIDTH{txdat_ctmask_d3_w[0]}} & txdat_data_d3_q[`CHIE_DAT_FLIT_DATA_WIDTH-1:0] |
           {`CHIE_DAT_FLIT_DATA_WIDTH{txdat_ctmask_d3_w[1]}} & txdat_data_d3_q[(`CHIE_DAT_FLIT_DATA_WIDTH*2)-1:`CHIE_DAT_FLIT_DATA_WIDTH];

    assign txdat_be_d3_w = {`CHIE_DAT_FLIT_BE_WIDTH{txdat_ctmask_d3_w[0]}} & txdat_be_d3_q[`CHIE_DAT_FLIT_BE_WIDTH-1:0] |
           {`CHIE_DAT_FLIT_BE_WIDTH{txdat_ctmask_d3_w[1]}} & txdat_be_d3_q[(`CHIE_DAT_FLIT_BE_WIDTH*2)-1:`CHIE_DAT_FLIT_BE_WIDTH];

    ////////////////////////////////////////////////////////
    // pack txdatflit and Dispatch
    ////////////////////////////////////////////////////////

    // txdatflit TxnID
    assign txdatflit_txnid_d3_w[`CHIE_DAT_FLIT_TXNID_WIDTH-2:0] = txdat_rdy_idx_d3_q[`CHIE_DAT_FLIT_TXNID_WIDTH-2:0];

    // write entry TxnID[MSB] = 1'b1, read entry TxnID[MSB] = 1'b0
    assign txdatflit_txnid_d3_w[`CHIE_DAT_FLIT_TXNID_WIDTH-1]   = 1'b1;

    // txdatflit DataID
    assign txdatflit_dataid_d3_w = ({2{txdat_ctmask_d3_w[0]}} & 2'b00) |
           ({2{txdat_ctmask_d3_w[1]}} & 2'b10) ;

    // txdatflit Be
    assign txdatflit_be_d3_w = txdat_be_d3_w;

    // txdatflit Data
    generate
        for (byt = 0; byt < `CHIE_DAT_FLIT_BE_WIDTH; byt = byt + 1)begin
            assign txdatflit_data_d3_w[(8*byt) +: 8] = ({8{txdatflit_be_d3_w[byt]}} & txdat_data_d3_w[(8*byt) +: 8]);
        end
    endgenerate

    generate
        if(CHIE_DAT_RSVDC_WIDTH_PARAM != 0)begin
            always @*begin
                wb_txdatflit_d3_o[`CHIE_DAT_FLIT_RSVDC_RANGE] = {`CHIE_DAT_FLIT_RSVDC_WIDTH{1'b0}};
            end
        end
    endgenerate


    // txdatflit Opcode
    assign txdatflit_opcode_d3_w[`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0] = txdat_compack_d3_q? `CHIE_NCBWRDATACOMPACK : `CHIE_NONCOPYBACKWRDATA;

    always@* begin
        wb_txdatflit_d3_o                                 = {`CHIE_DAT_FLIT_WIDTH{1'b0}};
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_QOS_RANGE]       = txdat_qos_d3_q;
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_TGTID_RANGE]     = txdat_tgtid_d3_q;
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_SRCID_RANGE]     = RNI_NID_PARAM;
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_TXNID_RANGE]     = txdat_dbid_d3_q;
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_OPCODE_RANGE]    = txdatflit_opcode_d3_w;
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_DBID_RANGE]      = txdatflit_txnid_d3_w;
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_CCID_RANGE]      = txdat_ccid_d3_q;
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_DATAID_RANGE]    = txdatflit_dataid_d3_w;
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_BE_RANGE]        = txdatflit_be_d3_w;
        wb_txdatflit_d3_o[`CHIE_DAT_FLIT_DATA_RANGE]      = txdatflit_data_d3_w;
    end

    // txdatflit valid
    assign wb_txdatflitv_d3_o = txdat_rdy_v_d3_q;

    ////////////////////////////////////////////////////////
    // B Response Dispatch
    ////////////////////////////////////////////////////////

    // Push into FIFO only when received last data beat
    assign brsp_fifo_push_d2_w = brsp_rdy_v_d2_i;
    assign brsp_fifo_in_d2_w   = {brsp_axid_d2_i,brsp_resperr_d2_i,brsp_last_v_d2_q_i};

    sync_fifo #(
                  .FIFO_ENTRIES_WIDTH ( `BRSP_FIFO_ENTRIES_WIDTH ),
                  .FIFO_ENTRIES_DEPTH ( `BRSP_FIFO_ENTRIES_DEPTH ),
                  .FIFO_BYP_ENABLE    ( 1'b0                     )
              )brsp_fifo(
                  .clk      ( clk_i                 ),
                  .rst      ( rst_i                 ),
                  .push     ( brsp_fifo_push_d2_w   ),
                  .pop      ( wb_brsp_fifo_pop_d3_o ),
                  .data_in  ( brsp_fifo_in_d2_w     ),
                  .data_out ( brsp_fifo_out_d3_w    ),
                  .empty    ( brsp_fifo_empty_w     ),
                  .full     (                       ),
                  .count    (                       )
              );

    assign wb_brsp_fifo_pop_d3_o = (~brsp_fifo_empty_w & ~brsp_fifo_out_d3_w[`BRSP_FIFO_LAST_RANGE]) | (BVALID0 & BREADY0);

    assign B_CH_S0[`AXI4_BID_RANGE]   = brsp_fifo_out_d3_w[`BRSP_FIFO_LAST_RANGE]? brsp_fifo_out_d3_w[`BRSP_FIFO_AXID_RANGE] : 0;
    assign B_CH_S0[`AXI4_BRESP_RANGE] = brsp_fifo_out_d3_w[`BRSP_FIFO_LAST_RANGE]? brsp_fifo_out_d3_w[`BRSP_FIFO_RESPERR_RANGE] : 0;

    assign BVALID0 = ~brsp_fifo_empty_w & brsp_fifo_out_d3_w[`BRSP_FIFO_LAST_RANGE];

    // Assertion Checker
`ifdef ASSERT_CHECKER_ON

    assert_checker #(
                       2,  // security_level
                       "aw_alloc_entry_s2_i is ZERO!")
                   aw_alloc_entry_s2_i_check (
                       .clk   (clk_i),
                       .rst   (rst_i),
                       .cond  (aw_alloc_valid_s2_i & ~(|aw_alloc_entry_s2_i))
                   );

    assert_checker #(
                       2,  // security_level
                       "txdat_rdy_entry_d2_q_i is ZERO!")
                   txdat_rdy_entry_d2_q_i_check (
                       .clk   (clk_i),
                       .rst   (rst_i),
                       .cond  ((txdat_rdy_v_d2_q_i) & ~(|txdat_rdy_entry_d2_q_i))
                   );
`endif

endmodule
