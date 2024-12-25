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

`include "rni_defines.v"
module rni_link_handshake
    (
        // global input
        clk,
        rst,

        // link handshake interface
        TXLINKACTIVEREQ,
        TXLINKACTIVEACK,

        RXLINKACTIVEREQ,
        RXLINKACTIVEACK,

        txlink_state,
        rxlink_state,

        txflit_avail,
        rxcrd_cnt_full,

        lcrd_return_en,
        rxcrd_en
    );

    // global input
    input  wire                       clk;
    input  wire                       rst;

    // link handshake interface
    output wire                       TXLINKACTIVEREQ;
    input  wire                       TXLINKACTIVEACK;

    input  wire                       RXLINKACTIVEREQ;
    output wire                       RXLINKACTIVEACK;

    output wire [`LL_STATE_WIDTH-1:0] txlink_state;
    output wire [`LL_STATE_WIDTH-1:0] rxlink_state;

    input  wire                       txflit_avail;
    input  wire                       rxcrd_cnt_full;

    output wire                       lcrd_return_en;
    output wire                       rxcrd_en;

    // wire

    // reg
    reg                               txlinkactivereq_s0;
    reg                               rxlinkactiveack_s0;
    reg                               txlinkactivereq_s1_q;
    reg                               txlinkactiveack_s1_q;
    reg                               rxlinkactivereq_s1_q;
    reg                               rxlinkactiveack_s1_q;

    // main function
    // TXLINKACTIVE
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)
            txlinkactiveack_s1_q <= 1'b0;
        else
            txlinkactiveack_s1_q <= TXLINKACTIVEACK;
    end

    always@* begin
        case(txlink_state)
            // Transition from STOP to ACTIVATE when:
            // 1. Need to send txflit and RXLINK state is NOT DEACTIVATE or RUN.
            // 2. Received RXLINKACTIVEREQ
            `LL_STOP :
                txlinkactivereq_s0 = (txflit_avail & (rxlink_state == `LL_STOP)) | (rxlink_state == `LL_ACTIVATE);
            // Transition from RUN to DEACTIVATE when:
            // 1. Received RXLINKACTIVEREQ = 0
            `LL_RUN  :
                txlinkactivereq_s0 = ~(rxlink_state == `LL_DEACTIVATE);
            default  :
                txlinkactivereq_s0 = txlinkactivereq_s1_q;
        endcase
    end

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)
            txlinkactivereq_s1_q <= 1'b0;
        else
            txlinkactivereq_s1_q <= txlinkactivereq_s0;
    end

    assign TXLINKACTIVEREQ = txlinkactivereq_s1_q;

    assign txlink_state = {txlinkactivereq_s1_q, txlinkactiveack_s1_q};

    // RXLINKACTIVE
    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)
            rxlinkactivereq_s1_q <= 1'b0;
        else
            rxlinkactivereq_s1_q <= RXLINKACTIVEREQ;
    end

    always@* begin
        case(rxlink_state)
            // Transition from ACTIVATE to RUN when:
            // 1. TXLINK state is NOT DEACTIVATE
            `LL_ACTIVATE   :
                rxlinkactiveack_s0 = (txlink_state != `LL_DEACTIVATE);
            // Transition from DEACTIVATE to STOP when:
            // 1. All credits are received and TXLINK state is NOT ACTIVATE
            `LL_DEACTIVATE :
                rxlinkactiveack_s0 = ~(rxcrd_cnt_full & (txlink_state != `LL_ACTIVATE));
            default        :
                rxlinkactiveack_s0 = rxlinkactiveack_s1_q;
        endcase
    end

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)
            rxlinkactiveack_s1_q <= 1'b0;
        else
            rxlinkactiveack_s1_q <= rxlinkactiveack_s0;
    end

    assign RXLINKACTIVEACK = rxlinkactiveack_s1_q;

    assign rxlink_state    = {rxlinkactivereq_s1_q, rxlinkactiveack_s1_q};

    assign lcrd_return_en  = ~txlinkactivereq_s1_q;
    assign rxcrd_en        = (rxlink_state == `LL_RUN);

endmodule
