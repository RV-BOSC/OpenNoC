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

module rni_awlink `RNI_PARAM
    (
        ///////////////////////////////////////////////////////////////
        // Inputs
        ///////////////////////////////////////////////////////////////

        // Global inputs
        clk_i,
        rst_i,

        // AMBA4
        AWVALID,
        AWBUS,
        stall_flag_s1_i,

        ///////////////////////////////////////////////////////////////
        // Outputs
        ///////////////////////////////////////////////////////////////
        AWREADY,
        awlink_awvalid_s1_o,
        awlink_awbus_s1_o,

        awlink_len_s1_o,
        awlink_valid_s1_o,
        awlink_addr_s1_o,
        awlink_done_s1_o,
        awlink_bc_vec_s2_o,
        awlink_dmask_s2_o,
        awlink_size_s2_o,
        awlink_lock_s2_o
    );


    ///////////////////////////////////////////////////////////////
    // Inputs
    ///////////////////////////////////////////////////////////////

    // Global inputs
    input wire                                  clk_i;
    input wire                                  rst_i;

    // AMBA4 xface
    input wire                                  AWVALID;
    input wire  [`AXI4_AW_WIDTH-1:0]            AWBUS;
    input wire                                  stall_flag_s1_i;


    ///////////////////////////////////////////////////////////////
    // Outputs
    ///////////////////////////////////////////////////////////////
    output wire                                     AWREADY;

    output wire                                     awlink_awvalid_s1_o;
    output wire [`AXI4_AW_WIDTH-1:0]                awlink_awbus_s1_o;

    output wire  [`AXI4_AWLEN_WIDTH-1:0]            awlink_len_s1_o;
    output wire                                     awlink_valid_s1_o;
    output wire [`AXI4_AWADDR_WIDTH-1:0]            awlink_addr_s1_o;
    output wire                                     awlink_done_s1_o;
    output wire [`RNI_BCVEC_WIDTH-1:0]              awlink_bc_vec_s2_o;
    output wire [`RNI_DMASK_WIDTH-1:0]              awlink_dmask_s2_o;
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]     awlink_size_s2_o;
    output wire                                     awlink_lock_s2_o;

    wire [`AW_FIFO_CNT_WIDTH-1:0]       aw_fifo_count;
    wire                                awready_w;
    wire [`AXI4_AW_WIDTH-1:0]           awbus_out_r1;
    wire                                axi_valid_s1_i;
    wire  [`AXI4_AWADDR_WIDTH-1:0]      axi_addr_in_s1_i;
    wire  [`AXI4_AWSIZE_WIDTH-1:0]      axi_size_in_s1_i;
    wire  [`AXI4_AWBURST_WIDTH-1:0]     axi_burst_s1_i;
    wire                                axi_lock_in_s1_i;
    wire                                axi_excl_s1_i;
    wire [`AXI4_AWLEN_WIDTH-1:0]        axi_len_in_s1_i;
    wire                                aw_fifo_empty;

    reg                                 awready_q;

    assign awlink_awvalid_s1_o = axi_valid_s1_i;
    assign awlink_awbus_s1_o[`AXI4_AW_WIDTH-1:0] = awbus_out_r1[`AXI4_AW_WIDTH-1:0];
    assign awready_w = ~(((aw_fifo_count[`AW_FIFO_CNT_WIDTH-1:0] == `AW_FIFO_CNT_NUM)&& ~awlink_done_s1_o) || ((aw_fifo_count[`AW_FIFO_CNT_WIDTH-1:0] == (`AW_FIFO_CNT_NUM - 1'b1)) && AWVALID && AWREADY && ~awlink_done_s1_o));

    assign AWREADY = awready_q;
    assign axi_addr_in_s1_i[`AXI4_AWADDR_WIDTH-1:0] = awbus_out_r1[`AXI4_AWADDR_RANGE];
    assign axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0] = awbus_out_r1[`AXI4_AWSIZE_RANGE];
    assign axi_burst_s1_i[`AXI4_AWBURST_WIDTH-1:0] = awbus_out_r1[`AXI4_AWBURST_RANGE];
    assign axi_len_in_s1_i[`AXI4_AWLEN_WIDTH-1:0] = awbus_out_r1[`AXI4_AWLEN_RANGE];
    assign axi_lock_in_s1_i = awbus_out_r1[`AXI4_AWLOCK_RANGE];
    assign axi_excl_s1_i = axi_lock_in_s1_i & !axi_burst_s1_i[`AXI4_AWBURST_WIDTH-1:0];
    assign axi_valid_s1_i = !aw_fifo_empty;
    assign awlink_len_s1_o[`AXI4_AWLEN_WIDTH-1:0] = axi_len_in_s1_i[`AXI4_AWLEN_WIDTH-1:0];

    sync_fifo #(
                  .FIFO_ENTRIES_WIDTH(`AXI4_AW_WIDTH),
                  .FIFO_ENTRIES_DEPTH(2),
                  .FIFO_BYP_ENABLE   (1'b0)
              )
              sync_fifo_aw(
                  .clk        (clk_i),
                  .rst        (rst_i),
                  .push       (AWVALID & AWREADY),
                  .pop        (awlink_done_s1_o),
                  .data_in    (AWBUS[`AXI4_AW_WIDTH-1:0]),

                  .data_out   (awbus_out_r1[`AXI4_AW_WIDTH-1:0]),
                  .empty      (aw_fifo_empty),
                  .full       (),
                  .count      (aw_fifo_count[`AW_FIFO_CNT_WIDTH-1:0])
              );


    rni_segburst rni_segburst_aw(
                     .clk_i                    (clk_i)
                     ,.rst_i                    (rst_i)
                     ,.axi_valid_s1_i           (axi_valid_s1_i)
                     ,.axi_addr_in_s1_i         (axi_addr_in_s1_i)
                     ,.axi_len_in_s1_i          (axi_len_in_s1_i)
                     ,.axi_size_in_s1_i         (axi_size_in_s1_i)
                     ,.axi_burst_s1_i           (axi_burst_s1_i)
                     ,.axi_lock_in_s1_i         (axi_lock_in_s1_i)
                     ,.stall_flag_s1_i          (stall_flag_s1_i)

                     ,.segburst_valid_s1_o      (awlink_valid_s1_o)
                     ,.segburst_addr_s1_o       (awlink_addr_s1_o)
                     ,.segburst_done_s1_o       (awlink_done_s1_o)
                     ,.segburst_bc_vec_s2_o     (awlink_bc_vec_s2_o)
                     ,.segburst_dmask_s2_o      (awlink_dmask_s2_o)
                     ,.segburst_size_s2_o       (awlink_size_s2_o)
                     ,.segburst_lock_s2_o       (awlink_lock_s2_o)
                 );

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)begin
            awready_q <= 1'b0;
        end
        else begin
            awready_q <= awready_w;
        end
    end

endmodule
