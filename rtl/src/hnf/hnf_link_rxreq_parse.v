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
*    Qichao Xie <xieqichao@bosc.ac.cn>
*    Nana Cai <cainana@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_link_rxreq_parse `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_link
        rxreqflitv,
        rxreqflit,
        rxreqflitpend,

        //inputs from hnf_cache_pipeline
        biq_req_valid_s0_q,
        biq_req_addr_s0_q,

        //inputs from hnf_mshr_qos
        qos_seq_pool_full_s0_q,
        rxreq_retry_enable_s0,

        //inputs from hnf_link_txrsp_wrap
        txrsp_mshr_retryack_won_s1,

        //outputs to link
        rxreq_lcrdv,

        //outputs to hnf_mshr
        li_mshr_rxreq_valid_s0,
        li_mshr_rxreq_qos_s0,
        li_mshr_rxreq_srcid_s0,
        li_mshr_rxreq_txnid_s0,
        li_mshr_rxreq_opcode_s0,
        li_mshr_rxreq_size_s0,
        li_mshr_rxreq_addr_s0,
        li_mshr_rxreq_ns_s0,
        li_mshr_rxreq_allowretry_s0,
        li_mshr_rxreq_order_s0,
        li_mshr_rxreq_pcrdtype_s0,
        li_mshr_rxreq_memattr_s0,
        li_mshr_rxreq_lpid_s0,
        li_mshr_rxreq_excl_s0,
        li_mshr_rxreq_expcompack_s0,
        li_mshr_rxreq_tracetag_s0
    );

    //global inputs
    input wire                                      clk;
    input wire                                      rst;

    //inputs from link
    input wire                                      rxreqflitv;
    input wire [`CHIE_REQ_FLIT_RANGE]               rxreqflit;
    input wire                                      rxreqflitpend;

    //inputs from hnf_cache_pipeline
    input wire                                      biq_req_valid_s0_q;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]      biq_req_addr_s0_q;

    //inputs from hnf_mshr_qos
    input wire                                      qos_seq_pool_full_s0_q;
    input wire                                      rxreq_retry_enable_s0;

    //inputs from hnf_link_txrsp_wrap
    input wire                                      txrsp_mshr_retryack_won_s1;

    //outputs to link
    output wire                                     rxreq_lcrdv;

    //outputs to hnf_mshr
    output wire                                     li_mshr_rxreq_valid_s0;
    output wire [`CHIE_REQ_FLIT_QOS_WIDTH-1:0]      li_mshr_rxreq_qos_s0;
    output wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]    li_mshr_rxreq_srcid_s0;
    output wire [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]    li_mshr_rxreq_txnid_s0;
    output wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]   li_mshr_rxreq_opcode_s0;
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]     li_mshr_rxreq_size_s0;
    output wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]     li_mshr_rxreq_addr_s0;
    output wire                                     li_mshr_rxreq_ns_s0;
    output wire                                     li_mshr_rxreq_allowretry_s0;
    output wire [`CHIE_REQ_FLIT_ORDER_WIDTH-1:0]    li_mshr_rxreq_order_s0;
    output wire [`CHIE_REQ_FLIT_PCRDTYPE_WIDTH-1:0] li_mshr_rxreq_pcrdtype_s0;
    output wire [`CHIE_REQ_FLIT_MEMATTR_WIDTH-1:0]  li_mshr_rxreq_memattr_s0;
    output wire [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]     li_mshr_rxreq_lpid_s0;
    output wire                                     li_mshr_rxreq_excl_s0;
    output wire                                     li_mshr_rxreq_expcompack_s0;
    output wire                                     li_mshr_rxreq_tracetag_s0;

    //internal reg signals
    reg                                             rxreqflitv_en_q;
    reg [`HNF_LCRD_REQ_CNT_RANGE]                 rxreq_crd_cnt_s1_q;
    reg [3:0]                                       rxreq_crdcntsm_out;
    reg                                             rxreqcrdv_s1_q;

    //internal wire signals
    wire [`HNF_LCRD_REQ_CNT_RANGE]                rxreq_crd_cnt_inc1_val_s1;
    wire [`HNF_LCRD_REQ_CNT_RANGE]                rxreq_crd_cnt_dec_val_s1;
    wire [`HNF_LCRD_REQ_CNT_RANGE]                rxreq_crd_cnt_inc_s1;
    wire [3:0]                                      rxreq_crdcntsm_in_sx;
    wire                                            hnf_rxcrd_enable_sx;
    wire                                            rxreq_crd_cnt_zero_sx;
    wire                                            li_req_crd_rtn_s0;
    wire                                            li_retack_tx_s1;
    wire                                            rxreq_crd_cnt_upd_s1;
    wire                                            rxreqcrdv_ns_s0;
    wire                                            rxreq_crd_cnt_inc1_s1;
    wire                                            rxreq_crd_cnt_dec_s1;
    wire [`HNF_LCRD_REQ_CNT_RANGE]                rxreq_crd_cnt_nxt_s1;

    //main function

    //link_rxreq_parse awake
    always @(posedge clk or posedge rst)begin : rxreqflitv_en_q_logic_t
        if(rst == 1'b1)
            rxreqflitv_en_q <= 1'b0;
        else if (rxreqflitpend == 1'b1)
            rxreqflitv_en_q <= 1'b1;
        else
            rxreqflitv_en_q <= 1'b0;
    end

    //rxreqflit decode
    assign li_mshr_rxreq_valid_s0      = (rxreqflitv == 1'b1) || (biq_req_valid_s0_q == 1'b1 && qos_seq_pool_full_s0_q == 1'b0);

    assign li_mshr_rxreq_qos_s0        = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_QOS_RANGE]       :{`CHIE_REQ_FLIT_QOS_WIDTH{1'b0}};
    assign li_mshr_rxreq_srcid_s0      = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_SRCID_RANGE]     :{`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
    assign li_mshr_rxreq_txnid_s0      = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_TXNID_RANGE]     :{`CHIE_REQ_FLIT_TXNID_WIDTH{1'b0}};
    assign li_mshr_rxreq_opcode_s0     = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE]    :(biq_req_valid_s0_q == 1'b1 && qos_seq_pool_full_s0_q == 1'b0) ? `SF_EVICT : {`CHIE_REQ_FLIT_OPCODE_WIDTH{1'b0}};
    assign li_mshr_rxreq_size_s0       = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_SIZE_RANGE]      :{`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};

    assign li_mshr_rxreq_addr_s0       = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_ADDR_RANGE]      :
           (biq_req_valid_s0_q == 1'b1 && qos_seq_pool_full_s0_q == 1'b0)? biq_req_addr_s0_q:{`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};

    assign li_mshr_rxreq_ns_s0         = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_NS_RANGE]        :{`CHIE_REQ_FLIT_NS_WIDTH{1'b0}};
    assign li_mshr_rxreq_allowretry_s0 = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE]:(biq_req_valid_s0_q == 1'b1 && qos_seq_pool_full_s0_q == 1'b0) ? {`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH{1'b1}} : {`CHIE_REQ_FLIT_ALLOWRETRY_WIDTH{1'b0}};
    assign li_mshr_rxreq_order_s0      = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_ORDER_RANGE]     :{`CHIE_REQ_FLIT_ORDER_WIDTH{1'b0}};
    assign li_mshr_rxreq_pcrdtype_s0   = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_PCRDTYPE_RANGE]  :{`CHIE_REQ_FLIT_PCRDTYPE_WIDTH{1'b0}};
    assign li_mshr_rxreq_memattr_s0    = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_MEMATTR_RANGE]   :{`CHIE_REQ_FLIT_MEMATTR_WIDTH{1'b0}};
    assign li_mshr_rxreq_lpid_s0       = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_LPID_RANGE]      :{`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
    assign li_mshr_rxreq_excl_s0       = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_EXCL_RANGE]      :{`CHIE_REQ_FLIT_EXCL_WIDTH{1'b0}};
    assign li_mshr_rxreq_expcompack_s0 = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_EXPCOMPACK_RANGE]:{`CHIE_REQ_FLIT_EXPCOMPACK_WIDTH{1'b0}};
    assign li_mshr_rxreq_tracetag_s0   = (rxreqflitv == 1'b1)? rxreqflit[`CHIE_REQ_FLIT_TRACETAG_RANGE]  :{`CHIE_REQ_FLIT_TRACETAG_WIDTH{1'b0}};

    //rxreq L-credit
    assign li_req_crd_rtn_s0 = !rxreq_retry_enable_s0 && rxreqflitv == 1'b1;

    //retry transaction sent
    assign li_retack_tx_s1 = txrsp_mshr_retryack_won_s1;

    // ---------- input ------------- //
    // hnf_rxcrd_enable_sx rxreq_crd_cnt_zero_sx li_req_crd_rtn_s0 li_retack_tx_s1
    // ---------- output -------------//
    // upd lcrdv inc1 dec1
    // 1 0 0 0 //  8 //  1 1 0 1  //  dec - 1
    // 1 0 0 1 //  9 //  0 1 0 0  //  no change
    // 1 0 1 0 // 10 //  0 1 0 0  //  no change
    // 1 0 1 1 // 11 //  1 1 1 0  //  inc + 1

    // 1 1 0 0 // 12 //  0 0 0 0  //  no change
    // 1 1 0 1 // 13 //  0 1 0 0  //  no change
    // 1 1 1 0 // 14 //  0 1 0 0  //  no change
    // 1 1 1 1 // 15 //  1 1 1 0  //  inc + 1

    assign rxreq_crd_cnt_inc1_val_s1 = rxreq_crd_cnt_s1_q + `LCRD_INCDEC_ONE;
    assign rxreq_crd_cnt_dec_val_s1  = rxreq_crd_cnt_s1_q - `LCRD_INCDEC_ONE;

    assign hnf_rxcrd_enable_sx   = 1'b1;
    assign rxreq_crd_cnt_zero_sx = (rxreq_crd_cnt_s1_q == {`HNF_LCRD_REQ_CNT_WIDTH{1'b0}});
    assign rxreq_crdcntsm_in_sx  = {hnf_rxcrd_enable_sx, rxreq_crd_cnt_zero_sx, li_req_crd_rtn_s0, li_retack_tx_s1};

    always @*begin
        casez (rxreq_crdcntsm_in_sx)
            4'b1000  :
                rxreq_crdcntsm_out = 4'hd;
            4'b1001  :
                rxreq_crdcntsm_out = 4'h4;
            4'b1010  :
                rxreq_crdcntsm_out = 4'h4;
            4'b1011  :
                rxreq_crdcntsm_out = 4'he;

            4'b1100  :
                rxreq_crdcntsm_out = 4'h0;
            4'b1101  :
                rxreq_crdcntsm_out = 4'h4;
            4'b1110  :
                rxreq_crdcntsm_out = 4'h4;
            4'b1111  :
                rxreq_crdcntsm_out = 4'he;
            default   :
                rxreq_crdcntsm_out = 4'h0;
        endcase
    end

    assign rxreq_crd_cnt_upd_s1  = rxreq_crdcntsm_out[3];
    assign rxreqcrdv_ns_s0       = rxreq_crdcntsm_out[2];
    assign rxreq_crd_cnt_inc1_s1 = rxreq_crdcntsm_out[1];
    assign rxreq_crd_cnt_dec_s1  = rxreq_crdcntsm_out[0];

    assign rxreq_crd_cnt_nxt_s1 = rxreq_crd_cnt_dec_s1? rxreq_crd_cnt_dec_val_s1:
           rxreq_crd_cnt_inc_s1;

    assign rxreq_crd_cnt_inc_s1 = rxreq_crd_cnt_inc1_val_s1;


    always @(posedge clk or posedge rst) begin: rxreq_crd_cnt_s1_q_logic_t
        if (rst == 1'b1)
            rxreq_crd_cnt_s1_q <= XP_LCRD_NUM_PARAM;
        else if (rxreq_crd_cnt_upd_s1 == 1'b1)
            rxreq_crd_cnt_s1_q <= rxreq_crd_cnt_nxt_s1;
    end

    always @(posedge clk or posedge rst) begin: rxreqcrdv_s1_q_logic_t
        if (rst == 1'b1)
            rxreqcrdv_s1_q <= 1'b0;
        else
            rxreqcrdv_s1_q <= rxreqcrdv_ns_s0;
    end

    assign rxreq_lcrdv = rxreqcrdv_s1_q;
    //-----------------------------------------------------------------------------
    // DISPLAY INFO
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_INFO

    always @(posedge clk)begin
        if(rxreqflitv)begin
            `display_info($sformatf("HNF RXREQ received a flit\n opcode: %h\n srcid: %h\n txnid: %h\n size: %h\n addr: %h\n allowretry: %h\n order: %h\n memattr: %h\n lpid: %h\n excl: %h\n expcompack: %h\n Time: %0d\n",li_mshr_rxreq_opcode_s0,li_mshr_rxreq_srcid_s0,li_mshr_rxreq_txnid_s0,li_mshr_rxreq_size_s0,li_mshr_rxreq_addr_s0,li_mshr_rxreq_allowretry_s0,li_mshr_rxreq_order_s0,li_mshr_rxreq_memattr_s0,li_mshr_rxreq_lpid_s0,li_mshr_rxreq_excl_s0,li_mshr_rxreq_expcompack_s0,$time()));
        end
    end
`endif

    //-----------------------------------------------------------------------------
    // DISPLAY FATAL
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_FATAL
    always @(*)begin
        `display_fatal( (!((rxreqflitv == 1'b1))) || (rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_READNOSNP)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_WRITENOSNPFULL)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_WRITENOSNPPTL)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_CLEANUNIQUE)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_READCLEAN)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_READNOTSHAREDDIRTY)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_READONCE)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] ==  `CHIE_READUNIQUE)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_WRITEUNIQUEFULL)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_WRITEUNIQUEPTL)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_WRITEBACKFULL)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_WRITECLEANFULL)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_WRITEEVICTFULL)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_MAKEUNIQUE)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_EVICT)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_CLEANSHARED)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_CLEANINVALID)||(rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `SF_EVICT),$sformatf("Fatal info: RXREQ received a unsupported flit with opcode: %h",rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE]));
    end
`endif
endmodule
