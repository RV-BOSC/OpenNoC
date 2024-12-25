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

module sync_fifo #(
        parameter FIFO_ENTRIES_WIDTH = 32,
        parameter FIFO_ENTRIES_DEPTH = 16,
        parameter FIFO_BYP_ENABLE    = 1'b0
    )
    (
        // global inputs
        clk,
        rst,

        // inputs
        push,
        pop,
        data_in,

        // outputs
        data_out,
        empty,
        full,
        count
    );
    // localparam
    localparam FIFO_PTR_WIDTH = (FIFO_ENTRIES_DEPTH == 1)? 0 : $clog2(FIFO_ENTRIES_DEPTH);

    // global inputs
    input  wire                          clk;
    input  wire                          rst;

    // inputs
    input  wire                          push;
    input  wire                          pop;
    input  wire [FIFO_ENTRIES_WIDTH-1:0] data_in;

    // outputs
    output wire [FIFO_ENTRIES_WIDTH-1:0] data_out;
    output wire                          empty;
    output wire                          full;
    output reg  [FIFO_PTR_WIDTH:0]       count;

    // wire
    wire                                 fifo_byp;
    wire                                 rd_ptr_en;
    wire                                 wr_ptr_en;
    wire [FIFO_PTR_WIDTH-1:0]            rd_ptr_ns;
    wire [FIFO_PTR_WIDTH-1:0]            wr_ptr_ns;
    wire [FIFO_PTR_WIDTH:0]              fifo_cnt;
    wire                                 upd_fifo_cnt;
    wire                                 empty_ns;
    wire                                 full_ns;

    // reg
    reg  [FIFO_ENTRIES_WIDTH-1:0]        fifo_mem [0:FIFO_ENTRIES_DEPTH-1];
    reg  [FIFO_ENTRIES_WIDTH-1:0]        fifo_mem_q;
    reg  [FIFO_PTR_WIDTH-1:0]            rd_ptr;
    reg  [FIFO_PTR_WIDTH-1:0]            wr_ptr;
    reg                                  empty_q;
    reg                                  full_q;
    reg  [FIFO_ENTRIES_WIDTH-1:0]        rd_mem_data;

    genvar i;

generate if(FIFO_ENTRIES_DEPTH == 1)begin
            assign upd_fifo_cnt = push ^ pop;

            always @(posedge clk or posedge rst) begin
                if (rst == 1'b1)
                    count <= 1'b0;
                else if (upd_fifo_cnt == 1'b1)
                    count <= push;
            end

            assign full  = count;
            assign empty = ~count;

            always @(posedge clk)begin
                if (push == 1'b1)
                    fifo_mem_q <= data_in;
            end

            assign data_out = (empty & FIFO_BYP_ENABLE)? data_in : fifo_mem_q;
        end
        else begin
            // bypass
            assign fifo_byp = push & pop & empty & FIFO_BYP_ENABLE;

            // read pointer
            assign rd_ptr_en = pop & ~fifo_byp;
            assign rd_ptr_ns = (rd_ptr == (FIFO_ENTRIES_DEPTH-1))? {FIFO_PTR_WIDTH{1'b0}} : (rd_ptr[FIFO_PTR_WIDTH-1:0] + 1'b1);

            always @(posedge clk or posedge rst)begin
                if(rst == 1'b1)
                    rd_ptr <= {FIFO_PTR_WIDTH{1'b0}};
                else if(rd_ptr_en == 1'b1)
                    rd_ptr <= rd_ptr_ns;
            end

            // write pointer
            assign wr_ptr_en = push & ~fifo_byp;
            assign wr_ptr_ns = (wr_ptr == (FIFO_ENTRIES_DEPTH-1))? {FIFO_PTR_WIDTH{1'b0}} : (wr_ptr[FIFO_PTR_WIDTH-1:0] + 1'b1);

            always @(posedge clk or posedge rst)begin
                if(rst == 1'b1)
                    wr_ptr <= {FIFO_PTR_WIDTH{1'b0}};
                else if(wr_ptr_en == 1'b1)
                    wr_ptr <= wr_ptr_ns;
            end

            // write fifo memory
            for(i=0;i<FIFO_ENTRIES_DEPTH;i=i+1)begin
                always @(posedge clk)begin
                    if((wr_ptr == i) & push)begin
                        fifo_mem[i] <= data_in;
                    end
                end
            end

            // read fifo memory
            integer j;
            always@*begin
                for(j=0;j<FIFO_ENTRIES_DEPTH;j=j+1)begin
                    if(rd_ptr == j)begin
                        rd_mem_data = fifo_mem[j];
                    end
                end
            end

            // fifo count logic
            assign fifo_cnt = wr_ptr_en? (count + 1'b1) : (count - 1'b1);

            assign upd_fifo_cnt = (push ^ pop) & ~fifo_byp;

            always @(posedge clk or posedge rst)begin
                if(rst == 1'b1)
                    count <= {(FIFO_PTR_WIDTH+1){1'b0}};
                else if(upd_fifo_cnt == 1'b1)
                    count <= fifo_cnt;
            end

            // fifo empty logic
            assign empty_ns = (count == {{FIFO_PTR_WIDTH{1'b0}},1'b1}) && ~push;

            always @(posedge clk or posedge rst)begin
                if(rst == 1'b1)
                    empty_q <= 1'b1;
                else if(upd_fifo_cnt == 1'b1)
                    empty_q <= empty_ns;
            end

            assign empty = empty_q;

            // fifo full logic
            assign full_ns = (count == (FIFO_ENTRIES_DEPTH-1)) & ~pop;

            always @(posedge clk or posedge rst)begin
                if(rst == 1'b1)
                    full_q <= 1'b0;
                else if(upd_fifo_cnt == 1'b1)
                    full_q <= full_ns;
            end

            assign full = full_q;

            // drive and select read data
            assign data_out = (empty_q & FIFO_BYP_ENABLE)? data_in : rd_mem_data;
        end
    endgenerate
    // Assertion Checker
`ifdef ASSERT_CHECKER_ON

    assert_checker #(
                       2,  // security_level
                       "Push asserted when FIFO is full and pop deasserted!")
                   push_full_check (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (push & ~pop & full)
                   );

    assert_checker #(
                       2,  // security_level
                       "Pop asserted when FIFO is empty!")
                   pop_empty_check0 (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (pop & empty & ~FIFO_BYP_ENABLE)
                   );

    assert_checker #(
                       2,  // security_level
                       "Pop asserted when FIFO is empty and push deasserted!")
                   pop_empty_check1 (
                       .clk   (clk),
                       .rst   (rst),
                       .cond  (pop & ~push & empty & & FIFO_BYP_ENABLE)
                   );
`endif

endmodule
