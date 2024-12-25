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

module hni `HNI_PARAM
    (
        CLK,
        RST,

        //CHIE interface
        TXLINKACTIVEREQ,
        TXLINKACTIVEACK,
        RXLINKACTIVEREQ,
        RXLINKACTIVEACK,
        TXSACTIVE,
        RXSACTIVE,

        RXREQFLITV,
        RXREQFLIT,
        RXREQFLITPEND,
        RXREQLCRDV,

        RXRSPFLITV,
        RXRSPFLIT,
        RXRSPFLITPEND,
        RXRSPLCRDV,

        RXDATFLITV,
        RXDATFLIT,
        RXDATFLITPEND,
        RXDATLCRDV,

        TXRSPFLITV,
        TXRSPFLIT,
        TXRSPFLITPEND,
        TXRSPLCRDV,
        
        TXDATFLITV,
        TXDATFLIT,
        TXDATFLITPEND,
        TXDATLCRDV,

        //AXI interface
        ARID,
        ARADDR,
        ARLEN,
        ARSIZE,
        ARBURST,
        ARLOCK,
        ARCACHE,
        ARPROT,
        ARQOS,
        ARREGION,
        ARVALID,
        ARREADY,

        RID,
        RDATA,
        RRESP,
        RLAST,
        RVALID,
        RREADY,

        AWID,
        AWADDR,
        AWLEN,
        AWSIZE,
        AWBURST,
        AWLOCK,
        AWCACHE,
        AWPROT,
        AWQOS,
        AWREGION,
        AWVALID,
        AWREADY,

        WDATA,
        WSTRB,
        WLAST,
        WVALID,
        WREADY,

        BID,
        BRESP,
        BVALID,
        BREADY
    );
    input wire                                  CLK;
    input wire                                  RST;

    //CHIE interface
    output wire                                 TXLINKACTIVEREQ;
    input  wire                                 TXLINKACTIVEACK;
    input  wire                                 RXLINKACTIVEREQ;
    output wire                                 RXLINKACTIVEACK;
    output wire                                 TXSACTIVE;
    input  wire                                 RXSACTIVE;

    input wire                                  RXREQFLITV;
    input wire [`CHIE_REQ_FLIT_RANGE]           RXREQFLIT;
    input wire                                  RXREQFLITPEND;
    output wire                                 RXREQLCRDV;

    input wire                                  RXRSPFLITV;
    input wire [`CHIE_RSP_FLIT_RANGE]           RXRSPFLIT;
    input wire                                  RXRSPFLITPEND;
    output wire                                 RXRSPLCRDV;

    input wire                                  RXDATFLITV;
    input wire [`CHIE_DAT_FLIT_RANGE]           RXDATFLIT;
    input wire                                  RXDATFLITPEND;
    output wire                                 RXDATLCRDV;

    output wire                                 TXRSPFLITV;
    output wire [`CHIE_RSP_FLIT_RANGE]          TXRSPFLIT;
    output wire                                 TXRSPFLITPEND;
    input wire                                  TXRSPLCRDV;

    output wire                                 TXDATFLITV;
    output wire [`CHIE_DAT_FLIT_RANGE]          TXDATFLIT;
    output wire                                 TXDATFLITPEND;
    input wire                                  TXDATLCRDV;

    //AXI interface
    output wire [10:0]                          ARID;
    output wire [`AXI4_ARADDR_WIDTH-1:0]        ARADDR;
    output wire [7:0]                           ARLEN;
    output wire [2:0]                           ARSIZE;
    output wire [1:0]                           ARBURST;
    output wire [0:0]                           ARLOCK;
    output wire [3:0]                           ARCACHE;
    output wire [2:0]                           ARPROT;
    output wire [3:0]                           ARQOS;
    output wire [3:0]                           ARREGION;
    output wire                                 ARVALID;
    input  wire                                 ARREADY;

    input  wire [10:0]                          RID;
    input  wire [`AXI4_RDATA_WIDTH-1:0]         RDATA;
    input  wire [1:0]                           RRESP;
    input  wire                                 RLAST;
    input  wire                                 RVALID;
    output wire                                 RREADY;

    output wire [10:0]                          AWID;
    output wire [`AXI4_AWADDR_WIDTH-1:0]        AWADDR;
    output wire [7:0]                           AWLEN;
    output wire [2:0]                           AWSIZE;
    output wire [1:0]                           AWBURST;
    output wire [0:0]                           AWLOCK;
    output wire [3:0]                           AWCACHE;
    output wire [2:0]                           AWPROT;
    output wire [3:0]                           AWQOS;
    output wire [3:0]                           AWREGION;
    output wire                                 AWVALID;
    input  wire                                 AWREADY;

    output wire [`AXI4_WDATA_WIDTH-1:0]         WDATA;
    output wire [`AXI4_WSTRB_WIDTH-1:0]         WSTRB;
    output wire                                 WLAST;
    output wire                                 WVALID;
    input  wire                                 WREADY;

    input  wire [10:0]                          BID;
    input  wire [1:0]                           BRESP;
    input  wire                                 BVALID;
    output wire                                 BREADY;

    wire                                        rxreq_retry_enable_s0;
    wire                                        txrsp_retryack_won_s1;
    wire                                        rxreq_valid_s0;
    wire [`CHIE_REQ_FLIT_RANGE]                 rxreqflit_s0;
    wire                                        rxrsp_valid_s0;
    wire [`CHIE_RSP_FLIT_RANGE]                 rxrspflit_s0;
    wire                                        rxreq_alloc_en_s0;
    wire [`CHIE_REQ_FLIT_RANGE]                 rxreq_alloc_flit_s0;
    wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]          mshr_entry_idx_alloc_s0;
    wire                                        qos_txrsp_retryack_valid_s1;
    wire [`HNI_RETRY_ACKQ_DATA_RANGE]           qos_txrsp_retryack_fifo_s1;
    wire                                        qos_txrsp_pcrdgnt_valid_s2;
    wire [`HNI_PCRDGRANTQ_DATA_RANGE]           qos_txrsp_pcrdgnt_fifo_s2;
    wire                                        mshr_entry_sleep_s1;   
    wire                                        txrsp_valid_sx_q;
    wire [`CHIE_RSP_FLIT_QOS_WIDTH-1:0]         txrsp_qos_sx;
    wire [`CHIE_RSP_FLIT_TGTID_WIDTH-1:0]       txrsp_tgtid_sx;
    wire [`CHIE_RSP_FLIT_TXNID_WIDTH-1:0]       txrsp_txnid_sx;
    wire [`CHIE_RSP_FLIT_OPCODE_WIDTH-1:0]      txrsp_opcode_sx;
    wire [`CHIE_RSP_FLIT_RESPERR_WIDTH-1:0]     txrsp_resperr_sx;
    wire [`CHIE_RSP_FLIT_RESP_WIDTH-1:0]        txrsp_resp_sx;
    wire [`CHIE_RSP_FLIT_DBID_WIDTH-1:0]        txrsp_dbid_sx;
    wire [`CHIE_RSP_FLIT_TRACETAG_WIDTH-1:0]    txrsp_tracetag_sx;
    wire                                        txrsp_pcrdgnt_won_s2;
    wire                                        txrsp_won_sx;
    wire                                        txrsp_fp_won_s1;
    wire                                        rxdat_valid_s0;
    wire [`CHIE_DAT_FLIT_RANGE]                 rxdatflit_s0;
    wire                                        dbf_txdat_valid_sx;
    wire [`CHIE_DAT_FLIT_RANGE]                 txdat_flit;
    wire                                        txdat_dbf_rdy_s1;
    wire                                        txdat_dbf_won_sx;
    wire                                        mshr_retired_valid_sx;
    wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]          mshr_retired_idx_sx;
    wire                                        excl_pass_s1;
    wire                                        excl_fail_s1;
    wire                                        rxreq_dbf_en_s0;
    wire [10:0]                                 rxreq_dbf_axid_s0;
    wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]          rxreq_dbf_entry_idx_s0;
    wire                                        rxreq_dbf_wr_s0;  
    wire [`CHIE_REQ_FLIT_ADDR_WIDTH-1:0]        rxreq_dbf_addr_s0;
    wire                                        rxreq_dbf_device_s0;
    wire [`CHIE_REQ_FLIT_SIZE_WIDTH-1:0]        rxreq_dbf_size_s0; 
    wire [`AXI4_AWLEN_WIDTH-1:0]                rxreq_dbf_axlen_s0;
    wire                                        mshr_rdat_en_sx;
    wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]          mshr_rdat_entry_idx_sx;
    wire                                        mshr_txdat_en_sx;
    wire [`CHIE_DAT_FLIT_TGTID_WIDTH-1:0]       mshr_txdat_tgtid_sx;
    wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]       mshr_txdat_txnid_sx;
    wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]      mshr_txdat_opcode_sx;
    wire [`CHIE_DAT_FLIT_RESP_WIDTH-1:0]        mshr_txdat_resp_sx; 
    wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]     mshr_txdat_resperr_sx;
    wire [`CHIE_DAT_FLIT_DBID_WIDTH-1:0]        mshr_txdat_dbid_sx;  
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]      mshr_txdat_dataid_sx;
    wire [`CHIE_DAT_FLIT_TRACETAG_WIDTH-1:0]    mshr_txdat_tracetag_sx;
    wire                                        mshr_wdat_en_sx;
    wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]          mshr_wdat_entry_idx_sx;
    wire                                        dbf_wdat_last; 
    wire                                        mshr_txdat_won_sx;
    wire                                        dbf_rxdat_valid_s0;
    wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]       dbf_rxdat_txnid_s0;
    wire [`CHIE_DAT_FLIT_OPCODE_WIDTH-1:0]      dbf_rxdat_opcode_s0;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]      dbf_rxdat_dataid_s0;
    wire                                        dbf_rvalid_sx;
    wire [`HNI_MSHR_ENTRIES_WIDTH-1:0]          dbf_rvalid_entry_idx_sx;
    wire [3:0]                                  dbf_cdmask_sx;

    reg txlinkactivereq_q;
    reg rxlinkactivereq_q;
    always @(posedge CLK) begin
        if (RST) begin
            txlinkactivereq_q <= 1'b0;
            rxlinkactivereq_q <= 1'b0;
        end else begin
            txlinkactivereq_q <= 1'b1;
            rxlinkactivereq_q <= RXLINKACTIVEREQ;
        end
    end
    assign TXLINKACTIVEREQ = txlinkactivereq_q;
    assign RXLINKACTIVEACK = rxlinkactivereq_q;
    assign TXSACTIVE       = TXLINKACTIVEREQ & TXLINKACTIVEACK & (!RST);

    //module
    hni_rxreq `HNI_PARAM_INST
        u_hni_rxreq(
            .clk(CLK),
            .rst(RST),
            .rxreqflitv(RXREQFLITV),
            .rxreqflit(RXREQFLIT),
            .rxreqflitpend(RXREQFLITPEND),
            .rxreq_retry_enable_s0(rxreq_retry_enable_s0),
            .txrsp_retryack_won_s1(txrsp_retryack_won_s1),
            .rxreq_lcrdv(RXREQLCRDV),
            .rxreq_valid_s0(rxreq_valid_s0),
            .rxreqflit_s0(rxreqflit_s0)
            );

    hni_rxrsp `HNI_PARAM_INST
        u_hni_rxrsp(
            .clk(CLK),
            .rst(RST),
            .rxrspflitv(RXRSPFLITV),
            .rxrspflit(RXRSPFLIT),
            .rxrspflitpend(RXRSPFLITPEND),
            .rxrsp_lcrdv(RXRSPLCRDV),
            .rxrsp_valid_s0(rxrsp_valid_s0), //TO MSHR
            .rxrspflit_s0(rxrspflit_s0) //TO MSHR
        );


    hni_txrsp `HNI_PARAM_INST
        u_hni_txrsp(
            .clk(CLK),
            .rst(RST),
            .txrsp_lcrdv(TXRSPLCRDV),
            .rxreq_alloc_en_s0(rxreq_alloc_en_s0),
            .rxreq_alloc_flit_s0(rxreq_alloc_flit_s0),
            .mshr_entry_idx_alloc_s0(mshr_entry_idx_alloc_s0),
            .qos_txrsp_retryack_valid_s1(qos_txrsp_retryack_valid_s1),
            .qos_txrsp_retryack_fifo_s1(qos_txrsp_retryack_fifo_s1),
            .qos_txrsp_pcrdgnt_valid_s2(qos_txrsp_pcrdgnt_valid_s2),
            .qos_txrsp_pcrdgnt_fifo_s2(qos_txrsp_pcrdgnt_fifo_s2),
            .mshr_entry_sleep_s1(mshr_entry_sleep_s1),   
            .txrsp_valid_sx_q(txrsp_valid_sx_q),
            .txrsp_qos_sx(txrsp_qos_sx),
            .txrsp_tgtid_sx(txrsp_tgtid_sx),
            .txrsp_txnid_sx(txrsp_txnid_sx),
            .txrsp_opcode_sx(txrsp_opcode_sx),
            .txrsp_resperr_sx(txrsp_resperr_sx),
            .txrsp_resp_sx(txrsp_resp_sx),
            .txrsp_dbid_sx(txrsp_dbid_sx),
            .txrsp_tracetag_sx(txrsp_tracetag_sx),
            .excl_pass_s1(excl_pass_s1),
            .txrspflitv(TXRSPFLITV),
            .txrspflit(TXRSPFLIT),
            .txrspflitpend(TXRSPFLITPEND),
            .txrsp_retryack_won_s1(txrsp_retryack_won_s1),
            .txrsp_pcrdgnt_won_s2(txrsp_pcrdgnt_won_s2),
            .txrsp_won_sx(txrsp_won_sx),
            .txrsp_fp_won_s1(txrsp_fp_won_s1)
        );

    hni_rxdat `HNI_PARAM_INST
        u_hni_rxdat(
            .clk(CLK),
            .rst(RST),
            .rxdatflitv(RXDATFLITV),
            .rxdatflit(RXDATFLIT),
            .rxdatflitpend(RXDATFLITPEND),
            .rxdat_lcrdv(RXDATLCRDV),
            .rxdat_valid_s0(rxdat_valid_s0),
            .rxdatflit_s0(rxdatflit_s0)
        );

    hni_txdat `HNI_PARAM_INST
        u_hni_txdat(
            .clk(CLK),
            .rst(RST),
            .txdat_lcrdv(TXDATLCRDV),
            .dbf_txdat_valid_sx(dbf_txdat_valid_sx),
            .txdat_flit(txdat_flit),
            .txdatflitv(TXDATFLITV),
            .txdatflit(TXDATFLIT),
            .txdatflitpend(TXDATFLITPEND),
            .txdat_dbf_rdy_s1(txdat_dbf_rdy_s1),
            .txdat_dbf_won_sx(txdat_dbf_won_sx)
        );

    hni_qos `HNI_PARAM_INST
        u_hni_qos(
            .clk(CLK),
            .rst(RST),
            .rxreq_valid_s0(rxreq_valid_s0),
            .rxreqflit_s0(rxreqflit_s0),
            .txrsp_retryack_won_s1(txrsp_retryack_won_s1),
            .txrsp_pcrdgnt_won_s2(txrsp_pcrdgnt_won_s2),
            .mshr_retired_valid_sx(mshr_retired_valid_sx),
            .mshr_retired_idx_sx(mshr_retired_idx_sx),
            .qos_txrsp_retryack_valid_s1(qos_txrsp_retryack_valid_s1),
            .qos_txrsp_retryack_fifo_s1(qos_txrsp_retryack_fifo_s1),
            .qos_txrsp_pcrdgnt_valid_s2(qos_txrsp_pcrdgnt_valid_s2),
            .qos_txrsp_pcrdgnt_fifo_s2(qos_txrsp_pcrdgnt_fifo_s2),
            .rxreq_retry_enable_s0(rxreq_retry_enable_s0),
            .rxreq_alloc_en_s0(rxreq_alloc_en_s0),
            .rxreq_alloc_flit_s0(rxreq_alloc_flit_s0),
            .mshr_entry_idx_alloc_s0(mshr_entry_idx_alloc_s0)
        );

    hni_global_monitor `HNI_PARAM_INST
        u_hni_global_monitor(
            .clk(CLK),
            .rst(RST),
            .rxreq_alloc_en_s0(rxreq_alloc_en_s0),
            .rxreq_alloc_flit_s0(rxreq_alloc_flit_s0),
            .excl_pass_s1(excl_pass_s1),
            .excl_fail_s1(excl_fail_s1)
        );

    hni_data_buffer `HNI_PARAM_INST
        u_hni_data_buffer(
            .clk(CLK),
            .rst(RST),
            .rxdat_valid_s0(rxdat_valid_s0),
            .rxdatflit_s0(rxdatflit_s0),
            .rxreq_dbf_en_s0(rxreq_dbf_en_s0),
            .rxreq_dbf_axid_s0(rxreq_dbf_axid_s0),
            .rxreq_dbf_entry_idx_s0(rxreq_dbf_entry_idx_s0),
            .rxreq_dbf_wr_s0(rxreq_dbf_wr_s0),  
            .rxreq_dbf_addr_s0(rxreq_dbf_addr_s0),
            .rxreq_dbf_device_s0(rxreq_dbf_device_s0),
            .rxreq_dbf_size_s0(rxreq_dbf_size_s0), 
            .rxreq_dbf_axlen_s0(rxreq_dbf_axlen_s0),
            .mshr_retired_valid_sx(mshr_retired_valid_sx),
            .mshr_retired_idx_sx(mshr_retired_idx_sx),
            .mshr_rdat_en_sx(mshr_rdat_en_sx),
            .mshr_rdat_entry_idx_sx(mshr_rdat_entry_idx_sx),
            .mshr_txdat_en_sx(mshr_txdat_en_sx),
            .mshr_txdat_tgtid_sx(mshr_txdat_tgtid_sx),
            .mshr_txdat_txnid_sx(mshr_txdat_txnid_sx),
            .mshr_txdat_opcode_sx(mshr_txdat_opcode_sx),
            .mshr_txdat_resp_sx(mshr_txdat_resp_sx),
            .mshr_txdat_resperr_sx(mshr_txdat_resperr_sx),
            .mshr_txdat_dbid_sx(mshr_txdat_dbid_sx),
            .mshr_txdat_dataid_sx(mshr_txdat_dataid_sx),
            .mshr_txdat_tracetag_sx(mshr_txdat_tracetag_sx),
            .mshr_wdat_en_sx(mshr_wdat_en_sx),
            .mshr_wdat_entry_idx_sx(mshr_wdat_entry_idx_sx),
            .txdat_dbf_rdy_s1(txdat_dbf_rdy_s1),
            .txdat_dbf_won_sx(txdat_dbf_won_sx),
            .dbf_txdat_valid_sx(dbf_txdat_valid_sx),
            .txdat_flit(txdat_flit),
            .mshr_txdat_won_sx(mshr_txdat_won_sx),
            .dbf_rxdat_valid_s0(dbf_rxdat_valid_s0),
            .dbf_rxdat_txnid_s0(dbf_rxdat_txnid_s0),
            .dbf_rxdat_opcode_s0(dbf_rxdat_opcode_s0),
            .dbf_rxdat_dataid_s0(dbf_rxdat_dataid_s0),
            .dbf_rvalid_sx(dbf_rvalid_sx),
            .dbf_rvalid_entry_idx_sx(dbf_rvalid_entry_idx_sx),
            .dbf_cdmask_sx(dbf_cdmask_sx),
            .w_last(dbf_wdat_last), 
            .rid(RID),
            .rdata(RDATA),
            .rresp(RRESP),
            .rlast(RLAST),
            .rvalid(RVALID),
            .rready(RREADY),
            .wdata(WDATA),
            .wstrb(WSTRB),
            .wlast(WLAST),
            .wvalid(WVALID),
            .wready(WREADY)
        );

    hni_mshr `HNI_PARAM_INST
        u_hni_mshr(
            .clk(CLK),
            .rst(RST),        
            .rxreq_alloc_en_s0(rxreq_alloc_en_s0),
            .rxreq_alloc_flit_s0(rxreq_alloc_flit_s0),
            .mshr_entry_idx_alloc_s0(mshr_entry_idx_alloc_s0),        
            .excl_pass_s1(excl_pass_s1),
            .excl_fail_s1(excl_fail_s1),       
            .rxrsp_valid_s0(rxrsp_valid_s0),
            .rxrspflit_s0(rxrspflit_s0),       
            .mshr_entry_sleep_s1(mshr_entry_sleep_s1),
            .txrsp_valid_sx_q(txrsp_valid_sx_q),
            .txrsp_qos_sx(txrsp_qos_sx),
            .txrsp_tgtid_sx(txrsp_tgtid_sx),
            .txrsp_txnid_sx(txrsp_txnid_sx),
            .txrsp_opcode_sx(txrsp_opcode_sx),
            .txrsp_resperr_sx(txrsp_resperr_sx),
            .txrsp_resp_sx(txrsp_resp_sx),
            .txrsp_dbid_sx(txrsp_dbid_sx),
            .txrsp_tracetag_sx(txrsp_tracetag_sx),      
            .txrsp_won_sx(txrsp_won_sx),
            .txrsp_fp_won_s1(txrsp_fp_won_s1),        
            .dbf_rxdat_valid_s0(dbf_rxdat_valid_s0),
            .dbf_rxdat_txnid_s0(dbf_rxdat_txnid_s0),
            .dbf_rxdat_opcode_s0(dbf_rxdat_opcode_s0),
            .dbf_rxdat_dataid_s0(dbf_rxdat_dataid_s0),   
            .rxreq_dbf_en_s0(rxreq_dbf_en_s0),
            .rxreq_dbf_axid_s0(rxreq_dbf_axid_s0),
            .rxreq_dbf_wr_s0(rxreq_dbf_wr_s0),
            .rxreq_dbf_entry_idx_s0(rxreq_dbf_entry_idx_s0),
            .rxreq_dbf_addr_s0(rxreq_dbf_addr_s0),
            .rxreq_dbf_device_s0(rxreq_dbf_device_s0),
            .rxreq_dbf_size_s0(rxreq_dbf_size_s0), 
            .rxreq_dbf_axlen_s0(rxreq_dbf_axlen_s0),
            .mshr_rdat_en_sx(mshr_rdat_en_sx),
            .mshr_rdat_entry_idx_sx(mshr_rdat_entry_idx_sx), 
            .dbf_rvalid_sx(dbf_rvalid_sx),
            .dbf_rvalid_entry_idx_sx(dbf_rvalid_entry_idx_sx),
            .dbf_cdmask_sx(dbf_cdmask_sx),
            .mshr_txdat_en_sx(mshr_txdat_en_sx),
            .mshr_txdat_tgtid_sx(mshr_txdat_tgtid_sx),
            .mshr_txdat_txnid_sx(mshr_txdat_txnid_sx),
            .mshr_txdat_opcode_sx(mshr_txdat_opcode_sx),
            .mshr_txdat_resp_sx(mshr_txdat_resp_sx),
            .mshr_txdat_resperr_sx(mshr_txdat_resperr_sx),
            .mshr_txdat_dbid_sx(mshr_txdat_dbid_sx),
            .mshr_txdat_dataid_sx(mshr_txdat_dataid_sx),
            .mshr_txdat_tracetag_sx(mshr_txdat_tracetag_sx),
            .mshr_wdat_en_sx(mshr_wdat_en_sx),
            .mshr_wdat_entry_idx_sx(mshr_wdat_entry_idx_sx),  
            .dbf_wdat_last(dbf_wdat_last), 
            .mshr_txdat_won_sx(mshr_txdat_won_sx),  
            .mshr_retired_valid_sx(mshr_retired_valid_sx),
            .mshr_retired_idx_sx(mshr_retired_idx_sx),        
            .arid_sx(ARID),
            .araddr_sx(ARADDR),
            .arlen_sx(ARLEN),
            .arsize_sx(ARSIZE),
            .arburst_sx(ARBURST),
            .arlock_sx(ARLOCK),
            .arcache_sx(ARCACHE),
            .arprot_sx(ARPROT),
            .arqos_sx(ARQOS),
            .arregion_sx(ARREGION),
            .arvalid_sx(ARVALID),
            .arready_sx(ARREADY),     
            .awid_sx(AWID),
            .awaddr_sx(AWADDR),
            .awlen_sx(AWLEN),
            .awsize_sx(AWSIZE),
            .awburst_sx(AWBURST),
            .awlock_sx(AWLOCK),
            .awcache_sx(AWCACHE),
            .awprot_sx(AWPROT),
            .awqos_sx(AWQOS),
            .awregion_sx(AWREGION),
            .awvalid_sx(AWVALID),
            .awready_sx(AWREADY),     
            .bid_sx(BID),
            .bresp_sx(BRESP),
            .bvalid_sx(BVALID),
            .bready_sx(BREADY)
        );

endmodule
