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
*    Li Zhao <lizhao@bosc.ac.cn>
*    Nana Cai <cainana@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*    Xiaotian Cao <caoxiaotian@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "axi4_defines.v"
`include "hni_defines.v"
`include "hni_param.v"

module hni_data_buffer `HNI_PARAM 
    (
        clk,
        rst,

        rxdat_valid_s0,
        rxdatflit_s0,

        rxreq_dbf_en_s0,
        rxreq_dbf_axid_s0,
        rxreq_dbf_entry_idx_s0,
        rxreq_dbf_wr_s0,   //write txn
        rxreq_dbf_addr_s0,
        rxreq_dbf_device_s0,
        rxreq_dbf_size_s0,
        rxreq_dbf_axlen_s0,

        mshr_retired_valid_sx,
        mshr_retired_idx_sx,

        mshr_wdat_en_sx,    //send data to axi slave enable
        mshr_wdat_entry_idx_sx,

        mshr_rdat_en_sx,
        mshr_rdat_entry_idx_sx,

        mshr_txdat_en_sx,   //mshr allow dbf send data to chi xp
        mshr_txdat_tgtid_sx,
        mshr_txdat_txnid_sx,
        mshr_txdat_opcode_sx,
        mshr_txdat_resp_sx,
        mshr_txdat_resperr_sx,
        mshr_txdat_dbid_sx,
        mshr_txdat_dataid_sx,
        mshr_txdat_tracetag_sx,

        txdat_dbf_rdy_s1,
        txdat_dbf_won_sx,

        dbf_rxdat_valid_s0,
        dbf_rxdat_txnid_s0,
        dbf_rxdat_opcode_s0,
        dbf_rxdat_dataid_s0,

        dbf_rvalid_sx,
        dbf_rvalid_entry_idx_sx,
        dbf_cdmask_sx,
        w_last,

        dbf_txdat_valid_sx,
        txdat_flit,
        mshr_txdat_won_sx,

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

    //global inputs
    input wire                                      clk;
    input wire                                      rst;

    //input from hni_rxdat
    input wire                                      rxdat_valid_s0;
    input wire [`CHIE_DAT_FLIT_RANGE]               rxdatflit_s0;

    //inputs from hni_mshr
    input wire                                      rxreq_dbf_en_s0;
    input wire [`HNI_AXI4_AXID_WIDTH-1:0]           rxreq_dbf_axid_s0; //slave id
    input wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]        rxreq_dbf_entry_idx_s0; //allocate entry idx
    input wire                                      rxreq_dbf_wr_s0;   //write txn or read txn
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]      rxreq_dbf_addr_s0;
    input wire                                      rxreq_dbf_device_s0;
    input wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]      rxreq_dbf_size_s0;//rxdata/txdata size
    input wire [`AXI4_AWLEN_WIDTH-1:0]              rxreq_dbf_axlen_s0;

    input wire                                      mshr_retired_valid_sx;
    input wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]        mshr_retired_idx_sx;

    input wire                                      mshr_wdat_en_sx;    //send data to axi slave enable
    input wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]        mshr_wdat_entry_idx_sx;

    input wire                                      mshr_rdat_en_sx;   //rdat:mshr allow dbf receive data from AXI rdata
    input wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]        mshr_rdat_entry_idx_sx;

    input wire                                      mshr_txdat_en_sx;   //txdat:mshr allow dbf send data to chi xp
    input wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]     mshr_txdat_tgtid_sx;
    input wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]     mshr_txdat_txnid_sx;
    input wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]    mshr_txdat_opcode_sx;
    input wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]      mshr_txdat_resp_sx; 
    input wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]   mshr_txdat_resperr_sx;
    input wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]      mshr_txdat_dbid_sx; 
    input wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]    mshr_txdat_dataid_sx;
    input wire [`CHIE_DAT_FLIT_TRACETAG_WIDTH-1:0]  mshr_txdat_tracetag_sx;

    //input from hni_txdat
    input wire                                      txdat_dbf_rdy_s1; //txdat:handshake between txdat and dbf
    input wire                                      txdat_dbf_won_sx;

    //outputs to hni_mshr
    output wire                                     dbf_rxdat_valid_s0;
    output wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]    dbf_rxdat_txnid_s0;
    output wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]   dbf_rxdat_opcode_s0;
    output wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]   dbf_rxdat_dataid_s0; 

    output wire                                     dbf_rvalid_sx;
    output reg [`HNI_MSHR_ENTRIES_WIDTH-1:0]        dbf_rvalid_entry_idx_sx;
    output wire [3:0]                               dbf_cdmask_sx;
    output wire                                     mshr_txdat_won_sx;
    output wire                                     w_last;

    //output to hni_txdat
    output wire                                     dbf_txdat_valid_sx;//txdat:handshake between txdat and dbf
    output reg  [`CHIE_DAT_FLIT_RANGE]              txdat_flit; //txdat

    //inout with axi slaves
    input  wire [10:0]                              rid;
    input  wire [`AXI4_RDATA_WIDTH-1:0]             rdata;
    input  wire [1:0]                               rresp;
    input  wire                                     rlast;
    input  wire                                     rvalid;
    output wire                                     rready;

    output reg [`AXI4_WDATA_WIDTH-1:0]              wdata;
    output reg [`AXI4_WSTRB_WIDTH-1:0]              wstrb;
    output reg                                      wlast;
    output wire                                     wvalid;
    input  wire                                     wready;

    //internal signals
    reg [`HNI_MASK_WL_RANGE]                 dbf_wlmask_s0;
    reg [`HNI_MASK_CD_RANGE]                 dbf_rd_cdmask_q[0:`HNI_MSHR_ENTRIES_NUM-1];
    reg [`HNI_MASK_WL_RANGE]                 dbf_rd_wlmask_q[0:`HNI_MSHR_ENTRIES_NUM-1];
    reg [`HNI_MASK_CD_RANGE]                 dbf_wr_cdmask_q[0:`HNI_MSHR_ENTRIES_NUM-1]; 
    reg [`HNI_MASK_WL_RANGE]                 dbf_wr_wlmask_q[0:`HNI_MSHR_ENTRIES_NUM-1]; 
    reg [1:0]                                rxreq_alloc_ccid_q[0:`HNI_MSHR_ENTRIES_NUM-1];
    reg [`HNI_AXI4_AXID_WIDTH-1:0]           rxreq_alloc_axid_q[0:`HNI_MSHR_ENTRIES_NUM-1];
    reg [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]      rxreq_alloc_size_q[0:`HNI_MSHR_ENTRIES_NUM-1];
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]          rready_q;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]          rready_rst_q;
    reg [1:0]                                rresp_q[0:`HNI_MSHR_ENTRIES_NUM-1];
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]          rxreq_dbf_wr_q;
    reg [`AXI4_RDATA_WIDTH*4-1:0]            rdata_receive;
    reg [10:0]                               axid_current;
    reg [`HNI_MASK_CD_RANGE]                 rd_cdmask_current;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]    dbf_data_q[0:`HNI_MSHR_ENTRIES_NUM-1];
    reg [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]      dbf_be_q[0:`HNI_MSHR_ENTRIES_NUM-1];
    reg                                      dbf_rvalid_q;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]      mshr_txdat_data_sx;
    reg [`CHIE_DAT_FLIT_BE_WIDTH-1:0]        mshr_txdat_be_sx;
    reg [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]    mshr_txdat_dataid_q;
    reg [`CHIE_DAT_FLIT_CCID_WIDTH-1:0]      mshr_txdat_ccid_sx;
    reg [`HNI_MSHR_ENTRIES_NUM-1:0]          wvalid_q;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]    wdata_current;
    reg [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]      wstrb_current;
    reg [`HNI_MASK_CD_RANGE]                 wr_cdmask_current;
    reg [`HNI_MASK_WL_RANGE]                 wr_wlmask_current;

    wire                                     rxdatflit_valid_s0;
    wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]    rxdat_txnid_s0;
    wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]   rxdat_opcode_s0;
    wire [`CHIE_DAT_FLIT_BE_WIDTH-1:0]       rxdat_be_s0;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]   rxdat_dataid_s0;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]     rxdat_data_s0;
    wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]       rxdat_entry_idx_s0;
    wire                                     align_256b_ccid_01_len_1;
    wire                                     align_256b_ccid_11_len_1;
    wire                                     align_256b_ccid_11_len_2;
    wire                                     align_256b_ccid_11_len_4;
    wire                                     align_256b_ccid_10_len_4;
    wire [`HNI_MASK_CD_RANGE]                dbf_cdmask_s0; 
    wire                                     rready_rst;
    wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]       txdat_entry_idx_sx;

    //rxdat decode
    assign rxdatflit_valid_s0  = rxdat_valid_s0;
    assign rxdat_txnid_s0  = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_TXNID_RANGE]  : {`CHIE_DAT_FLIT_TXNID_WIDTH{1'b0}};
    assign rxdat_opcode_s0 = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_OPCODE_RANGE] : {`CHIE_DAT_FLIT_OPCODE_WIDTH{1'b0}};//NONCOPYBACKWRDATA/NCBWRDATACOMPACK
    assign rxdat_be_s0     = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_BE_RANGE]     : {`CHIE_DAT_FLIT_BE_WIDTH{1'b0}};
    assign rxdat_dataid_s0 = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_DATAID_RANGE] : {`CHIE_DAT_FLIT_DATAID_WIDTH{1'b0}};
    assign rxdat_data_s0   = (rxdat_valid_s0 == 1'b1) ? rxdatflit_s0[`CHIE_DAT_FLIT_DATA_RANGE]   : {`CHIE_DAT_FLIT_DATA_WIDTH{1'b0}};

    assign rxdat_entry_idx_s0  = rxdat_txnid_s0[`HNI_MSHR_ENTRIES_WIDTH-1:0];

    assign dbf_rxdat_valid_s0  = rxdatflit_valid_s0;
    assign dbf_rxdat_txnid_s0  = rxdat_txnid_s0;
    assign dbf_rxdat_opcode_s0 = rxdat_opcode_s0;
    assign dbf_rxdat_dataid_s0 = rxdat_dataid_s0;

    //CCID = addr[5:4] - For a data bus width of 256 bits only the most significant CCID and DataID bits(msb) 
    //       must match for the critical chunk.
    // cdmask - Chunk dispatch mask - indicates the 128b data beat to be sent next
    //     As each data beat is sent, the mask is rotated left to point to
    //     the next data beat
    // wlmask - WLast mask - indicates the last data beat
    // rdmask - Received data mask - indicates which data beats have been received 
    // pdmask - Pending data mask - indicates which data beats have not been sent 
    //      initialized to 1 for beats that need to be sent. As each beat is sent, the
    //      corresponding bit is cleared
    assign align_256b_ccid_01_len_1 = (rxreq_dbf_addr_s0[5:4] == 2'b01) && (rxreq_dbf_axlen_s0 == 8'b00);
    assign align_256b_ccid_11_len_1 = (rxreq_dbf_addr_s0[5:4] == 2'b11) && (rxreq_dbf_axlen_s0 == 8'b00);
    assign align_256b_ccid_11_len_2 = (rxreq_dbf_addr_s0[5:4] == 2'b11) && (rxreq_dbf_axlen_s0 == 8'b01);
    assign align_256b_ccid_11_len_4 = (rxreq_dbf_addr_s0[5:4] == 2'b11) && (rxreq_dbf_axlen_s0 == 8'b11);
    assign align_256b_ccid_10_len_4 = (rxreq_dbf_addr_s0[5:4] == 2'b10) && (rxreq_dbf_axlen_s0 == 8'b11);

    assign dbf_cdmask_s0 =(rxreq_dbf_device_s0 == 1'b1) ? ((rxreq_dbf_addr_s0[5:4] == 2'b00) ? 4'b0001 
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b01) ? 4'b0010 
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b10) ? 4'b0100
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b11) ? 4'b1000 : 4'b0000))))
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b00) ? 4'b0001 // normal memory
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b01 && align_256b_ccid_01_len_1) ? 4'b0010 
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b01 && ~align_256b_ccid_01_len_1) ? 4'b0001
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b10 && align_256b_ccid_10_len_4) ? 4'b0001
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b10 && ~align_256b_ccid_10_len_4) ? 4'b0100
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b11 && align_256b_ccid_11_len_1) ? 4'b1000
                            : ((rxreq_dbf_addr_s0[5:4] == 2'b11 && align_256b_ccid_11_len_2) ? 4'b0100 
			                : ((rxreq_dbf_addr_s0[5:4] == 2'b11 && align_256b_ccid_11_len_4) ? 4'b0001 : 4'b0000)))))))); 
                        
    always @* begin: dbf_wlmask_comb_logic
        if(rxreq_dbf_device_s0)begin
            case(rxreq_dbf_addr_s0[5:4])
                2'b00:begin
                    case(rxreq_dbf_axlen_s0)
                        8'b00:begin
                            dbf_wlmask_s0 = 4'b0001;
                        end
                        8'b01:begin
                            dbf_wlmask_s0 = 4'b0010;
                        end
                        8'b10:begin//not happen
                            dbf_wlmask_s0 = 4'b0100;
                        end
                        8'b11:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        default:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                    endcase
                end
                2'b01:begin
                    case(rxreq_dbf_axlen_s0)
                        8'b00:begin
                            dbf_wlmask_s0 = 4'b0010;
                        end
                        8'b01:begin //not happen
                            dbf_wlmask_s0 = 4'b0100;
                        end
                        8'b10:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b11:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        default:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                    endcase
                end
                2'b10:begin
                    case(rxreq_dbf_axlen_s0)
                        8'b00:begin
                            dbf_wlmask_s0 = 4'b0100;
                        end
                        8'b01:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b10:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b11:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        default:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                    endcase
                end
                2'b11:begin
                    case(rxreq_dbf_axlen_s0)
                        8'b00:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b01:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b10:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b11:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        default:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                    endcase
                end
                default:begin
                    dbf_wlmask_s0 = 4'b1000;
                end
            endcase
        end
        else begin//normal memory
            case(rxreq_dbf_addr_s0[5:4])
                2'b00:begin
                    case(rxreq_dbf_axlen_s0)
                        8'b00:begin
                            dbf_wlmask_s0 = 4'b0001;
                        end
                        8'b01:begin
                            dbf_wlmask_s0 = 4'b0010;
                        end
                        8'b10:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b11:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        default:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                    endcase
                end
                2'b01:begin
                    case(rxreq_dbf_axlen_s0)
                        8'b00:begin
                            dbf_wlmask_s0 = 4'b0010;//cd=0010
                        end
                        8'b01:begin
                            dbf_wlmask_s0 = 4'b0010;//cd=0001
                        end
                        8'b10:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b11:begin
                            dbf_wlmask_s0 = 4'b1000;//cd=0001
                        end
                        default:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                    endcase
                end
                2'b10:begin
                    case(rxreq_dbf_axlen_s0)
                        8'b00:begin
                            dbf_wlmask_s0 = 4'b0100;//cd=0100
                        end
                        8'b01:begin
                            dbf_wlmask_s0 = 4'b1000;//cd=0100
                        end
                        8'b10:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b11:begin
                            dbf_wlmask_s0 = 4'b1000;//cd=0001
                        end
                        default:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                    endcase
                end
                2'b11:begin
                    case(rxreq_dbf_axlen_s0)
                        8'b00:begin
                            dbf_wlmask_s0 = 4'b1000;//cd=1000
                        end
                        8'b01:begin
                            dbf_wlmask_s0 = 4'b1000;//cd=0100
                        end
                        8'b10:begin //not happen
                            dbf_wlmask_s0 = 4'b1000;
                        end
                        8'b11:begin
                            dbf_wlmask_s0 = 4'b1000;//cd=0001
                        end
                        default:begin
                            dbf_wlmask_s0 = 4'b1000;
                        end
                    endcase
                end
            endcase
        end
    end

    genvar i;
    integer entry,j;
    generate
       for(i = 0;i<`HNI_MSHR_ENTRIES_NUM;i = i+1) begin:req_alloc_info_timing_logic
        //rxreq allocate info
            always@(posedge clk or posedge rst)begin:ccid_axid_timing_logic
                if(rst)begin
                    rxreq_alloc_axid_q[i]     <= {`HNI_AXI4_AXID_WIDTH{1'b0}};
                    rxreq_alloc_ccid_q[i]     <= 2'b0;
                    rxreq_alloc_size_q[i]     <= 3'b0;
                end
                else if(rxreq_dbf_en_s0 && i == rxreq_dbf_entry_idx_s0)begin
                    rxreq_alloc_axid_q[i]     <= rxreq_dbf_axid_s0;
                    rxreq_alloc_ccid_q[i]     <= rxreq_dbf_addr_s0[5:4];
                    rxreq_alloc_size_q[i]     <= rxreq_dbf_size_s0;
                end
                else if(mshr_retired_valid_sx && i == mshr_retired_idx_sx)begin
                    rxreq_alloc_axid_q[i]     <= {`HNI_AXI4_AXID_WIDTH{1'b0}};
                    rxreq_alloc_ccid_q[i]     <= 2'b0;
                    rxreq_alloc_size_q[i]     <= 3'b0;
                end
            end

            always@(posedge clk or posedge rst)begin:rxreq_wr_timing_logic
                if(rst)begin
                    rxreq_dbf_wr_q[i] <= 1'b0;
                end
                else if(rxreq_dbf_wr_s0 && rxreq_dbf_en_s0 && i == rxreq_dbf_entry_idx_s0)begin
                    rxreq_dbf_wr_q[i] <= 1'b1;
                end
                else if(mshr_retired_valid_sx && i == mshr_retired_idx_sx)begin
                    rxreq_dbf_wr_q[i] <= 1'b0;
                end
            end

            always@(posedge clk or posedge rst)begin:rready_timing_logic
                if(rst)begin
                    rready_q[i] <= 1'b0;
                end
                else if(mshr_rdat_en_sx && i == mshr_rdat_entry_idx_sx)begin
                    rready_q[i] <= 1'b1;
                end
                else if(rvalid && rready && rlast && rready_q[i] && (rid == rxreq_alloc_axid_q[i]))begin//same axid be sleep
                    rready_q[i] <= 1'b0;
                end
            end

            always@(posedge clk or posedge rst)begin:rresp_timing_logic
                if(rst)begin
                    rresp_q[i] <= 2'b0;
                end
                else if(rvalid && rready && rready_q[i] && (rid == rxreq_alloc_axid_q[i]))begin
                    rresp_q[i] <= rresp;
                end
                else if(mshr_retired_valid_sx && i == mshr_retired_idx_sx)begin
                    rresp_q[i] <= 2'b0;
                end
            end
       end
    endgenerate

    //AXI R Channel
    assign rready     = |rready_q & (~rready_rst);

    generate
        for(i = 0;i<`HNI_MSHR_ENTRIES_NUM;i = i+1) begin:dbf_rd_mask_timing_logic
        //AXI RDATA
            always@(posedge clk or posedge rst)begin
                if(rst)begin
                    dbf_rd_cdmask_q[i]    <= {`HNI_MASK_CD_WIDTH{1'b0}};
                    dbf_rd_wlmask_q[i]    <= {`HNI_MASK_WL_WIDTH{1'b0}};
                end
                else if(rxreq_dbf_en_s0 && i == rxreq_dbf_entry_idx_s0 && !rxreq_dbf_wr_s0)begin
                    dbf_rd_cdmask_q[i]    <= dbf_cdmask_s0;
                    dbf_rd_wlmask_q[i]    <= dbf_wlmask_s0;
                end
                else if (rvalid && rready && rready_q[i] && (rid == rxreq_alloc_axid_q[i])) begin
                    if((dbf_rd_cdmask_q[i] == dbf_rd_wlmask_q[i]) && rlast)begin
                        dbf_rd_cdmask_q[i]    <= {`HNI_MASK_CD_WIDTH{1'b0}};
                        dbf_rd_wlmask_q[i]    <= {`HNI_MASK_WL_WIDTH{1'b0}};
                    end
                    else begin
                        if(dbf_rd_cdmask_q[i] == 4'b0001)begin
                            dbf_rd_cdmask_q[i] <= 4'b0010;
                        end
                        else if(dbf_rd_cdmask_q[i] == 4'b0010)begin
                            dbf_rd_cdmask_q[i] <= 4'b0100;
                        end
                        else if(dbf_rd_cdmask_q[i] == 4'b0100)begin
                            dbf_rd_cdmask_q[i] <= 4'b1000;
                        end
                        else if(dbf_rd_cdmask_q[i] == 4'b1000)begin
                            dbf_rd_cdmask_q[i] <= 4'b0000;
                        end
                    end
                end
                else begin
                    dbf_rd_cdmask_q[i] <=  dbf_rd_cdmask_q[i];
                    dbf_rd_wlmask_q[i] <=  dbf_rd_wlmask_q[i];
                end
            end
        end
    endgenerate

    always@(*)begin: current_rd_mask_axid_comb_logic
        rd_cdmask_current = {`HNI_MASK_CD_WIDTH{1'b0}};
        axid_current = 11'b0;
        for(entry=0; entry<`HNI_MSHR_ENTRIES_NUM; entry = entry+1)begin
            if (rready_q[entry] && rvalid && (rid == rxreq_alloc_axid_q[entry]))begin
                rd_cdmask_current = dbf_rd_cdmask_q[entry];    
                axid_current = rxreq_alloc_axid_q[entry];
            end
        end
    end

    always@(*) begin:receive_rdata_comb_logic          
        rdata_receive = {`AXI4_RDATA_WIDTH*4{1'b0}};
        if (rvalid && rready && (rid == axid_current)) begin
            for(j=0;j<4;j=j+1) begin
                if(rd_cdmask_current[j] == 1)begin
                    rdata_receive[j*`AXI4_RDATA_WIDTH+:`AXI4_RDATA_WIDTH] = rdata;
                end
            end
        end
    end

    //Data buffer 
    generate
        for(i = 0;i<`HNI_MSHR_ENTRIES_NUM;i = i+1) begin:dbf_receive_data_timing_logic
            always@(posedge clk or posedge rst)begin
                if(rst)begin
                    dbf_data_q[i] <= {`CHIE_DAT_FLIT_DATA_WIDTH*2{1'b0}};
                    dbf_be_q[i]   <= {`CHIE_DAT_FLIT_BE_WIDTH*2{1'b0}};
                end
                else begin
                    if (mshr_retired_valid_sx && i == mshr_retired_idx_sx) begin//entry retired
                        dbf_data_q[i] <= {`CHIE_DAT_FLIT_DATA_WIDTH*2{1'b0}};
                        dbf_be_q[i]   <= {`CHIE_DAT_FLIT_BE_WIDTH*2{1'b0}};
                    end
                    else if (rxdat_valid_s0 && rxreq_dbf_wr_q[i] && (i == rxdat_entry_idx_s0))begin
                        if(rxdat_dataid_s0 == 2'b00)begin
                            dbf_data_q[i][`CHIE_DAT_FLIT_DATA_WIDTH-1:0] <= rxdat_data_s0[`CHIE_DAT_FLIT_DATA_WIDTH-1:0];
                            dbf_be_q[i][`CHIE_DAT_FLIT_BE_WIDTH-1:0]     <= rxdat_be_s0[`CHIE_DAT_FLIT_BE_WIDTH-1:0] | dbf_be_q[i][`CHIE_DAT_FLIT_BE_WIDTH-1:0];
                        end
                        else if(rxdat_dataid_s0 == 2'b10)begin
                            dbf_data_q[i][`CHIE_DAT_FLIT_DATA_WIDTH*2-1:`CHIE_DAT_FLIT_DATA_WIDTH] <= rxdat_data_s0[`CHIE_DAT_FLIT_DATA_WIDTH-1:0];
                            dbf_be_q[i][`CHIE_DAT_FLIT_BE_WIDTH*2-1:`CHIE_DAT_FLIT_BE_WIDTH]     <= rxdat_be_s0[`CHIE_DAT_FLIT_BE_WIDTH-1:0] | dbf_be_q[i][`CHIE_DAT_FLIT_BE_WIDTH*2-1:`CHIE_DAT_FLIT_BE_WIDTH];
                        end
                    end
                    else if(rvalid && rready && rready_q[i] && (rid == rxreq_alloc_axid_q[i]))begin
                        dbf_data_q[i] <= rdata_receive | dbf_data_q[i];
                    end
                end
            end
        //special case:when size is equal to 6 and ccid is equal to 11 or 10, txdatflit needs to be sent twice,the one is all zero, the other is from rdata.
            always@(posedge clk)begin
                if(rxreq_alloc_size_q[i] == 3'b110 && rxreq_alloc_ccid_q[i][1] == 1'b1 && rvalid && rready && rready_q[i] && rid == rxreq_alloc_axid_q[i] && rlast)
                    rready_rst_q[i] <= 1'b1;
                else 
                    rready_rst_q[i] <= 1'b0; 
            end
        end
    endgenerate

    assign rready_rst    = |rready_rst_q;
    
    always@(*)begin: dbf_rvalid_comb_logic
        dbf_rvalid_entry_idx_sx = {`HNI_MSHR_ENTRIES_WIDTH{1'b0}};
        for(entry=0; entry<`HNI_MSHR_ENTRIES_NUM; entry = entry+1)begin
            if (rvalid && rready && rready_q[entry] && (rid == rxreq_alloc_axid_q[entry]))begin
                dbf_rvalid_entry_idx_sx = entry;
            end
        end
    end

    assign dbf_rvalid_sx = rvalid & rready;
    assign dbf_cdmask_sx = {`HNI_MASK_CD_WIDTH{dbf_rvalid_sx}} & dbf_rd_cdmask_q[dbf_rvalid_entry_idx_sx];

    //write data to CHI TXDAT
    assign dbf_txdat_valid_sx = mshr_txdat_en_sx;
    assign txdat_entry_idx_sx = mshr_txdat_dbid_sx[`HNI_MSHR_ENTRIES_WIDTH-1:0];

    always@(*)begin:txdat_data_and_be_comb_logic
        mshr_txdat_data_sx   = {`CHIE_DAT_FLIT_DATA_WIDTH{1'b0}};
        mshr_txdat_be_sx     = {`CHIE_DAT_FLIT_BE_WIDTH{1'b0}};
        mshr_txdat_ccid_sx  = 2'b0;
        if(mshr_txdat_en_sx && txdat_dbf_rdy_s1)begin
            for(entry = 0;entry<`HNI_MSHR_ENTRIES_NUM;entry = entry+1) begin:txdata
                if(entry == txdat_entry_idx_sx)begin
                    mshr_txdat_ccid_sx = rxreq_alloc_ccid_q[entry];
                    if(mshr_txdat_dataid_sx == 2'b00)begin
                        mshr_txdat_data_sx   = dbf_data_q[entry][`CHIE_DAT_FLIT_DATA_WIDTH-1:0];
                        mshr_txdat_be_sx     = {`CHIE_DAT_FLIT_BE_WIDTH{1'b1}};
                    end
                    else if(mshr_txdat_dataid_sx == 2'b10)begin
                        mshr_txdat_data_sx   = dbf_data_q[entry][`CHIE_DAT_FLIT_DATA_WIDTH*2-1:`CHIE_DAT_FLIT_DATA_WIDTH];
                        mshr_txdat_be_sx     = {`CHIE_DAT_FLIT_BE_WIDTH{1'b1}};
                    end
                end
            end
        end
    end

    generate
        if(CHIE_DAT_RSVDC_WIDTH_PARAM != 0)begin
            always @*begin
                txdat_flit[`CHIE_DAT_FLIT_RSVDC_RANGE]    = {`CHIE_DAT_FLIT_RSVDC_WIDTH{1'b0}};
            end
        end
    endgenerate

    //data to txdat
    always@(*)begin:txdat_package_comb_logic
        txdat_flit[`CHIE_DAT_FLIT_QOS_RANGE]       = {`CHIE_DAT_FLIT_QOS_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_TGTID_RANGE]     = mshr_txdat_tgtid_sx;
        txdat_flit[`CHIE_DAT_FLIT_SRCID_RANGE]     = `HNI0_ID;
        txdat_flit[`CHIE_DAT_FLIT_TXNID_RANGE]     = mshr_txdat_txnid_sx;
        txdat_flit[`CHIE_DAT_FLIT_HOMENID_RANGE]   = (mshr_txdat_opcode_sx == `CHIE_COMPDATA)?`HNI0_ID : {`CHIE_DAT_FLIT_HOMENID_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_OPCODE_RANGE]    = mshr_txdat_opcode_sx;
        txdat_flit[`CHIE_DAT_FLIT_RESPERR_RANGE]   = (rresp_q[txdat_entry_idx_sx] == 2'b10) ? 2'b10 : mshr_txdat_resperr_sx;
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
        txdat_flit[`CHIE_DAT_FLIT_BE_RANGE]        = mshr_txdat_be_sx;
        txdat_flit[`CHIE_DAT_FLIT_DATA_RANGE]      = mshr_txdat_data_sx;
        txdat_flit[`CHIE_DAT_FLIT_DATACHECK_RANGE] = {`CHIE_DAT_FLIT_DATACHECK_WIDTH{1'b0}};
        txdat_flit[`CHIE_DAT_FLIT_POISON_RANGE]    = {`CHIE_DAT_FLIT_POISON_WIDTH{1'b0}};
    end

    //from txdat
    assign mshr_txdat_won_sx = txdat_dbf_won_sx;

    generate
        for(i = 0;i<`HNI_MSHR_ENTRIES_NUM;i = i+1) begin:temp_wvalid_timing_logic
            always@(posedge clk or posedge rst)begin
                if(rst)begin
                    wvalid_q[i] <= 1'b0;
                end
                else if(mshr_wdat_en_sx && (i == mshr_wdat_entry_idx_sx))begin
                    wvalid_q[i] <= 1'b1;
                end
                else if(wlast && wready)begin
                    wvalid_q[i] <= 1'b0;
                end
            end
        end
    endgenerate

    assign wvalid = |wvalid_q;

    always@(*)begin: current_wr_mask_wdata_wstrb_comb_logic
        wr_cdmask_current = {`HNI_MASK_CD_WIDTH{1'b0}};
        wr_wlmask_current = {`HNI_MASK_WL_WIDTH{1'b0}};
        wdata_current = {`CHIE_DAT_FLIT_DATA_WIDTH*2{1'b0}};
        wstrb_current = {`CHIE_DAT_FLIT_BE_WIDTH*2{1'b0}};
        for(entry=0; entry<`HNI_MSHR_ENTRIES_NUM; entry = entry+1)begin
            if (wvalid_q[entry])begin
                wr_cdmask_current = dbf_wr_cdmask_q[entry];
                wr_wlmask_current = dbf_wr_wlmask_q[entry];
                wdata_current = dbf_data_q[entry];
                wstrb_current = dbf_be_q[entry];
            end
        end
    end

    //write data to AXI slave
    generate
        for(i = 0;i<`HNI_MSHR_ENTRIES_NUM;i = i+1) begin:dbf_wr_mask_timing_logic
            always@(posedge clk or posedge rst)begin
                if(rst)begin
                    dbf_wr_wlmask_q[i]    <= {`HNI_MASK_WL_WIDTH{1'b0}};
                    dbf_wr_cdmask_q[i]    <= {`HNI_MASK_CD_WIDTH{1'b0}};
                end
                else if(rxreq_dbf_wr_s0 && rxreq_dbf_en_s0 && i == rxreq_dbf_entry_idx_s0)begin
                    dbf_wr_wlmask_q[i]    <= dbf_wlmask_s0;
                    dbf_wr_cdmask_q[i]    <= dbf_cdmask_s0;
                end
                else if(wvalid_q[i] && wready)begin
                    if(dbf_wr_cdmask_q[i] == dbf_wr_wlmask_q[i])begin
                        dbf_wr_wlmask_q[i]    <= {`HNI_MASK_WL_WIDTH{1'b0}};
                        dbf_wr_cdmask_q[i]    <= {`HNI_MASK_CD_WIDTH{1'b0}};
                    end
                    else begin
                        if(dbf_wr_cdmask_q[i] == 4'b0001)begin
                            dbf_wr_cdmask_q[i] <= 4'b0010;
                        end
                        else if(dbf_wr_cdmask_q[i] == 4'b0010)begin
                            dbf_wr_cdmask_q[i] <= 4'b0100;
                        end
                        else if(dbf_wr_cdmask_q[i] == 4'b0100)begin
                            dbf_wr_cdmask_q[i] <= 4'b1000;
                        end
                         else if(dbf_wr_cdmask_q[i] == 4'b1000)begin
                            dbf_wr_cdmask_q[i] <= 4'b0000;
                        end
                    end
                end
                else begin
                    dbf_wr_wlmask_q[i]    <= dbf_wr_wlmask_q[i];
                    dbf_wr_cdmask_q[i]    <= dbf_wr_cdmask_q[i];
                end
            end
        end
    endgenerate

    always@(*) begin:send_data_to_slave_comb_logic
        wdata = {`AXI4_WDATA_WIDTH{1'b0}};
        wstrb = {`AXI4_WSTRB_WIDTH{1'b0}};
        wlast = 1'b0;
        if(wvalid)begin
            if(wr_cdmask_current == wr_wlmask_current)begin
                wlast = 1'b1;
                for(j=0;j<4;j=j+1) begin
                    if(wr_cdmask_current[j] == 1)begin
                        wdata = wdata_current[j*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH];
                        wstrb = wstrb_current[j*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH];
                    end
                end
            end
            else begin
                if(wr_cdmask_current == 4'b0001)begin
                    wdata = wdata_current[0*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH];
                    wstrb = wstrb_current[0*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH];
                end
                else if(wr_cdmask_current == 4'b0010)begin
                    wdata = wdata_current[1*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH];
                    wstrb = wstrb_current[1*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH];
                end
                else if(wr_cdmask_current == 4'b0100)begin
                    wdata = wdata_current[2*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH];
                    wstrb = wstrb_current[2*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH];
                end
                else if(wr_cdmask_current == 4'b1000)begin
                    wdata = wdata_current[3*`AXI4_WDATA_WIDTH+:`AXI4_WDATA_WIDTH];
                    wstrb = wstrb_current[3*`AXI4_WSTRB_WIDTH+:`AXI4_WSTRB_WIDTH];
                end
            end
        end
    end

    assign w_last = wvalid && wready && wlast;

endmodule
