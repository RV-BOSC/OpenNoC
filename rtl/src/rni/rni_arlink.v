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

`include "axi4_defines.v"
`include "chie_defines.v"
`include "rni_defines.v"
`include "rni_param.v"


module rni_arlink
    `RNI_PARAM
        (
            clk_i
            ,rst_i

            ,ARVALID
            ,AR_CH_S0
            ,alloc_busy_s1_i

            ,ARREADY
            ,arlink_arbus_s1_o

            ,arlink_valid_s1_o
            ,arlink_addr_s1_o
            ,arlink_bc_vec_s2_o
            ,arlink_dmask_s2_o
            ,arlink_size_s2_o
            ,arlink_lock_s2_o
        );

    input  wire                                 clk_i;
    input  wire                                 rst_i;

    input  wire                                 ARVALID;
    input  wire [`AXI4_AR_WIDTH-1:0]            AR_CH_S0;
    input  wire                                 alloc_busy_s1_i;

    output wire                                 ARREADY;
    output wire [`AXI4_AR_WIDTH-1:0]            arlink_arbus_s1_o;

    output wire                                 arlink_valid_s1_o;
    output wire [`AXI4_ARADDR_WIDTH-1:0]        arlink_addr_s1_o;
    output wire [`RNI_BCVEC_WIDTH-1:0]          arlink_bc_vec_s2_o;
    output wire [`RNI_DMASK_WIDTH-1:0]          arlink_dmask_s2_o;
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] arlink_size_s2_o;
    output wire                                 arlink_lock_s2_o;


    wire                           segburst_done_s1_w;
    wire                           arlink_fifo_push_s1_w;
    wire                           arlink_fifo_pop_s1_w;
    wire                           arlink_fifo_empty_s1_w;
    wire                           arlink_fifo_full_s1_w;
    wire [`AXI4_ARADDR_WIDTH-1:0]  ar_addr_in_s1_w;
    wire [`AXI4_ARBURST_WIDTH-1:0] ar_burst_in_s1_w;
    wire [`AXI4_ARLEN_WIDTH-1:0]   ar_len_in_s1_w;
    wire [`AXI4_ARLOCK_WIDTH-1:0]  ar_lock_in_s1_w;
    wire [`AXI4_ARSIZE_WIDTH-1:0]  ar_size_in_s1_w;
    wire [`AXI4_AR_WIDTH-1:0]      arbus_out_s1_w;
    wire                           segburst_busy_s1_w;

    wire                           arvalid_s1;


    assign arlink_fifo_push_s1_w = ARVALID & ARREADY;
    assign arlink_fifo_pop_s1_w  = ~arlink_fifo_empty_s1_w & segburst_done_s1_w;

    sync_fifo #(
                  .FIFO_ENTRIES_WIDTH (`AXI4_AR_WIDTH)
                  ,.FIFO_ENTRIES_DEPTH (2)
                  ,.FIFO_BYP_ENABLE    (1'b0)
              ) u_arlink_fifo (
                  .clk      (clk_i)
                  ,.rst      (rst_i)
                  ,.push     (arlink_fifo_push_s1_w)
                  ,.pop      (arlink_fifo_pop_s1_w)
                  ,.data_in  (AR_CH_S0)
                  ,.data_out (arbus_out_s1_w)
                  ,.empty    (arlink_fifo_empty_s1_w)
                  ,.full     (arlink_fifo_full_s1_w)
                  ,.count    ()
              );

    assign ARREADY = ~arlink_fifo_full_s1_w;

    assign arlink_arbus_s1_o   = arbus_out_s1_w;
    assign arvalid_s1 = ~arlink_fifo_empty_s1_w;

    assign ar_addr_in_s1_w[`AXI4_ARADDR_WIDTH-1:0]   = {`AXI4_ARADDR_WIDTH{arvalid_s1}} & arlink_arbus_s1_o[`AXI4_ARADDR_RANGE];
    assign ar_len_in_s1_w[`AXI4_ARLEN_WIDTH-1:0]     = {`AXI4_ARLEN_WIDTH{arvalid_s1}} & arlink_arbus_s1_o[`AXI4_ARLEN_RANGE];
    assign ar_size_in_s1_w[`AXI4_ARSIZE_WIDTH-1:0]   = {`AXI4_ARSIZE_WIDTH{arvalid_s1}} & arlink_arbus_s1_o[`AXI4_ARSIZE_RANGE];
    assign ar_burst_in_s1_w[`AXI4_ARBURST_WIDTH-1:0] = {`AXI4_ARBURST_WIDTH{arvalid_s1}} & arlink_arbus_s1_o[`AXI4_ARBURST_RANGE];
    assign ar_lock_in_s1_w[`AXI4_ARLOCK_WIDTH-1:0]   = {`AXI4_ARLOCK_WIDTH{arvalid_s1}} & arlink_arbus_s1_o[`AXI4_ARLOCK_RANGE];

    assign segburst_busy_s1_w = alloc_busy_s1_i;

    rni_segburst
        `RNI_PARAM_INST
        u_segburst (
            .clk_i                (clk_i)
            ,.rst_i                (rst_i)
            ,.axi_valid_s1_i       (arvalid_s1)
            ,.axi_addr_in_s1_i     (ar_addr_in_s1_w)
            ,.axi_len_in_s1_i      (ar_len_in_s1_w)
            ,.axi_size_in_s1_i     (ar_size_in_s1_w)
            ,.axi_burst_s1_i       (ar_burst_in_s1_w)
            ,.axi_lock_in_s1_i     (ar_lock_in_s1_w)
            ,.stall_flag_s1_i      (segburst_busy_s1_w)

            // Outputs
            ,.segburst_valid_s1_o  (arlink_valid_s1_o)
            ,.segburst_addr_s1_o   (arlink_addr_s1_o)
            ,.segburst_done_s1_o   (segburst_done_s1_w)
            ,.segburst_bc_vec_s2_o (arlink_bc_vec_s2_o)
            ,.segburst_dmask_s2_o  (arlink_dmask_s2_o)
            ,.segburst_size_s2_o   (arlink_size_s2_o)
            ,.segburst_lock_s2_o   (arlink_lock_s2_o)
        );

endmodule
