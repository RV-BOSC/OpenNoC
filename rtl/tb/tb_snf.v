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
*    Guo Bing <guobing@bosc.ac.cn>
*    Chunyan Lin <linchunyan@bosc.ac.cn>
*/

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module tb_snf `HNF_PARAM
    (
        //global inputs
        CLK,
        RST,

        RXREQFLITV,
        RXREQFLIT,

        RXDATFLITV,
        RXDATFLIT,

        TXRSPFLITV,
        TXRSPFLIT,

        TXDATFLITV,
        TXDATFLIT,

        dbg_sn_wr_en,
        dbg_sn_addr,
        dbg_sn_wr_data,

        dbg_sn_rd_en,
        dbg_sn_rd_data
    );
    input wire                                 CLK;
    input wire                                 RST;

    input wire                                 RXREQFLITV;
    input wire [`CHIE_REQ_FLIT_RANGE]          RXREQFLIT;

    input wire                                 RXDATFLITV;
    input wire [`CHIE_DAT_FLIT_RANGE]          RXDATFLIT;

    input wire                                 dbg_sn_wr_en;
    input wire                                 dbg_sn_rd_en;
    input wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0] dbg_sn_addr;
    input wire [`CHIE_DAT_FLIT_WIDTH*2-1:0]    dbg_sn_wr_data;

    output wire [`CHIE_DAT_FLIT_WIDTH*2-1:0]   dbg_sn_rd_data;

    output reg                                 TXRSPFLITV;
    output reg [`CHIE_RSP_FLIT_RANGE]          TXRSPFLIT;

    output reg                                 TXDATFLITV;
    output reg [`CHIE_DAT_FLIT_RANGE]          TXDATFLIT;

    //internal wire
    wire                                       rxreqflit_v;
    wire [`CHIE_REQ_FLIT_RANGE]                rxreqflit;
    wire                                       rxdatflit_v;
    wire [`CHIE_DAT_FLIT_RANGE]                rxdatflit;
    wire                                       rxreq_is_rdnosnp;
    wire                                       rxreq_is_wrnosnpf;
    wire                                       rxreq_is_wrnosnpp;
    wire                                       rxreq_is_wrnosnp;
    wire                                       rxreq_is_noncopybackwrdata;
    wire                                       dyn_req;
    wire                                       static_req;
    wire                                       wr_dataid0;
    wire                                       wr_dataid2;
    wire                                       wr_en_id0;
    wire                                       wr_en_id2;
    wire                                       rxreq_ord;
    wire                                       rdnsnp_recipt;
    wire                                       rd_en;
    wire                                       wr_en;
    wire [511:0]                               wr_data;
    wire [511:0]                               rd_data;
    wire [(`CHIE_DAT_FLIT_DATA_WIDTH*2)-1:0]   wr_new_data;
    wire                                       mem_empty;
    wire                                       mem_full;
    wire                                       wrnosnp_dwt;
    wire                                       ncbwrdata_from_rn;
    wire                                       dat_cancel;

    //internal regs
    //reg [511:0]                                rd_data_out;
    reg [`CHIE_DAT_FLIT_RANGE]                 txdatflit_tmp0;
    reg [`CHIE_DAT_FLIT_RANGE]                 txdatflit_tmp1;
    reg [6:0]                                  txdat_tgtid;
    reg [11:0]                                 txdat_txnid;
    reg [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]        txdat_dbid;
    reg                                        send_data0;
    reg                                        send_data1;
    reg [`CHIE_RSP_FLIT_RANGE]                 txrspflit_tmp;
    reg [6:0]                                  txrsp_tgtid;
    reg [11:0]                                 txrsp_txnid;
    reg [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      txrsp_opcode;
    reg                                        send_rsp;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]        wr_data_l;
    reg [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]        wr_data_h;
    reg                                        wr_en_q;
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        addr;
    reg [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        addr_q;
    reg                                        wrnosnp_dwt_q;
    reg                                        ncbwrdata_from_rn_q;

    //main methods
    //rxreq logic
    assign rxreqflit = RXREQFLITV? RXREQFLIT:{`CHIE_REQ_FLIT_WIDTH{1'b0}};
    assign rxreqflit_v = RXREQFLITV;

    assign rxdatflit = RXDATFLITV? RXDATFLIT:{`CHIE_DAT_FLIT_WIDTH{1'b0}};
    assign rxdatflit_v = RXDATFLITV;

    assign dyn_req = (rxreqflit[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE] == 1'b1);
    assign static_req = rxreqflit_v & (rxreqflit[`CHIE_REQ_FLIT_ALLOWRETRY_RANGE] == 1'b0);

    assign rxreq_is_rdnosnp = rxreqflit_v & (rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_READNOSNP);
    assign rxreq_is_wrnosnpf = rxreqflit_v & (rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_WRITENOSNPFULL);
    assign rxreq_is_wrnosnpp = rxreqflit_v & (rxreqflit[`CHIE_REQ_FLIT_OPCODE_RANGE] == `CHIE_WRITENOSNPPTL);
    assign wrnosnp_dwt = (rxreq_is_wrnosnpf | rxreq_is_wrnosnpp) & (rxreqflit[`CHIE_REQ_FLIT_DODWT_RANGE] == 1'b1);

    assign rxreq_is_wrnosnp = (rxreq_is_wrnosnpf | rxreq_is_wrnosnpp);
    assign rxreq_ord = (rxreqflit[`CHIE_REQ_FLIT_ORDER_RANGE] == 2'b01);

    assign rdnsnp_recipt = rxreqflit_v & rxreq_ord;

    assign rd_en = dbg_sn_rd_en? 1'b1:rxreq_is_rdnosnp? 1'b1:1'b0;

    assign rxreq_is_noncopybackwrdata = rxdatflit_v & (rxdatflit[`CHIE_DAT_FLIT_OPCODE_RANGE] == `CHIE_NONCOPYBACKWRDATA);
    assign wr_dataid0 = (rxdatflit[`CHIE_DAT_FLIT_DATAID_RANGE] == 2'b00);
    assign wr_dataid2 = (rxdatflit[`CHIE_DAT_FLIT_DATAID_RANGE] == 2'b10);
    assign ncbwrdata_from_rn = wr_en_id2 & (rxdatflit[`CHIE_DAT_FLIT_SRCID_RANGE] == `RN0_ID);

    assign wr_en_id0 = rxreq_is_noncopybackwrdata & wr_dataid0;
    assign wr_en_id2 = rxreq_is_noncopybackwrdata & wr_dataid2;
    assign dat_cancel = ~(|rxdatflit[`CHIE_DAT_FLIT_BE_RANGE]) & rxdatflit_v;

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            ncbwrdata_from_rn_q <= 1'b0;
        else if(ncbwrdata_from_rn ==  1'b1)
            ncbwrdata_from_rn_q <= 1'b1;
        else
            ncbwrdata_from_rn_q <= 1'b0;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            wrnosnp_dwt_q <= {`CHIE_REQ_FLIT_DODWT_WIDTH{1'b0}};
        else if(wrnosnp_dwt ==  1'b1)
            wrnosnp_dwt_q <= 1'b1;
        else
            wrnosnp_dwt_q <= 1'b0;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            addr_q <= {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
        else if(rxreq_is_wrnosnp ==  1'b1)
            addr_q <= rxreqflit[`CHIE_REQ_FLIT_ADDR_RANGE];
        else
            ;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            wr_data_l <= {256{1'b0}};
        else if(wr_en_id0 ==  1'b1)
            wr_data_l <= rxdatflit[`CHIE_DAT_FLIT_DATA_RANGE];
        else
            ;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            wr_data_h <= {256{1'b0}};
        else if(wr_en_id2 ==  1'b1)
            wr_data_h <= rxdatflit[`CHIE_DAT_FLIT_DATA_RANGE];
        else
            ;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            wr_en_q <= 1'b0;
        else if(wr_en_id2 ==  1'b1)
            wr_en_q <= wr_en_id2 & ~dat_cancel;
        else
            wr_en_q <= 1'b0;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            txdat_tgtid <= {7{1'b0}};
        else if(rxreqflit_v ==  1'b1)
            txdat_tgtid <= rxreqflit[`CHIE_REQ_FLIT_RETURNNID_RANGE];
        else
            ;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            txdat_txnid <= {12{1'b0}};
        else if(rxreqflit_v ==  1'b1)
            txdat_txnid <= rxreqflit[`CHIE_REQ_FLIT_RETURNTXNID_RANGE];
        else
            ;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            txdat_dbid <= {12{1'b0}};
        else if(rxreqflit_v ==  1'b1)
            txdat_dbid <= rxreqflit[`CHIE_REQ_FLIT_TXNID_RANGE];
        else
            ;
    end

    //always@(posedge CLK or negedge RST)
    //begin
    //  if(RST == 1'b1)
    //    rd_data_out <= {512{1'b0}};
    //  else
    //    rd_data_out <= rd_data;
    //end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            send_data0 <= 1'b0;
        else if(rxreq_is_rdnosnp)
            send_data0 <= 1'b1;
        else
            send_data0 <= 1'b0;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            send_data1 <= 1'b0;
        else
            send_data1 <= send_data0;
    end

    assign wr_new_data = {wr_data_h,wr_data_l};

    assign wr_data = dbg_sn_wr_en? dbg_sn_wr_data:wr_en_q? wr_new_data:'d0;

    assign wr_en = dbg_sn_wr_en? 1'b1:wr_en_q? 1'b1:1'b0;

    generate
        if(CHIE_DATACHECK_WIDTH_PARAM != 0)begin
            always @*begin
                txdatflit_tmp0[`CHIE_DAT_FLIT_DATACHECK_RANGE] = {`CHIE_DAT_FLIT_DATACHECK_WIDTH{1'b0}};
                txdatflit_tmp1[`CHIE_DAT_FLIT_DATACHECK_RANGE] = {`CHIE_DAT_FLIT_DATACHECK_WIDTH{1'b0}};
            end
        end
        if(CHIE_POISON_WIDTH_PARAM != 0)begin
            always @*begin
                txdatflit_tmp0[`CHIE_DAT_FLIT_POISON_RANGE] = {`CHIE_DAT_FLIT_POISON_WIDTH{1'b0}};
                txdatflit_tmp1[`CHIE_DAT_FLIT_POISON_RANGE] = {`CHIE_DAT_FLIT_POISON_WIDTH{1'b0}};
            end
        end
    endgenerate

    always@*begin
        txdatflit_tmp0[`CHIE_DAT_FLIT_QOS_RANGE]      = {`CHIE_DAT_FLIT_QOS_WIDTH{1'b0}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_TGTID_RANGE]    = txdat_tgtid;
        txdatflit_tmp0[`CHIE_DAT_FLIT_SRCID_RANGE]    = `SN_ID;
        txdatflit_tmp0[`CHIE_DAT_FLIT_TXNID_RANGE]    = txdat_txnid;
        txdatflit_tmp0[`CHIE_DAT_FLIT_HOMENID_RANGE]  = `HNF0_ID;
        txdatflit_tmp0[`CHIE_DAT_FLIT_OPCODE_RANGE]   = `CHIE_COMPDATA;
        txdatflit_tmp0[`CHIE_DAT_FLIT_RESPERR_RANGE]  = {`CHIE_DAT_FLIT_RESPERR_WIDTH{1'b0}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_RESP_RANGE]     = `CHIE_COMP_RESP_UC;
        txdatflit_tmp0[`CHIE_DAT_FLIT_FWDSTATE_RANGE] = {`CHIE_DAT_FLIT_FWDSTATE_WIDTH{1'b0}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_CBUSY_RANGE]    = {`CHIE_DAT_FLIT_CBUSY_WIDTH{1'b0}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_DBID_RANGE]     = txdat_dbid;
        txdatflit_tmp0[`CHIE_DAT_FLIT_CCID_RANGE]     = {`CHIE_DAT_FLIT_CCID_WIDTH{1'b0}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_DATAID_RANGE]   = 2'b00;
        txdatflit_tmp0[`CHIE_DAT_FLIT_TAGOP_RANGE]    = {`CHIE_DAT_FLIT_TAGOP_WIDTH{1'b0}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_TAG_RANGE]      = {`CHIE_DAT_FLIT_TAG_WIDTH{1'b0}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_TU_RANGE]       = {`CHIE_DAT_FLIT_TU_WIDTH{1'b0}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_TRACETAG_RANGE] = {`CHIE_DAT_FLIT_TRACETAG_WIDTH{1'b0}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_BE_RANGE]       = {`CHIE_DAT_FLIT_BE_WIDTH{1'b1}};
        txdatflit_tmp0[`CHIE_DAT_FLIT_DATA_RANGE]     = rd_data[255:0];
    end

    always@*begin
        txdatflit_tmp1[`CHIE_DAT_FLIT_QOS_RANGE]      = {`CHIE_DAT_FLIT_QOS_WIDTH{1'b0}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_TGTID_RANGE]    = txdat_tgtid;
        txdatflit_tmp1[`CHIE_DAT_FLIT_SRCID_RANGE]    = `SN_ID;
        txdatflit_tmp1[`CHIE_DAT_FLIT_TXNID_RANGE]    = txdat_txnid;
        txdatflit_tmp1[`CHIE_DAT_FLIT_HOMENID_RANGE]  = `HNF0_ID;
        txdatflit_tmp1[`CHIE_DAT_FLIT_OPCODE_RANGE]   = `CHIE_COMPDATA;
        txdatflit_tmp1[`CHIE_DAT_FLIT_RESPERR_RANGE]  = {`CHIE_DAT_FLIT_RESPERR_WIDTH{1'b0}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_RESP_RANGE]     = `CHIE_COMP_RESP_UC;
        txdatflit_tmp1[`CHIE_DAT_FLIT_FWDSTATE_RANGE] = {`CHIE_DAT_FLIT_FWDSTATE_WIDTH{1'b0}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_CBUSY_RANGE]    = {`CHIE_DAT_FLIT_CBUSY_WIDTH{1'b0}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_DBID_RANGE]     = txdat_dbid;
        txdatflit_tmp1[`CHIE_DAT_FLIT_CCID_RANGE]     = {`CHIE_DAT_FLIT_CCID_WIDTH{1'b0}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_DATAID_RANGE]   = 2'b10;
        txdatflit_tmp1[`CHIE_DAT_FLIT_TAGOP_RANGE]    = {`CHIE_DAT_FLIT_TAGOP_WIDTH{1'b0}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_TAG_RANGE]      = {`CHIE_DAT_FLIT_TAG_WIDTH{1'b0}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_TU_RANGE]       = {`CHIE_DAT_FLIT_TU_WIDTH{1'b0}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_TRACETAG_RANGE] = {`CHIE_DAT_FLIT_TRACETAG_WIDTH{1'b0}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_BE_RANGE]       = {`CHIE_DAT_FLIT_BE_WIDTH{1'b1}};
        txdatflit_tmp1[`CHIE_DAT_FLIT_DATA_RANGE]     = rd_data[511:256];
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)begin
            TXDATFLITV <= 1'b0;
            TXDATFLIT <= {512{1'b0}};
        end
        else if(send_data0)begin
            TXDATFLITV <= 1'b1;
            TXDATFLIT <= txdatflit_tmp0;
        end
        else if(send_data1)begin
            TXDATFLITV <= 1'b1;
            TXDATFLIT <= txdatflit_tmp1;
        end
        else begin
            TXDATFLITV <= 1'b0;
        end
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            txrsp_tgtid <= {7{1'b0}};
        else if(wrnosnp_dwt == 1'b1 & rxreqflit_v ==  1'b1)
            txrsp_tgtid <= `RN0_ID;
        else if(ncbwrdata_from_rn == 1'b1)
            txrsp_tgtid <= `HNF0_ID;
        else if(rxreqflit_v ==  1'b1)
            txrsp_tgtid <= rxreqflit[`CHIE_REQ_FLIT_SRCID_RANGE];
        else
            ;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            txrsp_txnid <= {12{1'b0}};
        else if(rxreqflit_v ==  1'b1)
            txrsp_txnid <= rxreqflit[`CHIE_REQ_FLIT_TXNID_RANGE];
        else
            ;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            txrsp_opcode <= {`CHIE_RSP_FLIT_OPCODE_WIDTH{1'b0}};
        else if((rxreqflit_v ==  1'b1))
            txrsp_opcode <= wrnosnp_dwt? `CHIE_DBIDRESP:(rxreq_is_wrnosnpf | rxreq_is_wrnosnpp)? `CHIE_COMPDBIDRESP:rdnsnp_recipt? `CHIE_READRECEIPT:'d0;
        else if((rxdatflit_v ==  1'b1))
            txrsp_opcode <= ncbwrdata_from_rn? `CHIE_COMP:'d0;
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)
            send_rsp <= 1'b0;
        else if(rxreq_is_wrnosnpf | rxreq_is_wrnosnpp | rdnsnp_recipt | wrnosnp_dwt | ncbwrdata_from_rn)
            send_rsp <= 1'b1;
        else
            send_rsp <= 1'b0;
    end

    always @*begin
        txrspflit_tmp[`CHIE_RSP_FLIT_QOS_RANGE]      = {`CHIE_RSP_FLIT_QOS_WIDTH{1'b0}};
        txrspflit_tmp[`CHIE_RSP_FLIT_TGTID_RANGE]    = txrsp_tgtid;
        txrspflit_tmp[`CHIE_RSP_FLIT_SRCID_RANGE]    = `SN_ID;
        txrspflit_tmp[`CHIE_RSP_FLIT_TXNID_RANGE]    = txrsp_txnid;
        txrspflit_tmp[`CHIE_RSP_FLIT_OPCODE_RANGE]   = txrsp_opcode;
        txrspflit_tmp[`CHIE_RSP_FLIT_RESPERR_RANGE]  = {`CHIE_RSP_FLIT_RESPERR_WIDTH{1'b0}};
        txrspflit_tmp[`CHIE_RSP_FLIT_RESP_RANGE]     = {`CHIE_RSP_FLIT_RESP_WIDTH{1'b0}};
        txrspflit_tmp[`CHIE_RSP_FLIT_FWDSTATE_RANGE] = {`CHIE_RSP_FLIT_FWDSTATE_WIDTH{1'b0}};
        txrspflit_tmp[`CHIE_RSP_FLIT_CBUSY_RANGE]    = {`CHIE_RSP_FLIT_CBUSY_WIDTH{1'b0}};
        txrspflit_tmp[`CHIE_RSP_FLIT_DBID_RANGE]     = {`CHIE_RSP_FLIT_DBID_WIDTH{1'b0}};
        txrspflit_tmp[`CHIE_RSP_FLIT_PCRDTYPE_RANGE] = {`CHIE_RSP_FLIT_PCRDTYPE_WIDTH{1'b0}};
        txrspflit_tmp[`CHIE_RSP_FLIT_TAGOP_RANGE]    = {`CHIE_RSP_FLIT_TAGOP_WIDTH{1'b0}};
        txrspflit_tmp[`CHIE_RSP_FLIT_TRACETAG_RANGE] = {`CHIE_RSP_FLIT_TRACETAG_WIDTH{1'b0}};
    end

    always@(posedge CLK or posedge RST)begin
        if(RST == 1'b1)begin
            TXRSPFLITV <= 1'b0;
            TXRSPFLIT <= {`CHIE_RSP_FLIT_WIDTH{1'b0}};
        end
        else if(send_rsp)begin
            TXRSPFLITV <= 1'b1;
            TXRSPFLIT <= txrspflit_tmp;
        end
        else begin
            TXRSPFLITV <= 1'b0;
        end
    end

    always@*begin
        if(RST == 1'b1)
            addr = {`CHIE_REQ_FLIT_ADDR_WIDTH{1'b0}};
        else if(dbg_sn_wr_en | dbg_sn_rd_en)
            addr = dbg_sn_addr;
        else if(wr_en_q)
            addr = addr_q;
        else if(rxreqflit_v)
            addr = rxreqflit[`CHIE_REQ_FLIT_ADDR_RANGE];
        else
            ;
    end

    assign dbg_sn_rd_data = rd_data;

    tb_snf_sram u_snf_sram(
                    .clk     (CLK     ),
                    .rst     (RST     ),
                    .addr    (addr    ),
                    .rd_en   (rd_en   ),
                    .wr_en   (wr_en   ),
                    .wr_data (wr_data ),
                    .rd_data (rd_data ),
                    .empty   (mem_empty),
                    .full    (mem_full)
                );

endmodule
