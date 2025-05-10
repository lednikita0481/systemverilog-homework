//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_2_pipe
(
    input         clk,
    input         rst,

    input         arg_vld,
    input  [31:0] a,
    input  [31:0] b,
    input  [31:0] c,

    output        res_vld,
    output [31:0] res
);

    // Task:
    //
    // Implement a pipelined module formula_2_pipe that computes the result
    // of the formula defined in the file formula_2_fn.svh.
    //
    // The requirements:
    //
    // 1. The module formula_2_pipe has to be pipelined.
    //
    // It should be able to accept a new set of arguments a, b and c
    // arriving at every clock cycle.
    //
    // It also should be able to produce a new result every clock cycle
    // with a fixed latency after accepting the arguments.
    //
    // 2. Your solution should instantiate exactly 3 instances
    // of a pipelined isqrt module, which computes the integer square root.
    //
    // 3. Your solution should save dynamic power by properly connecting
    // the valid bits.
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm#state_0

    localparam PIPE_DEPTH = 4;

    logic        first_sqrt_vld;
    logic [15:0] first_sqrt_out;

    logic        second_sqrt_vld;
    logic [15:0] second_sqrt_out;

    logic [31:0] input_a_delay [8];
    logic [31:0] input_b_delay [4];

    always_ff @(posedge clk) begin
        if (rst) begin
            for (int i = 0; i < 8; i++)
                input_a_delay[i] <= '0;
            for (int i = 0; i < 4; i++)
                input_b_delay[i] <= '0;
        end else begin
            input_a_delay[0] <= arg_vld ? a : input_a_delay[0];
            input_b_delay[0] <= arg_vld ? b : input_b_delay[0];

            for (int i = 1; i < 8; i++)
                input_a_delay[i] <= input_a_delay[i-1];

            for (int i = 1; i < 4; i++)
                input_b_delay[i] <= input_b_delay[i-1];
        end
    end

    isqrt #(.n_pipe_stages(PIPE_DEPTH)) sqrt_first (
        .clk(clk),
        .rst(rst),
        .x_vld(arg_vld),
        .x(c),
        .y_vld(first_sqrt_vld),
        .y(first_sqrt_out)
    );

    isqrt #(.n_pipe_stages(PIPE_DEPTH)) sqrt_second (
        .clk(clk),
        .rst(rst),
        .x_vld(first_sqrt_vld),
        .x(input_b_delay[3] + {16'b0, first_sqrt_out}),
        .y_vld(second_sqrt_vld),
        .y(second_sqrt_out)
    );

    isqrt #(.n_pipe_stages(PIPE_DEPTH)) sqrt_final (
        .clk(clk),
        .rst(rst),
        .x_vld(second_sqrt_vld),
        .x(input_a_delay[7] + {16'b0, second_sqrt_out}),
        .y_vld(res_vld),
        .y(res[15:0])
    );

    assign res[31:16] = '0;


endmodule
