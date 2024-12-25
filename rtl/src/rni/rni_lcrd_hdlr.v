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

module rni_lcrd_hdlr #(
        parameter LCRD_INIT_CNT_VAL = 4,
        parameter LCRD_MAX_CNT_VAL  = 4
    )
    (
        // global inputs
        clk,
        rst,

        // inputs
        lcrd_inc,
        lcrd_dec,

        // outputs
        lcrd_full,
        lcrd_avail
    );

    // local param
    localparam LCRD_MAX_CNT_WIDTH = ((LCRD_MAX_CNT_VAL == 1)? 1 :
                                     (LCRD_MAX_CNT_VAL < 4)? 2 :
                                     (LCRD_MAX_CNT_VAL < 8)? 3 :
                                     (LCRD_MAX_CNT_VAL < 16)? 4 : 5);

    // global inputs
    input  wire clk;
    input  wire rst;

    // inputs
    input  wire lcrd_inc;
    input  wire lcrd_dec;

    // outputs
    output wire lcrd_full;
    output wire lcrd_avail;

    // internal wire
    wire                         lcrd_cnt_upd_s0;
    wire                         lcrd_cnt_not_zero;

    // internal reg
    reg [LCRD_MAX_CNT_WIDTH-1:0] lcrd_cnt_s0;
    reg [LCRD_MAX_CNT_WIDTH-1:0] lcrd_cnt_s1_q;
    reg                          lcrd_idle;

    // main function
    always @* begin
        casez({lcrd_inc,lcrd_dec})
            2'b00 :
                lcrd_cnt_s0 = lcrd_cnt_s1_q;
            2'b01 :
                lcrd_cnt_s0 = (lcrd_cnt_s1_q - 1'b1);
            2'b10 :
                lcrd_cnt_s0 = (lcrd_cnt_s1_q + 1'b1);
            2'b11 :
                lcrd_cnt_s0 = lcrd_cnt_s1_q;
        endcase
    end

    assign lcrd_cnt_upd_s0 = lcrd_inc | lcrd_dec;

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1)
            lcrd_idle <= 1'b1;
        else if(lcrd_idle == 1'b1)
            lcrd_idle <= ~lcrd_idle;
    end

    always @(posedge clk or posedge rst) begin
        if (rst == 1'b1)
            lcrd_cnt_s1_q <= {LCRD_MAX_CNT_WIDTH{1'b0}};
        else if (lcrd_idle == 1'b1)
            lcrd_cnt_s1_q <= LCRD_INIT_CNT_VAL;
        else if (lcrd_cnt_upd_s0 == 1'b1)
            lcrd_cnt_s1_q <= lcrd_cnt_s0;
    end

    assign lcrd_cnt_not_zero = (lcrd_cnt_s1_q != {LCRD_MAX_CNT_WIDTH{1'b0}});
    assign lcrd_full  = ~lcrd_dec & (lcrd_cnt_s1_q == LCRD_MAX_CNT_VAL);
    assign lcrd_avail = (lcrd_cnt_not_zero | lcrd_inc) & (rst == 1'b0);

    // Assertion Checker
`ifdef ASSERT_CHECKER_ON

    assert_checker #(
                       3,  // security_level
                       "LCRD_MAX_CNT_VAL must be less than 16!")
                   LCRD_MAX_CNT_VAL_check (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (LCRD_MAX_CNT_VAL > 15)
                   );

    assert_checker #(
                       3,  // security_level
                       "LCRD_INIT_CNT_VAL must be less than or equal LCRD_MAX_CNT_VAL!")
                   LCRD_INIT_CNT_VAL_check (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (LCRD_INIT_CNT_VAL > LCRD_MAX_CNT_VAL)
                   );

    assert_checker #(
                       2,  // security_level
                       "Decrease when L-credit is empty!")
                   dec_when_lcrd_empty_check (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (lcrd_dec & ~lcrd_inc & ~lcrd_avail)
                   );

    assert_checker #(
                       2,  // security_level
                       "Increase when L-credit is full!")
                   inc_when_lcrd_full_check (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (lcrd_inc & lcrd_full)
                   );
`endif

endmodule
