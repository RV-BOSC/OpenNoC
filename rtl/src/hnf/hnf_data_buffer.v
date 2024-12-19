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
*    Wenhao Li <liwenhao@bosc.ac.cn>
*    Hongyu Gao <gaohongyu@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_data_buffer `HNF_PARAM (clk,
                                       rst,
                                       li_dbf_rxdat_valid_s0,
                                       li_dbf_rxdat_txnid_s0,
                                       li_dbf_rxdat_opcode_s0,
                                       li_dbf_rxdat_dataid_s0,
                                       li_dbf_rxdat_be_s0,
                                       li_dbf_rxdat_data_s0,
                                       mshr_dbf_rd_idx_sx1_q,
                                       mshr_dbf_rd_valid_sx1_q,
                                       mshr_dbf_retired_idx_sx1_q,
                                       mshr_dbf_retired_valid_sx1_q,
                                       pipe_dbf_wr_valid_sx9_q,
                                       pipe_dbf_wr_idx_sx9_q,
                                       pipe_dbf_wr_data_sx9_q,
                                       pipe_dbf_rd_idx_sx2_q,
                                       pipe_dbf_rd_idx_sx2_valid_q,
                                       dbf_pipe_rd_data_sx7_q,
                                       dbf_txdat_valid_sx1,
                                       dbf_txdat_idx_sx1,
                                       dbf_txdat_be_sx1,
                                       dbf_txdat_data_sx1,
                                       dbf_txdat_pe_sx1);

    //global inputs
    input wire                                       clk;
    input wire                                       rst;

    //inputs from hnf_link_rxdat_parse
    input wire                                       li_dbf_rxdat_valid_s0;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]             li_dbf_rxdat_txnid_s0;
    input wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]     li_dbf_rxdat_opcode_s0;
    input wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]     li_dbf_rxdat_dataid_s0;
    input wire [`CHIE_DAT_FLIT_BE_WIDTH-1:0]         li_dbf_rxdat_be_s0;
    input wire [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]       li_dbf_rxdat_data_s0;

    //inputs from hnf_mshr_ctl
    input wire [`MSHR_ENTRIES_WIDTH-1:0]             mshr_dbf_rd_idx_sx1_q;
    input wire                                       mshr_dbf_rd_valid_sx1_q;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]             mshr_dbf_retired_idx_sx1_q;
    input wire                                       mshr_dbf_retired_valid_sx1_q;

    //inputs from hnf_cache_pipeline
    input wire                                       pipe_dbf_wr_valid_sx9_q;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]             pipe_dbf_wr_idx_sx9_q;
    input wire [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]     pipe_dbf_wr_data_sx9_q;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]             pipe_dbf_rd_idx_sx2_q;
    input wire                                       pipe_dbf_rd_idx_sx2_valid_q;


    //outputs to hnf_cache_pipeline
    output reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]    dbf_pipe_rd_data_sx7_q;

    //outputs to hnf_link_txdat_wrap
    output wire                                      dbf_txdat_valid_sx1;
    output wire [`MSHR_ENTRIES_WIDTH-1:0]            dbf_txdat_idx_sx1;
    output wire [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]      dbf_txdat_be_sx1;
    output wire [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]    dbf_txdat_data_sx1;
    output wire [1:0]                                dbf_txdat_pe_sx1;

    //internal signals
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0] dbf_data_q[0:`MSHR_ENTRIES_NUM-1];
    reg [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]   dbf_be_q[0:`MSHR_ENTRIES_NUM-1];
    reg [1:0]                             dbf_pe_q[0:`MSHR_ENTRIES_NUM-1];
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0] dbf_pipe_rd_data_sx3_q;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0] dbf_pipe_rd_data_sx4_q;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0] dbf_pipe_rd_data_sx5_q;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0] dbf_pipe_rd_data_sx6_q;

    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0] temp_li_data;
    reg [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0] temp_li_be;

    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0] temp_pipe_data;
    reg [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0] temp_pipe_be;

    wire [5:0] offset;

    assign offset=(li_dbf_rxdat_dataid_s0 == 2'b10)?`CHIE_DAT_FLIT_DATA_WIDTH/8:'d0;

    genvar i;
    generate
        for(i = 0;i<(`CHIE_DAT_FLIT_DATA_WIDTH*2)/8;i = i+1) begin:get_wt_temp
            always@(*) begin//linklist temp data
                if (li_dbf_rxdat_valid_s0&&pipe_dbf_wr_valid_sx9_q&&(li_dbf_rxdat_txnid_s0 == pipe_dbf_wr_idx_sx9_q)) begin//write conflict
                    if ((li_dbf_rxdat_dataid_s0 == 2'b00&&i<`CHIE_DAT_FLIT_DATA_WIDTH/8)||(li_dbf_rxdat_dataid_s0 == 2'b10&&i >= `CHIE_DAT_FLIT_DATA_WIDTH/8)) begin//first package
                        temp_li_data[i*8+:8] = li_dbf_rxdat_be_s0[i-offset]?li_dbf_rxdat_data_s0[(i-offset)*8+:8]:(dbf_be_q[li_dbf_rxdat_txnid_s0][i]?dbf_data_q[li_dbf_rxdat_txnid_s0][i*8+:8]:pipe_dbf_wr_data_sx9_q[i*8+:8]);
                        temp_li_be[i]        = 1;
                    end
                    else begin//The rest
                        temp_li_data[i*8+:8] = dbf_be_q[li_dbf_rxdat_txnid_s0][i]?dbf_data_q[li_dbf_rxdat_txnid_s0][i*8+:8]:pipe_dbf_wr_data_sx9_q[i*8+:8];
                        temp_li_be[i]        = 1;
                    end
                end
                else begin
                    if (li_dbf_rxdat_valid_s0 && ((li_dbf_rxdat_opcode_s0 == `CHIE_COPYBACKWRDATA)||(li_dbf_rxdat_opcode_s0 == `CHIE_NONCOPYBACKWRDATA)||(li_dbf_rxdat_opcode_s0 == `CHIE_NCBWRDATACOMPACK))) begin//over write
                        if ((li_dbf_rxdat_dataid_s0 == 2'b00&&i<`CHIE_DAT_FLIT_DATA_WIDTH/8)||(li_dbf_rxdat_dataid_s0 == 2'b10&&i >= `CHIE_DAT_FLIT_DATA_WIDTH/8))begin
                            temp_li_data[i*8+:8] = li_dbf_rxdat_be_s0[i-offset]?li_dbf_rxdat_data_s0[(i-offset)*8+:8]:dbf_data_q[li_dbf_rxdat_txnid_s0][i*8+:8];
                            temp_li_be[i]        = li_dbf_rxdat_be_s0[i-offset]||dbf_be_q[li_dbf_rxdat_txnid_s0][i];
                        end
                        else begin
                            temp_li_data[i*8+:8] = dbf_data_q[li_dbf_rxdat_txnid_s0][i*8+:8];
                            temp_li_be[i]        = dbf_be_q[li_dbf_rxdat_txnid_s0][i];
                        end
                    end
                    else if (li_dbf_rxdat_valid_s0 && ((li_dbf_rxdat_opcode_s0 == `CHIE_SNPRESPDATA)||(li_dbf_rxdat_opcode_s0 == `CHIE_SNPRESPDATAFWDED))) begin//merge
                        if ((li_dbf_rxdat_dataid_s0 == 2'b00&&i<`CHIE_DAT_FLIT_DATA_WIDTH/8)||(li_dbf_rxdat_dataid_s0 == 2'b10&&i >= `CHIE_DAT_FLIT_DATA_WIDTH/8))begin
                            temp_li_data[i*8+:8] = (li_dbf_rxdat_be_s0[i-offset]&&!dbf_be_q[li_dbf_rxdat_txnid_s0][i])?li_dbf_rxdat_data_s0[(i-offset)*8+:8]:dbf_data_q[li_dbf_rxdat_txnid_s0][i*8+:8];
                            temp_li_be[i]        = li_dbf_rxdat_be_s0[i-offset]||dbf_be_q[li_dbf_rxdat_txnid_s0][i];
                        end
                        else begin
                            temp_li_data[i*8+:8] = dbf_data_q[li_dbf_rxdat_txnid_s0][i*8+:8];
                            temp_li_be[i]        = dbf_be_q[li_dbf_rxdat_txnid_s0][i];
                        end
                    end
                    else if (li_dbf_rxdat_valid_s0 && (li_dbf_rxdat_opcode_s0 == `CHIE_COMPDATA))begin
                        if ((li_dbf_rxdat_dataid_s0 == 2'b00&&i<`CHIE_DAT_FLIT_DATA_WIDTH/8)||(li_dbf_rxdat_dataid_s0 == 2'b10&&i >= `CHIE_DAT_FLIT_DATA_WIDTH/8))begin
                            temp_li_data[i*8+:8] = !dbf_be_q[li_dbf_rxdat_txnid_s0][i]?li_dbf_rxdat_data_s0[(i-offset)*8+:8]:dbf_data_q[li_dbf_rxdat_txnid_s0][i*8+:8];
                            temp_li_be[i]        = 1;
                        end
                        else begin
                            temp_li_data[i*8+:8] = dbf_data_q[li_dbf_rxdat_txnid_s0][i*8+:8];
                            temp_li_be[i]        = dbf_be_q[li_dbf_rxdat_txnid_s0][i];
                        end
                    end
                    else begin
                        temp_li_data[i*8+:8] = dbf_data_q[li_dbf_rxdat_txnid_s0][i*8+:8];
                        temp_li_be[i]        = dbf_be_q[li_dbf_rxdat_txnid_s0][i];
                    end
                end
            end

            always@(*) begin//pipe temp data
                if(pipe_dbf_wr_valid_sx9_q && pipe_dbf_rd_idx_sx2_valid_q)begin
                    temp_pipe_data[i*8+:8] = pipe_dbf_wr_data_sx9_q[i*8+:8];
                    temp_pipe_be[i]        = 1;
                end
                else if (pipe_dbf_wr_valid_sx9_q&&!(li_dbf_rxdat_valid_s0&&(li_dbf_rxdat_txnid_s0 == pipe_dbf_wr_idx_sx9_q)))begin
                    temp_pipe_data[i*8+:8] = dbf_be_q[pipe_dbf_wr_idx_sx9_q][i]?dbf_data_q[pipe_dbf_wr_idx_sx9_q][i*8+:8]:pipe_dbf_wr_data_sx9_q[i*8+:8];
                    temp_pipe_be[i]        = 1;
                end
                else begin
                    temp_pipe_data[i*8+:8] = dbf_data_q[pipe_dbf_wr_idx_sx9_q][i*8+:8];
                    temp_pipe_be[i]        = dbf_be_q[pipe_dbf_wr_idx_sx9_q][i];
                end
            end
        end
    endgenerate

    generate
        for(i = 0;i<`MSHR_ENTRIES_NUM;i = i+1) begin:load_wt_temp
            always@(posedge clk or posedge rst)begin
                if(rst)begin
                    dbf_data_q[i] <= 'd0;
                    dbf_be_q[i]   <= 'd0;
                    dbf_pe_q[i]   <= 'd0;
                end
                else begin
                    if (mshr_dbf_retired_valid_sx1_q && i == mshr_dbf_retired_idx_sx1_q) begin//entry retired
                        dbf_data_q[i] <= 'd0;
                        dbf_be_q[i]   <= 'd0;
                        dbf_pe_q[i]   <= 'd0;
                    end
                    else if (li_dbf_rxdat_valid_s0 && pipe_dbf_wr_valid_sx9_q && i == li_dbf_rxdat_txnid_s0 && i== pipe_dbf_wr_idx_sx9_q)begin
                        dbf_data_q[i] <= temp_li_data;
                        dbf_be_q[i]   <= temp_li_be;
                        dbf_pe_q[i]   <= 2'b11;
                    end
                    else if(li_dbf_rxdat_valid_s0 && i == li_dbf_rxdat_txnid_s0)begin
                        dbf_data_q[i] <= temp_li_data;
                        dbf_be_q[i]   <= temp_li_be;
                        dbf_pe_q[i]   <= (li_dbf_rxdat_dataid_s0 == 2'b00) ? (dbf_pe_q[i] | 2'b01) : (dbf_pe_q[i] | 2'b10);
                    end
                    else if (pipe_dbf_wr_valid_sx9_q && i == pipe_dbf_wr_idx_sx9_q)begin
                        dbf_data_q[i] <= temp_pipe_data;
                        dbf_be_q[i]   <= temp_pipe_be;
                        dbf_pe_q[i]   <= 2'b11;
                    end
                    else begin
                    end
                end
            end
        end
    endgenerate

    always@(posedge clk or posedge rst)begin :pipe_rd
        if(rst)begin
            dbf_pipe_rd_data_sx3_q <= 'd0;
            dbf_pipe_rd_data_sx4_q <= 'd0;
            dbf_pipe_rd_data_sx5_q <= 'd0;
            dbf_pipe_rd_data_sx6_q <= 'd0;
            dbf_pipe_rd_data_sx7_q <= 'd0;
        end
        else begin
            dbf_pipe_rd_data_sx3_q <= pipe_dbf_rd_idx_sx2_valid_q?dbf_data_q[pipe_dbf_rd_idx_sx2_q]:dbf_pipe_rd_data_sx3_q;
            dbf_pipe_rd_data_sx4_q <= dbf_pipe_rd_data_sx3_q;
            dbf_pipe_rd_data_sx5_q <= dbf_pipe_rd_data_sx4_q;
`ifdef HNF_DELAY_ONE_CYCLE

            dbf_pipe_rd_data_sx6_q <= dbf_pipe_rd_data_sx5_q;
            dbf_pipe_rd_data_sx7_q <= dbf_pipe_rd_data_sx6_q;
`else
            dbf_pipe_rd_data_sx7_q <= dbf_pipe_rd_data_sx5_q;
`endif

        end
    end

    assign dbf_txdat_valid_sx1 = mshr_dbf_rd_valid_sx1_q;//tx read
    assign dbf_txdat_idx_sx1   = mshr_dbf_rd_idx_sx1_q;
    assign dbf_txdat_be_sx1    = dbf_be_q[mshr_dbf_rd_idx_sx1_q];
    assign dbf_txdat_data_sx1  = dbf_data_q[mshr_dbf_rd_idx_sx1_q];
    assign dbf_txdat_pe_sx1    = dbf_pe_q[mshr_dbf_rd_idx_sx1_q];

endmodule
