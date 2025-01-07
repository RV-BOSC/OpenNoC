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
*    Guo Bing <guobing@bosc.ac.cn>
*    Nana Cai <cainana@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_link_txdat_wrap `HNF_PARAM
    (
        //global inputs
        clk,
        rst,

        //inputs from link
        txdat_lcrdv,

        //inputs from hnf_mshr
        mshr_txdat_tgtid_sx2,
        mshr_txdat_txnid_sx2,
        mshr_txdat_opcode_sx2,
        mshr_txdat_resp_sx2,
        mshr_txdat_resperr_sx2,
        mshr_txdat_dbid_sx2,

        //inputs from hnf_data_buffer
        dbf_txdat_data_sx1,
        dbf_txdat_idx_sx1,
        dbf_txdat_be_sx1,
        dbf_txdat_valid_sx1,
        dbf_txdat_pe_sx1,

        //outputs to hnf_link
        txdatflitv,
        txdatflit,
        txdatflitpend,

        //outputs to hnf_mshr
        txdat_mshr_clr_dbf_busy_valid_sx3,
        txdat_mshr_clr_dbf_busy_idx_sx3,
        txdat_mshr_rd_idx_sx2,
        txdat_mshr_busy_sx
    );

    //global inputs
    input wire                                    clk;
    input wire                                    rst;

    //inputs from hnf_link
    input wire                                    txdat_lcrdv;

    //inputs from hnf_mshr
    input wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]   mshr_txdat_tgtid_sx2;
    input wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]   mshr_txdat_txnid_sx2;
    input wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]  mshr_txdat_opcode_sx2;
    input wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]    mshr_txdat_resp_sx2;
    input wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0] mshr_txdat_resperr_sx2;
    input wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]    mshr_txdat_dbid_sx2;

    //inputs from hnf_data_buffer
    input wire                                    dbf_txdat_valid_sx1;
    input wire [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]  dbf_txdat_data_sx1;
    input wire [`MSHR_ENTRIES_WIDTH-1:0]          dbf_txdat_idx_sx1;
    input wire [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]    dbf_txdat_be_sx1;
    input wire [1:0]                              dbf_txdat_pe_sx1;

    //outputs to hnf_link
    output reg                                    txdatflitv;
    output reg  [`CHIE_DAT_FLIT_RANGE]            txdatflit;
    output wire                                   txdatflitpend;

    //outputs to hnf_mshr
    output reg                                    txdat_mshr_clr_dbf_busy_valid_sx3;
    output reg  [`MSHR_ENTRIES_WIDTH-1:0]         txdat_mshr_clr_dbf_busy_idx_sx3;
    output wire [`MSHR_ENTRIES_WIDTH-1:0]         txdat_mshr_rd_idx_sx2;
    output wire                                   txdat_mshr_busy_sx;

    //internal reg signals
    reg [`CHIE_DAT_FLIT_RANGE]                    txdatflit_mshr_s0;
    reg                                           dbf_txdat_valid_entry1_sx;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]         dbf_txdat_data_entry1_sx;
    reg [`MSHR_ENTRIES_WIDTH-1:0]                 dbf_txdat_idx_entry1_sx;
    reg [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]           dbf_txdat_be_entry1_sx;
    reg [1:0]                                     dbf_txdat_pe_entry1_sx;
    reg                                           dbf_txdat_valid_entry2_sx;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH*2-1:0]         dbf_txdat_data_entry2_sx;
    reg [`MSHR_ENTRIES_WIDTH-1:0]                 dbf_txdat_idx_entry2_sx;
    reg [`CHIE_DAT_FLIT_BE_WIDTH*2-1:0]           dbf_txdat_be_entry2_sx;
    reg [1:0]                                     dbf_txdat_pe_entry2_sx;
    reg [`HNF_LCRD_DAT_CNT_WIDTH-1:0]             txdat_crd_cnt_q;
    reg [`HNF_LCRD_DAT_CNT_WIDTH-1:0]             dat_crd_cnt_ns_s0;
    reg                                           dbf_txdat_valid_entry2_sx_ns;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]        mshr_txdat_dataid_sx_ns;
    reg [`CHIE_DAT_FLIT_BE_WIDTH-1:0]             mshr_txdat_be_sx_ns;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]           mshr_txdat_data_sx_ns;

    //internal wire signals
    wire                                          dat_crd_cnt_not_zero_sx;
    wire                                          txdat_crd_avail_s1;
    wire                                          txdat_busy_sx;
    wire                                          txdatcrdv_s0;
    wire                                          txdat_crd_cnt_inc_sx;
    wire                                          txdat_req_s0;
    wire [`CHIE_DAT_FLIT_RANGE]                   txdatflit_s0;
    wire                                          txdatflitv_s0;
    wire                                          txdat_crd_cnt_dec_sx;
    wire                                          update_dat_crd_cnt_s0;
    wire [`HNF_LCRD_DAT_CNT_WIDTH-1:0]            dat_crd_cnt_s1;
    wire [`HNF_LCRD_DAT_CNT_WIDTH-1:0]            dat_crd_cnt_inc_s0;
    wire [`HNF_LCRD_DAT_CNT_WIDTH-1:0]            dat_crd_cnt_dec_s0;
    wire                                          dbf_txdat_entry1_dealloc_sx;
    wire                                          dbf_txdat_entry2_dealloc_sx;

    //main function
    assign dat_crd_cnt_not_zero_sx = (txdat_crd_cnt_q != 'd0);
    assign txdat_crd_avail_s1      = (txdat_lcrdv | dat_crd_cnt_not_zero_sx);
    assign txdat_busy_sx           = ~txdat_crd_avail_s1;

    assign txdatcrdv_s0            = txdat_lcrdv;
    assign txdat_crd_cnt_inc_sx    = txdatcrdv_s0;
    assign txdat_req_s0            = (dbf_txdat_valid_entry1_sx | dbf_txdat_valid_entry2_sx_ns);

    //determine dataid
    assign mshr_txdat_dataid_sx_ns =    ({2{dbf_txdat_valid_entry2_sx_ns & dbf_txdat_pe_entry2_sx[0]}}    & 2'b00) |
           ({2{dbf_txdat_valid_entry2_sx_ns & (~dbf_txdat_pe_entry2_sx[0])}} & 2'b10) |
           ({2{(~dbf_txdat_valid_entry2_sx_ns) & dbf_txdat_pe_entry1_sx[0]}} & 2'b00) |
           ({2{(~dbf_txdat_valid_entry2_sx_ns) & (~dbf_txdat_pe_entry1_sx[0])}} & 2'b10);

    always @* begin: txdat_be_sel_comb_logic
        mshr_txdat_be_sx_ns = {`CHIE_DAT_FLIT_BE_WIDTH{1'b0}};
        if(mshr_txdat_dataid_sx_ns == 2'b00 & dbf_txdat_valid_entry2_sx_ns)
            mshr_txdat_be_sx_ns = dbf_txdat_be_entry2_sx[`CHIE_DAT_FLIT_BE_WIDTH-1:0];
        else if(mshr_txdat_dataid_sx_ns == 2'b10 & dbf_txdat_valid_entry2_sx_ns)
            mshr_txdat_be_sx_ns = dbf_txdat_be_entry2_sx[(`CHIE_DAT_FLIT_BE_WIDTH*2)-1:`CHIE_DAT_FLIT_BE_WIDTH];
        else if(mshr_txdat_dataid_sx_ns == 2'b00 & dbf_txdat_valid_entry1_sx)
            mshr_txdat_be_sx_ns = dbf_txdat_be_entry1_sx[`CHIE_DAT_FLIT_BE_WIDTH-1:0];
        else if(mshr_txdat_dataid_sx_ns == 2'b10 & dbf_txdat_valid_entry1_sx)
            mshr_txdat_be_sx_ns = dbf_txdat_be_entry1_sx[(`CHIE_DAT_FLIT_BE_WIDTH*2)-1:`CHIE_DAT_FLIT_BE_WIDTH];
        else
            ;
    end

    always @* begin: txdat_data_sel_comb_logic
        mshr_txdat_data_sx_ns = {`CHIE_DAT_FLIT_DATA_WIDTH{1'b0}};
        if(mshr_txdat_dataid_sx_ns == 2'b00 & dbf_txdat_valid_entry2_sx_ns)
            mshr_txdat_data_sx_ns = dbf_txdat_data_entry2_sx[`CHIE_DAT_FLIT_DATA_WIDTH-1:0];
        else if(mshr_txdat_dataid_sx_ns == 2'b10 & dbf_txdat_valid_entry2_sx_ns)
            mshr_txdat_data_sx_ns = dbf_txdat_data_entry2_sx[(`CHIE_DAT_FLIT_DATA_WIDTH*2)-1:`CHIE_DAT_FLIT_DATA_WIDTH];
        else if(mshr_txdat_dataid_sx_ns == 2'b00 & dbf_txdat_valid_entry1_sx)
            mshr_txdat_data_sx_ns = dbf_txdat_data_entry1_sx[`CHIE_DAT_FLIT_DATA_WIDTH-1:0];
        else if(mshr_txdat_dataid_sx_ns == 2'b10 & dbf_txdat_valid_entry1_sx)
            mshr_txdat_data_sx_ns = dbf_txdat_data_entry1_sx[(`CHIE_DAT_FLIT_DATA_WIDTH*2)-1:`CHIE_DAT_FLIT_DATA_WIDTH];
        else
            ;
    end

    generate
        if(CHIE_DAT_RSVDC_WIDTH_PARAM != 0)begin
            always @*begin
                txdatflit_mshr_s0[`CHIE_DAT_FLIT_RSVDC_RANGE] = {`CHIE_DAT_FLIT_RSVDC_WIDTH{1'b0}};
            end
        end
        if(CHIE_DATACHECK_WIDTH_PARAM != 0)begin
            always @*begin
                txdatflit_mshr_s0[`CHIE_DAT_FLIT_DATACHECK_RANGE] = {`CHIE_DAT_FLIT_DATACHECK_WIDTH{1'b0}};
            end
        end
        if(CHIE_POISON_WIDTH_PARAM != 0)begin
            always @*begin
                txdatflit_mshr_s0[`CHIE_DAT_FLIT_POISON_RANGE] = {`CHIE_DAT_FLIT_POISON_WIDTH{1'b0}};
            end
        end
    endgenerate

    always @*begin : combinational_logic1
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_QOS_RANGE]       = {`CHIE_DAT_FLIT_QOS_WIDTH{1'b0}};
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_TGTID_RANGE]     = mshr_txdat_tgtid_sx2;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_SRCID_RANGE]     = HNF_NID_PARAM;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_TXNID_RANGE]     = mshr_txdat_txnid_sx2;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_HOMENID_RANGE]   = (mshr_txdat_opcode_sx2 == `CHIE_COMPDATA)?HNF_NID_PARAM : 0;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_OPCODE_RANGE]    = mshr_txdat_opcode_sx2;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_RESPERR_RANGE]   = mshr_txdat_resperr_sx2;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_RESP_RANGE]      = mshr_txdat_resp_sx2;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_FWDSTATE_RANGE]  = {`CHIE_DAT_FLIT_FWDSTATE_WIDTH{1'b0}};
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_CBUSY_RANGE]     = {`CHIE_DAT_FLIT_CBUSY_WIDTH{1'b0}};
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_DBID_RANGE]      = mshr_txdat_dbid_sx2;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_CCID_RANGE]      = {`CHIE_DAT_FLIT_CCID_WIDTH{1'b0}};
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_DATAID_RANGE]    = mshr_txdat_dataid_sx_ns;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_TAGOP_RANGE]     = {`CHIE_DAT_FLIT_TAGOP_WIDTH{1'b0}};
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_TAG_RANGE]       = {`CHIE_DAT_FLIT_TAG_WIDTH{1'b0}};
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_TU_RANGE]        = {`CHIE_DAT_FLIT_TU_WIDTH{1'b0}};
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_TRACETAG_RANGE]  = {`CHIE_DAT_FLIT_TRACETAG_WIDTH{1'b0}};
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_BE_RANGE]        = mshr_txdat_be_sx_ns;
        txdatflit_mshr_s0[`CHIE_DAT_FLIT_DATA_RANGE]      = mshr_txdat_data_sx_ns;
    end

    assign txdatflit_s0            = txdatflit_mshr_s0;
    assign dat_crd_cnt_s1          = txdat_crd_cnt_q;
    assign txdatflitv_s0           = (txdat_req_s0 & ~txdat_busy_sx);
    assign txdat_crd_cnt_dec_sx    = (txdatflitv_s0 & txdat_crd_avail_s1); //lcrd - 1

    assign txdatflitpend = 1'b1;

    //txdatflit sending logic
    always @(posedge clk or posedge rst) begin: txdatflit_logic_t
        if(rst == 1'b1)begin
            txdatflit  <= {`CHIE_DAT_FLIT_WIDTH{1'b0}};
            txdatflitv <= 1'b0;
        end
        else if((txdatflitv_s0 == 1'b1) & (txdat_crd_avail_s1 == 1'b1))begin
            txdatflit  <= txdatflit_s0;
            txdatflitv <= 1'b1;
        end
        else begin
            txdatflit  <= txdatflit;
            txdatflitv <= 1'b0;
        end
    end


    //deallocate entry if flit sent
    assign dbf_txdat_entry1_dealloc_sx = (txdatflitv_s0 & txdat_crd_avail_s1) & dbf_txdat_valid_entry1_sx &(~dbf_txdat_valid_entry2_sx_ns) & ~dbf_txdat_entry2_dealloc_sx &
           (dbf_txdat_pe_entry1_sx[0] ^ dbf_txdat_pe_entry1_sx[1]);

    assign dbf_txdat_entry2_dealloc_sx = (txdatflitv_s0 & txdat_crd_avail_s1) & dbf_txdat_valid_entry2_sx_ns &
           (dbf_txdat_pe_entry2_sx[0] ^ dbf_txdat_pe_entry2_sx[1]);

    assign txdat_mshr_busy_sx = (dbf_txdat_valid_entry1_sx && dbf_txdat_valid_entry2_sx);

    //clr busy logic
    always @(posedge clk or posedge rst) begin: txdat_mshr_clr_dbf_busy_valid_sx3_logic_t
        if (rst == 1'b1)
            txdat_mshr_clr_dbf_busy_valid_sx3 <= 1'b0;
        else if(dbf_txdat_entry1_dealloc_sx | dbf_txdat_entry2_dealloc_sx)
            txdat_mshr_clr_dbf_busy_valid_sx3 <= 1'b1;
        else
            txdat_mshr_clr_dbf_busy_valid_sx3 <= 1'b0;
    end

    always @(posedge clk or posedge rst) begin: txdat_mshr_clr_dbf_busy_idx_sx3_logic_t
        if (rst == 1'b1)
            txdat_mshr_clr_dbf_busy_idx_sx3 <= {`MSHR_ENTRIES_WIDTH{1'b0}};
        else if(dbf_txdat_entry1_dealloc_sx)
            txdat_mshr_clr_dbf_busy_idx_sx3 <= dbf_txdat_idx_entry1_sx;
        else if(dbf_txdat_entry2_dealloc_sx)
            txdat_mshr_clr_dbf_busy_idx_sx3 <= dbf_txdat_idx_entry2_sx;
        else
            txdat_mshr_clr_dbf_busy_idx_sx3 <= {`MSHR_ENTRIES_WIDTH{1'b0}};
    end

    //receive dbf_txdat_valid_sx1, pass valid
    always @(posedge clk or posedge rst) begin: dbf_txdat_valid_entry1_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_valid_entry1_sx <= 1'b0;
        else if(dbf_txdat_valid_sx1 && !dbf_txdat_valid_entry1_sx)
            dbf_txdat_valid_entry1_sx <= 1'b1;
        else if(dbf_txdat_entry1_dealloc_sx)
            dbf_txdat_valid_entry1_sx <= 1'b0;
        else begin
        end
    end

    always @(posedge clk or posedge rst) begin: dbf_txdat_valid_entry2_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_valid_entry2_sx <= 1'b0;
        else if(dbf_txdat_valid_sx1 && dbf_txdat_valid_entry1_sx && !dbf_txdat_valid_entry2_sx)
            dbf_txdat_valid_entry2_sx <= 1'b1;
        else if(dbf_txdat_entry2_dealloc_sx)
            dbf_txdat_valid_entry2_sx <= 1'b0;
        else begin
        end
    end

    always @(posedge clk or posedge rst) begin: dbf_txdat_valid_entry2_sx_ns_logic_t
        if(rst == 1'b1)
            dbf_txdat_valid_entry2_sx_ns <= 1'b0;
        else if((dbf_txdat_valid_entry2_sx || (dbf_txdat_valid_sx1 && dbf_txdat_valid_entry1_sx && !dbf_txdat_valid_entry2_sx)) && (dbf_txdat_entry1_dealloc_sx || !dbf_txdat_valid_entry1_sx) && !dbf_txdat_entry2_dealloc_sx)
            dbf_txdat_valid_entry2_sx_ns <= 1'b1;
        else if(dbf_txdat_entry2_dealloc_sx)
            dbf_txdat_valid_entry2_sx_ns <= 1'b0;
        else begin
        end
    end

    //receive dbf_txdat_valid_sx1, pass index to mshr
    always @(posedge clk or posedge rst) begin: dbf_txdat_idx_entry1_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_idx_entry1_sx <= {`MSHR_ENTRIES_WIDTH{1'b0}};
        else if(dbf_txdat_valid_sx1 && !dbf_txdat_valid_entry1_sx)
            dbf_txdat_idx_entry1_sx <= dbf_txdat_idx_sx1;
        else begin
        end
    end

    always @(posedge clk or posedge rst) begin: dbf_txdat_idx_entry2_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_idx_entry2_sx <= {`MSHR_ENTRIES_WIDTH{1'b0}};
        else if(dbf_txdat_valid_sx1 && dbf_txdat_valid_entry1_sx && !dbf_txdat_valid_entry2_sx)
            dbf_txdat_idx_entry2_sx <= dbf_txdat_idx_sx1;
        else begin
        end
    end

    assign txdat_mshr_rd_idx_sx2 = dbf_txdat_valid_entry2_sx_ns? dbf_txdat_idx_entry2_sx : dbf_txdat_valid_entry1_sx? dbf_txdat_idx_entry1_sx : {`MSHR_ENTRIES_WIDTH{1'b0}};

    //receive dbf_txdat_valid_sx1, pass data
    always @(posedge clk or posedge rst) begin: dbf_txdat_data_entry1_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_data_entry1_sx <= {`CACHE_LINE_WIDTH{1'b0}};
        else if(dbf_txdat_valid_sx1 && !dbf_txdat_valid_entry1_sx)
            dbf_txdat_data_entry1_sx <= dbf_txdat_data_sx1;
        else
            dbf_txdat_data_entry1_sx <= dbf_txdat_data_entry1_sx;
    end

    always @(posedge clk or posedge rst) begin: dbf_txdat_data_entry2_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_data_entry2_sx <= {`CACHE_LINE_WIDTH{1'b0}};
        else if(dbf_txdat_valid_sx1 && dbf_txdat_valid_entry1_sx && !dbf_txdat_valid_entry2_sx)
            dbf_txdat_data_entry2_sx <= dbf_txdat_data_sx1;
        else
            dbf_txdat_data_entry2_sx <= dbf_txdat_data_entry2_sx;
    end

    //receive dbf_txdat_valid_sx1, pass be
    always @(posedge clk or posedge rst) begin: dbf_txdat_be_entry1_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_be_entry1_sx <= {`CACHE_BE_WIDTH{1'b0}};
        else if(dbf_txdat_valid_sx1 && !dbf_txdat_valid_entry1_sx)
            dbf_txdat_be_entry1_sx <= dbf_txdat_be_sx1;
        else
            dbf_txdat_be_entry1_sx <= dbf_txdat_be_entry1_sx;
    end

    always @(posedge clk or posedge rst) begin: dbf_txdat_be_entry2_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_be_entry2_sx <= {`CACHE_BE_WIDTH{1'b0}};
        else if(dbf_txdat_valid_sx1 && dbf_txdat_valid_entry1_sx && !dbf_txdat_valid_entry2_sx)
            dbf_txdat_be_entry2_sx <= dbf_txdat_be_sx1;
        else
            dbf_txdat_be_entry2_sx <= dbf_txdat_be_entry2_sx;
    end

    //receive dbf_txdat_valid_sx1, pass pe
    always @(posedge clk or posedge rst) begin: dbf_txdat_pe_entry1_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_pe_entry1_sx <= {`CACHE_BE_WIDTH{1'b0}};
        else if(dbf_txdat_valid_sx1 && !dbf_txdat_valid_entry1_sx)
            dbf_txdat_pe_entry1_sx <= dbf_txdat_pe_sx1;
        else if(dbf_txdat_valid_entry1_sx & (~dbf_txdat_valid_entry2_sx_ns) & txdat_crd_avail_s1)
            dbf_txdat_pe_entry1_sx <= dbf_txdat_pe_entry1_sx[0]?{dbf_txdat_pe_entry1_sx[1],1'b0}:2'b00;
        else
            dbf_txdat_pe_entry1_sx <= dbf_txdat_pe_entry1_sx;
    end

    always @(posedge clk or posedge rst) begin: dbf_txdat_pe_entry2_sx_logic_t
        if(rst == 1'b1)
            dbf_txdat_pe_entry2_sx <= {`CACHE_BE_WIDTH{1'b0}};
        else if(dbf_txdat_valid_sx1 && dbf_txdat_valid_entry1_sx && !dbf_txdat_valid_entry2_sx)
            dbf_txdat_pe_entry2_sx <= dbf_txdat_pe_sx1;
        else if( dbf_txdat_valid_entry2_sx_ns & txdat_crd_avail_s1)
            dbf_txdat_pe_entry2_sx <= dbf_txdat_pe_entry2_sx[0]?{dbf_txdat_pe_entry2_sx[1],1'b0}:2'b00;
        else
            dbf_txdat_pe_entry2_sx <= dbf_txdat_pe_entry2_sx;
    end

    //L-credit logic
    assign update_dat_crd_cnt_s0   = txdat_crd_cnt_inc_sx | txdat_crd_cnt_dec_sx;
    assign dat_crd_cnt_inc_s0      = (dat_crd_cnt_s1 + 1'b1);
    assign dat_crd_cnt_dec_s0      = (dat_crd_cnt_s1 - 1'b1);

    always @* begin: dat_crd_cnt_ns_s0_logic_c
        casez({txdat_crd_cnt_inc_sx, txdat_crd_cnt_dec_sx})
            2'b00:
                dat_crd_cnt_ns_s0 = txdat_crd_cnt_q;     // hold
            2'b01:
                dat_crd_cnt_ns_s0 = dat_crd_cnt_dec_s0;  // dec
            2'b10:
                dat_crd_cnt_ns_s0 = dat_crd_cnt_inc_s0;  // inc
            2'b11:
                dat_crd_cnt_ns_s0 = txdat_crd_cnt_q;     // hold
            default:
                dat_crd_cnt_ns_s0 = {`HNF_LCRD_DAT_CNT_WIDTH{1'b0}};
        endcase
    end

    always @(posedge clk or posedge rst)begin
        if (rst == 1'b1)
            txdat_crd_cnt_q <= {`HNF_LCRD_DAT_CNT_WIDTH{1'b0}};
        else if (update_dat_crd_cnt_s0 == 1'b1)
            txdat_crd_cnt_q <= dat_crd_cnt_ns_s0;
    end

    //-----------------------------------------------------------------------------
    // DISPLAY INFO
    //-----------------------------------------------------------------------------
`ifdef DISPLAY_INFO
    always @(posedge clk)begin
        if(txdatflitv)begin
            `display_info($sformatf("HNF TXDAT send a flit\n tgtid: %h\n opcode: %h\n txnid: %h\n resp: %h\n resperr: %h\n dbid: %h\n dataid: %h\n be: %h\n data: %h\n Time: %0d\n",txdatflit[`CHIE_DAT_FLIT_TGTID_RANGE],txdatflit[`CHIE_DAT_FLIT_OPCODE_RANGE],txdatflit[`CHIE_DAT_FLIT_TXNID_RANGE],txdatflit[`CHIE_DAT_FLIT_RESP_RANGE],txdatflit[`CHIE_DAT_FLIT_RESPERR_RANGE],txdatflit[`CHIE_DAT_FLIT_DBID_RANGE],txdatflit[`CHIE_DAT_FLIT_DATAID_RANGE],txdatflit[`CHIE_DAT_FLIT_BE_RANGE],txdatflit[`CHIE_DAT_FLIT_DATA_RANGE],$time()));
        end
    end
`endif
endmodule
