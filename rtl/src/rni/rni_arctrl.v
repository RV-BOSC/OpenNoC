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

`include "axi4_defines.v"
`include "chie_defines.v"
`include "rni_defines.v"
`include "rni_param.v"

module rni_arctrl
    `RNI_PARAM
        (
            clk_i
            ,rst_i

            // AXI AR0 channel
            ,AR_CH_S0
            ,ARVALID0
            ,ARREADY0

            // txreq outputs
            ,arctrl_txreqflitv_s4_o
            ,arctrl_txreqflit_s4_o
            ,arctrl_txreqflit_sent_s4_i

            // rxrsp inputs
            ,rxrspflitv_d1_i
            ,rxrspflit_d1_i

            // rxdat inputs
            ,rxdatflitv_d1_i
            ,rxdatflit_txnid_d1_i
            ,rxdatflit_dataid_d1_i

            // s0 rdata dispatch
            ,rp_fifo_acpt_d4_i
            ,arctrl_rb_valid_d4_o
            ,arctrl_rb_ctmask_d4_o
            ,arctrl_rb_rlast_d4_o
            ,arctrl_rb_rid_d4_o
            ,arctrl_rb_idx_d4_o
            ,arctrl_rb_bc_d4_o

            ,pcrdgnt_pkt_v_d2_i
            ,pcrdgnt_pkt_d2_i
            ,arctrl_pcrdgnt_h_present_d3_o
            ,arctrl_pcrdgnt_l_present_d3_o
            ,ar_pcrdgnt_h_win_d3_i
            ,ar_pcrdgnt_l_win_d3_i
        );

    input  wire                                       clk_i;
    input  wire                                       rst_i;

    input  wire [`AXI4_AR_WIDTH-1:0]                  AR_CH_S0;
    input  wire                                       ARVALID0;
    output wire                                       ARREADY0;

    output wire                                       arctrl_txreqflitv_s4_o;
    output wire [`CHIE_REQ_FLIT_WIDTH-1:0]            arctrl_txreqflit_s4_o;
    input  wire                                       arctrl_txreqflit_sent_s4_i;

    input  wire                                       rxdatflitv_d1_i;
    input  wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]      rxdatflit_txnid_d1_i;
    input  wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]     rxdatflit_dataid_d1_i;

    input  wire                                       rxrspflitv_d1_i;
    input  wire [`CHIE_RSP_FLIT_WIDTH-1:0]            rxrspflit_d1_i;

    input  wire                                       rp_fifo_acpt_d4_i;
    output wire                                       arctrl_rb_valid_d4_o;
    output wire [`RNI_DMASK_CT_WIDTH-1:0]             arctrl_rb_ctmask_d4_o;
    output wire                                       arctrl_rb_rlast_d4_o;
    output wire [`AXI4_ARID_WIDTH-1:0]                arctrl_rb_rid_d4_o;
    output wire [`RNI_AR_ENTRIES_WIDTH-1:0]           arctrl_rb_idx_d4_o;
    output wire [`RNI_BC_WIDTH-1:0]                   arctrl_rb_bc_d4_o;

    input  wire                                       pcrdgnt_pkt_v_d2_i;
    input  wire [`PCRDGRANT_PKT_WIDTH-1:0]            pcrdgnt_pkt_d2_i;
    output wire                                       arctrl_pcrdgnt_h_present_d3_o;
    output wire                                       arctrl_pcrdgnt_l_present_d3_o;
    input  wire                                       ar_pcrdgnt_h_win_d3_i;
    input  wire                                       ar_pcrdgnt_l_win_d3_i;

    wire alloc_busy_s1_w;
    wire [`AXI4_AR_WIDTH-1:0] arlink_arbus_s1_w;
    wire arlink_valid_s1_w;
    wire [`AXI4_ARADDR_WIDTH-1:0] arlink_addr_s1_w;
    wire [`RNI_BCVEC_WIDTH-1:0] arlink_bc_vec_s2_w;
    wire [`RNI_DMASK_WIDTH-1:0] arlink_dmask_s2_w;
    wire [`AXI4_ARSIZE_WIDTH-1:0] arlink_size_s2_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_alloc_ptr_s1_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_rdy_s1_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_v_ns_w;
    wire arctrl_new_entry_req_dep_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_is_req_dep_v_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_dep_v_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_req_dep_chain_young_ns_w;
    wire arctrl_new_entry_rdata_dep_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_is_rdata_dep_v_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_rdata_dep_v_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_rdata_dep_chain_young_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_req_retry_ready_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_hi_retry_rdy_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_lo_retry_rdy_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_req_new_rdy_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_hi_new_rdy_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_lo_new_rdy_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_select_vec_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_hi_retry_dec_w;
    wire arctrl_req_hi_retry_found_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_lo_retry_dec_w;
    wire arctrl_req_lo_retry_found_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_hi_new_dec_w;
    wire arctrl_req_hi_new_found_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_lo_new_dec_w;
    wire arctrl_req_lo_new_found_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_ptr_ns_w;
    wire arctrl_entry_req_select_success_flag_w;
    wire [CHIE_NID_WIDTH_PARAM-1:0] ar_tx_send_nid_w;
    wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0] arctrl_entry_rxrsp_tgtid_w;
    wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0] arctrl_entry_rxrsp_srcid_w;
    wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0] arctrl_entry_rxrsp_txnid_w;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0] arctrl_entry_rxrsp_opcode_w;
    wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] arctrl_entry_rxrsp_pcrdtype_w;
    wire ar_rxrsp_correct_w;
    wire rxrsp_retryack_recv_flag_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_retryack_recv_vec_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_retryack_recv_vec_ns_w;
    wire rxrsp_pcrdgrant_recv_flag_w;
    wire rxrsp_pcrdtype_hi_select_w;
    wire rxrsp_pcrdtype_lo_select_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_hi_upd_ptr_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_lo_upd_ptr_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_recv_vec_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_hi_recv_vec_d2_w;
    wire rxrsp_pcrdtype_hi_match_d2_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_lo_recv_vec_d2_w;
    wire rxrsp_pcrdtype_lo_match_d2_w;
    wire [`RNI_DMASK_PD_WIDTH-1:0] arctrl_rdat_pdmask_ns_w;
    wire rxdat_recv_done_flag_w;
    wire rdata_select_adv_w;
    wire [`RNI_DMASK_CT_WIDTH-1:0] arctrl_rdat_ctmask_ns_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_rdata_select_w;
    wire [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_dealloc_vec_w;
    wire arctrl_entry_dealloc_v_w;

    reg arctrl_entry_full_r;
    reg [`AXI4_ARID_WIDTH-1:0] arctrl_arid_s2_r;
    reg [`AXI4_ARADDR_WIDTH-1:0] arctrl_araddr_s2_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_same_req_chain_vec_d2_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_is_req_dep_num_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_sameid_rdata_chain_vec_d2_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_is_rdata_dep_num_r;
    reg [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0] ar_txreq_txnid_r;
    reg [`CHIE_REQ_FLIT_WIDTH-1:0] ar_txreqflit_info_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_rxrsp_ptr_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_hi_rdy_vec_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_lo_rdy_vec_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_rxdat_ptr_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_rdata_rdy_r;
    reg [`RNI_BCVEC_WIDTH-1:0] arctrl_rdata_bc_r;
    reg arctrl_rdata_bc_break_r;
    reg [`RNI_AR_ENTRIES_WIDTH-1:0] arctrl_rdata_entry_idx_r;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxdat_recv_done_vec_r;
    reg [`RNI_DMASK_CT_WIDTH-1:0] arctrl_rdat_ctmask_r;
    reg [`RNI_DMASK_PD_WIDTH-1:0] arctrl_rdat_pdmask_r;
    reg [`RNI_DMASK_LS_WIDTH-1:0] arctrl_rdat_lsmask_r;
    reg [`AXI4_ARID_WIDTH-1:0] arctrl_rdat_axid_r;
    reg [`RNI_BCVEC_WIDTH-1:0] arctrl_rdat_bcvec_r;

    reg [`AXI4_AR_WIDTH-1:0] arctrl_entry_info_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [`AXI4_ARADDR_WIDTH-1:0] arctrl_entry_addr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_qos_hi_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_v_q;
    reg arlink_valid_s2_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_alloc_ptr_s2_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_select_rdy_q;
    reg [`AXI4_ARSIZE_WIDTH-1:0] arctrl_entry_size_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [`RNI_DMASK_LS_WIDTH-1:0] arctrl_entry_lsmask_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [`RNI_BCVEC_WIDTH-1:0] arctrl_entry_bcvec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_is_req_dep_v_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_dep_v_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_is_req_dep_num_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_req_dep_chain_young_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_is_rdata_dep_v_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_rdata_dep_v_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_is_rdata_dep_num_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_rdata_dep_chain_young_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_ptr_q;
    reg arctrl_entry_req_select_success_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_entry_req_select_vec_q;
    reg arctrl_entry_req_select_retry_flag_q;
    reg ar_txreqflitv_s5_q;
    reg [`CHIE_REQ_FLIT_WIDTH-1:0] ar_txreqflit_s5_q;
    reg ar_txreqflit_sent_s5_q;
    reg rxrsp_pcrdtype_hi_match_d3_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_hi_recv_vec_d3_q;
    reg rxrsp_pcrdtype_lo_match_d3_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_lo_recv_vec_d3_q;
    reg [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] rxrsp_retryack_pcrdtype_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_retryack_recv_vec_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_hi_upd_ptr_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_lo_upd_ptr_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] rxrsp_pcrdgrant_recv_vec_q;
    reg rxdat_flitv_q;
    reg [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0] rxdat_txnid_q;
    reg [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0] rxdat_dataid_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_rdata_start_ptr_q;
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0] arctrl_rdata_send_q;
    reg [`RNI_DMASK_RV_WIDTH-1:0] arctrl_entry_rvmask_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [`RNI_DMASK_CT_WIDTH-1:0] arctrl_entry_ctmask_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [`RNI_DMASK_PD_WIDTH-1:0] arctrl_entry_pdmask_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];

    genvar entry;
    integer i;
    /////////////////////////////////////////////////////////////
    // txreq s1
    /////////////////////////////////////////////////////////////
    rni_arlink rni_arlink_u0
               (
                   .clk_i                          (clk_i                  )
                   ,.rst_i                         (rst_i                  )
                   ,.ARVALID                       (ARVALID0               )
                   ,.AR_CH_S0                      (AR_CH_S0               )
                   ,.ARREADY                       (ARREADY0               )
                   ,.alloc_busy_s1_i               (alloc_busy_s1_w        )
                   ,.arlink_arbus_s1_o             (arlink_arbus_s1_w      )
                   ,.arlink_valid_s1_o             (arlink_valid_s1_w      )
                   ,.arlink_addr_s1_o              (arlink_addr_s1_w       )
                   ,.arlink_bc_vec_s2_o            (arlink_bc_vec_s2_w     )
                   ,.arlink_dmask_s2_o             (arlink_dmask_s2_w      )
                   ,.arlink_size_s2_o              (arlink_size_s2_w       )
                   ,.arlink_lock_s2_o              (                       )
               );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AR_ENTRIES_NUM_PARAM)
        )
        arctrl_entry_alloc(
            .in_vec(arctrl_entry_rdy_s1_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.startx({RNI_AR_ENTRIES_NUM_PARAM{1'b0}})
            ,.ptr_dec(arctrl_alloc_ptr_s1_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.found()
        );

    always@* begin
        arctrl_entry_full_r = 1'b1;
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)
            arctrl_entry_full_r = arctrl_entry_full_r & arctrl_entry_v_q[i];
    end

    assign alloc_busy_s1_w = arctrl_entry_full_r;
    assign arctrl_entry_rdy_s1_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = ~arctrl_entry_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] & {RNI_AR_ENTRIES_NUM_PARAM{arlink_valid_s1_w}};
    assign arctrl_entry_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = (arctrl_entry_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] | arctrl_alloc_ptr_s1_w[RNI_AR_ENTRIES_NUM_PARAM-1:0]) & ~arctrl_entry_dealloc_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin: txn_info
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_info_q[entry][`AXI4_AR_WIDTH-1:0] <= {`AXI4_AR_WIDTH{1'b0}};
                end
                else begin
                    if(arctrl_alloc_ptr_s1_w[entry] == 1'b1)begin
                        arctrl_entry_info_q[entry][`AXI4_AR_WIDTH-1:0] <= arlink_arbus_s1_w[`AXI4_AR_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_addr_q[entry][`AXI4_ARADDR_WIDTH-1:0] <= {`AXI4_ARADDR_WIDTH{1'b0}};
                end
                else begin
                    if(arctrl_alloc_ptr_s1_w[entry] == 1'b1)begin
                        arctrl_entry_addr_q[entry][`AXI4_ARADDR_WIDTH-1:0] <= arlink_addr_s1_w[`AXI4_ARADDR_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_qos_hi_q[entry] <= 1'b0;
                end
                else begin
                    if(arctrl_alloc_ptr_s1_w[entry] == 1'b1)begin
                        arctrl_entry_qos_hi_q[entry] <= (arlink_arbus_s1_w[`AXI4_ARQOS_RANGE] == 4'b1111);
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(arlink_valid_s1_w | arctrl_entry_dealloc_v_w)begin
                arctrl_entry_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_entry_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arlink_valid_s2_q <= 1'b0;
        end
        else begin
            arlink_valid_s2_q <= arlink_valid_s1_w;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_alloc_ptr_s2_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            arctrl_alloc_ptr_s2_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_alloc_ptr_s1_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
        end
    end
    /////////////////////////////////////////////////////////////
    // txreq s2
    /////////////////////////////////////////////////////////////
    always@* begin
        arctrl_arid_s2_r[`AXI4_ARID_WIDTH-1:0] = {`AXI4_ARID_WIDTH{1'b0}};
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)
            arctrl_arid_s2_r[`AXI4_ARID_WIDTH-1:0] = arctrl_arid_s2_r[`AXI4_ARID_WIDTH-1:0] | ({`AXI4_ARID_WIDTH{arctrl_alloc_ptr_s2_q[i]}} & arctrl_entry_info_q[i][`AXI4_ARID_RANGE]);
    end

    always@* begin
        arctrl_araddr_s2_r[`AXI4_ARADDR_WIDTH-1:0] = {`AXI4_ARADDR_WIDTH{1'b0}};
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)
            arctrl_araddr_s2_r[`AXI4_ARADDR_WIDTH-1:0] = arctrl_araddr_s2_r[`AXI4_ARADDR_WIDTH-1:0] | ({`AXI4_ARADDR_WIDTH{arctrl_alloc_ptr_s2_q[i]}} & arctrl_entry_addr_q[i][`AXI4_ARADDR_WIDTH-1:0]);
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_req_select_rdy_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            arctrl_entry_req_select_rdy_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_entry_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
        end
    end

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin: txn_size_info
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_size_q[entry][`AXI4_ARSIZE_WIDTH-1:0] <= {`AXI4_ARSIZE_WIDTH{1'b0}};
                end
                else begin
                    if(arctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        arctrl_entry_size_q[entry][`AXI4_ARSIZE_WIDTH-1:0] <= arlink_size_s2_w[`AXI4_ARSIZE_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_lsmask_q[entry][`RNI_DMASK_LS_WIDTH-1:0] <={`RNI_DMASK_LS_WIDTH{1'b0}};
                end
                else begin
                    if(arctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        arctrl_entry_lsmask_q[entry][`RNI_DMASK_LS_WIDTH-1:0] <= arlink_dmask_s2_w[`RNI_DMASK_LS_RANGE];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_bcvec_q[entry][`RNI_BCVEC_WIDTH-1:0] <= {`RNI_BCVEC_WIDTH{1'b0}};
                end
                else begin
                    if(arctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        arctrl_entry_bcvec_q[entry][`RNI_BCVEC_WIDTH-1:0] <= arlink_bc_vec_s2_w[`RNI_BCVEC_WIDTH-1:0];
                    end
                end
            end
        end
    endgenerate

    //request chain
    assign arctrl_new_entry_req_dep_w = |arctrl_same_req_chain_vec_d2_r[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_entry_is_req_dep_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = (arctrl_entry_is_req_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] | arctrl_same_req_chain_vec_d2_r[RNI_AR_ENTRIES_NUM_PARAM-1:0]) & ~rxdat_recv_done_vec_r[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_entry_req_dep_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = (arctrl_entry_req_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] | ({RNI_AR_ENTRIES_NUM_PARAM{(arctrl_new_entry_req_dep_w)}} & arctrl_alloc_ptr_s2_q[RNI_AR_ENTRIES_NUM_PARAM-1:0])) & ~arctrl_entry_is_req_dep_num_r[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_req_dep_chain_young_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = ((arctrl_req_dep_chain_young_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] | arctrl_alloc_ptr_s2_q[RNI_AR_ENTRIES_NUM_PARAM-1:0]) & ~arctrl_same_req_chain_vec_d2_r[RNI_AR_ENTRIES_NUM_PARAM-1:0]) & ~rxdat_recv_done_vec_r[RNI_AR_ENTRIES_NUM_PARAM-1:0];

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin:axid_req_same
            always@* begin
                if((arctrl_alloc_ptr_s2_q[entry] == 1'b0) && (arctrl_entry_v_q[entry] == 1'b1) && (rxdat_recv_done_vec_r[entry] == 1'b0))begin
                    arctrl_same_req_chain_vec_d2_r[entry] = arlink_valid_s2_q && (arctrl_arid_s2_r[`AXI4_ARID_WIDTH-1:0] == arctrl_entry_info_q[entry][`AXI4_ARID_RANGE]) &&
                                                  (arctrl_araddr_s2_r[`AXI4_ARADDR_WIDTH-1:`L3_CACHELINE_OFFSET] == arctrl_entry_addr_q[entry][`AXI4_ARADDR_WIDTH-1:`L3_CACHELINE_OFFSET]) && arctrl_req_dep_chain_young_q[entry];
                end
                else begin
                    arctrl_same_req_chain_vec_d2_r[entry] = 1'b0;
                end
            end
        end
    endgenerate

    always@* begin
        arctrl_entry_is_req_dep_num_r[RNI_AR_ENTRIES_NUM_PARAM-1:0] = {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)
            arctrl_entry_is_req_dep_num_r[RNI_AR_ENTRIES_NUM_PARAM-1:0] = arctrl_entry_is_req_dep_num_r[RNI_AR_ENTRIES_NUM_PARAM-1:0] | ({RNI_AR_ENTRIES_NUM_PARAM{rxdat_recv_done_vec_r[i]}} & arctrl_entry_is_req_dep_num_q[i][RNI_AR_ENTRIES_NUM_PARAM-1:0]);
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_is_req_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(arlink_valid_s2_q | rxdat_recv_done_flag_w)begin
                arctrl_entry_is_req_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_entry_is_req_dep_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_req_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if((arlink_valid_s2_q && arctrl_new_entry_req_dep_w) | rxdat_recv_done_flag_w)begin
                arctrl_entry_req_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_entry_req_dep_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin:req_dep_num
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_is_req_dep_num_q[entry][RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
                end
                else begin
                    if(rxdat_recv_done_vec_r[entry])begin
                        arctrl_entry_is_req_dep_num_q[entry][RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
                    end
                    else if((arlink_valid_s2_q && arctrl_same_req_chain_vec_d2_r[entry]))begin
                        arctrl_entry_is_req_dep_num_q[entry][RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_alloc_ptr_s2_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_req_dep_chain_young_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(arlink_valid_s2_q | rxdat_recv_done_flag_w)begin
                arctrl_req_dep_chain_young_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_req_dep_chain_young_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    //rdata chain
    assign arctrl_new_entry_rdata_dep_w = |arctrl_sameid_rdata_chain_vec_d2_r[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_entry_is_rdata_dep_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = (arctrl_entry_is_rdata_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] | arctrl_sameid_rdata_chain_vec_d2_r[RNI_AR_ENTRIES_NUM_PARAM-1:0]) & ~arctrl_entry_dealloc_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_entry_rdata_dep_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = (arctrl_entry_rdata_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] | ({RNI_AR_ENTRIES_NUM_PARAM{(arctrl_new_entry_rdata_dep_w)}} & arctrl_alloc_ptr_s2_q[RNI_AR_ENTRIES_NUM_PARAM-1:0])) & ~arctrl_entry_is_rdata_dep_num_r[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_rdata_dep_chain_young_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = ((arctrl_rdata_dep_chain_young_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] | arctrl_alloc_ptr_s2_q[RNI_AR_ENTRIES_NUM_PARAM-1:0]) & ~arctrl_sameid_rdata_chain_vec_d2_r[RNI_AR_ENTRIES_NUM_PARAM-1:0]) & ~arctrl_entry_dealloc_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin:axid_rdata_same
            always@* begin
                if((arctrl_alloc_ptr_s2_q[entry] == 1'b0) && (arctrl_entry_v_q[entry] == 1'b1) && (arctrl_entry_dealloc_vec_w[entry] == 1'b0))begin
                    arctrl_sameid_rdata_chain_vec_d2_r[entry] = (arlink_valid_s2_q && arctrl_arid_s2_r[`AXI4_ARID_WIDTH-1:0] == arctrl_entry_info_q[entry][`AXI4_ARID_RANGE]) && arctrl_rdata_dep_chain_young_q[entry];
                end
                else begin
                    arctrl_sameid_rdata_chain_vec_d2_r[entry] = 1'b0;
                end
            end
        end
    endgenerate

    always@* begin
        arctrl_entry_is_rdata_dep_num_r[RNI_AR_ENTRIES_NUM_PARAM-1:0] = {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)
            arctrl_entry_is_rdata_dep_num_r[RNI_AR_ENTRIES_NUM_PARAM-1:0] = arctrl_entry_is_rdata_dep_num_r[RNI_AR_ENTRIES_NUM_PARAM-1:0] | ({RNI_AR_ENTRIES_NUM_PARAM{arctrl_entry_dealloc_vec_w[i]}} & arctrl_entry_is_rdata_dep_num_q[i][RNI_AR_ENTRIES_NUM_PARAM-1:0]);
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_is_rdata_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(arlink_valid_s2_q | arctrl_entry_dealloc_v_w)begin
                arctrl_entry_is_rdata_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_entry_is_rdata_dep_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_rdata_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if((arlink_valid_s2_q & arctrl_new_entry_rdata_dep_w) | arctrl_entry_dealloc_v_w)begin
                arctrl_entry_rdata_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_entry_rdata_dep_v_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin:rdata_dep_num
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_is_rdata_dep_num_q[entry][RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
                end
                else begin
                    if(arctrl_entry_dealloc_vec_w[entry])begin
                        arctrl_entry_is_rdata_dep_num_q[entry][RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
                    end
                    else if((arlink_valid_s2_q && arctrl_sameid_rdata_chain_vec_d2_r[entry]))begin
                        arctrl_entry_is_rdata_dep_num_q[entry][RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_alloc_ptr_s2_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_rdata_dep_chain_young_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(arlink_valid_s2_q | arctrl_entry_dealloc_v_w)begin
                arctrl_rdata_dep_chain_young_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_rdata_dep_chain_young_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    /////////////////////////////////////////////////////////////
    // txreq select
    /////////////////////////////////////////////////////////////
    assign arctrl_req_retry_ready_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = arctrl_entry_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] & arctrl_entry_req_select_rdy_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] & rxrsp_pcrdgrant_recv_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] & ~arctrl_entry_req_select_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_entry_req_hi_retry_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = arctrl_req_retry_ready_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] & arctrl_entry_qos_hi_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_entry_req_lo_retry_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = arctrl_req_retry_ready_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] & ~arctrl_entry_qos_hi_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_req_new_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = arctrl_entry_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] & arctrl_entry_req_select_rdy_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] & ~arctrl_entry_req_dep_v_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] & ~rxrsp_retryack_recv_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] & ~arctrl_entry_req_select_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_entry_req_hi_new_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = arctrl_req_new_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] & arctrl_entry_qos_hi_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_entry_req_lo_new_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = arctrl_req_new_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] & ~arctrl_entry_qos_hi_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    //deassert select_vec when receiving retryack
    assign arctrl_entry_req_select_vec_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = (arctrl_entry_req_select_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] | ({RNI_AR_ENTRIES_NUM_PARAM{arctrl_entry_req_select_success_flag_w}} & arctrl_entry_req_ptr_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])) & ~rxrsp_retryack_recv_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] & ~arctrl_entry_dealloc_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AR_ENTRIES_NUM_PARAM)
        )
        req_retry_hi(
            .in_vec(arctrl_entry_req_hi_retry_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.startx(arctrl_entry_req_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(arctrl_entry_req_hi_retry_dec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.found(arctrl_req_hi_retry_found_w)
        );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AR_ENTRIES_NUM_PARAM)
        )
        req_retry_lo(
            .in_vec(arctrl_entry_req_lo_retry_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.startx(arctrl_entry_req_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(arctrl_entry_req_lo_retry_dec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.found(arctrl_req_lo_retry_found_w)
        );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AR_ENTRIES_NUM_PARAM)
        )
        req_new_hi(
            .in_vec(arctrl_entry_req_hi_new_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.startx(arctrl_entry_req_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(arctrl_entry_req_hi_new_dec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.found(arctrl_req_hi_new_found_w)
        );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AR_ENTRIES_NUM_PARAM)
        )
        req_new_lo(
            .in_vec(arctrl_entry_req_lo_new_rdy_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.startx(arctrl_entry_req_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(arctrl_entry_req_lo_new_dec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.found(arctrl_req_lo_new_found_w)
        );

    assign arctrl_entry_req_ptr_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = arctrl_req_hi_retry_found_w ? arctrl_entry_req_hi_retry_dec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0]:
           arctrl_req_hi_new_found_w ? arctrl_entry_req_hi_new_dec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0]:
           arctrl_req_lo_retry_found_w ? arctrl_entry_req_lo_retry_dec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0]:
           arctrl_entry_req_lo_new_dec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_entry_req_select_success_flag_w = (arctrl_req_hi_retry_found_w | arctrl_req_hi_new_found_w | arctrl_req_lo_retry_found_w | arctrl_req_lo_new_found_w) & (arctrl_txreqflit_sent_s4_i | ~arctrl_txreqflitv_s4_o);

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_req_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(arctrl_entry_req_select_success_flag_w)begin
                arctrl_entry_req_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_entry_req_ptr_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_req_select_success_q <= 1'b0;
        end
        else begin
            arctrl_entry_req_select_success_q <= arctrl_entry_req_select_success_flag_w;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_req_select_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(arctrl_entry_req_select_success_flag_w | rxrsp_retryack_recv_flag_w | arctrl_entry_dealloc_v_w)begin
                arctrl_entry_req_select_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_entry_req_select_vec_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_entry_req_select_retry_flag_q <= 1'b0;
        end
        else begin
            if(arctrl_entry_req_select_success_flag_w)begin
                arctrl_entry_req_select_retry_flag_q <= arctrl_req_hi_retry_found_w | arctrl_req_lo_retry_found_w;
            end
        end
    end

    /////////////////////////////////////////////////////////////
    // txreq send
    /////////////////////////////////////////////////////////////
    assign ar_tx_send_nid_w[CHIE_NID_WIDTH_PARAM-1:0] = HNF_NID_PARAM;

    always@* begin
        ar_txreq_txnid_r[`CHIE_REQ_FLIT_TXNID_WIDTH-1:0] = {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
        ar_txreq_txnid_r[`CHIE_REQ_FLIT_TXNID_WIDTH-1] = 1'b0;
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)
            ar_txreq_txnid_r[`RNI_AR_ENTRIES_WIDTH-1:0] = ar_txreq_txnid_r[`RNI_AR_ENTRIES_WIDTH-1:0] | ({`RNI_AR_ENTRIES_WIDTH{arctrl_entry_req_ptr_q[i]}} & i);
    end

    generate
        if(CHIE_REQ_RSVDC_WIDTH_PARAM != 0)begin
            always @*begin
                ar_txreqflit_info_r[`CHIE_REQ_FLIT_RSVDC_RANGE] = {`CHIE_REQ_FLIT_RSVDC_WIDTH{1'b0}};
            end
        end
    endgenerate

    always@* begin
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_WIDTH-1:0] = {`CHIE_REQ_FLIT_WIDTH{1'b0}};
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_TGTID_RANGE] = ar_tx_send_nid_w[CHIE_NID_WIDTH_PARAM-1:0];
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_SRCID_RANGE] = RNI_NID_PARAM;
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_TXNID_RANGE] = ar_txreq_txnid_r[`CHIE_REQ_FLIT_TXNID_WIDTH-1:0];
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_OPCODE_RANGE] = `CHIE_READONCE;
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE] = ~arctrl_entry_req_select_retry_flag_q;
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_ORDER_RANGE] = 2'b00;
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_EARLYWRACK_RANGE] = 1'b1;
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_DEVICE_RANGE] = 1'b0;
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_CACHEABLE_RANGE] = 1'b1;
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_SNPATTR_RANGE] = 1'b1;
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_LPID_RANGE] = {`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_SIZE_RANGE] = 3'b110;
        ar_txreqflit_info_r[`CHIE_REQ_FLIT_EXPCOMPACK_RANGE] = 1'b0;
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)begin
            ar_txreqflit_info_r[`CHIE_REQ_FLIT_QOS_RANGE] = ar_txreqflit_info_r[`CHIE_REQ_FLIT_QOS_RANGE] | ({`AXI4_ARQOS_WIDTH{arctrl_entry_req_ptr_q[i]}} & arctrl_entry_info_q[i][`AXI4_ARQOS_RANGE]);
            ar_txreqflit_info_r[`CHIE_REQ_FLIT_ADDR_RANGE] = ar_txreqflit_info_r[`CHIE_REQ_FLIT_ADDR_RANGE] | ({`AXI4_ARADDR_WIDTH{arctrl_entry_req_ptr_q[i]}} & arctrl_entry_addr_q[i][`AXI4_ARADDR_WIDTH-1:0]);
            ar_txreqflit_info_r[`CHIE_REQ_FLIT_PCRDTYPE_RANGE] = ~arctrl_entry_req_select_retry_flag_q ? {`CHIE_REQ_FLIT_PCRDTYPE_WIDTH{1'b0}} :
                               ar_txreqflit_info_r[`CHIE_REQ_FLIT_PCRDTYPE_RANGE] | ({`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{arctrl_entry_req_ptr_q[i]}} & rxrsp_retryack_pcrdtype_q[i][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]);
            ar_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_ALLOCATE_RANGE] = ar_txreqflit_info_r[`CHIE_REQ_FLIT_MEMATTR_ALLOCATE_RANGE] | (arctrl_entry_req_ptr_q[i] & arctrl_entry_info_q[i][`AXI4_ARCACHE_MSB-1]);
        end
    end

    assign arctrl_txreqflitv_s4_o = arctrl_entry_req_select_success_q | (~ar_txreqflit_sent_s5_q & ar_txreqflitv_s5_q);
    assign arctrl_txreqflit_s4_o[`CHIE_REQ_FLIT_WIDTH-1:0] = (~ar_txreqflit_sent_s5_q & ar_txreqflitv_s5_q) ? ar_txreqflit_s5_q[`CHIE_REQ_FLIT_WIDTH-1:0] : ar_txreqflit_info_r[`CHIE_REQ_FLIT_WIDTH-1:0];

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            ar_txreqflitv_s5_q <= 1'b0;
        end
        else begin
            ar_txreqflitv_s5_q <= arctrl_txreqflitv_s4_o;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            ar_txreqflit_s5_q[`CHIE_REQ_FLIT_WIDTH-1:0] <= {`CHIE_REQ_FLIT_WIDTH{1'b0}};
        end
        else begin
            ar_txreqflit_s5_q[`CHIE_REQ_FLIT_WIDTH-1:0]<= arctrl_txreqflit_s4_o[`CHIE_REQ_FLIT_WIDTH-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            ar_txreqflit_sent_s5_q <= 1'b0;
        end
        else begin
            ar_txreqflit_sent_s5_q<= arctrl_txreqflit_sent_s4_i;
        end
    end

    /////////////////////////////////////////////////////////////
    // rxrsp
    /////////////////////////////////////////////////////////////
    assign arctrl_entry_rxrsp_tgtid_w[`CHIE_RSP_FLIT_TGTID_WIDTH-1:0] = rxrspflit_d1_i[`CHIE_RSP_FLIT_TGTID_RANGE];
    assign arctrl_entry_rxrsp_srcid_w[`CHIE_RSP_FLIT_SRCID_WIDTH-1:0] = rxrspflit_d1_i[`CHIE_RSP_FLIT_SRCID_RANGE];
    assign arctrl_entry_rxrsp_txnid_w[`CHIE_RSP_FLIT_TXNID_WIDTH-1:0] = rxrspflit_d1_i[`CHIE_RSP_FLIT_TXNID_RANGE];
    assign arctrl_entry_rxrsp_opcode_w[`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0] = rxrspflit_d1_i[`CHIE_RSP_FLIT_OPCODE_RANGE];
    assign arctrl_entry_rxrsp_pcrdtype_w[`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] = rxrspflit_d1_i[`CHIE_RSP_FLIT_PCRDTYPE_RANGE];

    assign ar_rxrsp_correct_w = rxrspflitv_d1_i & ~arctrl_entry_rxrsp_txnid_w[`CHIE_RSP_FLIT_TXNID_WIDTH-1] & (arctrl_entry_rxrsp_tgtid_w[`CHIE_RSP_FLIT_TGTID_WIDTH-1:0] == RNI_NID_PARAM);
    assign rxrsp_retryack_recv_flag_w = ar_rxrsp_correct_w & (arctrl_entry_rxrsp_opcode_w[`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0] == `CHIE_RETRYACK);
    assign rxrsp_retryack_recv_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = {RNI_AR_ENTRIES_NUM_PARAM{rxrsp_retryack_recv_flag_w}} & arctrl_rxrsp_ptr_r[RNI_AR_ENTRIES_NUM_PARAM-1:0];

    assign rxrsp_retryack_recv_vec_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = (rxrsp_retryack_recv_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] | rxrsp_retryack_recv_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0]) & ~arctrl_entry_dealloc_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];

    assign rxrsp_pcrdgrant_recv_flag_w = pcrdgnt_pkt_v_d2_i;
    assign arctrl_pcrdgnt_h_present_d3_o = rxrsp_pcrdtype_hi_match_d3_q;
    assign arctrl_pcrdgnt_l_present_d3_o = rxrsp_pcrdtype_lo_match_d3_q;
    assign rxrsp_pcrdtype_hi_select_w = ar_pcrdgnt_h_win_d3_i & rxrsp_pcrdtype_hi_match_d3_q;
    assign rxrsp_pcrdtype_lo_select_w = ar_pcrdgnt_l_win_d3_i & rxrsp_pcrdtype_lo_match_d3_q;
    assign rxrsp_pcrdgrant_hi_upd_ptr_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = {RNI_AR_ENTRIES_NUM_PARAM{rxrsp_pcrdtype_hi_select_w}} & rxrsp_pcrdgrant_hi_recv_vec_d3_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign rxrsp_pcrdgrant_lo_upd_ptr_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = {RNI_AR_ENTRIES_NUM_PARAM{rxrsp_pcrdtype_lo_select_w}} & rxrsp_pcrdgrant_lo_recv_vec_d3_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign rxrsp_pcrdgrant_recv_vec_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = (rxrsp_pcrdgrant_recv_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] |
            (({RNI_AR_ENTRIES_NUM_PARAM{rxrsp_pcrdtype_hi_select_w}} & rxrsp_pcrdgrant_hi_recv_vec_d3_q[RNI_AR_ENTRIES_NUM_PARAM-1:0]) |
             ({RNI_AR_ENTRIES_NUM_PARAM{rxrsp_pcrdtype_lo_select_w}} & rxrsp_pcrdgrant_lo_recv_vec_d3_q[RNI_AR_ENTRIES_NUM_PARAM-1:0]))) &
           ~arctrl_entry_dealloc_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin:rxrsp_ptr
            always@* begin
                if(entry == arctrl_entry_rxrsp_txnid_w[`RNI_AR_ENTRIES_WIDTH-1:0])begin
                    arctrl_rxrsp_ptr_r[entry] = 1'b1;
                end
                else begin
                    arctrl_rxrsp_ptr_r[entry] = 1'b0;
                end
            end
        end
    endgenerate

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin:pcrdtype_match
            always@* begin
                if(rxrsp_pcrdgrant_recv_flag_w & rxrsp_retryack_recv_vec_q[entry] & ~(rxrsp_pcrdgrant_recv_vec_q[entry] | rxrsp_pcrdgrant_recv_vec_ns_w[entry]))begin
                    rxrsp_pcrdgrant_hi_rdy_vec_r[entry] = (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_PCRDTYPE_RANGE] == rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]) &&
                                                (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_SRCID_RANGE] == ar_tx_send_nid_w[CHIE_NID_WIDTH_PARAM-1:0]) &&
                                                (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_TGTID_RANGE] == RNI_NID_PARAM) && arctrl_entry_qos_hi_q[entry];
                end
                else begin
                    rxrsp_pcrdgrant_hi_rdy_vec_r[entry] = 1'b0;
                end
            end

            always@* begin
                if(rxrsp_pcrdgrant_recv_flag_w & rxrsp_retryack_recv_vec_q[entry] & ~(rxrsp_pcrdgrant_recv_vec_q[entry] | rxrsp_pcrdgrant_recv_vec_ns_w[entry]))begin
                    rxrsp_pcrdgrant_lo_rdy_vec_r[entry] = (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_PCRDTYPE_RANGE] == rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]) &&
                                                (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_SRCID_RANGE] == ar_tx_send_nid_w[CHIE_NID_WIDTH_PARAM-1:0]) &&
                                                (pcrdgnt_pkt_d2_i[`PCRDGRANT_PKT_TGTID_RANGE] == RNI_NID_PARAM) && ~arctrl_entry_qos_hi_q[entry];
                end
                else begin
                    rxrsp_pcrdgrant_lo_rdy_vec_r[entry] = 1'b0;
                end
            end
        end
    endgenerate
    //s2 selects entry, s3 knows whether it is successful, and s4 updates rxrsp_pcrdgrant_hi_upd_ptr_q/rxrsp_pcrdgrant_recv_vec_q,
    // it is necessary to consider the situation of two consecutive beats.
    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AR_ENTRIES_NUM_PARAM)
        )
        pcrdtype_hi_select(
            .in_vec(rxrsp_pcrdgrant_hi_rdy_vec_r[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.startx(rxrsp_pcrdtype_hi_select_w ? rxrsp_pcrdgrant_hi_upd_ptr_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] : rxrsp_pcrdgrant_hi_upd_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(rxrsp_pcrdgrant_hi_recv_vec_d2_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.found(rxrsp_pcrdtype_hi_match_d2_w)
        );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AR_ENTRIES_NUM_PARAM)
        )
        pcrdtype_lo_select(
            .in_vec(rxrsp_pcrdgrant_lo_rdy_vec_r[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.startx(rxrsp_pcrdtype_lo_select_w ? rxrsp_pcrdgrant_lo_upd_ptr_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] : rxrsp_pcrdgrant_lo_upd_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(rxrsp_pcrdgrant_lo_recv_vec_d2_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.found(rxrsp_pcrdtype_lo_match_d2_w)
        );

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdtype_hi_match_d3_q <= 1'b0;
        end
        else begin
            rxrsp_pcrdtype_hi_match_d3_q <= rxrsp_pcrdtype_hi_match_d2_w;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_hi_recv_vec_d3_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            rxrsp_pcrdgrant_hi_recv_vec_d3_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_hi_recv_vec_d2_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdtype_lo_match_d3_q <= 1'b0;
        end
        else begin
            rxrsp_pcrdtype_lo_match_d3_q <= rxrsp_pcrdtype_lo_match_d2_w;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_lo_recv_vec_d3_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            rxrsp_pcrdgrant_lo_recv_vec_d3_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_lo_recv_vec_d2_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
        end
    end

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin:rxrsp_info
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] <= {`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};
                end
                else begin
                    if(rxrsp_retryack_recv_vec_w[entry])begin
                        rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] <= arctrl_entry_rxrsp_pcrdtype_w[`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0];
                    end
                    else if(arctrl_entry_dealloc_vec_w[entry])begin
                        rxrsp_retryack_pcrdtype_q[entry][`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0] <= {`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};
                    end
                end
            end
        end
    endgenerate

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_retryack_recv_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_retryack_recv_flag_w | arctrl_entry_dealloc_v_w)begin
                rxrsp_retryack_recv_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= rxrsp_retryack_recv_vec_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_hi_upd_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_pcrdtype_hi_select_w)begin
                rxrsp_pcrdgrant_hi_upd_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_hi_upd_ptr_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_lo_upd_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_pcrdtype_lo_select_w)begin
                rxrsp_pcrdgrant_lo_upd_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_lo_upd_ptr_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxrsp_pcrdgrant_recv_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else begin
            if(rxrsp_pcrdtype_hi_select_w | rxrsp_pcrdtype_lo_select_w | arctrl_entry_dealloc_v_w)begin
                rxrsp_pcrdgrant_recv_vec_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= rxrsp_pcrdgrant_recv_vec_ns_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
            end
        end
    end

    /////////////////////////////////////////////////////////////
    // rdata
    /////////////////////////////////////////////////////////////
    assign arctrl_rdat_pdmask_ns_w[`RNI_DMASK_PD_WIDTH-1:0] = arctrl_rdat_pdmask_r[`RNI_DMASK_PD_WIDTH-1:0] & (~arctrl_rdat_ctmask_r[`RNI_DMASK_CT_WIDTH-1:0]);
    assign rxdat_recv_done_flag_w = |rxdat_recv_done_vec_r[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign rdata_select_adv_w = rp_fifo_acpt_d4_i | (!arctrl_rb_valid_d4_o);
    assign arctrl_rb_valid_d4_o = |arctrl_rdata_send_q[RNI_AR_ENTRIES_NUM_PARAM-1:0];
    assign arctrl_rb_ctmask_d4_o[`RNI_DMASK_CT_WIDTH-1:0] = arctrl_rdat_ctmask_r[`RNI_DMASK_CT_WIDTH-1:0];
    assign arctrl_rb_rlast_d4_o = |(arctrl_rdat_ctmask_r[`RNI_DMASK_CT_WIDTH-1:0] & arctrl_rdat_lsmask_r[`RNI_DMASK_LS_WIDTH-1:0]);
    assign arctrl_rb_rid_d4_o[`AXI4_ARID_WIDTH-1:0] = arctrl_rdat_axid_r[`AXI4_ARID_WIDTH-1:0];
    assign arctrl_rb_idx_d4_o[`RNI_AR_ENTRIES_WIDTH-1:0] = arctrl_rdata_entry_idx_r[`RNI_AR_ENTRIES_WIDTH-1:0];
    assign arctrl_rb_bc_d4_o[`RNI_BC_WIDTH-1:0] = arctrl_rdata_bc_r[`RNI_BC_WIDTH-1:0];

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(`RNI_DMASK_CT_WIDTH)
        )
        arctrl_ctmask_ns(
            .in_vec(arctrl_rdat_pdmask_r[`RNI_DMASK_PD_WIDTH-1:0] & (~arctrl_rdat_ctmask_r[`RNI_DMASK_CT_WIDTH-1:0]))
            ,.startx({`RNI_DMASK_CT_WIDTH{1'b0}})
            ,.ptr_dec(arctrl_rdat_ctmask_ns_w[`RNI_DMASK_CT_WIDTH-1:0])
            ,.found()
        );

    rni_sel_bit_from_vec
        #(
            .VEC_WIDTH(RNI_AR_ENTRIES_NUM_PARAM)
        )
        arctrl_rdata_entry(
            .in_vec(arctrl_rdata_rdy_r[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.startx(arctrl_rdata_start_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.ptr_dec(arctrl_rdata_select_w[RNI_AR_ENTRIES_NUM_PARAM-1:0])
            ,.found()
        );

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin:rxdat_ptr
            always@* begin
                if((entry == rxdat_txnid_q[`RNI_AR_ENTRIES_WIDTH-1:0]) && rxdat_flitv_q)begin
                    arctrl_rxdat_ptr_r[entry] = 1'b1;
                end
                else begin
                    arctrl_rxdat_ptr_r[entry] = 1'b0;
                end
            end

            always@* begin
                if(|(arctrl_entry_rvmask_q[entry] & ((arctrl_rdat_ctmask_ns_w[`RNI_DMASK_CT_WIDTH-1:0] & {`RNI_DMASK_CT_WIDTH{rp_fifo_acpt_d4_i & arctrl_rdata_send_q[entry]}}) |
                                                     (arctrl_entry_ctmask_q[entry] & {`RNI_DMASK_CT_WIDTH{~rp_fifo_acpt_d4_i}}))) && (~arctrl_entry_rdata_dep_v_q[entry]))begin
                    arctrl_rdata_rdy_r[entry] = 1'b1;
                end
                else begin
                    arctrl_rdata_rdy_r[entry] = 1'b0;
                end
            end
        end
    endgenerate

    always@* begin
        arctrl_rdata_bc_r[`RNI_BCVEC_WIDTH-1:0] = arctrl_rdat_bcvec_r[`RNI_BCVEC_WIDTH-1:0];
        arctrl_rdata_bc_break_r = 1'b0;
        for (i=0; i < `RNI_DMASK_CT_WIDTH; i=i+1)begin
            if((!arctrl_rdat_ctmask_r[i]) && (!arctrl_rdata_bc_break_r))begin
                arctrl_rdata_bc_r[`RNI_BCVEC_WIDTH-1:0] = arctrl_rdata_bc_r[`RNI_BCVEC_WIDTH-1:0] >> `RNI_BC_WIDTH;
                arctrl_rdata_bc_break_r = 1'b0;
            end
            else begin
                arctrl_rdata_bc_r[`RNI_BCVEC_WIDTH-1:0] =  arctrl_rdata_bc_r[`RNI_BCVEC_WIDTH-1:0];
                arctrl_rdata_bc_break_r = 1'b1;
            end
        end
    end

    always@* begin
        arctrl_rdata_entry_idx_r[`RNI_AR_ENTRIES_WIDTH-1:0] = {`RNI_AR_ENTRIES_WIDTH{1'b0}};
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)begin
            if(arctrl_rdata_send_q[i])begin
                arctrl_rdata_entry_idx_r[`RNI_AR_ENTRIES_WIDTH-1:0] = i;
            end
        end
    end

    always@* begin
        rxdat_recv_done_vec_r[RNI_AR_ENTRIES_NUM_PARAM-1:0] = {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)begin
            if(arctrl_rxdat_ptr_r[i])begin
                rxdat_recv_done_vec_r[i] = (((arctrl_entry_rvmask_q[i][`RNI_DMASK_RV_WIDTH-1:0] | {{2{rxdat_dataid_q[1]}},{2{~rxdat_dataid_q[1]}}}) &
                                             arctrl_entry_pdmask_q[i][`RNI_DMASK_PD_WIDTH-1:0]) == arctrl_entry_pdmask_q[i][`RNI_DMASK_PD_WIDTH-1:0]);
            end
        end
    end

    always@* begin
        arctrl_rdat_ctmask_r[`RNI_DMASK_CT_WIDTH-1:0] = {`RNI_DMASK_CT_WIDTH{1'b0}};
        arctrl_rdat_pdmask_r[`RNI_DMASK_PD_WIDTH-1:0] = {`RNI_DMASK_PD_WIDTH{1'b0}};
        arctrl_rdat_lsmask_r[`RNI_DMASK_LS_WIDTH-1:0] = {`RNI_DMASK_LS_WIDTH{1'b0}};
        arctrl_rdat_axid_r[`AXI4_ARID_WIDTH-1:0] = {`AXI4_ARID_WIDTH{1'b0}};
        arctrl_rdat_bcvec_r[`RNI_BCVEC_WIDTH-1:0] = {`RNI_BCVEC_WIDTH{1'b0}};
        for (i=0; i < RNI_AR_ENTRIES_NUM_PARAM; i=i+1)begin
            arctrl_rdat_ctmask_r[`RNI_DMASK_CT_WIDTH-1:0] = arctrl_rdat_ctmask_r[`RNI_DMASK_CT_WIDTH-1:0] | ({`RNI_DMASK_CT_WIDTH{arctrl_rdata_send_q[i]}} & arctrl_entry_ctmask_q[i][`RNI_DMASK_CT_WIDTH-1:0]);
            arctrl_rdat_pdmask_r[`RNI_DMASK_PD_WIDTH-1:0] = arctrl_rdat_pdmask_r[`RNI_DMASK_PD_WIDTH-1:0] | ({`RNI_DMASK_PD_WIDTH{arctrl_rdata_send_q[i]}} & arctrl_entry_pdmask_q[i][`RNI_DMASK_PD_WIDTH-1:0]);
            arctrl_rdat_lsmask_r[`RNI_DMASK_LS_WIDTH-1:0] = arctrl_rdat_lsmask_r[`RNI_DMASK_LS_WIDTH-1:0] | ({`RNI_DMASK_LS_WIDTH{arctrl_rdata_send_q[i]}} & arctrl_entry_lsmask_q[i][`RNI_DMASK_LS_WIDTH-1:0]);
            arctrl_rdat_axid_r[`AXI4_ARID_WIDTH-1:0] = arctrl_rdat_axid_r[`AXI4_ARID_WIDTH-1:0] | ({`AXI4_ARID_WIDTH{arctrl_rdata_send_q[i]}} & arctrl_entry_info_q[i][`AXI4_ARID_RANGE]);
            arctrl_rdat_bcvec_r[`RNI_BCVEC_WIDTH-1:0] = arctrl_rdat_bcvec_r[`RNI_BCVEC_WIDTH-1:0] | ({`RNI_BCVEC_WIDTH{arctrl_rdata_send_q[i]}} & arctrl_entry_bcvec_q[i][`RNI_BCVEC_WIDTH-1:0]);
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxdat_flitv_q <= 1'b0;
        end
        else begin
            rxdat_flitv_q <= rxdatflitv_d1_i;
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxdat_txnid_q[`CHIE_DAT_FLIT_TXNID_WIDTH-1:0] <= {`CHIE_DAT_FLIT_TXNID_WIDTH{1'b0}};
        end
        else begin
            rxdat_txnid_q[`CHIE_DAT_FLIT_TXNID_WIDTH-1:0] <= rxdatflit_txnid_d1_i[`CHIE_DAT_FLIT_TXNID_WIDTH-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            rxdat_dataid_q[`CHIE_DAT_FLIT_DATAID_WIDTH-1:0] <= {`CHIE_DAT_FLIT_DATAID_WIDTH{1'b0}};
        end
        else begin
            rxdat_dataid_q[`CHIE_DAT_FLIT_DATAID_WIDTH-1:0] <= rxdatflit_dataid_d1_i[`CHIE_DAT_FLIT_DATAID_WIDTH-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_rdata_start_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else if(rdata_select_adv_w)begin
            arctrl_rdata_start_ptr_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_rdata_select_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
        end
    end

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            arctrl_rdata_send_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= {RNI_AR_ENTRIES_NUM_PARAM{1'b0}};
        end
        else if(rdata_select_adv_w)begin
            arctrl_rdata_send_q[RNI_AR_ENTRIES_NUM_PARAM-1:0] <= arctrl_rdata_select_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
        end
    end

    generate
        for (entry=0; entry < RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1) begin:arctrl_mask
            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_rvmask_q[entry][`RNI_DMASK_RV_WIDTH-1:0] <={`RNI_DMASK_RV_WIDTH{1'b0}};
                end
                else begin
                    if(arctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        arctrl_entry_rvmask_q[entry][`RNI_DMASK_RV_WIDTH-1:0] <= arlink_dmask_s2_w[`RNI_DMASK_RV_RANGE];
                    end
                    else if(arctrl_rxdat_ptr_r[entry])begin
                        arctrl_entry_rvmask_q[entry][`RNI_DMASK_RV_WIDTH-1:0] <= arctrl_entry_rvmask_q[entry][`RNI_DMASK_RV_WIDTH-1:0] | {{2{rxdat_dataid_q[1]}},{2{~rxdat_dataid_q[1]}}};
                    end

                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_ctmask_q[entry][`RNI_DMASK_CT_WIDTH-1:0] <={`RNI_DMASK_CT_WIDTH{1'b0}};
                end
                else begin
                    if(arctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        arctrl_entry_ctmask_q[entry][`RNI_DMASK_CT_WIDTH-1:0] <= arlink_dmask_s2_w[`RNI_DMASK_CT_RANGE];
                    end
                    else if(arctrl_rdata_send_q[entry] && rp_fifo_acpt_d4_i)begin
                        arctrl_entry_ctmask_q[entry][`RNI_DMASK_CT_WIDTH-1:0] <= arctrl_rdat_ctmask_ns_w[`RNI_DMASK_CT_WIDTH-1:0];
                    end
                end
            end

            always @(posedge clk_i or posedge rst_i) begin
                if (rst_i == 1'b1)begin
                    arctrl_entry_pdmask_q[entry][`RNI_DMASK_PD_WIDTH-1:0] <={`RNI_DMASK_PD_WIDTH{1'b0}};
                end
                else begin
                    if(arctrl_alloc_ptr_s2_q[entry] == 1'b1)begin
                        arctrl_entry_pdmask_q[entry][`RNI_DMASK_PD_WIDTH-1:0] <= arlink_dmask_s2_w[`RNI_DMASK_PD_RANGE];
                    end
                    else if(arctrl_rdata_send_q[entry] && rp_fifo_acpt_d4_i)begin
                        arctrl_entry_pdmask_q[entry][`RNI_DMASK_PD_WIDTH-1:0] <= arctrl_rdat_pdmask_ns_w[`RNI_DMASK_PD_WIDTH-1:0];
                    end
                end
            end
        end
    endgenerate

    /////////////////////////////////////////////////////////////
    // dealloc
    /////////////////////////////////////////////////////////////
    assign arctrl_entry_dealloc_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0] = {RNI_AR_ENTRIES_NUM_PARAM{rp_fifo_acpt_d4_i && !(|arctrl_rdat_pdmask_ns_w[`RNI_DMASK_PD_WIDTH-1:0])}} & arctrl_rdata_send_q;
    assign arctrl_entry_dealloc_v_w = |arctrl_entry_dealloc_vec_w[RNI_AR_ENTRIES_NUM_PARAM-1:0];
endmodule
