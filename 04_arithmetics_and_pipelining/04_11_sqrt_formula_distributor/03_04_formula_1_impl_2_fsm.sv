//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the formula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value
    //
    // You can read the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    enum logic [2:0] {
        IDLE,
        SEND_AB,
        WAIT_AB,
        SEND_C,
        WAIT_C,
        DONE
    } 
    state, new_state;

    logic [31:0] a_reg,  b_reg,  c_reg;
    logic [15:0] a_sqrt, b_sqrt, c_sqrt;

    always_comb 
    begin
        new_state = state;

        res_vld = 0;
        res = 0;
        isqrt_1_x_vld = 0;
        isqrt_2_x_vld = 0;
        isqrt_1_x = 0;
        isqrt_2_x = 0;

        case (state)
            IDLE: 
                if (arg_vld) 
                    new_state = SEND_AB;

            SEND_AB: 
            begin
                isqrt_1_x_vld = 1;
                isqrt_1_x = a_reg;
                isqrt_2_x_vld = 1;
                isqrt_2_x = b_reg;
                new_state = WAIT_AB;
            end

            WAIT_AB: 
                if (isqrt_1_y_vld && isqrt_2_y_vld) 
                    new_state = SEND_C;

            SEND_C: 
            begin
                isqrt_1_x_vld = 1;
                isqrt_1_x = c_reg;
                new_state = WAIT_C;
            end

            WAIT_C: 
                if (isqrt_1_y_vld) 
                    new_state = DONE;

            DONE: 
            begin
                res_vld = 1;
                res = a_sqrt + b_sqrt + c_sqrt;
                new_state = IDLE;
            end
        endcase
    end


    always_ff @(posedge clk) 
    begin
        if (rst)
            state <= IDLE;
        else
            state <= new_state;

        if (arg_vld && state == IDLE) 
        begin
            a_reg <= a;
            b_reg <= b;
            c_reg <= c;
        end

        if (state == WAIT_AB) 
        begin
            if (isqrt_1_y_vld) 
                a_sqrt <= isqrt_1_y;
            if (isqrt_2_y_vld) 
                b_sqrt <= isqrt_2_y;
        end

        if (state == WAIT_C && isqrt_1_y_vld) 
            c_sqrt <= isqrt_1_y;
    end

endmodule
