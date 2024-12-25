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
//------------------------------------------------------------------------
// This is designed to monitor a given condition and report errors
// based on a specified security level.
//
// Parameters:
// security_level: severity of the report when the condition is false.
// message: message to be displayed with the report.
//
// Security Levels:
// Level 0: Normal Information.
// Level 1: Warning might have impact.
// Level 2: Error must be solved.
// Level 3: Fatal terminates the simulation.
//------------------------------------------------------------------------

module assert_checker #(
    parameter int security_level = 0,
    parameter string message = ""
) (
    input logic clk,
    input logic rst,
    input logic cond
);

  // Property to check the test expression for different security levels
  property check_condition;
    @(posedge clk) disable iff (rst) (~cond);  // Assert when condition is false
  endproperty

  // Function to handle errors based on security level
  function void level_handler(input int level, input string msg);
    case (level)
      0: $display("Assertion info level 0: %s", msg);
      1: $warning("Assertion warning level 1: %s", msg);
      2: $error("Assertion failed level 2: %s", msg);
      3: $fatal("Assertion failed level 3: %s", msg);
      default: $fatal(4, "Unsupported security level: %0d", level);
    endcase
  endfunction

  // Assert the property and call level_handler on failure
  generate
    if (security_level >= 2 && security_level <= 3) begin
      assert property (check_condition)
      else level_handler(security_level, message);
    end
    else if (security_level >= 0 && security_level <= 1) begin
      always_ff @(posedge clk or posedge rst) begin
        if (cond) begin
          level_handler(security_level, message);
        end
      end
    end
    else begin
      initial $fatal(4, "Unsupported security level: %0d", security_level);
    end
  endgenerate

endmodule
