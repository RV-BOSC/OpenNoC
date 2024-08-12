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

`include "chie_defines.v"
`include "hnf_defines.v"
`include "hnf_param.v"

module hnf_sram #(
        parameter RAM_ADDR_WIDTH = 14,
        parameter RAM_DATA_WIDTH = 512
    ) (
        CLK,
        WE,
        ADDR,
        DATA_IN,
        DATA_OUT
    );

    localparam RAM_DEPTH = 2**RAM_ADDR_WIDTH;

    input  wire                       CLK;
    input  wire                       WE;
    input  wire [RAM_ADDR_WIDTH-1:0]  ADDR;
    input  wire [RAM_DATA_WIDTH-1:0]  DATA_IN;
    output wire [RAM_DATA_WIDTH-1:0]  DATA_OUT;

    wire [RAM_DATA_WIDTH-1:0]         data_out_raw;
    reg  [RAM_DATA_WIDTH-1:0]         memory_data [RAM_DEPTH-1:0];

    integer i;
    genvar gi;


    always@(posedge CLK)begin
        if(WE) begin
            memory_data[ADDR] <= DATA_IN;
        end
        else begin
            memory_data[ADDR] <= memory_data[ADDR];
        end
    end

    assign data_out_raw[RAM_DATA_WIDTH-1:0] = memory_data[ADDR];

`ifdef HNF_DELAY_ONE_CYCLE

    reg  [RAM_DATA_WIDTH-1:0]         data_out_q;

    always@(posedge CLK)begin
        data_out_q <= data_out_raw;
    end

    assign DATA_OUT = data_out_q;
`else
    assign DATA_OUT = data_out_raw;
`endif

endmodule
