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

module poll_function #(
        parameter POLL_ENTRIES_NUM = 4,
        // MODE
        // 0: always start finding entry from LSB.
        // 1: start finding entry from previous selected entry.
        parameter POLL_MODE = 1
    )
    (
        //global inputs
        clk,
        rst,

        //inputs
        entry_vec,
        upd,

        //outputs
        found,
        sel_entry,
        sel_index
    );
    //local parameters
    localparam POLL_ENTRIES_WIDTH = (POLL_ENTRIES_NUM == 1)? 1 : $clog2(POLL_ENTRIES_NUM);

    //global inputs
    input  wire                          clk;
    input  wire                          rst;

    //inputs
    input  wire  [POLL_ENTRIES_NUM-1:0]  entry_vec;
    input  wire                          upd;

    //outputs
    output wire                          found;
    output wire [POLL_ENTRIES_NUM-1:0]   sel_entry;
    output wire [POLL_ENTRIES_WIDTH-1:0] sel_index;

    //internal wire
    wire [POLL_ENTRIES_NUM-1:0]          nxt_entry_mask;
    wire [POLL_ENTRIES_NUM-1:0]          entry_vecx;

    //internal reg
    reg  [POLL_ENTRIES_NUM-1:0]          nxt_entry_mask0;
    reg  [POLL_ENTRIES_NUM-1:0]          nxt_entry_maskx;
    reg  [POLL_ENTRIES_NUM-1:0]          nxt_entry_mask_q;
    reg  [POLL_ENTRIES_NUM-1:0]          entry_vec_ptr_sel0_tmp;
    reg  [POLL_ENTRIES_NUM-1:0]          entry_vec_ptr_selx_tmp;
    reg  [POLL_ENTRIES_NUM-1:0]          entry_vec_ptr_sel0;
    reg  [POLL_ENTRIES_NUM-1:0]          entry_vec_ptr_selx;
    reg                                  found0;
    reg                                  foundx;
    reg  [POLL_ENTRIES_WIDTH-1:0]        sel0_index;
    reg  [POLL_ENTRIES_WIDTH-1:0]        selx_index;

    always @* begin : find_1st_entry_from_entry_vec
        integer i;
        entry_vec_ptr_sel0_tmp = {POLL_ENTRIES_NUM{1'b0}};
        entry_vec_ptr_sel0 = {POLL_ENTRIES_NUM{1'b0}};

        for (i=1; i<POLL_ENTRIES_NUM; i=i+1)begin
            entry_vec_ptr_sel0_tmp[i] = entry_vec_ptr_sel0_tmp[i-1] | entry_vec[i-1];
        end

        for(i=0; i<POLL_ENTRIES_NUM; i=i+1)begin
            entry_vec_ptr_sel0[i] = ~entry_vec_ptr_sel0_tmp[i] & entry_vec[i];
        end
    end

    assign entry_vecx = entry_vec & nxt_entry_mask_q;

    always @* begin :find_xst_entry_from_entry_vecx
        integer i;
        entry_vec_ptr_selx_tmp = {POLL_ENTRIES_NUM{1'b0}};
        entry_vec_ptr_selx = {POLL_ENTRIES_NUM{1'b0}};

        for (i=1; i<POLL_ENTRIES_NUM; i=i+1)begin
            entry_vec_ptr_selx_tmp[i] = entry_vec_ptr_selx_tmp[i-1] | entry_vecx[i-1];
        end

        for(i=0; i<POLL_ENTRIES_NUM; i=i+1)begin
            entry_vec_ptr_selx[i] = ~entry_vec_ptr_selx_tmp[i] & entry_vecx[i];
        end
    end

    always@* begin : mask_nxt_from_entry0
        integer i;
        nxt_entry_mask0 = {POLL_ENTRIES_NUM{1'b1}};
        found0 = 1'b0;
        sel0_index = {POLL_ENTRIES_WIDTH{1'b0}};
        for(i=0;i<POLL_ENTRIES_NUM;i=i+1)begin
            if(entry_vec[i] == 1'b1 && !found0)begin
                nxt_entry_mask0[i] = 1'b0;
                sel0_index = i;
                found0 = 1'b1;
            end
            else if(found0)begin
            end
            else
                nxt_entry_mask0[i] = 1'b0;
        end
    end

    always@* begin : mask_nxt_from_entryx
        integer i;
        nxt_entry_maskx = nxt_entry_mask_q;
        foundx = 1'b0;
        selx_index = {POLL_ENTRIES_WIDTH{1'b0}};
        for(i=0;i<POLL_ENTRIES_NUM;i=i+1)begin
            if(entry_vecx[i] == 1'b1 && !foundx)begin
                nxt_entry_maskx[i] = 1'b0;
                selx_index = i;
                foundx = 1'b1;
            end
            else if(foundx)begin
            end
            else
                nxt_entry_maskx[i] = 1'b0;
        end
    end

    assign sel_entry = (foundx & POLL_MODE)? entry_vec_ptr_selx : entry_vec_ptr_sel0;
    assign sel_index = (foundx & POLL_MODE)? selx_index : sel0_index;
    assign nxt_entry_mask = (foundx & POLL_MODE)? nxt_entry_maskx : nxt_entry_mask0;

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1)
            nxt_entry_mask_q <= {POLL_ENTRIES_NUM{1'b0}};
        else if (upd == 1'b1 & POLL_MODE == 1'b1)
            nxt_entry_mask_q <= nxt_entry_mask;
    end

    assign found = foundx | found0;

    // Assertion Checker
`ifdef ASSERT_CHECKER_ON

    assert_checker #(
                       1,  // security_level
                       "Update when entry_vec is ZERO!")
                   entry_vec_check (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (upd & (entry_vec == {POLL_ENTRIES_NUM{1'b0}}))
                   );

    assert_checker #(
                       3,  // security_level
                       "POLL_ENTRIES_NUM must be NOT greater than 128")
                   POLL_ENTRIES_NUM_MAX_check (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (POLL_ENTRIES_NUM > 128)
                   );

    assert_checker #(
                       3,  // security_level
                       "Invalid POLL_MODE value,should be only 1 or 0")
                   POLL_MODE_check (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (~((POLL_MODE == 1) || (POLL_MODE == 0)))
                   );
`endif
endmodule
