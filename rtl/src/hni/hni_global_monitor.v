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

module hni_global_monitor `HNI_PARAM 
    (
        clk,
        rst,
        rxreq_alloc_en_s0,
        rxreq_alloc_flit_s0,
        excl_pass_s1,
        excl_fail_s1
    );

    //inputs
    input  wire                                              clk;
    input  wire                                              rst;

    //inputs from hni_qos
    input  wire                                              rxreq_alloc_en_s0;
    input  wire [`CHIE_REQ_FLIT_RANGE]                       rxreq_alloc_flit_s0;

    //outputs to hni_mshr and hni_txrsp(fastpath)
    output wire                                              excl_pass_s1;
    output wire                                              excl_fail_s1;

    reg                                   gb_valid_q[0:HNI_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]  gb_srcid_q[0:HNI_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]   gb_lpid_q[0:HNI_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]   gb_addr_q[0:HNI_MSHR_EXCL_RN_NUM_PARAM-1];

    reg                                   gb_valid_w[0:HNI_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]  gb_srcid_w[0:HNI_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]   gb_lpid_w[0:HNI_MSHR_EXCL_RN_NUM_PARAM-1];
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]   gb_addr_w[0:HNI_MSHR_EXCL_RN_NUM_PARAM-1];

    wire                                              rxreq_excl_s0;
    wire [`CHIE_REQ_FLIT_OPCODE_WIDTH-1:0]            rxreq_opcode_s0;
    wire [`CHIE_REQ_FLIT_SRCID_WIDTH-1:0]             rxreq_srcid_s0;
    wire [`CHIE_REQ_FLIT_LPID_WIDTH-1:0]              rxreq_lpid_s0;
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]              rxreq_addr_s0;
    wire                                              excl_load_s0;
    wire                                              rxreq_wr_s0;
    wire                                              excl_store_s0;
    wire                                              store_notmatch_s0;//req writenosnp not match

    reg                                               excl_pass_s1_q;
    reg                                               excl_fail_s1_q;
    reg                                               load_same_lp_s0;//load req come from same LP
    reg                                               load_new_lp_s0;//load req come from not same LP
    reg                                               store_match_s0;//store req match
    reg                                               load_samelp_flag;//judge the same LP or not
    reg                                               load_new_flag;//judge add new entry finish or not

    assign rxreq_excl_s0         = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_EXCL_RANGE]   : {`CHIE_REQ_FLIT_EXCL_WIDTH{1'b0}};
    assign rxreq_opcode_s0       = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_OPCODE_RANGE] : {`CHIE_REQ_FLIT_OPCODE_WIDTH{1'b0}};
    assign rxreq_srcid_s0        = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_SRCID_RANGE]  : {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
    assign rxreq_lpid_s0         = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_LPID_RANGE]   : {`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
    assign rxreq_addr_s0         = (rxreq_alloc_en_s0 == 1'b1) ? rxreq_alloc_flit_s0[`CHIE_REQ_FLIT_ADDR_RANGE]   : {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};

    assign excl_load_s0          = rxreq_excl_s0&&(rxreq_opcode_s0 == `CHIE_READNOSNP)&&rxreq_alloc_en_s0;
    assign rxreq_wr_s0           = (rxreq_opcode_s0 == `CHIE_WRITENOSNPFULL||rxreq_opcode_s0 == `CHIE_WRITENOSNPPTL)&&rxreq_alloc_en_s0;
    assign excl_store_s0         = rxreq_excl_s0&&rxreq_wr_s0;

    assign store_notmatch_s0    = !store_match_s0&&excl_store_s0;

    always@(*) begin :load_judge
        integer i;
        load_samelp_flag = 1'b0;
        if(excl_load_s0)begin
            for(i = 0;i<HNI_MSHR_EXCL_RN_NUM_PARAM;i = i+1)begin
                if (gb_valid_q[i]&&rxreq_srcid_s0 == gb_srcid_q[i]&&rxreq_lpid_s0 == gb_lpid_q[i])begin
                    load_samelp_flag = 1'b1;
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
        for(i = 0;i<HNI_MSHR_EXCL_RN_NUM_PARAM;i = i+1)begin
            if (excl_store_s0&&gb_valid_q[i]&&rxreq_srcid_s0 == gb_srcid_q[i]&&rxreq_lpid_s0 == gb_lpid_q[i]&&gb_addr_q[i][CHIE_REQ_ADDR_WIDTH_PARAM-1:0] == rxreq_addr_s0[CHIE_REQ_ADDR_WIDTH_PARAM-1:0])begin
                store_match_s0 = 1'b1;
            end
            else begin
                store_match_s0 = store_match_s0;
            end
        end
    end

    always@(*) begin:temp_data
        integer i;
        load_new_flag=1'b1;
        for(i = 0;i<HNI_MSHR_EXCL_RN_NUM_PARAM;i = i+1) begin:gb_ram_temp
            gb_valid_w[i]=gb_valid_q[i];
            gb_srcid_w[i]=gb_srcid_q[i];
            gb_lpid_w[i]=gb_lpid_q[i];
            gb_addr_w[i]=gb_addr_q[i];
            if (load_same_lp_s0&&gb_valid_q[i]&&rxreq_srcid_s0 == gb_srcid_q[i]&&rxreq_lpid_s0 == gb_lpid_q[i])begin
                gb_valid_w[i]=1'b1;
                gb_srcid_w[i]=rxreq_srcid_s0;
                gb_lpid_w[i]=rxreq_lpid_s0;
                gb_addr_w[i]=rxreq_addr_s0;
            end
            else if (load_new_lp_s0&&!gb_valid_q[i]&&load_new_flag)begin
                gb_valid_w[i]=1'b1;
                gb_srcid_w[i]=rxreq_srcid_s0;
                gb_lpid_w[i]=rxreq_lpid_s0;
                gb_addr_w[i]=rxreq_addr_s0;
                load_new_flag=1'b0;
            end
            else if(store_match_s0 && gb_valid_q[i] && gb_addr_q[i][CHIE_REQ_ADDR_WIDTH_PARAM-1:0] == rxreq_addr_s0[CHIE_REQ_ADDR_WIDTH_PARAM-1:0])begin
                gb_valid_w[i]=1'b0;
                gb_srcid_w[i]={`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
                gb_lpid_w[i]={`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
                gb_addr_w[i]={`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
            end
            else if(rxreq_wr_s0 && !excl_store_s0 && gb_valid_q[i] && ((rxreq_srcid_s0 != gb_srcid_q[i]) || (rxreq_lpid_s0 != gb_lpid_q[i])) && gb_addr_q[i][CHIE_REQ_ADDR_WIDTH_PARAM-1:0] == rxreq_addr_s0[CHIE_REQ_ADDR_WIDTH_PARAM-1:0])begin
                gb_valid_w[i]=1'b0;
                gb_srcid_w[i]={`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
                gb_lpid_w[i]={`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
                gb_addr_w[i]={`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
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
        for(i = 0;i<HNI_MSHR_EXCL_RN_NUM_PARAM;i = i+1)begin
            always@(posedge clk or posedge rst) begin :data_update
                if (rst) begin
                    gb_valid_q[i]          <= 1'b0;
                    gb_srcid_q[i]          <= {`CHIE_REQ_FLIT_SRCID_WIDTH{1'b0}};
                    gb_lpid_q[i]           <= {`CHIE_REQ_FLIT_LPID_WIDTH{1'b0}};
                    gb_addr_q[i]           <= {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
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
            excl_pass_s1_q <= 1'b0;
            excl_fail_s1_q <= 1'b0;
        end
        else begin
            if(store_notmatch_s0)begin
                excl_pass_s1_q <= 1'b0;
                excl_fail_s1_q <= 1'b1;
            end
            else if (excl_load_s0||store_match_s0)begin
                excl_pass_s1_q <= 1'b1;
                excl_fail_s1_q <= 1'b0;
            end
            else begin
                excl_pass_s1_q <= 1'b0;
                excl_fail_s1_q <= 1'b0;
            end

        end
    end

    assign excl_pass_s1 = excl_pass_s1_q;
    assign excl_fail_s1 = excl_fail_s1_q;

endmodule

