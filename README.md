# SystemVerilog Functional Coverage Demonstration: 16-bit ALU
This repository contains a SystemVerilog testbench demonstrating functional coverage principles and constrained randomization techniques applied to a 16-bit ALU. It was developed as part of the UCF EEE 5703 coursework.

The primary objective of this project was to design and demonstrate meaningful tests and coverage metrics for ALU functionality. The testbench leverages the power of constraints to optimize coverage with as few test vectors as possible. Using this approach, I was able to achieve 100% functional coverage of the ALU with just 64 test vectors.
Coverage Highlights:

    All 9 opcodes were covered, including:
    Addition, Subtraction, Multiplication, AND, OR, NOT, Shift Left (SHL), and Shift Right (SHR).

    For arithmetic operations, key operand scenarios were considered:

        Zero

        Maximum value

        Negative values

    Cross-coverage was implemented to verify interaction between operands and results, including:

        Negative results

        Overflow/rollover behavior

The Device Under Test (DUT) is a 16-bit ALU generated by an LLM, provided by the course professor.
Running the Testbench:

To view and execute the testbench, visit the EDA Playground link:
https://www.edaplayground.com/x/NK94
