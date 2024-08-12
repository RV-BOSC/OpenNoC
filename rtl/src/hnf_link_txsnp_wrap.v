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
*    Wenhao Li <liwenhao@bosc.ac.cn>
*    Jianhong Zhang <zhangjianhong@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_link_txsnp_wrap `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hnf_link
        txsnp_lcrdv,

        //inputs from hnf_mshr_ctl
        mshr_txsnp_valid_sx1_q,
        mshr_txsnp_qos_sx1,
        mshr_txsnp_txnid_sx1_q,
        mshr_txsnp_fwdnid_sx1,
        mshr_txsnp_fwdtxnid_sx1,
        mshr_txsnp_opcode_sx1,
        mshr_txsnp_addr_sx1,
        mshr_txsnp_ns_sx1,
        mshr_txsnp_rettosrc_sx1,
        mshr_txsnp_tracetag_sx1,
        mshr_txsnp_rn_vec_sx1,

        //outputs to hnf_link
        txsnpflitv,
        txsnpflit,
        txsnpflitpend,

        //outputs to hnf_mshr_ctl
        txsnp_mshr_busy_sx1
    );

    //global inputs
    input wire                                      clk;
    input wire                                      rst;

    //inputs from hnf_link
    input wire                                      txsnp_lcrdv;

    //inputs from hnf_mshr_ctl
    input wire                                      mshr_txsnp_valid_sx1_q;
    input wire [`CHIE_SNP_FLIT_QOS_WIDTH-1:0]       mshr_txsnp_qos_sx1;
    input wire [`CHIE_SNP_FLIT_TXNID_WIDTH-1:0]     mshr_txsnp_txnid_sx1_q;
    input wire [`CHIE_SNP_FLIT_FWDNID_WIDTH-1:0]    mshr_txsnp_fwdnid_sx1;
    input wire [`CHIE_SNP_FLIT_FWDTXNID_WIDTH-1:0]  mshr_txsnp_fwdtxnid_sx1;
    input wire [`CHIE_SNP_FLIT_OPCODE_WIDTH-1:0]    mshr_txsnp_opcode_sx1;
    input wire [`CHIE_SNP_FLIT_ADDR_WIDTH-1:0]      mshr_txsnp_addr_sx1;
    input wire [`CHIE_SNP_FLIT_NS_WIDTH-1:0]        mshr_txsnp_ns_sx1;
    input wire [`CHIE_SNP_FLIT_RETTOSRC_WIDTH-1:0]  mshr_txsnp_rettosrc_sx1;
    input wire [`CHIE_SNP_FLIT_TRACETAG_WIDTH-1:0]  mshr_txsnp_tracetag_sx1;
    input wire [HNF_MSHR_RNF_NUM_PARAM-1:0]         mshr_txsnp_rn_vec_sx1;

    //outputs to hnf_link
    output reg                                      txsnpflitv;
    output reg  [`HNF_SNP_FLIT_RANGE]               txsnpflit;
    output wire                                     txsnpflitpend;

    //outputs to hnf_mshr_ctl
    output wire                                     txsnp_mshr_busy_sx1;

    //internal reg signals
    reg [`HNF_LCRD_SNP_CNT_WIDTH-1:0]             txsnp_crd_cnt_q;
    reg [`MSHR_SNPCNT_WIDTH-1:0]                    txsnp_cnt_q;
    reg [`MSHR_SNPCNT_WIDTH-1:0]                    mshr_txsnp_rn_cnt;
    reg [HNF_MSHR_RNF_NUM_PARAM-1:0]                tgt_vec;
    reg [HNF_MSHR_RNF_NUM_PARAM-1:0]                tgt_vec_q;
    reg                                             clr_1st;
    reg [`HNF_SNP_FLIT_RANGE]                       txsnpflit_s0_q;
    reg [`HNF_LCRD_SNP_CNT_WIDTH-1:0]             snp_crd_cnt_ns_s0;
    reg [`HNF_SNP_FLIT_RANGE]                       txsnpflit_s0;
    reg                                             found_rn_vec;
    reg [HNF_MSHR_RNF_NUM_PARAM-1:0]                found_rn_vec_num;
    reg                                             found_tgt_vec;
    reg [HNF_MSHR_RNF_NUM_PARAM-1:0]                found_tgt_vec_num;
    reg [CHIE_NID_WIDTH_PARAM-1:0]                  rnid_list_array[0:HNF_MSHR_RNF_NUM_PARAM-1];

    //internal wire signals
    wire                                            txsnp_busy_sx;
    wire                                            txsnp_req_s0;
    wire                                            txsnpflitv_s0;
    wire [`MSHR_SNPCNT_WIDTH-1:0]                   txsnp_cnt_tmp;
    wire                                            txsnp_crd_avail_s1;
    wire                                            txsnpcrdv_s0;
    wire                                            snp_crd_cnt_not_zero_sx;
    wire                                            update_snp_crd_cnt_s0;
    wire                                            txsnp_crd_cnt_inc_sx;
    wire                                            txsnp_crd_cnt_dec_sx;
    wire [`HNF_LCRD_SNP_CNT_WIDTH-1:0]            snp_crd_cnt_inc_s0;
    wire [`HNF_LCRD_SNP_CNT_WIDTH-1:0]            snp_crd_cnt_dec_s0;
    wire [((HNF_MSHR_RNF_NUM_PARAM*CHIE_NID_WIDTH_PARAM)-1):0] rnnid_list;

    //main function
    genvar i;

    assign rnnid_list = RNF_NID_LIST_PARAM;

    generate
        for(i=0; i<`RNF_NUM; i=i+1)begin
            always @* begin
                rnid_list_array[i] = rnnid_list[i*CHIE_NID_WIDTH_PARAM+CHIE_NID_WIDTH_PARAM-1:i*CHIE_NID_WIDTH_PARAM];
            end
        end
    endgenerate

    always @* begin:found_rn_vec_comb_logic
        integer i;
        found_rn_vec     = 1'b0;
        found_rn_vec_num = 0;
        for (i=0; i<`RNF_NUM; i=i+1)begin
            if(mshr_txsnp_rn_vec_sx1[i] & ~found_rn_vec)begin
                found_rn_vec = 1'b1;
                found_rn_vec_num = i;
            end
        end
    end

    always @* begin:found_tgt_vec_comb_logic
        integer i;
        found_tgt_vec     = 1'b0;
        found_tgt_vec_num = 0;
        for (i=0; i<`RNF_NUM; i=i+1)begin
            if(tgt_vec_q[i] & ~found_tgt_vec)begin
                found_tgt_vec = 1'b1;
                found_tgt_vec_num = i;
            end
        end
    end

    always @* begin: txsnp_wrap_compute_snp_cnt_comb_logic
        integer i;
        mshr_txsnp_rn_cnt = 0;
        for (i = 0; i < `RNF_NUM; i = i + 1) begin
            if (mshr_txsnp_rn_vec_sx1[i] == 1'b1) begin
                mshr_txsnp_rn_cnt = mshr_txsnp_rn_cnt + 1;
            end
        end
    end

    //lcrd_avail

    assign snp_crd_cnt_not_zero_sx = (txsnp_crd_cnt_q != 0);

    //outputs to mshr
    assign txsnp_mshr_busy_sx1 = ((mshr_txsnp_valid_sx1_q == 1'b1) && ((txsnp_cnt_q > 0) | (txsnp_crd_avail_s1 == 1'b0)));

    //read lcrd
    assign txsnpcrdv_s0            = txsnp_lcrdv;
    assign txsnp_crd_cnt_inc_sx    = txsnpcrdv_s0;
    assign txsnp_req_s0            = mshr_txsnp_valid_sx1_q;

    // select from new request and old request(snoop count > 1)
    always @* begin: txsnpflit_s0_logic_c
        txsnpflit_s0 = (txsnp_cnt_q > {`MSHR_SNPCNT_WIDTH{1'b0}})? txsnpflit_s0_q : {`HNF_SNP_FLIT_WIDTH{1'b0}};
        if(txsnp_cnt_q > {`MSHR_SNPCNT_WIDTH{1'b0}})begin
            txsnpflit_s0[`CHIE_SNP_FLIT_WIDTH+CHIE_NID_WIDTH_PARAM-1:`CHIE_SNP_FLIT_WIDTH] = rnid_list_array[found_tgt_vec_num];
        end
        else if(mshr_txsnp_valid_sx1_q == 1'b1 & txsnp_mshr_busy_sx1 == 1'b0)begin
            //MSHR txsnpflit wrap
            txsnpflit_s0[`CHIE_SNP_FLIT_QOS_RANGE]          = mshr_txsnp_qos_sx1;
            txsnpflit_s0[`CHIE_SNP_FLIT_SRCID_RANGE]        = HNF_NID_PARAM;
            txsnpflit_s0[`CHIE_SNP_FLIT_TXNID_RANGE]        = mshr_txsnp_txnid_sx1_q;
            txsnpflit_s0[`CHIE_SNP_FLIT_FWDNID_RANGE]       = mshr_txsnp_fwdnid_sx1;
            txsnpflit_s0[`CHIE_SNP_FLIT_FWDTXNID_RANGE]     = mshr_txsnp_fwdtxnid_sx1;
            txsnpflit_s0[`CHIE_SNP_FLIT_OPCODE_RANGE]       = mshr_txsnp_opcode_sx1;
            txsnpflit_s0[`CHIE_SNP_FLIT_ADDR_RANGE]         = mshr_txsnp_addr_sx1;
            txsnpflit_s0[`CHIE_SNP_FLIT_NS_RANGE]           = mshr_txsnp_ns_sx1;
            txsnpflit_s0[`CHIE_SNP_FLIT_DONOTGOTOSD_RANGE]  = {`CHIE_SNP_FLIT_DONOTGOTOSD_WIDTH{1'b1}};
            txsnpflit_s0[`CHIE_SNP_FLIT_RETTOSRC_RANGE]     = mshr_txsnp_rettosrc_sx1;
            txsnpflit_s0[`CHIE_SNP_FLIT_TRACETAG_RANGE]     = mshr_txsnp_tracetag_sx1;
            //configure tgtid in txsnpflit
            txsnpflit_s0[`CHIE_SNP_FLIT_WIDTH+CHIE_NID_WIDTH_PARAM-1:`CHIE_SNP_FLIT_WIDTH] = rnid_list_array[found_rn_vec_num];
        end
    end

    assign txsnp_cnt_tmp = (mshr_txsnp_valid_sx1_q & ~txsnp_mshr_busy_sx1)? mshr_txsnp_rn_cnt : {`MSHR_SNPCNT_WIDTH{1'b0}};

    //preserve flit if snoopee count > 1
    always @(posedge clk or posedge rst) begin: txsnpflit_s0_q_logic_t
        if(rst == 1'b1)
            txsnpflit_s0_q <= {`HNF_SNP_FLIT_WIDTH{1'b0}};
        else if(txsnp_cnt_tmp > {{(`MSHR_SNPCNT_WIDTH-1){1'b0}},1'b1})
            txsnpflit_s0_q <= txsnpflit_s0;
        else
            txsnpflit_s0_q <= txsnpflit_s0_q;
    end

    //just received it or not zero
    assign txsnp_crd_avail_s1      = txsnpcrdv_s0 | snp_crd_cnt_not_zero_sx;
    assign txsnp_busy_sx           = ~txsnp_crd_avail_s1;
    assign txsnpflitv_s0           = (txsnp_req_s0 == 1'b1 | txsnp_cnt_q>0) & (txsnp_busy_sx == 1'b0);


    //clear the bit if that bit is ready to send
    always @* begin : compute_target_need_to_be_send
        integer i;
        tgt_vec = mshr_txsnp_rn_vec_sx1;
        clr_1st = 1'b0;
        for(i = 0; i < `RNF_NUM ; i = i + 1)begin
            if(mshr_txsnp_rn_vec_sx1[i] == 1'b1 & txsnp_crd_avail_s1 == 1'b1 & clr_1st == 1'b0)begin
                tgt_vec[i] = 1'b0;
                clr_1st    = 1'b1;
            end
            else begin
                tgt_vec[i] = tgt_vec[i];
                clr_1st    = clr_1st;
            end
        end
    end

    //save the rn vector and snoopee cnt
    always @(posedge clk or posedge rst) begin: txsnp_cnt_q_logic_t
        integer i;
        if(rst == 1'b1)begin
            tgt_vec_q        <= {`RNF_NUM{1'b0}};
            txsnp_cnt_q      <= {`MSHR_SNPCNT_WIDTH{1'b0}};
        end
        else if((txsnp_crd_avail_s1 == 1'b1) & (mshr_txsnp_valid_sx1_q == 1'b1) & (txsnp_cnt_q == 0))begin
            tgt_vec_q        <= tgt_vec;
            txsnp_cnt_q      <= txsnp_cnt_tmp-1;
        end
        //if src match, clear its valid, rn cnt-1
        else if((txsnp_crd_avail_s1 == 1'b1) & (txsnpflitv_s0 == 1'b1) & (txsnp_cnt_q > 0) & (found_tgt_vec == 1))begin
            txsnp_cnt_q                   <= txsnp_cnt_q-1;
            tgt_vec_q[found_tgt_vec_num]  <= 1'b0;
        end
    end

    //can send packet,lcrdv-1
    assign txsnp_crd_cnt_dec_sx = txsnpflitv_s0;
    assign txsnpflitpend = 1'b1;

    always @(posedge clk or posedge rst) begin: txsnpflit_logic_t
        if(rst == 1'b1)begin
            txsnpflit  <= {`HNF_SNP_FLIT_WIDTH{1'b0}};
            txsnpflitv <= 1'b0;
        end
        else if((txsnpflitv_s0 == 1'b1) & (txsnp_crd_avail_s1 == 1'b1))begin
            txsnpflit  <= txsnpflit_s0;
            txsnpflitv <= 1'b1;
        end
        else begin
            txsnpflitv <= 1'b0;
            txsnpflit  <= txsnpflit;
        end
    end

    assign update_snp_crd_cnt_s0   = txsnp_crd_cnt_inc_sx | txsnp_crd_cnt_dec_sx;
    assign snp_crd_cnt_inc_s0      = (txsnp_crd_cnt_q + 1'b1);
    assign snp_crd_cnt_dec_s0      = (txsnp_crd_cnt_q - 1'b1);

    always @* begin: snp_crd_cnt_ns_s0_logic_c
        casez({txsnp_crd_cnt_inc_sx, txsnp_crd_cnt_dec_sx})
            2'b00:
                snp_crd_cnt_ns_s0   = txsnp_crd_cnt_q;     // hold
            2'b01:
                snp_crd_cnt_ns_s0   = snp_crd_cnt_dec_s0;  // dec
            2'b10:
                snp_crd_cnt_ns_s0   = snp_crd_cnt_inc_s0;  // inc
            2'b11:
                snp_crd_cnt_ns_s0   = txsnp_crd_cnt_q;     // hold
            default:
                snp_crd_cnt_ns_s0 = {`HNF_LCRD_SNP_CNT_WIDTH{1'b0}};
        endcase
    end

    always @(posedge clk or posedge rst) begin: txsnp_crd_cnt_q_logic_t
        if (rst == 1'b1)
            txsnp_crd_cnt_q <= {`HNF_LCRD_SNP_CNT_WIDTH{1'b0}};
        else if (update_snp_crd_cnt_s0 == 1'b1)
            txsnp_crd_cnt_q <= snp_crd_cnt_ns_s0;
        else
            txsnp_crd_cnt_q <= txsnp_crd_cnt_q;
    end

    //-----------------------------------------------------------------------------
    // DISPLAY INFO
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_INFO
    always @(posedge clk)begin
        if(txsnpflitv)begin
            `display_info($sformatf("HNF TXSNP send a flit\n tgtid: %h\n opcode: %h\n txnid: %h\n fwdnid: %h\n fwdtxnid: %h\n addr: %h\n rettosrc: %h\n Time: %0d\n",txsnpflit[`CHIE_SNP_FLIT_WIDTH+CHIE_NID_WIDTH_PARAM-1:`CHIE_SNP_FLIT_WIDTH],txsnpflit[`CHIE_SNP_FLIT_OPCODE_RANGE],txsnpflit[`CHIE_SNP_FLIT_TXNID_RANGE],txsnpflit[`CHIE_SNP_FLIT_FWDNID_RANGE],txsnpflit[`CHIE_SNP_FLIT_FWDTXNID_RANGE],txsnpflit[`CHIE_SNP_FLIT_ADDR_RANGE],txsnpflit[`CHIE_SNP_FLIT_RETTOSRC_RANGE],$time()));
        end
    end
`endif
endmodule
