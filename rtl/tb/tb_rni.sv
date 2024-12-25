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

// Mode Support
// 1. NULL 
// 2. AW_TEST_EN
// 3. AR_TEST_EN
// 4. AR_TEST_EN,AW_TEST_EN
// 5. AR_TEST_EN,AW_TEST_EN,AW_AFTER_AR_EN

`define AW_TEST_EN
`define AR_TEST_EN
// `define AW_AFTER_AR_EN

module tb_rni;
    parameter AXI4_PA_WIDTH_PARAM                = 44;
    parameter AXI4_AXDATA_WIDTH_PARAM            = 128;
    parameter CHIE_NID_WIDTH_PARAM               = 11;
    parameter CHIE_REQ_RSVDC_WIDTH_PARAM         = 0;
    parameter CHIE_DAT_RSVDC_WIDTH_PARAM         = 0;
    parameter CHIE_REQ_ADDR_WIDTH_PARAM          = 44;
    parameter CHIE_SNP_ADDR_WIDTH_PARAM          = 41;
    parameter CHIE_PA_WIDTH_PARAM                = 44;
    parameter CHIE_DATA_WIDTH_PARAM              = 256;
    parameter CHIE_BE_WIDTH_PARAM                = 32;
    parameter CHIE_POISON_WIDTH_PARAM            = 0;
    parameter CHIE_DATACHECK_WIDTH_PARAM         = 0;
    parameter RNI_AR_ENTRIES_NUM_PARAM           = 32;
    parameter RNI_AW_ENTRIES_NUM_PARAM           = 32;
    parameter HNF_NID_PARAM                      = 0; 
    parameter RNI_NID_PARAM                      = 6;  

    // reg
    reg                                         clk;
    reg                                         rst;
    reg                                         SIM_DONE;
    reg                                         AW_SIM_DONE;
    reg                                         AR_SIM_DONE;
    reg                                         INIT_DONE;
    reg [10:0]                                  AWID0;
    reg [44-1:0]                                AWADDR0;
    reg [7:0]                                   AWLEN0;
    reg [2:0]                                   AWSIZE0;
    reg [1:0]                                   AWBURST0;
    reg [0:0]                                   AWLOCK0;
    reg [3:0]                                   AWCACHE0;
    reg [2:0]                                   AWPROT0;
    reg [3:0]                                   AWREGION0;
    reg [3:0]                                   AWQOS0;
    reg                                         AWVALID0;
    reg                                         AWREADY0;
    reg [AXI4_AXDATA_WIDTH_PARAM-1:0]           WDATA0;
    reg [(AXI4_AXDATA_WIDTH_PARAM/8)-1:0]       WSTRB0;
    reg                                         WLAST0;
    reg                                         WVALID0;
    reg                                         WREADY0;
    reg                                         BREADY0;
    reg                                         BVALID0;
    reg                                         RREADY0;
    reg [10:0]                                  ARID0;
    reg [44-1:0]                                ARADDR0;
    reg [7:0]                                   ARLEN0;
    reg [2:0]                                   ARSIZE0;
    reg [1:0]                                   ARBURST0;
    reg [0:0]                                   ARLOCK0;
    reg [3:0]                                   ARCACHE0;
    reg [2:0]                                   ARPROT0;
    reg [3:0]                                   ARREGION0;
    reg [3:0]                                   ARQOS0;
    reg                                         ARVALID0;
    reg                                         ARREADY0;
    wire                                        RVALID0;
    wire                                        RLAST0;
    reg                                         TXRSPFLITV;
    reg                                         TXRSPLCRDV;
    reg                                         TXDATFLITV;
    reg                                         TXDATLCRDV;
    reg                                         TXREQFLITV;
    reg [`CHIE_REQ_FLIT_RANGE]                  TXREQFLIT;
    reg [`CHIE_RSP_FLIT_RANGE]                  TXRSPFLIT;
    reg [`CHIE_DAT_FLIT_RANGE]                  TXDATFLIT;
    reg                                         TXREQLCRDV;
    reg [`CHIE_RSP_FLIT_RANGE]                  RXRSPFLIT;
    reg [`CHIE_RSP_FLIT_RANGE]                  rxrspflit_tmp;
    reg                                         RXRSPFLITV;
    reg                                         RXDATFLITV;
    reg [`CHIE_DAT_FLIT_RANGE]                  RXDATFLIT;
    reg [`CHIE_DAT_FLIT_RANGE]                  rxdatflit_tmp;
    reg [(AXI4_AXDATA_WIDTH_PARAM/8)-1:0]       wstrb0;
    reg [32-1:0]                                wdata_cnt;
    reg [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]        txnid_r1[0:RNI_AR_ENTRIES_NUM_PARAM-1];
    reg [RNI_AR_ENTRIES_NUM_PARAM-1:0]          r_entry_v;
    reg [32-1:0]                                r0;
    reg [32-1:0]                                r1;
    reg [`CHIE_REQ_FLIT_TXNID_WIDTH-1:0]        txnid_w1[0:RNI_AW_ENTRIES_NUM_PARAM-1];
    reg [RNI_AW_ENTRIES_NUM_PARAM-1:0]          w_entry_v;
    reg [32-1:0]                                dbid_sent_v;
    reg [32-1:0]                                w0;
    reg [32-1:0]                                w1;
    reg [32-1:0]                                w2;
    reg [32-1:0]                                aw_cnt;
    reg [32-1:0]                                ar_cnt;
    reg [CHIE_PA_WIDTH_PARAM-1:0]               r_addr_tmp;
    reg [CHIE_PA_WIDTH_PARAM-1:0]               w_addr_tmp;
    reg                                         TXLINKACTIVEACK;
    reg                                         RXLINKACTIVEREQ;

    // wire
    wire                                        TXLINKACTIVEREQ;

    rni #(
        .AXI4_PA_WIDTH_PARAM            (AXI4_PA_WIDTH_PARAM         ),
        .AXI4_AXDATA_WIDTH_PARAM        (AXI4_AXDATA_WIDTH_PARAM     ),
        .CHIE_NID_WIDTH_PARAM           (CHIE_NID_WIDTH_PARAM        ),
        .CHIE_REQ_RSVDC_WIDTH_PARAM     (CHIE_REQ_RSVDC_WIDTH_PARAM  ),
        .CHIE_DAT_RSVDC_WIDTH_PARAM     (CHIE_DAT_RSVDC_WIDTH_PARAM  ),
        .CHIE_REQ_ADDR_WIDTH_PARAM      (CHIE_REQ_ADDR_WIDTH_PARAM   ),
        .CHIE_SNP_ADDR_WIDTH_PARAM      (CHIE_SNP_ADDR_WIDTH_PARAM   ),
        .CHIE_PA_WIDTH_PARAM            (CHIE_PA_WIDTH_PARAM         ),
        .CHIE_DATA_WIDTH_PARAM          (CHIE_DATA_WIDTH_PARAM       ),
        .CHIE_BE_WIDTH_PARAM            (CHIE_BE_WIDTH_PARAM         ),
        .CHIE_POISON_WIDTH_PARAM        (CHIE_POISON_WIDTH_PARAM     ),
        .CHIE_DATACHECK_WIDTH_PARAM     (CHIE_DATACHECK_WIDTH_PARAM  ),
        .RNI_AR_ENTRIES_NUM_PARAM       (RNI_AR_ENTRIES_NUM_PARAM    ),
        .RNI_AW_ENTRIES_NUM_PARAM       (RNI_AW_ENTRIES_NUM_PARAM    ),
        .HNF_NID_PARAM                  (HNF_NID_PARAM               ),
        .RNI_NID_PARAM                  (RNI_NID_PARAM               )
    )rni_inst(
        .CLK                            ( clk                        ),
        .RST                            ( rst                        ),
        .TXLINKACTIVEREQ                ( TXLINKACTIVEREQ            ),
        .TXLINKACTIVEACK                ( TXLINKACTIVEACK            ),
        .RXLINKACTIVEREQ                ( RXLINKACTIVEREQ            ),
        .RXLINKACTIVEACK                (                            ),
        .RXRSPFLITPEND                  ( 1'b1                       ),
        .RXRSPFLITV                     ( RXRSPFLITV                 ),
        .RXRSPFLIT                      ( RXRSPFLIT                  ),
        .RXRSPLCRDV                     (                            ),
        .RXDATFLITPEND                  ( 1'b1                       ),
        .RXDATFLITV                     ( RXDATFLITV                 ),
        .RXDATFLIT                      ( RXDATFLIT                  ),
        .RXDATLCRDV                     (                            ),
        .TXRSPFLITPEND                  (                            ),
        .TXRSPFLITV                     ( TXRSPFLITV                 ),
        .TXRSPFLIT                      ( TXRSPFLIT                  ),
        .TXRSPLCRDV                     ( TXRSPLCRDV                 ),
        .TXDATFLITPEND                  (                            ),
        .TXDATFLITV                     ( TXDATFLITV                 ),
        .TXDATFLIT                      ( TXDATFLIT                  ),
        .TXDATLCRDV                     ( TXDATLCRDV                 ),
        .TXREQFLITPEND                  (                            ),
        .TXREQFLITV                     ( TXREQFLITV                 ),
        .TXREQFLIT                      ( TXREQFLIT                  ),
        .TXREQLCRDV                     ( TXREQLCRDV                 ),
        .AWID0                          ( AWID0                      ),
        .AWADDR0                        ( AWADDR0                    ),
        .AWLEN0                         ( AWLEN0                     ),
        .AWSIZE0                        ( AWSIZE0                    ),
        .AWBURST0                       ( AWBURST0                   ),
        .AWLOCK0                        ( AWLOCK0                    ),
        .AWCACHE0                       ( AWCACHE0                   ),
        .AWPROT0                        ( AWPROT0                    ),
        .AWQOS0                         ( AWQOS0                     ),
        .AWREGION0                      ( AWREGION0                  ),
        .AWVALID0                       ( AWVALID0                   ),
        .AWREADY0                       ( AWREADY0                   ),
        .WDATA0                         ( WDATA0                     ),
        .WSTRB0                         ( WSTRB0                     ),
        .WLAST0                         ( WLAST0                     ),
        .WVALID0                        ( WVALID0                    ),
        .WREADY0                        ( WREADY0                    ),
        .BID0                           (                            ),
        .BRESP0                         (                            ),
        .BVALID0                        ( BVALID0                    ),
        .BREADY0                        ( BREADY0                    ),
        .ARID0                          ( ARID0                      ),
        .ARADDR0                        ( ARADDR0                    ),
        .ARLEN0                         ( ARLEN0                     ),
        .ARSIZE0                        ( ARSIZE0                    ),
        .ARBURST0                       ( ARBURST0                   ),
        .ARLOCK0                        ( ARLOCK0                    ),
        .ARCACHE0                       ( ARCACHE0                   ),
        .ARPROT0                        ( ARPROT0                    ),
        .ARQOS0                         ( ARQOS0                     ),
        .ARREGION0                      ( ARREGION0                  ),
        .ARVALID0                       ( ARVALID0                   ),
        .ARREADY0                       ( ARREADY0                   ),
        .RID0                           (                            ),
        .RDATA0                         (                            ),
        .RRESP0                         (                            ),
        .RLAST0                         ( RLAST0                     ),
        .RVALID0                        ( RVALID0                    ),
        .RREADY0                        ( RREADY0                    )
    );

// Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 10ns clock period
    end

// Reset generation
    initial begin
        rst = 1;
        #85 rst = 0;
    end

// Initialization
    initial begin
        SIM_DONE    = 0;
    `ifdef AW_TEST_EN
        AW_SIM_DONE = 0;
    `else
        AW_SIM_DONE = 1;
    `endif

    `ifdef AR_TEST_EN
        AR_SIM_DONE = 0;
    `else
        AR_SIM_DONE = 1;
    `endif
        INIT_DONE   = 0;
        AWID0       = 0;
        AWADDR0     = 0;
        AWLEN0      = 0;
        AWSIZE0     = 0;
        AWBURST0    = 0;
        AWLOCK0     = 0;
        AWCACHE0    = 0;
        AWPROT0     = 0;
        AWQOS0      = 0;
        AWREGION0   = 0;
        AWVALID0    = 0;
        BREADY0     = 1;
        RREADY0     = 1;
        ARID0       = 0;
        ARADDR0     = 0;
        ARLEN0      = 0;
        ARSIZE0     = 0;
        ARBURST0    = 0;
        ARLOCK0     = 0;
        ARCACHE0    = 0;
        ARPROT0     = 0;
        ARREGION0   = 0;
        ARQOS0      = 0;
        ARVALID0    = 0;
        TXRSPLCRDV  = 0;
        TXDATLCRDV  = 0;
        TXREQLCRDV  = 0;
        RXRSPFLITV  = 0;
        RXRSPFLIT   = 0;
        RXDATFLITV  = 0;
        RXDATFLIT   = 0;
        wdata_cnt   = 0;
        aw_cnt      = 1;
        wait(!rst);
        repeat (50) @(posedge clk);
        // send 4 lcrd
        TXRSPLCRDV  <= 1;
        TXDATLCRDV  <= 1;
        TXREQLCRDV  <= 1;
        repeat (4) @(posedge clk);
        TXRSPLCRDV  <= 0;
        TXDATLCRDV  <= 0;
        TXREQLCRDV  <= 0;
        INIT_DONE    = 1;
    end
    // link initialization
    always @(posedge clk or posedge rst)begin
        if(rst == 1'b1)
            TXLINKACTIVEACK <= 1'b0;
        else if(!TXLINKACTIVEREQ)
            TXLINKACTIVEACK <= 1'b0;
        else if(TXLINKACTIVEREQ)
            TXLINKACTIVEACK <= 1'b1;
        else;
    end

    always @(posedge clk or posedge rst) begin
        if(rst == 1'b1)
            RXLINKACTIVEREQ <= 1'b1;
        else if(SIM_DONE)
            RXLINKACTIVEREQ <= 1'b0;
        else;
    end

    // send lcrdv after get txflit
    initial begin
        wait(INIT_DONE);
        forever @(posedge clk) begin
            if(TXDATFLITV & (TXDATFLIT[`CHIE_DAT_FLIT_OPCODE_RANGE] !== `CHIE_DATLCRDRETURN))
                TXDATLCRDV  <= 1;
            else
                TXDATLCRDV  <= 0;
            if(TXRSPFLITV & (TXRSPFLIT[`CHIE_RSP_FLIT_OPCODE_RANGE] !== `CHIE_RSPLCRDRETURN))
                TXRSPLCRDV  <= 1;
            else
                TXRSPLCRDV  <= 0;
            if(TXREQFLITV & (TXREQFLIT[`CHIE_REQ_FLIT_OPCODE_RANGE] !== `CHIE_REQLCRDRETURN))
                TXREQLCRDV  <= 1;
            else
                TXREQLCRDV  <= 0;
        end
    end

    initial begin
        wait(SIM_DONE);
        repeat(15)@(posedge clk) begin
            RXRSPFLITV <= 1;
            RXRSPFLIT  <= 'd0;
            RXDATFLITV <= 1;
            RXDATFLIT  <= 'd0;
        end
        @(posedge clk)
        RXRSPFLITV <= 0;
        RXDATFLITV <= 0;
    end

// AR test sequence
`ifdef AR_TEST_EN
    initial begin
        wait(INIT_DONE);
    // Fixed base test
    //
    // Test Sequence 1
    //      Len     = 1
    //      Size    = 16 bytes
    //      Burst   = FIXED
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h10
    // SIZE: 4 
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b010000;
        ARLEN0        <= 8'b00000000;
        ARSIZE0       <= 3'b100;
        ARBURST0      <= 2'b00;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 3
    //      Size    = 16 bytes
    //      Burst   = FIXED
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h10
    // SIZE: 4 
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b010000;
        ARLEN0        <= 8'b00000010;
        ARSIZE0       <= 3'b100;
        ARBURST0      <= 2'b00;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 3
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = FIXED
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h18
    // SIZE: 2 
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b011000;
        ARLEN0        <= 8'b00000011;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b00;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        wait(RVALID0 & RLAST0)begin
            @(posedge clk);
        end
    // Test Sequence 4
    //      Len     = 14
    //      Size    = 4 bytes
    //      Burst   = FIXED
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h18
    // SIZE: 2 
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b011000;
        ARLEN0        <= 8'b00001101;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b00;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Wrap base test
    //
    // Test Sequence 1
    //      Len     = 1
    //      Size    = 16 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h20
    // SIZE: 4 
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b100000;
        ARLEN0        <= 8'b00000000;
        ARSIZE0       <= 3'b100;
        ARBURST0      <= 2'b10;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 8
    //      Size    = 16 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1 - 1 - 1
    // TXDATFLIT: 2 - 2 - 2
    // ADDR: 'h20 - 'h40 - 'h00
    // SIZE: 5 - 6 - 5
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b100000;
        ARLEN0        <= 8'b00000111;
        ARSIZE0       <= 3'b100;
        ARBURST0      <= 2'b10;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 3
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h04 - 'h00
    // SIZE: 4 - 4
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b000100;
        ARLEN0        <= 8'b00000011;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b10;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 4
    //      Len     = 16
    //      Size    = 4 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h04 - 'h00
    // SIZE: 6 - 4
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b000100;
        ARLEN0        <= 8'b00001111;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b10;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 5
    //      Len     = 16
    //      Size    = 4 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 1
    // ADDR: 'h31 - 'h00
    // SIZE: 6 - 6
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b110001;
        ARLEN0        <= 8'b00001111;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b10;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Incr aligned base test
    //
    // Test Sequence 1
    //      Len     = 4
    //      Size    = 8 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h08
    // SIZE: 6
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b001000;
        ARLEN0        <= 8'b00000011;
        ARSIZE0       <= 3'b011;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 7
    //      Size    = 8 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h08
    // SIZE: 6
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b001000;
        ARLEN0        <= 8'b00000110;
        ARSIZE0       <= 3'b011;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 3
    //      Len     = 3
    //      Size    = 2 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h06
    // SIZE: 4
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b000110;
        ARLEN0        <= 8'b00000010;
        ARSIZE0       <= 3'b001;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 4
    //      Len     = 14
    //      Size    = 2 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h06
    // SIZE: 6
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b000110;
        ARLEN0        <= 8'b00001101;
        ARSIZE0       <= 3'b001;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 5
    //      Len     = 20
    //      Size    = 1 bytes
    //      Burst   = INCR 
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h1D
    // SIZE: 6
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b011101;
        ARLEN0        <= 8'b00010011;
        ARSIZE0       <= 3'b000;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 6
    //      Len     = 64
    //      Size    = 1 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h1D - 'h40
    // SIZE: 6 - 5
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b011101;
        ARLEN0        <= 8'b00111111;
        ARSIZE0       <= 3'b000;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    //Incr unaligned base test
    // Test Sequence 1
    //      Len     = 4
    //      Size    = 16 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h01
    // SIZE: 6
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b000001;
        ARLEN0        <= 8'b00000011;
        ARSIZE0       <= 3'b100;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 15
    //      Size    = 16 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1 - 1 - 1
    // TXDATFLIT: 2 - 2 - 2 - 2
    // ADDR: 'h01 - 'h40 - 'h80 - 'hC0
    // SIZE: 6 - 6 - 6 - 6
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b000001;
        ARLEN0        <= 8'b00001110;
        ARSIZE0       <= 3'b100;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 3
    //      Len     = 2
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 1
    // ADDR: 'h15
    // SIZE: 4
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b010101;
        ARLEN0        <= 8'b00000001;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 4
    //      Len     = 9
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h15
    // SIZE: 6
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b010101;
        ARLEN0        <= 8'b00001000;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Two Read with same ID
    //
    // Test Sequence 1
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h00
    // SIZE: 2
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b000000;
        ARLEN0        <= 8'b00000011;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h00
    // SIZE: 2
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b0000000;
        ARLEN0        <= 8'b00000011;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARADDR0       <= 'b1100000;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Two Read with diff ID
    //
    // Test Sequence 1
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h00
    // SIZE: 2
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b000000;
        ARLEN0        <= 8'b00000011;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARID0         <= 1;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h00
    // SIZE: 2
        wait(ARREADY0);
        ARID0         <= 0;
        ARADDR0       <= 'b0000000;
        ARLEN0        <= 8'b00000011;
        ARSIZE0       <= 3'b010;
        ARBURST0      <= 2'b01;
        ARLOCK0       <= 0;
        ARCACHE0      <= 4'b1011;
        ARPROT0       <= 0;
        ARREGION0     <= 0;
        ARQOS0        <= 0;
        ARVALID0      <= 1;
        @(posedge clk);
        ARID0         <= 1;
        ARADDR0       <= 'b1100000;
        @(posedge clk);
        ARVALID0      <= 0;
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
        for(int i=0;i<ARLEN0;i++)begin
            while (!RVALID0)begin
                @(posedge clk);
            end
        end
        while (!(RVALID0 & RLAST0)) begin
            @(posedge clk);
        end
        AR_SIM_DONE = 1;
    end

    // Get TxnID
    initial begin
        r0 = 0;
        r_entry_v <= 0;;
        forever @(posedge clk) begin
            if(TXREQFLITV & ~TXREQFLIT[`CHIE_REQ_FLIT_TXNID_MSB] & (TXREQFLIT[`CHIE_REQ_FLIT_OPCODE_RANGE] !== `CHIE_REQLCRDRETURN))begin
                txnid_r1[r0]  <= TXREQFLIT[`CHIE_REQ_FLIT_TXNID_RANGE];
                r_entry_v[r0] <= 1; 
                if(r0 == (RNI_AR_ENTRIES_NUM_PARAM-1))begin
                    r0 <= 0;
                end
                else begin
                    r0 <= r0 + 1;
                end
            end
        end
    end

    // send CompData
    initial begin
        r1 = 0;
        forever @(posedge clk) begin
            RXDATFLITV <= 1'b0;
            if(r_entry_v[r1])begin
                repeat (10) @(posedge clk);
                rxdatflit_tmp[`CHIE_DAT_FLIT_RANGE]        = {`CHIE_DAT_FLIT_WIDTH{1'b0}};
                rxdatflit_tmp[`CHIE_DAT_FLIT_TGTID_RANGE]  = RNI_NID_PARAM;
                rxdatflit_tmp[`CHIE_DAT_FLIT_SRCID_RANGE]  = HNF_NID_PARAM;
                rxdatflit_tmp[`CHIE_DAT_FLIT_TXNID_RANGE]  = txnid_r1[r1];
                rxdatflit_tmp[`CHIE_DAT_FLIT_OPCODE_RANGE] = `CHIE_COMPDATA;
                rxdatflit_tmp[`CHIE_DAT_FLIT_DATAID_RANGE] = 2'b00;
                rxdatflit_tmp[`CHIE_DAT_FLIT_BE_RANGE]     = 32'hffffffff;
                rxdatflit_tmp[`CHIE_DAT_FLIT_DATA_RANGE]   = 256'hffffffffffffffff1111111111111111cccccccccccccccc0123456789abcdef;
                RXDATFLITV <= 1'b1;
                RXDATFLIT  <= rxdatflit_tmp;
                @(posedge clk);
                rxdatflit_tmp[`CHIE_DAT_FLIT_DATAID_RANGE] = 2'b10;
                rxdatflit_tmp[`CHIE_DAT_FLIT_DATA_RANGE]   = 256'heeeeeeeeeeeeeeee3333333333333333000000000000000002468ace13579bdf;
                RXDATFLITV <= 1'b1;
                RXDATFLIT  <= rxdatflit_tmp;
                r_entry_v[r1] <= 0; 
                if(r1 == (RNI_AR_ENTRIES_NUM_PARAM-1))begin
                    r1 <= 0;
                end
                else begin
                    r1 <= r1 + 1;
                end
            end
        end
    end
`endif


// AW test sequence
`ifdef AW_TEST_EN
    initial begin
        wait(INIT_DONE);
    `ifdef AW_AFTER_AR_EN
        wait(AR_SIM_DONE);
    `endif
    // Fixed base test
    //
    // Test Sequence 1
    //      Len     = 1
    //      Size    = 16 bytes
    //      Burst   = FIXED
    // TXREQFLIT: 1
    // TXDATFLIT: 1
    // ADDR: 'h10
    // SIZE: 4 
    // ----------------
    // >--------------<
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b010000;
        AWLEN0      <= 8'b00000000;
        AWSIZE0     <= 3'b100;
        AWBURST0    <= 2'b00;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'hffff;
        aw_cnt       = 1;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 3
    //      Size    = 16 bytes
    //      Burst   = FIXED
    // TXREQFLIT: 1
    // TXDATFLIT: 1
    // ADDR: 'h10
    // SIZE: 4 
    // ----------------
    // >--------------<
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b010000;
        AWLEN0      <= 8'b00000010;
        AWSIZE0     <= 3'b100;
        AWBURST0    <= 2'b00;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'hffff;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 3
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = FIXED
    // TXREQFLIT: 1
    // TXDATFLIT: 1
    // ADDR: 'h18
    // SIZE: 2 
    // ----------------
    // ---->--<--------
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b011000;
        AWLEN0      <= 8'b00000011;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b00;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h000f;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 4
    //      Len     = 14
    //      Size    = 4 bytes
    //      Burst   = FIXED
    // TXREQFLIT: 1
    // TXDATFLIT: 1
    // ADDR: 'h18
    // SIZE: 2 
    // ----------------
    // ---->--<--------
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b010100;
        AWLEN0      <= 8'b00001101;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b00;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h000f;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Wrap base test
    //
    // Test Sequence 1
    //      Len     = 1
    //      Size    = 16 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1
    // TXDATFLIT: 1
    // ADDR: 'h20
    // SIZE: 4 
    // ----------------
    // ----------------
    // >--------------<
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b100000;
        AWLEN0      <= 8'b00000000;
        AWSIZE0     <= 3'b100;
        AWBURST0    <= 2'b10;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'hffff;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 8
    //      Size    = 16 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1 - 1 - 1
    // TXDATFLIT: 1 - 2 - 1
    // ADDR: 'h20 - 'h40 - 'h00
    // SIZE: 5 - 6 - 5
    // ----------------
    // >---------------
    // ---------------<
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b100000;
        AWLEN0      <= 8'b00000111;
        AWSIZE0     <= 3'b100;
        AWBURST0    <= 2'b10;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'hffff;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 3
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 1 - 1
    // ADDR: 'h04 - 'h00
    // SIZE: 4 - 4
    // -----------<----
    // ------------>---
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b000100;
        AWLEN0      <= 8'b00000011;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b10;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h000f;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 4
    //      Len     = 16
    //      Size    = 4 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 1
    // ADDR: 'h04 - 'h00
    // SIZE: 6 - 4
    // -----------<>---
    // ----------------
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b000100;
        AWLEN0      <= 8'b00001111;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b10;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h000f;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 5
    //      Len     = 16
    //      Size    = 4 bytes
    //      Burst   = WRAP
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 1
    // ADDR: 'h31 - 'h00
    // SIZE: 4 - 6
    // -----------<>---
    // ----------------
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b110001;
        AWLEN0      <= 8'b00001111;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b10;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h000f;
        aw_cnt       = 1;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Incr aligned base test
    //
    // Test Sequence 1
    //      Len     = 4
    //      Size    = 8 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h08
    // SIZE: 6
    // -------<--------
    // ----------------
    // ----------------
    // -------->-------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b001000;
        AWLEN0      <= 8'b00000011;
        AWSIZE0     <= 3'b011;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'hff00;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 7
    //      Size    = 8 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h08
    // SIZE: 6
    // -------<--------
    // -------->-------
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b001000;
        AWLEN0      <= 8'b00000110;
        AWSIZE0     <= 3'b011;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'hff00;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 3
    //      Len     = 3
    //      Size    = 2 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 1
    // ADDR: 'h06
    // SIZE: 4
    // ---->----<------
    // ----------------
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b000110;
        AWLEN0      <= 8'b00000010;
        AWSIZE0     <= 3'b001;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h0ff0;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 4
    //      Len     = 14
    //      Size    = 2 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h06
    // SIZE: 6
    // ---------<------
    // ----------------
    // -------------->-
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b000110;
        AWLEN0      <= 8'b00001101;
        AWSIZE0     <= 3'b001;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h0ff0;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 5
    //      Len     = 20
    //      Size    = 1 bytes
    //      Burst   = INCR 
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h1D
    // SIZE: 6
    // ----------------
    // --<-------------
    // ----------------
    // --------------->
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b011101;
        AWLEN0      <= 8'b00010011;
        AWSIZE0     <= 3'b000;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h0002;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 6
    //      Len     = 64
    //      Size    = 1 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 1
    // ADDR: 'h1D - 'h40
    // SIZE: 6 - 5
    // ----------------
    // --<>------------
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b011101;
        AWLEN0      <= 8'b01000000;
        AWSIZE0     <= 3'b000;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h0002;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Incr unaligned base test
    //
    // Test Sequence 1
    //      Len     = 4
    //      Size    = 16 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h01
    // SIZE: 6
    // --------------<>
    // ----------------
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b000001;
        AWLEN0      <= 8'b00000011;
        AWSIZE0     <= 3'b100;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'hffff;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 15
    //      Size    = 16 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1 - 1 - 1
    // TXDATFLIT: 2 - 2 - 2 - 2
    // ADDR: 'h01 - 'h40 - 'h80 - 'hC0
    // SIZE: 6 - 6 - 6 - 6
    // --------------<-
    // ----------------
    // ----------------
    // --------------->
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b000001;
        AWLEN0      <= 8'b00001110;
        AWSIZE0     <= 3'b100;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'hffff;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 3
    //      Len     = 2
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 1
    // ADDR: 'h15
    // SIZE: 4
    // ----------------
    // --->------<-----
    // ----------------
    // ----------------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b010101;
        AWLEN0      <= 8'b00000001;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h000f;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 4
    //      Len     = 9
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1
    // TXDATFLIT: 2
    // ADDR: 'h15
    // SIZE: 6
    // ----------------
    // ----------<-----
    // ----------------
    // ------->--------
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b010101;
        AWLEN0      <= 8'b00001000;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h000f;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Two write with same ID
    //
    // Test Sequence 1
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h00
    // SIZE: 2
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b0000000;
        AWLEN0      <= 8'b00000011;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h00ff;
        aw_cnt       = 2;
        @(posedge clk);
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
        @(posedge clk);
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h00
    // SIZE: 2
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b0000000;
        AWLEN0      <= 8'b00000011;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h00ff;
        @(posedge clk);
        AWADDR0     <= 'b1000000;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
        @(posedge clk);
        while(!BVALID0)begin
            @(posedge clk);
        end
        repeat (16) @(posedge clk);
    // Two write with diff ID
    //
    // Test Sequence 1
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h00
    // SIZE: 2
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b0000000;
        AWLEN0      <= 8'b00000011;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h00ff;
        @(posedge clk);
        AWID0       <= 1;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
        @(posedge clk);
        while(!BVALID0)begin
            @(posedge clk);
        end
    // Test Sequence 2
    //      Len     = 4
    //      Size    = 4 bytes
    //      Burst   = INCR
    // TXREQFLIT: 1 - 1
    // TXDATFLIT: 2 - 2
    // ADDR: 'h00
    // SIZE: 2
        wait(AWREADY0);
        AWID0       <= 0;
        AWADDR0     <= 'b0000000;
        AWLEN0      <= 8'b00000011;
        AWSIZE0     <= 3'b010;
        AWBURST0    <= 2'b01;
        AWLOCK0     <= 0;
        AWCACHE0    <= 4'b0111;
        AWPROT0     <= 0;
        AWQOS0      <= 0;
        AWVALID0    <= 1;
        wstrb0       = 'h00ff;
        @(posedge clk);
        AWID0       <= 1;
        AWADDR0     <= 'b1000000;
        @(posedge clk);
        AWVALID0    <= 0;
        while(!BVALID0)begin
            @(posedge clk);
        end
        @(posedge clk);
        while(!BVALID0)begin
            @(posedge clk);
        end
        AW_SIM_DONE = 1;
    end

    // Send Wdata
    initial begin
        forever @(posedge clk)begin
            while(AWVALID0 == 0)begin
                @(posedge clk);
            end
            repeat(aw_cnt) @(posedge clk)begin
                repeat (4) @(posedge clk);
                while (WREADY0 == 0) begin
                    @(posedge clk);
                end
                wdata_cnt    = 0;
                repeat (AWLEN0+1) @(posedge clk) begin
                    wdata_cnt = wdata_cnt + 1;
                    if(wdata_cnt == (AWLEN0+1))begin
                        WDATA0  <= 'hffffffffffffffffffffffffffffffff;
                        WSTRB0  <= wstrb0;
                        WLAST0  <= 1;
                        WVALID0 <= 1;
                    end
                    else begin
                        WDATA0  <= 'h11111111111111111111111111111111;
                        WSTRB0  <= wstrb0;
                        WLAST0  <= 0;
                        WVALID0 <= 1;
                    end
                    while (WREADY0 == 0) begin
                        @(posedge clk);
                    end
                end
                @(posedge clk);
                WVALID0     <= 0;
                WLAST0      <= 0;
            end
        end
    end

    // Get TxnID
    initial begin
        w0 <= 0;
        w_entry_v <= 0;
        forever @(posedge clk) begin
            if(TXREQFLITV & TXREQFLIT[`CHIE_REQ_FLIT_TXNID_MSB] & (TXREQFLIT[`CHIE_REQ_FLIT_OPCODE_RANGE] !== `CHIE_REQLCRDRETURN))begin
                txnid_w1[w0] <= TXREQFLIT[`CHIE_REQ_FLIT_TXNID_RANGE];
                w_entry_v[w0] <= 1; 
                if(w0 == (RNI_AW_ENTRIES_NUM_PARAM-1))begin
                    w0 <= 0;
                end
                else begin
                    w0 <= w0 + 1;
                end
            end
        end
    end

    // Send DBIDResp
    initial begin
        w1 <= 0;
        dbid_sent_v <= 0;
        forever @(posedge clk) begin
            if(w_entry_v[w1])begin
                repeat (9) @(posedge clk);
                rxrspflit_tmp[`CHIE_RSP_FLIT_RANGE]        = {`CHIE_RSP_FLIT_WIDTH{1'b0}};
                rxrspflit_tmp[`CHIE_RSP_FLIT_TGTID_RANGE]  = RNI_NID_PARAM;
                rxrspflit_tmp[`CHIE_RSP_FLIT_SRCID_RANGE]  = HNF_NID_PARAM;
                rxrspflit_tmp[`CHIE_RSP_FLIT_TXNID_RANGE]  = txnid_w1[w1];
                rxrspflit_tmp[`CHIE_RSP_FLIT_OPCODE_RANGE] = `CHIE_DBIDRESP;
                RXRSPFLITV <= 1'b1;
                RXRSPFLIT  <= rxrspflit_tmp;
                dbid_sent_v[w1] <= 1;
                w_entry_v[w1]   <= 0;
                if(w1 == (RNI_AW_ENTRIES_NUM_PARAM-1))begin
                    w1 <= 0;
                end
                else begin
                    w1 <= w1 + 1;
                end
                @(posedge clk);
                RXRSPFLITV <= 1'b0;
            end
        end
    end

    // Send Comp
    initial begin
        w2 <= 0;
        forever @(posedge clk) begin
            if(dbid_sent_v[w2])begin
                repeat (8) @(posedge clk);
                rxrspflit_tmp[`CHIE_RSP_FLIT_RANGE]        = {`CHIE_RSP_FLIT_WIDTH{1'b0}};
                rxrspflit_tmp[`CHIE_RSP_FLIT_TGTID_RANGE]  = RNI_NID_PARAM;
                rxrspflit_tmp[`CHIE_RSP_FLIT_SRCID_RANGE]  = HNF_NID_PARAM;
                rxrspflit_tmp[`CHIE_RSP_FLIT_TXNID_RANGE]  = txnid_w1[w2];
                rxrspflit_tmp[`CHIE_RSP_FLIT_OPCODE_RANGE] = `CHIE_COMP;
                RXRSPFLITV <= 1'b1;
                RXRSPFLIT  <= rxrspflit_tmp;
                dbid_sent_v[w2] <= 0;
                if(w2 == (RNI_AW_ENTRIES_NUM_PARAM-1))begin
                    w2 <= 0;
                end
                else begin
                    w2 <= w2 + 1;
                end
                @(posedge clk);
                RXRSPFLITV <= 1'b0;
            end
        end
    end
`endif


// Result check
    initial begin
        forever @(posedge clk) begin
            if($time >= 100000000) begin
                $display("\n\n\ERROR TIMEOUT at %0t", $time);
                $display("\n\n\
                #####################################################\n\
                test_result:FAILED  #################################\n\
                #####################################################\n\n");
                $finish;
            end
        end
    end

    initial begin
        wait(AW_SIM_DONE & AR_SIM_DONE);
        SIM_DONE = AW_SIM_DONE & AR_SIM_DONE;
        repeat (50) @(posedge clk);
        $display("\n\n\
        #####################################################\n\
        test_result:PASSED  #################################\n\
        #####################################################\n\n");
        $finish;
    end

// Waveform generation
    initial begin
       $fsdbDumpfile("tb_rni.fsdb");
       $fsdbDumpvars;
    //    $fsdbDumpMDA();
    end
endmodule