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

// Overview
// This module contains logic for rxdatflit -> rdata

`include "axi4_defines.v"
`include "chie_defines.v"
`include "rni_defines.v"
`include "rni_param.v"

module rni_rd_buffer `RNI_PARAM
    (
        //global port
        clk_i
        ,rst_i

        //from rni_link_ctl
        ,rxdatflitv_d1_i
        ,rxdatflit_d1_i

        //to rni_arctrl
        ,rxdatflitv_d1_o
        ,rxdatflit_txnid_d1_o
        ,rxdatflit_dataid_d1_o
        ,rp_fifo_acpt_d4_o

        //from rni_arctrl
        ,arctrl_rb_valid_d4_i
        ,arctrl_rb_idx_d4_i
        ,arctrl_rb_ctmask_d4_i
        ,arctrl_rb_rlast_d4_i
        ,arctrl_rb_rid_d4_i
        ,arctrl_rb_bc_d4_i

        //to rni_axi_bus
        ,R_CH_S0
        ,RVALID0
        ,RREADY0
    );
    //global port
    input  wire                                     clk_i;
    input  wire                                     rst_i;

    //from rni_link_ctl
    input  wire                                     rxdatflitv_d1_i;
    input  wire [`CHIE_DAT_FLIT_WIDTH-1:0]          rxdatflit_d1_i;

    //to rni_arctrl
    output wire                                     rxdatflitv_d1_o;
    output wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]    rxdatflit_txnid_d1_o;
    output wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]   rxdatflit_dataid_d1_o;
    output wire                                     rp_fifo_acpt_d4_o;

    //from rni_arctrl
    input  wire                                     arctrl_rb_valid_d4_i;
    input  wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]       arctrl_rb_idx_d4_i;
    input  wire [`RNI_DMASK_CT_WIDTH-1:0]           arctrl_rb_ctmask_d4_i;
    input  wire                                     arctrl_rb_rlast_d4_i;
    input  wire [`AXI4_RID_WIDTH-1:0]               arctrl_rb_rid_d4_i;
    input  wire [`RNI_BC_WIDTH-1:0]                 arctrl_rb_bc_d4_i;

    //to rni_axi_bus
    output wire [`AXI4_R_WIDTH-1:0]                 R_CH_S0;
    output wire                                     RVALID0;
    input  wire                                     RREADY0;

    //wire
    wire [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]           txnid_d1_w;
    wire [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]          dataid_d1_w;
    wire [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]            data_d1_w;
    wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]         resperr_d1_w;
    wire                                            rdata_last_d4_w;
    wire [`AXI4_RID_WIDTH-1:0]                      rdata_rid_d4_w;
    wire [`RNI_BC_WIDTH-1:0]                        rdata_bc_d4_w;
    wire                                            bank0_wr_en_d2_w;
    wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]              bank0_wr_addr_d2_w;
    wire [`RNI_RD_BANK_DATA_WIDTH-1:0]              bank0_wr_data_d2_w;
    wire                                            bank1_wr_en_d2_w;
    wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]              bank1_wr_addr_d2_w;
    wire [`RNI_RD_BANK_DATA_WIDTH-1:0]              bank1_wr_data_d2_w;
    wire                                            bank2_wr_en_d2_w;
    wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]              bank2_wr_addr_d2_w;
    wire [`RNI_RD_BANK_DATA_WIDTH-1:0]              bank2_wr_data_d2_w;
    wire                                            bank3_wr_en_d2_w;
    wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]              bank3_wr_addr_d2_w;
    wire [`RNI_RD_BANK_DATA_WIDTH-1:0]              bank3_wr_data_d2_w;
    wire                                            bank0_rd_en_d4_w;
    wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]              bank0_rd_addr_d4_w;
    wire [`RNI_RD_BANK_DATA_WIDTH-1:0]              bank0_rd_data_d4_w;
    wire                                            bank1_rd_en_d4_w;
    wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]              bank1_rd_addr_d4_w;
    wire [`RNI_RD_BANK_DATA_WIDTH-1:0]              bank1_rd_data_d4_w;
    wire                                            bank2_rd_en_d4_w;
    wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]              bank2_rd_addr_d4_w;
    wire [`RNI_RD_BANK_DATA_WIDTH-1:0]              bank2_rd_data_d4_w;
    wire                                            bank3_rd_en_d4_w;
    wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]              bank3_rd_addr_d4_w;
    wire [`RNI_RD_BANK_DATA_WIDTH-1:0]              bank3_rd_data_d4_w;
    wire [`RNI_RD_BANK_DATA_WIDTH-1:0]              data_bank_out_d4_w [`RNI_RD_BANK_NUM-1:0];
    wire [`RNI_RD_BANK_NUM-1:0]                     data_bank_vec_d4_w;
    wire [`RNI_DMASK_CT_WIDTH-1:0]                  data_bank_ctmask_d4_w;
    wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]              data_bank_idx_d4_w [`RNI_RD_BANK_NUM-1:0];
    wire [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]         data_bank_resperr_d4_w [`RNI_RD_BANK_NUM-1:0];
    wire [`RNI_RD_BANK_NUM-1:0]                     resperr_bank_wren_d2_w [RNI_AR_ENTRIES_NUM_PARAM-1:0];
    wire [`AXI4_RDATA_WIDTH-1:0]                    rdata_128_d4_w [`RNI_RD_BANK_NUM-1:0];
    wire [`AXI4_RDATA_WIDTH-1:0]                    rdata_256_d4_w [(`RNI_RD_BANK_NUM/2)-1:0];
    wire [`AXI4_RRESP_WIDTH-1:0]                    resperr_128_d4_w [`RNI_RD_BANK_NUM-1:0];
    wire [`AXI4_RRESP_WIDTH-1:0]                    resperr_256_d4_w [(`RNI_RD_BANK_NUM/2)-1:0];
    wire [`AXI4_RDATA_WIDTH-1:0]                    rdata_data_d4_w;
    wire [`AXI4_RRESP_WIDTH-1:0]                    rdata_resperr_d4_w;
    wire                                            rp_fifo_avail_d4_w;
    wire                                            rp_fifo_push_d4_w;
    wire                                            rp_fifo_pop_d5_w;
    wire [`AXI4_R_WIDTH+`RNI_BC_WIDTH-1:0]          rp_fifo_data_in_d4_w;
    wire [`AXI4_R_WIDTH+`RNI_BC_WIDTH-1:0]          rp_fifo_data_out_d5_w;
    wire                                            rp_fifo_empty_w;
    wire                                            rp_fifo_full_w;
    wire                                            bcount_v_d5_w;
    wire [`RNI_BC_WIDTH-1:0]                        bcount_d5_w;
    wire [`RNI_BC_WIDTH-1:0]                        bcount_w;
    wire                                            bcount_zero_w;
    wire                                            bcount_done_w;
    wire [`AXI4_R_WIDTH-1:0]                        rd_fifo_data_in_d5_w;
    wire [`AXI4_R_WIDTH-1:0]                        rd_fifo_data_out_d6_w;
    wire                                            rd_fifo_empty_w;
    wire                                            rd_fifo_full_w;
    wire                                            rd_fifo_push_d5_w;
    wire                                            rd_fifo_pop_d5_w;

    //reg
    reg                                             rxdatflitv_d2_q;
    reg  [`CHIE_DAT_FLIT_DATAID_WIDTH-1:0]          dataid_d2_q;
    reg  [`CHIE_DAT_FLIT_DATA_WIDTH-1:0]            data_d2_q;
    reg  [`CHIE_DAT_FLIT_TXNID_WIDTH-1:0]           txnid_d2_q;
    reg  [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]         resperr_d2_q;
    reg  [`CHIE_DAT_FLIT_RESPERR_WIDTH-1:0]         resperr_bank_d3_q [RNI_AR_ENTRIES_NUM_PARAM-1:0][`RNI_RD_BANK_NUM-1:0];
    reg  [`RNI_BC_WIDTH-1:0]                        bcount_q;

    genvar bank;
    genvar entry;

    //rxdatflit decode
    assign txnid_d1_w   = rxdatflit_d1_i [`CHIE_DAT_FLIT_TXNID_RANGE];
    assign dataid_d1_w  = rxdatflit_d1_i [`CHIE_DAT_FLIT_DATAID_RANGE];
    assign data_d1_w    = rxdatflit_d1_i [`CHIE_DAT_FLIT_DATA_RANGE];
    assign resperr_d1_w = rxdatflit_d1_i [`CHIE_DAT_FLIT_RESPERR_RANGE];

    //arctrl request decode
    assign rdata_rid_d4_w  = arctrl_rb_rid_d4_i;
    assign rdata_last_d4_w = arctrl_rb_rlast_d4_i;
    assign rdata_bc_d4_w   = arctrl_rb_bc_d4_i;

    //forward to rni_arctrl
    assign rxdatflitv_d1_o       = rxdatflitv_d1_i;
    assign rxdatflit_txnid_d1_o  = txnid_d1_w;
    assign rxdatflit_dataid_d1_o = dataid_d1_w;

    //forward to d2
    always @(posedge clk_i) begin
        rxdatflitv_d2_q  <= rxdatflitv_d1_i;
    end

    always @(posedge clk_i) begin
        if(rxdatflitv_d1_i == 1'b1) begin
            dataid_d2_q  <= dataid_d1_w;
            data_d2_q    <= data_d1_w;
            txnid_d2_q   <= txnid_d1_w;
            resperr_d2_q <= resperr_d1_w;
        end
    end

    //write data bank
generate if(CHIE_DATA_WIDTH_PARAM == 128)begin
            assign bank0_wr_en_d2_w   = (dataid_d2_q == 2'b00) & rxdatflitv_d2_q;
            assign bank0_wr_addr_d2_w = txnid_d2_q;
            assign bank0_wr_data_d2_w = data_d2_q;

            assign bank1_wr_en_d2_w   = (dataid_d2_q == 2'b01) & rxdatflitv_d2_q;
            assign bank1_wr_addr_d2_w = txnid_d2_q;
            assign bank1_wr_data_d2_w = data_d2_q;

            assign bank2_wr_en_d2_w   = (dataid_d2_q == 2'b10) & rxdatflitv_d2_q;
            assign bank2_wr_addr_d2_w = txnid_d2_q;
            assign bank2_wr_data_d2_w = data_d2_q;

            assign bank3_wr_en_d2_w   = (dataid_d2_q == 2'b11) & rxdatflitv_d2_q;
            assign bank3_wr_addr_d2_w = txnid_d2_q;
            assign bank3_wr_data_d2_w = data_d2_q;
        end
        else if(CHIE_DATA_WIDTH_PARAM == 256)begin
            assign bank0_wr_en_d2_w   = (dataid_d2_q == 2'b00) & rxdatflitv_d2_q;
            assign bank0_wr_addr_d2_w = txnid_d2_q;
            assign bank0_wr_data_d2_w = data_d2_q[127:0];

            assign bank1_wr_en_d2_w   = bank0_wr_en_d2_w;
            assign bank1_wr_addr_d2_w = txnid_d2_q;
            assign bank1_wr_data_d2_w = data_d2_q[255:128];

            assign bank2_wr_en_d2_w   = (dataid_d2_q == 2'b10) & rxdatflitv_d2_q;
            assign bank2_wr_addr_d2_w = txnid_d2_q;
            assign bank2_wr_data_d2_w = data_d2_q[127:0];

            assign bank3_wr_en_d2_w   = bank2_wr_en_d2_w;
            assign bank3_wr_addr_d2_w = txnid_d2_q;
            assign bank3_wr_data_d2_w = data_d2_q[255:128];
        end
        else if(CHIE_DATA_WIDTH_PARAM == 512)begin
            assign bank0_wr_en_d2_w   = (dataid_d2_q == 2'b00) & rxdatflitv_d2_q;
            assign bank0_wr_addr_d2_w = txnid_d2_q;
            assign bank0_wr_data_d2_w = data_d2_q[127:0];

            assign bank1_wr_en_d2_w   = bank0_wr_en_d2_w;
            assign bank1_wr_addr_d2_w = txnid_d2_q;
            assign bank1_wr_data_d2_w = data_d2_q[255:128];

            assign bank2_wr_en_d2_w   = bank0_wr_en_d2_w;
            assign bank2_wr_addr_d2_w = txnid_d2_q;
            assign bank2_wr_data_d2_w = data_d2_q[383:256];

            assign bank3_wr_en_d2_w   = bank0_wr_en_d2_w;
            assign bank3_wr_addr_d2_w = txnid_d2_q;
            assign bank3_wr_data_d2_w = data_d2_q[511:384];
        end
    endgenerate

    //write resperr bank
generate if(CHIE_DATA_WIDTH_PARAM == 128)begin
            for (entry=0; entry<RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1)begin
                for (bank=0; bank<`RNI_RD_BANK_NUM; bank=bank+1)begin
                    assign resperr_bank_wren_d2_w[entry][bank] = rxdatflitv_d2_q & (txnid_d2_q == entry) & (dataid_d2_q == bank);
                end
            end
        end
        else if(CHIE_DATA_WIDTH_PARAM == 256)begin
            for (entry=0; entry<RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1)begin
                for (bank=0; bank<`RNI_RD_BANK_NUM; bank=bank+2)begin
                    assign resperr_bank_wren_d2_w[entry][bank]   = rxdatflitv_d2_q & (txnid_d2_q == entry) & (dataid_d2_q == bank);
                    assign resperr_bank_wren_d2_w[entry][bank+1] = rxdatflitv_d2_q & (txnid_d2_q == entry) & ((dataid_d2_q+1) == bank+1);
                end
            end
        end
        else if(CHIE_DATA_WIDTH_PARAM == 512)begin
            for (entry=0; entry<RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1)begin
                for (bank=0; bank<`RNI_RD_BANK_NUM; bank=bank+1)begin
                    assign resperr_bank_wren_d2_w[entry][bank] = rxdatflitv_d2_q & (txnid_d2_q == entry) & (dataid_d2_q == 2'b00);
                end
            end
        end
    endgenerate

generate for (entry=0; entry<RNI_AR_ENTRIES_NUM_PARAM; entry=entry+1)begin
            for (bank=0; bank<`RNI_RD_BANK_NUM; bank=bank+1)begin
                always @(posedge clk_i)begin
                    if (resperr_bank_wren_d2_w[entry][bank] == 1'b1)
                        resperr_bank_d3_q[entry][bank] <= resperr_d2_q;
                end
            end
        end
    endgenerate

    //read data and resperr bank
    assign rp_fifo_avail_d4_w = ~rp_fifo_full_w;

    generate
        for (bank=0; bank<`RNI_RD_BANK_NUM; bank=bank+1) begin
            assign data_bank_vec_d4_w[bank]     = arctrl_rb_valid_d4_i & rp_fifo_avail_d4_w & arctrl_rb_ctmask_d4_i[bank];
            assign data_bank_ctmask_d4_w[bank]  = data_bank_vec_d4_w[bank]? arctrl_rb_ctmask_d4_i[bank] : 0;
            assign data_bank_idx_d4_w[bank]     = data_bank_vec_d4_w[bank]? arctrl_rb_idx_d4_i : 0;
            assign data_bank_resperr_d4_w[bank] = data_bank_vec_d4_w[bank]? resperr_bank_d3_q[arctrl_rb_idx_d4_i][bank] : 0;
        end
    endgenerate

    assign rp_fifo_acpt_d4_o  = |data_bank_vec_d4_w;

    assign bank0_rd_en_d4_w   = data_bank_vec_d4_w[0];
    assign bank0_rd_addr_d4_w = data_bank_idx_d4_w[0];

    assign bank1_rd_en_d4_w   = data_bank_vec_d4_w[1];
    assign bank1_rd_addr_d4_w = data_bank_idx_d4_w[1];

    assign bank2_rd_en_d4_w   = data_bank_vec_d4_w[2];
    assign bank2_rd_addr_d4_w = data_bank_idx_d4_w[2];

    assign bank3_rd_en_d4_w   = data_bank_vec_d4_w[3];
    assign bank3_rd_addr_d4_w = data_bank_idx_d4_w[3];

    //read data buffer bank inst
    rni_datbuf_bank `RNI_PARAM_INST
                    rni_datbuf_bank_inst (

                        //global port
                        .clk_i             ( clk_i              )
                        ,.rst_i             ( rst_i              )

                        //bank0
                        ,.bank0_wr_en_i     ( bank0_wr_en_d2_w   )
                        ,.bank0_wr_addr_i   ( bank0_wr_addr_d2_w )
                        ,.bank0_wr_data_i   ( bank0_wr_data_d2_w )
                        ,.bank0_rd_en_i     ( bank0_rd_en_d4_w   )
                        ,.bank0_rd_addr_i   ( bank0_rd_addr_d4_w )
                        ,.bank0_rd_data_o   ( bank0_rd_data_d4_w )

                        //bank1
                        ,.bank1_wr_en_i     ( bank1_wr_en_d2_w   )
                        ,.bank1_wr_addr_i   ( bank1_wr_addr_d2_w )
                        ,.bank1_wr_data_i   ( bank1_wr_data_d2_w )
                        ,.bank1_rd_en_i     ( bank1_rd_en_d4_w   )
                        ,.bank1_rd_addr_i   ( bank1_rd_addr_d4_w )
                        ,.bank1_rd_data_o   ( bank1_rd_data_d4_w )

                        //bank2
                        ,.bank2_wr_en_i     ( bank2_wr_en_d2_w   )
                        ,.bank2_wr_addr_i   ( bank2_wr_addr_d2_w )
                        ,.bank2_wr_data_i   ( bank2_wr_data_d2_w )
                        ,.bank2_rd_en_i     ( bank2_rd_en_d4_w   )
                        ,.bank2_rd_addr_i   ( bank2_rd_addr_d4_w )
                        ,.bank2_rd_data_o   ( bank2_rd_data_d4_w )

                        //bank3
                        ,.bank3_wr_en_i     ( bank3_wr_en_d2_w   )
                        ,.bank3_wr_addr_i   ( bank3_wr_addr_d2_w )
                        ,.bank3_wr_data_i   ( bank3_wr_data_d2_w )
                        ,.bank3_rd_en_i     ( bank3_rd_en_d4_w   )
                        ,.bank3_rd_addr_i   ( bank3_rd_addr_d4_w )
                        ,.bank3_rd_data_o   ( bank3_rd_data_d4_w )
                    );

    assign data_bank_out_d4_w[0] = bank0_rd_data_d4_w;
    assign data_bank_out_d4_w[1] = bank1_rd_data_d4_w;
    assign data_bank_out_d4_w[2] = bank2_rd_data_d4_w;
    assign data_bank_out_d4_w[3] = bank3_rd_data_d4_w;

    //pack data and repserr into AXI form
generate if(AXI4_AXDATA_WIDTH_PARAM == 128)begin
            for (bank=0; bank<`RNI_RD_BANK_NUM; bank=bank+1) begin
                assign rdata_128_d4_w[bank]   = data_bank_out_d4_w[bank];
                assign resperr_128_d4_w[bank] = data_bank_resperr_d4_w[bank];
            end
            assign rdata_data_d4_w = {`AXI4_RDATA_WIDTH{data_bank_ctmask_d4_w[0]}} & rdata_128_d4_w[0] |
                   {`AXI4_RDATA_WIDTH{data_bank_ctmask_d4_w[1]}} & rdata_128_d4_w[1] |
                   {`AXI4_RDATA_WIDTH{data_bank_ctmask_d4_w[2]}} & rdata_128_d4_w[2] |
                   {`AXI4_RDATA_WIDTH{data_bank_ctmask_d4_w[3]}} & rdata_128_d4_w[3] ;

            assign rdata_resperr_d4_w = {`AXI4_RRESP_WIDTH{data_bank_ctmask_d4_w[0]}} & resperr_128_d4_w[0] |
                   {`AXI4_RRESP_WIDTH{data_bank_ctmask_d4_w[1]}} & resperr_128_d4_w[1] |
                   {`AXI4_RRESP_WIDTH{data_bank_ctmask_d4_w[2]}} & resperr_128_d4_w[2] |
                   {`AXI4_RRESP_WIDTH{data_bank_ctmask_d4_w[3]}} & resperr_128_d4_w[3] ;
        end
        else if(AXI4_AXDATA_WIDTH_PARAM == 256)begin
            for (bank=0; bank<`RNI_RD_BANK_NUM/2; bank=bank+1) begin
                assign rdata_256_d4_w[bank][127:0]   = data_bank_out_d4_w[bank*2];
                assign rdata_256_d4_w[bank][255:128] = data_bank_out_d4_w[(bank*2)+1];
                assign resperr_256_d4_w[bank]        = data_bank_resperr_d4_w[bank*2];
            end
            assign rdata_data_d4_w = {`AXI4_RDATA_WIDTH{data_bank_ctmask_d4_w[0] & data_bank_ctmask_d4_w[1]}} & rdata_256_d4_w[0] |
                   {`AXI4_RDATA_WIDTH{data_bank_ctmask_d4_w[2] & data_bank_ctmask_d4_w[3]}} & rdata_256_d4_w[1] ;

            assign rdata_resperr_d4_w = {`AXI4_RRESP_WIDTH{data_bank_ctmask_d4_w[0] & data_bank_ctmask_d4_w[1]}} & resperr_256_d4_w[0] |
                   {`AXI4_RRESP_WIDTH{data_bank_ctmask_d4_w[2] & data_bank_ctmask_d4_w[3]}} & resperr_256_d4_w[1] ;
        end
    endgenerate

    //R pending fifo
    assign rp_fifo_push_d4_w = rp_fifo_acpt_d4_o;
    assign rp_fifo_pop_d5_w  = ~rp_fifo_empty_w & bcount_done_w;

    assign rp_fifo_data_in_d4_w[`AXI4_RID_RANGE]   = rdata_rid_d4_w;
    assign rp_fifo_data_in_d4_w[`AXI4_RDATA_RANGE] = rdata_data_d4_w;
    assign rp_fifo_data_in_d4_w[`AXI4_RRESP_RANGE] = rdata_resperr_d4_w;
    assign rp_fifo_data_in_d4_w[`AXI4_RLAST_RANGE] = rdata_last_d4_w;
    assign rp_fifo_data_in_d4_w[`AXI4_RLAST_MSB+`RNI_BC_WIDTH:`AXI4_RLAST_MSB+1] = rdata_bc_d4_w;

    sync_fifo #(
                  .FIFO_ENTRIES_WIDTH ( `RNI_RP_FIFO_WIDTH    )
                  ,.FIFO_ENTRIES_DEPTH ( `RNI_RP_FIFO_DEPTH    )
                  ,.FIFO_BYP_ENABLE    ( 1'b0                  )
              ) rp_fifo_inst (
                  .clk                ( clk_i                 )
                  ,.rst                ( rst_i                 )
                  ,.push               ( rp_fifo_push_d4_w     )
                  ,.pop                ( rp_fifo_pop_d5_w      )
                  ,.data_in            ( rp_fifo_data_in_d4_w  )
                  ,.data_out           ( rp_fifo_data_out_d5_w )
                  ,.empty              ( rp_fifo_empty_w       )
                  ,.full               ( rp_fifo_full_w        )
                  ,.count              (                       )
              );

    //data beat count control
    assign bcount_v_d5_w = ~rp_fifo_empty_w & ~rd_fifo_full_w;
    assign bcount_d5_w   = rp_fifo_data_out_d5_w [`AXI4_RLAST_MSB+`RNI_BC_WIDTH:`AXI4_RLAST_MSB+1];
    assign bcount_w      = (bcount_q == {`RNI_BC_WIDTH{1'b0}}) ? bcount_d5_w : (bcount_q - 1'b1);

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i == 1'b1)
            bcount_q <= {`RNI_BC_WIDTH{1'b0}};
        else if (bcount_v_d5_w == 1'b1)
            bcount_q <= bcount_w;
    end

    assign bcount_zero_w = (bcount_d5_w == {`RNI_BC_WIDTH{1'b0}}) | (bcount_w == {`RNI_BC_WIDTH{1'b0}});
    assign bcount_done_w = bcount_v_d5_w & bcount_zero_w;

    //R dispath fifo
    assign rd_fifo_pop_d5_w  = RREADY0 & RVALID0;
    assign rd_fifo_push_d5_w = bcount_v_d5_w & ~rd_fifo_full_w;

    assign rd_fifo_data_in_d5_w[`AXI4_RID_RANGE]   = rp_fifo_data_out_d5_w[`AXI4_RID_RANGE];
    assign rd_fifo_data_in_d5_w[`AXI4_RDATA_RANGE] = rp_fifo_data_out_d5_w[`AXI4_RDATA_RANGE];
    assign rd_fifo_data_in_d5_w[`AXI4_RRESP_RANGE] = rp_fifo_data_out_d5_w[`AXI4_RRESP_RANGE];
    assign rd_fifo_data_in_d5_w[`AXI4_RLAST_RANGE] = rp_fifo_data_out_d5_w[`AXI4_RLAST_RANGE] & bcount_v_d5_w & bcount_zero_w;

    sync_fifo #(
                  .FIFO_ENTRIES_WIDTH ( `RNI_RD_FIFO_WIDTH    )
                  ,.FIFO_ENTRIES_DEPTH ( `RNI_RD_FIFO_DEPTH    )
                  ,.FIFO_BYP_ENABLE    ( 1'b0                  )
              ) rd_fifo (
                  .clk                ( clk_i                 )
                  ,.rst                ( rst_i                 )
                  ,.push               ( rd_fifo_push_d5_w     )
                  ,.pop                ( rd_fifo_pop_d5_w      )
                  ,.data_in            ( rd_fifo_data_in_d5_w  )
                  ,.data_out           ( rd_fifo_data_out_d6_w )
                  ,.empty              ( rd_fifo_empty_w       )
                  ,.full               ( rd_fifo_full_w        )
                  ,.count              (                       )
              );

    assign RVALID0 = ~rd_fifo_empty_w;
    assign R_CH_S0 = rd_fifo_data_out_d6_w;

    // Assertion Checker
`ifdef ASSERT_CHECKER_ON

    assert_checker #(
                       3,  // security_level
                       "CHIE_DATA_WIDTH_PARAM must be 256!")
                   CHIE_DATA_WIDTH_PARAM_check (
                       .clk   (clk_i),
                       .rst   (rst_i),
                       .cond  (CHIE_DATA_WIDTH_PARAM !== 256)
                   );

    assert_checker #(
                       3,  // security_level
                       "AXI4_AXDATA_WIDTH_PARAM must be 128!")
                   AXI4_AXDATA_WIDTH_PARAM_check (
                       .clk   (clk_i),
                       .rst   (rst_i),
                       .cond  (AXI4_AXDATA_WIDTH_PARAM !== 128)
                   );

    assert_checker #(
                       2,  // security_level
                       "arctrl_rb_ctmask_d4_i is ZERO!")
                   arctrl_rb_ctmask_d4_i_check (
                       .clk   (clk_i),
                       .rst   (rst_i),
                       .cond  (arctrl_rb_valid_d4_i & ~(|arctrl_rb_ctmask_d4_i))
                   );

    assert_checker #(
                       2,  // security_level
                       "RXDATFLIT opcode is NOT Compatible!")
                   rxdatflit_op_check (
                       .clk   (clk_i),
                       .rst   (rst_i),
                       .cond  (rxdatflitv_d1_i & (rxdatflit_d1_i[`CHIE_DAT_FLIT_OPCODE_RANGE] !== `CHIE_COMPDATA))
                   );

    assert_checker #(
                       2,  // security_level
                       "RXDATFLIT TgtID is NOT current NodeID!")
                   rxdatflit_tgtid_check (
                       .clk   (clk_i),
                       .rst   (rst_i),
                       .cond  (rxdatflitv_d1_i & (rxdatflit_d1_i[`CHIE_DAT_FLIT_TGTID_RANGE] !== RNI_NID_PARAM))
                   );

    assert_checker #(
                       2,  // security_level
                       "RXDATFLIT receive Data Error!")
                   rxdatflit_data_error_check (
                       .clk   (clk_i),
                       .rst   (rst_i),
                       .cond  (rxdatflitv_d1_i & (rxdatflit_d1_i[`CHIE_DAT_FLIT_RESPERR_RANGE] == 2'b10))
                   );

    assert_checker #(
                       2,  // security_level
                       "RXDATFLIT receive Non data Error!")
                   rxdatflit_non_data_error_check (
                       .clk   (clk_i),
                       .rst   (rst_i),
                       .cond  (rxdatflitv_d1_i & (rxdatflit_d1_i[`CHIE_DAT_FLIT_RESPERR_RANGE] == 2'b11))
                   );
`endif
endmodule
