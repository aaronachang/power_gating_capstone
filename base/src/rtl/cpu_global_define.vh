`ifdef FIBONACCI
    `define BENCHMARK "fibonacci.v"
`elsif BRANCH_TEST
    `define BENCHMARK "branch_test.v"
`elsif FIBONACCI_SHIFT
    `define BENCHMARK "fibonacci_shift.v"
`else
    `define BENCHMARK "test_instr.v"
`endif

