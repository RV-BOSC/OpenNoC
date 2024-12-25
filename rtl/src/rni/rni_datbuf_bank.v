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
// This block contains 4 data buffer bank

`include "axi4_defines.v"
`include "chie_defines.v"
`include "rni_defines.v"
`include "rni_param.v"

module rni_datbuf_bank `RNI_PARAM
    (
        //global port
        clk_i
        ,rst_i

        //bank0
        ,bank0_wr_en_i
        ,bank0_wr_addr_i
        ,bank0_wr_data_i
        ,bank0_rd_en_i
        ,bank0_rd_addr_i
        ,bank0_rd_data_o

        //bank1
        ,bank1_wr_en_i
        ,bank1_wr_addr_i
        ,bank1_wr_data_i
        ,bank1_rd_en_i
        ,bank1_rd_addr_i
        ,bank1_rd_data_o

        //bank2
        ,bank2_wr_en_i
        ,bank2_wr_addr_i
        ,bank2_wr_data_i
        ,bank2_rd_en_i
        ,bank2_rd_addr_i
        ,bank2_rd_data_o

        //bank3
        ,bank3_wr_en_i
        ,bank3_wr_addr_i
        ,bank3_wr_data_i
        ,bank3_rd_en_i
        ,bank3_rd_addr_i
        ,bank3_rd_data_o
    );
    //global port
    input  wire                                 clk_i;
    input  wire                                 rst_i;

    //bank0
    input  wire                                 bank0_wr_en_i;
    input  wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]   bank0_wr_addr_i;
    input  wire [`RNI_RD_BANK_DATA_WIDTH-1:0]   bank0_wr_data_i;
    input  wire                                 bank0_rd_en_i;
    input  wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]   bank0_rd_addr_i;
    output wire [`RNI_RD_BANK_DATA_WIDTH-1:0]   bank0_rd_data_o;

    //bank1
    input  wire                                 bank1_wr_en_i;
    input  wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]   bank1_wr_addr_i;
    input  wire [`RNI_RD_BANK_DATA_WIDTH-1:0]   bank1_wr_data_i;
    input  wire                                 bank1_rd_en_i;
    input  wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]   bank1_rd_addr_i;
    output wire [`RNI_RD_BANK_DATA_WIDTH-1:0]   bank1_rd_data_o;

    //bank2
    input  wire                                 bank2_wr_en_i;
    input  wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]   bank2_wr_addr_i;
    input  wire [`RNI_RD_BANK_DATA_WIDTH-1:0]   bank2_wr_data_i;
    input  wire                                 bank2_rd_en_i;
    input  wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]   bank2_rd_addr_i;
    output wire [`RNI_RD_BANK_DATA_WIDTH-1:0]   bank2_rd_data_o;

    //bank3
    input  wire                                 bank3_wr_en_i;
    input  wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]   bank3_wr_addr_i;
    input  wire [`RNI_RD_BANK_DATA_WIDTH-1:0]   bank3_wr_data_i;
    input  wire                                 bank3_rd_en_i;
    input  wire [`RNI_RD_BANK_ADDR_WIDTH-1:0]   bank3_rd_addr_i;
    output wire [`RNI_RD_BANK_DATA_WIDTH-1:0]   bank3_rd_data_o;

    //reg
    reg [`RNI_RD_BANK_DATA_WIDTH-1:0]           bank0_rd_data;
    reg [`RNI_RD_BANK_DATA_WIDTH-1:0]           bank1_rd_data;
    reg [`RNI_RD_BANK_DATA_WIDTH-1:0]           bank2_rd_data;
    reg [`RNI_RD_BANK_DATA_WIDTH-1:0]           bank3_rd_data;
    reg [`RNI_RD_BANK_DATA_WIDTH-1:0]           datbank0_q [RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [`RNI_RD_BANK_DATA_WIDTH-1:0]           datbank1_q [RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [`RNI_RD_BANK_DATA_WIDTH-1:0]           datbank2_q [RNI_AR_ENTRIES_NUM_PARAM-1:0];
    reg [`RNI_RD_BANK_DATA_WIDTH-1:0]           datbank3_q [RNI_AR_ENTRIES_NUM_PARAM-1:0];

    //parameter
    integer i;
    genvar  bk_entry;

    //write data bank
    generate
        for (bk_entry=0; bk_entry<RNI_AR_ENTRIES_NUM_PARAM; bk_entry=bk_entry+1) begin
            always @(posedge clk_i) begin
                if(bank0_wr_en_i && (bank0_wr_addr_i == bk_entry))
                    datbank0_q[bk_entry] <= bank0_wr_data_i;
            end
            always @(posedge clk_i) begin
                if(bank1_wr_en_i && (bank1_wr_addr_i == bk_entry))
                    datbank1_q[bk_entry] <= bank1_wr_data_i;
            end
            always @(posedge clk_i) begin
                if(bank2_wr_en_i && (bank2_wr_addr_i == bk_entry))
                    datbank2_q[bk_entry] <= bank2_wr_data_i;
            end
            always @(posedge clk_i) begin
                if(bank3_wr_en_i && (bank3_wr_addr_i == bk_entry))
                    datbank3_q[bk_entry] <= bank3_wr_data_i;
            end
        end
    endgenerate

    //read data bank
    always @* begin
        bank0_rd_data = {`RNI_RD_BANK_DATA_WIDTH{1'b0}};
        for(i=0; i<RNI_AR_ENTRIES_NUM_PARAM; i=i+1) begin
            if(bank0_rd_en_i && (bank0_rd_addr_i == i))
                bank0_rd_data = datbank0_q[i];
        end
    end

    always @* begin
        bank1_rd_data = {`RNI_RD_BANK_DATA_WIDTH{1'b0}};
        for(i=0; i<RNI_AR_ENTRIES_NUM_PARAM; i=i+1) begin
            if(bank1_rd_en_i && (bank1_rd_addr_i == i))
                bank1_rd_data = datbank1_q[i];
        end
    end

    always @* begin
        bank2_rd_data = {`RNI_RD_BANK_DATA_WIDTH{1'b0}};
        for(i=0; i<RNI_AR_ENTRIES_NUM_PARAM; i=i+1) begin
            if(bank2_rd_en_i && (bank2_rd_addr_i == i))
                bank2_rd_data = datbank2_q[i];
        end
    end

    always @* begin
        bank3_rd_data = {`RNI_RD_BANK_DATA_WIDTH{1'b0}};
        for(i=0; i<RNI_AR_ENTRIES_NUM_PARAM; i=i+1) begin
            if(bank3_rd_en_i && (bank3_rd_addr_i == i))
                bank3_rd_data = datbank3_q[i];
        end
    end

    assign bank0_rd_data_o = bank0_rd_data;
    assign bank1_rd_data_o = bank1_rd_data;
    assign bank2_rd_data_o = bank2_rd_data;
    assign bank3_rd_data_o = bank3_rd_data;

endmodule
