// -------------------------------------------------------
// ALU Verification — UCF EEE 5703
// Author: Jonathan Joslin
// Date: October 2024
//
// Testbench Coverage demonstration developed to show valid coverage of an ALU design provided by generative AI in a student project
// Coverage, cross-coverage and test points developed by Jonathan Joslin
// -------------------------------------------------------

`timescale 1ns / 1ps

module ALU_16bit_tb;

// Inputs
reg [15:0] A, B;
reg [3:0] opcode;
reg [6:0] shift_amt;

// Outputs
wire [15:0] result;
wire [31:0] mul_result;
wire carry_out, zero_flag, negative_flag, overflow_flag;

// Instantiate the Unit Under Test (UUT)
ALU_16bit uut (
    .A(A), 
    .B(B), 
    .opcode(opcode), 
    .shift_amt(shift_amt), 
    .result(result),
    .mul_result(mul_result),
    .carry_out(carry_out), 
    .zero_flag(zero_flag), 
    .negative_flag(negative_flag), 
    .overflow_flag(overflow_flag)
);

// Covergroup for opcode
  covergroup cg_opcode_ALU_functions with function sample(bit [3:0] op, bit [15:0] A, bit [15:0] B, bit [6:0] shift_amt, bit z_flag, bit of_flag, bit n_flag);
      cp_opcode_arith: coverpoint op {
          bins add = {4'b0000};
          bins sub = {4'b0001};
          bins mul = {4'b0010};
          bins logical = {4'b0011, 4'b0100, 4'b0101, 4'b0110, 4'b0111};
      }

      cp_opcode_logic: coverpoint op {
        bins AND = {4'b0011};
        bins OR  = {4'b0100};
        bins NOT = {4'b0101};
        bins SHL = {4'b0110};
        bins SHR = {4'b0111};
      }

       cp_zero: coverpoint z_flag {
          bins zero = {1'b1};
          bins non_zero = {1'b0};
      }
      cp_negative: coverpoint n_flag {
        bins negative = {1'b1};
        bins non_negative = {1'b0};
      }
      cp_overflow: coverpoint of_flag {
          bins of = {1'b1};
          bins no_of = {1'b0};
      }
      coverpoint A {
        bins zero = {[0:0]};
        bins big = {[32768:$]};
        bins other = {[1:32767]};
        bins max = {16'hFFFF};
      }
      coverpoint B {
        bins zero = {[0:0]};
        bins big = {[32768:$]};
        bins other = {[1:32767]};
        bins max = {16'hFFFF};
      }
    coverpoint shift_amt {
      bins zero = {[0:0]};
      bins max = {16'd16};
      bins other = {[1:15]};
    }


      addition: cross cp_opcode_arith, A, B{
        option.cross_auto_bin_max = 0;
        bins addZeros = binsof(cp_opcode_arith.add) && binsof(A.zero) && binsof(B.zero); // test zero
        bins addLarge = binsof(cp_opcode_arith.add) && binsof(A.big) && binsof(B.big); // test rollover

      }
    
      subtraction: cross cp_opcode_arith, A, B{
        option.cross_auto_bin_max = 0;
        bins neg_output_B = binsof(cp_opcode_arith.sub) && binsof(A.zero) && (binsof(B.other) || binsof(B.big));
        bins neg_output_A = binsof(cp_opcode_arith.sub) && binsof(B.zero) && (binsof(A.other) || binsof(A.big));
    
      }
      multiplication: cross cp_opcode_arith, A, B {
        option.cross_auto_bin_max = 0;
        bins mult_AisZeroB_other = binsof(cp_opcode_arith.mul) && binsof(A.zero) && (binsof(B.other)||binsof(B.big)); // test to produce zero
        bins mult_A_otherBisZero = binsof(cp_opcode_arith.mul) && (binsof(A.other) || binsof(A.big)) && binsof(B.zero); // test to produce zero
        bins largeMultiplication = binsof(cp_opcode_arith.mul) && binsof(A.big) && binsof(B.big); // test to produce rollover
      }
    
    
    // logic
    AND: cross cp_opcode_logic, A, B {
    	option.cross_auto_bin_max = 0;
      	bins and_zeros = binsof(cp_opcode_logic.AND) && binsof(A.zero) && binsof(B.zero);
        bins Amax_and_Bzero = binsof(cp_opcode_logic.AND) && binsof(A.max) && binsof(B.zero);
        bins Azero_and_Bmax = binsof(cp_opcode_logic.AND) && binsof(A.zero) && binsof(B.max);
     	// all other cases 
      	bins all_others = binsof(cp_opcode_logic.AND) && (binsof(A.other) || binsof(A.big)) && (binsof(B.other)||binsof(B.big));


    }
    OR: cross cp_opcode_logic, A, B {
    	option.cross_auto_bin_max = 0;
      bins or_zeros = binsof(cp_opcode_logic.OR) && binsof(A.zero) && binsof(B.zero);
      bins Amax_and_Bzero = binsof(cp_opcode_logic.OR) && binsof(A.max) && binsof(B.zero);
      bins Azero_and_Bmax = binsof(cp_opcode_logic.OR) && binsof(A.zero) && binsof(B.max);
      // all other cases
      bins all_others = binsof(cp_opcode_logic.OR) && (binsof(A.other) || binsof(A.big)) && (binsof(B.other)||binsof(B.big));
    }
    SLL: cross cp_opcode_logic, A, shift_amt {
   		option.cross_auto_bin_max = 0;
      bins shift_zeros = binsof(cp_opcode_logic.SHL) && binsof(A.zero);
      bins shift_by_zero = binsof(cp_opcode_logic.SHL) && (binsof(A.other) || binsof(A.big)) && binsof(shift_amt.zero);
      bins shift_by_max = binsof(cp_opcode_logic.SHL) && (binsof(A.other) || binsof(A.big)) && binsof(shift_amt.max);
    }
    SRL: cross cp_opcode_logic, A, shift_amt {
   		option.cross_auto_bin_max = 0;
      bins shift_zeros = binsof(cp_opcode_logic.SHR) && binsof(A.zero);
      bins shift_by_zero = binsof(cp_opcode_logic.SHR) && (binsof(A.other) || binsof(A.big)) && binsof(shift_amt.zero);
      bins shift_by_max = binsof(cp_opcode_logic.SHR) && (binsof(A.other) || binsof(A.big)) && binsof(shift_amt.max);
    }
    
      
endgroup

// Covergroup for results
covergroup cg_result with function sample(bit [15:0] res, bit z_flag, bit n_flag);
    cp_zero: coverpoint z_flag {
        bins zero = {1'b1};
        bins non_zero = {1'b0};
    }
    cp_negative: coverpoint n_flag {
        bins negative = {1'b1};
        bins non_negative = {1'b0};
    }
endgroup

cg_opcode_ALU_functions cg_op;
cg_result cg_res;


  
// Class for generating random test vectors
class TestVector;
    rand bit [15:0] A, B;
    randc bit [3:0] opcode;
    rand bit [6:0] shift_amt;
  
      logic rand_select; // To hold the random choice

    // Pre-randomize function
    function void pre_randomize();
        // Generate a random value and assign it to rand_select
        rand_select = $urandom_range(0, 1);
    endfunction
  
  constraint usable_op{
  	opcode < 8;
  }

    // Constraint to limit the range of shift amounts for shift operations
    
	constraint shift { 
      if (opcode == 4'b0110 || opcode == 4'b0111) {
        shift_amt dist {
          [0 : 0]      :/ 12,
          [1:15] :/ 1,
          [16:16] :/8
        };
        
        (shift_amt == 0) -> A dist {
            [0 : 0]      :/ 6,
            [100 : 16'hFF00] :/ 2,
            [16'hFFFE : $] :/ 2
          };        	
        A dist {
          [0 : 0]      :/ 4,
          [100 : 16'hFF00] :/ 2,
          [16'hFFFE : $] :/ 4
        };        
      }
    }
  
  constraint arithmetic {
    if (opcode == 4'b0000) { //addition
          A dist {
            [0 : 0]      :/ 5,
            [100 : 16'hFF00] :/ 2,
            [16'hFF00 : $] :/ 2
          };

          B dist {
            [0 : 0]      :/ 5,
            [100 : 16'hFF00] :/ 2,
            [16'hFF00 : $] :/ 2
          };
      }
      if(opcode == 4'b0010){ // multiplication
          A dist {
            [0 : 0]      :/ 4,
            [1 : $] :/ 2,
            [32000:$] :/4
          };

          B dist {
            [0 : 0]      :/ 4,
            [1 : $] :/ 2,
            [32000:$] :/4
          };
        }
        if(opcode == 4'b0001){ // subtraction

          (A == 0) -> B dist {
            [0:0] :/2,
            [1:32767] :/4,
            [32768:$] :/4
          };

          (B == 0) -> A dist {
            [0:0] :/2,
            [1:32767] :/4,
            [32768:$] :/4
          };

          // Default fallback constraints (always active, but don't conflict due to implication guards above)
          A dist {
            [0:0] :/3,
            [1:32767] :/3,
            [32768:$] :/4
          };

          B dist {
            [0:0] :/3,
            [1:32767] :/3,
            [32768:$] :/4
          };
      }
    }

	constraint logical {
        if (opcode == 4'b0100 || opcode == 4'b0011) {
            A dist {
              [0:0] :/ 5,
              [1:16'hfffe] :/ 3,
              [16'hffff:16'hffff] :/ 6
            };

            B dist {
              [0:0] :/ 5,
              [1:16'hfffe] :/ 3,
              [16'hffff:16'hffff] :/ 6
            };

            // Use the rand_select variable for conditional logic
          if (rand_select == 0) {
                (B == 16'hffff) -> (A == 0);
          } else {
                (A == 16'hffff) -> (B == 0);
            }
        }
    }

 
    // Additional constraints can be added here to refine the test cases
  
endclass

initial begin
    TestVector tv = new();
    
    // Initialize covergroups
    cg_op = new();
    cg_res = new();

    // Random test generation loop
  repeat (64) begin // Adjust the number of iterations as needed
      assert(tv.randomize()) else $error("Randomization failed");
        A = tv.A;
        B = tv.B;
        opcode = tv.opcode;
        shift_amt = tv.shift_amt;
		
        #10; // Delay to allow operation to complete

    cg_op.sample(opcode, A, B, shift_amt, zero_flag, overflow_flag, negative_flag); // Sample the opcode covergroup
    cg_res.sample(result, zero_flag, negative_flag); // Sample the result covergroup


    end
 	cg_op.stop();
  	cg_res.stop();
    $finish;
end


final
  begin
    $display("overall coverage = %0f", $get_coverage());
    $display("Op Code coverage = %0f", cg_op.get_coverage());
    $display("Result coverage = %0f", cg_op.get_coverage());
  end
  
endmodule
