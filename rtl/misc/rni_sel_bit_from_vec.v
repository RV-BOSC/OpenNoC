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

module rni_sel_bit_from_vec
    #(
         parameter VEC_WIDTH = -1
     )
     (
         in_vec,
         startx,
         ptr_dec,
         found
     );
    localparam VEC_LOG2_WIDTH = $clog2(VEC_WIDTH);
    //input
    input wire [VEC_WIDTH-1:0]  in_vec;
    input wire [VEC_WIDTH-1:0]  startx;
    //output
    output wire [VEC_WIDTH-1:0] ptr_dec;
    output wire                 found;

    //internal signals
    wire [VEC_WIDTH-1:0]    upper_mask;
    wire [VEC_WIDTH-1:0]    lower_mask;
    wire [VEC_WIDTH-1:0]    in_vecx;
    reg [VEC_WIDTH-1:0]     upper_ptr_dec;
    reg [VEC_WIDTH-1:0]     lower_ptr_dec;
    reg upper_found;
    reg lower_found;
    reg [VEC_WIDTH-1:0] tmp_low;
    reg [VEC_WIDTH-1:0] tmp_upr;

    integer ii;

    assign lower_mask[VEC_WIDTH-1:0] = (startx[VEC_WIDTH-1:0] - 1'b1);
    assign upper_mask[VEC_WIDTH-1:0] = ~lower_mask[VEC_WIDTH-1:0];

    always@* begin:find1_from_bit0
        lower_found = 1'b0;
        lower_ptr_dec = {VEC_WIDTH{1'b0}};
        for (ii = 0; ii < VEC_WIDTH; ii = ii + 1) begin
            if (in_vec[ii] == 1'b1) begin
                lower_ptr_dec[ii] = 1'b1;
                lower_found = 1'b1;
                disable find1_from_bit0;
            end
        end
    end

    assign in_vecx[VEC_WIDTH-1:0] = upper_mask[VEC_WIDTH-1:0] & in_vec[VEC_WIDTH-1:0];

    always@* begin:hnf_sel_bit_from_nxt
        upper_found = 1'b0;
        upper_ptr_dec = {VEC_WIDTH{1'b0}};
        for (ii = 0; ii < VEC_WIDTH; ii = ii + 1) begin
            if (in_vecx[ii] == 1'b1) begin
                upper_ptr_dec[ii] = 1'b1;
                upper_found = 1'b1;
                disable hnf_sel_bit_from_nxt;
            end
        end
    end

    assign found = upper_found | lower_found;
    assign ptr_dec[VEC_WIDTH-1:0] = upper_found ? upper_ptr_dec[VEC_WIDTH-1:0] : lower_ptr_dec[VEC_WIDTH-1:0];

endmodule
