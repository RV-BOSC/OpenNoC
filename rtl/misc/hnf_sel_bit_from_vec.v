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
*/

module hnf_sel_bit_from_vec
    #(
         parameter ENTRIES_NUM = -1
     )
     (
         entry_vec,
         start_entry,
         entry_ptr_sel,
         found
     );
    //input
    input wire [ENTRIES_NUM-1:0]  entry_vec;
    input wire [ENTRIES_NUM-1:0]  start_entry;
    //output
    output wire [ENTRIES_NUM-1:0] entry_ptr_sel;
    output wire                 found;

    //internal signals
    wire [ENTRIES_NUM-1:0]    upper_mask;
    wire [ENTRIES_NUM-1:0]    lower_mask;
    wire [ENTRIES_NUM-1:0]    in_vecx;
    reg [ENTRIES_NUM-1:0]     upper_ptr_dec;
    reg [ENTRIES_NUM-1:0]     lower_ptr_dec;
    wire upper_found;
    wire lower_found;
    reg tmp_flag_low;
    reg tmp_flag_high;

    integer ii;

    assign lower_mask[ENTRIES_NUM-1:0] = ((start_entry[ENTRIES_NUM-1:0]) - 1'b1);
    assign upper_mask[ENTRIES_NUM-1:0] = ~lower_mask[ENTRIES_NUM-1:0];

    always@*begin
        lower_ptr_dec = {ENTRIES_NUM{1'b0}};
        tmp_flag_low = 0;
        for (ii = 0; ii < ENTRIES_NUM; ii = ii + 1) begin
            if (!tmp_flag_low) begin
                lower_ptr_dec[ii] = entry_vec[ii];
                tmp_flag_low = entry_vec[ii];
            end
        end
    end
    assign lower_found = |lower_ptr_dec[ENTRIES_NUM-1:0];

    assign in_vecx[ENTRIES_NUM-1:0] = upper_mask[ENTRIES_NUM-1:0] & entry_vec[ENTRIES_NUM-1:0];

    always@*begin
        upper_ptr_dec = {ENTRIES_NUM{1'b0}};
        tmp_flag_high = 0;
        for (ii = 0; ii < ENTRIES_NUM; ii = ii + 1) begin
            if (!tmp_flag_high) begin
                upper_ptr_dec[ii] = in_vecx[ii];
                tmp_flag_high = in_vecx[ii];
            end
        end
    end
    assign upper_found = |upper_ptr_dec[ENTRIES_NUM-1:0];

    assign found = upper_found | lower_found;
    assign entry_ptr_sel[ENTRIES_NUM-1:0] = upper_found ? upper_ptr_dec[ENTRIES_NUM-1:0] : lower_ptr_dec[ENTRIES_NUM-1:0];

endmodule
