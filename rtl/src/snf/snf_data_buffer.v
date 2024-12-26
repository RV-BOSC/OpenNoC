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
*    Nana Cai <cainana@bosc.ac.cn>
*    Li Zhao <lizhao@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*    Xiaotian Cao <caoxiaotian@bosc.ac.cn>
*    Guo Bing <guobing@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "axi4_defines.v"
`include "snf_defines.v"
`include "snf_param.v"

module snf_data_buffer `SNF_PARAM
    (
        clk,
        rst,
        rxdat_valid_s0,
        rxdatflit_s0,
        rxreq_dbf_en_s1,
        rxreq_dbf_entry_idx_s1,
        rxreq_dbf_wr_s1,
        rxreq_dbf_addr_s1,
        rxreq_dbf_size_s1,
        rxreq_dbf_axlen_s1,
        mshr_retired_valid_sx,
        mshr_retired_idx_sx,
        mshr_wdat_en_sx,
        mshr_wdat_entry_idx_sx,
        mshr_txdat_en_sx,
        mshr_txdat_entry_idx_sx,
        mshr_txdat_tgtid_sx,
        mshr_txdat_txnid_sx,
        mshr_txdat_opcode_sx,
        mshr_txdat_resp_sx,
        mshr_txdat_resperr_sx,
        mshr_txdat_dbid_sx,
        mshr_txdat_dataid_sx,
        mshr_txdat_tracetag_sx,
        mshr_txdat_srcid_sx,
        mshr_txdat_homenid_sx,
        txdat_dbf_rdy_s1,
        txdat_dbf_won_sx,
        dbf_mshr_rxdat_ok_sx,
        dbf_mshr_rxdat_ok_idx_sx,
        dbf_mshr_rxdat_cancel_sx,
        dbf_mshr_rxdat_cancel_idx_sx,
        dbf_mshr_rdata_en_sx,
        dbf_mshr_rdata_idx_sx,
        dbf_mshr_rdata_cdmask_sx,
        mshr_txdat_won_sx,
        dbf_txdat_valid_sx,
        txdat_flit,
        rid,
        rdata,
        rresp,
        rlast,
        rvalid,
        rready,
        wdata,
        wstrb,
        wlast,
        wvalid,
        wready
    );

    input wire                                      clk;
    input wire                                      rst;
    input wire                                      rxdat_valid_s0;
    input wire [`CHIE_DAT_FLIT_RANGE]               rxdatflit_s0;
    input wire                                      rxreq_dbf_en_s1;
    input wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]        rxreq_dbf_entry_idx_s1;
    input wire                                      rxreq_dbf_wr_s1;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]      rxreq_dbf_addr_s1;
    input wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]      rxreq_dbf_size_s1;
    input wire [`AXI4_ARLEN_WIDTH-1:0]              rxreq_dbf_axlen_s1;
    input wire                                      mshr_retired_valid_sx;
    input wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]        mshr_retired_idx_sx;
    input wire                                      mshr_wdat_en_sx;
    input wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]        mshr_wdat_entry_idx_sx;
    input wire                                      mshr_txdat_en_sx;
    input wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]        mshr_txdat_entry_idx_sx;
    input wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]     mshr_txdat_tgtid_sx;
    input wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]     mshr_txdat_txnid_sx;
    input wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]    mshr_txdat_opcode_sx;
    input wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]      mshr_txdat_resp_sx;
    input wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]   mshr_txdat_resperr_sx;
    input wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]      mshr_txdat_dbid_sx;
    input wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]    mshr_txdat_dataid_sx;
    input wire [`CHIE_DAT_FLIT_TRACETAG_WIDTH-1:0]  mshr_txdat_tracetag_sx;
    input wire [`CHIE_DAT_FLIT_SRCID_WIDTH-1:0]     mshr_txdat_srcid_sx;
    input wire [`CHIE_DAT_FLIT_HOMENID_WIDTH-1:0]   mshr_txdat_homenid_sx;
    output wire                                     mshr_txdat_won_sx;
    input wire                                      txdat_dbf_rdy_s1;
    input wire                                      txdat_dbf_won_sx;
    output reg  [`CHIE_DAT_FLIT_RANGE]              txdat_flit;
    output wire                                     dbf_mshr_rxdat_ok_sx;
    output wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]       dbf_mshr_rxdat_ok_idx_sx;
    output wire                                     dbf_mshr_rxdat_cancel_sx;
    output wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]       dbf_mshr_rxdat_cancel_idx_sx;
    output wire                                     dbf_mshr_rdata_en_sx;
    output wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]       dbf_mshr_rdata_idx_sx;
    output wire [`SNF_MASK_CD_WIDTH-1:0]            dbf_mshr_rdata_cdmask_sx;
    output wire                                     dbf_txdat_valid_sx;
    input  wire [`AXI4_ARID_WIDTH-1:0]              rid;
    input  wire [`AXI4_RDATA_WIDTH-1:0]             rdata;
    input  wire [`AXI4_RRESP_WIDTH-1:0]             rresp;
    input  wire [`AXI4_RLAST_WIDTH-1:0]             rlast;
    input  wire                                     rvalid;
    output wire                                     rready;
    output wire [`AXI4_WDATA_WIDTH-1:0]             wdata;
    output wire [`AXI4_WSTRB_WIDTH-1:0]             wstrb;
    output wire [`AXI4_WLAST_WIDTH-1:0]             wlast;
    output wire                                     wvalid;
    input  wire                                     wready;

    reg [`CHIE_DAT_FLIT_CCID_WIDTH-1:0]             rxreq_alloc_ccid_s2_q[0:`SNF_MSHR_ENTRIES_NUM-1];
    reg [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]             rxreq_alloc_size_s2_q[0:`SNF_MSHR_ENTRIES_NUM-1];
    reg [`SNF_MASK_CD_WIDTH-1:0]                    rdata_cdmask_q[0:`SNF_MSHR_ENTRIES_NUM-1];
    reg [`SNF_MASK_WL_WIDTH-1:0]                    rdata_wlmask_q[0:`SNF_MSHR_ENTRIES_NUM-1];
    reg [`SNF_MASK_CD_WIDTH-1:0]                    wdata_cdmask_q[0:`SNF_MSHR_ENTRIES_NUM-1];
    reg [`SNF_MASK_WL_WIDTH-1:0]                    wdata_wlmask_q[0:`SNF_MSHR_ENTRIES_NUM-1];
    reg [`SNF_MASK_WL_WIDTH-1:0]                    dbf_wlmask_s1_q;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]           dbf_data_q[0:`SNF_MSHR_ENTRIES_NUM-1];
    reg [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]             dbf_be_q[0:`SNF_MSHR_ENTRIES_NUM-1];
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]               wdata_rec_idx_sx_q;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]               wdata_fifo_set_vec;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]               wdata_fifo_get_vec;
    reg [`SNF_MSHR_ENTRIES_NUM-1:0]                 wdata_fifo_valid_sx;
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]               wdata_fifo_entry_idx_sx[0:`SNF_MSHR_ENTRIES_NUM-1];
    reg [`SNF_MSHR_ENTRIES_WIDTH-1:0]               wdata_cancel_idx_sx_q;
    reg [1:0]                                       wdata_recv_cnt_q[0:`SNF_MSHR_ENTRIES_NUM-1];

    wire                                            AXI_128;
    wire                                            wdata_to_slave;
    wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]              wdata_to_slave_idx;
    wire [`SNF_MASK_CD_WIDTH-1:0]                   wdata_cdmask_next;
    wire [1:0]                                      wdata_recv_sx;
    wire [1:0]                                      wdata_recv_cnt_next;
    wire                                            wdata_recv_update;
    wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]              wdata_recv_idx;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]          wdata_recv_data_sx;
    wire [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]            wdata_recv_be_sx;
    wire                                            wdata_cancel_recv_s0;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]            dbf_txdat_data_sx;
    wire [`CHIE_DAT_FLIT_BE_WIDTH-1:0]              dbf_txdat_be_sx;
    wire                                            dbf_txdat_en_sx;
    wire [`SNF_MASK_CD_WIDTH-1:0]                   dbf_cdmask_s0;
    wire [`SNF_MASK_CD_WIDTH-1:0]                   dbf_rd_cdmask_next_sel;
    wire [`SNF_MASK_CD_WIDTH-1:0]                   dbf_rd_cdmask_next;
    wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]              dbf_txdat_entry_idx_sx;
    wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]           rxdat_txnid_s0;
    wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]          rxdat_opcode_s0;
    wire [`CHIE_DAT_FLIT_BE_WIDTH-1:0]              rxdat_be_s0;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]          rxdat_dataid_s0;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]            rxdat_data_s0;
    wire                                            rdata_recv_update_sx;
    wire [`SNF_MSHR_ENTRIES_WIDTH-1:0]              rdata_recv_entry_idx_sx;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]          rdata_recv_data_sx;
    wire [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]            rdata_recv_be_sx;
    wire [`CHIE_DAT_FLIT_CCID_WIDTH-1:0]            mshr_txdat_ccid_sx;

    genvar entry;

    //rxdat decode
    assign rxdat_txnid_s0  = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_TXNID_RANGE]  : {`CHIE_DAT_FLIT_TXNID_WIDTH{1'b0}};
    assign rxdat_opcode_s0 = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_OPCODE_RANGE] : {`CHIE_DAT_FLIT_OPCODE_WIDTH{1'b0}};
    assign rxdat_be_s0     = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_BE_RANGE]     : {`CHIE_DAT_FLIT_BE_WIDTH{1'b0}};
    assign rxdat_dataid_s0 = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_DATAID_RANGE] : {`CHIE_DAT_FLIT_DATAID_WIDTH{1'b0}};
    assign rxdat_data_s0   = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_DATA_RANGE]   : {`CHIE_DAT_FLIT_DATA_WIDTH{1'b0}};
    assign wdata_cancel_recv_s0 = (rxdat_opcode_s0 == `CHIE_WRITEDATACANCEL);

    assign AXI_128 = (`AXI4_AXDATA_WIDTH == 128) ? 1'b1 : 1'b0;

    //************************************************************************//
    // CCID = addr[5:4]
    // cdmask : receive data bank
    // wlmask : the last data bank
    // dbf_cdmask_s0 : the first data bank
    //************************************************************************//
    assign dbf_cdmask_s0 = (AXI_128) ? ((rxreq_dbf_addr_s1[5:4] == 2'b00) ? 4'b0001
                                            : (((rxreq_dbf_addr_s1[5:4] == 2'b01) && ((rxreq_dbf_axlen_s1 == 2'b01) | ((rxreq_dbf_axlen_s1 == 2'b11)))) ? 4'b0001
                                            : ((rxreq_dbf_addr_s1[5:4] == 2'b01) ? 4'b0010
                                            : (((rxreq_dbf_addr_s1[5:4] == 2'b10) && (rxreq_dbf_axlen_s1 == 2'b11)) ? 4'b0001
                                            : ((rxreq_dbf_addr_s1[5:4] == 2'b10) ? 4'b0100
                                            : (((rxreq_dbf_addr_s1[5:4] == 2'b11) && (rxreq_dbf_axlen_s1 == 2'b11)) ? 4'b0001
                                            : (((rxreq_dbf_addr_s1[5:4] == 2'b11) && (rxreq_dbf_axlen_s1 == 2'b01)) ? 4'b0100
                                            : ((rxreq_dbf_addr_s1[5:4] == 2'b11) ? 4'b1000 : 4'b0000))))))))
                                    :(((rxreq_dbf_addr_s1[5] == 1'b1) && (rxreq_dbf_axlen_s1 == 2'b00)) ? 4'b1100 : 4'b0011);

    generate if (`AXI4_AXDATA_WIDTH == 128) begin:dbf_rd_wlmask_128_gen
        always @(*) begin: wlmask_comb_logic
        dbf_wlmask_s1_q = 4'b0000;
            case(rxreq_dbf_addr_s1[5:4])
                2'b00:begin
                    case(rxreq_dbf_axlen_s1)
                        2'b00:
                            dbf_wlmask_s1_q = 4'b0001;
                        2'b01:
                            dbf_wlmask_s1_q = 4'b0010;
                        2'b11:
                            dbf_wlmask_s1_q = 4'b1000;
                    endcase
                end
                2'b01:begin
                    case(rxreq_dbf_axlen_s1)
                        2'b00:
                            dbf_wlmask_s1_q = 4'b0010;
                        2'b01:
                            dbf_wlmask_s1_q = 4'b0010;
                        2'b11:
                            dbf_wlmask_s1_q = 4'b1000;
                    endcase
                end
                2'b10:begin
                    case(rxreq_dbf_axlen_s1)
                        2'b00:
                            dbf_wlmask_s1_q = 4'b0100;
                        2'b01:
                            dbf_wlmask_s1_q = 4'b1000;
                        2'b11:
                            dbf_wlmask_s1_q = 4'b1000;
                    endcase
                end
                2'b11:begin
                    case(rxreq_dbf_axlen_s1)
                        2'b00:
                            dbf_wlmask_s1_q = 4'b1000;
                        2'b01:
                            dbf_wlmask_s1_q = 4'b1000;
                        2'b11:
                            dbf_wlmask_s1_q = 4'b1000;
                    endcase
                end
                default:begin
                    dbf_wlmask_s1_q = 4'b0000;
                end
            endcase
        end
    end else begin :dbf_rd_wlmask_256_gen
        always @(*) begin: wlmask_comb_logic
            dbf_wlmask_s1_q = 4'b0000;
            case(rxreq_dbf_addr_s1[5])
                1'b0:begin
                    case(rxreq_dbf_axlen_s1)
                        2'b00:
                            dbf_wlmask_s1_q = 4'b0011;
                        2'b01:
                            dbf_wlmask_s1_q = 4'b1100;
                    endcase
                end
                1'b1:begin
                    case(rxreq_dbf_axlen_s1)
                        2'b00:
                            dbf_wlmask_s1_q = 4'b1100;
                        2'b01:
                            dbf_wlmask_s1_q = 4'b1100;
                    endcase
                end
                default:begin
                    dbf_wlmask_s1_q = 4'b0000;
                end
            endcase
        end
    end
    endgenerate

    generate
       for(entry = 0;entry<`SNF_MSHR_ENTRIES_NUM;entry = entry+1) begin:req_alloc_info_timing_logic
            always@(posedge clk or posedge rst)begin:ccid_axid_timing_logic
                if(rst)begin
                    rxreq_alloc_ccid_s2_q[entry]     <= 2'b0;
                    rxreq_alloc_size_s2_q[entry]     <= 3'b0;
                end
                else if(rxreq_dbf_en_s1 && (entry == rxreq_dbf_entry_idx_s1))begin
                    rxreq_alloc_ccid_s2_q[entry]     <= rxreq_dbf_addr_s1[5:4];
                    rxreq_alloc_size_s2_q[entry]     <= rxreq_dbf_size_s1;
                end
                else if(mshr_retired_valid_sx && (entry == mshr_retired_idx_sx))begin
                    rxreq_alloc_ccid_s2_q[entry]     <= 2'b0;
                    rxreq_alloc_size_s2_q[entry]     <= 3'b0;
                end
            end
       end
    endgenerate

    //************************************************************************//
    //                        databuffer inout data                           //
    //************************************************************************//
    generate
        for(entry=0;entry<`SNF_MSHR_ENTRIES_NUM;entry=entry+1) begin
            always @(posedge clk or posedge rst) begin:rdat_receive_logic
                if (rst)begin
                    dbf_data_q[entry] <= {`CHIE_DAT_FLIT_DATA_WIDTH*2{1'b0}};
                    dbf_be_q[entry]   <= {`CHIE_DAT_FLIT_BE_WIDTH*2{1'b0}};
                end
                else if (rdata_recv_update_sx && (entry == rdata_recv_entry_idx_sx))begin
                    dbf_data_q[entry] <= dbf_data_q[entry] | rdata_recv_data_sx;
                    dbf_be_q[entry]   <= dbf_be_q[entry] | rdata_recv_be_sx;
                end
                else if (wdata_recv_update && (entry == wdata_recv_idx))begin
                    dbf_data_q[entry] <= dbf_data_q[entry] | wdata_recv_data_sx;
                    dbf_be_q[entry]   <= dbf_be_q[entry] | wdata_recv_be_sx;
                end
                else if (mshr_retired_valid_sx && (entry == mshr_retired_idx_sx))begin
                    dbf_data_q[entry] <= {`CHIE_DAT_FLIT_DATA_WIDTH*2{1'b0}};
                    dbf_be_q[entry]   <= {`CHIE_DAT_FLIT_BE_WIDTH*2{1'b0}};
                end
                else begin
                    ;
                end
            end
        end
    endgenerate

    //************************************************************************//
    //                             AXI R Channel                              //
    //************************************************************************//
    generate
        for(entry = 0;entry<`SNF_MSHR_ENTRIES_NUM;entry = entry+1) begin:dbf_rd_mask_update_timing_logic
            always @(posedge clk or posedge rst)begin:rdat_mask_timing_logic
                if(rst)begin
                        rdata_cdmask_q[entry]   <= {`SNF_MASK_CD_WIDTH{1'b0}};
                        rdata_wlmask_q[entry]   <= {`SNF_MASK_WL_WIDTH{1'b0}};
                end
                else if(rxreq_dbf_en_s1 && !rxreq_dbf_wr_s1 && (entry == rxreq_dbf_entry_idx_s1))begin
                        rdata_cdmask_q[entry]   <= dbf_cdmask_s0;
                        rdata_wlmask_q[entry]   <= dbf_wlmask_s1_q;
                end
                else if(rdata_recv_update_sx && rlast && (entry == rdata_recv_entry_idx_sx))begin
                        rdata_cdmask_q[entry]    <= {`SNF_MASK_CD_WIDTH{1'b0}};
                        rdata_wlmask_q[entry]    <= {`SNF_MASK_WL_WIDTH{1'b0}};
                end
                else if(rdata_recv_update_sx && !rlast && AXI_128 && (entry == rdata_recv_entry_idx_sx))begin
                        rdata_cdmask_q[entry]    <= dbf_rd_cdmask_next;
                        rdata_wlmask_q[entry]    <= rdata_wlmask_q[entry];
                end
                else if(rdata_recv_update_sx && !rlast && !AXI_128 && (entry == rdata_recv_entry_idx_sx))begin
                        rdata_cdmask_q[entry]    <= rdata_cdmask_q[entry] ^ {4{1'b1}};
                        rdata_wlmask_q[entry]    <= rdata_wlmask_q[entry];
                end
                else begin
                    ;
                end
            end
        end
    endgenerate

    assign rready = 1'b1;
    assign rdata_recv_update_sx = rready && rvalid;
    assign dbf_rd_cdmask_next_sel = rdata_cdmask_q[rdata_recv_entry_idx_sx] << 1;
    assign dbf_rd_cdmask_next = ((|dbf_rd_cdmask_next_sel) == 1'b0) ? 4'b0001 : dbf_rd_cdmask_next_sel;
    assign rdata_recv_entry_idx_sx = rdata_recv_update_sx ? rid : 0;
    assign rdata_recv_data_sx = (AXI_128) ? ({{`AXI4_RDATA_WIDTH{rdata_cdmask_q[rdata_recv_entry_idx_sx][3]}},{`AXI4_RDATA_WIDTH{rdata_cdmask_q[rdata_recv_entry_idx_sx][2]}},{`AXI4_RDATA_WIDTH{rdata_cdmask_q[rdata_recv_entry_idx_sx][1]}},{`AXI4_RDATA_WIDTH{rdata_cdmask_q[rdata_recv_entry_idx_sx][0]}}} & {4{rdata}})
                                        :({{`AXI4_RDATA_WIDTH{rdata_cdmask_q[rdata_recv_entry_idx_sx][3]}},{`AXI4_RDATA_WIDTH{rdata_cdmask_q[rdata_recv_entry_idx_sx][1]}}} & {2{rdata}});
    assign rdata_recv_be_sx = {`CHIE_DAT_FLIT_BE_WIDTH*2{1'b1}};
    assign dbf_mshr_rdata_en_sx = rdata_recv_update_sx;
    assign dbf_mshr_rdata_idx_sx = rdata_recv_entry_idx_sx;
    assign dbf_mshr_rdata_cdmask_sx = rdata_cdmask_q[rdata_recv_entry_idx_sx];

    //************************************************************************//
    //                        DBUF TXDAT Channel                              //
    //************************************************************************//

    assign dbf_txdat_valid_sx = dbf_txdat_en_sx;
    assign dbf_txdat_en_sx = mshr_txdat_en_sx && txdat_dbf_rdy_s1;
    assign dbf_txdat_entry_idx_sx = mshr_txdat_entry_idx_sx;
    assign dbf_txdat_data_sx = (dbf_txdat_en_sx) ? ((mshr_txdat_dataid_sx == 2'b00) ? dbf_data_q[dbf_txdat_entry_idx_sx][0+:`CHIE_DAT_FLIT_DATA_WIDTH] : ((mshr_txdat_dataid_sx == 2'b10) ? dbf_data_q[dbf_txdat_entry_idx_sx][`CHIE_DAT_FLIT_DATA_WIDTH+:`CHIE_DAT_FLIT_DATA_WIDTH] : {`CHIE_DAT_FLIT_DATA_WIDTH{1'b0}})) : {`CHIE_DAT_FLIT_DATA_WIDTH{1'b0}};
    assign dbf_txdat_be_sx = (dbf_txdat_en_sx) ?  ((mshr_txdat_dataid_sx == 2'b00) ? dbf_be_q[dbf_txdat_entry_idx_sx][0+:`CHIE_DAT_FLIT_BE_WIDTH] : ((mshr_txdat_dataid_sx == 2'b10) ? dbf_be_q[dbf_txdat_entry_idx_sx][`CHIE_DAT_FLIT_BE_WIDTH+:`CHIE_DAT_FLIT_BE_WIDTH] : {`CHIE_DAT_FLIT_BE_WIDTH{1'b0}})) : {`CHIE_DAT_FLIT_BE_WIDTH{1'b0}};

    assign mshr_txdat_ccid_sx = rxreq_alloc_ccid_s2_q[dbf_txdat_entry_idx_sx];

    // output to mshr
    assign mshr_txdat_won_sx = txdat_dbf_won_sx;

    generate
        if(CHIE_DAT_RSVDC_WIDTH_PARAM != 0)begin
            always @*begin
                txdat_flit[`CHIE_DAT_FLIT_RSVDC_RANGE] = {`CHIE_DAT_FLIT_RSVDC_WIDTH{1'b0}};
            end
        end
    endgenerate

    always@(*)begin:txdat_package_comb_logic
        txdat_flit[`CHIE_DAT_FLIT_QOS_RANGE]       = {`CHIE_DAT_FLIT_QOS_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_TGTID_RANGE]     = mshr_txdat_tgtid_sx;
        txdat_flit[`CHIE_DAT_FLIT_SRCID_RANGE]     = mshr_txdat_srcid_sx;
        txdat_flit[`CHIE_DAT_FLIT_TXNID_RANGE]     = mshr_txdat_txnid_sx;
        txdat_flit[`CHIE_DAT_FLIT_HOMENID_RANGE]   = mshr_txdat_homenid_sx;
        txdat_flit[`CHIE_DAT_FLIT_OPCODE_RANGE]    = mshr_txdat_opcode_sx;
        txdat_flit[`CHIE_DAT_FLIT_RESPERR_RANGE]   = mshr_txdat_resperr_sx;
        txdat_flit[`CHIE_DAT_FLIT_RESP_RANGE]      = mshr_txdat_resp_sx;
        txdat_flit[`CHIE_DAT_FLIT_FWDSTATE_RANGE]  = {`CHIE_DAT_FLIT_FWDSTATE_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_CBUSY_RANGE]     = {`CHIE_DAT_FLIT_CBUSY_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_DBID_RANGE]      = mshr_txdat_dbid_sx;
        txdat_flit[`CHIE_DAT_FLIT_CCID_RANGE]      = mshr_txdat_ccid_sx;
        txdat_flit[`CHIE_DAT_FLIT_DATAID_RANGE]    = mshr_txdat_dataid_sx;
        txdat_flit[`CHIE_DAT_FLIT_TAGOP_RANGE]     = {`CHIE_DAT_FLIT_TAGOP_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_TAG_RANGE]       = {`CHIE_DAT_FLIT_TAG_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_TU_RANGE]        = {`CHIE_DAT_FLIT_TU_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_TRACETAG_RANGE]  = mshr_txdat_tracetag_sx;
        txdat_flit[`CHIE_DAT_FLIT_BE_RANGE]        = dbf_txdat_be_sx;
        txdat_flit[`CHIE_DAT_FLIT_DATA_RANGE]      = dbf_txdat_data_sx;
        txdat_flit[`CHIE_DAT_FLIT_DATACHECK_RANGE] = {`CHIE_DAT_FLIT_DATACHECK_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_POISON_RANGE]    = {`CHIE_DAT_FLIT_POISON_WIDTH{1'b0}};
    end

    //************************************************************************//
    //                              W channel                                 //
    //************************************************************************//
    generate
        for(entry = 0;entry<`SNF_MSHR_ENTRIES_NUM;entry = entry+1) begin:recv_data_cnt_timing_logic
            always @(posedge clk or posedge rst) begin
                if (rst)begin
                    wdata_recv_cnt_q[entry] <= 2'b00;
                end
                else if (wdata_recv_update && (entry == wdata_recv_idx))begin
                    wdata_recv_cnt_q[entry] <= wdata_recv_cnt_next;
                end
                else if (dbf_mshr_rxdat_ok_sx && (entry == dbf_mshr_rxdat_ok_idx_sx))begin
                    wdata_recv_cnt_q[entry] <= 2'b00;
                end
            end
        end
    endgenerate

    always @(posedge clk or posedge rst) begin : recv_idx_timing_logic
        if (rst)begin
            wdata_rec_idx_sx_q <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if (wdata_recv_update)begin
            wdata_rec_idx_sx_q <= wdata_recv_idx;
        end
        else if (dbf_mshr_rxdat_ok_sx)begin
            wdata_rec_idx_sx_q <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
    end

    always @(posedge clk or posedge rst) begin : wrdata_cancel_idx_timing_logic
        if (rst)begin
            wdata_cancel_idx_sx_q <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else begin
            wdata_cancel_idx_sx_q <= wdata_rec_idx_sx_q;
        end
    end

    assign wdata_recv_update = rxdat_valid_s0 ;
    assign wdata_recv_idx  = rxdat_txnid_s0[`SNF_MSHR_ENTRIES_WIDTH-1:0];
    assign wdata_recv_cnt_next = wdata_recv_cnt_q[wdata_recv_idx] | wdata_recv_sx;
    assign wdata_cancel_recv_s0 = (rxdat_opcode_s0 == `CHIE_WRITEDATACANCEL);
    assign wdata_recv_sx = (wdata_recv_update == 1'b1) ? ((rxdat_dataid_s0 == 2'b00) ? 2'b01 : 2'b10) : 2'b00;
    assign wdata_recv_data_sx = (wdata_cancel_recv_s0 == 1'b0) ? ((rxdat_dataid_s0 == 2'b00) ? {{`CHIE_DAT_FLIT_DATA_WIDTH{1'b0}},rxdat_data_s0} : ((rxdat_dataid_s0 == 2'b10)? {rxdat_data_s0,{`CHIE_DAT_FLIT_DATA_WIDTH{1'b0}}} : {`CHIE_DAT_FLIT_DATA_WIDTH*2{1'b0}}))
                                                            : {`CHIE_DAT_FLIT_DATA_WIDTH*2{1'b0}};
    assign wdata_recv_be_sx = (wdata_cancel_recv_s0 == 1'b0) ? ((rxdat_dataid_s0 == 2'b00) ? {{`CHIE_DAT_FLIT_BE_WIDTH{1'b0}},rxdat_be_s0} : ((rxdat_dataid_s0 == 2'b10)? {rxdat_be_s0,{`CHIE_DAT_FLIT_BE_WIDTH{1'b0}}} : {`CHIE_DAT_FLIT_BE_WIDTH*2{1'b0}}))
                                                            : {`CHIE_DAT_FLIT_BE_WIDTH*2{1'b0}};


    assign dbf_mshr_rxdat_ok_sx = (((rxreq_alloc_size_s2_q[wdata_rec_idx_sx_q] == 3'b110) && (wdata_recv_cnt_q[wdata_rec_idx_sx_q] == 2'b11)) | ((rxreq_alloc_size_s2_q[wdata_rec_idx_sx_q] != 3'b110) && (|wdata_recv_cnt_q[wdata_rec_idx_sx_q])));
    assign dbf_mshr_rxdat_ok_idx_sx = wdata_rec_idx_sx_q;
    assign dbf_mshr_rxdat_cancel_sx = wdata_cancel_recv_s0 && dbf_mshr_rxdat_ok_sx;
    assign dbf_mshr_rxdat_cancel_idx_sx = wdata_cancel_idx_sx_q;

    //************************************************************************//
    //                      write data to AXI slave                           //
    //************************************************************************//
    always @(posedge clk or posedge rst)begin:wdata_fifo_set_vec_timing_logic
        if (rst)begin
                wdata_fifo_set_vec <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if (mshr_wdat_en_sx)begin
                wdata_fifo_set_vec <= ((wdata_fifo_set_vec + 1) == `SNF_MSHR_ENTRIES_NUM) ? 1'b0 : (wdata_fifo_set_vec + 1);
        end
    end

    always @(posedge clk or posedge rst)begin:wdata_fifo_get_vec_timing_logic
        if (rst)begin
                wdata_fifo_get_vec <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
        end
        else if (wvalid && wready && wlast)begin
                wdata_fifo_get_vec <= ((wdata_fifo_get_vec + 1) == `SNF_MSHR_ENTRIES_NUM) ? 1'b0 : (wdata_fifo_get_vec + 1);
        end
    end

    generate
        for(entry = 0;entry<`SNF_MSHR_ENTRIES_NUM;entry = entry+1) begin:wdata_fifo_set_timing_logic
            always @(posedge clk or posedge rst)begin
                if (rst)begin
                    wdata_fifo_valid_sx[entry]        <= 1'b0;
                    wdata_fifo_entry_idx_sx[entry]    <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
                end
                else if (mshr_wdat_en_sx && (entry == wdata_fifo_set_vec))begin
                    wdata_fifo_valid_sx[entry]        <= 1'b1;
                    wdata_fifo_entry_idx_sx[entry]    <= mshr_wdat_entry_idx_sx;
                end
                else if (wvalid && wready && wlast && (entry == wdata_fifo_get_vec))begin
                    wdata_fifo_valid_sx[entry]        <= 1'b0;
                    wdata_fifo_entry_idx_sx[entry]    <= {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};
                end
            end
        end
    endgenerate

    assign wvalid = wdata_fifo_valid_sx[wdata_fifo_get_vec];

    generate
        for(entry = 0;entry<`SNF_MSHR_ENTRIES_NUM;entry = entry+1) begin:dbf_wr_wlmask_update_timing_logic
            always @(posedge clk or posedge rst)begin:wr_wlmask_timing_logic
                if (rst)begin
                    wdata_wlmask_q[entry]    <= {`SNF_MASK_WL_WIDTH{1'b0}};
                end
                else if (rxreq_dbf_wr_s1 && rxreq_dbf_en_s1 && (entry == rxreq_dbf_entry_idx_s1))begin
                    wdata_wlmask_q[entry]    <= dbf_wlmask_s1_q;
                end
                else if (mshr_retired_valid_sx && (entry == mshr_retired_idx_sx))begin
                    wdata_wlmask_q[entry]    <= 4'b0000;
                end
                else begin
                    ;
                end
            end
        end
    endgenerate

    generate
        for(entry = 0;entry<`SNF_MSHR_ENTRIES_NUM;entry = entry+1) begin:dbf_wr_cdmask_update_timing_logic
            always @(posedge clk or posedge rst)begin:wr_cdmask_timing_logic
                if (rst)begin
                    wdata_cdmask_q[entry]  <= {`SNF_MASK_CD_WIDTH{1'b0}};
                end
                else if (rxreq_dbf_en_s1 && rxreq_dbf_wr_s1 && (entry == rxreq_dbf_entry_idx_s1))begin
                    wdata_cdmask_q[entry]  <= dbf_cdmask_s0;
                end
                else if (wdata_to_slave && (entry == wdata_to_slave_idx))begin
                    wdata_cdmask_q[entry]  <= wdata_cdmask_next;
                end
                else if (mshr_retired_valid_sx && (entry == mshr_retired_idx_sx))begin
                    wdata_cdmask_q[entry]  <= 4'b0000;
                end
                else begin
                    ;
                end
            end
        end
    endgenerate

    assign wdata_to_slave = wvalid & wready;
    assign wdata_to_slave_idx = wvalid ? wdata_fifo_entry_idx_sx[wdata_fifo_get_vec] : {`SNF_MSHR_ENTRIES_WIDTH{1'b0}};;
    assign wdata_cdmask_next = ((AXI_128) ? ((|(wdata_cdmask_q[wdata_to_slave_idx] <<1) != 0) ? (wdata_cdmask_q[wdata_to_slave_idx] <<1) : 4'b0001)
                                                : wdata_cdmask_q[wdata_to_slave_idx] ^ {4{1'b1}});
    assign wdata = (AXI_128) ? (({`AXI4_WDATA_WIDTH{wdata_cdmask_q[wdata_to_slave_idx][0]}} & dbf_data_q[wdata_to_slave_idx][0*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH])
                                        | ({`AXI4_WDATA_WIDTH{wdata_cdmask_q[wdata_to_slave_idx][1]}} & dbf_data_q[wdata_to_slave_idx][1*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH])
                                        | ({`AXI4_WDATA_WIDTH{wdata_cdmask_q[wdata_to_slave_idx][2]}} & dbf_data_q[wdata_to_slave_idx][2*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH])
                                        | ({`AXI4_WDATA_WIDTH{wdata_cdmask_q[wdata_to_slave_idx][3]}} & dbf_data_q[wdata_to_slave_idx][3*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH]))
                                      : (({`AXI4_WDATA_WIDTH/2{wdata_cdmask_q[wdata_to_slave_idx][1:0]}} & dbf_data_q[wdata_to_slave_idx][0*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH])
                                        | ({`AXI4_WDATA_WIDTH/2{wdata_cdmask_q[wdata_to_slave_idx][3:2]}} & dbf_data_q[wdata_to_slave_idx][1*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH]));

    assign wstrb = (AXI_128) ? (({`AXI4_WSTRB_WIDTH{wdata_cdmask_q[wdata_to_slave_idx][0]}} & dbf_be_q[wdata_to_slave_idx][0*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH])
                                        | ({`AXI4_WSTRB_WIDTH{wdata_cdmask_q[wdata_to_slave_idx][1]}} & dbf_be_q[wdata_to_slave_idx][1*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH])
                                        | ({`AXI4_WSTRB_WIDTH{wdata_cdmask_q[wdata_to_slave_idx][2]}} & dbf_be_q[wdata_to_slave_idx][2*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH])
                                        | ({`AXI4_WSTRB_WIDTH{wdata_cdmask_q[wdata_to_slave_idx][3]}} & dbf_be_q[wdata_to_slave_idx][3*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH]))
                                      : (({`AXI4_WSTRB_WIDTH/2{wdata_cdmask_q[wdata_to_slave_idx][1:0]}} & dbf_be_q[wdata_to_slave_idx][0*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH])
                                        | ({`AXI4_WSTRB_WIDTH/2{wdata_cdmask_q[wdata_to_slave_idx][3:2]}} & dbf_be_q[wdata_to_slave_idx][1*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH]));

    assign wlast = (wvalid == 1'b1) ? ((wdata_cdmask_q[wdata_to_slave_idx] == wdata_wlmask_q[wdata_to_slave_idx]) ? 1'b1 : 1'b0) : 1'b0;

endmodule
