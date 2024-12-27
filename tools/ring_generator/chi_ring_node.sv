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
*    Jianxing Wang <wangjianxing@bosc.ac.cn>
*    Zhao Li       <lizhao@bosc.ac.cn>
*/

`ifndef CHI_RING_NODE_H
`define CHI_RING_NODE_H
module chi_ring_node #(
    parameter REQ_FLIT_WIDTH,
    parameter RSP_FLIT_WIDTH,
    parameter DAT_FLIT_WIDTH,
    parameter SNP_FLIT_WIDTH,
    parameter SNP_TGTID_OFFSET,
    parameter REQ_CH_EN = {6{1'b1}},
    parameter RSP_CH_EN = {6{1'b1}},
    parameter DAT_CH_EN = {6{1'b1}},
    parameter SNP_CH_EN = {6{1'b1}},
    parameter ROUTER_NODE_NUM
) (
    input clk,
    input rst,
    input [6:1] my_xid,

    //REQ
    input RXREQFLITV_E,
    input RXREQFLITV_W,
    input RXREQFLITV_P0,
    input RXREQFLITV_P1,

    input [REQ_FLIT_WIDTH-1:0] RXREQFLIT_E,
    input [REQ_FLIT_WIDTH-1:0] RXREQFLIT_W,
    input [REQ_FLIT_WIDTH-1:0] RXREQFLIT_P0,
    input [REQ_FLIT_WIDTH-1:0] RXREQFLIT_P1,

    output RXREQLCRDV_E,
    output RXREQLCRDV_W,
    output RXREQLCRDV_P0,
    output RXREQLCRDV_P1,

    output TXREQFLITV_E,
    output TXREQFLITV_W,
    output TXREQFLITV_P0,
    output TXREQFLITV_P1,

    output [REQ_FLIT_WIDTH-1:0] TXREQFLIT_E,
    output [REQ_FLIT_WIDTH-1:0] TXREQFLIT_W,
    output [REQ_FLIT_WIDTH-1:0] TXREQFLIT_P0,
    output [REQ_FLIT_WIDTH-1:0] TXREQFLIT_P1,

    input TXREQLCRDV_E,
    input TXREQLCRDV_W,
    input TXREQLCRDV_P0,
    input TXREQLCRDV_P1,

    //RSP
    input RXRSPFLITV_E,
    input RXRSPFLITV_W,
    input RXRSPFLITV_P0,
    input RXRSPFLITV_P1,

    input [RSP_FLIT_WIDTH-1:0] RXRSPFLIT_E,
    input [RSP_FLIT_WIDTH-1:0] RXRSPFLIT_W,
    input [RSP_FLIT_WIDTH-1:0] RXRSPFLIT_P0,
    input [RSP_FLIT_WIDTH-1:0] RXRSPFLIT_P1,

    output RXRSPLCRDV_E,
    output RXRSPLCRDV_W,
    output RXRSPLCRDV_P0,
    output RXRSPLCRDV_P1,

    output TXRSPFLITV_E,
    output TXRSPFLITV_W,
    output TXRSPFLITV_P0,
    output TXRSPFLITV_P1,

    output [RSP_FLIT_WIDTH-1:0] TXRSPFLIT_E,
    output [RSP_FLIT_WIDTH-1:0] TXRSPFLIT_W,
    output [RSP_FLIT_WIDTH-1:0] TXRSPFLIT_P0,
    output [RSP_FLIT_WIDTH-1:0] TXRSPFLIT_P1,

    input TXRSPLCRDV_E,
    input TXRSPLCRDV_W,
    input TXRSPLCRDV_P0,
    input TXRSPLCRDV_P1,

    //DAT
    input RXDATFLITV_E,
    input RXDATFLITV_W,
    input RXDATFLITV_P0,
    input RXDATFLITV_P1,

    input [DAT_FLIT_WIDTH-1:0] RXDATFLIT_E,
    input [DAT_FLIT_WIDTH-1:0] RXDATFLIT_W,
    input [DAT_FLIT_WIDTH-1:0] RXDATFLIT_P0,
    input [DAT_FLIT_WIDTH-1:0] RXDATFLIT_P1,

    output RXDATLCRDV_E,
    output RXDATLCRDV_W,
    output RXDATLCRDV_P0,
    output RXDATLCRDV_P1,

    output TXDATFLITV_E,
    output TXDATFLITV_W,
    output TXDATFLITV_P0,
    output TXDATFLITV_P1,

    output [DAT_FLIT_WIDTH-1:0] TXDATFLIT_E,
    output [DAT_FLIT_WIDTH-1:0] TXDATFLIT_W,
    output [DAT_FLIT_WIDTH-1:0] TXDATFLIT_P0,
    output [DAT_FLIT_WIDTH-1:0] TXDATFLIT_P1,

    input TXDATLCRDV_E,
    input TXDATLCRDV_W,
    input TXDATLCRDV_P0,
    input TXDATLCRDV_P1,
    //SNP
    input RXSNPFLITV_E,
    input RXSNPFLITV_W,
    input RXSNPFLITV_P0,
    input RXSNPFLITV_P1,

    input [SNP_FLIT_WIDTH-1:0] RXSNPFLIT_E,
    input [SNP_FLIT_WIDTH-1:0] RXSNPFLIT_W,
    input [SNP_FLIT_WIDTH-1:0] RXSNPFLIT_P0,
    input [SNP_FLIT_WIDTH-1:0] RXSNPFLIT_P1,

    output RXSNPLCRDV_E,
    output RXSNPLCRDV_W,
    output RXSNPLCRDV_P0,
    output RXSNPLCRDV_P1,

    output TXSNPFLITV_E,
    output TXSNPFLITV_W,
    output TXSNPFLITV_P0,
    output TXSNPFLITV_P1,

    output [SNP_FLIT_WIDTH-1:0] TXSNPFLIT_E,
    output [SNP_FLIT_WIDTH-1:0] TXSNPFLIT_W,
    output [SNP_FLIT_WIDTH-1:0] TXSNPFLIT_P0,
    output [SNP_FLIT_WIDTH-1:0] TXSNPFLIT_P1,

    input TXSNPLCRDV_E,
    input TXSNPLCRDV_W,
    input TXSNPLCRDV_P0,
    input TXSNPLCRDV_P1,

    output TXLINKACTIVEREQ_P0,
    input  TXLINKACTIVEACK_P0,
    input  RXLINKACTIVEREQ_P0,
    output RXLINKACTIVEACK_P0,

    output TXLINKACTIVEREQ_P1,
    input  TXLINKACTIVEACK_P1,
    input  RXLINKACTIVEREQ_P1,
    output RXLINKACTIVEACK_P1,

    output TXSACTIVE_P0,
    input  RXSACTIVE_P0, 
    output TXSACTIVE_P1,
    input  RXSACTIVE_P1 
);

  wire TXLINKACTIVEREQ_SYNC_P0;
  wire TXLINKACTIVEACK_SYNC_P0;
  reg  TXLINKACTIVE_P0_q;
  reg  RXLINKACTIVE_P0_q;

  wire TXLINKACTIVEREQ_SYNC_P1;
  wire TXLINKACTIVEACK_SYNC_P1;
  reg  TXLINKACTIVE_P1_q;
  reg  RXLINKACTIVE_P1_q;
  reg  reset_done;

  chi_ring_channel #(
    .FLIT_WIDTH(REQ_FLIT_WIDTH),
    .ROUTER_NODE_NUM(ROUTER_NODE_NUM)
  ) m_req (
      .clk(clk),
      .rst(rst),
      .my_xid(my_xid),

      .TXLINKACTIVEREQ_P0(TXLINKACTIVEREQ_SYNC_P0),
      .TXLINKACTIVEACK_P0(TXLINKACTIVEACK_SYNC_P0),
      .TXLINKACTIVEREQ_P1(TXLINKACTIVEREQ_SYNC_P1),
      .TXLINKACTIVEACK_P1(TXLINKACTIVEACK_SYNC_P0),

      .RXFLITV_E(RXREQFLITV_E),
      .RXFLITV_W(RXREQFLITV_W),
      .RXFLITV_P0(RXREQFLITV_P0),
      .RXFLITV_P1(RXREQFLITV_P1),

      .RXFLIT_E (RXREQFLIT_E),
      .RXFLIT_W (RXREQFLIT_W),
      .RXFLIT_P0(RXREQFLIT_P0),
      .RXFLIT_P1(RXREQFLIT_P1),

      .RXLCRDV_E (RXREQLCRDV_E),
      .RXLCRDV_W (RXREQLCRDV_W),
      .RXLCRDV_P0(RXREQLCRDV_P0),
      .RXLCRDV_P1(RXREQLCRDV_P1),

      .TXFLITV_E (TXREQFLITV_E),
      .TXFLITV_W (TXREQFLITV_W),
      .TXFLITV_P0(TXREQFLITV_P0),
      .TXFLITV_P1(TXREQFLITV_P1),

      .TXFLIT_E (TXREQFLIT_E),
      .TXFLIT_W (TXREQFLIT_W),
      .TXFLIT_P0(TXREQFLIT_P0),
      .TXFLIT_P1(TXREQFLIT_P1),

      .TXLCRDV_E (TXREQLCRDV_E),
      .TXLCRDV_W (TXREQLCRDV_W),
      .TXLCRDV_P0(TXREQLCRDV_P0),
      .TXLCRDV_P1(TXREQLCRDV_P1)
  );
  chi_ring_channel #(
    .FLIT_WIDTH(RSP_FLIT_WIDTH),
    .ROUTER_NODE_NUM(ROUTER_NODE_NUM)
  ) m_rsp (
      .clk(clk),
      .rst(rst),
      .my_xid(my_xid),

      .TXLINKACTIVEREQ_P0(TXLINKACTIVEREQ_SYNC_P0),
      .TXLINKACTIVEACK_P0(TXLINKACTIVEACK_SYNC_P0),
      .TXLINKACTIVEREQ_P1(TXLINKACTIVEREQ_SYNC_P1),
      .TXLINKACTIVEACK_P1(TXLINKACTIVEACK_SYNC_P0),

      .RXFLITV_E(RXRSPFLITV_E),
      .RXFLITV_W(RXRSPFLITV_W),
      .RXFLITV_P0(RXRSPFLITV_P0),
      .RXFLITV_P1(RXRSPFLITV_P1),

      .RXFLIT_E (RXRSPFLIT_E),
      .RXFLIT_W (RXRSPFLIT_W),
      .RXFLIT_P0(RXRSPFLIT_P0),
      .RXFLIT_P1(RXRSPFLIT_P1),

      .RXLCRDV_E (RXRSPLCRDV_E),
      .RXLCRDV_W (RXRSPLCRDV_W),
      .RXLCRDV_P0(RXRSPLCRDV_P0),
      .RXLCRDV_P1(RXRSPLCRDV_P1),

      .TXFLITV_E (TXRSPFLITV_E),
      .TXFLITV_W (TXRSPFLITV_W),
      .TXFLITV_P0(TXRSPFLITV_P0),
      .TXFLITV_P1(TXRSPFLITV_P1),

      .TXFLIT_E (TXRSPFLIT_E),
      .TXFLIT_W (TXRSPFLIT_W),
      .TXFLIT_P0(TXRSPFLIT_P0),
      .TXFLIT_P1(TXRSPFLIT_P1),

      .TXLCRDV_E (TXRSPLCRDV_E),
      .TXLCRDV_W (TXRSPLCRDV_W),
      .TXLCRDV_P0(TXRSPLCRDV_P0),
      .TXLCRDV_P1(TXRSPLCRDV_P1)
  );
  chi_ring_channel #(
    .FLIT_WIDTH(DAT_FLIT_WIDTH),
    .ROUTER_NODE_NUM(ROUTER_NODE_NUM)
  ) m_dat (
      .clk(clk),
      .rst(rst),
      .my_xid(my_xid),

      .TXLINKACTIVEREQ_P0(TXLINKACTIVEREQ_SYNC_P0),
      .TXLINKACTIVEACK_P0(TXLINKACTIVEACK_SYNC_P0),
      .TXLINKACTIVEREQ_P1(TXLINKACTIVEREQ_SYNC_P1),
      .TXLINKACTIVEACK_P1(TXLINKACTIVEACK_SYNC_P0),

      .RXFLITV_E(RXDATFLITV_E),
      .RXFLITV_W(RXDATFLITV_W),
      .RXFLITV_P0(RXDATFLITV_P0),
      .RXFLITV_P1(RXDATFLITV_P1),

      .RXFLIT_E (RXDATFLIT_E),
      .RXFLIT_W (RXDATFLIT_W),
      .RXFLIT_P0(RXDATFLIT_P0),
      .RXFLIT_P1(RXDATFLIT_P1),

      .RXLCRDV_E (RXDATLCRDV_E),
      .RXLCRDV_W (RXDATLCRDV_W),
      .RXLCRDV_P0(RXDATLCRDV_P0),
      .RXLCRDV_P1(RXDATLCRDV_P1),

      .TXFLITV_E (TXDATFLITV_E),
      .TXFLITV_W (TXDATFLITV_W),
      .TXFLITV_P0(TXDATFLITV_P0),
      .TXFLITV_P1(TXDATFLITV_P1),

      .TXFLIT_E (TXDATFLIT_E),
      .TXFLIT_W (TXDATFLIT_W),
      .TXFLIT_P0(TXDATFLIT_P0),
      .TXFLIT_P1(TXDATFLIT_P1),

      .TXLCRDV_E (TXDATLCRDV_E),
      .TXLCRDV_W (TXDATLCRDV_W),
      .TXLCRDV_P0(TXDATLCRDV_P0),
      .TXLCRDV_P1(TXDATLCRDV_P1)
  );
  chi_ring_channel #(
    .FLIT_WIDTH(SNP_FLIT_WIDTH),
    .FLIT_TGT_OFFSET(SNP_TGTID_OFFSET),
    .ROUTER_NODE_NUM(ROUTER_NODE_NUM)
  ) m_snp (
      .clk(clk),
      .rst(rst),
      .my_xid(my_xid),

      .TXLINKACTIVEREQ_P0(TXLINKACTIVEREQ_SYNC_P0),
      .TXLINKACTIVEACK_P0(TXLINKACTIVEACK_SYNC_P0),
      .TXLINKACTIVEREQ_P1(TXLINKACTIVEREQ_SYNC_P1),
      .TXLINKACTIVEACK_P1(TXLINKACTIVEACK_SYNC_P0),

      .RXFLITV_E(RXSNPFLITV_E),
      .RXFLITV_W(RXSNPFLITV_W),
      .RXFLITV_P0(RXSNPFLITV_P0),
      .RXFLITV_P1(RXSNPFLITV_P1),

      .RXFLIT_E (RXSNPFLIT_E),
      .RXFLIT_W (RXSNPFLIT_W),
      .RXFLIT_P0(RXSNPFLIT_P0),
      .RXFLIT_P1(RXSNPFLIT_P1),

      .RXLCRDV_E (RXSNPLCRDV_E),
      .RXLCRDV_W (RXSNPLCRDV_W),
      .RXLCRDV_P0(RXSNPLCRDV_P0),
      .RXLCRDV_P1(RXSNPLCRDV_P1),

      .TXFLITV_E (TXSNPFLITV_E),
      .TXFLITV_W (TXSNPFLITV_W),
      .TXFLITV_P0(TXSNPFLITV_P0),
      .TXFLITV_P1(TXSNPFLITV_P1),

      .TXFLIT_E (TXSNPFLIT_E),
      .TXFLIT_W (TXSNPFLIT_W),
      .TXFLIT_P0(TXSNPFLIT_P0),
      .TXFLIT_P1(TXSNPFLIT_P1),

      .TXLCRDV_E (TXSNPLCRDV_E),
      .TXLCRDV_W (TXSNPLCRDV_W),
      .TXLCRDV_P0(TXSNPLCRDV_P0),
      .TXLCRDV_P1(TXSNPLCRDV_P1)
  );

  always @(posedge clk or posedge rst) begin
      if (rst) begin
          TXLINKACTIVE_P0_q <= 1'b0;
      end else if (TXLINKACTIVEACK_P0 & TXLINKACTIVEREQ_P0) begin
          TXLINKACTIVE_P0_q <= 1'b1;
      end
  end
  always @(posedge clk or posedge rst) begin
      if (rst) begin
          RXLINKACTIVE_P0_q <= 1'b0;
      end else if (RXLINKACTIVEREQ_P0) begin
          RXLINKACTIVE_P0_q <= 1'b1;
      end
  end

  always @(posedge clk or posedge rst) begin
      if (rst) begin
          TXLINKACTIVE_P1_q <= 1'b0;
      end else if (TXLINKACTIVEACK_P1 & TXLINKACTIVEREQ_P1) begin
          TXLINKACTIVE_P1_q <= 1'b1;
      end
  end
  always @(posedge clk or posedge rst) begin
      if (rst) begin
          RXLINKACTIVE_P1_q <= 1'b0;
      end else if (RXLINKACTIVEREQ_P1) begin
          RXLINKACTIVE_P1_q <= 1'b1;
      end
  end

  always @(posedge clk or posedge rst) begin
      if (rst) begin
          reset_done <= 1'b0;
      end else begin
          reset_done <= 1'b1;
      end
  end

  assign TXLINKACTIVEREQ_P0 = reset_done;
  assign TXLINKACTIVEREQ_P1 = reset_done;
  assign RXLINKACTIVEACK_P0 = RXLINKACTIVE_P0_q;
  assign RXLINKACTIVEACK_P1 = RXLINKACTIVE_P1_q;
  assign TXSACTIVE_P0 = TXLINKACTIVE_P0_q;
  assign TXSACTIVE_P1 = TXLINKACTIVE_P1_q;

  assign TXLINKACTIVEREQ_SYNC_P0 = TXLINKACTIVEREQ_P0;
  assign TXLINKACTIVEACK_SYNC_P0 = TXLINKACTIVE_P0_q;
  assign TXLINKACTIVEREQ_SYNC_P1 = TXLINKACTIVEREQ_P1;
  assign TXLINKACTIVEACK_SYNC_P1 = TXLINKACTIVE_P1_q;
endmodule
`endif /* CHI_RING_NODE_H */
