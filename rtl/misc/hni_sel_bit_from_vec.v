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
`include "hni_defines.v"
`include "hni_param.v"

module hni_sel_bit_from_vec `HNI_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from hni_qos
        req_entry_vec,
        upd_start_entry,

        //outputs to hni_qos
        req_entry_ptr_sel
    );
    //local parameters
    localparam ENTRIES_NUM = HNI_MSHR_RNF_NUM_PARAM;

    //global inputs
    input wire                    clk;
    input wire                    rst;

    //inputs from hni_qos
    input wire  [ENTRIES_NUM-1:0] req_entry_vec;
    input wire                    upd_start_entry;

    //outputs to hni_qos
    output wire [ENTRIES_NUM-1:0] req_entry_ptr_sel;

    //internal wire signals
    wire [ENTRIES_NUM-1:0]        nxt_entry_ns;
    wire [ENTRIES_NUM-1:0]        req_entry_vecx;

    //internal reg signals
    reg  [ENTRIES_NUM-1:0]        nxt_entry0;
    reg  [ENTRIES_NUM-1:0]        nxt_entryx;
    reg  [ENTRIES_NUM-1:0]        nxt_entry_q;
    reg  [ENTRIES_NUM-1:0]        req_entry_vec_q;
    reg  [ENTRIES_NUM-1:0]        req_entry_ptr_sel0_vector;
    reg  [ENTRIES_NUM-1:0]        req_entry_ptr_selx_vector;
    reg  [ENTRIES_NUM-1:0]        req_entry_ptr_sel0;
    reg  [ENTRIES_NUM-1:0]        req_entry_ptr_selx;
    reg                           found0;
    reg                           foundx;

    always @* begin: req_entry_ptr_sel0_vector_sel_comb_logic
        integer i;
        req_entry_ptr_sel0_vector = {ENTRIES_NUM{1'b0}};
        req_entry_ptr_sel0 = {ENTRIES_NUM{1'b0}};

        for (i=1; i<ENTRIES_NUM; i=i+1)begin
            req_entry_ptr_sel0_vector[i] = req_entry_ptr_sel0_vector[i-1] | req_entry_vec_q[i-1];
        end

        for(i=0; i<ENTRIES_NUM; i=i+1)begin
            req_entry_ptr_sel0[i] = ~req_entry_ptr_sel0_vector[i] & req_entry_vec_q[i];
        end
    end

    always@* begin: find_from_entry0
        integer i;
        nxt_entry0 = {ENTRIES_NUM{1'b1}};
        found0 = 1'b0;
        for(i=0; i<ENTRIES_NUM; i=i+1)begin
            if(req_entry_vec_q[i] == 1'b1 && !found0)begin
                nxt_entry0[i] = 1'b0;
                found0 = 1'b1;
            end
            else if(found0)begin
            end
            else
                nxt_entry0[i] = 1'b0;
        end
    end

    assign req_entry_vecx = req_entry_vec_q & nxt_entry_q;

    always @* begin: req_entry_ptr_selx_vector_sel_comb_logic
        integer i;
        req_entry_ptr_selx_vector = {ENTRIES_NUM{1'b0}};
        req_entry_ptr_selx = {ENTRIES_NUM{1'b0}};

        for (i=1; i<ENTRIES_NUM; i=i+1)begin
            req_entry_ptr_selx_vector[i] = req_entry_ptr_selx_vector[i-1] | req_entry_vecx[i-1];
        end

        for(i=0; i<ENTRIES_NUM; i=i+1)begin
            req_entry_ptr_selx[i] = ~req_entry_ptr_selx_vector[i] & req_entry_vecx[i];
        end
    end

    always@* begin: find_from_entryx
        integer i;
        nxt_entryx = nxt_entry_q;
        foundx = 1'b0;
        for(i=0; i<ENTRIES_NUM; i=i+1)begin
            if(req_entry_vecx[i] == 1'b1 && !foundx)begin
                nxt_entryx[i] = 1'b1;
                foundx = 1'b1;
            end
            else if(foundx)begin
            end
            else
                nxt_entryx[i] = 1'b0;
        end
    end

    assign nxt_entry_ns = (foundx)? (nxt_entryx<<1) : nxt_entry0;

    always @(posedge clk or posedge rst) begin: update_nxt_entry_timing_logic
        if (rst == 1'b1)begin
            nxt_entry_q <= {ENTRIES_NUM{1'b0}};
            req_entry_vec_q <= {ENTRIES_NUM{1'b0}};
        end
        else if (upd_start_entry == 1'b1)begin
            nxt_entry_q <= nxt_entry_ns;
            req_entry_vec_q <= req_entry_vec;
        end
    end

    assign req_entry_ptr_sel = (foundx)? req_entry_ptr_selx : req_entry_ptr_sel0;

endmodule
