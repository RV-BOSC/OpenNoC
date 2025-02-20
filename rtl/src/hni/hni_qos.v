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

`include "chie_defines.v"
`include "axi4_defines.v"
`include "hni_defines.v"
`include "hni_param.v"

module hni_qos `HNI_PARAM
    (
        clk,
        rst,

        rxreq_valid_s0,
        rxreqflit_s0,

        txrsp_retryack_won_s1,
        txrsp_pcrdgnt_won_s2,

        mshr_retired_valid_sx,
        mshr_retired_idx_sx,

        qos_txrsp_retryack_valid_s1,
        qos_txrsp_retryack_fifo_s1,

        qos_txrsp_pcrdgnt_valid_s2,
        qos_txrsp_pcrdgnt_fifo_s2,

        rxreq_retry_enable_s0,

        rxreq_alloc_en_s0,
        rxreq_alloc_flit_s0,
        mshr_entry_idx_alloc_s0
    );
//RET_CNT
    //inputs
    input wire                                       clk;
    input wire                                       rst;

    //inputs from RXREQ
    input wire                                       rxreq_valid_s0;
    input wire [`CHIE_REQ_FLIT_RANGE]                rxreqflit_s0;

    //inputs from TXRSP
    input wire                                       txrsp_retryack_won_s1;
    input wire                                       txrsp_pcrdgnt_won_s2;

    //inputs from hni_mshr
    input wire                                       mshr_retired_valid_sx;
    input wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]         mshr_retired_idx_sx;

    //outputs to TXRSP
    output wire                                      qos_txrsp_retryack_valid_s1;
    output wire [`HNI_RETRY_ACKQ_DATA_RANGE]         qos_txrsp_retryack_fifo_s1;

    output wire                                      qos_txrsp_pcrdgnt_valid_s2;
    output wire [`HNI_PCRDGRANTQ_DATA_RANGE]         qos_txrsp_pcrdgnt_fifo_s2;

    //outputs to RXREQ
    output wire                                      rxreq_retry_enable_s0;

    //outputs to global_monitor,mshr and TXRSP(fastpath)
    output wire                                      rxreq_alloc_en_s0;
    output wire [`CHIE_REQ_FLIT_RANGE]               rxreq_alloc_flit_s0;
    output wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]        mshr_entry_idx_alloc_s0;

    //internal wire signals
    wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]            rxreq_txnid_s0;
    wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]              rxreq_qos_s0;
    wire [`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH-1:0]       rxreq_allowretry_s0;
    wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]            rxreq_srcid_s0;
    wire [`CHIE_REQ_FLIT_TRACETAG_WIDTH-1:0]         rxreq_tracetag_s0;
    wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]         rxreq_pcrdtype_s0;
    wire                                             qpc_high_s0;
    wire                                             qpc_low_s0;
    wire                                             req_qos_can_alloc_s0;
    wire                                             req_dyn_s0;
    wire                                             req_static_s0;
    wire                                             qos_h_can_alloc_s0;
    wire                                             qos_l_can_alloc_s0;
    wire                                             req_dyn_alloc_s0;
    wire                                             req_static_alloc_s0;
    wire                                             req_dyn_alloc_fail_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]                 mshr_dyn_entry_idx_avail_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]                 mshr_static_entry_idx_avail_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]                 mshr_alloc_entry_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]                 mshr_alloc_set_v_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]                 mshr_entry_valid_flop_en_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]                 mshr_static_set_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]                 mshr_alloc_entry_s1;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]                 mshr_static_en_s0;
    wire                                             qos_high_pool_avail_s0;
    wire                                             qos_low_pool_avail_s0;
    wire                                             qos_pool_high_full_s0;
    wire                                             qos_pool_low_full_s0;
    wire                                             high_cnt_update_s0;
    wire                                             low_cnt_update_s0;
    wire [`HNI_QOS_CNT_WIDTH-1:0]                    qos_pool_high_cnt_ns;
    wire [`HNI_QOS_CNT_WIDTH-1:0]                    qos_pool_low_cnt_ns;
    wire                                             qos_pool_high_cnt_inc_s0;
    wire                                             qos_pool_high_cnt_dec_s0;
    wire                                             qos_pool_low_cnt_inc_s0;
    wire                                             qos_pool_low_cnt_dec_s0;
    wire                                             qos_low_pool_alloc_s0;
    wire                                             qos_high_pool_alloc_s0;
    wire [`HNI_QOS_CLASS_WIDTH-1:0]                  qos_pool_retire_class_sx;
    wire                                             h_retire_can_convert_static_sx;
    wire                                             l_retire_can_convert_static_sx;
    wire [`HNI_QOS_CLASS_WIDTH-1:0]                  qos_class_pool_s0;
    wire [`HNI_MSHR_ENTRIES_NUM-1:0]                 qos_class_pool_flop_en_s0;
    wire                                             mark_mshr_static_sx;
    wire [`HNI_RETRY_ACKQ_DATA_RANGE]                retry_ackq_datain_s0;
    wire [`HNI_PCRDGRANTQ_DATA_RANGE]                pcrdgrant_fifo_datain_s1;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_bank_srcid_match_vec_s0;
    wire                                             ret_bank_alloc_en_s0;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_bank_entry_v_s0;
    wire                                             ret_is_h_s0;
    wire                                             ret_is_l_s0;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_inc_ptr_s0;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_h_inc_s0;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_l_inc_s0;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_h_dec_s1;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_l_dec_s1;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_h_en_s1;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_l_en_s1;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_h_zero;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_h_one;
    wire                                             retry_h_num_one;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_l_zero;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_l_one;
    wire                                             retry_l_num_one;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             h_retry_req_entry;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             l_retry_req_entry;
    wire                                             high_present;
    wire                                             low_present;
    wire                                             l_present_win;
    wire                                             h_present_win_sx;
    wire                                             l_present_win_sx;
    wire                                             l_wait_lost;
    wire                                             l_wait_cnt_inc;
    wire                                             l_wait_cnt_rst;
    wire                                             l_to_h_disbale;
    wire                                             l_wait_upd_en;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_h_dec_ptr_sx1;
    wire [`HNI_RET_BANK_ENTRIES_NUM-1:0]             ret_cnt_l_dec_ptr_sx1;
    wire                                             pcrdgnt_req_enable_s1;
    wire [`CHIE_RSP_FLIT_SRCID_WIDTH-1:0]            pcrdgnt_srcid_s1;
    wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]              pcrdgnt_qos_s1;
    wire [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]         retry_ackq_pcrdtype_s0;
    wire [`HNI_RETRY_ACKQ_DATA_RANGE]                retry_ack_fifo_dataout_s1;
    wire                                             retry_ack_fifo_empty;
    wire                                             retry_ack_fifo_full;
    wire                                             retry_ack_fifo_push;
    wire                                             retry_ack_fifo_pop;
    wire [`HNI_PCRDGRANTQ_DATA_RANGE]                pcrdgrant_fifo_dataout_s2;
    wire                                             pcrdgrant_fifo_empty;
    wire                                             pcrdgrant_fifo_full;
    wire                                             pcrdgrant_fifo_push;
    wire                                             pcrdgrant_fifo_pop;

    //internal reg signals
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]                  mshr_static_entry_valid_s1_q;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]                mshr_dyn_idx_alloc_s0;
    reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]                mshr_static_idx_alloc_s0;
    reg                                              rxreq_alloc_en_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]                  mshr_alloc_entry_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]                  mshr_entry_valid_s1_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]                  mshr_retire_entry_s0;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]                  mshr_dyn_entry_idx_ptr_s0;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]                  mshr_dyn_entry_idx_vector;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]                  mshr_static_entry_idx_ptr_s0;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]                  mshr_static_entry_idx_vector;
    reg                                              qos_high_pool_full_s1_q;
    reg                                              qos_low_pool_full_s1_q;
    reg [`HNI_QOS_CNT_WIDTH-1:0]                     qos_pool_high_cnt_q;
    reg [`HNI_QOS_CNT_WIDTH-1:0]                     qos_pool_low_cnt_q;
    reg [`HNI_QOS_CLASS_WIDTH-1:0]                   qos_class_pool_s1_q[0:`HNI_MSHR_ENTRIES_NUM-1];
    reg [`CHIE_RSP_FLIT_PCRDTYPE_WIDTH-1:0]          pcrdgnt_pcrdtype_s1;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             ret_bank_srcid_s1_q[0:HNI_MSHR_RNF_NUM_PARAM-1];
    reg [`HNI_RET_BANK_ENTRIES_NUM-1:0]              ret_bank_entry_v_s1_q;
    reg [`HNI_RET_BANK_ENTRIES_WIDTH-1:0]            ret_bank_entry_idx_s1_q;
    reg [`HNI_RET_BANK_ENTRIES_NUM-1:0]              ret_bank_entry_ptr_s0;
    reg [`HNI_RET_BANK_ENTRIES_NUM-1:0]              ret_cnt_h_inc_s1_q;
    reg [`HNI_RET_BANK_ENTRIES_NUM-1:0]              ret_cnt_l_inc_s1_q;
    reg [`HNI_RET_BANK_CNT_WIDTH-1:0]                ret_cnt_h_entry_s2_q[0:HNI_MSHR_RNF_NUM_PARAM-1];
    reg [`HNI_RET_BANK_CNT_WIDTH-1:0]                ret_cnt_l_entry_s2_q[0:HNI_MSHR_RNF_NUM_PARAM-1];
    reg [`HNI_RET_BANK_CNT_WIDTH-1:0]                ret_cnt_h_entry_ns_s1[0:HNI_MSHR_RNF_NUM_PARAM-1];
    reg [`HNI_RET_BANK_CNT_WIDTH-1:0]                ret_cnt_l_entry_ns_s1[0:HNI_MSHR_RNF_NUM_PARAM-1];
    reg                                              h_present_win_sx1_q;
    reg                                              l_present_win_sx1_q;
    reg [`HNI_MAX_WAIT_CNT_WIDTH-1:0]                l_wait_cnt_q;
    reg [`HNI_MAX_WAIT_CNT_WIDTH-1:0]                l_wait_cnt_ns;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             h_pcrdgrant_srcid_sx1;
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             l_pcrdgrant_srcid_sx1;

    //Rxreq decode
    assign rxreq_txnid_s0       = (rxreq_valid_s0 == 1'b1) ? rxreqflit_s0[`CHIE_REQ_FLIT_TXNID_RANGE]      : {`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
    assign rxreq_qos_s0         = (rxreq_valid_s0 == 1'b1) ? rxreqflit_s0[`CHIE_REQ_FLIT_QOS_RANGE]        : {`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};
    assign rxreq_allowretry_s0  = (rxreq_valid_s0 == 1'b1) ? rxreqflit_s0[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE] : {`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH{1'b0}};
    assign rxreq_srcid_s0       = (rxreq_valid_s0 == 1'b1) ? rxreqflit_s0[`CHIE_REQ_FLIT_SRCID_RANGE]      : {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
    assign rxreq_tracetag_s0    = (rxreq_valid_s0 == 1'b1) ? rxreqflit_s0[`CHIE_REQ_FLIT_TRACETAG_RANGE]   : {`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};
    assign rxreq_pcrdtype_s0    = (rxreq_valid_s0 == 1'b1) ? rxreqflit_s0[`CHIE_REQ_FLIT_PCRDTYPE_RANGE]   : {`CHIE_REQ_FLIT_PCRDTYPE_WIDTH{1'b0}};

    //QoS Priority Class:high
    assign qpc_high_s0 = (rxreq_qos_s0 >= `HNI_QOS_HIGH_MIN)?1'b1:1'b0;

    //QoS Priority Class:low
    assign qpc_low_s0 = (rxreq_qos_s0 <= `HNI_QOS_LOW_MAX)?1'b1:1'b0;

    //Dynamic/static
    assign req_dyn_s0            = rxreq_valid_s0 & rxreq_allowretry_s0;
    assign req_static_s0         = rxreq_valid_s0 & ~rxreq_allowretry_s0;

    //high can allocate if high and low pool is available
    assign qos_h_can_alloc_s0 = qos_high_pool_avail_s0 | qos_low_pool_avail_s0;

    //low can allocate if low pool is available
    assign qos_l_can_alloc_s0 = qos_low_pool_avail_s0;

    assign req_qos_can_alloc_s0 = (qpc_high_s0 & qos_h_can_alloc_s0 ) | (qpc_low_s0 & qos_l_can_alloc_s0 ) ;

    //qos allocate logic
    assign req_dyn_alloc_s0      = req_dyn_s0 & req_qos_can_alloc_s0;
    assign req_dyn_alloc_fail_s0 = req_dyn_s0 & ~req_qos_can_alloc_s0;

    assign req_static_alloc_s0   = req_static_s0;

    //qos allocate enable
    assign rxreq_alloc_en_s0         = req_dyn_alloc_s0 | req_static_alloc_s0;

    assign rxreq_alloc_flit_s0       = (rxreq_alloc_en_s0 == 1'b1) ? rxreqflit_s0 : {`CHIE_REQ_FLIT_WIDTH{1'b0}};

    always @(posedge clk or posedge rst) begin: update_mshr_alloc_en_timing_logic
        if (rst == 1'b1)
            rxreq_alloc_en_s1_q <= 1'b0;
        else
            rxreq_alloc_en_s1_q <= rxreq_alloc_en_s0;
    end

    //encode the dynamic allocation pointer
    assign mshr_dyn_entry_idx_avail_s0 = ~mshr_static_entry_valid_s1_q & ~mshr_entry_valid_s1_q;

    //find 1 from available dynamic allocations
    always @* begin: mshr_dyn_entry_idx_ptr_comb_logic
        integer i;
        mshr_dyn_entry_idx_vector = {`HNI_MSHR_ENTRIES_NUM{1'b0}};
        mshr_dyn_entry_idx_ptr_s0 = {`HNI_MSHR_ENTRIES_NUM{1'b0}};

        for (i=1; i<`HNI_MSHR_ENTRIES_NUM; i=i+1)begin
            mshr_dyn_entry_idx_vector[i] = mshr_dyn_entry_idx_vector[i-1] | mshr_dyn_entry_idx_avail_s0[i-1];
        end

        for(i=0; i<`HNI_MSHR_ENTRIES_NUM; i=i+1)begin
            mshr_dyn_entry_idx_ptr_s0[i] = ~mshr_dyn_entry_idx_vector[i] & mshr_dyn_entry_idx_avail_s0[i];
        end
    end

    //encode the dynamic allocation index
    always @* begin: enc_dyn_ptr_alloc_idx_comb_logic
        integer i;
        mshr_dyn_idx_alloc_s0 = {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};

        for(i=0; i<`HNI_MSHR_ENTRIES_NUM; i = i+1)begin
            if (mshr_dyn_entry_idx_ptr_s0[i])
                mshr_dyn_idx_alloc_s0 = i;
            else
                mshr_dyn_idx_alloc_s0 = mshr_dyn_idx_alloc_s0;
        end
    end

    //encode the static allocation pointer
    assign mshr_static_entry_idx_avail_s0 = mshr_static_entry_valid_s1_q & ~mshr_entry_valid_s1_q;

    //find 1 from available static allocations
    always @* begin: mshr_static_entry_idx_ptr_comb_logic
        integer i;
        mshr_static_entry_idx_vector = {`HNI_MSHR_ENTRIES_NUM{1'b0}};
        mshr_static_entry_idx_ptr_s0 = {`HNI_MSHR_ENTRIES_NUM{1'b0}};

        for (i=1; i<`HNI_MSHR_ENTRIES_NUM; i=i+1)begin
            mshr_static_entry_idx_vector[i] = mshr_static_entry_idx_vector[i-1] | mshr_static_entry_idx_avail_s0[i-1];
        end

        for(i=0; i<`HNI_MSHR_ENTRIES_NUM; i=i+1)begin
            mshr_static_entry_idx_ptr_s0[i] = ~mshr_static_entry_idx_vector[i] & mshr_static_entry_idx_avail_s0[i];
        end
    end

    //encode the static allocation index
    always @* begin: enc_static_ptr_alloc_idx_comb_logic
        integer i;
        mshr_static_idx_alloc_s0 = {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        for(i=0; i<`HNI_MSHR_ENTRIES_NUM; i = i+1)begin
            if (mshr_static_entry_idx_ptr_s0[i])
                mshr_static_idx_alloc_s0 = i;
            else
                mshr_static_idx_alloc_s0 = mshr_static_idx_alloc_s0;
        end
    end

    //qos allocate index logic
    assign mshr_entry_idx_alloc_s0 = req_static_s0? mshr_static_idx_alloc_s0 : mshr_dyn_idx_alloc_s0;

    //qos alloccate location
    assign mshr_alloc_entry_s0 = req_static_s0? mshr_static_entry_idx_ptr_s0 : mshr_dyn_entry_idx_ptr_s0;

    always @(posedge clk or posedge rst) begin: mshr_entry_location_timing_logic
        if (rst == 1'b1)
            mshr_alloc_entry_s1_q <= {`HNI_MSHR_ENTRIES_NUM{1'b0}};
        else if (rxreq_alloc_en_s0 == 1'b1)
            mshr_alloc_entry_s1_q <= mshr_alloc_entry_s0;
    end

    //qos enqueue entry location valid.
    //  qos entry valid is set on alloc and cleared on retire.
    assign mshr_alloc_set_v_s0 = {`HNI_MSHR_ENTRIES_NUM{rxreq_alloc_en_s0}} & mshr_alloc_entry_s0;

    always @* begin: retired_entry_idx_location_comb_logic
        mshr_retire_entry_s0 = {`HNI_MSHR_ENTRIES_NUM{1'b0}};
        if(mshr_retired_valid_sx == 1'b1)
            mshr_retire_entry_s0[mshr_retired_idx_sx] = 1'b1;
        else
            mshr_retire_entry_s0 = {`HNI_MSHR_ENTRIES_NUM{1'b0}};
    end

    assign mshr_entry_valid_flop_en_s0 = mshr_alloc_set_v_s0 | mshr_retire_entry_s0;

    genvar entry;
    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1)begin
            always @(posedge clk or posedge rst) begin: update_mshr_entry_valid_timing_logic
                if (rst == 1'b1)
                    mshr_entry_valid_s1_q[entry] <= 1'b0;
                else if (mshr_entry_valid_flop_en_s0[entry] == 1'b1)
                    mshr_entry_valid_s1_q[entry] <= mshr_alloc_set_v_s0[entry];
                else
                    ;
            end
        end
    endgenerate

    //mshr static entry valid logic
    assign h_retire_can_convert_static_sx  = (qos_pool_retire_class_sx == `HNI_QOS_CLASS_HIGH) &
           high_present;

    assign l_retire_can_convert_static_sx  = (qos_pool_retire_class_sx == `HNI_QOS_CLASS_LOW) &
           (high_present | low_present);

    assign mark_mshr_static_sx = mshr_retired_valid_sx &
           (h_retire_can_convert_static_sx | l_retire_can_convert_static_sx);

    assign mshr_alloc_entry_s1  = {`HNI_MSHR_ENTRIES_NUM{rxreq_alloc_en_s1_q}} & mshr_alloc_entry_s1_q;

    assign mshr_static_set_s0   = ({`HNI_MSHR_ENTRIES_NUM{mark_mshr_static_sx}} & mshr_retire_entry_s0);

    //static entry is set on mshr retired.
    //  static entry is cleared on mshr allocate (previously retried).
    assign mshr_static_en_s0 = mshr_static_set_s0 | mshr_alloc_entry_s1;
    //(mshr_retire_entry_s0 & mshr_static_entry_valid_s1_q);

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1)begin
            always @(posedge clk or posedge rst) begin: update_mshr_static_entry_valid_timing_logic
                if (rst == 1'b1)
                    mshr_static_entry_valid_s1_q[entry] <= 1'b0;
                else if (mshr_static_en_s0[entry] == 1'b1)
                    mshr_static_entry_valid_s1_q[entry] <= mshr_static_set_s0[entry];
            end
        end
    endgenerate

    //mshr qos class pool decode logic
    assign qos_class_pool_s0 = ({`HNI_QOS_CLASS_WIDTH{qos_low_pool_alloc_s0}} & `HNI_QOS_CLASS_LOW  ) |
           ({`HNI_QOS_CLASS_WIDTH{qos_high_pool_alloc_s0}} & `HNI_QOS_CLASS_HIGH );

    assign qos_class_pool_flop_en_s0 = {`HNI_MSHR_ENTRIES_NUM{req_dyn_alloc_s0}} & mshr_alloc_entry_s0;

    generate
        for(entry=0;entry<`HNI_MSHR_ENTRIES_NUM;entry=entry+1)begin
            always @(posedge clk or posedge rst) begin: update_mshr_pool_timing_logic
                if (rst == 1'b1)
                qos_class_pool_s1_q[entry] <= {`HNI_QOS_CLASS_WIDTH{1'b0}};
                else if (qos_class_pool_flop_en_s0[entry] == 1'b1)
                    qos_class_pool_s1_q[entry] <= qos_class_pool_s0;
                else
                    ;
            end
        end
    endgenerate
    
    assign qos_pool_retire_class_sx = qos_class_pool_s1_q[mshr_retired_idx_sx];

    //high pool count logic
    assign qos_high_pool_alloc_s0 = qos_high_pool_avail_s0 & qpc_high_s0;

    assign qos_pool_high_cnt_inc_s0 = req_dyn_alloc_s0 & qos_high_pool_alloc_s0;//static req don't need to update qos_pool_x_cnt
    assign qos_pool_high_cnt_dec_s0 = mshr_retired_valid_sx &
           ~(high_present) &
           (qos_pool_retire_class_sx == `HNI_QOS_CLASS_HIGH);

    assign high_cnt_update_s0 = (qos_pool_high_cnt_inc_s0 | qos_pool_high_cnt_dec_s0) &
           ~(qos_pool_high_cnt_inc_s0 & qos_pool_high_cnt_dec_s0);

    assign qos_pool_high_cnt_ns = qos_pool_high_cnt_inc_s0? (qos_pool_high_cnt_q + 1'b1):
           (qos_pool_high_cnt_q - 1'b1);

    assign qos_pool_high_full_s0 = (qos_pool_high_cnt_ns == `HNI_QOS_HIGH_POOL_NUM);

    always @(posedge clk or posedge rst) begin: update_high_pool_count_timing_logic
        if (rst == 1'b1)
            qos_pool_high_cnt_q <= {`HNI_QOS_CNT_WIDTH{1'b0}};
        else if (high_cnt_update_s0 == 1'b1)
            qos_pool_high_cnt_q <= qos_pool_high_cnt_ns;
        else
            qos_pool_high_cnt_q <= qos_pool_high_cnt_q;
    end

    always @(posedge clk or posedge rst) begin: update_high_pool_full_timing_logic
        if (rst == 1'b1)
            qos_high_pool_full_s1_q <= 1'b0;
        else if (high_cnt_update_s0 == 1'b1)
            qos_high_pool_full_s1_q <= qos_pool_high_full_s0;
        else
            qos_high_pool_full_s1_q <= qos_high_pool_full_s1_q;
    end

    assign qos_high_pool_avail_s0 = ~qos_high_pool_full_s1_q;

    //low pool count logic
    assign qos_low_pool_alloc_s0 = qos_low_pool_avail_s0 &
           (qpc_high_s0 | qpc_low_s0) &
           ~(qos_high_pool_alloc_s0);

    assign qos_pool_low_cnt_inc_s0 = req_dyn_alloc_s0 & qos_low_pool_alloc_s0;
    assign qos_pool_low_cnt_dec_s0 = mshr_retired_valid_sx &
           ~(high_present | low_present) &
           (qos_pool_retire_class_sx == `HNI_QOS_CLASS_LOW);

    assign low_cnt_update_s0 = (qos_pool_low_cnt_inc_s0 | qos_pool_low_cnt_dec_s0) &
           ~(qos_pool_low_cnt_inc_s0 & qos_pool_low_cnt_dec_s0);

    assign qos_pool_low_cnt_ns = qos_pool_low_cnt_inc_s0? (qos_pool_low_cnt_q + 1'b1):
           (qos_pool_low_cnt_q - 1'b1);

    assign qos_pool_low_full_s0 = (qos_pool_low_cnt_ns == `HNI_QOS_LOW_POOL_NUM);

    always @(posedge clk or posedge rst) begin: update_low_pool_count_timing_logic
        if (rst == 1'b1)
            qos_pool_low_cnt_q <= {`HNI_QOS_CNT_WIDTH{1'b0}};
        else if (low_cnt_update_s0 == 1'b1)
            qos_pool_low_cnt_q <= qos_pool_low_cnt_ns;
        else
            qos_pool_low_cnt_q <= qos_pool_low_cnt_q;
    end

    always @(posedge clk or posedge rst) begin: update_low_pool_full_timing_logic
        if (rst == 1'b1)
            qos_low_pool_full_s1_q <= 1'b0;
        else if (low_cnt_update_s0 == 1'b1)
            qos_low_pool_full_s1_q <= qos_pool_low_full_s0;
        else
            qos_low_pool_full_s1_q <= qos_low_pool_full_s1_q;
    end

    assign qos_low_pool_avail_s0 = ~qos_low_pool_full_s1_q;

    //rxreq retry enable logic
    assign rxreq_retry_enable_s0 = req_dyn_alloc_fail_s0;

    //retry pcrdtype field encode logic
    //  qos is HNI_QOS_CLASS_LOW   ,pcrdtype = 0
    //  qos is HNI_QOS_CLASS_HIGH  ,pcrdtype = 1

    assign retry_ackq_pcrdtype_s0 = { 2'b0, qpc_high_s0, qpc_low_s0};

    //retry_ack_fifo flit assamble
    assign retry_ackq_datain_s0[`HNI_RETRY_ACKQ_SRCID_RANGE]    = rxreq_srcid_s0;
    assign retry_ackq_datain_s0[`HNI_RETRY_ACKQ_TXNID_RANGE]    = rxreq_txnid_s0;
    assign retry_ackq_datain_s0[`HNI_RETRY_ACKQ_QOS_RANGE]      = rxreq_qos_s0;
    assign retry_ackq_datain_s0[`HNI_RETRY_ACKQ_TRACE_RANGE]    = rxreq_tracetag_s0;
    assign retry_ackq_datain_s0[`HNI_RETRY_ACKQ_PCRDTYPE_RANGE] = retry_ackq_pcrdtype_s0;

    assign retry_ack_fifo_push = rxreq_retry_enable_s0 & (~retry_ack_fifo_full | (retry_ack_fifo_full & txrsp_retryack_won_s1));
    assign retry_ack_fifo_pop  = txrsp_retryack_won_s1 & ~retry_ack_fifo_empty;

    hni_fifo #(
                       .FIFO_WIDTH (`HNI_RETRY_ACKQ_DATA_WIDTH    ),
                       .FIFO_DEPTH (`HNI_RETRY_ACKQ_DATA_DEPTH    )
                   )retry_ack_fifo(
                       .clk        (clk                       ),
                       .rst        (rst                       ),
                       .wr_en      (retry_ack_fifo_push       ),
                       .wr_data    (retry_ackq_datain_s0      ),
                       .rd_en      (retry_ack_fifo_pop        ),
                       .rd_data    (retry_ack_fifo_dataout_s1 ),
                       .empty      (retry_ack_fifo_empty      ),
                       .full       (retry_ack_fifo_full       )
                   );

    //retry_ack_fifo
    assign qos_txrsp_retryack_valid_s1    = ~retry_ack_fifo_empty;
    assign qos_txrsp_retryack_fifo_s1     = retry_ack_fifo_dataout_s1;

    //retry bank logic
    //retry bank srcid match logic
    genvar ret_entry;
    generate
        for(ret_entry=0; ret_entry<`HNI_RET_BANK_ENTRIES_NUM;ret_entry=ret_entry+1)begin
            assign ret_bank_srcid_match_vec_s0[ret_entry] = (rxreq_srcid_s0 == ret_bank_srcid_s1_q[ret_entry]) & ret_bank_entry_v_s1_q[ret_entry];
        end
    endgenerate

    //qualify retry bank allocation
    assign ret_bank_alloc_en_s0  = req_dyn_alloc_fail_s0 & ~(|ret_bank_srcid_match_vec_s0);//rxreq_valid_s0

    //update next retry bank entry index
    always @(posedge clk or posedge rst) begin: update_next_ret_bank_idx_timing_logic
        if (rst == 1'b1)
            ret_bank_entry_idx_s1_q <= {`HNI_RET_BANK_ENTRIES_WIDTH{1'b0}};
        else if (ret_bank_alloc_en_s0 == 1'b1)
            ret_bank_entry_idx_s1_q <= ret_bank_entry_idx_s1_q + 1'b1;
        else
            ret_bank_entry_idx_s1_q <= ret_bank_entry_idx_s1_q;
    end

    always @* begin:pass_ret_bank_alloc_idx_to_ptr
        integer i;
        ret_bank_entry_ptr_s0 = {`HNI_RET_BANK_ENTRIES_NUM{1'b0}};
        for (i=0; i<`HNI_RET_BANK_ENTRIES_NUM; i=i+1)
            ret_bank_entry_ptr_s0[i] = (ret_bank_entry_idx_s1_q == i);
    end

    //update retry bank entry valid
    assign ret_bank_entry_v_s0 = {`HNI_RET_BANK_ENTRIES_NUM{ret_bank_alloc_en_s0}} & ret_bank_entry_ptr_s0;

    generate
        for(ret_entry=0; ret_entry<`HNI_RET_BANK_ENTRIES_NUM;ret_entry=ret_entry+1)begin
            always @(posedge clk or posedge rst) begin: update_ret_bank_entry_valid_timing_logic
                if (rst == 1'b1)
                    ret_bank_entry_v_s1_q[ret_entry] <= 1'b0;
                else if (ret_bank_entry_v_s0[ret_entry] == 1'b1)
                    ret_bank_entry_v_s1_q[ret_entry] <= ret_bank_entry_v_s0[ret_entry];
            end
        end
    endgenerate

    //update retry bank srcid entry
    generate
        for(ret_entry=0;ret_entry< `HNI_RET_BANK_ENTRIES_NUM;ret_entry=ret_entry+1) begin: update_retry_bank_srcid_pool_timing_logic
            always @(posedge clk)begin
                if (ret_bank_entry_v_s0[ret_entry] == 1'b1)
                    ret_bank_srcid_s1_q[ret_entry] <= rxreq_srcid_s0;
                else
                    ;
            end
        end
    endgenerate

    //update retry bank count pointer
    assign ret_cnt_inc_ptr_s0 = ret_bank_alloc_en_s0? ret_bank_entry_ptr_s0 : ret_bank_srcid_match_vec_s0;

    //retry bank qos class cnt logic
    assign ret_is_h_s0 = rxreq_retry_enable_s0 & qpc_high_s0;

    assign ret_is_l_s0 = rxreq_retry_enable_s0 & qpc_low_s0;

    generate
        for(ret_entry=0;ret_entry<`HNI_RET_BANK_ENTRIES_NUM;ret_entry=ret_entry+1)begin
            //retry bank high count
            assign ret_cnt_h_inc_s0[ret_entry] = ret_is_h_s0 & ret_cnt_inc_ptr_s0[ret_entry];
            assign ret_cnt_h_dec_s1[ret_entry] = (h_present_win_sx1_q & pcrdgrant_fifo_push & ~ret_cnt_h_zero[ret_entry] & ret_cnt_h_dec_ptr_sx1[ret_entry]);
            assign ret_cnt_h_en_s1[ret_entry] = ret_cnt_h_inc_s0[ret_entry] | ret_cnt_h_dec_s1[ret_entry];

            always @* begin: determine_h_entry_cnt_update_comb_logic
                casez({ret_cnt_h_inc_s0[ret_entry], ret_cnt_h_dec_s1[ret_entry]})
                    2'b10:
                        ret_cnt_h_entry_ns_s1[ret_entry] = ret_cnt_h_entry_s2_q[ret_entry]+1'b1;
                    2'b01:
                        ret_cnt_h_entry_ns_s1[ret_entry] = ret_cnt_h_entry_s2_q[ret_entry]-1'b1;
                    2'b11:
                        ret_cnt_h_entry_ns_s1[ret_entry] = ret_cnt_h_entry_s2_q[ret_entry];
                    default:
                        ret_cnt_h_entry_ns_s1[ret_entry] = ret_cnt_h_entry_s2_q[ret_entry];
                endcase
            end

            always @(posedge clk or posedge rst) begin: update_h_entry_cnt_timing_logic
                if (rst == 1'b1)
                    ret_cnt_h_entry_s2_q[ret_entry]<= {`HNI_RET_BANK_CNT_WIDTH{1'b0}};
                else if (ret_cnt_h_en_s1[ret_entry] == 1'b1)
                    ret_cnt_h_entry_s2_q[ret_entry] <= ret_cnt_h_entry_ns_s1[ret_entry];
            end

            assign ret_cnt_h_zero[ret_entry]  = ret_cnt_h_entry_s2_q[ret_entry] == {`HNI_RET_BANK_CNT_WIDTH{1'b0}};

            assign ret_cnt_h_one[ret_entry]  = (ret_cnt_h_entry_s2_q[ret_entry] == 1'b1) & (~(ret_cnt_h_inc_s0[ret_entry] == 1'b1));

            //retry bank low count
            assign ret_cnt_l_inc_s0[ret_entry] = ret_is_l_s0 & ret_cnt_inc_ptr_s0[ret_entry];
            assign ret_cnt_l_dec_s1[ret_entry] = (l_present_win_sx1_q & pcrdgrant_fifo_push & ~ret_cnt_l_zero[ret_entry] & ret_cnt_l_dec_ptr_sx1[ret_entry]);
            assign ret_cnt_l_en_s1[ret_entry] = ret_cnt_l_inc_s0[ret_entry] | ret_cnt_l_dec_s1[ret_entry];

            always @* begin: determine_l_entry_cnt_update_comb_logic
                casez({ret_cnt_l_inc_s0[ret_entry], ret_cnt_l_dec_s1[ret_entry]})
                    2'b10:
                        ret_cnt_l_entry_ns_s1[ret_entry] = ret_cnt_l_entry_s2_q[ret_entry]+1'b1;
                    2'b01:
                        ret_cnt_l_entry_ns_s1[ret_entry] = ret_cnt_l_entry_s2_q[ret_entry]-1'b1;
                    2'b11:
                        ret_cnt_l_entry_ns_s1[ret_entry] = ret_cnt_l_entry_s2_q[ret_entry];
                    default:
                        ret_cnt_l_entry_ns_s1[ret_entry] = ret_cnt_l_entry_s2_q[ret_entry];
                endcase
            end

            always @(posedge clk or posedge rst) begin: update_l_entry_cnt_timing_logic
                if (rst == 1'b1)
                    ret_cnt_l_entry_s2_q[ret_entry]<= {`HNI_RET_BANK_CNT_WIDTH{1'b0}};
                else if (ret_cnt_l_en_s1[ret_entry] == 1'b1)
                    ret_cnt_l_entry_s2_q[ret_entry] <= ret_cnt_l_entry_ns_s1[ret_entry];
            end

            assign ret_cnt_l_zero[ret_entry]  = ret_cnt_l_entry_s2_q[ret_entry] == {`HNI_RET_BANK_CNT_WIDTH{1'b0}};

            assign ret_cnt_l_one[ret_entry]  = (ret_cnt_l_entry_s2_q[ret_entry] == 1'b1) & (~(ret_cnt_l_inc_s0[ret_entry] == 1'b1));
        end
    endgenerate

    assign retry_h_num_one = |ret_cnt_h_one;
    assign retry_l_num_one = |ret_cnt_l_one;

    assign h_retry_req_entry = (ret_bank_entry_v_s1_q & ~ret_cnt_h_zero) | ret_cnt_h_inc_s0;

    assign l_retry_req_entry = (ret_bank_entry_v_s1_q & ~ret_cnt_l_zero) | ret_cnt_l_inc_s0;

    assign high_present = retry_h_num_one ? (|(h_retry_req_entry & ~ret_cnt_h_dec_s1)) : (|h_retry_req_entry);

    assign low_present = retry_l_num_one ? (|(l_retry_req_entry & ~ret_cnt_l_dec_s1)) : (|l_retry_req_entry);

    //pcrdgrant and starvation logic
    //disable logic
    assign l_to_h_disbale  = (l_wait_cnt_q  >= `HNI_LOW2HIGH_MAX_CNT);

    //high present win logic
    assign h_present_win_sx = high_present & mshr_retired_valid_sx & ((qos_pool_retire_class_sx == `HNI_QOS_CLASS_HIGH) ? 1'b1 : (~l_to_h_disbale));

    always @(posedge clk or posedge rst) begin: update_h_present_win_timing_logic
        if (rst == 1'b1)
            h_present_win_sx1_q <= 1'b0;
        else
            h_present_win_sx1_q <= h_present_win_sx;
    end

    //low present win logic
    assign l_present_win = low_present & mshr_retired_valid_sx & (qos_pool_retire_class_sx == `HNI_QOS_CLASS_LOW);
    assign l_present_win_sx = ~h_present_win_sx & l_present_win;

    always @(posedge clk or posedge rst) begin: update_l_present_win_timing_logic
        if (rst == 1'b1)
            l_present_win_sx1_q <= 1'b0;
        else
            l_present_win_sx1_q <= l_present_win_sx;
    end

    //ltoh count logic
    assign l_wait_lost = l_present_win & ~l_present_win_sx;
    assign l_wait_cnt_inc = l_wait_lost & ~(l_wait_cnt_q == `HNI_LOW2HIGH_MAX_CNT);
    assign l_wait_cnt_rst = l_present_win_sx;

    always @* begin: determine_low_wait_cnt_update_comb_logic
        casez({l_wait_cnt_rst, l_wait_cnt_inc})
            2'b00:
                l_wait_cnt_ns = l_wait_cnt_q;
            2'b01:
                l_wait_cnt_ns = l_wait_cnt_q + 1'b1;
            2'b1?:
                l_wait_cnt_ns = {`HNI_MAX_WAIT_CNT_WIDTH{1'b0}};
            default:
                l_wait_cnt_ns = {`HNI_MAX_WAIT_CNT_WIDTH{1'b0}};
        endcase
    end

    assign l_wait_upd_en = l_wait_cnt_inc | l_wait_cnt_rst;

    always @(posedge clk or posedge rst) begin: update_low_to_hhigh_timing_logic
        if (rst == 1'b1)
            l_wait_cnt_q <= {`HNI_MAX_WAIT_CNT_WIDTH{1'b0}};
        else if (l_wait_upd_en == 1'b1)
            l_wait_cnt_q <= l_wait_cnt_ns;
        else
            l_wait_cnt_q <= l_wait_cnt_q;
    end

    //pcrdgrant enable logic
    assign pcrdgnt_req_enable_s1 = h_present_win_sx1_q | l_present_win_sx1_q;

    //h pcrdgrant srcid logic
    hni_sel_bit_from_vec `HNI_PARAM_INST
                    h_sel_bit_from_vec(
                        .clk               (clk                 ),
                        .rst               (rst                 ),
                        .req_entry_vec     (h_retry_req_entry   ),
                        .upd_start_entry   (h_present_win_sx  ),
                        .req_entry_ptr_sel (ret_cnt_h_dec_ptr_sx1)
                    );

    always @* begin: high_pcrdgrant_srcid_comb_logic
        integer i;
        h_pcrdgrant_srcid_sx1 = {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        for (i=0; i<`HNI_RET_BANK_ENTRIES_NUM; i=i+1)
            h_pcrdgrant_srcid_sx1 = h_pcrdgrant_srcid_sx1 | ({`CHIE_REQ_FLIT_SRCID_WIDTH{ret_cnt_h_dec_ptr_sx1[i]}} & ret_bank_srcid_s1_q[i]);
    end

    //l pcrdgrant srcid logic
    hni_sel_bit_from_vec `HNI_PARAM_INST
                    l_sel_bit_from_vec(
                        .clk               (clk                 ),
                        .rst               (rst                 ),
                        .req_entry_vec     (l_retry_req_entry   ),
                        .upd_start_entry   (l_present_win_sx  ),
                        .req_entry_ptr_sel (ret_cnt_l_dec_ptr_sx1)
                    );

    always @* begin: low_pcrdgrant_srcid_comb_logic
        integer i;
        l_pcrdgrant_srcid_sx1 = {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
        for (i=0; i<`HNI_RET_BANK_ENTRIES_NUM; i=i+1)
            l_pcrdgrant_srcid_sx1 = l_pcrdgrant_srcid_sx1 | ({`CHIE_REQ_FLIT_SRCID_WIDTH{ret_cnt_l_dec_ptr_sx1[i]}} & ret_bank_srcid_s1_q[i]);
    end

    //arbitrate pcrdgrant srcid
    assign pcrdgnt_srcid_s1 = ({`CHIE_REQ_FLIT_SRCID_WIDTH{h_present_win_sx1_q}}  & h_pcrdgrant_srcid_sx1)  |
           ({`CHIE_REQ_FLIT_SRCID_WIDTH{l_present_win_sx1_q}}  & l_pcrdgrant_srcid_sx1)  ;

    //arbitrate pcrdgrant qos
    assign pcrdgnt_qos_s1 = ({`CHIE_REQ_FLIT_QOS_WIDTH{h_present_win_sx1_q}}  & `CHIE_REQ_FLIT_QOS_WIDTH'hf) |
           ({`CHIE_REQ_FLIT_QOS_WIDTH{l_present_win_sx1_q}}  & `CHIE_REQ_FLIT_QOS_WIDTH'h0) ;

    //generate pcrdgrant pcrdtype
    always @*begin
        pcrdgnt_pcrdtype_s1    = {`CHIE_REQ_FLIT_PCRDTYPE_WIDTH{1'b0}};
        pcrdgnt_pcrdtype_s1[0] = l_present_win_sx1_q;
        pcrdgnt_pcrdtype_s1[1] = h_present_win_sx1_q;
    end

    //encode pcrdgrant part fields to fifo
    assign pcrdgrant_fifo_datain_s1[`HNI_PCRDGRANTQ_SRCID_RANGE]    = pcrdgnt_srcid_s1;
    assign pcrdgrant_fifo_datain_s1[`HNI_PCRDGRANTQ_QOS_RANGE]      = pcrdgnt_qos_s1;
    assign pcrdgrant_fifo_datain_s1[`HNI_PCRDGRANTQ_PCRDTYPE_RANGE] = pcrdgnt_pcrdtype_s1;

    assign pcrdgrant_fifo_push = pcrdgnt_req_enable_s1 & (~pcrdgrant_fifo_full | (pcrdgrant_fifo_full & txrsp_pcrdgnt_won_s2));
    assign pcrdgrant_fifo_pop  = txrsp_pcrdgnt_won_s2 & ~pcrdgrant_fifo_empty;

    hni_fifo #(
                       .FIFO_WIDTH (`HNI_PCRDGRANTQ_DATA_WIDTH    ),
                       .FIFO_DEPTH (`HNI_PCRDGRANTQ_DATA_DEPTH    )
                   )pcrdgrant_fifo(
                       .clk        (clk                       ),
                       .rst        (rst                       ),
                       .wr_en      (pcrdgrant_fifo_push       ),
                       .wr_data    (pcrdgrant_fifo_datain_s1  ),
                       .rd_en      (pcrdgrant_fifo_pop        ),
                       .rd_data    (pcrdgrant_fifo_dataout_s2 ),
                       .empty      (pcrdgrant_fifo_empty      ),
                       .full       (pcrdgrant_fifo_full       )
                   );

    //decode pcrdgrant part fields from fifo
    assign qos_txrsp_pcrdgnt_valid_s2    = ~pcrdgrant_fifo_empty;
    assign qos_txrsp_pcrdgnt_fifo_s2     = pcrdgrant_fifo_dataout_s2;

endmodule
