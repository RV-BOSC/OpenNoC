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

module rni_bcount_ctl
    (
        // global input
        clk,
        rst,

        // input
        rq_valid,
        wd_valid,
        bcount_vec,
        ctmask,
        pdmask,

        // output
        fdmask,
        bk_done,
        rq_done
    );

    // global input
    input  wire                 clk;
    input  wire                 rst;

    // input
    input  wire                 rq_valid;
    input  wire                 wd_valid;
    input  wire [16-1:0]        bcount_vec;
    input  wire [4-1:0]         ctmask;
    input  wire [4-1:0]         pdmask;

    // output
    output wire [4-1:0]         fdmask;
    output wire                 bk_done;
    output wire                 rq_done;

    // wire
    wire [4-1:0]                fdmask_nxt;
    wire                        bcount_upd;
    wire [4-1:0]                bcount_nxt;
    wire [4-1:0]                bcount_int;
    wire                        bcount_zero;
    wire [4-1:0]                pdmask_nxt;
    wire                        fdmask_upd;
    wire                        pdmask_upd;

    // reg
    reg  [4-1:0]                fdmask_q;
    reg  [4-1:0]                bcount_q;
    reg  [4-1:0]                pdmask_q;

    // main function
    // pdmask update
    assign pdmask_nxt = (|pdmask_q)? (~fdmask & pdmask_q) : (~ctmask & pdmask);
    assign pdmask_upd = bk_done;

    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1)
            pdmask_q <= {4{1'b0}};
        else if(pdmask_upd)
            pdmask_q <= pdmask_nxt;
    end

    // beat count update
    assign bcount_int = ({4{fdmask[3]}} & bcount_vec[15:12]) |
           ({4{fdmask[2]}} & bcount_vec[11:8])  |
           ({4{fdmask[1]}} & bcount_vec[7:4])   |
           ({4{fdmask[0]}} & bcount_vec[3:0])   ;

    assign bcount_nxt = (bcount_q == {4{1'b0}})? bcount_int : (bcount_q - 1'b1);
    assign bcount_upd = rq_valid & wd_valid;

    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1)
            bcount_q <= {4{1'b0}};
        else if(bcount_upd)
            bcount_q <= bcount_nxt;
    end

    assign bcount_zero = ((bcount_nxt == {4{1'b0}}) & (bcount_int != {4{1'b0}})) | (bcount_int == {4{1'b0}});

    assign bk_done = rq_valid & wd_valid & bcount_zero;
    assign rq_done  = rq_valid & wd_valid & ~(|pdmask_nxt) & bk_done;

    // fdmask update
    assign fdmask_nxt = (rq_done)? {4{1'b0}} : {fdmask[2:0],fdmask[3]};
    assign fdmask_upd = bk_done;

    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1)
            fdmask_q <= {4{1'b0}};
        else if(fdmask_upd)
            fdmask_q <= fdmask_nxt;
    end

    assign fdmask = (|fdmask_q)? fdmask_q : ctmask;

    // Assertion Checker
`ifdef ASSERT_CHECKER_ON

    assert_checker #(
                       2,  // security_level
                       "ctmask is ZERO!")
                   cdmask_check (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (rq_valid & ~(|ctmask))
                   );
`endif

endmodule
