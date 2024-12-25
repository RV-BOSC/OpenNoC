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

`define SEGB_STATE_WIDTH       5
`define SEGB_CACHE_OFFSET      6
`define SEGB_DW_WIDTH          4


`define SEGB_PASS                                  `SEGB_STATE_WIDTH'b00000
`define SEGB_INCR                                  `SEGB_STATE_WIDTH'b00001
`define SEGB_MULTILINE_WRAP                        `SEGB_STATE_WIDTH'b00010
`define SEGB_SINGLELINE_WRAP                       `SEGB_STATE_WIDTH'b00100
`define SEGB_SINGLELINE_WRAP_FIRST_PART            `SEGB_STATE_WIDTH'b01000
`define SEGB_SINGLELINE_WRAP_SECOND_PART           `SEGB_STATE_WIDTH'b10000

module rni_segburst `RNI_PARAM
    (

        // Global inputs
        clk_i
        ,rst_i
        /////////////////////////////////////////////////////////////
        // Inputs
        /////////////////////////////////////////////////////////////
        ,axi_valid_s1_i
        ,axi_addr_in_s1_i
        ,axi_len_in_s1_i
        ,axi_size_in_s1_i
        ,axi_burst_s1_i
        ,axi_lock_in_s1_i
        ,stall_flag_s1_i

        /////////////////////////////////////////////////////////////
        // Outputs
        /////////////////////////////////////////////////////////////
        ,segburst_valid_s1_o
        ,segburst_addr_s1_o
        ,segburst_done_s1_o
        ,segburst_bc_vec_s2_o
        ,segburst_dmask_s2_o
        ,segburst_size_s2_o
        ,segburst_lock_s2_o
    );

    // Global inputs
    input wire           clk_i;
    input wire           rst_i ;

    // Strap inputs

    /////////////////////////////////////////////////////////////
    // Inputs
    /////////////////////////////////////////////////////////////
    input wire                              axi_valid_s1_i;
    input wire  [`AXI4_AWADDR_WIDTH-1:0]    axi_addr_in_s1_i;
    input wire  [`AXI4_AWLEN_WIDTH-1:0]     axi_len_in_s1_i;
    input wire  [`AXI4_AWSIZE_WIDTH-1:0]    axi_size_in_s1_i;
    input wire  [`AXI4_AWBURST_WIDTH-1:0]   axi_burst_s1_i;
    input wire                              axi_lock_in_s1_i;
    input wire                              stall_flag_s1_i;

    /////////////////////////////////////////////////////////////
    // Outputs
    /////////////////////////////////////////////////////////////
    output reg                                      segburst_valid_s1_o;
    output reg [`AXI4_AWADDR_WIDTH-1:0]             segburst_addr_s1_o;
    output reg                                      segburst_done_s1_o;
    output reg [`RNI_BCVEC_WIDTH-1:0]               segburst_bc_vec_s2_o;
    output wire [`RNI_DMASK_WIDTH-1:0]              segburst_dmask_s2_o;
    output wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]     segburst_size_s2_o;
    output wire                                     segburst_lock_s2_o;


    //#
    //# Internal Signals
    //# =========================================
    //#
    wire                                        axi_burst_fix_w;
    wire                                        axi_burst_incr_w;
    wire                                        axi_burst_wrap_w;
    wire [`AXI4_AWADDR_WIDTH-1:0]               axi_addr_align_w;
    wire [`AXI4_AWLEN_WIDTH:0]                  axi_len_plusone_s1_w;
    wire [`AXI_4KB_WIDTH-1:0]                   axi_bytes_subone_w;
    wire [`AXI_4KB_WIDTH-1:0]                   addr_plus_bytes_w;
    wire [`AXI_4KB_WIDTH-1:0]                   axi_len_mul_size_w;
    wire [5:0]                                  cacheline_cnt_incr_w;
    wire [5:0]                                  cacheline_cnt_wrap_w;
    wire [`AXI4_AWADDR_WIDTH-1:0]               addr_div_size_w;
    wire [`AXI4_AWADDR_WIDTH-1:0]               addr_boundary_and_len_wrap_w;
    wire [`AXI4_AWADDR_WIDTH-1:0]               addr_boundary_wrap_s1_w;
    wire [`AXI4_AWADDR_WIDTH-1:0]               addr_multiline_wrap_final_s1_w;
    wire [5:0]                                  txn_cnt_multi_wrap_w;
    wire [5:0]                                  txn_cnt_single_wrap_w;
    wire                                        incr_multiline_w;
    wire                                        wrap_multiline_w;
    wire                                        wrap_singleline_w;
    wire [3:0]                                  chi_len_sl_wrap_second_w;
    wire [3:0]                                  chi_len_sl_wrap_first_w;
    wire [`AXI_4KB_WIDTH-1:0]                   chi_addr_sl_wrap_first_tail_w;
    wire [`AXI_4KB_WIDTH-1:0]                   chi_addr_sl_wrap_second_tail_w;
    wire                                        overflow_bit_one_w;
    wire                                        overflow_bit_two_w;
    wire                                        overflow_bit_three_w;
    wire                                        overflow_bit_four_w;
    wire                                        overflow_bit_five_w;
    wire [`AXI_4KB_WIDTH-1:0]                   axi_last_trans_addr_w;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_fastpass_w;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_nonfp_w;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_sl_wrap_s1_w;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_sl_wrap_first_s1_w;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_sl_wrap_second_s1_w;
    wire [3:0]                                  chi_bc_first_w;
    wire [3:0]                                  chi_bc_middle_w;
    wire [3:0]                                  chi_bc_last_w;
    wire                                        state_enable_w;

    reg                                         axi_new_trans_r;
    reg  [`SEGB_STATE_WIDTH-1:0]                state_q;
    reg  [`SEGB_STATE_WIDTH-1:0]                state_nxt_r;
    reg  [7:0]                                  txn_cnt_s1_r;
    reg  [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_s1_r;
    reg  [7:0]                                  txn_cnt_q;
    reg  [`AXI4_AWADDR_WIDTH-1:0]               axi_addr_in_q;
    reg  [`AXI4_AWADDR_WIDTH-1:0]               axi_addr_q;
    reg  [`AXI4_AWADDR_WIDTH-1:0]               addr_boundary_wrap_q;
    reg  [`AXI4_AWADDR_WIDTH-1:0]               addr_multiline_wrap_final_q;
    reg  [`AXI_4KB_WIDTH-1:0]                   axi_last_trans_addr_q;
    reg  [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_sl_wrap_q;
    reg  [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_sl_wrap_first_q;
    reg  [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_sl_wrap_second_q;
    reg  [`RNI_DMASK_WIDTH-1:0]                 segburst_dmask_q;
    reg  [3:0]                                  chi_ct_vec_s1_r;
    reg  [3:0]                                  chi_pd_vec_s1_r;
    reg  [3:0]                                  chi_ls_vec_s1_r;
    reg  [`RNI_BCVEC_WIDTH-1:0]                 chi_bc_vec_s1_r;
    reg  [`RNI_DMASK_WIDTH-1:0]                 segburst_dmask_s1_r;
    reg  [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        chi_size_q;
    reg                                         axi_lock_q;

    assign axi_burst_fix_w       = ~|axi_burst_s1_i[`AXI4_AWBURST_WIDTH-1:0];
    assign axi_burst_incr_w      = axi_burst_s1_i[0];
    assign axi_burst_wrap_w      = axi_burst_s1_i[1];

    assign axi_addr_align_w[`AXI4_AWADDR_WIDTH-1:0]                       = (axi_addr_in_s1_i[`AXI4_AWADDR_WIDTH-1:0] >> axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0]) << axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0];
    assign axi_len_plusone_s1_w[`AXI4_AWLEN_WIDTH:0]                      = axi_len_in_s1_i[`AXI4_AWLEN_WIDTH-1:0] + 1'b1;
    assign {overflow_bit_one_w,axi_bytes_subone_w[`AXI_4KB_WIDTH-1:0]}      = ({4'b0,axi_len_plusone_s1_w[`AXI4_AWLEN_WIDTH:0]} << axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0]) - 1'b1;
    assign {overflow_bit_two_w,addr_plus_bytes_w[`AXI_4KB_WIDTH-1:0]}       = axi_bytes_subone_w[`AXI_4KB_WIDTH-1:0] + axi_addr_align_w[`AXI_4KB_WIDTH-1:0];
    assign axi_len_mul_size_w[`AXI_4KB_WIDTH-1:0]                         = {4'b0,axi_len_in_s1_i[`AXI4_AWLEN_WIDTH-1:0]} << axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0];

    assign cacheline_cnt_incr_w[5:0]          = addr_plus_bytes_w[`AXI_4KB_WIDTH-1:`SEGB_CACHE_OFFSET] - axi_addr_align_w[`AXI_4KB_WIDTH-1:`SEGB_CACHE_OFFSET];//incr cacehline num -1
    assign cacheline_cnt_wrap_w[5:0]          = axi_bytes_subone_w[`AXI_4KB_WIDTH-1:`SEGB_CACHE_OFFSET];//wrap cacehline num -1

    assign addr_div_size_w[`AXI4_AWADDR_WIDTH-1:0]                 = (axi_addr_align_w[`AXI4_AWADDR_WIDTH-1:0] >> axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0]);
    assign addr_boundary_and_len_wrap_w[`AXI4_AWADDR_WIDTH-1:0]    = {addr_div_size_w[`AXI4_AWADDR_WIDTH-1:4], (addr_div_size_w[3:0] & (~axi_len_in_s1_i[3:0]))};
    //Find the starting boundary of wrap
    assign addr_boundary_wrap_s1_w[`AXI4_AWADDR_WIDTH-1:0]         = addr_boundary_and_len_wrap_w[`AXI4_AWADDR_WIDTH-1:0]  << axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0];
    //Find the end boundary of multiline wrap(only 8 or 16 lengths for 16B DATA WIDTH)
    assign addr_multiline_wrap_final_s1_w[`AXI4_AWADDR_WIDTH-1:0]  = (((axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0] == 'd4) && (axi_len_in_s1_i[`AXI4_AWLEN_WIDTH-1:0] == 'd7)) ||
            ((axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0] == 'd3) && (axi_len_in_s1_i[`AXI4_AWLEN_WIDTH-1:0] == 'd15))) ?
           {addr_boundary_wrap_s1_w[`AXI4_AWADDR_WIDTH-1:(`SEGB_CACHE_OFFSET+1)],1'b1,{`SEGB_CACHE_OFFSET{1'b0}}} :
           (((axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0] == 'd4) && (axi_len_in_s1_i[`AXI4_AWLEN_WIDTH-1:0] == 'd15)) ?
            {addr_boundary_wrap_s1_w[`AXI4_AWADDR_WIDTH-1:(`SEGB_CACHE_OFFSET+2)],2'b11,{`SEGB_CACHE_OFFSET{1'b0}}} : 0);

    assign txn_cnt_multi_wrap_w[5:0]    = (axi_addr_align_w[`SEGB_CACHE_OFFSET-1:0] == {`SEGB_CACHE_OFFSET{1'b0}}) ? cacheline_cnt_wrap_w[5:0] : cacheline_cnt_wrap_w[5:0] + 1'b1;

    assign txn_cnt_single_wrap_w[5:0]    = (addr_boundary_wrap_s1_w[`AXI4_AWADDR_WIDTH-1:0] == axi_addr_align_w[`AXI4_AWADDR_WIDTH-1:0]) ? cacheline_cnt_wrap_w[5:0] : cacheline_cnt_wrap_w[5:0] + 1'b1;

    assign incr_multiline_w       = axi_burst_incr_w & (|cacheline_cnt_incr_w[5:0]);
    assign wrap_multiline_w       = axi_burst_wrap_w & (|cacheline_cnt_wrap_w[5:0]);
    assign wrap_singleline_w      = axi_burst_wrap_w & (~|cacheline_cnt_wrap_w[5:0]);
    //The number of len in the second part(actual number)
    assign chi_len_sl_wrap_second_w[3:0]                      = addr_div_size_w[3:0] & axi_len_in_s1_i[3:0];
    //The number of len in the first part(actual number -1)
    assign chi_len_sl_wrap_first_w[3:0]                       = axi_len_in_s1_i[3:0] - chi_len_sl_wrap_second_w[3:0];
    //The starting address of the last trans in the first part
    assign {overflow_bit_three_w,chi_addr_sl_wrap_first_tail_w[`AXI_4KB_WIDTH-1:0]}  = axi_addr_align_w[`AXI_4KB_WIDTH-1:0] + ({8'b0,chi_len_sl_wrap_first_w[3:0]} << axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0]);
    //The starting address of the last trans in the second part
    assign {overflow_bit_four_w,chi_addr_sl_wrap_second_tail_w[`AXI_4KB_WIDTH-1:0]}  = addr_boundary_wrap_s1_w[`AXI_4KB_WIDTH-1:0] + ({8'b0,(chi_len_sl_wrap_second_w[3:0] - 4'b0001)} << axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0]);

    assign {overflow_bit_five_w,axi_last_trans_addr_w[`AXI_4KB_WIDTH-1:0]} = axi_addr_align_w[`AXI_4KB_WIDTH-1:0] + ({1'b0,axi_len_mul_size_w[`AXI_4KB_WIDTH-1:0]});
    //The size of fastpass/segb_singleline_wrap is only 16B and 64B
    assign chi_size_fastpass_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]            = (axi_last_trans_addr_w[5:4] == axi_addr_align_w[5:4]) ? 3'b100 : ((axi_last_trans_addr_w[5] == axi_addr_align_w[5]) ? 3'b101 : 3'b110);
    assign chi_size_nonfp_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]               = axi_addr_align_w[5:4] == 2'b11 ? 3'b100 : (axi_addr_align_w[5:4] == 2'b10) ? 3'b101 : 3'b110;
    assign chi_size_sl_wrap_s1_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]          = (axi_len_mul_size_w[5:4] == 2'b00) ? 3'b100 : (axi_len_mul_size_w[5:4] == 2'b01) ? 3'b101 : 3'b110;
    assign chi_size_sl_wrap_first_s1_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]    = (chi_addr_sl_wrap_first_tail_w[5:4] == axi_addr_align_w[5:4]) ? 3'b100 : ((chi_addr_sl_wrap_first_tail_w[5] == axi_addr_align_w[5]) ? 3'b101 :3'b110);
    assign chi_size_sl_wrap_second_s1_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]   = (chi_addr_sl_wrap_second_tail_w[5:4] == addr_boundary_wrap_s1_w[5:4]) ? 3'b100 : ((chi_addr_sl_wrap_second_tail_w[5] == addr_boundary_wrap_s1_w[5]) ? 3'b101 : 3'b110);

    assign chi_bc_first_w[3:0]            = (~axi_addr_align_w[3:0]) >> axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0];
    assign chi_bc_middle_w[3:0]           = 4'b1111 >> axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0];
    assign chi_bc_last_w[3:0]             = (addr_plus_bytes_w[3:0]) >> axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0];

    assign segburst_dmask_s2_o[`RNI_DMASK_WIDTH-1:0]          = segburst_dmask_q[`RNI_DMASK_WIDTH-1:0];
    assign segburst_size_s2_o[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]       = chi_size_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0];
    assign segburst_lock_s2_o                                      = axi_lock_q;
    assign state_enable_w                                   = ~stall_flag_s1_i & axi_valid_s1_i;

    always@* begin
        axi_new_trans_r = 1'b0;
        casez (state_q[`SEGB_STATE_WIDTH-1:0])
            `SEGB_PASS:begin
                axi_new_trans_r = axi_valid_s1_i & ~stall_flag_s1_i;
                segburst_valid_s1_o = axi_valid_s1_i & ~stall_flag_s1_i & ~wrap_singleline_w;
                segburst_addr_s1_o[`AXI4_AWADDR_WIDTH-1:0] = axi_addr_in_s1_i[`AXI4_AWADDR_WIDTH-1:0];
                segburst_done_s1_o = segburst_valid_s1_o & (state_nxt_r[`SEGB_STATE_WIDTH-1:0] == `SEGB_PASS) & ~stall_flag_s1_i;
                txn_cnt_s1_r[7:0] = axi_burst_fix_w ? axi_len_in_s1_i[`AXI4_AWLEN_WIDTH-1:0] :
                    axi_burst_incr_w ? {2'b00,cacheline_cnt_incr_w[5:0]} :
                        wrap_multiline_w ? {2'b00,txn_cnt_multi_wrap_w[5:0]} :
                            {2'b00,txn_cnt_single_wrap_w[5:0]} + 1'b1;
                chi_size_s1_r[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] = axi_burst_fix_w ? axi_size_in_s1_i[`AXI4_AWSIZE_WIDTH-1:0] :
                    (state_nxt_r[`SEGB_STATE_WIDTH-1:0] == `SEGB_PASS) ? chi_size_fastpass_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] :
                        chi_size_nonfp_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0];
            end
            `SEGB_INCR:begin
                segburst_valid_s1_o = ~stall_flag_s1_i;
                segburst_addr_s1_o[`AXI4_AWADDR_WIDTH-1:0] = (axi_addr_q[`AXI4_AWADDR_WIDTH-1:`SEGB_CACHE_OFFSET] + 1'b1) << `SEGB_CACHE_OFFSET;
                segburst_done_s1_o = segburst_valid_s1_o & (state_nxt_r[`SEGB_STATE_WIDTH-1:0] == `SEGB_PASS) & ~stall_flag_s1_i;
                txn_cnt_s1_r[7:0] = txn_cnt_q[7:0] - 1'b1;
                chi_size_s1_r[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] = ((txn_cnt_q[7:0]-1'b1) != 0) ? 3'b110 : (axi_last_trans_addr_q[5:4] == 2'b00) ? 3'b100 : (axi_last_trans_addr_q[5:4] == 2'b01) ? 3'b101 : 3'b110;
            end
            `SEGB_MULTILINE_WRAP:begin
                segburst_valid_s1_o = ~stall_flag_s1_i;
                segburst_addr_s1_o[`AXI4_AWADDR_WIDTH-1:0] = (axi_addr_q[`AXI4_AWADDR_WIDTH-1:`SEGB_CACHE_OFFSET] == addr_multiline_wrap_final_q[`AXI4_AWADDR_WIDTH-1:`SEGB_CACHE_OFFSET]) ?
                addr_boundary_wrap_q[`AXI4_AWADDR_WIDTH-1:0] : ((axi_addr_q[`AXI4_AWADDR_WIDTH-1:`SEGB_CACHE_OFFSET] + 1'b1) << `SEGB_CACHE_OFFSET);

                segburst_done_s1_o = segburst_valid_s1_o & (state_nxt_r[`SEGB_STATE_WIDTH-1:0] == `SEGB_PASS) & ~stall_flag_s1_i;
                txn_cnt_s1_r[7:0] = txn_cnt_q[7:0] - 1'b1;
                chi_size_s1_r[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] = ((txn_cnt_q[7:0]-1'b1) != 0) ? 3'b110 : (axi_last_trans_addr_q[5:4] == 2'b00) ? 3'b100 : (axi_last_trans_addr_q[5:4] == 2'b01) ? 3'b101 : 3'b110;
            end
            `SEGB_SINGLELINE_WRAP:begin
                segburst_valid_s1_o = ~stall_flag_s1_i & ((txn_cnt_q[7:0]-1'b1) == 0);
                segburst_addr_s1_o[`AXI4_AWADDR_WIDTH-1:0] = axi_addr_q[`AXI4_AWADDR_WIDTH-1:0];
                segburst_done_s1_o = segburst_valid_s1_o & (state_nxt_r[`SEGB_STATE_WIDTH-1:0] == `SEGB_PASS) & ~stall_flag_s1_i;
                txn_cnt_s1_r[7:0] = ((txn_cnt_q[7:0]-1'b1) == 0) ? txn_cnt_q[7:0] - 1'b1 : txn_cnt_q[7:0];
                chi_size_s1_r[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] = chi_size_sl_wrap_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0];
            end
            `SEGB_SINGLELINE_WRAP_FIRST_PART:begin
                segburst_valid_s1_o = ~stall_flag_s1_i;
                segburst_addr_s1_o[`AXI4_AWADDR_WIDTH-1:0] = axi_addr_q[`AXI4_AWADDR_WIDTH-1:0];
                segburst_done_s1_o = 1'b0;
                txn_cnt_s1_r[7:0] = txn_cnt_q[7:0] - 1'b1;
                chi_size_s1_r[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] = chi_size_sl_wrap_first_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0];
            end
            `SEGB_SINGLELINE_WRAP_SECOND_PART:begin
                segburst_valid_s1_o = ~stall_flag_s1_i;
                segburst_addr_s1_o[`AXI4_AWADDR_WIDTH-1:0] = addr_boundary_wrap_q[`AXI4_AWADDR_WIDTH-1:0];
                segburst_done_s1_o = segburst_valid_s1_o & ~stall_flag_s1_i;
                txn_cnt_s1_r[7:0] = txn_cnt_q[7:0] - 1'b1;
                chi_size_s1_r[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] = chi_size_sl_wrap_second_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0];
            end
            default: begin
                segburst_valid_s1_o = 1'bX;
                segburst_addr_s1_o[`AXI4_AWADDR_WIDTH-1:0] = {`AXI4_AWADDR_WIDTH{1'bX}};
                segburst_done_s1_o = 1'bX;
                txn_cnt_s1_r[7:0] = 8'bX;
                chi_size_s1_r[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] = {`CHIE_REQ_FLIT_SIZE_WIDTH{1'bX}};
            end
        endcase
    end

    always@* begin
        casez (state_q[`SEGB_STATE_WIDTH-1:0])
            `SEGB_PASS:begin
                if(wrap_singleline_w)begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_SINGLELINE_WRAP;
                end
                else if(wrap_multiline_w)begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_MULTILINE_WRAP;
                end
                else if(incr_multiline_w)begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_INCR;
                end
                else begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_PASS;
                end

            end
            `SEGB_INCR:begin
                if((txn_cnt_q[7:0]-1'b1) == 0)begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_PASS;
                end
                else begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_INCR;
                end
            end
            `SEGB_MULTILINE_WRAP:begin
                if((txn_cnt_q[7:0]-1'b1) == 0)begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_PASS;
                end
                else begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_MULTILINE_WRAP;
                end
            end
            `SEGB_SINGLELINE_WRAP:begin
                if((txn_cnt_q[7:0]-1'b1) == 0)begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_PASS;
                end
                else begin
                    state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_SINGLELINE_WRAP_FIRST_PART;
                end
            end
            `SEGB_SINGLELINE_WRAP_FIRST_PART:begin
                state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_SINGLELINE_WRAP_SECOND_PART;
            end
            `SEGB_SINGLELINE_WRAP_SECOND_PART:begin
                state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_PASS;
            end
            default: begin
                state_nxt_r[`SEGB_STATE_WIDTH-1:0] = `SEGB_PASS;
            end
        endcase
    end

    always@* begin
        chi_ct_vec_s1_r[3:0] = 4'b0001 << segburst_addr_s1_o[5:4];
        casez (state_q[`SEGB_STATE_WIDTH-1:0])
            `SEGB_PASS:begin
                if(axi_burst_fix_w)begin
                    chi_pd_vec_s1_r[3:0] = 4'b0001 << axi_addr_align_w[5:4];
                    chi_ls_vec_s1_r[3:0] = 4'b0001 << axi_addr_align_w[5:4];
                    chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {12'b0,axi_len_in_s1_i[3:0]} << {axi_addr_align_w[5:4],2'b00};
                end
                else if(state_nxt_r[`SEGB_STATE_WIDTH-1:0] == `SEGB_PASS)begin
                    casez({axi_addr_align_w[5:4],addr_plus_bytes_w[5:4]})
                        4'b0000:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0001;
                            chi_ls_vec_s1_r[3:0] = 4'b0001;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,axi_len_in_s1_i[3:0]};
                        end
                        4'b0001:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0011;
                            chi_ls_vec_s1_r[3:0] = 4'b0010;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,chi_bc_last_w[3:0],chi_bc_first_w[3:0]};
                        end
                        4'b0010:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0111;
                            chi_ls_vec_s1_r[3:0] = 4'b0100;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_first_w[3:0]};
                        end
                        4'b0011:begin
                            chi_pd_vec_s1_r[3:0] = 4'b1111;
                            chi_ls_vec_s1_r[3:0] = 4'b1000;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_first_w[3:0]};
                        end
                        4'b0101:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0010;
                            chi_ls_vec_s1_r[3:0] = 4'b0010;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,axi_len_in_s1_i[3:0],4'b0000};
                        end
                        4'b0110:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0110;
                            chi_ls_vec_s1_r[3:0] = 4'b0100;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,chi_bc_last_w[3:0],chi_bc_first_w[3:0],4'b0000};
                        end
                        4'b0111:begin
                            chi_pd_vec_s1_r[3:0] = 4'b1110;
                            chi_ls_vec_s1_r[3:0] = 4'b1000;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_first_w[3:0],4'b0000};
                        end
                        4'b1010:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0100;
                            chi_ls_vec_s1_r[3:0] = 4'b0100;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,axi_len_in_s1_i[3:0],4'b0000,4'b0000};
                        end
                        4'b1011:begin
                            chi_pd_vec_s1_r[3:0] = 4'b1100;
                            chi_ls_vec_s1_r[3:0] = 4'b1000;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_last_w[3:0],chi_bc_first_w[3:0],4'b0000,4'b0000};
                        end
                        4'b1111:begin
                            chi_pd_vec_s1_r[3:0] = 4'b1000;
                            chi_ls_vec_s1_r[3:0] = 4'b1000;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {axi_len_in_s1_i[3:0],4'b0000,4'b0000,4'b0000};
                        end
                        default:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0000;
                            chi_ls_vec_s1_r[3:0] = 4'b0000;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,4'b0000};
                        end
                    endcase
                end
                else begin
                    chi_pd_vec_s1_r[3:0] = 4'b1111 << axi_addr_align_w[5:4];
                    chi_ls_vec_s1_r[3:0] = 4'b0000;
                    chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_first_w[3:0]} << {axi_addr_align_w[5:4],2'b00};
                end
            end
            `SEGB_INCR:begin
                if(state_nxt_r[`SEGB_STATE_WIDTH-1:0] == `SEGB_PASS)begin
                    casez(addr_plus_bytes_w[5:4])
                        2'b00:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0001;
                            chi_ls_vec_s1_r[3:0] = 4'b0001;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,chi_bc_last_w[3:0]};
                        end
                        2'b01:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0011;
                            chi_ls_vec_s1_r[3:0] = 4'b0010;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,chi_bc_last_w[3:0],chi_bc_middle_w[3:0]};
                        end
                        2'b10:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0111;
                            chi_ls_vec_s1_r[3:0] = 4'b0100;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0]};
                        end
                        2'b11:begin
                            chi_pd_vec_s1_r[3:0] = 4'b1111;
                            chi_ls_vec_s1_r[3:0] = 4'b1000;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0]};
                        end
                        default:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0000;
                            chi_ls_vec_s1_r[3:0] = 4'b0000;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,4'b0000};
                        end
                    endcase
                end
                else begin
                    chi_pd_vec_s1_r[3:0] = 4'b1111;
                    chi_ls_vec_s1_r[3:0] = 4'b0000;
                    chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0]};
                end
            end
            `SEGB_MULTILINE_WRAP:begin
                if(state_nxt_r[`SEGB_STATE_WIDTH-1:0] == `SEGB_PASS)begin
                    casez(addr_plus_bytes_w[5:4])
                        2'b00:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0001;
                            chi_ls_vec_s1_r[3:0] = 4'b0001;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,chi_bc_last_w[3:0]};
                        end
                        2'b01:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0011;
                            chi_ls_vec_s1_r[3:0] = 4'b0010;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,chi_bc_last_w[3:0],chi_bc_middle_w[3:0]};
                        end
                        2'b10:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0111;
                            chi_ls_vec_s1_r[3:0] = 4'b0100;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0]};
                        end
                        2'b11:begin
                            chi_pd_vec_s1_r[3:0] = 4'b1111;
                            chi_ls_vec_s1_r[3:0] = 4'b1000;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0]};
                        end
                        default:begin
                            chi_pd_vec_s1_r[3:0] = 4'b0000;
                            chi_ls_vec_s1_r[3:0] = 4'b0000;
                            chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,4'b0000};
                        end
                    endcase
                end
                else begin
                    chi_pd_vec_s1_r[3:0] = 4'b1111;
                    chi_ls_vec_s1_r[3:0] = 4'b0000;
                    chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0]};
                end
            end
            `SEGB_SINGLELINE_WRAP:begin
                casez({axi_addr_align_w[5:4],addr_plus_bytes_w[5:4]})
                    4'b0000:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0001;
                        chi_ls_vec_s1_r[3:0] = 4'b0001;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,axi_len_in_s1_i[3:0]};
                    end
                    4'b0001:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0011;
                        chi_ls_vec_s1_r[3:0] = 4'b0010;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,chi_bc_last_w[3:0],chi_bc_first_w[3:0]};
                    end
                    4'b0011:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1111;
                        chi_ls_vec_s1_r[3:0] = 4'b1000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_first_w[3:0]};
                    end
                    4'b0101:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0010;
                        chi_ls_vec_s1_r[3:0] = 4'b0010;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,axi_len_in_s1_i[3:0],4'b0000};
                    end
                    4'b1010:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0100;
                        chi_ls_vec_s1_r[3:0] = 4'b0100;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,axi_len_in_s1_i[3:0],4'b0000,4'b0000};
                    end
                    4'b1011:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1100;
                        chi_ls_vec_s1_r[3:0] = 4'b1000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_last_w[3:0],chi_bc_first_w[3:0],4'b0000,4'b0000};
                    end
                    4'b1111:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1000;
                        chi_ls_vec_s1_r[3:0] = 4'b1000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {axi_len_in_s1_i[3:0],4'b0000,4'b0000,4'b0000};
                    end
                    default:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0000;
                        chi_ls_vec_s1_r[3:0] = 4'b0000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,4'b0000};
                    end
                endcase
            end
            `SEGB_SINGLELINE_WRAP_FIRST_PART:begin
                casez({axi_addr_align_w[5:4],chi_addr_sl_wrap_first_tail_w[5:4]})
                    4'b0000:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0001;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,chi_len_sl_wrap_first_w[3:0]};
                    end
                    4'b0001:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0011;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,chi_bc_middle_w[3:0],chi_bc_first_w[3:0]};
                    end
                    4'b0011:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1111;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_first_w[3:0]};
                    end
                    4'b0101:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0010;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,chi_len_sl_wrap_first_w[3:0],4'b0000};
                    end
                    4'b0111:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1110;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_first_w[3:0],4'b0000};
                    end
                    4'b1010:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0100;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,chi_len_sl_wrap_first_w[3:0],4'b0000,4'b0000};
                    end
                    4'b1011:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1100;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_middle_w[3:0],chi_bc_first_w[3:0],4'b0000,4'b0000};
                    end
                    4'b1111:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_len_sl_wrap_first_w[3:0],4'b0000,4'b0000,4'b0000};
                    end
                    default:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,4'b0000};
                    end
                endcase
                chi_ls_vec_s1_r[3:0] = 4'b0000;
            end
            `SEGB_SINGLELINE_WRAP_SECOND_PART:begin
                casez({addr_boundary_wrap_s1_w[5:4],chi_addr_sl_wrap_second_tail_w[5:4]})
                    4'b0000:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0001;
                        chi_ls_vec_s1_r[3:0] = 4'b0001;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,chi_len_sl_wrap_second_w[3:0] - 1'b1};
                    end
                    4'b0001:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0011;
                        chi_ls_vec_s1_r[3:0] = 4'b0010;
                        //Although the end address of wrap is different from the end address of addr_in+len*size, the offset is the same and can be used directly.
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,chi_bc_last_w[3:0],chi_bc_middle_w[3:0]};
                    end
                    4'b0010:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0111;
                        chi_ls_vec_s1_r[3:0] = 4'b0100;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0]};
                    end
                    4'b0011:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1111;
                        chi_ls_vec_s1_r[3:0] = 4'b1000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_last_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0],chi_bc_middle_w[3:0]};
                    end
                    4'b0101:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0010;
                        chi_ls_vec_s1_r[3:0] = 4'b0010;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,chi_len_sl_wrap_second_w[3:0] - 1'b1,4'b0000};
                    end
                    4'b1010:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0100;
                        chi_ls_vec_s1_r[3:0] = 4'b0100;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,chi_len_sl_wrap_second_w[3:0] - 1'b1,4'b0000,4'b0000};
                    end
                    4'b1011:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1100;
                        chi_ls_vec_s1_r[3:0] = 4'b1000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_bc_last_w[3:0],chi_bc_middle_w[3:0],4'b0000,4'b0000};
                    end
                    4'b1111:begin
                        chi_pd_vec_s1_r[3:0] = 4'b1000;
                        chi_ls_vec_s1_r[3:0] = 4'b1000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {chi_len_sl_wrap_second_w[3:0] - 1'b1,4'b0000,4'b0000,4'b0000};
                    end
                    default:begin
                        chi_pd_vec_s1_r[3:0] = 4'b0000;
                        chi_ls_vec_s1_r[3:0] = 4'b0000;
                        chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,4'b0000};
                    end
                endcase
            end
            default: begin
                chi_pd_vec_s1_r[3:0] = 4'b0000;
                chi_ls_vec_s1_r[3:0] = 4'b0000;
                chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0] = {4'b0000,4'b0000,4'b0000,4'b0000};
            end
        endcase
    end

    always@* begin
        segburst_dmask_s1_r[`RNI_DMASK_CT_RANGE] = chi_ct_vec_s1_r[3:0];
        segburst_dmask_s1_r[`RNI_DMASK_PD_RANGE] = chi_pd_vec_s1_r[3:0];
        segburst_dmask_s1_r[`RNI_DMASK_LS_RANGE] = chi_ls_vec_s1_r[3:0];
        segburst_dmask_s1_r[`RNI_DMASK_RV_RANGE] = 4'b0000;
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            state_q[`SEGB_STATE_WIDTH-1:0] <= `SEGB_PASS;
        end
        else begin
            if(state_enable_w)begin
                state_q[`SEGB_STATE_WIDTH-1:0] <= state_nxt_r[`SEGB_STATE_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            txn_cnt_q[7:0] <= 8'd0;
        end
        else begin
            if(~stall_flag_s1_i)begin
                txn_cnt_q[7:0] <= txn_cnt_s1_r[7:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            axi_addr_q[`AXI4_AWADDR_WIDTH-1:0] <= {`AXI4_AWADDR_WIDTH{1'b0}};
        end
        else begin
            if(~stall_flag_s1_i)begin
                axi_addr_q[`AXI4_AWADDR_WIDTH-1:0] <= segburst_addr_s1_o[`AXI4_AWADDR_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            axi_lock_q <= 1'b0;
        end
        else begin
            if(~stall_flag_s1_i)begin
                axi_lock_q <= axi_lock_in_s1_i;
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            axi_addr_in_q[`AXI4_AWADDR_WIDTH-1:0] <= {`AXI4_AWADDR_WIDTH{1'b0}};
        end
        else begin
            if(axi_new_trans_r)begin
                axi_addr_in_q[`AXI4_AWADDR_WIDTH-1:0] <= axi_addr_align_w[`AXI4_AWADDR_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            addr_boundary_wrap_q[`AXI4_AWADDR_WIDTH-1:0] <= {`AXI4_AWADDR_WIDTH{1'b0}};
        end
        else begin
            if(axi_new_trans_r)begin
                addr_boundary_wrap_q[`AXI4_AWADDR_WIDTH-1:0] <= addr_boundary_wrap_s1_w[`AXI4_AWADDR_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            addr_multiline_wrap_final_q[`AXI4_AWADDR_WIDTH-1:0] <= {`AXI4_AWADDR_WIDTH{1'b0}};
        end
        else begin
            if(axi_new_trans_r)begin
                addr_multiline_wrap_final_q[`AXI4_AWADDR_WIDTH-1:0] <= addr_multiline_wrap_final_s1_w[`AXI4_AWADDR_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            axi_last_trans_addr_q[`AXI_4KB_WIDTH-1:0] <= {`AXI_4KB_WIDTH{1'b0}};
        end
        else begin
            if(axi_new_trans_r)begin
                axi_last_trans_addr_q[`AXI_4KB_WIDTH-1:0] <= axi_last_trans_addr_w[`AXI_4KB_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            chi_size_sl_wrap_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] <= {`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
        end
        else begin
            if(axi_new_trans_r)begin
                chi_size_sl_wrap_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] <= chi_size_sl_wrap_s1_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0];
            end
        end
    end
    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            chi_size_sl_wrap_first_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] <= {`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
        end
        else begin
            if(axi_new_trans_r)begin
                chi_size_sl_wrap_first_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] <= chi_size_sl_wrap_first_s1_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0];
            end
        end
    end
    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            chi_size_sl_wrap_second_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] <= {`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
        end
        else begin
            if(axi_new_trans_r)begin
                chi_size_sl_wrap_second_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] <= chi_size_sl_wrap_second_s1_w[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            segburst_dmask_q[`RNI_DMASK_WIDTH-1:0] <= {`RNI_DMASK_WIDTH{1'b0}};
        end
        else begin
            if(segburst_valid_s1_o)begin
                segburst_dmask_q[`RNI_DMASK_WIDTH-1:0] <= segburst_dmask_s1_r[`RNI_DMASK_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            segburst_bc_vec_s2_o[`RNI_BCVEC_WIDTH-1:0] <= {`RNI_BCVEC_WIDTH{1'b0}};
        end
        else begin
            if(segburst_valid_s1_o)begin
                segburst_bc_vec_s2_o[`RNI_BCVEC_WIDTH-1:0] <= chi_bc_vec_s1_r[`RNI_BCVEC_WIDTH-1:0];
            end
        end
    end

    always @(posedge clk_i or posedge rst_i ) begin
        if (rst_i == 1'b1)begin
            chi_size_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] <= {`CHIE_REQ_FLIT_SIZE_WIDTH{1'b0}};
        end
        else begin
            if(segburst_valid_s1_o)begin
                chi_size_q[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0] <= chi_size_s1_r[`CHIE_REQ_FLIT_SIZE_WIDTH-1:0];
            end
        end
    end

endmodule
