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
*    Bingcheng Jin <jinbingcheng@bosc.ac.cn>
*    Hongyu Gao <gaohongyu@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_mshr_global_monitor `HNF_PARAM (clk,
            rst,
            mshr_alloc_en_s0,
            li_mshr_rxreq_valid_s0,
            li_mshr_rxreq_srcid_s0,
            li_mshr_rxreq_opcode_s0,
            li_mshr_rxreq_addr_s0,
            li_mshr_rxreq_ns_s0,
            li_mshr_rxreq_lpid_s0,
            li_mshr_rxreq_excl_s0,
            excl_pass_s1,
            excl_fail_s1);

    //inputs
    input  wire                                              clk;
    input  wire                                              rst;

    //inputs from hnf_mshr_qos
    input  wire                                              mshr_alloc_en_s0;

    //inputs from hnf_link_rxreq_parse
    input  wire                                              li_mshr_rxreq_valid_s0;
    input  wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             li_mshr_rxreq_srcid_s0;
    input  wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]            li_mshr_rxreq_opcode_s0;
    input  wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]              li_mshr_rxreq_addr_s0;
    input  wire [`CHIE_REQ_FLIT_NS_WIDTH-1:0]                li_mshr_rxreq_ns_s0;
    input  wire [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]              li_mshr_rxreq_lpid_s0;
    input  wire [`CHIE_REQ_FLIT_EXCL_WIDTH-1:0]              li_mshr_rxreq_excl_s0;

    //outputs to hnf_mshr_ctl and hnf_mshr_bypass
    output wire                                              excl_pass_s1;
    output wire                                              excl_fail_s1;


    reg                                   gb_valid_q[0:HNF_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]  gb_srcid_q[0:HNF_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]   gb_lpid_q[0:HNF_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]   gb_addr_q[0:HNF_MSHR_EXCL_RN_NUM_PARAM-1];

    reg                                   gb_valid_w[0:HNF_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]  gb_srcid_w[0:HNF_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]   gb_lpid_w[0:HNF_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]   gb_addr_w[0:HNF_MSHR_EXCL_RN_NUM_PARAM-1];

    wire                                              excl_load_s0;
    wire                                              excl_store_s0;
    wire                                              req_rdnosnp_s0;
    wire                                              req_rdnosharedirty_s0;
    wire                                              req_rdclean_s0;
    wire                                              req_wrnosnp_s0;
    wire                                              req_cleanunique_s0;
    wire                                              store_notmatch_wrnosnp_s0;//req writenosnp not match
    wire                                              store_notmatch_cu_s0;//req writenosnp not match
    reg                                               excl_pass_s1_q;
    reg                                               excl_fail_s1_q;
    reg                                               load_same_lp_s0;//load req come from same LP
    reg                                               load_new_lp_s0;//load req come from not same LP
    reg                                               store_match_s0;//store req match
    reg                                               cu_addr_notmatch_s0;//cleanunique req come from same LP but addr not match
    reg                                               load_samelp_flag;//judge the same LP or not
    reg                                               load_new_flag;//judge add new entry finish or not
    reg                                               store_cu_newentry_flag;//judge cleanunique add new entry finish or not

    assign req_rdnosnp_s0        = li_mshr_rxreq_excl_s0&&(li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_READNOSNP)&&mshr_alloc_en_s0;
    assign req_rdnosharedirty_s0 = li_mshr_rxreq_excl_s0&&(li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_READNOTSHAREDDIRTY)&&mshr_alloc_en_s0;
    assign req_rdclean_s0        = li_mshr_rxreq_excl_s0&&(li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_READCLEAN)&&mshr_alloc_en_s0;
    assign req_wrnosnp_s0        = li_mshr_rxreq_excl_s0&&(li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_WRITENOSNPFULL||li_mshr_rxreq_opcode_s0 == `CHIE_WRITENOSNPPTL)&&mshr_alloc_en_s0;
    assign req_cleanunique_s0    = li_mshr_rxreq_excl_s0&&(li_mshr_rxreq_valid_s0)&&(li_mshr_rxreq_opcode_s0 == `CHIE_CLEANUNIQUE)&&mshr_alloc_en_s0;

    assign excl_load_s0  = (req_rdnosnp_s0 || req_rdnosharedirty_s0 || req_rdclean_s0);
    assign excl_store_s0 = (req_wrnosnp_s0 || req_cleanunique_s0);
    assign store_notmatch_wrnosnp_s0    = !store_match_s0&&req_wrnosnp_s0;
    assign store_notmatch_cu_s0 = !store_match_s0&&req_cleanunique_s0;


    always@(*) begin :load_judge
        integer i;
        load_samelp_flag = 0;
        if(excl_load_s0)begin
            for(i = 0;i<HNF_MSHR_EXCL_RN_NUM_PARAM;i = i+1)begin
                if (gb_valid_q[i]&&li_mshr_rxreq_srcid_s0 == gb_srcid_q[i]&&li_mshr_rxreq_lpid_s0 == gb_lpid_q[i])begin
                    load_samelp_flag = 1;
                end
                else begin
                    load_samelp_flag = load_samelp_flag;
                end
            end
            if (!load_samelp_flag)begin
                load_same_lp_s0 = 1'b0;
                load_new_lp_s0  = 1'b1;
            end
            else begin
                load_same_lp_s0 = 1'b1;
                load_new_lp_s0  = 1'b0;
            end
        end
        else begin
            load_same_lp_s0 = 1'b0;
            load_new_lp_s0  = 1'b0;
        end
    end

    always@(*) begin :store_judge_match
        integer i;
        store_match_s0 = 1'b0;
        for(i = 0;i<HNF_MSHR_EXCL_RN_NUM_PARAM;i = i+1)begin
            if (excl_store_s0&&gb_valid_q[i]&&li_mshr_rxreq_srcid_s0 == gb_srcid_q[i]&&li_mshr_rxreq_lpid_s0 == gb_lpid_q[i]&&gb_addr_q[i][CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET] == li_mshr_rxreq_addr_s0[CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET])begin
                store_match_s0 = 1'b1;
            end
            else begin
                store_match_s0 = store_match_s0;
            end
        end
    end

    always@(*) begin :cleanunique_judge
        integer i;
        cu_addr_notmatch_s0 = 'd0;
        for(i = 0;i<HNF_MSHR_EXCL_RN_NUM_PARAM;i = i+1)begin
            if (store_notmatch_cu_s0&&gb_valid_q[i]&&li_mshr_rxreq_srcid_s0 == gb_srcid_q[i]&&li_mshr_rxreq_lpid_s0 == gb_lpid_q[i]&&gb_addr_q[i][CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET] != li_mshr_rxreq_addr_s0[CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET])begin
                cu_addr_notmatch_s0 = 'd1;
            end
            else begin
                cu_addr_notmatch_s0 = cu_addr_notmatch_s0;
            end
        end
    end


    always@(*) begin:temp_data
        integer i;
        load_new_flag=1;
        store_cu_newentry_flag=1;

        for(i = 0;i<HNF_MSHR_EXCL_RN_NUM_PARAM;i = i+1) begin:gb_ram_temp
            gb_valid_w[i]=gb_valid_q[i];
            gb_srcid_w[i]=gb_srcid_q[i];
            gb_lpid_w[i]=gb_lpid_q[i];
            gb_addr_w[i]=gb_addr_q[i];
            if (load_same_lp_s0&&gb_valid_q[i]&&li_mshr_rxreq_srcid_s0 == gb_srcid_q[i]&&li_mshr_rxreq_lpid_s0 == gb_lpid_q[i])begin
                gb_valid_w[i]='d1;
                gb_srcid_w[i]=li_mshr_rxreq_srcid_s0;
                gb_lpid_w[i]=li_mshr_rxreq_lpid_s0;
                gb_addr_w[i]=li_mshr_rxreq_addr_s0;
            end
            else if (load_new_lp_s0&&!gb_valid_q[i]&&load_new_flag)begin
                gb_valid_w[i]='d1;
                gb_srcid_w[i]=li_mshr_rxreq_srcid_s0;
                gb_lpid_w[i]=li_mshr_rxreq_lpid_s0;
                gb_addr_w[i]=li_mshr_rxreq_addr_s0;
                load_new_flag=0;
            end
            else if(store_match_s0&&gb_valid_q[i]&&gb_addr_q[i][CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET] == li_mshr_rxreq_addr_s0[CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET])begin
                gb_valid_w[i]='d0;
                gb_srcid_w[i]='d0;
                gb_lpid_w[i]='d0;
                gb_addr_w[i]='d0;
            end
            else if(store_notmatch_wrnosnp_s0&&gb_valid_q[i]&&li_mshr_rxreq_srcid_s0 == gb_srcid_q[i]&&li_mshr_rxreq_lpid_s0 == gb_lpid_q[i]&&gb_addr_q[i][CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET] != li_mshr_rxreq_addr_s0[CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET])begin
                gb_valid_w[i]='d0;
                gb_srcid_w[i]='d0;
                gb_lpid_w[i]='d0;
                gb_addr_w[i]='d0;
            end
            else if(store_notmatch_cu_s0&&gb_valid_q[i]&&li_mshr_rxreq_srcid_s0 == gb_srcid_q[i]&&li_mshr_rxreq_lpid_s0 == gb_lpid_q[i]&&gb_addr_q[i][CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET] != li_mshr_rxreq_addr_s0[CHIE_REQ_ADDR_WIDTH_PARAM-1:`CACHE_BLOCK_OFFSET])begin
                gb_valid_w[i]='d1;
                gb_srcid_w[i]=li_mshr_rxreq_srcid_s0;
                gb_lpid_w[i]=li_mshr_rxreq_lpid_s0;
                gb_addr_w[i]=li_mshr_rxreq_addr_s0;
            end
            else if(store_notmatch_cu_s0&&!cu_addr_notmatch_s0&&!gb_valid_q[i]&&store_cu_newentry_flag)begin
                gb_valid_w[i]='d1;
                gb_srcid_w[i]=li_mshr_rxreq_srcid_s0;
                gb_lpid_w[i]=li_mshr_rxreq_lpid_s0;
                gb_addr_w[i]=li_mshr_rxreq_addr_s0;
                store_cu_newentry_flag=0;
            end
            else begin
                gb_valid_w[i]=gb_valid_w[i];
                gb_srcid_w[i]=gb_srcid_w[i];
                gb_lpid_w[i]=gb_lpid_w[i];
                gb_addr_w[i]=gb_addr_w[i];
            end
        end
    end

    genvar i;
    generate
        for(i = 0;i<HNF_MSHR_EXCL_RN_NUM_PARAM;i = i+1)begin
            always@(posedge clk or posedge rst) begin :data_update
                if (rst) begin
                    gb_valid_q[i]          <= 'd0;
                    gb_srcid_q[i]          <= 'd0;
                    gb_lpid_q[i]           <= 'd0;
                    gb_addr_q[i]           <= 'd0;
                end
                else begin
                    gb_valid_q[i]          <= gb_valid_w[i];
                    gb_srcid_q[i]          <= gb_srcid_w[i];
                    gb_lpid_q[i]           <= gb_lpid_w[i] ;
                    gb_addr_q[i]           <= gb_addr_w[i] ;
                end
            end
        end
    endgenerate

    always@(posedge clk or posedge rst) begin :excl_pass
        if (rst) begin
            excl_pass_s1_q <= 'd0;
            excl_fail_s1_q <= 'd0;
        end
        else begin
            if(excl_store_s0&&!store_match_s0)begin
                excl_pass_s1_q <= 'd0;
                excl_fail_s1_q <= 'd1;
            end
            else if (excl_load_s0||store_match_s0)begin
                excl_pass_s1_q <= 'd1;
                excl_fail_s1_q <= 'd0;
            end
            else begin
                excl_pass_s1_q <= 'd0;
                excl_fail_s1_q <= 'd0;
            end

        end
    end

    assign excl_pass_s1 = excl_pass_s1_q;
    assign excl_fail_s1 = excl_fail_s1_q;
    //-----------------------------------------------------------------------------
    // DISPLAY FATAL
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_FATAL

    always @(*)begin
        `display_fatal((!li_mshr_rxreq_valid_s0) || (!li_mshr_rxreq_excl_s0) || (li_mshr_rxreq_opcode_s0==`CHIE_READNOSNP) || (li_mshr_rxreq_opcode_s0==`CHIE_READNOTSHAREDDIRTY) || (li_mshr_rxreq_opcode_s0==`CHIE_READCLEAN) || (li_mshr_rxreq_opcode_s0==`CHIE_WRITENOSNPFULL) || (li_mshr_rxreq_opcode_s0==`CHIE_CLEANUNIQUE) || (li_mshr_rxreq_opcode_s0==`CHIE_WRITENOSNPPTL),$sformatf("Fatal info: RXREQ received a unsupported excl flit with opcode: %h",li_mshr_rxreq_opcode_s0));
    end

    reg gm_full;
    always @(*)begin
        integer i;
        gm_full = 1;
        for(i = 0;i<HNF_MSHR_EXCL_RN_NUM_PARAM;i = i+1)begin
            gm_full = gm_full & gb_valid_q[i];
        end
    end
    always @(posedge clk)begin
        integer i;
        if(load_new_lp_s0 && (gm_full))begin
            $display($sformatf("Fatal info: Global Monitor overflowed,when RXREQ receield a excl filt with srcid: %h lpid: %h",li_mshr_rxreq_srcid_s0,li_mshr_rxreq_lpid_s0));
            for(i = 0;i<HNF_MSHR_EXCL_RN_NUM_PARAM;i = i+1)begin
                $display($sformatf("Global Monitor entry %d: srcid: %h,lpid: %h\n",i,gb_srcid_q[i],gb_lpid_q[i]));
            end
            `display_fatal(0,"");
        end
    end
`endif
endmodule



