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
*    Bingcheng Jin <jinbingcheng@bosc.ac.cn>
*    Hongyu Gao <gaohongyu@bosc.ac.cn>
*/

`include "hnf_defines.v"

module hnf_biq #(
        parameter BIQ_WIDTH = -1,
        parameter BIQ_DEPTH = -1
    ) (
        //global inputs
        clk,
        rst,

        //main inputs
        push,
        pop,
        addr_in,
        find,
        find_addr,

        //main outputs
        match,
        addr_out,
        biq_full,
        biq_empty,
        biq_pfull
    );
    //local parameter
    localparam BIQ_PTR_WIDTH = $clog2(BIQ_DEPTH)+1;

    //global inputs
    input wire                  clk;
    input wire                  rst;

    //main inputs
    input wire                  push;
    input wire                  pop;
    input wire [BIQ_WIDTH-1:0]  addr_in;
    input wire                  find;
    input wire [BIQ_WIDTH-1:0]  find_addr;

    //main outputs
    output wire                 match;
    output wire [BIQ_WIDTH-1:0] addr_out;
    output wire                 biq_full;
    output wire                 biq_empty;
    output wire                 biq_pfull;

    //internal regs
    wire                        biq_push_con;
    wire                        biq_pop_con;
    reg [BIQ_PTR_WIDTH-1:0]     rd_ptr_q;
    reg [BIQ_PTR_WIDTH-1:0]     wr_ptr_q;
    reg [BIQ_WIDTH-1:0]         biq_data_q [BIQ_DEPTH-1:0];
    reg [BIQ_DEPTH-1:0]         match_vec;
    reg [BIQ_PTR_WIDTH-1:0]     biq_find_loc;
    reg                         biq_find_flag;

    integer ii;

    generate
        if(BIQ_DEPTH == 1)begin
            reg biq_full_q;
            reg biq_empty_q;

            always @(posedge clk or posedge rst) begin
                if (rst == 1'b1)
                    biq_full_q <= 0;
                else if(biq_push_con)
                    biq_full_q <= 1'b1;
                else if(biq_pop_con)
                    biq_full_q <= 1'b0;
                else
                    biq_full_q <=biq_full_q;
            end
            always @(posedge clk) begin
                if(biq_push_con)begin
                    biq_data_q[0][BIQ_WIDTH-1:0] <= addr_in[BIQ_WIDTH-1:0];
                end
                else if(biq_pop_con)begin
                    biq_data_q[0][BIQ_WIDTH-1:0] <= 0;
                end
                else begin
                    biq_data_q[0][BIQ_WIDTH-1:0] <= biq_data_q[0][BIQ_WIDTH-1:0];
                end
            end

            assign biq_push_con             = push && (!biq_full_q || (pop == 1'b1));
            assign biq_pop_con              = pop && !push;
            assign match                    = biq_full && find && (biq_data_q[0][BIQ_WIDTH-1:`CACHE_BLOCK_OFFSET] == find_addr[BIQ_WIDTH-1:`CACHE_BLOCK_OFFSET]);
            assign addr_out[BIQ_WIDTH-1:0]  = biq_data_q[0][BIQ_WIDTH-1:0];
            assign biq_full                 = biq_full_q;
            assign biq_empty                = ~biq_full_q;
        end
        else begin
            assign biq_push_con     = (push == 1'b1) && (({~wr_ptr_q[BIQ_PTR_WIDTH-1],wr_ptr_q[BIQ_PTR_WIDTH-2:0]} != rd_ptr_q) || (pop == 1'b1));
            assign biq_pop_con      = (pop == 1'b1) && (wr_ptr_q != rd_ptr_q);

            always @(posedge clk or posedge rst) begin
                if (rst == 1'b1)
                    rd_ptr_q[BIQ_PTR_WIDTH-1:0] <= {BIQ_PTR_WIDTH{1'b0}};
                else if(biq_pop_con)
                    rd_ptr_q[BIQ_PTR_WIDTH-1:0] <= rd_ptr_q[BIQ_PTR_WIDTH-1:0] + 1'b1;
                else
                    rd_ptr_q[BIQ_PTR_WIDTH-1:0] <= rd_ptr_q[BIQ_PTR_WIDTH-1:0];
            end

            always @(posedge clk or posedge rst) begin
                if (rst == 1'b1)
                    wr_ptr_q[BIQ_PTR_WIDTH-1:0] <= {BIQ_PTR_WIDTH{1'b0}};
                else if(biq_push_con)
                    wr_ptr_q[BIQ_PTR_WIDTH-1:0] <= wr_ptr_q[BIQ_PTR_WIDTH-1:0]+1'b1;
                else
                    wr_ptr_q[BIQ_PTR_WIDTH-1:0] <= wr_ptr_q[BIQ_PTR_WIDTH-1:0];
            end

            always @(posedge clk) begin
                if(biq_push_con)begin
                    biq_data_q[wr_ptr_q[BIQ_PTR_WIDTH-2:0]][BIQ_WIDTH-1:0] <= addr_in[BIQ_WIDTH-1:0];
                end
                else begin
                end
            end

            assign biq_full = ({~wr_ptr_q[BIQ_PTR_WIDTH-1],wr_ptr_q[BIQ_PTR_WIDTH-2:0]} == rd_ptr_q[BIQ_PTR_WIDTH-1:0]);
            assign biq_empty = (wr_ptr_q[BIQ_PTR_WIDTH-1:0] == rd_ptr_q[BIQ_PTR_WIDTH-1:0]);

            always @* begin
                if (find & ~biq_empty) begin
                    match_vec = {BIQ_DEPTH{1'b0}};
                    biq_find_flag = 1'b0;
                    for (ii = 0; ii < BIQ_DEPTH; ii = ii + 1) begin
                        biq_find_loc[BIQ_PTR_WIDTH-1:0] = rd_ptr_q[BIQ_PTR_WIDTH-1:0] + ii;
                        if(biq_find_loc[BIQ_PTR_WIDTH-1:0] == wr_ptr_q[BIQ_PTR_WIDTH-1:0])begin
                            biq_find_flag = 1'b1;
                            match_vec[ii] = 1'b0;
                        end
                        else if(!biq_find_flag && find && find_addr[BIQ_WIDTH-1:`CACHE_BLOCK_OFFSET] == biq_data_q[biq_find_loc[BIQ_PTR_WIDTH-2:0]][BIQ_WIDTH-1:`CACHE_BLOCK_OFFSET])begin
                            match_vec[ii] = 1'b1;
                        end
                        else begin
                            match_vec[ii] = 1'b0;
                        end
                    end
                end
                else begin
                    match_vec = {BIQ_DEPTH{1'b0}};
                end
            end
            assign match = |match_vec[BIQ_DEPTH-1:0];
            assign addr_out[BIQ_WIDTH-1:0] = biq_data_q[rd_ptr_q[BIQ_PTR_WIDTH-2:0]][BIQ_WIDTH-1:0];
            assign biq_pfull = ({~wr_ptr_q[BIQ_PTR_WIDTH-1],wr_ptr_q[BIQ_PTR_WIDTH-2:0]} == rd_ptr_q[BIQ_PTR_WIDTH-1:0]);
        end
    endgenerate
endmodule
